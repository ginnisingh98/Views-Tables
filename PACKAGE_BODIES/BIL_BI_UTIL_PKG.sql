--------------------------------------------------------
--  DDL for Package Body BIL_BI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_UTIL_PKG" AS
/* $Header: bilbutb.pls 120.7 2005/11/21 01:46:56 hrpandey noship $ */

g_pkg VARCHAR2(1000);


--  **********************************************************************
--        FUNCTION chkLogLevel
--
--        Purpose
--        To check if log is Enabled for Messages
--      This function is a wrapper on FND APIs for OA Common Error
--       logging framework
--
--        p_log_level = Severity; valid values are -
--                        1. Statement Level (FND_LOG.LEVEL_STATEMENT)
--                        2. Procedure Level (FND_LOG.LEVEL_PROCEDURE)
--                        3. Event Level (FND_LOG.LEVEL_EVENT)
--                        4. Exception Level (FND_LOG.LEVEL_EXCEPTION)
--                        5. Error Level (FND_LOG.LEVEL_ERROR)
--                        6. Unexpected Level (FND_LOG.LEVEL_UNEXPECTED)
--
--        Output values:-
--                       = TRUE if FND Log is Enabled
--                            = FALSE if FND Log is DISABLED
--
--  **********************************************************************

FUNCTION chkLogLevel (p_log_level IN NUMBER) RETURN BOOLEAN AS


BEGIN
   /* Variable Intialization */
   g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

   IF (p_log_level >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN

     RETURN TRUE;

   END IF;

  RETURN FALSE;


 EXCEPTION
  WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

			FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                       MODULE => g_pkg || '.chkLogLevel',
		                       MESSAGE => fnd_message.get );

	  END IF;

END chkLogLevel;



--  **********************************************************************
--        PROCEDURE GET_CONV_RATE
--
--        Purpose:
--        used by get_page_params procedure, and by the
-- Top Open Opportunities report to get the currency conversion rate
--
--  **********************************************************************
PROCEDURE GET_CONV_RATE( p_as_of_date          IN  DATE
                        ,p_currency            IN  VARCHAR2
                        ,x_conv_rate_selected  OUT NOCOPY VARCHAR2
                        ,x_err_desc            OUT NOCOPY VARCHAR2
                        ,x_err_msg             OUT NOCOPY VARCHAR2
                        ,x_parameter_valid     OUT NOCOPY BOOLEAN
                        ) AS

 l_primary_currency VARCHAR2(50);
 l_parameter_valid  BOOLEAN;
 l_conv_type        VARCHAR2(20);
 l_user_currency    VARCHAR2(50);
 l_as_of_date       DATE;

BEGIN
	/* Variable Intialization */
    g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
	l_parameter_valid := TRUE;

    -- if as_of_date is greater than sysdate, then pass sysdate
    l_as_of_date:= p_as_of_date;
    IF(l_as_of_date > sysdate) THEN
        l_as_of_date:= sysdate;
    END IF;

    -- Retrieve global currency info
    l_primary_currency := bis_common_parameters.get_currency_code;

    --Update error message and error description in the case of null currency parameter

    IF l_primary_currency IS NULL THEN
                l_parameter_valid := FALSE;
                x_err_msg         := 'Null parameter(s)';
                x_err_desc        := x_err_desc ||  ' ,PRIMARY CURRENCY PROFILE';
    END IF;

    --Retrieve conversion rate
    IF l_parameter_valid = TRUE THEN
        IF INSTR(p_currency,'FII_GLOBAL1') > 0  THEN
           x_conv_rate_selected  := '1';
        ELSIF INSTR(p_currency,'FII_GLOBAL2') > 0 THEN
            x_conv_rate_selected  := '0';
       END IF;
    END IF;

    IF to_number(x_conv_rate_selected) < 0 THEN
        x_conv_rate_selected := 'NULL';
    END IF;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || '.get_conv_rate ',
		                                    MESSAGE => l_primary_currency ||', '||l_conv_type ||', '|| x_conv_rate_selected);
                     END IF;


    x_parameter_valid := l_parameter_valid;

EXCEPTION
WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '.get_conv_rate',
		                                MESSAGE => fnd_message.get );

          END IF;


END GET_CONV_RATE;


--  **********************************************************************
--        PROCEDURE GET_CURR_DATE
--
--        Purpose:
--        to get the current date from the bis_system_date
--
--  **********************************************************************
PROCEDURE GET_CURR_DATE(x_curr_date OUT NOCOPY DATE)

AS

BEGIN
   /* Variable Intialization */
   g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

   SELECT current_date_id INTO x_curr_date FROM bis_system_date;

EXCEPTION
WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);


                   FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                  MODULE => g_pkg || '.get_curr_date',
		                  MESSAGE => fnd_message.get );

           END IF;
END;



--  **********************************************************************
--        PROCEDURE GET_CURR_START_DATE
--
--        Purpose:
--        used by the reports to obtain the start date of the current period
--  **********************************************************************
PROCEDURE GET_CURR_START_DATE (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                        p_as_of_date       IN  DATE,
                        p_period_type      IN  VARCHAR2,
                        x_curr_start_date  OUT NOCOPY DATE)
AS

BEGIN
/* Variable Intialization */
   g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';


    IF (p_page_parameter_tbl.count > 0) THEN
            FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
                IF (p_page_parameter_tbl(i).parameter_name = 'BIS_CURRENT_EFFECTIVE_START_DATE') THEN
                        x_curr_start_date := p_page_parameter_tbl(i).period_date;
                END IF;
            END LOOP;
        END IF;

END;


--  **********************************************************************
--        FUNCTION GET_DBI_PARAMS
--
--        Purpose:
--        used by the portlet functions to get the default parameter values for
--  all parameters
--  **********************************************************************
FUNCTION GET_DBI_PARAMS(p_region_id IN VARCHAR2) RETURN VARCHAR2 AS

l_sg_id             VARCHAR2(100);--:=-1111;


BEGIN

	/* Variable Intialization */
    g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

    BEGIN
      l_sg_id:= JTF_RS_DBI_CONC_PUB.GET_SG_ID();

     EXCEPTION

        WHEN OTHERS THEN


                  IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                     fnd_message.set_token('Error is : ' ,SQLCODE);
                     fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '.get_dbi_params',
		                                MESSAGE => fnd_message.get );

                  END IF;

     END;


RETURN   '&BIL_DIMENSION4_FROM=All'||
        '&BIL_DIMENSION6='||'TIME_COMPARISON_TYPE+YEARLY'||
        '&BIL_DIMENSION8='|| l_sg_id ||
        '&JTF_ORG_SALES_GROUP='|| l_sg_id ||
        '&BIL_DIMENSION9=FII_GLOBAL1'||
        '&BIS_ENI_ITEM_VBH_CAT=All'||
		'&BIL_DIMENSION1=2';

END GET_DBI_PARAMS;


--  **********************************************************************
--        FUNCTION GET_DBI_SALES_GROUP_ID
--
--        Purpose:
--        used by the report functions to get the default sales group id
--  here we cannot return the string of all parameters due to PMV limitations
--  **********************************************************************
FUNCTION get_dbi_sales_group_id RETURN VARCHAR2 AS

l_sg_id             VARCHAR2(100);

BEGIN
 /* Variable Intialization */
 g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

 BEGIN
      l_sg_id:= JTF_RS_DBI_CONC_PUB.GET_SG_ID();

     EXCEPTION

        WHEN OTHERS THEN

                  IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                     fnd_message.set_token('Error is : ' ,SQLCODE);
                     fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '.get_dbi_sales_group_id',
		                                MESSAGE => fnd_message.get );
		 END IF;
     END;

RETURN l_sg_id;

END get_dbi_sales_group_id;


--  **********************************************************************
--        PROCEDURE GET_DEFAULT_QUERY
--
--        Purpose:
-- Returns default blank query to be used by individual report procedure
-- if PMV parameters are not passed correctly.
-- --------------------------------------------------------------------
PROCEDURE GET_DEFAULT_QUERY(
                          p_RegionName        IN  VARCHAR2,
                          x_SqlStr            OUT NOCOPY VARCHAR2
                          ) AS

CURSOR cAkRegionItem (pRegionName IN VARCHAR2,
		      pBilMeasureTxt IN VARCHAR2,
		      pGrandTotalTxt IN VARCHAR2,
		      pDrillTxt      IN VARCHAR2,
                      pNATxt         IN VARCHAR2,
                      pNVTxt         IN VARCHAR2,
                      pWCTxt         IN VARCHAR2)

IS


    SELECT attribute_code FROM AK_REGION_ITEMS
    WHERE REGION_CODE = pRegionName
    AND (ATTRIBUTE3 LIKE pBilMeasureTxt OR ATTRIBUTE1 IN
    (pGrandTotalTxt,pDrillTxt,pNaTxt))
    AND NVL(ATTRIBUTE3, pNVTxt) NOT LIKE pWCTxt
    ORDER BY DISPLAY_SEQUENCE;


temp_sql VARCHAR2(5000);


BEGIN
	/* Variable Intialization */
   g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

    temp_sql:= 'SELECT null viewby';


    -- Open a FOR Loop to access every individual region items


    FOR ITEM_REC IN cAkRegionItem(p_RegionName,'BIL_MEASURE%', 'GRAND_TOTAL',
'DRILL ACROSS URL','NOT_AVAILABLE_TEXT','NV','"%"')

        LOOP
        BEGIN
            temp_sql:= temp_sql ||',null '||ITEM_REC.attribute_code;
        END;


    END LOOP;


    temp_sql:= temp_sql ||' FROM DUAL WHERE 1=2 and rownum<0';
    x_SqlStr:= temp_sql;


EXCEPTION
WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '.get_default_query',
		                                MESSAGE => fnd_message.get );

           END IF;
END;


--  **********************************************************************
--        PROCEDURE GET_FORECAST_PROFILES
--
--        Purpose:
--        used to retrieve forecast category and forecast credit type profiles
--
--  **********************************************************************
PROCEDURE GET_FORECAST_PROFILES(
                          x_FstCrdtType            OUT NOCOPY  VARCHAR2
                          ) AS
BEGIN
	/* Variable Intialization */
   g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

  --  IF(FND_PROFILE.Value('BIL_BI_ASN_IMPLEMENTED') = 'Y') THEN

/*
     IF(BIL_BI_UTIL_PKG.GET_ASN_PROFILE = 'Y') THEN
        x_FstCrdtType := FND_PROFILE.Value('ASN_FRCST_CREDIT_TYPE_ID');
    ELSE
        x_FstCrdtType := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
    END IF;
*/

        x_FstCrdtType := FND_PROFILE.Value('ASN_FRCST_CREDIT_TYPE_ID');



              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                         FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                        MODULE => g_pkg || '.get_forecast_profiles ',
		                        MESSAGE => x_FstCrdtType);

              END IF;

EXCEPTION
WHEN OTHERS THEN

    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
       fnd_message.set_token('Error is : ' ,SQLCODE);
       fnd_message.set_token('Reason is : ', SQLERRM);

                       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                      MODULE => g_pkg || '.get_forecast_profiles',
		                      MESSAGE => fnd_message.get );

    END IF;
END;



--  **********************************************************************
--        PROCEDURE GET_GLOBAL_CONTS
--
--        Purpose:
--        used to retrieve the bitand_id, calendar_id, current_date, and fii_struct
-- table name
--
--  **********************************************************************
PROCEDURE GET_GLOBAL_CONTS(
                          x_bitand_id        OUT NOCOPY VARCHAR2,
                          x_calendar_id      OUT NOCOPY VARCHAR2,
                          x_curr_date        OUT NOCOPY DATE,
                          x_fii_struct       OUT NOCOPY VARCHAR2


)AS
   l_curr_date      DATE;
BEGIN
	 /* Variable Intialization */
     g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

     x_bitand_id     := 512;
     x_calendar_id   := -1;
     x_fii_struct    := 'FII_TIME_STRUCTURES';



     GET_CURR_DATE(x_curr_date => l_curr_date);

     x_curr_date:=l_curr_date;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE =>    g_pkg || '.get_global_conts ',
		                                    MESSAGE =>   x_bitand_id ||', '||x_calendar_id ||', '|| x_fii_struct);

                     END IF;


EXCEPTION
WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE =>    g_pkg || '.get_global_conts',
		                                MESSAGE =>   fnd_message.get );

           END IF;
END GET_GLOBAL_CONTS;




--  **********************************************************************
--        PROCEDURE GET_LATEST_SNAP_DATE
--
--        Purpose:
--        used by the reports that display pipeline and/or open opportunity
--        to retrieve the date of the last snapshot.  This date will be used
--        instead of the as_of_date in the front end query.
--  **********************************************************************
PROCEDURE GET_LATEST_SNAP_DATE(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                            ,p_as_of_date      IN  DATE
                            ,p_period_type      IN VARCHAR2
                            ,x_snapshot_date     OUT NOCOPY DATE )
AS

l_as_of_date     DATE;
l_start_date     DATE;
l_yesterday      DATE;
l_check_date     DATE;
l_period_type    VARCHAR2(50);
l_proc           VARCHAR2(50);

BEGIN
/* Variable Intialization */
g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_proc := 'GET_LATEST_SNAP_DATE';
l_as_of_date := trunc(p_as_of_date);
l_yesterday := trunc(sysdate) - 1;
l_period_type := p_period_type;

--if p_as_of_date is not today, then don't do anything
IF p_as_of_date <> trunc(sysdate) THEN
    x_snapshot_date := p_as_of_date;
ELSE
    --get current start_date
    BIL_BI_UTIL_PKG.GET_CURR_START_DATE(p_page_parameter_tbl  =>p_page_parameter_tbl,
                                            p_as_of_date  => l_as_of_date,
                                            p_period_type => l_period_type,
                                            x_curr_start_date  => l_start_date);

    l_start_date := trunc(l_start_date);
    --if start date is before yesterday, set check_date to yesterday,
    --if not, set check_date to start_date
    IF l_yesterday > l_start_date THEN
        l_check_date := l_yesterday;
    ELSE
        l_check_date := l_start_date;
    END IF;

    BEGIN
    --if yesterday falls in the same period, execute the query
    IF (l_start_date <= l_yesterday) THEN
        select trunc(max(period_to)) into x_snapshot_date
        from bis_refresh_log
        where object_name = 'BIL_BI_PIPELINE_F'
        and status = 'SUCCESS'
        and period_to <= l_as_of_date
        and period_to >= l_check_date;
    ELSE -- yesterday falls in a different period, return as of date
        x_snapshot_date := p_as_of_date;
    END IF;



--esapozh added on July 7, 2004 to force all reports to execute pipe queries
 if (x_snapshot_date is null) then
   x_snapshot_date := p_as_of_date;
 end if;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE =>    g_pkg ||'.'|| l_proc || '.x_snapshot_date',
		                                    MESSAGE =>   x_snapshot_date);

                     END IF;

EXCEPTION
WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '.get_latest_snapshot',
		                                MESSAGE => fnd_message.get );

          END IF;
END;

END IF;



END;


--  **********************************************************************
--        PROCEDURE GET_OTHER_PROFILES
--
--        Purpose:
--        used to retrieve the debug mode profile
--
--  **********************************************************************
PROCEDURE GET_OTHER_PROFILES(
                          x_DebugMode            OUT NOCOPY VARCHAR2
                          ) AS

BEGIN
	/* Variable Intialization */
    g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
    x_DebugMode := FND_PROFILE.Value('BIS_PMF_DEBUG');

EXCEPTION
WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '.get_other_profiles',
		                                MESSAGE => fnd_message.get );
           END IF;
END;


PROCEDURE GET_PAGE_PARAMS (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
                           p_region_id               IN     VARCHAR2,
                           x_as_of_date              OUT NOCOPY DATE,
                           x_comp_type               OUT NOCOPY VARCHAR2,
                           x_conv_rate_selected      OUT NOCOPY VARCHAR2,
                           x_curr_page_time_id       OUT NOCOPY NUMBER,
                           x_page_period_type        OUT NOCOPY VARCHAR2,
                           x_parameter_valid         OUT NOCOPY BOOLEAN,
                           x_period_type             OUT NOCOPY VARCHAR2,
                           x_prev_page_time_id       OUT NOCOPY NUMBER,
                           x_prior_as_of_date        OUT NOCOPY DATE,
                           x_prodcat_id              OUT NOCOPY VARCHAR2,
                           x_record_type_id          OUT NOCOPY NUMBER,
                           x_resource_id             OUT NOCOPY VARCHAR2,
                           x_sg_id                   OUT NOCOPY VARCHAR2,
                           x_parent_sg_id            OUT NOCOPY NUMBER,
                           x_viewby                  OUT NOCOPY VARCHAR2)
AS


  l_currency             VARCHAR2(20);
  l_salesgroup_id        VARCHAR2(100);
  l_period_id            VARCHAR2(20);
  l_comp_type            VARCHAR2(20);
  l_primary_currency     VARCHAR2(30);
  l_previous_date        DATE;
  l_current_date         DATE;
  l_as_of_date           DATE;
  l_parameter_valid      BOOLEAN;
  l_err_msg              VARCHAR2(320);
  l_err_desc             VARCHAR2(4000);
  l_err_msg1             VARCHAR2(320);
  l_err_desc1            VARCHAR2(4000);
  l_proc                 VARCHAR2(20);
  l_log_str              VARCHAR2(3000);
  l_resource_id          VARCHAR2(100);
  l_conv_rate_selected   VARCHAR2(100);
  l_parent_sls_grp_id    VARCHAR2(100);

BEGIN
    /* Variable Intialization */
    g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
    l_parameter_valid := True;
	l_err_msg := 'Null parameter(s)';
	l_err_desc := 'Please run with a valid ';
	l_proc := ' GET.PAGE.PARAMS ';


        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                   FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                  MODULE => g_pkg ||'.'|| l_proc || '.begin',
		                  MESSAGE => 'Start of Procedure '||l_proc);

        END IF;


    x_parameter_valid := l_parameter_valid;

    --retrieve page parameters

    IF p_page_parameter_tbl IS NOT NULL THEN

        FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

            CASE p_page_parameter_tbl(i).parameter_name

                 WHEN 'VIEW_BY' THEN

                 x_viewby := p_page_parameter_tbl(i).parameter_value;

                IF x_viewby IS NULL THEN

                   x_viewby := 'ORGANIZATION+JTF_ORG_SALES_GROUP';

                END IF;
                 WHEN 'PERIOD_TYPE' THEN

                     x_page_period_type := p_page_parameter_tbl(i).parameter_value;

                   IF x_page_period_type IS NULL THEN
                       l_parameter_valid := FALSE;
                       x_parameter_valid := l_parameter_valid;
                       l_err_desc        := l_err_desc || p_page_parameter_tbl(i).parameter_name;

                   END IF;

                WHEN 'AS_OF_DATE' THEN

                    l_as_of_date := p_page_parameter_tbl(i).PERIOD_DATE;
                    x_as_of_date := p_page_parameter_tbl(i).PERIOD_DATE;

                    IF l_as_of_date IS NULL THEN

                        l_parameter_valid := FALSE;
                        x_parameter_valid := l_parameter_valid;
                        l_err_desc        := l_err_desc || p_page_parameter_tbl(i).parameter_name;

                    END IF;

                 WHEN 'BIS_P_ASOF_DATE' THEN

                    x_prior_as_of_date:= p_page_parameter_tbl(i).PERIOD_DATE;

                 IF x_prior_as_of_date IS NULL THEN
                       l_parameter_valid := FALSE;
                       x_parameter_valid := l_parameter_valid;
                       l_err_desc        := l_err_desc || p_page_parameter_tbl(i).parameter_name;

                 END IF;

                WHEN 'TIME_COMPARISON_TYPE' THEN
                    x_comp_type := p_page_parameter_tbl(i).parameter_value;
                    IF x_comp_type IS NULL THEN
                        l_parameter_valid := FALSE;
                        x_parameter_valid := l_parameter_valid;
                        l_err_desc        := l_err_desc || p_page_parameter_tbl(i).parameter_name;
                    END IF;

                WHEN 'CURRENCY+FII_CURRENCIES' THEN
                    l_currency := p_page_parameter_tbl(i).parameter_id;

                    IF l_currency IS NULL THEN
                        l_parameter_valid := FALSE;
                        x_parameter_valid := l_parameter_valid;
                        l_err_desc        := l_err_desc || p_page_parameter_tbl(i).parameter_name;

                    END IF;

               WHEN 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN

                    l_salesgroup_id := p_page_parameter_tbl(i).parameter_id;

                    BIL_BI_UTIL_PKG.PARSE_SALES_GROUP_ID(
                                                        p_salesgroup_id =>l_salesgroup_id,
                                                        x_resource_id   =>l_resource_id);

                     x_sg_id:= l_salesgroup_id;
                     x_resource_id:=l_resource_id;

                      IF x_sg_id IS NULL THEN
                         l_parameter_valid := FALSE;
                         x_parameter_valid := l_parameter_valid;
                         l_err_desc        := l_err_desc || p_page_parameter_tbl(i).parameter_name;
                      END IF;


               WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN

                    x_prodcat_id := p_page_parameter_tbl(i).parameter_id;

-- ER #2467584 for gettig previous time_id e.g. TIME+FII_TIME_ENT_PERIOD_PFROM and TIME+FII_TIME_ENT_PERIOD_PTO
-- get values for p_prev_page_time_id to implement ER#2467584

               WHEN 'TIME+FII_TIME_WEEK_PFROM' THEN
                    x_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;

               WHEN 'TIME+FII_TIME_ENT_PERIOD_PFROM' THEN
                    x_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;

               WHEN 'TIME+FII_TIME_ENT_QTR_PFROM' THEN
                    x_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;

               WHEN 'TIME+FII_TIME_ENT_YEAR_PFROM' THEN
                    x_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;

-- get values for x_curr_page_time_id
               WHEN 'TIME+FII_TIME_WEEK_FROM' THEN
                    x_curr_page_time_id := p_page_parameter_tbl(i).parameter_id;  --'+FII_TIME_WEEK_FROM';

               WHEN 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
                    x_curr_page_time_id := p_page_parameter_tbl(i).parameter_id; --'+FII_TIME_ENT_PERIOD_FROM';

               WHEN 'TIME+FII_TIME_ENT_QTR_FROM' THEN
                    x_curr_page_time_id := p_page_parameter_tbl(i).parameter_id; --'+FII_TIME_ENT_QTR_FROM';

               WHEN 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
                    x_curr_page_time_id := p_page_parameter_tbl(i).parameter_id; --'+FII_TIME_ENT_YEAR_FROM';

            ELSE

              NULL;

            END CASE;
     END LOOP;


    -- Update error message and error description in the caes of null parameters

    IF x_prev_page_time_id IS NULL THEN
        l_parameter_valid := FALSE;
        x_parameter_valid := l_parameter_valid;
        l_err_desc        := l_err_desc || ', PREV_PAGE_TIME_ID';

    END IF;

    IF x_curr_page_time_id IS NULL THEN
        l_parameter_valid := FALSE;
        x_parameter_valid := l_parameter_valid;
        l_err_desc        := l_err_desc || ', CURR_PAGE_TIME_ID';

    END IF;

     IF x_parameter_valid = TRUE THEN
                       l_log_str := 'View by : '||x_viewby||'p_page_period_type : '||x_page_period_type||
                                ' p_as_of_date : '||x_as_of_date||' p_comp_type : '||x_comp_type||
                               ' l_currency : '||l_currency||' p_sg_id : '||x_sg_id||'p_prodcat_id : '||x_prodcat_id||
                      ' p_prev_page_time_id : '||x_prev_page_time_id||' x_curr_page_time_id : '||x_curr_page_time_id;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'|| l_proc || '.params',
		                                    MESSAGE => l_log_str);

                     END IF;

     ELSE

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE =>    g_pkg ||'.'|| l_proc ||'.'||l_err_msg,
		                                    MESSAGE =>   l_err_desc);

                     END IF;

     END IF;

    -- Retrieve Period_Type AND
    -- Record_Type For non-BIL query rollup
        --Year  :119
        --Qtr   :55
        --Month :23
        --Week  :11

 CASE x_page_period_type
        WHEN 'FII_TIME_WEEK' THEN x_period_type := 16; x_record_type_id := 32;
        WHEN 'FII_TIME_ENT_PERIOD' THEN x_period_type := 32; x_record_type_id  := 64;
        WHEN 'FII_TIME_ENT_QTR' THEN x_period_type := 64; x_record_type_id  := 128;
        WHEN 'FII_TIME_ENT_YEAR' THEN x_period_type := 128; x_record_type_id  := 256;

        ELSE

            l_parameter_valid := FALSE;
            x_parameter_valid := l_parameter_valid;
            l_err_msg1  := 'Invalid period type.';
            l_err_desc1 := 'Invalid period type. ';


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'||l_proc||'.'||l_err_msg,
		                                    MESSAGE => l_err_desc);

                     END IF;

 END CASE;

       IF x_parameter_valid = TRUE THEN
                 l_log_str := ' p_period_type : '||x_period_type||' x_record_type_id : '||x_record_type_id;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'|| l_proc,
		                                    MESSAGE => l_log_str);

                     END IF;

      END IF;



    --Update error message and error description in the case of null parameters
    IF x_prior_as_of_date IS NULL THEN
        l_parameter_valid := FALSE;
        x_parameter_valid := l_parameter_valid;
        l_err_desc        := l_err_desc || ', PRIOR_AS_OF_DATE';
    END IF;


    bil_bi_util_pkg.GET_CONV_RATE(p_as_of_date => l_as_of_date
                                 ,p_currency => l_currency
                                  ,x_conv_rate_selected => l_conv_rate_selected
                                  ,x_err_desc => l_err_desc
                                  ,x_err_msg => l_err_msg
                                  ,x_parameter_valid => l_parameter_valid);

  x_conv_rate_selected := l_conv_rate_selected;
  x_parameter_valid := l_parameter_valid;

       IF x_parameter_valid THEN

                 l_log_str := ' x_prior_as_of_date : '||x_prior_as_of_date||
                              ' p_conv_rate_selected : '||x_conv_rate_selected;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'||l_proc,
		                                    MESSAGE => l_log_str);

                     END IF;

      ELSE

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'||l_proc||'.'||l_err_msg,
		                                    MESSAGE => l_err_desc);

                     END IF;

       END IF;

BIL_BI_UTIL_PKG.GET_PARENT_SLS_GRP_ID(p_sales_grp_id => l_salesgroup_id,
                                x_parent_sls_grp_id  => l_parent_sls_grp_id,
                                x_parameter_valid => l_parameter_valid);




  x_parent_sg_id := l_parent_sls_grp_id;
  x_parameter_valid := l_parameter_valid;

       IF x_parameter_valid THEN

                 l_log_str := ' x_parent_sls_grp_id : '||x_parent_sg_id;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'||l_proc,
		                                    MESSAGE => l_log_str);

                     END IF;


       ELSE

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'||l_proc||'.'||l_err_msg,
		                                    MESSAGE => l_err_desc);

                     END IF;

       END IF;

  ELSE

    l_parameter_valid := FALSE;
    x_parameter_valid := l_parameter_valid;
       IF p_page_parameter_tbl IS NULL THEN

         l_log_str := ' Param table null! ';

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'||l_proc,
		                                    MESSAGE => l_log_str);

                     END IF;


            l_log_str := l_log_str || ' Length of param table '||
                    p_page_parameter_tbl.count;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||'.'||l_proc,
		                                    MESSAGE => l_log_str);

                     END IF;

    END IF;

END IF;

EXCEPTION
    WHEN OTHERS THEN

     IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_parameter_valid := FALSE;
        x_parameter_valid := l_parameter_valid;
        l_err_msg := 'New: '||SQLERRM();

        l_log_str := ' Exception_block!! ';

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg ||'.'||l_proc||'.'||l_log_str,
		                                MESSAGE => l_err_msg );

     END IF;
END GET_PAGE_PARAMS;



PROCEDURE GET_PARENT_SLS_GRP_ID(p_sales_grp_id IN NUMBER,
                                x_parent_sls_grp_id OUT NOCOPY NUMBER,
                                x_parameter_valid OUT NOCOPY BOOLEAN)
AS

l_parameter_valid BOOLEAN;
l_parent_sls_grp_id NUMBER;

BEGIN

g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_parameter_valid := TRUE;

    select parent_group_id
    into l_parent_sls_grp_id
    from jtf_rs_groups_denorm
    where group_id = p_sales_grp_id
    and immediate_parent_flag='Y'
    and latest_relationship_flag='Y';

x_parameter_valid := l_parameter_valid;
x_parent_sls_grp_id := l_parent_sls_grp_id;

EXCEPTION
WHEN NO_DATA_FOUND THEN
x_parameter_valid := l_parameter_valid;
x_parent_sls_grp_id := l_parent_sls_grp_id;
   WHEN OTHERS THEN

    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_parameter_valid := FALSE;
        x_parameter_valid := l_parameter_valid;
              fnd_message.set_name('FND','SQL_PLSQL_ERROR');
              fnd_message.set_token('ERROR',SQLCODE);
              fnd_message.set_token('REASON', SQLERRM);

                   FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                  MODULE => g_pkg ||'.getParentSalesGroup',
		                  MESSAGE => fnd_message.get );

    END IF;
END get_parent_sls_grp_id;


--  **********************************************************************
-- PROCEDURE GET_PRODUCT_WHERE_CLAUSE
--
-- Purpose:
--        Returns the where clause to be used by all reports where
--        product category can be selected.  Takes care of all view by's.
-- Note:
--        __Cannot__ be used for forecast measure since MV does not have
--        item reference
--
--  **********************************************************************
PROCEDURE get_Product_Where_Clause(p_prodcat IN VARCHAR2
                                  ,p_viewby IN VARCHAR2
                                  ,x_denorm OUT NOCOPY VARCHAR2
                                  ,x_where_clause OUT NOCOPY VARCHAR2)
AS
   l_denorm                VARCHAR2(100);
   l_product_where_clause  VARCHAR2(1000);
   l_proc                  VARCHAR2(50);
BEGIN
	   /* Variable Intialization */
       g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
	   l_denorm :=' ';
   	   l_product_where_clause := ' ';
   	   l_proc := 'get_Product_Where_Clause.';

       IF 'ITEM+ENI_ITEM_VBH_CAT' = p_viewby THEN

           l_denorm := ',ENI_ITEM_PROD_CAT_LOOKUP_V pcd ';

           IF 'ALL' = UPPER(p_prodcat) THEN
              /* l_product_where_clause := ' AND pcd.top_node_flag = :l_yes '||
                                         ' AND pcd.parent_id = pcd.child_id '||
                                         ' AND pcd.child_id = pcd.id '||
                                         ' AND sumry.product_category_id = pcd.id '||
                                         ' AND sumry.item_id IS NULL ';*/

				l_product_where_clause :=' AND pcd.top_node_flag = :l_yes '||
									     ' AND pcd.parent_id = sumry.product_category_id '||
									     ' AND pcd.child_id = sumry.product_category_id '||
									     ' AND sumry.product_category_id = pcd.id '||
										 ' AND sumry.item_id IS NULL ';

           ELSE
               l_product_where_clause := ' AND pcd.parent_id = :l_prodcat '||
                                         ' AND pcd.id = pcd.child_id '||
                                         ' AND sumry.product_category_id = pcd.child_id ';
               IF NOT isLeafNode(p_prodcat) THEN
                  l_product_where_clause := l_product_where_clause ||' AND NVL(sumry.item_id,''-2'') = DECODE(pcd.id,pcd.parent_id,''-1'',''-2'') ';
               END IF;

           END IF;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                               FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                              MODULE => g_pkg || l_proc ||'Prod cat view by',
		                              MESSAGE => ' Product where clause: '|| l_product_where_clause ||'; denorm: '|| l_denorm);

                     END IF;

       ELSE

        /* View by is one of ORGANIZATION+JTF_ORG_SALES_GROUP, TIME+FII_TIME_WEEK, TIME+FII_TIME_ENT_PERIOD
           , TIME+FII_TIME_ENT_QTR, TIME+FII_TIME_ENT_YEAR, CAMPAIGN+CAMPAIGN */
            IF 'ALL' <> UPPER(p_prodcat) THEN
                l_product_where_clause := ' AND sumry.product_category_id = :l_prodcat '||
                                          ' AND sumry.item_id IS NULL ';
            END IF;

                      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                               FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                              MODULE => g_pkg || l_proc || p_viewBy,
		                              MESSAGE => ' Product where clause: '|| l_product_where_clause ||'; denorm: '||l_denorm);

                     END IF;

      END IF;

       x_denorm := l_denorm;
       x_where_clause := l_product_where_clause;
       EXCEPTION
       WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('ERROR' ,SQLCODE);
              fnd_message.set_token('REASON',SQLERRM);
              fnd_message.set_token('ROUTINE',l_proc);

                       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                      MODULE => g_pkg || l_proc,
		                      MESSAGE => fnd_message.get );
          END IF;
END get_Product_Where_Clause;

/*  **********************************************************************
REM PROCEDURE GET_PC_NOROLLUP_WHERE_CLAUSE
REM
REM Purpose:
REM        Returns the where clause to be used by all reports where
REM        product category rollup is done at runtime. Takes care of all view by's.
REM Note:
REM        __Cannot__ be used for forecast measure since MV does not have
REM        item reference
REM
REM  **********************************************************************/
PROCEDURE GET_PC_NOROLLUP_WHERE_CLAUSE(p_prodcat IN VARCHAR2
                                       ,p_viewby IN VARCHAR2
                                       ,x_denorm OUT NOCOPY VARCHAR2
                                       ,x_where_clause OUT NOCOPY VARCHAR2)
AS
   l_denorm                VARCHAR2(100);
   l_product_where_clause  VARCHAR2(1000);
   l_proc                  VARCHAR2(50);
BEGIN
	/* Variable Intialization */
	g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
	l_denorm :=' ';
        l_product_where_clause := ' ';
        l_proc := 'get_Pipe_Product_Where_Clause.';
        IF 'ITEM+ENI_ITEM_VBH_CAT' = p_viewby THEN
	   IF 'ALL' = UPPER(p_prodcat) THEN
               l_product_where_clause :=' and sumry.product_category_id = pcd.child_id
                                      and pcd.top_node_flag = :l_yes
                                      AND pcd.object_type = ''CATEGORY_SET''
                                      AND pcd.object_id = d.category_set_id
                                      AND d.functional_area_id = 11
                                      AND pcd.dbi_flag = ''Y''';
               l_denorm := ',eni_denorm_hierarchies pcd, mtl_default_category_sets d ';
           ELSE
               l_product_where_clause := ' AND pcd.parent_id = :l_prodcat '||
                                         ' AND sumry.product_category_id = pcd.child_id ';
               l_denorm := ',ENI_ITEM_PROD_CAT_LOOKUP_V pcd ';
           END IF;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                               MODULE => g_pkg || l_proc ||'Prod cat view by',
		                               MESSAGE => ' Product where clause: '|| l_product_where_clause ||'; denorm: '|| l_denorm);

                     END IF;

         ELSE
              /* View by is one of ORGANIZATION+JTF_ORG_SALES_GROUP, TIME+FII_TIME_WEEK, TIME+FII_TIME_ENT_PERIOD
                 , TIME+FII_TIME_ENT_QTR, TIME+FII_TIME_ENT_YEAR, CAMPAIGN+CAMPAIGN */
              IF 'ALL' <> UPPER(p_prodcat) THEN
                 l_product_where_clause := ' AND sumry.product_category_id = eni1.child_id
                                             AND eni1.object_type = ''CATEGORY_SET''
                                             AND eni1.object_id = d.category_set_id
                                             AND d.functional_area_id = 11
                                             AND eni1.dbi_flag = ''Y''
                                             AND eni1.parent_id = :l_prodcat ';
                 l_denorm := ',eni_denorm_hierarchies eni1, mtl_default_category_sets d ';
              END IF;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                              FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                             MODULE => g_pkg || l_proc || p_viewBy,
		                             MESSAGE => ' Product where clause: '|| l_product_where_clause ||'; denorm: '||l_denorm);

                     END IF;

          END IF;
          x_denorm := l_denorm;
          x_where_clause := l_product_where_clause;
EXCEPTION
      WHEN OTHERS THEN

        IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
           fnd_message.set_token('ERROR' ,SQLCODE);
           fnd_message.set_token('REASON',SQLERRM);
           fnd_message.set_token('ROUTINE',l_proc);

                       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                      MODULE => g_pkg || l_proc ,
		                      MESSAGE => fnd_message.get );

        END IF;
END get_PC_NoRollup_Where_Clause;
--  **********************************************************************
--        PROCEDURE GET_TREND_PARAMS
--
--        Purpose:
--        used by the trend queries, returns the start and end dates of the trend
-- span, time id, and fii time table depending on the period type
-- week - fii_time_week
-- month - fii_time_ent_period
-- quarter - fii_time_ent_qtr
-- year - fii_time_ent_year
--  **********************************************************************
PROCEDURE GET_TREND_PARAMS( p_comp_type                 IN VARCHAR2,
                            p_curr_as_of_date           IN DATE,
                            p_page_parameter_tbl        IN     BIS_PMV_PAGE_PARAMETER_TBL,
                            p_page_period_type          IN VARCHAR2,
                            x_column_name               OUT NOCOPY VARCHAR2,
                            x_curr_eff_end_date         OUT NOCOPY DATE,
                            x_curr_start_date           OUT NOCOPY DATE,
                            x_prev_eff_end_date         OUT NOCOPY DATE,
                            x_prev_start_date           OUT NOCOPY DATE,
                            x_table_name                OUT NOCOPY VARCHAR2

                             ) AS

l_err_msg VARCHAR2(200);


BEGIN
/* Variable Intialization */
 g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

        --get period start date
       IF p_page_parameter_tbl(i).parameter_name = 'BIS_CUR_REPORT_START_DATE' THEN
          x_curr_start_date:= p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'BIS_PREV_REPORT_START_DATE' THEN
          x_prev_start_date:= p_page_parameter_tbl(i).period_date;
       END IF;
       -- GET values for &BIS_CUR_EFFECTIVE_END_DATE
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_WEEK_TO' THEN
         x_curr_eff_end_date := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_TO' THEN
         x_curr_eff_end_date  := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_TO' THEN
          x_curr_eff_end_date := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_TO' THEN
         x_curr_eff_end_date  := p_page_parameter_tbl(i).period_date;
       END IF;
       -- GET values for &BIS_PREVIOUS_EFFECTIVE_END_DATE
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_WEEK_PTO' THEN
         x_prev_eff_end_date := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_PTO' THEN
         x_prev_eff_end_date  := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_PTO' THEN
         x_prev_eff_end_date := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_PTO' THEN
         x_prev_eff_end_date  := p_page_parameter_tbl(i).period_date;
      END IF;
   END LOOP;
END IF;


CASE


    WHEN p_page_period_type = 'FII_TIME_ENT_YEAR' THEN
        x_table_name := 'fii_time_ent_year';
        x_column_name := 'ent_year_id';

 /*       SELECT ENT_YEAR_ID
        INTO   x_curr_startprd_id
        FROM   fii_time_ent_year
        WHERE  x_curr_start_date BETWEEN start_date AND end_date;
*/
     WHEN p_page_period_type = 'FII_TIME_WEEK' then
        x_table_name := 'fii_time_week';
        x_column_name := 'week_id';

    WHEN p_page_period_type = 'FII_TIME_ENT_PERIOD' then
        x_table_name := 'fii_time_ent_period';
        x_column_name := 'ent_period_id';
/*
        -- Get  p_startprd_id
        SELECT ent_period_id
        INTO   x_curr_startprd_id
        FROM   fii_time_ent_period
        WHERE  x_curr_start_date BETWEEN start_date AND end_date;

            IF p_comp_type = 'YEARLY' then
            -- Get p_prev_startprd_id

            SELECT ent_period_id
            INTO   x_prev_startprd_id
            FROM   fii_time_ent_period
            WHERE  x_prev_start_date BETWEEN start_date AND end_date;

        END IF;
*/

    WHEN p_page_period_type = 'FII_TIME_ENT_QTR' then
        x_table_name := 'fii_time_ent_qtr';
        x_column_name := 'ent_qtr_id';
/*
        --Get p_startprd_id

       SELECT ent_qtr_id
       INTO   x_curr_startprd_id
       FROM   fii_time_ent_qtr
       WHERE x_curr_start_date BETWEEN start_date AND end_date;


        IF p_comp_type = 'YEARLY' then

          --Get p_prev_startprd_id

      SELECT ent_qtr_id
      INTO   x_prev_startprd_id
      FROM   fii_time_ent_qtr
      WHERE  x_prev_start_date BETWEEN start_date AND end_date;

    END IF;
*/

END CASE;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || '.get_conv_rate ',
		                                    MESSAGE => 'x_column_name: '||x_column_name||'; '||
                                                    'x_curr_eff_end_date: '|| x_curr_eff_end_date||'; '||
                                                    'x_curr_start_date: '||x_curr_start_date||'; '||
                                                    'x_prev_eff_end_date: '||x_prev_eff_end_date||'; '||
                                                    'x_prev_start_date: '||x_prev_start_date||'; '||
                                                    'x_table_name: '||x_table_name||'; ');

                     END IF;

EXCEPTION

    WHEN OTHERS THEN
           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                          FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                         MODULE => g_pkg || '.get_trend_params',
		                         MESSAGE => fnd_message.get );

           END IF;
END GET_TREND_PARAMS;
--  **********************************************************************
--        FUNCTION GET_UNASSIGNED_PC
--        Purpose:
--        Returns Unassigned Categoty Used in FE queries
--	  when View By Product Category and Product Category = All
--  **********************************************************************

FUNCTION GET_UNASSIGNED_PC RETURN VARCHAR2 AS
  l_unassigned_value VARCHAR2(100);
BEGIN
 SELECT DESCRIPTION || ' ('|| MEANING ||')'
  INTO l_unassigned_value
  FROM FND_LOOKUP_VALUES
  WHERE LOOKUP_TYPE = 'ITEM_CATG' AND
        LOOKUP_CODE = '-1' AND
        LANGUAGE = USERENV('LANG');
RETURN l_unassigned_value;
 EXCEPTION
  WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '. GET_UNASSIGNED_PC',
		                                MESSAGE => fnd_message.get );

           END IF;
END GET_UNASSIGNED_PC;



--  **********************************************************************
--        FUNCTION isUserCurrency
--
--        Purpose:
--        returns a boolean, used to determine whether the user currency is
-- selected.  Used by the Sales Management Summary report to disable
-- the drill across URL to FII and ISC if user currency is selected.
--
--  **********************************************************************

FUNCTION isUserCurrency (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL)
    RETURN BOOLEAN AS

l_currency      VARCHAR2(100);
l_isUserCurrency BOOLEAN;

BEGIN
 /* Variable Intialization */
 g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
 l_isUserCurrency := FALSE;

 IF p_page_parameter_tbl IS NOT NULL THEN

        FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

            IF  p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
                    l_currency := p_page_parameter_tbl(i).parameter_id;

                    IF INSTR(l_currency,'FII_GLOBAL1') > 0  THEN
                        l_isUserCurrency := FALSE;
                    ELSE
                        l_isUserCurrency := TRUE;
                    END IF;
            END IF;
        END LOOP;
    END IF;

RETURN l_isUserCurrency;
END;




--  **********************************************************************
--        FUNCTION isLeafNode
--
--        Purpose:
--        returns a boolean, used to determine whether a selected product category
-- is at the leaf node.  If so, then self row is selected.  If not, then
-- child categories are selected to be displayed in the report.
--
--  **********************************************************************
FUNCTION isLeafNode (p_prodcat_id IN NUMBER) RETURN BOOLEAN AS


leaf_node varchar2(1);


BEGIN
 	/* Variable Intialization */
   g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

    SELECT a.leaf_node_flag INTO leaf_node
    FROM ENI_DENORM_HIERARCHIES A,
        MTL_DEFAULT_CATEGORY_SETS B
    WHERE B.FUNCTIONAL_AREA_ID = 11
    AND A.OBJECT_TYPE = 'CATEGORY_SET'
    AND A.OBJECT_ID = B.CATEGORY_SET_ID
    AND A.DBI_FLAG = 'Y'
    AND a.parent_id = p_prodcat_id
    AND a.parent_id = a.child_id;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE =>    g_pkg ||'.Leaf_node  ',
		                                    MESSAGE =>   'Leaf node: '||leaf_node
                                                || ', prodcat_id: ' || p_prodcat_id);

                     END IF;

    IF 'Y' = leaf_node THEN
      RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;


 EXCEPTION

  WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '.isLeafNode',
		                                MESSAGE => fnd_message.get );


         END IF;

END isLeafNode;


--  **********************************************************************
--        PROCEDURE PARSE_SALES_GROUP_ID
--
--        Purpose: if a resource is selected, then PMV will pass a concatenated
-- resource_id.sales_group_id in the sales_group parameter.  Parsing it here
-- into two parameters.  Used by the get_page_params procedure, as well as
-- by top_open_oppties report directly.
--
--  **********************************************************************
PROCEDURE PARSE_SALES_GROUP_ID(
        p_salesgroup_id     IN OUT NOCOPY VARCHAR2,
        x_resource_id       OUT NOCOPY VARCHAR2
       ) AS

l_sg_id         VARCHAR2(20);
l_resource_id   VARCHAR2(20);
l_dot           NUMBER;

BEGIN
	/* Variable Intialization */
    g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

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
-- PROCEDURE getLookupMeaning
--
-- Purpose:
--        Returns meaning corresponding to the type and code passed in.
--        Used to get messages like 'Assigned to Category' etc.
--
--  **********************************************************************

FUNCTION getLookupMeaning(p_lookuptype IN VARCHAR2,p_lookupcode IN VARCHAR2)
RETURN VARCHAR2

AS

l_cat_assign VARCHAR2(4000);

BEGIN
	 /* Variable Intialization */
     g_pkg := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';

     SELECT Meaning INTO l_cat_assign
     FROM FND_LOOKUP_VALUES
     WHERE LOOKUP_TYPE = p_lookuptype
     AND LOOKUP_CODE = p_lookupcode
     AND LANGUAGE = USERENV('LANG');

     RETURN l_cat_assign;

EXCEPTION
   WHEN OTHERS THEN

          IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR');
              fnd_message.set_token('ERROR',SQLCODE);
              fnd_message.set_token('REASON', SQLERRM);

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                 MODULE => g_pkg ||'.getLookupMeaning',
		                 MESSAGE => fnd_message.get );

           END IF;

END getLookupMeaning;



--  **********************************************************************
-- PROCEDURE GET_PRIOR_PRIOR_TIME
--
-- Purpose:
--         to get prior prior timeid and date
--         returns prior timeid and date for previous date passed as parameter
--  **********************************************************************

PROCEDURE GET_PRIOR_PRIOR_TIME (p_comp_type IN VARCHAR2,
                                p_period_type IN VARCHAR2,
                                p_prev_date IN DATE,
                                p_prev_page_time_id IN NUMBER,
                                x_prior_prior_date OUT NOCOPY DATE,
                                x_prior_prior_time_id OUT NOCOPY NUMBER) AS

l_timespan  NUMBER;
l_sequence  NUMBER;
l_year      NUMBER;
l_prior_prior_date DATE;
l_prior_prior_time_id NUMBER;
l_prev_date DATE;
l_proc      VARCHAR2(50);

BEGIN

g_pkg  := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_proc := 'get_prior_prior_time';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;

IF  (TRUNC(p_prev_date)>(bis_common_parameters.get_global_start_date-1)) THEN

  l_prev_date := TRUNC(p_prev_date);

  IF (p_period_type = 'FII_TIME_WEEK') THEN

       SELECT l_prev_date-w.start_date, w.sequence, p.year445_id
              INTO l_timespan, l_sequence, l_year
       FROM   fii_time_week w, fii_time_p445 p
       WHERE  w.period445_id=p.period445_id
       AND    l_prev_date BETWEEN w.start_date AND w.end_date;

       IF p_comp_type='SEQUENTIAL' THEN
          if l_sequence=1 then

             l_year:=l_year-1;

             SELECT MAX(w.sequence)
             INTO l_sequence
             FROM fii_time_week w, fii_time_p445 p
             WHERE w.period445_id=p.period445_id
             AND p.year445_id=l_year;
          else

             l_sequence:=l_sequence-1;
          end if;
       ELSE

             l_year:=l_year-1;
       END IF;

       SELECT w.week_id, w.start_date+l_timespan
              INTO l_prior_prior_time_id, l_prior_prior_date
       FROM   fii_time_week w, fii_time_p445 p
       WHERE  w.period445_id=p.period445_id
       AND    w.sequence=l_sequence
       AND    p.year445_id=l_year;

  ELSIF (p_period_type = 'FII_TIME_ENT_PERIOD') THEN

        SELECT p.end_date-l_prev_date, p.sequence, p.ent_year_id
               INTO l_timespan, l_sequence, l_year
        FROM   fii_time_ent_period p
        WHERE  l_prev_date BETWEEN p.start_date AND p.end_date;

       IF p_comp_type='SEQUENTIAL' THEN
          if l_sequence=1 then

              l_year:=l_year-1;

              SELECT MAX(p.sequence)
                     INTO l_sequence
              FROM   fii_time_ent_period p
              WHERE  p.ent_year_id=l_year;
          else

              l_sequence:=l_sequence-1;
          end if;
       ELSE

              l_year:=l_year-1;
       END IF;

       SELECT ent_period_id, GREATEST(p.start_date, p.end_date-l_timespan)
              INTO l_prior_prior_time_id, l_prior_prior_date
       FROM   fii_time_ent_period p
       WHERE  p.sequence=l_sequence
       AND    p.ent_year_id=l_year;

  ELSIF (p_period_type = 'FII_TIME_ENT_QTR') THEN

         SELECT end_date-l_prev_date, sequence, ent_year_id
                INTO l_timespan, l_sequence, l_year
         FROM   fii_time_ent_qtr
         WHERE  l_prev_date BETWEEN start_date AND end_date;

       IF p_comp_type='SEQUENTIAL' THEN
          if l_sequence=1 then

              l_year:=l_year-1;

              SELECT MAX(sequence)
                     INTO l_sequence
              FROM  fii_time_ent_qtr
              WHERE ent_year_id=l_year;
          else

              l_sequence:=l_sequence-1;
          end if;
        ELSE

              l_year:=l_year-1;
        END IF;

          SELECT ent_qtr_id, GREATEST(start_date, end_date-l_timespan)
                 INTO l_prior_prior_time_id, l_prior_prior_date
          FROM   fii_time_ent_qtr
          WHERE  sequence=l_sequence
          AND    ent_year_id=l_year;

  ELSIF (p_period_type = 'FII_TIME_ENT_YEAR') THEN

        SELECT end_date-l_prev_date, sequence
               INTO l_timespan, l_year
        FROM   fii_time_ent_year
        WHERE  l_prev_date BETWEEN start_date AND end_date;

        SELECT ent_year_id, GREATEST(start_date, end_date-l_timespan)
               INTO l_prior_prior_time_id, l_prior_prior_date
        FROM   fii_time_ent_year
        WHERE  sequence=l_year-1;

  END IF;

   /*Code to Handle the null prior prior date*/

  IF l_prior_prior_date IS NULL THEN
     x_prior_prior_date:=TO_DATE('01/01/1900', 'MM/DD/YYYY');
     x_prior_prior_time_id:= -999;
  ELSE
     x_prior_prior_date:=l_prior_prior_date;
     x_prior_prior_time_id:=l_prior_prior_time_id;
  END IF;

ELSE

  x_prior_prior_date:=TRUNC(p_prev_date);
  x_prior_prior_time_id:=p_prev_page_time_id;

END IF;
                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;


EXCEPTION

  WHEN NO_DATA_FOUND THEN
     x_prior_prior_date:=TO_DATE('01/01/1900', 'MM/DD/YYYY');
     x_prior_prior_time_id:= -999;

  WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || '. GET_PRIOR_PRIOR_TIME',
		                                MESSAGE => fnd_message.get );
           END IF;
END GET_PRIOR_PRIOR_TIME;

--  **********************************************************************************
-- FUNCTION GET_DRILL_LINKS
--
-- Purpose:
--         to get drill links
--         returns drill link for viewby,salesgroup,salesrep passed as parameter
--  **********************************************************************************

FUNCTION GET_DRILL_LINKS ( p_view_by           IN     VARCHAR2,
                           p_salesgroup_id     IN     VARCHAR2,
                           p_resource_id       IN     VARCHAR2
) RETURN VARCHAR2

AS

 l_view_by              VARCHAR2(200);
 l_salesgroup_id        VARCHAR2(100);
 l_resource_id          VARCHAR2(100);
 l_drill_link           VARCHAR2(3000) := NULL;
 l_proc                 VARCHAR2(50);

BEGIN

g_pkg  := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_proc := 'GET_DRILL_LINKS';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;

l_view_by := p_view_by;
l_resource_id := p_resource_id ;
l_salesgroup_id := p_salesgroup_id ;

   IF(l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') --View By = Product Categroy
     THEN
          IF (l_resource_id IS NOT NULL)  -- Some SalesRep is selected in the salesgroup LOV
            THEN
              l_drill_link  := 'pFunctionName=BIL_BI_OPPTY_LINE_DETAIL_R&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID&';
          END IF;
   ELSE -- VBY=Sales Group
       l_drill_link  := 'pFunctionName=BIL_BI_OPPTY_LINE_DETAIL_R&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID&';
   END IF;

                     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_EVENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Drill Link is =>'||l_drill_link);

                     END IF;


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;


RETURN l_drill_link ;


EXCEPTION

  WHEN OTHERS THEN
           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc,
		                                MESSAGE => fnd_message.get );

           END IF;

END GET_DRILL_LINKS;

--  **********************************************************************************
-- FUNCTION GET_LABEL_SGR
-- Purpose: to change the column headng dynamically when Sales Group/Sales Rep is selected from SG LOV on report
--  **********************************************************************************

FUNCTION GET_LBL_SGFST (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL) RETURN VARCHAR2
AS

l_salesgroup_id    VARCHAR2(100);
l_resource_id      VARCHAR2(100);
l_label            VARCHAR2(100);
l_proc             VARCHAR2(50);

BEGIN

g_pkg  := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_proc := 'GET_LBL_SGFST';

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;


       FOR i IN 1..p_page_parameter_tbl.COUNT
       LOOP
	     IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN

	        l_salesgroup_id := p_page_parameter_tbl(i).parameter_id;

                BIL_BI_UTIL_PKG.PARSE_SALES_GROUP_ID(
                                                     p_salesgroup_id =>l_salesgroup_id,
                                                     x_resource_id   =>l_resource_id);
	     END IF;
       END LOOP;


       IF l_resource_id is NULL THEN
         l_label:=FND_MESSAGE.GET_STRING('BIL','BIL_BI_LABEL_SGRP_FCST');
       ELSE
         l_label:=FND_MESSAGE.GET_STRING('BIL','BIL_BI_LABEL_SREP_FCST');
       END IF;

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;

       RETURN l_label;

EXCEPTION

WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => fnd_message.get );

           END IF;
              RETURN 'Direct Reports Forecast';

END GET_LBL_SGFST;

--  **********************************************************************************
-- PROCEDURE GET_PIPE_SNAP_DATE
-- Purpose: to get the snap date for the passed as_of_date
--  **********************************************************************************

PROCEDURE GET_PIPE_SNAP_DATE( p_as_of_date          IN DATE,
                              p_prev_date           IN DATE,
                              p_period_type         IN VARCHAR2,
                              p_coll_st_date        IN DATE,
                              p_coll_end_date       IN DATE,
                              p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_snap_date           OUT NOCOPY DATE,
                              x_prev_snap_date      OUT NOCOPY DATE
                             )

AS

l_as_of_date     DATE;
l_proc           VARCHAR2(1000);
l_sysdate        DATE:= TRUNC(sysdate);
l_snapshot_date  DATE;
l_prev_snap_date DATE;
l_coll_st_date   DATE;
l_coll_end_date  DATE;
l_period_start_date DATE;
l_period_type    VARCHAR2(1000);

BEGIN

l_as_of_date := trunc(p_as_of_date);
l_coll_st_date :=  p_coll_st_date;
l_coll_end_date := p_coll_end_date;
l_period_type := p_period_type;

g_pkg  := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_proc := 'GET_PIPE_SNAP_DATE';

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;
/*
 IF(l_as_of_date <> l_sysdate) THEN

      IF (l_as_of_date > l_sysdate) THEN
           l_snapshot_date := l_as_of_date;
      ELSE
          IF(l_as_of_date >= l_coll_st_date) THEN
             l_snapshot_date := l_as_of_date;
          ELSE
              l_snapshot_date := BIL_BI_UTIL_PKG.GET_HIST_SNAPSHOT_DATE(l_as_of_date, p_period_type);
          END IF;
    END IF;
*/

   IF(l_as_of_date <> l_sysdate) THEN

          l_snapshot_date := l_as_of_date;

       IF(l_as_of_date < l_coll_st_date) THEN

          l_snapshot_date := BIL_BI_UTIL_PKG.GET_HIST_SNAPSHOT_DATE(l_as_of_date, p_period_type);

          IF p_prev_date IS NOT NULL THEN
             l_prev_snap_date := BIL_BI_UTIL_PKG.GET_HIST_SNAPSHOT_DATE(p_prev_date, p_period_type);
          END IF;
       END IF;

   ELSE   --- (l_as_of_date = sysdate)

        BIL_BI_UTIL_PKG.GET_CURR_START_DATE(p_page_parameter_tbl  =>p_page_parameter_tbl,
                                            p_as_of_date  => l_as_of_date,
                                            p_period_type => l_period_type,
                                            x_curr_start_date  => l_period_start_date);

        IF (l_coll_end_date = l_sysdate OR (l_coll_end_date = l_sysdate-1 and l_period_start_date<= l_sysdate-1) ) THEN

                 IF  (l_coll_end_date =l_sysdate) THEN
                     l_snapshot_date := l_as_of_date;
                 ELSE
                     l_snapshot_date := l_coll_end_date;
                 END IF;
         ELSE
            --- Case where last collection was 2 days older than sysdate(as-of-date)
            --- This would ultimately not return any data, though the following parameters are passed to
            --- the query.
                      l_snapshot_date := l_as_of_date;
         END IF;
    END IF;

--              l_prev_snap_date := BIL_BI_UTIL_PKG.GET_HIST_SNAPSHOT_DATE(p_prev_date, p_period_type);


  x_snap_date :=  l_snapshot_date;
  x_prev_snap_date := l_prev_snap_date;


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;

EXCEPTION

WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => fnd_message.get );
           END IF;

END GET_PIPE_SNAP_DATE;

--  **********************************************************************************
-- PROCEDURE GET_PIPE_MV
-- Purpose: Based on the Date Current/Historical Pipeline MV is passed along with the
--          snapshot date.
--  **********************************************************************************

PROCEDURE GET_PIPE_MV(
                                     p_asof_date          IN  DATE,
                                     p_period_type        IN  VARCHAR2,
                                     p_compare_to         IN  VARCHAR2,
                                     p_prev_date          IN DATE,
                                     p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                                     x_pipe_mv            OUT NOCOPY VARCHAR2,
                                     x_snapshot_date      OUT NOCOPY DATE,
                                     x_prev_snap_date     OUT NOCOPY DATE
				    )
AS

l_pipe_mv            VARCHAR2(1000);
l_period_type        VARCHAR2(1000);
l_as_of_date         DATE;
l_coll_st_date       DATE;
l_coll_end_date      DATE;
l_period_start_date  DATE;
l_snapshot_date      DATE;
l_prev_snap_date     DATE;
l_proc               VARCHAR2(1000);
l_sysdate            DATE := TRUNC(SYSDATE);


  BEGIN

  g_pkg  := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
  l_proc := 'GET_PIPE_MV';
  l_as_of_date :=  trunc(p_asof_date);
  l_period_type := p_period_type ;


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;


        SELECT to_date(attribute1, 'dd/mm/yyyy'), MAX(to_date(attribute2, 'dd/mm/yyyy'))
        INTO l_coll_st_date,l_coll_end_date
        FROM bis_refresh_log a
        WHERE
        a.last_update_date = (
                         SELECT MAX(b.last_update_date) FROM bis_refresh_log b
					WHERE b.object_name = 'BIL_BI_PIPEC_F'
					AND status = 'SUCCESS'
				)
       AND a.object_name = 'BIL_BI_PIPEC_F'
       AND status = 'SUCCESS'
       group by to_date(attribute1, 'dd/mm/yyyy');



/*
  IF(l_as_of_date <> l_sysdate) THEN

       IF (l_as_of_date > l_sysdate) THEN

           l_pipe_mv := 'BIL_BI_PIPEC_G_MV';
       ELSE
           IF(l_as_of_date >= l_coll_st_date) THEN
               l_pipe_mv := 'BIL_BI_PIPEC_G_MV';
           ELSE
               l_pipe_mv := 'BIL_BI_PIPE_G_MV';
           END IF;
       END IF;
  ELSE
                 l_pipe_mv := 'BIL_BI_PIPEC_G_MV';
  END IF;
*/
--to be evaluated

       l_pipe_mv := 'BIL_BI_PIPEC_G_MV';

       IF (l_as_of_date < l_coll_st_date) THEN
           l_pipe_mv := 'BIL_BI_PIPE_G_MV';
       END IF;


   BIL_BI_UTIL_PKG.GET_PIPE_SNAP_DATE( p_as_of_date =>  l_as_of_date
                                      ,p_prev_date  =>  p_prev_date
                                      ,p_period_type => l_period_type
                                      ,p_coll_st_date => l_coll_st_date
                                      ,p_coll_end_date => l_coll_end_date
                                      ,p_page_parameter_tbl => p_page_parameter_tbl
                                      ,x_snap_date       => l_snapshot_date
                                      ,x_prev_snap_date  => l_prev_snap_date);


  x_pipe_mv := l_pipe_mv;
  x_snapshot_date := l_snapshot_date ;
  x_prev_snap_date := l_prev_snap_date;


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN

  x_pipe_mv := 'BIL_BI_PIPEC_G_MV';
  x_snapshot_date := TRUNC(SYSDATE);
  x_prev_snap_date := TRUNC(SYSDATE);

WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => fnd_message.get );

           END IF;

END GET_PIPE_MV;

--  **********************************************************************************
-- FUNCTION GET_HIST_SNAPSHOT_DATE
-- Purpose: Returns the snapshot date from Historical Pipeline MV closet date.
--  **********************************************************************************

FUNCTION GET_HIST_SNAPSHOT_DATE (    p_asof_date IN DATE,
                                     x_period_type IN VARCHAR2
				    ) RETURN DATE
AS

l_period_type      VARCHAR2(1000);
l_end_date         DATE;
l_period_end_date  DATE;
l_qtr_end_date     DATE;
l_year_end_date    DATE;
l_month_end_date   DATE;
l_as_of_date       DATE;
l_week_end_date    DATE;
l_week_start_date  DATE;
l_proc             VARCHAR2(1000);

BEGIN

g_pkg  := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_proc := 'GET_HIST_SNAPSHOT_DATE';

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Function '||l_proc);

                     END IF;

l_as_of_date := trunc(p_asof_date);
l_period_type := x_period_type;


    SELECT week_end_date, ent_period_end_date, ent_qtr_end_date, ent_year_end_date
           INTO l_week_end_date, l_period_end_date, l_qtr_end_date, l_year_end_date
    FROM FII_TIME_DAY
    WHERE report_date = l_as_of_date;


       IF (l_period_type = 'FII_TIME_ENT_PERIOD') THEN

           IF (l_period_end_date= l_as_of_date) THEN
              l_end_date := l_as_of_date;
           ELSE
              l_end_date := LEAST(l_week_end_date, l_period_end_date);
           END IF;

       ELSIF (l_period_type = 'FII_TIME_ENT_QTR') THEN

           IF (l_qtr_end_date= l_as_of_date) THEN
              l_end_date := l_as_of_date;
           ELSE
              l_end_date := LEAST(l_week_end_date, l_qtr_end_date);
           END IF;

       ELSIF (l_period_type = 'FII_TIME_ENT_YEAR') THEN

           IF (l_year_end_date= l_as_of_date) THEN
              l_end_date := l_as_of_date;
           ELSE
              l_end_date := LEAST(l_week_end_date, l_year_end_date);
           END IF;

       ELSE  --(week)

              l_end_date := l_week_end_date;
       END IF;


                    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;

RETURN l_end_date;

EXCEPTION

WHEN NO_DATA_FOUND THEN

RETURN TRUNC(SYSDATE);

WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => fnd_message.get );

           END IF;

END GET_HIST_SNAPSHOT_DATE;


--  **********************************************************************************
-- FUNCTION GET_PIPE_COL_NAMES
-- Purpose: Returns the column names for previous Year/Period for Pipe/Open/WtdPipe amts.
--  **********************************************************************************

FUNCTION GET_PIPE_COL_NAMES(         p_period_type   IN  VARCHAR2,
                                     p_compare_to    IN  VARCHAR2,
                                     p_column_type   IN  VARCHAR2,
                                     p_curr_suffix   IN  VARCHAR2
				     ) RETURN VARCHAR2
AS
l_period_type        VARCHAR2(1000);
l_compare_to         VARCHAR2(1000);
l_prev_amt           VARCHAR2(1000);
l_column_type        VARCHAR2(1000);
l_proc               VARCHAR2(1000);

BEGIN

g_pkg  := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_proc := 'GET_PIPE_COL_NAMES';

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Function '||l_proc);

                     END IF;


l_period_type := p_period_type ;
l_compare_to := p_compare_to;
l_column_type := p_column_type;

IF l_compare_to IS NOT NULL THEN

     CASE
         WHEN upper(l_column_type) = 'O' THEN l_prev_amt := '_OPEN_AMT_';
         WHEN upper(l_column_type) = 'P' THEN l_prev_amt := '_PIPE_AMT_';
         WHEN upper(l_column_type) = 'W' THEN l_prev_amt := '_WTD_PIPE_AMT_';
     END CASE;

-- TIME_COMPARISON_TYPE+YEARLY && TIME_COMPARISON_TYPE+SEQUENTIAL

      IF(l_compare_to = 'SEQUENTIAL') THEN
         CASE
             WHEN  l_period_type = 'FII_TIME_WEEK'      THEN
               l_prev_amt := 'PRVPRD'||l_prev_amt||'WK';

             WHEN  l_period_type = 'FII_TIME_ENT_PERIOD' THEN
               l_prev_amt := 'PRVPRD'||l_prev_amt||'PRD';

             WHEN  l_period_type = 'FII_TIME_ENT_QTR'    THEN
               l_prev_amt := 'PRVPRD'||l_prev_amt||'QTR';

             WHEN  l_period_type = 'FII_TIME_ENT_YEAR'   THEN
               l_prev_amt := 'PRVPRD'||l_prev_amt||'YR';
         END CASE;
      ELSIF (l_compare_to = 'YEARLY') THEN
         CASE
             WHEN  l_period_type = 'FII_TIME_WEEK'      THEN
                l_prev_amt := 'PRVYR'||l_prev_amt||'WK';

             WHEN  l_period_type = 'FII_TIME_ENT_PERIOD' THEN
                l_prev_amt := 'PRVYR'||l_prev_amt||'PRD';

             WHEN  l_period_type = 'FII_TIME_ENT_QTR'    THEN
               l_prev_amt := 'PRVYR'||l_prev_amt||'QTR';

             WHEN  l_period_type = 'FII_TIME_ENT_YEAR'   THEN
               l_prev_amt := 'PRVYR'||l_prev_amt||'YR';

         END CASE;
       END IF;

ELSE

     CASE
        WHEN upper(l_column_type) = 'O' THEN l_prev_amt := 'OPEN_AMT_';
        WHEN upper(l_column_type) = 'P' THEN l_prev_amt := 'PIPELINE_AMT_';
        WHEN upper(l_column_type) = 'W' THEN l_prev_amt := 'WTD_PIPELINE_AMT_';
     END CASE;

     CASE
       WHEN  l_period_type = 'FII_TIME_WEEK'      THEN
               l_prev_amt := l_prev_amt||'WEEK';

       WHEN  l_period_type = 'FII_TIME_ENT_PERIOD' THEN
               l_prev_amt := l_prev_amt||'PERIOD';

       WHEN  l_period_type = 'FII_TIME_ENT_QTR'    THEN
               l_prev_amt := l_prev_amt||'QUARTER';

       WHEN  l_period_type = 'FII_TIME_ENT_YEAR'   THEN
               l_prev_amt := l_prev_amt||'YEAR';
     END CASE;
END IF;

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Function '||l_proc);

                     END IF;
 RETURN l_prev_amt||p_curr_suffix;

EXCEPTION

WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => fnd_message.get );

           END IF;

END GET_PIPE_COL_NAMES;


--  **********************************************************************************
-- PROCEDURE GET_PIPE_TREND_SOURCE
-- Purpose: Returns the Pipeline MV Curr/Hist/View along with Snapshot Date.
--  **********************************************************************************

PROCEDURE GET_PIPE_TREND_SOURCE (p_as_of_date          IN DATE,
                                 p_prev_date           IN DATE,
                                 p_trend_type          IN VARCHAR2,
                                 p_period_type         IN VARCHAR2,
                                 p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                                 x_pipe_mv             OUT NOCOPY VARCHAR2,
                                 x_snap_date           OUT NOCOPY DATE,
                                 x_prev_snap_date      OUT NOCOPY DATE)
AS

l_coll_st_date   DATE;
l_coll_end_date  DATE;
l_period_start_date     DATE;
l_tmp_date       DATE;
l_as_of_date     DATE;
l_snapshot_date      DATE;
l_prev_snap_date DATE;
l_pipe_mv        VARCHAR2(200);
l_proc           VARCHAR2(1000);
l_sysdate        DATE:= TRUNC(sysdate);

BEGIN

g_pkg  := 'bil.patch.115.sql.BIL_BI_UTIL_PKG.';
l_proc := 'GET_PIPE_TREND_SOURCE';

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;

l_as_of_date:= trunc(p_as_of_date);

        SELECT to_date(attribute1, 'dd/mm/yyyy'), MAX(to_date(attribute2, 'dd/mm/yyyy'))
        INTO l_coll_st_date,l_coll_end_date
        FROM bis_refresh_log a
        WHERE
        a.last_update_date = (
                         SELECT MAX(b.last_update_date) FROM bis_refresh_log b
					WHERE b.object_name = 'BIL_BI_PIPEC_F'
					AND status = 'SUCCESS'
				)
       AND a.object_name = 'BIL_BI_PIPEC_F'
       AND status = 'SUCCESS'
       group by to_date(attribute1, 'dd/mm/yyyy');

---to get MV

    IF (l_as_of_date <  l_coll_st_date) THEN
          l_pipe_mv := 'BIL_BI_PIPE_G_MV';
    ELSE
          l_pipe_mv := 'BIL_BI_PIPE_G_V';
    END IF;


    IF p_trend_type = 'P' THEN

        SELECT MIN(date2) INTO l_tmp_date FROM bil_bi_rpt_tmp1;

        IF (l_tmp_date >= l_coll_st_date) THEN
             l_pipe_mv := 'BIL_BI_PIPEC_G_MV';
        END IF;

    END IF;

/*
  IF p_trend_type = 'P' THEN

     SELECT MIN(date2) INTO l_tmp_date FROM bil_bi_rpt_tmp1;

     IF (l_tmp_date >= l_coll_st_date) THEN
             l_pipe_mv := 'BIL_BI_PIPEC_G_MV';
     ELSE
           IF (l_as_of_date <  l_coll_st_date) THEN
              l_pipe_mv := 'BIL_BI_PIPE_G_MV';
           ELSE
              l_pipe_mv := 'BIL_BI_PIPE_G_V';
           END IF;
     END IF;
  ELSE
           IF (l_as_of_date <  l_coll_st_date) THEN
              l_pipe_mv := 'BIL_BI_PIPE_G_MV';
           ELSE
              l_pipe_mv := 'BIL_BI_PIPE_G_V';
           END IF;
  END IF;
*/
--to get snapshot date

   BIL_BI_UTIL_PKG.GET_PIPE_SNAP_DATE(p_as_of_date =>  l_as_of_date
                                      ,p_prev_date  =>  p_prev_date
                                      ,p_period_type => p_period_type
                                      ,p_coll_st_date => l_coll_st_date
                                      ,p_coll_end_date => l_coll_end_date
                                      ,p_page_parameter_tbl => p_page_parameter_tbl
                                      ,x_snap_date       => l_snapshot_date
                                      ,x_prev_snap_date  => l_prev_snap_date);

   IF (p_prev_date IS NOT NULL AND l_prev_snap_date IS NULL) THEN

      l_prev_snap_date := BIL_BI_UTIL_PKG.GET_HIST_SNAPSHOT_DATE(p_prev_date, p_period_type);

   END IF;

    x_pipe_mv   := l_pipe_mv;
    x_snap_date := l_snapshot_date;
    x_prev_snap_date := l_prev_snap_date;




                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN

  x_pipe_mv := 'BIL_BI_PIPEC_G_MV';
  x_snap_date := TRUNC(SYSDATE);
  x_prev_snap_date := TRUNC(SYSDATE);

WHEN OTHERS THEN

           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
              fnd_message.set_token('Error is : ' ,SQLCODE);
              fnd_message.set_token('Reason is : ', SQLERRM);

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => fnd_message.get );

           END IF;

END GET_PIPE_TREND_SOURCE;

END BIL_BI_UTIL_PKG;

/
