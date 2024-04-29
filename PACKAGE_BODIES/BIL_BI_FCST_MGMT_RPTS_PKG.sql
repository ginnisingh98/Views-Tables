--------------------------------------------------------
--  DDL for Package Body BIL_BI_FCST_MGMT_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_FCST_MGMT_RPTS_PKG" AS
/* $Header: bilbfsb.pls 120.4 2005/09/01 03:19:23 vchahal noship $ */
 g_pkg			VARCHAR2(100);
 g_sch_name VARCHAR2(100);
 /*******************************************************************************
 * Name    : Procedure BIL_BI_FRCST_OVERVIEW
 * Author  : Prasanna Patil
 * Date    : December 15, 2003
 * Purpose : Forecast Overview.
 *
 *           Copyright (c) 2003 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl     PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 * Date      Author     Description
 * ----      ------     -----------
 * 12/15/03  ppatil   Initial version
 * 02/06/03  ppatil	  Modified for View By Product Category query.
 ******************************************************************************/
PROCEDURE BIL_BI_FRCST_OVERVIEW ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                ,x_custom_sql         OUT NOCOPY VARCHAR2
                                ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )

 IS

    l_period_type               VARCHAR2(50);
    l_sg_id                     VARCHAR2(50);
    l_conv_rate_selected        VARCHAR2(50);
    l_curr_page_time_id         NUMBER;
    l_prev_page_time_id         NUMBER;
    l_region_id                 VARCHAR2(50);
    l_comp_type                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_bitand_id                 VARCHAR2(50);
    l_calendar_id               VARCHAR2(50);
    l_curr_as_of_date           DATE;
    l_prev_date                 DATE;
    l_page_period_type          VARCHAR2(50);
    l_bis_sysdate               DATE;
    l_fii_struct                VARCHAR2(50);
    l_record_type_id            NUMBER;
    l_sql_error_msg             VARCHAR2(1000);
    l_sql_error_desc            VARCHAR2(1000);
    l_sg_id_num                 NUMBER;
    l_fst_crdt_type             VARCHAR2(50);
    l_inner_where_clause        VARCHAR2(1000);
    l_sql_stmnt1              	VARCHAR2(32000);
    l_sql_stmnt2              	VARCHAR2(32000);
    l_sql_stmnt3              	VARCHAR2(32000);

	/* thefollwoing 3 variables are used only for VB=SG*/
    l_sql_stmnt1_1            	VARCHAR2(32000);
    l_sql_stmnt2_1            	VARCHAR2(32000);
    l_sql_stmnt3_1            	VARCHAR2(32000);

    l_sql_stmnt4                VARCHAR2(32000);
    l_custom_sql		VARCHAR2(32000);
    l_insert_stmnt		VARCHAR2(5000);
    l_outer_select		VARCHAR2(5000);
    l_where_clause1		VARCHAR2(5000);
    l_where_clause2		VARCHAR2(5000);
    l_where_clause3		VARCHAR2(5000);
    l_where_clause4		VARCHAR2(5000);
    l_prodcat_id                VARCHAR2(20);
    l_viewby                    VARCHAR2(200);
    l_resource_id		VARCHAR2(20);
    l_url_str          	   	VARCHAR2(1000);
    l_drill_str          	VARCHAR2(1000);
    l_cat_assign                VARCHAR2(1000);
    l_denorm		 	VARCHAR2(50);
    l_denorm1			VARCHAR2(50);
    l_cat_url			VARCHAR2(1000);
    l_sumry			VARCHAR2(50);
    l_sumry1			VARCHAR2(50);
    l_sumry2			VARCHAR2(50);
    l_product_where_clause1	VARCHAR2(2000);
    l_product_where_clause2	VARCHAR2(2000);
    l_yes			VARCHAR2(1);
    l_no			VARCHAR2(1);
    l_assign_cat		BOOLEAN;
    l_dummy_cnt			INTEGER;
    l_snap_date			DATE;
--    l_show_pipe_info		BOOLEAN;
    l_proc                      VARCHAR2(100);
    l_null_removal_clause	VARCHAR2(1000);
    l_parent_sales_group_id	NUMBER;
    l_parent_sls_grp_where_clause	VARCHAR2(1000);
    l_pipe_product_where_clause	VARCHAR2(1000);
    l_pipe_denorm               VARCHAR2(100);

    l_pc_select			VARCHAR2(32000);
    l_unassigned_value  VARCHAR2(100);
    l_prodcat_flag      VARCHAR2(200);

    l_currency_suffix   VARCHAR2(5);
    l_lookup_type       VARCHAR2(30);
    l_lookup_code       VARCHAR2(30);
    l_lang              VARCHAR2(30);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

    l_prev_pipe_amt          VARCHAR2(300);
    l_prv_wt_pipe_amt        VARCHAR2(300);
    l_column_type            VARCHAR2(1000);
    l_snapshot_date          DATE;
    l_open_mv_new            VARCHAR2(1000);
    l_open_mv_new1           VARCHAR2(1000);
    l_prev_snap_date         DATE;
    l_pipe_select1           VARCHAR2(4000);
    l_pipe_select2           VARCHAR2(4000);
    l_pipe_select3           VARCHAR2(4000);
    l_pipe_select4           VARCHAR2(4000);
    l_pipe_select5           VARCHAR2(4000);
    l_pc_pipe_select1           VARCHAR2(4000);
    l_pc_pipe_select2           VARCHAR2(4000);
    l_pc_pipe_select3           VARCHAR2(4000);
    l_pc_pipe_select4           VARCHAR2(4000);
    l_pc_pipe_select5           VARCHAR2(4000);
    l_inner_where_pipe       VARCHAR2(4000);



    BEGIN

    g_pkg := 'bil.patch.115.sql.BIL_BI_FCST_MGMT_RPTS_PKG.';
    l_region_id := 'BIL_BI_FRCST_OVERVIEW';
    l_parameter_valid := FALSE;
    l_yes := 'Y';
    l_no := 'N';
    l_proc := 'BIL_BI_FRCST_OVERVIEW.';
    g_sch_name := 'BIL';


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		      MODULE => g_pkg || l_proc || 'begin',
		      MESSAGE => 'Start of Procedure '||l_proc);

    END IF;


    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

    l_lookup_type := 'BIL_BI_LOOKUPS';
    l_lookup_code := 'ASSIGN_CATEG';
    l_lang        :=  USERENV('LANG');

    SELECT Meaning INTO l_cat_assign
    FROM FND_LOOKUP_VALUES
    WHERE LOOKUP_TYPE = l_lookup_type
      AND LOOKUP_CODE = l_lookup_code
      AND LANGUAGE = l_lang;

BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl  => p_page_parameter_tbl
                                    ,p_region_id 	  => l_region_id
                                    ,x_period_type 	  => l_period_type
                                    ,x_conv_rate_selected => l_conv_rate_selected
                                    ,x_sg_id 		  => l_sg_id
				    ,x_parent_sg_id	  => l_parent_sales_group_id
				    ,x_resource_id	  => l_resource_id
                                    ,x_prodcat_id 	  => l_prodcat_id
                                    ,x_curr_page_time_id  => l_curr_page_time_id
                                    ,x_prev_page_time_id  => l_prev_page_time_id
                                    ,x_comp_type 	  => l_comp_type
                                    ,x_parameter_valid 	  => l_parameter_valid
                                    ,x_as_of_date 	  => l_curr_as_of_date
                                    ,x_page_period_type   => l_page_period_type
                                    ,x_prior_as_of_date   => l_prev_date
                                    ,x_record_type_id 	  => l_record_type_id
                                    ,x_viewby             => l_viewby );

/*
   BIL_BI_UTIL_PKG.GET_LATEST_SNAP_DATE(p_page_parameter_tbl  => p_page_parameter_tbl
                                           ,p_as_of_date      => l_curr_as_of_date
                                           ,p_period_type     => NULL
                                           ,x_snapshot_date   => l_snap_date);
*/


/*** Query column mapping ******************************************************
*	Internal Name	Grand Total	Region Item Name
*	BIL_MEASURE1	BIL_MEASURE13 	Forecast
*	BIL_MEASURE2	BIL_MEASURE14	Prior Forecast
*	BIL_MEASURE3	BIL_MEASURE15	Change
*	BIL_MEASURE4	BIL_MEASURE16   Weighted Pipeline
*	BIL_MEASURE5	BIL_MEASURE17	Prior Weighted Pipeline
*	BIL_MEASURE6	BIL_MEASURE18	Change
*	BIL_MEASURE7	BIL_MEASURE19	Pipeline
*	BIL_MEASURE8	BIL_MEASURE20	Prior Pipeline
*	BIL_MEASURE9	BIL_MEASURE21	Change
*	BIL_MEASURE10	BIL_MEASURE22	Won
*	BIL_MEASURE11	BIL_MEASURE23	Prior Won
*	BIL_MEASURE12	BIL_MEASURE24	Change
*	BIL_MEASURE25	BIL_MEASURE26	Forecast - used for 2nd Graph
*******************************************************************************/

   IF l_parameter_valid THEN

      l_drill_str:=BIL_BI_UTIL_PKG.GET_DRILL_LINKS(p_view_by       => l_viewby
                                                   ,p_salesgroup_id => l_sg_id
                                                   ,p_resource_id   => l_resource_id);

	IF l_prodcat_id IS NULL THEN
           l_prodcat_id := 'All';
	ELSE
	   l_prodcat_id := to_number(REPLACE(l_prodcat_id,'''',''));
       END IF;

       IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
       ELSE
            l_currency_suffix := '';
       END IF;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		      MODULE => g_pkg || l_proc,
		      MESSAGE => 'l_parameter_valid = true');

    END IF;



/* Get the Prefix for the Open amt based upon Period Type and Compare To Params */


l_prev_pipe_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'P',
                                     p_curr_suffix    => l_currency_suffix
				    );



l_prv_wt_pipe_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'W',
                                     p_curr_suffix    => l_currency_suffix
				    );


/* Use the  BIL_BI_UTIL_PKG.GET_PIPE_MV proc to get the MV name and snap date for Pipeline/Open Amts. */



      BIL_BI_UTIL_PKG.GET_PIPE_MV(
                                     p_asof_date  => l_curr_as_of_date ,
                                     p_period_type  => l_page_period_type ,
                                     p_compare_to  =>  l_comp_type  ,
                                     p_prev_date  => l_prev_date,
                                     p_page_parameter_tbl => p_page_parameter_tbl,
                                     x_pipe_mv    => l_open_mv_new ,
                                     x_snapshot_date => l_snapshot_date  ,
                                     x_prev_snap_date  => l_prev_snap_date
				    );



       l_insert_stmnt  := 'INSERT INTO BIL_BI_RPT_TMP1 (VIEWBY, VIEWBYID, SORTORDER,BIL_MEASURE28,'||
			 	'BIL_MEASURE2,BIL_MEASURE4,BIL_MEASURE5,BIL_MEASURE7,BIL_MEASURE8, BIL_MEASURE10,'||
				'BIL_MEASURE11, BIL_URL1, BIL_URL2)';

       l_url_str:='pFunctionName=BIL_BI_FSTOVER_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
       l_outer_select := 'SELECT VIEWBY '||
		',VIEWBYID '||
		',BIL_MEASURE28 BIL_MEASURE1 '||
		',BIL_MEASURE2 '||
		',(BIL_MEASURE28-BIL_MEASURE2)/ABS(DECODE(BIL_MEASURE2,0,null,BIL_MEASURE2))*100 BIL_MEASURE3 '||
		',BIL_MEASURE10 BIL_MEASURE27 '||
		',BIL_MEASURE4 '||
		',BIL_MEASURE5 '||
		',(BIL_MEASURE4-BIL_MEASURE5)/ABS(DECODE(BIL_MEASURE5,0,null,BIL_MEASURE5))*100  BIL_MEASURE6 '||
		',BIL_MEASURE28 BIL_MEASURE25 '||
		',BIL_MEASURE7 '||
		',BIL_MEASURE8 '||
		',(BIL_MEASURE7-BIL_MEASURE8)/ABS(DECODE(BIL_MEASURE8, 0, null, BIL_MEASURE8))*100  BIL_MEASURE9 '||
		',BIL_MEASURE10 '||
		',BIL_MEASURE11 '||
		',(BIL_MEASURE10-BIL_MEASURE11)/ABS(DECODE(BIL_MEASURE11, 0 ,null, BIL_MEASURE11))*100 BIL_MEASURE12 '||
		',SUM(BIL_MEASURE28) OVER() BIL_MEASURE13 '||
		',SUM(BIL_MEASURE2) OVER() BIL_MEASURE14 '||
		',(SUM(BIL_MEASURE28) OVER() - SUM(BIL_MEASURE2) OVER())/ABS(DECODE(SUM(BIL_MEASURE2) OVER(), 0, null, '||
					'SUM(BIL_MEASURE2) OVER()))*100 BIL_MEASURE15 '||
		',SUM(BIL_MEASURE4) OVER() BIL_MEASURE16 '||
		',SUM(BIL_MEASURE5) OVER() BIL_MEASURE17 '||
		',(SUM(BIL_MEASURE4) OVER() - SUM(BIL_MEASURE5) OVER())/ABS(DECODE(SUM(BIL_MEASURE5) OVER(), 0, null, '||
					'SUM(BIL_MEASURE5) OVER()))*100  BIL_MEASURE18 '||
		',SUM(BIL_MEASURE7) OVER() BIL_MEASURE19 '||
		',SUM(BIL_MEASURE8) OVER()  BIL_MEASURE20 '||
		',(SUM(BIL_MEASURE7) OVER() - SUM(BIL_MEASURE8) OVER())/ABS(DECODE(SUM(BIL_MEASURE8) OVER(), 0, null, '||
					'SUM(BIL_MEASURE8) OVER()))*100  BIL_MEASURE21'||
		',SUM(BIL_MEASURE10) OVER() BIL_MEASURE22 '||
		',SUM(BIL_MEASURE11) OVER() BIL_MEASURE23 '||
		',(SUM(BIL_MEASURE10) OVER() - SUM(BIL_MEASURE11) OVER())/ABS(DECODE(SUM(BIL_MEASURE11) OVER(), 0, null, '||
				'SUM(BIL_MEASURE11) OVER()))*100  BIL_MEASURE24'||
		',SUM(BIL_MEASURE28) OVER() BIL_MEASURE26'||
		',SUM(BIL_MEASURE10) OVER() BIL_MEASURE28 '||
		', BIL_URL1 '||
		', BIL_URL2 '||
                ',DECODE('''||l_curr_as_of_date||''',TRUNC(SYSDATE),DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'','||
                'DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=PIPELINE'''||'),'||
                'DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=PIPELINE'''||')),NULL) BIL_URL3 '||
                ',DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'','||
                'DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=WON'''||'),'||
                'DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=WON'''||')) BIL_URL4 ';


		l_sql_stmnt1 :=	'(case when  sumry.effective_time_id = :l_curr_page_time_id AND '||
						'cal.report_date =:l_curr_as_of_date '||
				      	'then sumry.forecast_amt'||l_currency_suffix||' else NULL end) AS frcst '||
			       	',(case when  sumry.effective_time_id = :l_prev_page_time_id AND '||
						'cal.report_date =:l_prev_date '||
					'then sumry.forecast_amt'||l_currency_suffix||' else NULL end) AS priorFrcst '||
				',NULL AS wtdPipeline '||
				',NULL AS priorWtdPipeline '||
				',NULL AS pipeline '||
				',NULL AS priorPipeline '||
				',NULL AS won '||
				',NULL AS priorWon ';

		l_sql_stmnt1_1 :=	'SUM((case when  sumry.effective_time_id = :l_curr_page_time_id AND '||
						'cal.report_date =:l_curr_as_of_date '||
				      	'then sumry.forecast_amt'||l_currency_suffix||' else NULL end)) AS frcst '||
			       	',SUM((case when  sumry.effective_time_id = :l_prev_page_time_id AND '||
						'cal.report_date =:l_prev_date '||
					'then sumry.forecast_amt'||l_currency_suffix||' else NULL end)) AS priorFrcst '||
				',NULL AS wtdPipeline '||
				',NULL AS priorWtdPipeline '||
				',NULL AS pipeline '||
				',NULL AS priorPipeline '||
				',NULL AS won '||
				',NULL AS priorWon ';

		l_sql_stmnt4 :='(case when  sumry.effective_time_id = :l_curr_page_time_id AND '||
						 	'cal.report_date =:l_curr_as_of_date '||
				'then decode(sumry.salesrep_id, NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||') '||
						' else NULL end)  AS frcst '||
				',(case when  sumry.effective_time_id = :l_prev_page_time_id AND '||
						'cal.report_date =:l_prev_date '||
				'then decode(sumry.salesrep_id, NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||') '||
						'else NULL end) AS priorFrcst '||
				',NULL AS wtdPipeline '||
				',NULL AS priorWtdPipeline '||
				',NULL AS pipeline '||
				',NULL AS priorPipeline '||
				',NULL AS won '||
				',NULL AS priorWon ';
		l_where_clause1 := ' WHERE sumry.TXN_TIME_ID = cal.TIME_ID '||
					  'AND sumry.TXN_PERIOD_TYPE_ID = cal.PERIOD_TYPE_ID '||
					  'AND bitand(cal.record_type_id, :l_bitand_id)= :l_bitand_id '||
					  'AND sumry.EFFECTIVE_PERIOD_TYPE_ID = :l_period_type '||
					  'AND NVL(sumry.credit_type_id, :l_fst_crdt_type) = :l_fst_crdt_type  '||
					  'AND cal.report_date in (:l_curr_as_of_date, :l_prev_date) '||
					  'AND sumry.effective_time_id in (:l_curr_page_time_id, :l_prev_page_time_id) ';

		l_sql_stmnt2 :='  NULL AS frcst '||
				', NULL AS priorFrcst '||
				', NULL AS wtdPipeline '||
				', NULL priorWtdPipeline '||
				', NULL pipeline '||
				', NULL priorPipeline '||
				',(case when  cal.report_date =:l_curr_as_of_date '||
					'then sumry.won_opty_amt'||l_currency_suffix||' else NULL end)  AS won '||
				', (case when  cal.report_date =:l_prev_date '||
					'then sumry.won_opty_amt'||l_currency_suffix||' else NULL end) AS priorWon';

		l_sql_stmnt2_1 :='  NULL AS frcst '||
				', NULL AS priorFrcst '||
				', NULL AS wtdPipeline '||
				', NULL priorWtdPipeline '||
				', NULL pipeline '||
				', NULL priorPipeline '||
				', SUM((case when  cal.report_date =:l_curr_as_of_date '||
					'then sumry.won_opty_amt'||l_currency_suffix||' else NULL end)) AS won '||
				', SUM((case when  cal.report_date =:l_prev_date '||
					'then sumry.won_opty_amt'||l_currency_suffix||' else NULL end)) AS priorWon';

		l_where_clause2:=' WHERE sumry.effective_time_id = cal.time_id '||
		  			'AND sumry.effective_period_type_id = cal.PERIOD_TYPE_ID '||
		  			'AND bitand(cal.record_type_id, :l_record_type_id )= :l_record_type_id  '||
		  			'AND cal.report_date in (:l_curr_as_of_date, :l_prev_date) ';

l_pipe_select1 := ' NULL AS frcst '||
                      ',NULL AS priorFrcst '||
                      ',SUM((case when  :l_snapshot_date = sumry.snap_date then '||
                      'decode(:l_period_type, '||
                      '128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                      '64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                      '32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                      '16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
                      ')'||
                      'end)) AS wtdPipeline ';

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN

       l_pipe_select2 := ',SUM((case when  :l_prev_snap_date = sumry.snap_date then '||
                            'decode(:l_period_type, '||
                            '128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                            '64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                            '32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                            '16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
                            ')'||
                            'end))  AS priorWtdPipeline ';
ELSE
       l_pipe_select2 := ' , sum((CASE WHEN sumry.snap_date = :l_snapshot_date THEN '||
                          ''||l_prv_wt_pipe_amt||' '||
                           ' ELSE NULL '||
                 ' END))  AS priorWtdPipeline ';
END IF;

l_pipe_select3 := ',SUM((case when  :l_snapshot_date = sumry.snap_date then '||
                    'decode(:l_period_type, '||
                    '128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                    '64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                    '32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                    '16,PIPELINE_AMT_WEEK'||l_currency_suffix||
                    ')'||
                    'end)) AS pipeline ';

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
       l_pipe_select4 := ',SUM((case when  :l_prev_snap_date = sumry.snap_date then '||
                    'decode(:l_period_type, '||
                    '128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                    '64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                    '32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                    '16,PIPELINE_AMT_WEEK'||l_currency_suffix||
                    ')'||
                    'end)) AS priorPipeline ';
ELSE
       l_pipe_select4 := ' , sum((CASE WHEN sumry.snap_date =:l_snapshot_date THEN '||
                          ''||l_prev_pipe_amt||' '||
                           ' ELSE NULL '||
                 ' END))  AS priorPipeline ';

END IF;

       l_pipe_select5 :=',NULL AS won '||
                        ',NULL AS priorWon ';

l_sql_stmnt3_1 := l_pipe_select1 || l_pipe_select2 || l_pipe_select3 || l_pipe_select4 || l_pipe_select5 ;


/*
l_sql_stmnt3_1 :=' NULL AS frcst '||
',NULL AS priorFrcst '||
',SUM((case when  :l_snap_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end)) AS wtdPipeline '||
',SUM((case when  :l_prev_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end))  AS priorWtdPipeline '||
',SUM((case when  :l_snap_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end)) AS pipeline '||
',SUM((case when  :l_prev_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end)) AS priorPipeline '||
',NULL AS won '||
',NULL AS priorWon ';
*/

l_pc_pipe_select1 := ' NULL AS frcst '||
                      ',NULL AS priorFrcst '||
                      ',((case when  :l_snapshot_date = sumry.snap_date then '||
                      'decode(:l_period_type, '||
                      '128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                      '64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                      '32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                      '16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
                      ')'||
                      'end)) AS wtdPipeline ';

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN

       l_pc_pipe_select2 := ',((case when  :l_prev_snap_date = sumry.snap_date then '||
                            'decode(:l_period_type, '||
                            '128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                            '64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                            '32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                            '16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
                            ')'||
                            'end))  AS priorWtdPipeline ';
ELSE
       l_pc_pipe_select2 := ' , ((CASE WHEN sumry.snap_date = :l_snapshot_date THEN '||
                          ''||l_prv_wt_pipe_amt||' '||
                           ' ELSE NULL '||
                 ' END))  AS priorWtdPipeline ';
END IF;

l_pc_pipe_select3 := ', ((case when  :l_snapshot_date = sumry.snap_date then '||
                    'decode(:l_period_type, '||
                    '128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                    '64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                    '32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                    '16,PIPELINE_AMT_WEEK'||l_currency_suffix||
                    ')'||
                    'end)) AS pipeline ';

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
       l_pc_pipe_select4 := ', ((case when  :l_prev_snap_date = sumry.snap_date then '||
                    'decode(:l_period_type, '||
                    '128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                    '64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                    '32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                    '16,PIPELINE_AMT_WEEK'||l_currency_suffix||
                    ')'||
                    'end)) AS priorPipeline ';
ELSE
       l_pc_pipe_select4 := ' , ((CASE WHEN sumry.snap_date =:l_snapshot_date THEN '||
                          ''||l_prev_pipe_amt||' '||
                           ' ELSE NULL '||
                 ' END))  AS priorPipeline ';

END IF;

       l_pc_pipe_select5 :=',NULL AS won '||
                        ',NULL AS priorWon ';

l_sql_stmnt3 := l_pc_pipe_select1 ||
                  l_pc_pipe_select2 ||
                  l_pc_pipe_select3 ||
                  l_pc_pipe_select4 || l_pc_pipe_select5 ;


/*
l_sql_stmnt3 :=' NULL AS frcst '||
',NULL AS priorFrcst '||
',(case when  :l_snap_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end) AS wtdPipeline '||
',(case when  :l_prev_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end)  AS priorWtdPipeline '||
',(case when  :l_snap_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end) AS pipeline '||
',(case when  :l_prev_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end) AS priorPipeline '||
',NULL AS won '||
',NULL AS priorWon ';

*/


--	l_where_clause3 := ' WHERE sumry.snap_date in (:l_snap_date, :l_prev_date) ' ;


IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
   l_where_clause3 := '  WHERE  sumry.snap_date in (:l_snapshot_date, :l_prev_snap_date) ';
ELSE
   l_where_clause3 := '  WHERE  sumry.snap_date in (:l_snapshot_date) ';
END IF;

		BIL_BI_UTIL_PKG.GET_FORECAST_PROFILES( x_fstcrdttype => l_fst_crdt_type );

        	BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id          =>l_bitand_id,
			                             x_calendar_id        =>l_calendar_id,
			                             x_curr_date          =>l_bis_sysdate,
			                             x_fii_struct         =>l_fii_struct);

        	l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
		l_null_removal_clause := 'NOT(BIL_MEASURE1 IS NULL AND BIL_MEASURE4 IS NULL AND '||
									  		' BIL_MEASURE7 IS NULL AND '||
											' BIL_MEASURE10 IS NULL) ';
                 execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';


    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

    		l_sql_error_desc :=
        		'l_viewby => '||l_viewby||', '||
        		'l_curr_page_time_id => '|| l_curr_page_time_id ||', ' ||
        		'l_prev_page_time_id => '|| l_prev_page_time_id ||', ' ||
        		'l_curr_as_of_date => '|| l_curr_as_of_date ||', ' ||
        		'l_prev_date => '|| l_prev_date ||', ' ||
        		'l_conv_rate_selected => '|| l_conv_rate_selected ||', ' ||
        		'l_bitand_id => '|| l_bitand_id ||', ' ||
        		'l_period_type => '|| l_period_type ||', ' ||
        		'l_sg_id_num => '|| l_sg_id_num ||', ' ||
			'l_resource_id => '||l_resource_id||', '||
        		'l_fst_crdt_type => '|| l_fst_crdt_type ||', ' ||
        		'l_calendar_id => '|| l_calendar_id;


       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		      MODULE => g_pkg || l_proc || 'l_sql_error_desc',
          	      MESSAGE => l_sql_error_desc);

    END IF;



		BIL_BI_UTIL_PKG.GET_PC_NOROLLUP_WHERE_CLAUSE(
                                          p_prodcat      => l_prodcat_id,
                                          p_viewby       => l_viewby,
                                          x_denorm       => l_pipe_denorm,
                                          x_where_clause => l_pipe_product_where_clause);


    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		      MODULE => g_pkg || l_proc || ' l_viewby =>'||l_viewby,
		      MESSAGE => ' Prod cat '||l_prodcat_id);

       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		      MODULE => g_pkg || l_proc || ' l_pipe_prod_where =>',
		      MESSAGE => ' l_pipe_product_where_clause '||l_pipe_product_where_clause);

    END IF;


		CASE l_viewby
			WHEN 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
			      IF l_prodcat_id = 'All' THEN
				   l_pipe_product_where_clause := '';
				   l_denorm1 := '';
                   l_sumry := 'BIL_BI_FST_G_MV';
				   l_sumry1 := 'BIL_BI_OPTY_G_MV';
--				   l_sumry2 := 'BIL_BI_PIPE_G_MV';
			    	   l_sumry2 := l_open_mv_new;
				   l_where_clause3 := l_where_clause3||' AND sumry.grp_total_flag = 1 ';
				    l_prodcat_flag := ' ';
                              ELSE
				   l_sumry := 'BIL_BI_FST_PG_MV';
				   l_sumry1 := 'BIL_BI_OPTY_PG_MV';
--				   l_sumry2 := 'BIL_BI_PIPE_G_MV';
			    	   l_sumry2 := l_open_mv_new;
				   l_denorm := ' ';

				   l_product_where_clause2 := ' AND sumry.product_category_id = :l_productcat_id ';
				   l_where_clause3 := l_where_clause3||' AND sumry.grp_total_flag = 0 ';
                                   l_prodcat_flag := 'sumry.product_category_id, ';
			      END IF;

                         IF l_resource_id IS NULL THEN
			       l_custom_sql:='SELECT DECODE(tmp1.salesrep_id, NULL, grptl.group_name,restl.resource_name) VIEWBY '||
				   	',DECODE(tmp1.salesrep_id, NULL, to_char(tmp1.sales_group_id),'||
					' tmp1.salesrep_id||''.''||tmp1.sales_group_id ) VIEWBYID '||
				   				', SORTORDER '||
				   				',BIL_MEASURE28
                                , BIL_MEASURE2, BIL_MEASURE4, BIL_MEASURE5, BIL_MEASURE7,
                                BIL_MEASURE8, BIL_MEASURE10, BIL_MEASURE11,
                                DECODE(tmp1.salesrep_id, NULL, '''||l_url_str||''', NULL) BIL_URL1,
                                DECODE(tmp1.salesrep_id, NULL, NULL,'''||l_drill_str||''') BIL_URL2 FROM (
                                SELECT /*+ NO_MERGE */ salesrep_id, sales_group_id,
                                sortorder, parent_sales_group_id
                                ,SUM(frcst) BIL_MEASURE28 '||
								',SUM(priorFrcst) BIL_MEASURE2 '||
								',SUM(wtdPipeline) BIL_MEASURE4 '||
								',SUM(priorWtdPipeline) BIL_MEASURE5 '||
								',SUM(pipeline) BIL_MEASURE7 '||
								',SUM(priorPipeline) BIL_MEASURE8 '||
								',SUM(won) BIL_MEASURE10 '||
								',SUM(priorWon) BIL_MEASURE11 '||
								', NULL BIL_URL1 '||
								', NULL BIL_URL2 '||
								' FROM  '||
								'( '||
					 'SELECT /*+ LEADING(cal) */ '||
					  	' '||l_prodcat_flag||'
                          decode(sumry.salesrep_id, NULL,1,2) sortorder, '||
				 		'sumry.salesrep_id, '||
				 		'sumry.sales_group_id, '||
						'sumry.parent_sales_group_id parent_sales_group_id, '||
						l_sql_stmnt1_1||
					 ' FROM '||l_fii_struct||' cal, '||l_sumry||' sumry '||
						 l_denorm1||
					l_where_clause1||
					' AND sumry.parent_sales_group_id = :l_sg_id_num  '||
					' AND cal.xtd_flag = :l_yes '||
					' '||l_product_where_clause2||
					' GROUP BY '||
					  ' decode(sumry.salesrep_id, NULL,1,2),sumry.salesrep_id,sumry.sales_group_id,'||
						l_prodcat_flag||' sumry.parent_sales_group_id '||
					' UNION ALL '||
					' select  '||l_prodcat_flag||' sortorder, salesrep_id,
                    sales_group_id, parent_sales_group_id,
                    sum(frcst) frcst, sum(priorFrcst) priorFrcst,
                    sum(wtdPipeline) wtdPipeline,
                    sum(priorWtdPipeline) priorWtdPipeline,
                    sum(pipeline) pipeline,
                    sum(priorPipeline) priorPipeline, sum(won) won,
                    sum(priorWon) priorWon from (
                    SELECT /*+ LEADING(cal) */ '||
                        ' '||l_prodcat_flag||'
						decode(sumry.salesrep_id, NULL,1,2) sortorder, '||
				 		'sumry.salesrep_id, '||
				 		'sumry.sales_group_id, '||
						'sumry.parent_sales_group_id parent_sales_group_id, '||
						l_sql_stmnt2_1||
					' FROM '||l_fii_struct||' cal, '||l_sumry1||' sumry '||
					l_where_clause2||
					' AND sumry.parent_sales_group_id = :l_sg_id_num '||
					' AND cal.xtd_flag = :l_yes '||
					' GROUP BY '||
					  ' decode(sumry.salesrep_id, NULL,1,2),sumry.salesrep_id,sumry.sales_group_id,'||
						l_prodcat_flag||' sumry.parent_sales_group_id ';

				   	  l_custom_sql:= l_custom_sql||
						  ' UNION ALL '||
						  ' SELECT  '||l_prodcat_flag||'
                          decode(sumry.salesrep_id, NULL,1,2) sortorder, '||
				 		  	  'sumry.salesrep_id, '||
				 		  	  'sumry.sales_group_id, '||
							  'sumry.parent_sales_group_id parent_sales_group_id, '||
							  l_sql_stmnt3_1||
						  ' FROM '||l_sumry2||' sumry '||
						  l_where_clause3||
						  ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
					' GROUP BY '||
					  ' decode(sumry.salesrep_id, NULL,1,2),sumry.salesrep_id,sumry.sales_group_id,'||
						l_prodcat_flag||' sumry.parent_sales_group_id ';

				   l_custom_sql:= l_custom_sql||
					' ) sumry '||l_pipe_denorm||' where
					1=1 '||l_pipe_product_where_clause||
                    ' GROUP BY  sortorder,salesrep_id,sales_group_id,'||l_prodcat_flag||' parent_sales_group_id
                    ) group by sortorder, salesrep_id,sales_group_id, parent_sales_group_id
                    )

                    tmp1  '||
					',jtf_rs_groups_tl grptl '||
					',jtf_rs_resource_extns_tl restl '||
					' WHERE tmp1.parent_sales_group_id = :l_sg_id_num '||
					   ' AND grptl.group_id = tmp1.sales_group_id '||
		                           ' AND grptl.language = USERENV(''LANG'') '||
					   ' AND restl.language(+) = USERENV(''LANG'') '||
	              			   ' AND restl.resource_id(+) = tmp1.salesrep_id ';
			  ELSE

  				   l_custom_sql:='SELECT '||
				   				' restl.resource_name VIEWBY '||
				   				',tmp1.salesrep_id||''.''||tmp1.sales_group_id VIEWBYID '||
				   				', SORTORDER '||
                                                                ',BIL_MEASURE28
                                , BIL_MEASURE2, BIL_MEASURE4, BIL_MEASURE5, BIL_MEASURE7,
                                BIL_MEASURE8, BIL_MEASURE10, BIL_MEASURE11,
                                NULL IL_URL1,
                                DECODE(tmp1.salesrep_id, NULL, NULL,'''||l_drill_str||''') BIL_URL2 FROM (
                                SELECT /*+ NO_MERGE */ salesrep_id, sales_group_id,
                                sortorder, parent_sales_group_id
                                ,SUM(frcst) BIL_MEASURE28 '||
								',SUM(priorFrcst) BIL_MEASURE2 '||
								',SUM(wtdPipeline) BIL_MEASURE4 '||
								',SUM(priorWtdPipeline) BIL_MEASURE5 '||
								',SUM(pipeline) BIL_MEASURE7 '||
								',SUM(priorPipeline) BIL_MEASURE8 '||
								',SUM(won) BIL_MEASURE10 '||
								',SUM(priorWon) BIL_MEASURE11 '||
								', NULL BIL_URL1 '||
								', NULL BIL_URL2 '||
								' FROM  '||
								'( '||
								 'SELECT /*+ LEADING(cal) */ '||
								  ' '||l_prodcat_flag||'
                                  1 sortorder, '||
				 			  	  'sumry.salesrep_id, '||
				 			  	  'sumry.sales_group_id, '||
								  'sumry.parent_sales_group_id parent_sales_group_id, '||
								  l_sql_stmnt1_1||
								 ' FROM '||l_fii_struct||' cal, '||l_sumry||' sumry '||
								 l_denorm1||
								 l_where_clause1||
								 ' AND sumry.parent_sales_group_id = :l_sg_id_num  '||
								 ' AND cal.xtd_flag = :l_yes '||
								 ' '||l_product_where_clause2||' '||
					       ' GROUP BY '||
					         ' sumry.salesrep_id,sumry.sales_group_id,'||
						       l_prodcat_flag||' sumry.parent_sales_group_id  '||
								 ' UNION ALL '||
								 ' select  '||l_prodcat_flag||' sortorder, salesrep_id,
                                    sales_group_id, parent_sales_group_id,
                                    sum(frcst) frcst, sum(priorFrcst) priorFrcst,
                                    sum(wtdPipeline) wtdPipeline,
                                    sum(priorWtdPipeline) priorWtdPipeline,
                                    sum(pipeline) pipeline,
                                    sum(priorPipeline) priorPipeline, sum(won) won,
                                    sum(priorWon) priorWon from (
                                SELECT /*+ LEADING(cal) */ '||
								  ' '||l_prodcat_flag||'
                                  1 sortorder, '||
				 			  	  'sumry.salesrep_id, '||
				 			  	  'sumry.sales_group_id, '||
								  'sumry.parent_sales_group_id parent_sales_group_id, '||
								  l_sql_stmnt2_1||
								  ' FROM '||l_fii_struct||' cal, '||l_sumry1||' sumry '||
								  l_where_clause2||
								  ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
								  ' AND cal.xtd_flag = :l_yes '||
							    ' GROUP BY '||
					         ' sumry.salesrep_id,sumry.sales_group_id,'||
						       ' '||l_prodcat_flag||' sumry.parent_sales_group_id ';

				   	   l_custom_sql:= l_custom_sql||
								  ' UNION ALL '||
								  ' SELECT  '||l_prodcat_flag||'
                                  1 sortorder, '||
				 			  	  'sumry.salesrep_id, '||
				 			  	  'sumry.sales_group_id, '||
								  'sumry.parent_sales_group_id parent_sales_group_id, '||
								  l_sql_stmnt3_1||
								  ' FROM '||l_sumry2||' sumry '||
								  l_where_clause3||
								  ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
					       ' GROUP BY '||
					         ' sumry.salesrep_id,sumry.sales_group_id,'||
						       ' '||l_prodcat_flag||' sumry.parent_sales_group_id';

				   l_custom_sql:= l_custom_sql||
						' ) sumry '||l_pipe_denorm||' where
					1=1 '||l_pipe_product_where_clause||
                    ' GROUP BY  sortorder,salesrep_id,sales_group_id,'||l_prodcat_flag||'parent_sales_group_id
                    ) group by sortorder, salesrep_id,sales_group_id, parent_sales_group_id
                    ) tmp1   '||
						',jtf_rs_resource_extns_tl restl '||
						' WHERE tmp1.parent_sales_group_id = :l_sg_id_num '||
						  ' AND restl.language = USERENV(''LANG'') '||
						  ' AND restl.resource_id = tmp1.salesrep_id '||
						  ' AND tmp1.salesrep_id = :l_resource_id';
			  END IF;


    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		      MODULE => g_pkg || l_proc,
		      MESSAGE => 'before exec imm');

    END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


IF l_resource_id IS NULL THEN
	 IF l_prodcat_id = 'All' THEN
            IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		USING l_curr_page_time_id,l_curr_as_of_date, l_prev_page_time_id,l_prev_date,
		 l_bitand_id,l_bitand_id,l_period_type, l_fst_crdt_type,l_fst_crdt_type,
		 l_curr_as_of_date,l_prev_date, l_curr_page_time_id,l_prev_page_time_id, l_sg_id_num,l_yes,
		 l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date,
		 l_sg_id_num,l_yes,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
		 l_sg_id_num,
		 l_sg_id_num;
		COMMIT;
             ELSE
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		USING l_curr_page_time_id,l_curr_as_of_date, l_prev_page_time_id,l_prev_date,
		 l_bitand_id,l_bitand_id,l_period_type, l_fst_crdt_type,l_fst_crdt_type,
		 l_curr_as_of_date,l_prev_date, l_curr_page_time_id,l_prev_page_time_id, l_sg_id_num,l_yes,
		 l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date,
		 l_sg_id_num,l_yes,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
		 l_sg_id_num,
		 l_sg_id_num;
		COMMIT;
             END IF;
	ELSE

          IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
             EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	     USING l_curr_page_time_id,l_curr_as_of_date,
	     l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type,
             l_fst_crdt_type,l_fst_crdt_type, l_curr_as_of_date,l_prev_date, l_curr_page_time_id,l_prev_page_time_id,
             l_sg_id_num, l_yes, l_prodcat_id, l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
             l_curr_as_of_date,l_prev_date, l_sg_id_num, l_yes,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
	     l_sg_id_num, l_prodcat_id, l_sg_id_num;
           ELSE
             EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	     USING l_curr_page_time_id,l_curr_as_of_date,
	     l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type,
             l_fst_crdt_type,l_fst_crdt_type, l_curr_as_of_date,l_prev_date, l_curr_page_time_id,l_prev_page_time_id,
             l_sg_id_num, l_yes, l_prodcat_id, l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
             l_curr_as_of_date,l_prev_date, l_sg_id_num, l_yes,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
	     l_sg_id_num, l_prodcat_id, l_sg_id_num;
           END IF;
        END IF;
ELSE
	IF l_prodcat_id = 'All' THEN

        IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	   USING l_curr_page_time_id,l_curr_as_of_date,
	    l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type, l_fst_crdt_type,l_fst_crdt_type,
	    l_curr_as_of_date,l_prev_date, l_curr_page_time_id,l_prev_page_time_id, l_sg_id_num,l_yes,
            l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date,
            l_sg_id_num,l_yes,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
	    l_sg_id_num, l_sg_id_num,l_resource_id;
          ELSE
	  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	   USING l_curr_page_time_id,l_curr_as_of_date,
	    l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type, l_fst_crdt_type,l_fst_crdt_type,
	    l_curr_as_of_date,l_prev_date, l_curr_page_time_id,l_prev_page_time_id, l_sg_id_num,l_yes,
            l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date,
            l_sg_id_num,l_yes,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
	    l_sg_id_num, l_sg_id_num,l_resource_id;
          END IF;
      ELSE
        IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	   EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	      USING l_curr_page_time_id,l_curr_as_of_date,
	       l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type,
               l_fst_crdt_type,l_fst_crdt_type,l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id,
               l_sg_id_num,l_yes,l_prodcat_id, l_curr_as_of_date, l_prev_date,
               l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date, l_sg_id_num,l_yes,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
               l_sg_id_num,l_prodcat_id, l_sg_id_num,l_resource_id;
           ELSE
	   EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	      USING l_curr_page_time_id,l_curr_as_of_date,
	       l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type,
               l_fst_crdt_type,l_fst_crdt_type,l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id,
               l_sg_id_num,l_yes,l_prodcat_id, l_curr_as_of_date, l_prev_date,
               l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date, l_sg_id_num,l_yes,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
               l_sg_id_num,l_prodcat_id, l_sg_id_num,l_resource_id;
           END IF;
        END IF;
END IF;

			  x_custom_sql := 'SELECT * FROM ('||
			  			l_outer_select||' FROM BIL_BI_RPT_TMP1 '||
		  					' ORDER BY SORTORDER, UPPER(VIEWBY)'||
							') '||
							' WHERE '||l_null_removal_clause;
			WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
			       IF l_parent_sales_group_id IS NULL THEN
                                   IF l_resource_id IS NULL THEN
                                      l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id IS NULL ';
                                   ELSE
                                      l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id = sumry.sales_group_id ';
                                   END IF;
              	               ELSE
			  		IF l_resource_id IS NULL THEN
				   	   l_parent_sls_grp_where_clause :=
					   		' AND sumry.parent_sales_group_id = :l_parent_sales_group_id ';
			    		ELSE
				   	   l_parent_sls_grp_where_clause :=
					   		' AND sumry.parent_sales_group_id = :l_sg_id_num ';
					END IF;
			       END IF;
				l_cat_url := 'pFunctionName=BIL_BI_FSTOVER_R&pParamIds=Y&VIEW_BY='||l_viewby||
							 '&VIEW_BY_NAME=VIEW_BY_ID';
				l_pc_select := ' SELECT
              decode(tmp1.viewbyid, -1,:l_unassigned_value,
                                               mtl.DESCRIPTION || '' ('' || mtl.CATEGORY_CONCAT_SEGS ||'')'') VIEWBY,
		   				sortorder,
                        frcst ,
		   				priorFrcst,
		   				wtdPipeline,
		   				priorWtdPipeline ,
		   				pipeline,
		   				priorPipeline,
		   				won ,
		   				priorWon,
		   				VIEWBYID,
                        salesrep_id,
		   				BIL_URL1,
                          DECODE(tmp1.viewbyid,''-1'',NULL,'''||l_cat_url||''') BIL_URL2 '||
               ' FROM (
                SELECT
		  				1 SORTORDER,
		   				NULL frcst ,
		   				NULL priorFrcst,
		   				SUM(wtdPipeline) wtdPipeline,
		   				SUM(priorWtdPipeline)  priorWtdPipeline,
		   				SUM(pipeline) pipeline,
		   				SUM(priorPipeline) priorPipeline,
		   				SUM(won) won ,
		   				SUM(priorWon) priorWon,
                        pcd.parent_id VIEWBYID,
                        salesrep_id,
		   				NULL BIL_URL1
						';

                l_unassigned_value := BIL_BI_UTIL_PKG.GET_UNASSIGNED_PC;

				l_sumry := 'BIL_BI_FST_PG_MV';
			    	l_sumry1 := 'BIL_BI_OPTY_PG_MV';
--			    	l_sumry2 := 'BIL_BI_PIPE_G_MV';
			    	l_sumry2 := l_open_mv_new;
				l_where_clause3 := l_where_clause3||' AND sumry.grp_total_flag = 0 ';
				l_denorm := ' ,ENI_ITEM_PROD_CAT_LOOKUP_V pcd ';
				IF l_prodcat_id = 'All' THEN
				   l_product_where_clause1 := ' pcd.top_node_flag = :l_yes '||
						' AND pcd.parent_id = sumry.product_category_id '||
						' AND pcd.child_id = sumry.product_category_id '||
						' AND sumry.product_category_id = pcd.id ';
				ELSE
				   l_product_where_clause1 :=  '  sumry.product_category_id = pcd.child_id AND '||
				   			  '	pcd.parent_id=:l_prodcat_id AND pcd.child_id = pcd.id AND '||
							  ' NOT((assign_to_cat = 0 AND pcd.child_id = pcd.parent_id)) ' ;

				END IF;
				IF l_prodcat_id = 'All' THEN
					l_custom_sql := ' SELECT VIEWBY '||
					   			', VIEWBYID '||
					   			', SORTORDER '||
								',SUM(frcst) BIL_MEASURE28 '||
								',SUM(priorFrcst) BIL_MEASURE2 '||
								',SUM(wtdPipeline) BIL_MEASURE4 '||
								',SUM(priorWtdPipeline) BIL_MEASURE5 '||
								',SUM(pipeline) BIL_MEASURE7 '||
								',SUM(priorPipeline) BIL_MEASURE8 '||
								',SUM(won) BIL_MEASURE10 '||
								',SUM(priorWon) BIL_MEASURE11 '||
								','''||l_drill_str||''' BIL_URL1 '||
								',BIL_URL2 '||
							' FROM  '||
							'( '||
							' SELECT /*+ LEADING(cal) */ '||
							    	' pcd.value VIEWBY'||
								', 1 sortorder, '||
								  l_sql_stmnt4||
								',pcd.id VIEWBYID'||
								',sumry.salesrep_id salesrep_id '||
								',NULL BIL_URL1'||
								',DECODE(pcd.id,''-1'',NULL,'''||l_cat_url||''') BIL_URL2 '||
							' FROM '||l_fii_struct||' cal,'||
							        l_sumry||' sumry '||
								l_denorm||' '||
							' '||l_where_clause1||' AND '||l_product_where_clause1||
							' AND sumry.sales_group_id = :l_sg_id_num '||
  							l_parent_sls_grp_where_clause||
							' AND cal.xtd_flag = :l_yes ';

					IF l_resource_id IS  NULL THEN
					   l_custom_sql :=l_custom_sql ||
							' AND sumry.salesrep_id IS NULL ';
                                 	ELSE
						l_custom_sql :=l_custom_sql ||
							' AND sumry.salesrep_id = :l_resource_id ';
					END IF;
					l_custom_sql := l_custom_sql ||
							' UNION ALL '||
							l_pc_select ||
							' FROM ('||
							' SELECT /*+ LEADING(cal) */'||
								' NULL VIEWBY'||
								', 1 sortorder, '||l_sql_stmnt2||
								',NULL VIEWBYID'||
								',sumry.salesrep_id salesrep_id '||
								',NULL BIL_URL1'||
								',sumry.product_category_id product_category_id'||
							' FROM '||l_fii_struct||' cal,'||
							      l_sumry1||' sumry '||
							l_where_clause2||' '||
							' AND sumry.sales_group_id = :l_sg_id_num '||
							l_parent_sls_grp_where_clause||
							' AND cal.xtd_flag = :l_yes ';
					IF l_resource_id IS NULL THEN
					   l_custom_sql :=l_custom_sql ||
						' AND sumry.salesrep_id IS NULL ';
					ELSE
					   l_custom_sql :=l_custom_sql ||
						' AND sumry.salesrep_id = :l_resource_id ';
					END IF;

					   l_custom_sql := l_custom_sql||
						' UNION ALL '||
						' SELECT NULL VIEWBY'||
							', 1 sortorder, '||l_sql_stmnt3||
							',NULL VIEWBYID'||
							',sumry.salesrep_id salesrep_id '||
							',NULL BIL_URL1'||
							',sumry.product_category_id product_category_id'||
						' FROM '||l_sumry2||' sumry '||
						' '||l_where_clause3||' '||
						' AND sumry.sales_group_id = :l_sg_id_num '||
						l_parent_sls_grp_where_clause;
					     IF l_resource_id IS  NULL THEN
					        l_custom_sql :=l_custom_sql ||
					       			' AND sumry.salesrep_id IS NULL ';
					     ELSE
					        l_custom_sql :=l_custom_sql ||
								' AND sumry.salesrep_id = :l_resource_id ';
					     END IF;

        /*         l_pipe_product_where_clause := ' AND sumry.product_category_id =pcd.child_id
                                             AND pcd.object_type = ''CATEGORY_SET''
                                             AND pcd.object_id = d.category_set_id
                                             AND d.functional_area_id = 11
                                             AND pcd.dbi_flag = ''Y''
                                             AND pcd.top_node_flag = :l_yes ';
                 l_pipe_denorm := ',eni_denorm_hierarchies pcd, mtl_default_category_sets d ';
*/

					 l_custom_sql := l_custom_sql||
							' ) sumry '||l_pipe_denorm||
							' WHERE 1=1 '||l_pipe_product_where_clause||
							' GROUP BY pcd.parent_id, salesrep_id)tmp1 , mtl_categories_v mtl '||
				      ' WHERE mtl.category_id (+) = tmp1.viewbyid)' ||
							' GROUP BY VIEWBY, VIEWBYID, SORTORDER,BIL_URL2 ';


    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		      MODULE => g_pkg || l_proc || 'Prod cat Viewby ',
		      MESSAGE => 'l_custom_sql length '||LENGTH(l_custom_sql));

    END IF;



                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;



   IF l_parent_sales_group_id IS NULL THEN
    IF l_resource_id IS NULL THEN
        IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	  USING l_curr_page_time_id,l_curr_as_of_date,
	    l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type,
            l_fst_crdt_type,l_fst_crdt_type, l_curr_as_of_date,l_prev_date,
            l_curr_page_time_id,l_prev_page_time_id, l_yes,l_sg_id_num, l_yes, l_unassigned_value,
            l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
            l_curr_as_of_date,l_prev_date, l_sg_id_num, l_yes,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
	     l_sg_id_num, l_yes; --pc where clause
           COMMIT;
        ELSE
	  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	  USING l_curr_page_time_id,l_curr_as_of_date,
	    l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type,
            l_fst_crdt_type,l_fst_crdt_type, l_curr_as_of_date,l_prev_date,
            l_curr_page_time_id,l_prev_page_time_id, l_yes,l_sg_id_num, l_yes, l_unassigned_value,
            l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
            l_curr_as_of_date,l_prev_date, l_sg_id_num, l_yes,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
	     l_sg_id_num, l_yes; --pc where clause
           COMMIT;
         END IF;
     ELSE
        IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
             EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	     USING l_curr_page_time_id,l_curr_as_of_date,
	     l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type,
             l_fst_crdt_type,l_fst_crdt_type,
             l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id,
	     l_yes,l_sg_id_num,l_yes,l_resource_id, l_unassigned_value,
             l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
             l_curr_as_of_date,l_prev_date, l_sg_id_num,l_yes,l_resource_id,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
             l_sg_id_num,l_resource_id, l_yes; --pc where clause;
         ELSE
             EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	     USING l_curr_page_time_id,l_curr_as_of_date,
	     l_prev_page_time_id,l_prev_date, l_bitand_id,l_bitand_id,l_period_type,
             l_fst_crdt_type,l_fst_crdt_type,
             l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id,
	     l_yes,l_sg_id_num,l_yes,l_resource_id, l_unassigned_value,
             l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
             l_curr_as_of_date,l_prev_date, l_sg_id_num,l_yes,l_resource_id,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
             l_sg_id_num,l_resource_id, l_yes; --pc where clause;
         END IF;
    END IF;
 ELSE -- parent sales group id is not null
    IF l_resource_id IS NULL THEN
        IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	 EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	 USING l_curr_page_time_id,l_curr_as_of_date, l_prev_page_time_id,l_prev_date,
         l_bitand_id,l_bitand_id,l_period_type, l_fst_crdt_type,l_fst_crdt_type,
         l_curr_as_of_date,l_prev_date, l_curr_page_time_id,l_prev_page_time_id,
         l_yes,l_sg_id_num, l_parent_sales_group_id, l_yes, l_unassigned_value,
         l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
         l_curr_as_of_date,l_prev_date, l_sg_id_num, l_parent_sales_group_id, l_yes,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
          l_sg_id_num, l_parent_sales_group_id, l_yes; --pc where clause
        ELSE
	 EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	 USING l_curr_page_time_id,l_curr_as_of_date, l_prev_page_time_id,l_prev_date,
         l_bitand_id,l_bitand_id,l_period_type, l_fst_crdt_type,l_fst_crdt_type,
         l_curr_as_of_date,l_prev_date, l_curr_page_time_id,l_prev_page_time_id,
         l_yes,l_sg_id_num, l_parent_sales_group_id, l_yes, l_unassigned_value,
         l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
         l_curr_as_of_date,l_prev_date, l_sg_id_num, l_parent_sales_group_id, l_yes,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
          l_sg_id_num, l_parent_sales_group_id, l_yes; --pc where clause
        END IF;
    ELSE
        IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	   EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	   USING l_curr_page_time_id,l_curr_as_of_date, l_prev_page_time_id,l_prev_date,
           l_bitand_id,l_bitand_id,l_period_type, l_fst_crdt_type,l_fst_crdt_type,
           l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id, l_yes,l_sg_id_num,
           l_sg_id_num, l_yes,l_resource_id, l_unassigned_value, l_curr_as_of_date, l_prev_date,
           l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date, l_sg_id_num, l_sg_id_num,
           l_yes,l_resource_id,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
	   l_sg_id_num, l_sg_id_num, l_resource_id, l_yes; --pc where clause;
         ELSE
	   EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	   USING l_curr_page_time_id,l_curr_as_of_date, l_prev_page_time_id,l_prev_date,
           l_bitand_id,l_bitand_id,l_period_type, l_fst_crdt_type,l_fst_crdt_type,
           l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id, l_yes,l_sg_id_num,
           l_sg_id_num, l_yes,l_resource_id, l_unassigned_value, l_curr_as_of_date, l_prev_date,
           l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date, l_sg_id_num, l_sg_id_num,
           l_yes,l_resource_id,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
	   l_sg_id_num, l_sg_id_num, l_resource_id, l_yes; --pc where clause;
         END IF;
    END IF;
  END IF;

					x_custom_sql := 'SELECT * FROM ('||
			  					l_outer_select||' FROM BIL_BI_RPT_TMP1 '||
								' ORDER BY SORTORDER, UPPER(VIEWBY) '||
								') '||
								' WHERE '||l_null_removal_clause;
				ELSE -- product cat not all
				   l_custom_sql := ' SELECT VIEWBY '||
							', VIEWBYID '||
					   		', SORTORDER '||
							',SUM(frcst) BIL_MEASURE28 '||
							',SUM(priorFrcst) BIL_MEASURE2 '||
							',SUM(wtdPipeline) BIL_MEASURE4 '||
							',SUM(priorWtdPipeline) BIL_MEASURE5 '||
							',SUM(pipeline) BIL_MEASURE7 '||
							',SUM(priorPipeline) BIL_MEASURE8 '||
							',SUM(won) BIL_MEASURE10 '||
							',SUM(priorWon) BIL_MEASURE11 '||
							',DECODE(VIEWBY,'||':l_cat_assign'||',NULL,'''||l_drill_str||''') BIL_URL1 '||
							',BIL_URL2 '||
							' FROM  '||
							'( '||
							' SELECT /*+ LEADING(cal) */ '||
							    ' decode(pcd.parent_id,pcd.child_id,'||
								' decode(sumry.assign_to_cat,0,pcd.value,:l_cat_assign), '||
								' pcd.value) VIEWBY '||
							     ', decode(pcd.parent_id,pcd.id, 1, 2) sortorder, '||
							        l_sql_stmnt4||
							     ',pcd.id VIEWBYID'||
							     ',SUMRY.salesrep_id salesrep_id '||
							     ',NULL BIL_URL1'||
							     ', decode(pcd.parent_id, pcd.child_id, null, '||
							     ' '''||l_cat_url||''') BIL_URL2 '||
							' FROM '||l_fii_struct||' cal, '||
							        l_sumry||' sumry '||
							        l_denorm||' '||
							' '||l_where_clause1||' AND '||l_product_where_clause1||
							  ' AND sumry.sales_group_id = :l_sg_id_num '||
							  l_parent_sls_grp_where_clause||
							  ' AND cal.xtd_flag = :l_yes ';
							 IF l_resource_id IS NULL THEN
							    l_custom_sql :=l_custom_sql ||
								' AND sumry.salesrep_id IS NULL ';
					                 ELSE
							    l_custom_sql :=l_custom_sql ||
								' AND sumry.salesrep_id = :l_resource_id ';
							 END IF;
				l_custom_sql := l_custom_sql ||
							' )tmp1'||
							' GROUP BY VIEWBY, VIEWBYID, SORTORDER,BIL_URL2 ';


    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		      MODULE => g_pkg || 'Prod cat Viewby ',
		      MESSAGE => ' Forecast Query Product Cat not All ');

    END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


		IF l_parent_sales_group_id IS NULL THEN
				   IF l_resource_id IS NULL THEN
					EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
					  USING l_cat_assign, l_cat_assign,
				  		l_curr_page_time_id,l_curr_as_of_date,
						l_prev_page_time_id,l_prev_date,

						l_bitand_id,l_bitand_id,l_period_type,
						l_fst_crdt_type,l_fst_crdt_type,
						l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id,
						l_prodcat_id,
						l_sg_id_num, l_yes;
				    ELSE
					EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
					  USING l_cat_assign, l_cat_assign,
				  		l_curr_page_time_id,l_curr_as_of_date,
						l_prev_page_time_id,l_prev_date,

						l_bitand_id,l_bitand_id,l_period_type,
						l_fst_crdt_type,l_fst_crdt_type,
						l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id,
						l_prodcat_id,
						l_sg_id_num,l_yes,l_resource_id;

				   END IF;
				ELSE-- parent sales group is not null
				   IF l_resource_id IS NULL THEN
					EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
					  USING l_cat_assign, l_cat_assign,
				  		l_curr_page_time_id,l_curr_as_of_date,
						l_prev_page_time_id,l_prev_date,
						l_bitand_id,l_bitand_id,l_period_type,
						l_fst_crdt_type,l_fst_crdt_type,
						l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id,
						l_prodcat_id,
						l_sg_id_num,
						l_parent_sales_group_id,
						l_yes;
				   ELSE
					EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
					  USING l_cat_assign, l_cat_assign,
				  		l_curr_page_time_id,l_curr_as_of_date,
						l_prev_page_time_id,l_prev_date,
						l_bitand_id,l_bitand_id,l_period_type,
						l_fst_crdt_type,l_fst_crdt_type,
						l_curr_as_of_date,l_prev_date,l_curr_page_time_id,l_prev_page_time_id,
						l_prodcat_id,
						l_sg_id_num,
						l_sg_id_num,
						l_yes,l_resource_id;
				   END IF;
				END IF;
					-- for won, pipeline measures
				l_custom_sql :=
				    	' SELECT VIEWBY '||
						', VIEWBYID '||
						', SORTORDER '||
						',NULL BIL_MEASURE28 '||
						',NULL BIL_MEASURE2 '||
						',SUM(wtdPipeline) BIL_MEASURE4 '||
						',SUM(priorWtdPipeline) BIL_MEASURE5 '||
						',SUM(pipeline) BIL_MEASURE7 '||
						',SUM(priorPipeline) BIL_MEASURE8 '||
						',SUM(won) BIL_MEASURE10 '||
						',SUM(priorWon) BIL_MEASURE11 '||
						',DECODE(VIEWBY,'||':l_cat_assign'||',NULL,'''||l_drill_str||''') BIL_URL1 '||
						',BIL_URL2 '||
					' FROM  '||
					'( '||
					' SELECT /*+ LEADING(cal) */ '||
						' decode(pcd.parent_id,pcd.id, '||
							' decode(sumry.item_id,''-1'',:l_cat_assign,pcd.value),pcd.value) '||
						' VIEWBY'||
						', decode(pcd.parent_id,pcd.id,'||
								'decode(sumry.item_id,''-1'', 1, 2),2) sortorder, '||
						l_sql_stmnt2||
						',pcd.id VIEWBYID'||
						',NULL BIL_URL1'||
						',decode(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL2'||
					' FROM '||l_fii_struct||' cal,'||
					      l_sumry1||' sumry'||
					      l_pipe_denorm||' '||
					' '||l_where_clause2||' '||
					   l_pipe_product_where_clause||
					  ' AND sumry.sales_group_id = :l_sg_id_num '||
					  l_parent_sls_grp_where_clause||
					  ' AND cal.xtd_flag = :l_yes ';

				      IF l_resource_id IS  NULL THEN
				        l_custom_sql :=l_custom_sql ||
				  			' AND sumry.salesrep_id IS NULL ';
				      ELSE
				        l_custom_sql :=l_custom_sql ||
							' AND sumry.salesrep_id = :l_resource_id ';
				      END IF;
					 l_custom_sql := l_custom_sql||
					 ' UNION ALL '||
					' SELECT DECODE(pcd.parent_id, pcd.id,
					decode(sumry.item_id, ''-1'', :l_cat_assign, pcd.value), pcd.value) VIEWBY
                                        ,DECODE(pcd.parent_id, pcd.id,
					decode(sumry.item_id, ''-1'', 1, 2), 2) SORTORDER, '||
                                      	l_sql_stmnt3||
					',pcd.id VIEWBYID'||
					',NULL BIL_URL1'||
					',decode(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL2'||
					' FROM '||l_sumry2||' sumry'||
						l_pipe_denorm||' '||
					' '||l_where_clause3||' '||
					l_pipe_product_where_clause||
					' AND sumry.sales_group_id = :l_sg_id_num '||
					l_parent_sls_grp_where_clause;
				     	IF l_resource_id IS  NULL THEN
						l_custom_sql :=l_custom_sql ||
							' AND sumry.salesrep_id IS NULL ';
				     	ELSE
				        	l_custom_sql :=l_custom_sql ||
							' AND sumry.salesrep_id = :l_resource_id ';
				     	END IF;

				      l_custom_sql := l_custom_sql||
						' )tmp1'||
						' GROUP BY VIEWBY, VIEWBYID, SORTORDER,BIL_URL2 ';


    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		      MODULE => g_pkg || l_proc || 'Prod cat Viewby ',
		      MESSAGE => ' x_custom_sql length '||LENGTH(l_custom_sql));

    END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


IF l_parent_sales_group_id IS NULL THEN
   IF l_resource_id IS NULL THEN
      IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
         EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	 USING l_cat_assign, l_cat_assign, l_curr_as_of_date, l_prev_date,
          l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date, l_prodcat_id, l_sg_id_num,
          l_yes, l_cat_assign,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
	   l_prodcat_id, l_sg_id_num;
      ELSE
         EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	 USING l_cat_assign, l_cat_assign, l_curr_as_of_date, l_prev_date,
          l_record_type_id,l_record_type_id, l_curr_as_of_date,l_prev_date, l_prodcat_id, l_sg_id_num,
          l_yes, l_cat_assign,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
	   l_prodcat_id, l_sg_id_num;
      END IF;
   ELSE
      IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
           EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	   USING l_cat_assign, l_cat_assign, l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
                 l_curr_as_of_date,l_prev_date, l_prodcat_id, l_sg_id_num, l_yes, l_resource_id, l_cat_assign ,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
		  l_prodcat_id, l_sg_id_num, l_resource_id;
      ELSE
           EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	   USING l_cat_assign, l_cat_assign, l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
                 l_curr_as_of_date,l_prev_date, l_prodcat_id, l_sg_id_num, l_yes, l_resource_id, l_cat_assign ,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
		  l_prodcat_id, l_sg_id_num, l_resource_id;
      END IF;
    END IF;
ELSE -- parent sales group id not null
   IF l_resource_id IS NULL THEN
      IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
         EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	 USING l_cat_assign, l_cat_assign, l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
            l_curr_as_of_date,l_prev_date, l_prodcat_id, l_sg_id_num, l_parent_sales_group_id, l_yes, l_cat_assign,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
	    l_prodcat_id, l_sg_id_num, l_parent_sales_group_id;
      ELSE
         EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	 USING l_cat_assign, l_cat_assign, l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
            l_curr_as_of_date,l_prev_date, l_prodcat_id, l_sg_id_num, l_parent_sales_group_id, l_yes, l_cat_assign,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
	    l_prodcat_id, l_sg_id_num, l_parent_sales_group_id;
       END IF;
   ELSE
      IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	 EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	 USING l_cat_assign, l_cat_assign, l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
          l_curr_as_of_date,l_prev_date, l_prodcat_id, l_sg_id_num, l_sg_id_num, l_yes, l_resource_id, l_cat_assign ,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
	   l_prodcat_id, l_sg_id_num,  l_sg_id_num, l_resource_id;
       ELSE
	 EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	 USING l_cat_assign, l_cat_assign, l_curr_as_of_date, l_prev_date, l_record_type_id,l_record_type_id,
          l_curr_as_of_date,l_prev_date, l_prodcat_id, l_sg_id_num, l_sg_id_num, l_yes, l_resource_id, l_cat_assign ,
l_snapshot_date , l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date ,l_prev_snap_date,
	   l_prodcat_id, l_sg_id_num,  l_sg_id_num, l_resource_id;
       END IF;
   END IF;
END IF;
	  			       x_custom_sql := 'SELECT * FROM ('||
						l_outer_select||
						' FROM ( '||
						'SELECT VIEWBY, VIEWBYID, SORTORDER,SUM(BIL_MEASURE28) BIL_MEASURE28,'||
							' SUM(BIL_MEASURE2) BIL_MEASURE2,SUM(BIL_MEASURE4) BIL_MEASURE4, '||
							' SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE7) BIL_MEASURE7, '||
							' SUM(BIL_MEASURE8) BIL_MEASURE8,SUM(BIL_MEASURE10) BIL_MEASURE10,'||
							' SUM(BIL_MEASURE11) BIL_MEASURE11, BIL_URL1, BIL_URL2 '||
						' FROM BIL_BI_RPT_TMP1 '||
						' GROUP BY VIEWBY, VIEWBYID, SORTORDER, '||
							' BIL_URL1, BIL_URL2 '||
						') '||
						' ORDER BY SORTORDER, UPPER(VIEWBY) '||
						') WHERE '||l_null_removal_clause;
				END IF;
	        END CASE;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| 'Final Query =>',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;



               IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || 'Query Length=>',
		                 MESSAGE => length(x_custom_sql));

               END IF;


  	ELSE --no valid parameters

       		BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                    ,x_sqlstr    => x_custom_sql);
   END IF;

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
		                    MODULE => g_pkg || l_proc || 'proc_error',
		                    MESSAGE => fnd_message.get );

              END IF;
      RAISE;
END BIL_BI_FRCST_OVERVIEW;


/*******************************************************************************
 * Name    : Procedure BIL_BI_FRCST_PRODCAT
 * Author  : Vikas Chahal
 * Date    : Nov 22, 2004
 * Purpose : Forecast Overview By Product Category.
 *
 *           Copyright (c) 2004 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl     PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 ******************************************************************************/

PROCEDURE BIL_BI_FRCST_PRODCAT ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                ,x_custom_sql         OUT NOCOPY VARCHAR2
                                ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )

 IS

    l_period_type               VARCHAR2(50);
    l_sg_id                     VARCHAR2(50);
    l_conv_rate_selected        VARCHAR2(50);
    l_curr_page_time_id         NUMBER;
    l_prev_page_time_id         NUMBER;
    l_prior_prior_time_id       NUMBER;
    l_region_id                 VARCHAR2(50);
    l_comp_type                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_bitand_id                 VARCHAR2(50);
    l_calendar_id               VARCHAR2(50);
    l_curr_as_of_date           DATE;
    l_prev_date                 DATE;
    l_prior_prior_date          DATE;
    l_page_period_type          VARCHAR2(50);
    l_bis_sysdate               DATE;
    l_fii_struct                VARCHAR2(50);
    l_record_type_id            NUMBER;
    l_sql_error_msg             VARCHAR2(1000);
    l_sql_error_desc            VARCHAR2(1000);
    l_sg_id_num                 NUMBER;
    l_fst_crdt_type             VARCHAR2(50);
    l_sql_stmnt1              	VARCHAR2(32000);
    l_sql_stmnt3              	VARCHAR2(32000);

    l_custom_sql		VARCHAR2(32000);
    l_insert_stmnt		VARCHAR2(5000);
    l_outer_select		VARCHAR2(5000);
    l_where_clause1		VARCHAR2(5000);
    l_where_clause3		VARCHAR2(5000);
    l_prodcat_id                VARCHAR2(20);
    l_viewby                    VARCHAR2(200);
    l_resource_id		VARCHAR2(20);
    l_url_str          	   	VARCHAR2(1000);
    l_cat_assign                VARCHAR2(1000);
    l_denorm		 	VARCHAR2(50);
    l_cat_url			VARCHAR2(1000);
    l_sumry			VARCHAR2(50);
    l_sumry2			VARCHAR2(50);
    l_product_where_clause1	VARCHAR2(2000);
    l_yes			VARCHAR2(1);
    l_assign_cat		BOOLEAN;
    l_snap_date			DATE;
    l_proc                      VARCHAR2(100);
    l_null_removal_clause	VARCHAR2(1000);
    l_parent_sales_group_id	NUMBER;
    l_parent_sls_grp_where_clause	VARCHAR2(1000);
    l_pipe_product_where_clause	VARCHAR2(1000);
    l_pipe_denorm               VARCHAR2(100);

    l_pc_select			VARCHAR2(32000);
    l_unassigned_value  VARCHAR2(100);
    l_prodcat_flag      VARCHAR2(200);

    l_currency_suffix   VARCHAR2(5);
    l_pipe_url         	VARCHAR2(1000);

    l_lookup_type       VARCHAR2(30);
    l_lookup_code       VARCHAR2(30);
    l_lang              VARCHAR2(30);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

    l_prev_pipe_amt          VARCHAR2(300);
    l_prv_wt_pipe_amt          VARCHAR2(300);
    l_column_type        VARCHAR2(1000);
    l_snapshot_date          	    DATE;
    l_open_mv_new        VARCHAR2(1000);
    l_open_mv_new1        VARCHAR2(1000);
    l_prev_snap_date     DATE;
    l_pipe_select1           varchar2(4000);
    l_pipe_select2           varchar2(4000);
    l_pipe_select3           varchar2(4000);
    l_pipe_select4           varchar2(4000);
    l_inner_where_pipe       varchar2(4000);

  BEGIN

    g_pkg := 'bil.patch.115.sql.BIL_BI_FCST_MGMT_RPTS_PKG.';
    l_region_id := 'BIL_BI_FRCST_PRODCAT';
    l_parameter_valid := FALSE;
    l_yes := 'Y';
    l_proc := 'BIL_BI_FRCST_PRODCAT';
    g_sch_name := 'BIL';


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                 MODULE => g_pkg || l_proc || 'begin',
		                 MESSAGE => 'Start of Procedure '||l_proc);

   END IF;

    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

    l_lookup_type := 'BIL_BI_LOOKUPS';
    l_lookup_code := 'ASSIGN_CATEG';
    l_lang        :=  USERENV('LANG');

    SELECT Meaning INTO l_cat_assign
    FROM FND_LOOKUP_VALUES
    WHERE LOOKUP_TYPE = l_lookup_type
      AND LOOKUP_CODE = l_lookup_code
      AND LANGUAGE = l_lang;

    BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl  => p_page_parameter_tbl
                                    ,p_region_id 	  => l_region_id
                                    ,x_period_type 	  => l_period_type
                                    ,x_conv_rate_selected => l_conv_rate_selected
                                    ,x_sg_id 		  => l_sg_id
				    ,x_parent_sg_id	  => l_parent_sales_group_id
				    ,x_resource_id	  => l_resource_id
                                    ,x_prodcat_id 	  => l_prodcat_id
                                    ,x_curr_page_time_id  => l_curr_page_time_id
                                    ,x_prev_page_time_id  => l_prev_page_time_id
                                    ,x_comp_type 	  => l_comp_type
                                    ,x_parameter_valid 	  => l_parameter_valid
                                    ,x_as_of_date 	  => l_curr_as_of_date
                                    ,x_page_period_type   => l_page_period_type
                                    ,x_prior_as_of_date   => l_prev_date
                                    ,x_record_type_id 	  => l_record_type_id
                                    ,x_viewby             => l_viewby );


/*
   BIL_BI_UTIL_PKG.GET_LATEST_SNAP_DATE(p_page_parameter_tbl  => p_page_parameter_tbl
                                           ,p_as_of_date      => l_curr_as_of_date
                                           ,p_period_type     => NULL
                                           ,x_snapshot_date   => l_snap_date);
*/


/*** Query column mapping ******************************************************
Internal Name   Region Item Name	Grand Total
BIL_MEASURE1    Forecast		BIL_MEASURE15
BIL_MEASURE2    Prior Forecast		BIL_MEASURE16
BIL_MEASURE3    Change			BIL_MEASURE17
BIL_MEASURE4    Total Judgement		BIL_MEASURE18
BIL_MEASURE5    Change			BIL_MEASURE19
BIL_MEASURE6    Forecast Sub		BIL_MEASURE20
BIL_MEASURE7    Prior Forecast Sub	BIL_MEASURE21
BIL_MEASURE8    Change			BIL_MEASURE22
BIL_MEASURE9    Pipeline		BIL_MEASURE23
BIL_MEASURE10   Prior Pipeline		BIL_MEASURE24
BIL_MEASURE11   Change			BIL_MEASURE25
BIL_MEASURE12   Weighted Pipeline	BIL_MEASURE26
BIL_MEASURE13   Prior Weighted Pipeline	BIL_MEASURE27
BIL_MEASURE14   Change			BIL_MEASURE28
*******************************************************************************/


IF l_parameter_valid THEN

            l_viewby:='ITEM+ENI_ITEM_VBH_CAT';


            BIL_BI_UTIL_PKG.GET_PRIOR_PRIOR_TIME (p_comp_type           => l_comp_type,
                                                  p_period_type         => l_page_period_type,
                                                  p_prev_date           => l_prev_date,
                                                  p_prev_page_time_id   => l_prev_page_time_id,
                                                  x_prior_prior_date    => l_prior_prior_date,
                                                  x_prior_prior_time_id => l_prior_prior_time_id);


       IF l_prodcat_id IS NULL THEN
           l_prodcat_id := 'All';
       ELSE
	   l_prodcat_id := to_number(REPLACE(l_prodcat_id,'''',''));
       END IF;

       IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
       ELSE
            l_currency_suffix := '';
       END IF;

   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => 'l_parameter_valid = true');
   END IF;

       l_insert_stmnt  := 'INSERT INTO BIL_BI_RPT_TMP1 (VIEWBY, VIEWBYID, SORTORDER,BIL_MEASURE28,'||
			 	'BIL_MEASURE2,BIL_MEASURE3,BIL_MEASURE4,BIL_MEASURE5,'||
				'BIL_MEASURE6,BIL_MEASURE7,BIL_MEASURE8,BIL_MEASURE9,BIL_MEASURE10,BIL_MEASURE11,'||
                                'BIL_MEASURE12,BIL_URL1,BIL_URL2)';


         l_pipe_url:=BIL_BI_UTIL_PKG.GET_DRILL_LINKS(p_view_by      => l_viewby
                                                   ,p_salesgroup_id => l_sg_id
                                                   ,p_resource_id   => l_resource_id);

 l_url_str:='pFunctionName=BIL_BI_FSTOVER_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
 l_cat_url := 'pFunctionName=BIL_BI_FRCST_PRODCAT_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';

/* Get the Prefix for the Open amt based upon Period Type and Compare To Params */


l_prev_pipe_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'P',
                                     p_curr_suffix    => l_currency_suffix
				    );



l_prv_wt_pipe_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'W',
                                     p_curr_suffix    => l_currency_suffix
				    );


/* Use the  BIL_BI_UTIL_PKG.GET_PIPE_MV proc to get the MV name and snap date for Pipeline/Open Amts. */

      BIL_BI_UTIL_PKG.GET_PIPE_MV(
                                     p_asof_date  => l_curr_as_of_date ,
                                     p_period_type  => l_page_period_type ,
                                     p_compare_to  =>  l_comp_type  ,
                                     p_prev_date  => l_prev_date,
                                     p_page_parameter_tbl => p_page_parameter_tbl,
                                     x_pipe_mv    => l_open_mv_new ,
                                     x_snapshot_date => l_snapshot_date  ,
                                     x_prev_snap_date  => l_prev_snap_date
				    );



/*
BIL_MEASURE28    frcst
BIL_MEASURE2     priorfrcst
BIL_MEASURE3     priorpriorfrcst
BIL_MEASURE4     oppfcst
BIL_MEASURE5     prior_oppfrcst
BIL_MEASURE6     priorprior_oppfrcst
BIL_MEASURE7     frcst_sub
BIL_MEASURE8     priorfrcst_sub
BIL_MEASURE9     pipeline
BIL_MEASURE10    priorpipeline
BIL_MEASURE11    wtdpipeline
BIL_MEASURE12    priorwtdpipeline
BIL_MEASURE13    Total Judgement              SUM(BIL_MEASURE28) - SUM(BIL_MEASURE4)
BIL_MEASURE14    Prior Total Judgement        SUM(BIL_MEASURE2) -  SUM(BIL_MEASURE5)
BIL_MEASURE15    Prior Prior Total Judgement  SUM(BIL_MEASURE3) -  SUM(BIL_MEASURE6)
*/

l_outer_select := 'SELECT VIEWBY '||
',VIEWBYID '||
',BIL_MEASURE28                                                                        BIL_MEASURE1  '||
',BIL_MEASURE2                                                                         BIL_MEASURE23 '||
',BIL_MEASURE3                                                                         BIL_MEASURE24 '||
',(BIL_MEASURE28-BIL_MEASURE2)/ABS(DECODE(BIL_MEASURE2,0,null,BIL_MEASURE2))*100       BIL_MEASURE2  '||
',BIL_MEASURE4                                                                         BIL_MEASURE25 '||
',BIL_MEASURE5                                                                         BIL_MEASURE26 '||
',BIL_MEASURE6                                                                         BIL_MEASURE27 '||
',BIL_MEASURE13                                                                        BIL_MEASURE3  '||
',(BIL_MEASURE13-BIL_MEASURE14)/ABS(DECODE(BIL_MEASURE14,0,null,BIL_MEASURE14))*100    BIL_MEASURE4  '||
',BIL_MEASURE14                                                                        BIL_MEASURE5  '||
',(BIL_MEASURE14-BIL_MEASURE15)/ABS(DECODE(BIL_MEASURE15,0,null,BIL_MEASURE15))*100    BIL_MEASURE6  '||
',BIL_MEASURE7                                                                         BIL_MEASURE7  '||
',BIL_MEASURE8                                                                         BIL_MEASURE28 '||
',(BIL_MEASURE7-BIL_MEASURE8)/ABS(DECODE(BIL_MEASURE8, 0, null, BIL_MEASURE8))*100     BIL_MEASURE8  '||
',BIL_MEASURE9                                                                         BIL_MEASURE9  '||
',BIL_MEASURE10                                                                        BIL_MEASURE29 '||
',(BIL_MEASURE9-BIL_MEASURE10)/ABS(DECODE(BIL_MEASURE10, 0 ,null, BIL_MEASURE10))*100  BIL_MEASURE10 '||
',BIL_MEASURE11                                                                        BIL_MEASURE11 '||
',BIL_MEASURE12                                                                        BIL_MEASURE30 '||
',(BIL_MEASURE11-BIL_MEASURE12)/ABS(DECODE(BIL_MEASURE12, 0 ,null, BIL_MEASURE12))*100 BIL_MEASURE12 '||
',SUM(BIL_MEASURE28) OVER()                                                                   BIL_MEASURE13 '||
',SUM(BIL_MEASURE2)  OVER()                                                                   BIL_MEASURE32 '||
',(SUM(BIL_MEASURE28) OVER()-SUM(BIL_MEASURE2) OVER())/ABS(DECODE(SUM(BIL_MEASURE2) OVER(),0,null, '||
'SUM(BIL_MEASURE2) OVER()))*100                                                               BIL_MEASURE14 '||
',SUM(BIL_MEASURE13) OVER()                                                                   BIL_MEASURE15 '||
',(SUM(BIL_MEASURE13) OVER()-SUM(BIL_MEASURE14) OVER())/ABS(DECODE(SUM(BIL_MEASURE14) OVER(),0,null, '||
'SUM(BIL_MEASURE14) OVER()))*100                                                              BIL_MEASURE16 '||
',SUM(BIL_MEASURE7) OVER()                                                                    BIL_MEASURE17 '||
',(SUM(BIL_MEASURE7) OVER()-SUM(BIL_MEASURE8) OVER())/ABS(DECODE(SUM(BIL_MEASURE8) OVER(), 0, null,  '||
'SUM(BIL_MEASURE8) OVER()))*100                                                               BIL_MEASURE18 '||
',SUM(BIL_MEASURE9) OVER()                                                                    BIL_MEASURE19 '||
',(SUM(BIL_MEASURE9) OVER()-SUM(BIL_MEASURE10) OVER())/ABS(DECODE(SUM(BIL_MEASURE10) OVER(), 0 ,null, '||
'SUM(BIL_MEASURE10) OVER()))*100                                                              BIL_MEASURE20 '||
',SUM(BIL_MEASURE11) OVER()                                                                   BIL_MEASURE21 '||
',(SUM(BIL_MEASURE11) OVER()-SUM(BIL_MEASURE12) OVER())/ABS(DECODE(SUM(BIL_MEASURE12) OVER(), 0 ,null, '||
'SUM(BIL_MEASURE12) OVER()))*100                                                              BIL_MEASURE22 '||
', BIL_URL1 '||
',DECODE('''||l_curr_as_of_date||''',TRUNC(SYSDATE),'||
'DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=PIPELINE'''||')) BIL_URL2 ';


l_sql_stmnt1 := '(case when  sumry.effective_time_id = :l_curr_page_time_id AND '||
'cal.report_date =:l_curr_as_of_date '||
'then sumry.forecast_amt'||l_currency_suffix||' else NULL end)  AS frcst '||
',(case when  sumry.effective_time_id = :l_prev_page_time_id AND '||
'cal.report_date =:l_prev_date '||
'then sumry.forecast_amt'||l_currency_suffix||' else NULL end) AS priorFrcst '||
',(case when  sumry.effective_time_id = :l_prior_prior_time_id AND '||
'cal.report_date =:l_prior_prior_date '||
'then sumry.forecast_amt'||l_currency_suffix||' else NULL end) AS priorpriorFrcst '||
',(case when  sumry.effective_time_id = :l_curr_page_time_id AND '||
'cal.report_date =:l_curr_as_of_date '||
'then sumry.opp_forecast_amt'||l_currency_suffix||' else NULL end)  AS oppfrcst '||
',(case when  sumry.effective_time_id = :l_prev_page_time_id AND '||
'cal.report_date =:l_prev_date '||
'then sumry.opp_forecast_amt'||l_currency_suffix||' else NULL end) AS prior_oppFrcst '||
',(case when  sumry.effective_time_id = :l_prior_prior_time_id AND '||
'cal.report_date =:l_prior_prior_date '||
'then sumry.opp_forecast_amt'||l_currency_suffix||' else NULL end) AS priorprior_oppFrcst '||
',(case when  sumry.effective_time_id = :l_curr_page_time_id AND '||
'cal.report_date =:l_curr_as_of_date '||
'then sumry.forecast_amt_sub'||l_currency_suffix||' else NULL end)  AS frcst_sub '||
',(case when  sumry.effective_time_id = :l_prev_page_time_id AND '||
'cal.report_date =:l_prev_date '||
'then sumry.forecast_amt_sub'||l_currency_suffix||' else NULL end) As PriorFrcst_sub '||
',NULL AS pipeline '||
',NULL AS priorPipeline '||
',NULL AS wtdPipeline '||
',NULL AS priorWtdPipeline ';


l_where_clause1 := ' WHERE sumry.TXN_TIME_ID = cal.TIME_ID '||
'AND sumry.TXN_PERIOD_TYPE_ID = cal.PERIOD_TYPE_ID '||
'AND bitand(cal.record_type_id, :l_bitand_id)= :l_bitand_id '||
'AND sumry.EFFECTIVE_PERIOD_TYPE_ID = :l_period_type '||
'AND NVL(sumry.credit_type_id, :l_fst_crdt_type) = :l_fst_crdt_type  '||
'AND cal.report_date in (:l_curr_as_of_date, :l_prev_date, :l_prior_prior_date) '||
'AND sumry.effective_time_id in (:l_curr_page_time_id, :l_prev_page_time_id, :l_prior_prior_time_id) ';

/*
l_sql_stmnt3 :=' NULL AS frcst '||
',NULL AS priorFrcst '||
',NULL AS frcst_sub '||
',NULL AS PriorFrcst_sub '||
',(case when  :l_snap_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end) AS wtdPipeline '||
',(case when  :l_prev_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end)  AS priorWtdPipeline '||
',(case when  :l_snap_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end) AS pipeline '||
',(case when  :l_prev_date = sumry.snap_date then '||
'decode(:l_period_type, '||
'128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
'64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
'32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
'16,PIPELINE_AMT_WEEK'||l_currency_suffix||
')'||
'end) AS priorPipeline ';


l_where_clause3 := ' WHERE sumry.snap_date in (:l_snap_date, :l_prev_date) ' ;

*/

l_pipe_select1 := ' NULL AS frcst '||
                    ',NULL AS priorFrcst '||
                    ',NULL AS frcst_sub '||
                    ',NULL AS PriorFrcst_sub '||
                    ',(case when  :l_snapshot_date = sumry.snap_date then '||
                    'decode(:l_period_type, '||
                    '128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                    '64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                    '32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                    '16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
                    ')'||
                    'end) AS wtdPipeline ';

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN

       l_pipe_select2 := ',(case when  :l_prev_snap_date = sumry.snap_date then '||
                            'decode(:l_period_type, '||
                            '128,WTD_PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                            '64,WTD_PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                            '32,WTD_PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                            '16,WTD_PIPELINE_AMT_WEEK'||l_currency_suffix||
                            ')'||
                            'end)  AS priorWtdPipeline ';
ELSE
       l_pipe_select2 := ' ,(CASE WHEN sumry.snap_date = :l_snapshot_date THEN '||
                          ''||l_prv_wt_pipe_amt||' '||
                           ' ELSE NULL '||
                 ' END)  AS priorWtdPipeline ';
END IF;


l_pipe_select3 := ',(case when  :l_snapshot_date = sumry.snap_date then '||
                    'decode(:l_period_type, '||
                    '128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                    '64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                    '32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                    '16,PIPELINE_AMT_WEEK'||l_currency_suffix||
                    ')'||
                    'end) AS pipeline ';

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
       l_pipe_select4 := ',(case when  :l_prev_snap_date = sumry.snap_date then '||
                          'decode(:l_period_type, '||
                          '128,PIPELINE_AMT_YEAR'||l_currency_suffix||','||
                          '64,PIPELINE_AMT_QUARTER'||l_currency_suffix||','||
                          '32,PIPELINE_AMT_PERIOD'||l_currency_suffix||','||
                          '16,PIPELINE_AMT_WEEK'||l_currency_suffix||
                          ')'||
                          'end) AS priorPipeline ';
ELSE
       l_pipe_select4 := ' ,(CASE WHEN sumry.snap_date =:l_snapshot_date THEN '||
                          ''||l_prev_pipe_amt||' '||
                           ' ELSE NULL '||
                 ' END)  AS priorPipeline ';

END IF;


l_sql_stmnt3 := l_pipe_select1 || l_pipe_select2 || l_pipe_select3 || l_pipe_select4 ;


IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
    l_where_clause3 := ' WHERE sumry.snap_date in (:l_snapshot_date, :l_prev_snap_date) ' ;
ELSE
    l_where_clause3 := ' WHERE sumry.snap_date in (:l_snapshot_date ) ' ;
END IF;



                BIL_BI_UTIL_PKG.GET_FORECAST_PROFILES( x_fstcrdttype => l_fst_crdt_type );


        	BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id          =>l_bitand_id,
			                             x_calendar_id        =>l_calendar_id,
			                             x_curr_date          =>l_bis_sysdate,
			                             x_fii_struct         =>l_fii_struct);

        	l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));

		l_null_removal_clause := 'NOT(BIL_MEASURE1 IS NULL AND BIL_MEASURE25 IS NULL AND BIL_MEASURE3 IS NULL AND '||
						' BIL_MEASURE7 IS NULL AND BIL_MEASURE9 IS NULL AND'||
						' BIL_MEASURE11 IS NULL) ';

               execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';


   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

   		l_sql_error_desc :=
        		'l_viewby => '||l_viewby||', '||
        		'l_curr_page_time_id => '|| l_curr_page_time_id ||', ' ||
        		'l_prev_page_time_id => '|| l_prev_page_time_id ||', ' ||
                        'l_prior_prior_time_id => '|| l_prior_prior_time_id ||', ' ||
        		'l_curr_as_of_date => '|| l_curr_as_of_date ||', ' ||
        		'l_prev_date => '|| l_prev_date ||', ' ||
        		'l_prior_prior_date => '|| l_prior_prior_date ||', ' ||
        		'l_conv_rate_selected => '|| l_conv_rate_selected ||', ' ||
        		'l_bitand_id => '|| l_bitand_id ||', ' ||
        		'l_period_type => '|| l_period_type ||', ' ||
                        'l_parent_sales_group_id => '|| l_parent_sales_group_id ||', '||
        		'l_sg_id_num => '|| l_sg_id_num ||', ' ||
			'l_resource_id => '||l_resource_id||', '||
        		'l_fst_crdt_type => '|| l_fst_crdt_type ||', ' ||
        		'l_calendar_id => '|| l_calendar_id;


                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || 'l_sql_error_desc',
		                 MESSAGE => l_sql_error_desc);

   END IF;

		BIL_BI_UTIL_PKG.GET_PC_NOROLLUP_WHERE_CLAUSE(
                                          p_prodcat      => l_prodcat_id,
                                          p_viewby       => l_viewby,
                                          x_denorm       => l_pipe_denorm,
                                          x_where_clause => l_pipe_product_where_clause);

   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || ' l_viewby =>'||l_viewby,
		                 MESSAGE => ' Prod cat '||l_prodcat_id);

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || ' l_pipe_prod_where =>',
		                 MESSAGE => ' l_pipe_product_where_clause '||l_pipe_product_where_clause);
   END IF;

	         IF l_parent_sales_group_id IS NULL THEN
                    IF l_resource_id IS NULL THEN
                        l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id IS NULL ';
                    ELSE
                        l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id = sumry.sales_group_id ';
                    END IF;
              	 ELSE
		    IF l_resource_id IS NULL THEN
		        l_parent_sls_grp_where_clause :=
			' AND sumry.parent_sales_group_id = :l_parent_sales_group_id ';
		    ELSE
			l_parent_sls_grp_where_clause :=
			' AND sumry.parent_sales_group_id = :l_sg_id_num ';
		    END IF;
		 END IF;

	      l_pc_select := ' SELECT
                               decode(tmp1.viewbyid, -1,:l_unassigned_value,
                               mtl.DESCRIPTION || '' ('' || mtl.CATEGORY_CONCAT_SEGS ||'')'') VIEWBY,
		   	       sortorder,
                               frcst ,
		   	       priorFrcst,
                               priorpriorFrcst,
                               oppfrcst,
                               prior_oppfrcst,
                               priorprior_oppfrcst,
                               frcst_sub,
                               priorFrcst_sub,
		   	       pipeline,
		   	       priorPipeline,
		   	       wtdPipeline,
		   	       priorWtdPipeline ,
		   	       VIEWBYID,
                               salesrep_id,
                               DECODE(tmp1.viewbyid,''-1'',NULL,'''||l_cat_url||''') BIL_URL1,
                               BIL_URL2 '||
                             ' FROM (
                                   SELECT
		  		   1 SORTORDER,
		   		   NULL frcst ,
		   		   NULL priorFrcst,
                                   NULL priorpriorfrcst,
                                   NULL oppfrcst,
                                   NULL prior_oppfrcst,
                                   NULL priorprior_oppfrcst,
                                   NULL frcst_sub,
                                   NULL priorFrcst_sub,
		   		   SUM(pipeline) pipeline,
		   		   SUM(priorPipeline) priorPipeline,
		   		   SUM(wtdPipeline) wtdPipeline,
		   		   SUM(priorWtdPipeline) priorWtdPipeline ,
		                   pcd.parent_id VIEWBYID,
                                   salesrep_id,
		   		   BIL_URL2
				   ';

                l_unassigned_value := BIL_BI_UTIL_PKG.GET_UNASSIGNED_PC;

				l_sumry := 'BIL_BI_FST_PG_MV';
--			    	l_sumry2 := 'BIL_BI_PIPE_G_MV';
			    	l_sumry2 := l_open_mv_new;
				l_where_clause3 := l_where_clause3||' AND sumry.grp_total_flag = 0 ';
				l_denorm := ' ,ENI_ITEM_PROD_CAT_LOOKUP_V pcd ';

				IF l_prodcat_id = 'All' THEN
				   l_product_where_clause1 := ' pcd.top_node_flag = :l_yes '||
						' AND pcd.parent_id = sumry.product_category_id '||
						' AND pcd.child_id = sumry.product_category_id '||
						' AND sumry.product_category_id = pcd.id ';
				ELSE
				  l_product_where_clause1 :=  ' sumry.product_category_id = pcd.child_id AND '||
				   			       ' pcd.parent_id=:l_prodcat_id
                                   AND sumry.product_category_id = pcd.id AND '||
							       ' NOT((assign_to_cat = 0 AND pcd.child_id = pcd.parent_id)) ';

				END IF;

IF l_prodcat_id = 'All' THEN

      l_custom_sql :=
        ' SELECT   VIEWBY '||
               ',VIEWBYID '||
               ',SORTORDER '||
               ',SUM(frcst) BIL_MEASURE1 '||
               ',SUM(priorFrcst) BIL_MEASURE2 '||
               ',SUM(priorpriorFrcst) BIL_MEASURE3 '||
               ',SUM(oppFrcst) BIL_MEASURE4 '||
               ',SUM(prior_oppFrcst) BIL_MEASURE5 '||
               ',SUM(priorprior_oppFrcst) BIL_MEASURE6 '||
               ',SUM(frcst_sub) BIL_MEASURE7 '||
               ',SUM(priorFrcst_sub) BIL_MEASURE8 '||
               ',SUM(pipeline) BIL_MEASURE9 '||
               ',SUM(priorPipeline) BIL_MEASURE10 '||
               ',SUM(wtdPipeline) BIL_MEASURE11 '||
               ',SUM(priorWtdPipeline) BIL_MEASURE12 '||
               ',BIL_URL1 '||
               ','''||l_pipe_url||''' BIL_URL2 '||
      ' FROM  ( ' ||
	  ' SELECT /*+ LEADING(cal) */ '||
	           ' pcd.value VIEWBY '||
	           ', 1 sortorder, '||
	              l_sql_stmnt1||
	           ',pcd.id VIEWBYID '||
	           ',sumry.salesrep_id salesrep_id '||
	           ',DECODE(pcd.id,''-1'',NULL,'''||l_cat_url||''') BIL_URL1 '||
                   ',NULL BIL_URL2 '||
	  ' FROM '||l_fii_struct||' cal,'||
	            l_sumry||' sumry '||
		    l_denorm||' '||
          ' '||l_where_clause1||' AND '||
               l_product_where_clause1||
	  ' AND sumry.sales_group_id = :l_sg_id_num '||
	    l_parent_sls_grp_where_clause ||
          ' AND cal.xtd_flag = :l_yes ';

   IF l_resource_id IS  NULL THEN
      l_custom_sql :=l_custom_sql ||' AND sumry.salesrep_id IS NULL ';
   ELSE
      l_custom_sql :=l_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
   END IF;

   l_custom_sql := l_custom_sql||
                  ' UNION ALL '||
                   l_pc_select ||
	          ' FROM ('||
                  ' SELECT NULL VIEWBY'||
		  ', 1 sortorder, '||l_sql_stmnt3||
		  ',NULL VIEWBYID'||
		  ',sumry.salesrep_id salesrep_id '||
		  ',sumry.product_category_id product_category_id'||
                  ',NULL BIL_URL2 '||
		  ' FROM '||l_sumry2||' sumry '||
		  ' '||l_where_clause3||' '||
		  ' AND sumry.sales_group_id = :l_sg_id_num '||
		    l_parent_sls_grp_where_clause;


   IF l_resource_id IS  NULL THEN
      l_custom_sql :=l_custom_sql ||' AND sumry.salesrep_id IS NULL ';
   ELSE
      l_custom_sql :=l_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
   END IF;

   /*
    l_pipe_product_where_clause := ' AND sumry.product_category_id =pcd.child_id
                                             AND pcd.object_type = ''CATEGORY_SET''
                                             AND pcd.object_id = d.category_set_id
                                             AND d.functional_area_id = 11
                                             AND pcd.dbi_flag = ''Y''
                                             AND pcd.top_node_flag = :l_yes ';
    l_pipe_denorm := ',eni_denorm_hierarchies pcd, mtl_default_category_sets d ';
   */

   l_custom_sql := l_custom_sql||
                   ' ) sumry '||l_pipe_denorm||
		   ' WHERE 1=1 '||l_pipe_product_where_clause||
		   ' GROUP BY pcd.parent_id, salesrep_id)tmp1 , mtl_categories_v mtl '||
		   ' WHERE mtl.category_id (+) = tmp1.viewbyid)' ||
		   ' GROUP BY VIEWBY, VIEWBYID, SORTORDER ,BIL_URL1, BIL_URL2 ';


   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || 'Prod cat Viewby ',
		                 MESSAGE => ' l_custom_sql length '||LENGTH(l_custom_sql));

   END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;

				 IF l_parent_sales_group_id IS NULL THEN
        IF l_resource_id IS NULL THEN

           IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		       USING
                             l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date,
                             l_prior_prior_time_id, l_prior_prior_date, l_curr_page_time_id, l_curr_as_of_date,
			     l_prev_page_time_id, l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                             l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date,
                             l_bitand_id, l_bitand_id, l_period_type, l_fst_crdt_type, l_fst_crdt_type,
                             l_curr_as_of_date, l_prev_date, l_prior_prior_date, l_curr_page_time_id,
                             l_prev_page_time_id, l_prior_prior_time_id, l_yes, l_sg_id_num, l_yes,
                             l_unassigned_value,
			     l_snapshot_date, l_period_type,
                             l_snapshot_date,
			     l_snapshot_date, l_period_type,
			     l_snapshot_date,
                             l_snapshot_date,
			     l_sg_id_num, l_yes;
                          COMMIT;
           ELSE
                  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		       USING
                             l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date,
                             l_prior_prior_time_id, l_prior_prior_date, l_curr_page_time_id, l_curr_as_of_date,
			     l_prev_page_time_id, l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                             l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date,
                             l_bitand_id, l_bitand_id, l_period_type, l_fst_crdt_type, l_fst_crdt_type,
                             l_curr_as_of_date, l_prev_date, l_prior_prior_date, l_curr_page_time_id,
                             l_prev_page_time_id, l_prior_prior_time_id, l_yes, l_sg_id_num, l_yes,
                             l_unassigned_value,
			     l_snapshot_date, l_period_type,
                             l_prev_snap_date, l_period_type,
			     l_snapshot_date, l_period_type,
			     l_prev_snap_date, l_period_type,
                             l_snapshot_date, l_prev_snap_date,
			     l_sg_id_num, l_yes;
                          COMMIT;
            END IF;
	ELSE
              IF   ( l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
		  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		   USING l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date,
                         l_prior_prior_time_id, l_prior_prior_date, l_curr_page_time_id, l_curr_as_of_date,
                         l_prev_page_time_id, l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                         l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date, l_bitand_id,
                         l_bitand_id, l_period_type, l_fst_crdt_type, l_fst_crdt_type, l_curr_as_of_date,
                         l_prev_date, l_prior_prior_date, l_curr_page_time_id,
                         l_prev_page_time_id, l_prior_prior_time_id, l_yes, l_sg_id_num, l_yes, l_resource_id,
                         l_unassigned_value,
                         l_snapshot_date, l_period_type,
			 l_snapshot_date,
			 l_snapshot_date, l_period_type,
			 l_snapshot_date,
			 l_snapshot_date,
			 l_sg_id_num, l_resource_id, l_yes;
                ELSE
              	    EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		          USING l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date,
                         l_prior_prior_time_id, l_prior_prior_date, l_curr_page_time_id, l_curr_as_of_date,
                         l_prev_page_time_id, l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                         l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date, l_bitand_id,
                         l_bitand_id, l_period_type, l_fst_crdt_type, l_fst_crdt_type, l_curr_as_of_date,
                         l_prev_date, l_prior_prior_date, l_curr_page_time_id,
                         l_prev_page_time_id, l_prior_prior_time_id, l_yes, l_sg_id_num, l_yes, l_resource_id,
                         l_unassigned_value,
                         l_snapshot_date, l_period_type,
			 l_prev_snap_date, l_period_type,
			 l_snapshot_date, l_period_type,
			 l_prev_snap_date, l_period_type,
			 l_snapshot_date, l_prev_snap_date,
			 l_sg_id_num, l_resource_id, l_yes;
                END IF;
	END IF;
  ELSE -- parent sales group id is not null
	IF l_resource_id IS NULL THEN

              IF   ( l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                   EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	             USING l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id,
                         l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                         l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id,
                         l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                         l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id,
                         l_prev_date, l_bitand_id, l_bitand_id, l_period_type,
			 l_fst_crdt_type, l_fst_crdt_type, l_curr_as_of_date,
                         l_prev_date, l_prior_prior_date, l_curr_page_time_id, l_prev_page_time_id,
                         l_prior_prior_time_id, l_yes, l_sg_id_num, l_parent_sales_group_id, l_yes,
                         l_unassigned_value,
			 l_snapshot_date, l_period_type,
		         l_snapshot_date,
		         l_snapshot_date, l_period_type,
			 l_snapshot_date,
			 l_snapshot_date,
                         l_sg_id_num, l_parent_sales_group_id, l_yes;
               ELSE
                   EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	             USING l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id,
                         l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                         l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id,
                         l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                         l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id,
                         l_prev_date, l_bitand_id, l_bitand_id, l_period_type,
			 l_fst_crdt_type, l_fst_crdt_type, l_curr_as_of_date,
                         l_prev_date, l_prior_prior_date, l_curr_page_time_id, l_prev_page_time_id,
                         l_prior_prior_time_id, l_yes, l_sg_id_num, l_parent_sales_group_id, l_yes,
                         l_unassigned_value,
			 l_snapshot_date, l_period_type,
		         l_prev_snap_date, l_period_type,
		         l_snapshot_date, l_period_type,
			 l_prev_snap_date, l_period_type,
			 l_snapshot_date, l_prev_snap_date,
                         l_sg_id_num, l_parent_sales_group_id, l_yes;
                END IF;
        ELSE

              IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	         EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	              USING
                          l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date,
                          l_prior_prior_time_id, l_prior_prior_date, l_curr_page_time_id, l_curr_as_of_date,
			  l_prev_page_time_id, l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                          l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date, l_bitand_id,
                          l_bitand_id, l_period_type, l_fst_crdt_type, l_fst_crdt_type, l_curr_as_of_date,
                          l_prev_date, l_prior_prior_date, l_curr_page_time_id, l_prev_page_time_id,
                          l_prior_prior_time_id, l_yes, l_sg_id_num, l_sg_id_num, l_yes, l_resource_id,
                          l_unassigned_value,
			 l_snapshot_date, l_period_type,
			 l_snapshot_date,
			 l_snapshot_date, l_period_type,
			 l_snapshot_date,
			 l_snapshot_date,
		           l_sg_id_num, l_sg_id_num, l_resource_id, l_yes;
                ELSE
	           EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
	               USING
                          l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date,
                          l_prior_prior_time_id, l_prior_prior_date, l_curr_page_time_id, l_curr_as_of_date,
			  l_prev_page_time_id, l_prev_date, l_prior_prior_time_id, l_prior_prior_date,
                          l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id, l_prev_date, l_bitand_id,
                          l_bitand_id, l_period_type, l_fst_crdt_type, l_fst_crdt_type, l_curr_as_of_date,
                          l_prev_date, l_prior_prior_date, l_curr_page_time_id, l_prev_page_time_id,
                          l_prior_prior_time_id, l_yes, l_sg_id_num, l_sg_id_num, l_yes, l_resource_id,
                          l_unassigned_value,
			 l_snapshot_date, l_period_type,
			 l_prev_snap_date, l_period_type,
			 l_snapshot_date, l_period_type,
			 l_prev_snap_date, l_period_type,
			 l_snapshot_date, l_prev_snap_date,
		           l_sg_id_num, l_sg_id_num, l_resource_id, l_yes;
                 END IF;

	END IF;
   END IF;


ELSE -- product cat not all

         l_custom_sql := ' SELECT   VIEWBY '||
                         ',VIEWBYID '||
                         ',SORTORDER '||
                         ',SUM(frcst) BIL_MEASURE1 '||
                         ',SUM(priorFrcst) BIL_MEASURE2 '||
                         ',SUM(priorpriorFrcst) BIL_MEASURE3 '||
                         ',SUM(oppFrcst) BIL_MEASURE4 '||
                         ',SUM(prior_oppFrcst) BIL_MEASURE5 '||
                         ',SUM(priorprior_oppFrcst) BIL_MEASURE6 '||
                         ',SUM(frcst_sub) BIL_MEASURE7 '||
                         ',SUM(priorFrcst_sub) BIL_MEASURE8 '||
                         ',NULL BIL_MEASURE9 '||
                         ',NULL BIL_MEASURE10 '||
                         ',NULL BIL_MEASURE11 '||
                         ',NULL BIL_MEASURE12 '||
                         ',BIL_URL1 '||
                         ',DECODE(VIEWBY,'||':l_cat_assign'||',NULL,'''||l_pipe_url||''') BIL_URL2 '||
           	        ' FROM  '||
		      '( '||
		      ' SELECT /*+ LEADING(cal) */ '||
		      ' decode(pcd.parent_id,pcd.child_id,'||
		      ' decode(sumry.assign_to_cat,0,pcd.value,:l_cat_assign), '||
		      ' pcd.value) VIEWBY '||
		      ', decode(pcd.parent_id,pcd.id, 1, 2) sortorder, '||
		       l_sql_stmnt1||
		       ',pcd.id VIEWBYID'||
		       ',SUMRY.salesrep_id salesrep_id '||
		       ',decode(pcd.parent_id, pcd.child_id, null, '''||l_cat_url||''') BIL_URL1 '||
                       ',NULL BIL_URL2 '||
		       ' FROM '||l_fii_struct||' cal, '||
		                l_sumry||' sumry '||
				l_denorm||' '||
                        ' '||l_where_clause1||' AND '||l_product_where_clause1||
		        ' AND sumry.sales_group_id = :l_sg_id_num '||
			  l_parent_sls_grp_where_clause ||
			' AND cal.xtd_flag = :l_yes ';


   IF l_resource_id IS  NULL THEN
      l_custom_sql :=l_custom_sql ||' AND sumry.salesrep_id IS NULL ';
   ELSE
      l_custom_sql :=l_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
   END IF;


				l_custom_sql := l_custom_sql ||
							' )tmp1'||
							' GROUP BY VIEWBY, VIEWBYID, SORTORDER,BIL_URL1,BIL_URL2 ';

   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || 'Prod cat Viewby ',
		                 MESSAGE => ' Forecast Query Product Cat not All ');
   END IF;



                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| 'Forecast Query =>',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


			IF l_parent_sales_group_id IS NULL THEN
				   IF l_resource_id IS NULL THEN
					EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
					  USING l_cat_assign, l_cat_assign,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
                                                l_prior_prior_time_id,
                                                l_prior_prior_date,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
                                                l_prior_prior_time_id,
                                                l_prior_prior_date,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
						l_bitand_id,
                                                l_bitand_id,
                                                l_period_type,
						l_fst_crdt_type,
                                                l_fst_crdt_type,
						l_curr_as_of_date,
                                                l_prev_date,
                                                l_prior_prior_date,
                                                l_curr_page_time_id,
                                                l_prev_page_time_id,
                                                l_prior_prior_time_id,
						l_prodcat_id,
						l_sg_id_num,
                                                l_yes;
				    ELSE
					EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
					  USING l_cat_assign, l_cat_assign,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
                                                l_prior_prior_time_id,
                                                l_prior_prior_date,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
                                                l_prior_prior_time_id,
                                                l_prior_prior_date,
                                                l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
						l_bitand_id,
                                                l_bitand_id,
                                                l_period_type,
						l_fst_crdt_type,
                                                l_fst_crdt_type,
						l_curr_as_of_date,
                                                l_prev_date,
                                                l_prior_prior_date,
                                                l_curr_page_time_id,
                                                l_prev_page_time_id,
                                                l_prior_prior_time_id,
                                                l_prodcat_id,
						l_sg_id_num,
                                                l_yes,
                                                l_resource_id;
				   END IF;
				ELSE-- parent sales group is not null
				   IF l_resource_id IS NULL THEN
					EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
					  USING l_cat_assign,l_cat_assign,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
                                                l_prior_prior_time_id,
                                                l_prior_prior_date,
               			  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
                                                l_prior_prior_time_id,
                                                l_prior_prior_date,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
						l_bitand_id,
                                                l_bitand_id,
                                                l_period_type,
						l_fst_crdt_type,
                                                l_fst_crdt_type,
						l_curr_as_of_date,
                                                l_prev_date,
                                                l_prior_prior_date,
                                                l_curr_page_time_id,
                                                l_prev_page_time_id,
                                                l_prior_prior_time_id,
						l_prodcat_id,
						l_sg_id_num,
						l_parent_sales_group_id,
						l_yes;
				   ELSE
					EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
					  USING l_cat_assign,l_cat_assign,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
                                                l_prior_prior_time_id,
                                                l_prior_prior_date,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
                                                l_prior_prior_time_id,
                                                l_prior_prior_date,
				  		l_curr_page_time_id,
                                                l_curr_as_of_date,
						l_prev_page_time_id,
                                                l_prev_date,
						l_bitand_id,
                                                l_bitand_id,
                                                l_period_type,
						l_fst_crdt_type,
                                                l_fst_crdt_type,
						l_curr_as_of_date,
                                                l_prev_date,
                                                l_prior_prior_date,
                                                l_curr_page_time_id,
                                                l_prev_page_time_id,
                                                l_prior_prior_time_id,
                                                l_prodcat_id,
						l_sg_id_num,
						l_sg_id_num,
						l_yes,
                                                l_resource_id;
				   END IF;
				END IF;

	-- for pipeline measures

	l_custom_sql :=
	 ' SELECT VIEWBY '||
	            ', VIEWBYID '||
	            ', SORTORDER '||
          	   ',NULL BIL_MEASURE1 '||
          	   ',NULL BIL_MEASURE2 '||
          	   ',NULL BIL_MEASURE3 '||
          	   ',NULL BIL_MEASURE4 '||
                   ',NULL BIL_MEASURE5 '||
          	   ',NULL BIL_MEASURE6 '||
          	   ',NULL BIL_MEASURE7 '||
          	   ',NULL BIL_MEASURE8 '||
          	   ',SUM(pipeline) BIL_MEASURE9 '||
          	   ',SUM(priorPipeline) BIL_MEASURE10 '||
          	   ',SUM(wtdPipeline) BIL_MEASURE11 '||
          	   ',SUM(priorWtdPipeline) BIL_MEASURE12 '||
          	   ',BIL_URL1 '||
                   ',DECODE(VIEWBY,'||':l_cat_assign'||',NULL,'''||l_pipe_url||''') BIL_URL2 '||
	 ' FROM  '||
	     '( '||
	      ' SELECT DECODE(pcd.parent_id, pcd.id,
	      decode(sumry.item_id, ''-1'', :l_cat_assign, pcd.value), pcd.value) VIEWBY
              ,DECODE(pcd.parent_id, pcd.id,
	      decode(sumry.item_id, ''-1'', 1, 2), 2) SORTORDER, '||
              l_sql_stmnt3||
	      ',pcd.id VIEWBYID'||
	      ',decode(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL1 '||
              ',NULL BIL_URL2 '||
	 ' FROM '||l_sumry2||' sumry'||
            l_pipe_denorm||' '||
            ' '||l_where_clause3||' '||
            l_pipe_product_where_clause ||
            ' AND sumry.sales_group_id = :l_sg_id_num '||
            l_parent_sls_grp_where_clause;


	    IF l_resource_id IS  NULL THEN
	       l_custom_sql :=l_custom_sql ||' AND sumry.salesrep_id IS NULL ';
	    ELSE
               l_custom_sql :=l_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
	    END IF;

	    l_custom_sql := l_custom_sql||
	                    ' )tmp1'||
			    ' GROUP BY VIEWBY, VIEWBYID, SORTORDER ,BIL_URL1, BIL_URL2 ';


   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || 'Prod cat Viewby ',
		                 MESSAGE => ' x_custom_sql length '||LENGTH(l_custom_sql));

   END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' Oppty Pipe query ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


    IF l_parent_sales_group_id IS NULL THEN
           IF l_resource_id IS NULL THEN
                IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	              EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		            USING
                            l_cat_assign, l_cat_assign,
                            l_snapshot_date, l_period_type,
			    l_snapshot_date,
			    l_snapshot_date, l_period_type,
			    l_snapshot_date,
			    l_snapshot_date,
			    l_prodcat_id, l_sg_id_num;
                 ELSE
	              EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		            USING
                            l_cat_assign, l_cat_assign,
                            l_snapshot_date, l_period_type,
			    l_prev_snap_date, l_period_type,
			    l_snapshot_date, l_period_type,
			    l_prev_snap_date, l_period_type,
			    l_snapshot_date, l_prev_snap_date,
			    l_prodcat_id, l_sg_id_num;
                  END IF;

	    ELSE
                IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	  	      EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		            USING l_cat_assign, l_cat_assign,
                             l_snapshot_date, l_period_type,
			     l_snapshot_date,
			     l_snapshot_date, l_period_type,
			     l_snapshot_date,
			     l_snapshot_date,
                             l_prodcat_id, l_sg_id_num, l_resource_id;
                ELSE
	  	      EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		            USING l_cat_assign, l_cat_assign,
                             l_snapshot_date, l_period_type,
			     l_prev_snap_date, l_period_type,
			     l_snapshot_date, l_period_type,
			     l_prev_snap_date, l_period_type,
			     l_snapshot_date, l_prev_snap_date,
                             l_prodcat_id, l_sg_id_num, l_resource_id;
                END IF;

	     END IF;
    ELSE -- parent sales group id not null
             IF l_resource_id IS NULL THEN
                IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
		   EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		        USING l_cat_assign,l_cat_assign,
                           l_snapshot_date, l_period_type,
			   l_snapshot_date,
			   l_snapshot_date, l_period_type,
			   l_snapshot_date,
			   l_snapshot_date,
			   l_prodcat_id, l_sg_id_num, l_parent_sales_group_id;
                 ELSE
		   EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		        USING l_cat_assign,l_cat_assign,
                           l_snapshot_date, l_period_type,
			   l_prev_snap_date, l_period_type,
			   l_snapshot_date, l_period_type,
			   l_prev_snap_date, l_period_type,
			   l_snapshot_date, l_prev_snap_date,
			   l_prodcat_id, l_sg_id_num, l_parent_sales_group_id;
                  END IF;

              ELSE
                IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
		    EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		         USING l_cat_assign, l_cat_assign,
                          l_snapshot_date, l_period_type,
			  l_snapshot_date,
			  l_snapshot_date, l_period_type,
			  l_snapshot_date,
			  l_snapshot_date,
                          l_prodcat_id, l_sg_id_num, l_sg_id_num, l_resource_id;
                 ELSE
		    EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
		         USING l_cat_assign, l_cat_assign,
                          l_snapshot_date, l_period_type,
			  l_prev_snap_date, l_period_type,
			  l_snapshot_date, l_period_type,
			  l_prev_snap_date, l_period_type,
			  l_snapshot_date, l_prev_snap_date,
                          l_prodcat_id, l_sg_id_num, l_sg_id_num, l_resource_id;
                  END IF;
	      END IF;
     END IF;
  END IF;

/*
BIL_MEASURE28    frcst
BIL_MEASURE2     priorfrcst
BIL_MEASURE3     priorpriorfrcst
BIL_MEASURE4     oppfcst
BIL_MEASURE5     prior_oppfrcst
BIL_MEASURE6     priorprior_oppfrcst
BIL_MEASURE7     frcst_sub
BIL_MEASURE8     priorfrcst_sub
BIL_MEASURE9     pipeline
BIL_MEASURE10    priorpipeline
BIL_MEASURE11    wtdpipeline
BIL_MEASURE12    priorwtdpipeline
BIL_MEASURE13    Total Judgement              SUM(BIL_MEASURE28) - SUM(BIL_MEASURE4)
BIL_MEASURE14    Prior Total Judgement        SUM(BIL_MEASURE2) -  SUM(BIL_MEASURE5)
BIL_MEASURE15    Prior Prior Total Judgement  SUM(BIL_MEASURE3) -  SUM(BIL_MEASURE6)
*/

IF l_resource_id IS NULL THEN

x_custom_sql := 'SELECT '||
'VIEWBY, '||
'VIEWBYID, '||
'BIL_MEASURE1 ,  '||
'BIL_MEASURE23,  '||
'BIL_MEASURE24,  '||
'BIL_MEASURE2 ,  '||
'BIL_MEASURE25,  '||
'BIL_MEASURE26,  '||
'BIL_MEASURE27,  '||
'BIL_MEASURE3 ,  '||
'BIL_MEASURE4 ,  '||
'BIL_MEASURE5 ,  '||
'BIL_MEASURE6 ,  '||
'BIL_MEASURE7 ,  '||
'BIL_MEASURE28,  '||
'BIL_MEASURE8 ,  '||
'BIL_MEASURE9 ,  '||
'BIL_MEASURE29,  '||
'BIL_MEASURE10,  '||
'BIL_MEASURE11,  '||
'BIL_MEASURE30,  '||
'BIL_MEASURE12,  '||
'BIL_MEASURE13,  '||
'BIL_MEASURE14,  '||
'BIL_MEASURE15,  '||
'BIL_MEASURE16,  '||
'BIL_MEASURE17,  '||
'BIL_MEASURE18,  '||
'BIL_MEASURE19,  '||
'BIL_MEASURE20,  '||
'BIL_MEASURE21,  '||
'BIL_MEASURE22,  '||
'BIL_MEASURE32,  '||
'BIL_URL1,       '||
''''||l_url_str ||''' BIL_URL3,'||
'BIL_URL2        '||
  ' FROM ( '||
   l_outer_select ||
      ' FROM ( '||
        'SELECT VIEWBY, VIEWBYID, SORTORDER,  '||
        ' SUM(BIL_MEASURE28) BIL_MEASURE28,'||
        ' SUM(BIL_MEASURE2) BIL_MEASURE2,  '||
        ' SUM(BIL_MEASURE3) BIL_MEASURE3,  '||
        ' SUM(BIL_MEASURE4) BIL_MEASURE4,  '||
        ' SUM(BIL_MEASURE5) BIL_MEASURE5,  '||
        ' SUM(BIL_MEASURE6) BIL_MEASURE6,  '||
        ' SUM(BIL_MEASURE7) BIL_MEASURE7,  '||
        ' SUM(BIL_MEASURE8) BIL_MEASURE8,  '||
        ' SUM(BIL_MEASURE9) BIL_MEASURE9,  '||
        ' SUM(BIL_MEASURE10) BIL_MEASURE10,  '||
        ' SUM(BIL_MEASURE11) BIL_MEASURE11,  '||
        ' SUM(BIL_MEASURE12) BIL_MEASURE12,  '||
        ' SUM(BIL_MEASURE28) - SUM(BIL_MEASURE4) BIL_MEASURE13, '||
        ' SUM(BIL_MEASURE2)  - SUM(BIL_MEASURE5) BIL_MEASURE14, '||
        ' SUM(BIL_MEASURE3)  - SUM(BIL_MEASURE6) BIL_MEASURE15, '||
        ' BIL_URL1,  '||
        ' BIL_URL2 ' ||
        ' FROM BIL_BI_RPT_TMP1 '||
        ' GROUP BY VIEWBY, VIEWBYID, SORTORDER, '||
        ' BIL_URL1, BIL_URL2 ' ||
        ') '||
' ORDER BY SORTORDER, UPPER(VIEWBY) '||')' ||
' WHERE '||l_null_removal_clause;

ELSE

x_custom_sql := 'SELECT '||
'VIEWBY, '||
'VIEWBYID, '||
'NULL BIL_MEASURE1 ,  '||
'BIL_MEASURE23,  '||
'BIL_MEASURE24,  '||
'NULL BIL_MEASURE2 ,  '||
'BIL_MEASURE25,  '||
'BIL_MEASURE26,  '||
'BIL_MEASURE27,  '||
'BIL_MEASURE3 ,  '||
'BIL_MEASURE4 ,  '||
'BIL_MEASURE5 ,  '||
'BIL_MEASURE6 ,  '||
'BIL_MEASURE1 BIL_MEASURE7, '||
'BIL_MEASURE28,  '||
'BIL_MEASURE2 BIL_MEASURE8, '||
'BIL_MEASURE9 ,  '||
'BIL_MEASURE29,  '||
'BIL_MEASURE10,  '||
'BIL_MEASURE11,  '||
'BIL_MEASURE30,  '||
'BIL_MEASURE12,  '||
'NULL BIL_MEASURE13,  '||
'NULL BIL_MEASURE14,  '||
'BIL_MEASURE15,  '||
'BIL_MEASURE16,  '||
'BIL_MEASURE13 BIL_MEASURE17, '||
'BIL_MEASURE14 BIL_MEASURE18, '||
'BIL_MEASURE19,  '||
'BIL_MEASURE20,  '||
'BIL_MEASURE21,  '||
'BIL_MEASURE22,  '||
'BIL_MEASURE32,  '||
'BIL_URL1,       '||
''''||l_url_str ||''' BIL_URL3,'||
'BIL_URL2        '||
  ' FROM ( '||
   l_outer_select ||
      ' FROM ( '||
        'SELECT VIEWBY, VIEWBYID, SORTORDER,  '||
        ' SUM(BIL_MEASURE28) BIL_MEASURE28,'||
        ' SUM(BIL_MEASURE2) BIL_MEASURE2,  '||
        ' SUM(BIL_MEASURE3) BIL_MEASURE3,  '||
        ' SUM(BIL_MEASURE4) BIL_MEASURE4,  '||
        ' SUM(BIL_MEASURE5) BIL_MEASURE5,  '||
        ' SUM(BIL_MEASURE6) BIL_MEASURE6,  '||
        ' SUM(BIL_MEASURE7) BIL_MEASURE7,  '||
        ' SUM(BIL_MEASURE8) BIL_MEASURE8,  '||
        ' SUM(BIL_MEASURE9) BIL_MEASURE9,  '||
        ' SUM(BIL_MEASURE10) BIL_MEASURE10,  '||
        ' SUM(BIL_MEASURE11) BIL_MEASURE11,  '||
        ' SUM(BIL_MEASURE12) BIL_MEASURE12,  '||
        ' SUM(BIL_MEASURE28) - SUM(BIL_MEASURE4) BIL_MEASURE13, '||
        ' SUM(BIL_MEASURE2)  - SUM(BIL_MEASURE5) BIL_MEASURE14, '||
        ' SUM(BIL_MEASURE3)  - SUM(BIL_MEASURE6) BIL_MEASURE15, '||
        ' BIL_URL1, '||
        ' BIL_URL2  '||
        ' FROM BIL_BI_RPT_TMP1 '||
        ' GROUP BY VIEWBY, VIEWBYID, SORTORDER, '||
        ' BIL_URL1, BIL_URL2 ' ||
        ') '||
' ORDER BY SORTORDER, UPPER(VIEWBY) '||')' ||
' WHERE '||l_null_removal_clause;

END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' Final Query ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || 'Query Length=>',
		                 MESSAGE => length(x_custom_sql));

   END IF;

  ELSE --no valid parameters

       		BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                    ,x_sqlstr    => x_custom_sql);
   END IF;

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
		                    MODULE => g_pkg || l_proc || 'proc_error',
		                    MESSAGE => fnd_message.get );
              END IF;
      RAISE;
END BIL_BI_FRCST_PRODCAT;

END BIL_BI_FCST_MGMT_RPTS_PKG;


/
