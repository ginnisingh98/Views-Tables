--------------------------------------------------------
--  DDL for Package Body BIL_BI_OPPTY_MGMT_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_OPPTY_MGMT_RPTS_PKG" AS
/* $Header: bilbosb.pls 120.9 2005/10/13 09:17:44 sulingam noship $                  */

g_pkg VARCHAR2(100);
g_sch_name VARCHAR2(100);

 /*******************************************************************************
 * Name    : Procedure BIL_BI_WTD_PIPELINE
 * Author  : Prasanna Patil
 * Date    : June 30, 2003
 * Purpose : Weighted Pipeline Sales Intelligence report and charts.
 *
 *           Copyright (c) 2002 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 *
 * Date     Author     Description
 * ----     ------     -----------
 * 06/30/03 ppatil	   Intial Version
 * 05 Feb 2004 krsundar    New pipeline defn.
 * 09 Feb 2004 krsundar    Removed product references
 * 25 Feb 2004 krsundar    Pipeline : get_latest_snap_date uptake
 * 15 Mar 2004 krsundar    Remove temp tables (wherever possible)
 * 25 Mar 2004 krsundar    Drill and pivot fix
 ******************************************************************************/
PROCEDURE BIL_BI_WTD_PIPELINE(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                             ,x_custom_sql         OUT NOCOPY VARCHAR2
                             ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
AS
    l_curr_page_time_id         NUMBER;
    l_prev_page_time_id         NUMBER;
    l_bind_ctr                  NUMBER;
    l_record_type_id            NUMBER;
    l_sg_id_num                 NUMBER;
    l_curr_as_of_date           DATE;
    l_snap_date                 DATE;
    l_prev_date                 DATE;
    l_bis_sysdate               DATE;
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_comp_type                 VARCHAR2(50);
    l_bitand_id                 VARCHAR2(50);
    l_calendar_id               VARCHAR2(50);
    l_period_type               VARCHAR2(50);
    l_sg_id                     VARCHAR2(50);
    l_conv_rate_selected        VARCHAR2(50);
    l_page_period_type          VARCHAR2(50);
    l_fii_struct                VARCHAR2(50);
    l_sql_error_msg             VARCHAR2(1000);
    l_sql_error_desc            VARCHAR2(4000);
    l_viewby                    VARCHAR2(80) ;
    l_inner_where_clause        VARCHAR2(200);
    l_outer_select              VARCHAR2(3000);
    l_inter_select              VARCHAR2(5000);
    l_inner_select              VARCHAR2(15000);
    l_prodcat                   VARCHAR2(50);
    l_sumry                     VARCHAR2(50);
    l_url                       VARCHAR2(1000);
    l_custom_sql                VARCHAR2(32000);
    l_resource_id               VARCHAR2(20);
    l_insert_stmnt              VARCHAR2(5000);
    l_null_rem_clause           VARCHAR2(500);
    l_pipe                      VARCHAR2(200);
    l_wtd_pipe                  VARCHAR2(300);
    l_pb1                       VARCHAR2(250);
    l_pb2                       VARCHAR2(250);
    l_pb3                       VARCHAR2(250);
    l_pb4                       VARCHAR2(250);
    l_pb5                       VARCHAR2(250);
    l_pb6                       VARCHAR2(250);
    l_pb7                       VARCHAR2(250);
    l_pb8                       VARCHAR2(250);
    l_pb9                       VARCHAR2(250);
    l_pb10                       VARCHAR2(250);
    l_region_id                 VARCHAR2(50);
    l_rpt_str                   VARCHAR(50);
    l_parameter_valid           BOOLEAN;
    l_cat_assign                VARCHAR2(1000);
    l_proc                      VARCHAR2(100);
    l_parent_sales_group_id	    NUMBER;
    l_parent_sls_grp_where_clause	VARCHAR2(1000);
    l_pipe_product_where_clause	  VARCHAR2(1000);
    l_pipe_denorm               VARCHAR2(100);
    l_pc_select			        VARCHAR2(5000);
    l_unassigned_value		    VARCHAr2(100);
    l_currency_suffix           VARCHAR2(5);
    l_yes                       VARCHAR2(1);
    l_bis_bucket_rec BIS_BUCKET_PUB.bis_bucket_rec_type;
    l_return_status VARCHAR2(10);
    l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_bucket1   NUMBER;
    l_bucket2   NUMBER;
    l_bucket3   NUMBER;
    l_bucket4   NUMBER;
    l_bucket5   NUMBER;
    l_bucket6   NUMBER;
    l_bucket7   NUMBER;
    l_bucket8   NUMBER;
    l_bucket9   NUMBER;
    l_bucket10   NUMBER;
    l_buckets  NUMBER;
    l_outer_select1 VARCHAR2(500);
    l_outer_select2 VARCHAR2(500);
	    l_range1_low NUMBER;
    l_range2_low NUMBER;
    l_range3_low NUMBER;
    l_range4_low NUMBER;
    l_range5_low NUMBER;
    l_range6_low NUMBER;
    l_range7_low NUMBER;
    l_range8_low NUMBER;
    l_range9_low NUMBER;
    l_range10_low NUMBER;
    l_range1_high NUMBER;
    l_range2_high NUMBER;
    l_range3_high NUMBER;
    l_range4_high NUMBER;
    l_range5_high NUMBER;
    l_range6_high NUMBER;
    l_range7_high NUMBER;
    l_range8_high NUMBER;
    l_range9_high NUMBER;
    l_range10_high NUMBER;
    l_default_query1 VARCHAR2(1000);
    l_default_query2 VARCHAR2(1000);

    l_drill_link  VARCHAR2(2000);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

    l_pipe_amt            VARCHAR2(1000);
    l_wt_pipe_amt            VARCHAR2(1000);
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
    l_test_sql       varchar2(4000);


  BEGIN
       /*Intializing variables*/
	   g_pkg := 'bil.patch.115.sql.BIL_BI_OPPTY_MGMT_RPTS_PKG.';
	   l_bind_ctr := 0;
	   l_region_id := 'BIL_BI_WTD_PIPELINE';
       l_rpt_str := 'BIL_BI_WTDPIPE_R';
       l_parameter_valid := FALSE;
       l_cat_assign := ' ';
       l_proc := 'BIL_BI_WTD_PIPELINE.';
       l_yes := 'Y';
	   l_buckets := 10;
       l_bucket1 := 1;
       l_bucket2 := 2;
       l_bucket3 := 3;
       l_bucket4 := 4;
       l_bucket5 := 5;
       l_bucket6 := 6;
       l_bucket7 := 7;
       l_bucket8 := 8;
       l_bucket9 := 9;
       l_bucket10 := 10;
       l_default_query1 := ' ';
       l_default_query2 := ' ';


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                 MODULE => g_pkg || l_proc || 'begin',
		                 MESSAGE => 'Start of Procedure '|| l_proc);

   END IF;


       BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl  => p_page_parameter_tbl
                                      ,p_region_id           => l_region_id
                                      ,x_period_type         => l_period_type
                                      ,x_conv_rate_selected  => l_conv_rate_selected
                                      ,x_sg_id               => l_sg_id
  				     ,x_parent_sg_id	   	 => l_parent_sales_group_id
                                      ,x_resource_id         => l_resource_id
                                      ,x_prodcat_id          => l_prodcat
                                      ,x_curr_page_time_id   => l_curr_page_time_id
                                      ,x_prev_page_time_id   => l_prev_page_time_id
                                      ,x_comp_type           => l_comp_type
                                      ,x_parameter_valid     => l_parameter_valid
                                      ,x_as_of_date          => l_curr_as_of_date
                                      ,x_page_period_type    => l_page_period_type
                                      ,x_prior_as_of_date    => l_prev_date
                                      ,x_record_type_id      => l_record_type_id
                                      ,x_viewby              => l_viewby);

   BIS_BUCKET_PUB.RETRIEVE_BIS_BUCKET (
  p_short_name	=> 'BIL_BI_WTD_PIPELINE_BUK'
, x_bis_bucket_rec		=> l_bis_bucket_rec
, x_return_status       => l_return_status
, x_error_tbl           => l_error_tbl
);





l_range1_low  := l_bis_bucket_rec.range1_low;l_range1_high := l_bis_bucket_rec.range1_high;

l_range2_low  := l_bis_bucket_rec.range2_low;l_range2_high := l_bis_bucket_rec.range2_high;

l_range3_low  := l_bis_bucket_rec.range3_low;l_range3_high := l_bis_bucket_rec.range3_high;

l_range4_low  := l_bis_bucket_rec.range4_low;l_range4_high := l_bis_bucket_rec.range4_high;

l_range5_low  := l_bis_bucket_rec.range5_low;l_range5_high := l_bis_bucket_rec.range5_high;

l_range6_low  := l_bis_bucket_rec.range6_low;l_range6_high  := l_bis_bucket_rec.range6_high;

l_range7_low  := l_bis_bucket_rec.range7_low;l_range7_high  := l_bis_bucket_rec.range7_high;

l_range8_low  := l_bis_bucket_rec.range8_low;l_range8_high  := l_bis_bucket_rec.range8_high;

l_range9_low  := l_bis_bucket_rec.range9_low;l_range9_high  := l_bis_bucket_rec.range9_high;

l_range10_low := l_bis_bucket_rec.range10_low;l_range10_high := l_bis_bucket_rec.range10_high;



--should I create a structure here so that I don't have 10 IF checks
IF l_range1_low IS NULL AND l_range1_high IS NULL THEN
l_range1_low := -1;l_range1_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range2_low IS NULL AND l_range2_high IS NULL THEN
l_range2_low := -1;l_range2_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range3_low IS NULL AND l_range3_high IS NULL THEN
l_range3_low := -1;l_range3_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range4_low IS NULL AND l_range4_high IS NULL THEN
l_range4_low := -1;l_range4_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range5_low IS NULL AND l_range5_high IS NULL THEN
l_range5_low := -1;l_range5_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range6_low IS NULL AND l_range6_high IS NULL THEN
l_range6_low := -1;l_range6_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range7_low IS NULL AND l_range7_high IS NULL THEN
l_range7_low := -1;l_range7_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range8_low IS NULL AND l_range8_high IS NULL THEN
l_range8_low := -1;l_range8_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range9_low IS NULL AND l_range9_high IS NULL THEN
l_range9_low := -1;l_range9_high := -1;l_buckets := l_buckets-1;
END IF;

IF l_range10_low IS NULL AND l_range10_high IS NULL THEN
l_range10_low := -1;l_range10_high := -1;l_buckets := l_buckets-1;
END IF;


/*
       bil_bi_util_pkg.get_latest_snap_date(p_page_parameter_tbl  => p_page_parameter_tbl
                                           ,p_as_of_date          => l_curr_as_of_date
                                           ,p_period_type         => NULL
                                           ,x_snapshot_date       => l_snap_date);
*/

       IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
       ELSE
            l_currency_suffix := '';
       END IF;


       IF l_parameter_valid THEN

          l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id,''''));
          l_resource_id := TO_NUMBER(REPLACE(l_resource_id,''''));

          IF l_prodcat IS NULL THEN
             l_prodcat := 'All';
          ELSE
             l_prodcat := REPLACE(l_prodcat,'''','');
          END IF;

          BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id   => l_bitand_id
                                          ,x_calendar_id => l_calendar_id
                                          ,x_curr_date   => l_bis_sysdate
                                          ,x_fii_struct  => l_fii_struct);



-- Get the Drill Link to the Opty Line Detail Report

l_drill_link := bil_bi_util_pkg.get_drill_links( p_view_by =>  l_viewby,
                                                 p_salesgroup_id =>   l_sg_id,
                                                 p_resource_id   =>    l_resource_id  );





/* Get the Prefix for the Open amt based upon Period Type and Compare To Params */


l_pipe_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'P',
                                     p_curr_suffix    => l_currency_suffix
				    );

l_wt_pipe_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
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


   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                l_sql_error_desc := 'l_viewby => '||l_viewby||','||
                                 'l_curr_page_time_id => '|| l_curr_page_time_id ||',' ||
                                 'l_prev_page_time_id => '|| l_prev_page_time_id ||',' ||
                                 'l_snapshot_date => '|| l_snapshot_date ||',' ||
                                 'l_prev_snap_date => '|| l_prev_snap_date ||',' ||
                                 'l_conv_rate_selected => '|| l_conv_rate_selected ||',' ||
                                 'l_bitand_id => '|| l_bitand_id ||',' ||
                                 'l_period_type => '|| l_period_type ||',' ||
                                 'l_sg_id_num => '|| l_sg_id_num ||',' ||
                                 'l_resource_id => '|| l_resource_id ||',' ||
                                 'l_bis_sysdate => '|| l_bis_sysdate ||',' ||
                                 'l_calendar_id => '|| l_calendar_id ||',' ||
                                 'l_prodcat => '|| l_prodcat;


                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => 'Params '||l_sql_error_desc);

   END IF;



IF( l_open_mv_new = 'BIL_BI_PIPEC_G_MV') THEN
  l_open_mv_new := 'BIL_BI_PIPEC_WG_MV' ;
ELSE
  l_open_mv_new := 'BIL_BI_PIPE_MV' ;
END IF;


          /* Mappings...
           * BIL_MEASURE22 - Pipeline
           * BIL_MEASURE23 - Prior Pipeline
           * BIL_MEASURE24 - Change
           * BIL_MEASURE2_B1-B10 probability 1 to 10

           * BIL_MEASURE7  - Weighted Pipeline
           * BIL_MEASURE8  - Prior Weighted Pipeline
           * BIL_MEASURE25 - Change
           * BIL_MEASURE12_B1-B10 -probability 1 to 10 total
           * BIL_MEASURE17 - Weighted Pipeline Total
           * BIL_MEASURE18 - Prior Weighted Pipeline
           * BIL_MEASURE20 - Pipeline Mix Graph (Region does not have a prompt)
           * BIL_MEASURE34 - Grand total(BIL_MEASURE20), Might not be necesarry
           * BIL_MEASURE26 - Pipeline Total
           * BIL_MEASURE27 - Prior Pipeline Total
           * BIL_MEASURE28 - Pipeline Change Total
           * BIL_MEASURE29 - Weighted Pipeline Change Total
           * BIL_MEASURE32 - Weighted Pipeline Mix Graph (Region does not have a prompt)
           * BIL_MEASURE33 - Grand Total(BIL_MEASURE32), Might not be necesarry
           * BIL_URL3      - Drill to Opty Line Detail Report
           */


          l_outer_select := 'SELECT VIEWBY ';
          IF 'ORGANIZATION+JTF_ORG_SALES_GROUP' = l_viewby THEN
              l_outer_select := l_outer_select ||
			  	',DECODE(BIL_URL1,NULL,VIEWBYID||''.''||:l_sg_id_num,VIEWBYID) VIEWBYID ';
          ELSE
              l_outer_select := l_outer_select ||',VIEWBYID ';
          END IF;



                  l_null_rem_clause := ' WHERE NOT (BIL_MEASURE22 IS NULL '||
                                           'AND BIL_MEASURE2_B1 IS NULL ';

    --get the number of buckets
    --SELECT COUNT(1)
    --INTO l_buckets
    --FROM BIL_BI_BUCKET_MV;


   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc,
		                 MESSAGE => 'No of buckets '|| l_buckets);

   END IF;


    FOR i IN 2..l_buckets
    LOOP
            l_outer_select1 := l_outer_select1 || ',BIL_MEASURE2_B'||i;
            l_outer_select2 := l_outer_select2 || ',SUM(BIL_MEASURE2_B' ||i|| ') OVER() BIL_MEASURE12_B'||i;
            l_null_rem_clause := l_null_rem_clause || ' AND BIL_MEASURE2_B'||i|| ' IS NULL';
	END LOOP;


    l_null_rem_clause := l_null_rem_clause ||  ' AND BIL_MEASURE7 IS NULL) ';




          l_outer_select := l_outer_select ||',BIL_MEASURE22 '||
                                  ',BIL_MEASURE23 '||
                                  ',(BIL_MEASURE22 - BIL_MEASURE23) / '||
				  ' ABS(DECODE(BIL_MEASURE23,0,NULL,BIL_MEASURE23)) * 100 BIL_MEASURE24 '||
                                  ',BIL_MEASURE2_B1 '|| l_outer_select1;

         l_outer_select := l_outer_select ||             ',BIL_MEASURE7 '||
                                  ',BIL_MEASURE8 '||
                                  ',SUM(BIL_MEASURE2_B1) OVER() BIL_MEASURE12_B1 '|| l_outer_select2;
        l_outer_select := l_outer_select ||
                                  ',SUM(BIL_MEASURE7) OVER() BIL_MEASURE17 '||
                                  ',SUM(BIL_MEASURE8) OVER() BIL_MEASURE18 '||
                                  ',BIL_MEASURE22 BIL_MEASURE20 '||
                                  ',(BIL_MEASURE7-BIL_MEASURE8)/ '||
				  'ABS(DECODE(BIL_MEASURE8,0,NULL,BIL_MEASURE8)) * 100 BIL_MEASURE25 '||

                                  ',SUM(BIL_MEASURE22) OVER() BIL_MEASURE34 '||
                                  ',SUM(BIL_MEASURE22) OVER() BIL_MEASURE26 '||
                                  ',SUM(BIL_MEASURE23) OVER() BIL_MEASURE27 '||
                                  ',(SUM(BIL_MEASURE22) OVER() - SUM(BIL_MEASURE23) OVER()) / '||
                                       'ABS(DECODE(SUM(BIL_MEASURE23) OVER(), 0, NULL, '||
					'SUM(BIL_MEASURE23) OVER())) * 100 BIL_MEASURE28 '||
                                  ',(SUM(BIL_MEASURE7) OVER()- SUM(BIL_MEASURE8) OVER()) / '||
                                        'ABS(DECODE(SUM(BIL_MEASURE8) OVER(), 0, NULL, '||
					'SUM(BIL_MEASURE8) OVER())) * 100 BIL_MEASURE29 '||
                                  ',BIL_MEASURE7 BIL_MEASURE32 '||
                                  ',SUM(BIL_MEASURE7) OVER() BIL_MEASURE33 '||
                                  ',BIL_URL1,BIL_URL2'||
               ',DECODE('''||l_curr_as_of_date||''',TRUNC(SYSDATE),
                        DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                               DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=PIPELINE'''||'),
                               DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=PIPELINE'''||')),
                       NULL) BIL_URL3 ';


/*
         CASE l_page_period_type
        WHEN 'FII_TIME_ENT_YEAR' THEN
             l_pipe := 'pipeline_amt_year'||l_currency_suffix;
             l_wtd_pipe := 'wtd_pipeline_amt_year'||l_currency_suffix;

        WHEN 'FII_TIME_ENT_QTR' THEN
            l_pipe := 'pipeline_amt_quarter'||l_currency_suffix;
            l_wtd_pipe := 'wtd_pipeline_amt_quarter'||l_currency_suffix;

        WHEN 'FII_TIME_ENT_PERIOD' THEN
             l_pipe := 'pipeline_amt_period'||l_currency_suffix;
             l_wtd_pipe := 'wtd_pipeline_amt_period'||l_currency_suffix;
        ELSE
            --week
            l_pipe := 'pipeline_amt_week'||l_currency_suffix;
            l_wtd_pipe := 'wtd_pipeline_amt_week'||l_currency_suffix;
        END CASE;
*/

l_pipe :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => NULL,
                                     p_column_type => 'P',
                                     p_curr_suffix    => l_currency_suffix
				    );

l_wtd_pipe :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => NULL,
                                     p_column_type => 'W',
                                     p_curr_suffix    => l_currency_suffix
				    );



            l_pb1 := '( CASE WHEN sumry.bucket_id = :l_bucket1 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb2 := '( CASE WHEN sumry.bucket_id = :l_bucket2 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb3 := '( CASE WHEN sumry.bucket_id = :l_bucket3 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb4 := '( CASE WHEN sumry.bucket_id = :l_bucket4 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb5 := '( CASE WHEN sumry.bucket_id = :l_bucket5 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb6 := '( CASE WHEN sumry.bucket_id = :l_bucket6 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb7 := '( CASE WHEN sumry.bucket_id = :l_bucket7 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb8 := '( CASE WHEN sumry.bucket_id = :l_bucket8 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb9 := '( CASE WHEN sumry.bucket_id = :l_bucket9 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';
            l_pb10 := '( CASE WHEN sumry.bucket_id = :l_bucket10 THEN sumry.'||l_wtd_pipe||'
                ELSE NULL END
                ) ' || ' ';





/*
       l_inner_select := 'SORT_ORDER '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                ' THEN '|| l_pipe ||
                                ' ELSE NULL '||
                                'END) BIL_MEASURE22 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_prev_date '||
                                ' THEN '|| l_pipe ||
                                ' ELSE NULL '||
                                ' END) BIL_MEASURE23 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                'THEN '|| l_pb1 ||
                                ' ELSE NULL '||
                                'END) BIL_MEASURE2_B1 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                'THEN '|| l_pb2 ||
                                ' ELSE NULL '||
                                'END) BIL_MEASURE2_B2 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_pb3 ||
                                 ' ELSE NULL '||
                                 'END) BIL_MEASURE2_B3 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_pb4 ||
                                 ' ELSE NULL '||
                                 'END) BIL_MEASURE2_B4 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_pb5 ||
                                 ' ELSE NULL '||
                                 'END) BIL_MEASURE2_B5 '||
                                                        ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_pb6 ||
                                 ' ELSE NULL '||
                                 'END) BIL_MEASURE2_B6 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_pb7 ||
                                 ' ELSE NULL '||
                                 'END) BIL_MEASURE2_B7 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_pb8 ||
                                 'ELSE NULL '||
                                 'END) BIL_MEASURE2_B8 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_pb9 ||
                                 ' ELSE NULL '||
                                 'END) BIL_MEASURE2_B9 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_pb10 ||
                                 ' ELSE NULL '||
                                 'END) BIL_MEASURE2_B10 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snap_date '||
                                 'THEN '|| l_wtd_pipe
                                  ||'
                                  ELSE NULL '||
                                 'END) BIL_MEASURE7 '||
                            ', SUM(CASE WHEN sumry.snap_date = :l_prev_date '||
                                 'THEN '|| l_wtd_pipe ||'
                                  ELSE NULL '||
                                 'END) BIL_MEASURE8 ';
*/

l_pipe_select1 := 'SORT_ORDER '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                                ' THEN '|| l_pipe ||
                                ' ELSE NULL '||
                                'END) BIL_MEASURE22 ';



IF (l_open_mv_new =  'BIL_BI_PIPE_MV') THEN
   l_pipe_select2 := ',SUM(CASE WHEN sumry.snap_date = :l_prev_snap_date '||
                                ' THEN '|| l_pipe ||
                                ' ELSE NULL '||
                                ' END) BIL_MEASURE23 ';
ELSE
   l_pipe_select2 := ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                                ' THEN '|| l_pipe_amt ||
                                ' ELSE NULL '||
                                ' END) BIL_MEASURE23 ';
END IF;


l_pipe_select3 :=  ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                   'THEN '|| l_pb1 ||
                   ' ELSE NULL '||
                   'END) BIL_MEASURE2_B1 '||
               ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                   'THEN '|| l_pb2 ||
                   ' ELSE NULL '||
                   'END) BIL_MEASURE2_B2 '||
               ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                    'THEN '|| l_pb3 ||
                    ' ELSE NULL '||
                    'END) BIL_MEASURE2_B3 '||
               ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                    'THEN '|| l_pb4 ||
                    ' ELSE NULL '||
                    'END) BIL_MEASURE2_B4 '||
               ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                    'THEN '|| l_pb5 ||
                    ' ELSE NULL '||
                    'END) BIL_MEASURE2_B5 '||
                ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                    'THEN '|| l_pb6 ||
                    ' ELSE NULL '||
                    'END) BIL_MEASURE2_B6 '||
               ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                    'THEN '|| l_pb7 ||
                    ' ELSE NULL '||
                    'END) BIL_MEASURE2_B7 '||
               ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                    'THEN '|| l_pb8 ||
                    'ELSE NULL '||
                    'END) BIL_MEASURE2_B8 '||
               ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                    'THEN '|| l_pb9 ||
                    ' ELSE NULL '||
                    'END) BIL_MEASURE2_B9 '||
               ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                    'THEN '|| l_pb10 ||
                    ' ELSE NULL '||
                                 'END) BIL_MEASURE2_B10 '||
                            ',SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                                 'THEN '|| l_wtd_pipe
                                  ||'
                                  ELSE NULL '||
                                 'END) BIL_MEASURE7 ';

IF (l_open_mv_new =  'BIL_BI_PIPE_MV') THEN
   l_pipe_select4 :=     ', SUM(CASE WHEN sumry.snap_date = :l_prev_snap_date '||
                                 'THEN '|| l_wtd_pipe ||'
                                  ELSE NULL '||
                                 'END) BIL_MEASURE8 ';
ELSE
   l_pipe_select4 :=     ', SUM(CASE WHEN sumry.snap_date = :l_snapshot_date '||
                                 'THEN '|| l_wt_pipe_amt ||'
                                  ELSE NULL '||
                                 'END) BIL_MEASURE8 ';
END IF;


/*
l_pipe_select4 :=     ', SUM(CASE WHEN sumry.snap_date = :l_prev_snap_date '||
                                 'THEN '|| l_wt_pipe_amt ||'
                                  ELSE NULL '||
                                 'END) BIL_MEASURE8 ';
*/


          l_inner_select := l_pipe_select1 ||
                            l_pipe_select2 ||
                            l_pipe_select3 ||
                            l_pipe_select4 ;


/*
          l_inner_where_clause := ' AND sumry.snap_date IN (:l_snap_date,:l_prev_date)';

*/

IF (l_open_mv_new =  'BIL_BI_PIPE_MV') THEN
   l_inner_where_clause := ' AND  sumry.snap_date in (:l_snapshot_date, :l_prev_snap_date) ';
ELSE
   l_inner_where_clause := '  AND sumry.snap_date in (:l_snapshot_date) ';
END IF;


	  BIL_BI_UTIL_PKG.GET_PC_NOROLLUP_WHERE_CLAUSE(
                                          p_prodcat      => l_prodcat,
                                          p_viewby       => l_viewby,
                                          x_denorm       => l_pipe_denorm,
                                          x_where_clause => l_pipe_product_where_clause);



          l_url := 'pFunctionName='||l_rpt_str||'&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
--        l_sumry := ' bil_bi_pipe_mv ';
          l_sumry := l_open_mv_new ;




          CASE l_viewby
               WHEN 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN

                    IF 'All' = l_prodcat THEN
                       l_pipe_product_where_clause := ' AND sumry.grp_total_flag = 1 ';

		    		ELSE
			   			l_pipe_product_where_clause := l_pipe_product_where_clause||' AND sumry.grp_total_flag = 0 ';
                    END IF;


   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                  FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                 MODULE => g_pkg || l_proc || 'Sales grp view by',
		                 MESSAGE => ' Product where clause '||l_pipe_product_where_clause);

   END IF;

                    IF l_resource_id IS NULL THEN


					l_outer_select := l_outer_select ||
					'
					FROM ( SELECT NVL(restl.resource_name,grptl.group_name) VIEWBY
					,(CASE WHEN restl.resource_id IS NULL THEN 1 ELSE 2 END) SORT_ORDER
					,BIL_MEASURE22,BIL_MEASURE23,BIL_MEASURE2_B1,BIL_MEASURE2_B2,BIL_MEASURE2_B3
					,BIL_MEASURE2_B4,BIL_MEASURE2_B5,BIL_MEASURE2_B6,BIL_MEASURE2_B7,BIL_MEASURE2_B8
					,BIL_MEASURE2_B9,BIL_MEASURE2_B10,BIL_MEASURE7, BIL_MEASURE8
					,(CASE WHEN restl.resource_id IS NULL THEN grptl.group_id ELSE restl.resource_id END) VIEWBYID
					,(CASE WHEN restl.resource_id IS NULL THEN ''' || l_url ||''' ' || ' ELSE NULL END) BIL_URL1
					,DECODE(restl.resource_id, NULL, NULL,''' ||l_drill_link||''') BIL_URL2
';




l_inner_select := REPLACE(l_inner_select, 'SORT_ORDER', 'sumry.sales_group_id, sumry.salesrep_id');

                         l_custom_sql := 'SELECT /*+ NO_MERGE */ '
							||l_inner_select||
                 ' FROM '||l_sumry||' sumry '||
                                                   l_pipe_denorm||

                                         ' WHERE sumry.parent_sales_group_id = :l_sg_id_num '||
                                                l_inner_where_clause || l_pipe_product_where_clause ||
                                          ' GROUP BY sumry.sales_group_id, sumry.salesrep_id ';


x_custom_sql := 'SELECT * FROM ( '||l_outer_select ||
					' FROM ('||l_custom_sql||') '||
					'sumry, jtf_rs_groups_tl grptl ,jtf_rs_resource_extns_tl restl
  WHERE  grptl.group_id = sumry.sales_group_id
 AND grptl.language = USERENV(''LANG'')
 AND restl.language(+) = USERENV(''LANG'')
 AND restl.resource_id(+) = sumry.salesrep_id
 )
  ORDER BY SORT_ORDER,VIEWBY)'|| l_null_rem_clause;


                    ELSE


                        l_custom_sql := 'SELECT restl.resource_name VIEWBY '||
                                             ',2 ' ||l_inner_select||
                                             ',restl.resource_id VIEWBYID '||
                                             ',NULL BIL_URL1 '||
                                             ',DECODE(restl.resource_id, NULL, NULL,'''||l_drill_link||''') BIL_URL2 '||
                                        ' FROM '||l_sumry||' sumry '||
                                                l_pipe_denorm||
                                              ',jtf_rs_resource_extns_tl restl '||
                                        ' WHERE sumry.parent_sales_group_id = :l_sg_id_num '||
                                             ' AND restl.language = USERENV(''LANG'') '||
                                             ' AND restl.resource_id = :l_resource_id '||
                                             ' AND restl.resource_id = sumry.salesrep_id '||
                                              l_inner_where_clause || l_pipe_product_where_clause ||
                                        ' GROUP BY restl.resource_id, restl.resource_name '||
                                        ' ,DECODE(restl.resource_id, NULL, NULL,'''||l_drill_link||''')    ';



			x_custom_sql := 'SELECT * FROM ( '||l_outer_select ||
					' FROM ('||l_custom_sql||') '||
					'ORDER BY SORT_ORDER,VIEWBY)'|| l_null_rem_clause;


                    END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;



                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'Query Length=>',
		                                    MESSAGE => length(l_custom_sql));

                     END IF;


               WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN

			l_pipe_product_where_clause := l_pipe_product_where_clause||' AND sumry.grp_total_flag = 0 ';


                         IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                              FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                             MODULE => g_pkg || l_proc || ' Prod cat view by.Product where clause  ',
		                                             MESSAGE => l_pipe_product_where_clause);

                         END IF;


		IF l_parent_sales_group_id IS NULL THEN
                IF l_resource_id IS NULL THEN
			  	l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id IS NULL ';
                ELSE
                l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id = :l_sg_id_num ';
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


                    IF 'All' = l_prodcat THEN
		       l_unassigned_value := BIL_BI_UTIL_PKG.GET_UNASSIGNED_PC;
                       l_custom_sql := 'SELECT NULL VIEWBY '||
                                             ', 1 '||l_inner_select||
                                             ',pcd.parent_id VIEWBYID '||
                                             ',NULL BIL_URL1 '||
                                             ',NULL BIL_URL2 '||
                                        'FROM '||l_sumry||' sumry'||
                                              l_pipe_denorm||
                                         ' WHERE sumry.sales_group_id = :l_sg_id_num '||
                                           		l_parent_sls_grp_where_clause ||
							l_inner_where_clause ||
							l_pipe_product_where_clause;

                       IF l_resource_id IS NULL THEN
                          l_custom_sql := l_custom_sql ||' AND sumry.salesrep_id IS NULL ';
                       ELSE
                          l_custom_sql := l_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
                       END IF;

                       l_custom_sql := l_custom_sql ||' GROUP BY pcd.parent_id';
		       l_pc_select := ' SELECT
			 decode(sumry.viewbyid, -1,:l_unassigned_value,
 				mtl.DESCRIPTION || '' ('' || mtl.CATEGORY_CONCAT_SEGS ||'')'') VIEWBY
			,SORT_ORDER
			,SUM(BIL_MEASURE22) BIL_MEASURE22
			,SUM(BIL_MEASURE23) BIL_MEASURE23
			,SUM(BIL_MEASURE2_B1) BIL_MEASURE2_B1
			,SUM(BIL_MEASURE2_B2) BIL_MEASURE2_B2
			,SUM(BIL_MEASURE2_B3) BIL_MEASURE2_B3
			,SUM(BIL_MEASURE2_B4) BIL_MEASURE2_B4
			,SUM(BIL_MEASURE2_B5) BIL_MEASURE2_B5
            ,SUM(BIL_MEASURE2_B6) BIL_MEASURE2_B6
            ,SUM(BIL_MEASURE2_B7) BIL_MEASURE2_B7
            ,SUM(BIL_MEASURE2_B8) BIL_MEASURE2_B8
            ,SUM(BIL_MEASURE2_B9) BIL_MEASURE2_B9
            ,SUM(BIL_MEASURE2_B10) BIL_MEASURE2_B10
			,SUM(BIL_MEASURE7) BIL_MEASURE7
			,SUM(BIL_MEASURE8) BIL_MEASURE8
            ,VIEWBYID
			,'''||l_drill_link||''' BIL_URL1,'||
		        ' DECODE(sumry.viewbyid,''-1'',NULL, '''||l_url||''' '||
                        '  ) BIL_URL2 ';

                       l_custom_sql := l_pc_select||
					' FROM ('||l_custom_sql||
                                               ') sumry, mtl_categories_v mtl '||
					' WHERE mtl.category_id (+) = sumry.viewbyid '||
					' GROUP BY SORT_ORDER,
						decode(sumry.viewbyid, -1,:l_unassigned_value,
 							mtl.DESCRIPTION || '' ('' || mtl.CATEGORY_CONCAT_SEGS ||'')''),
						VIEWBYID, BIL_URL1, BIL_URL2 ';


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'Query Length for View By '|| l_viewby,
		                                    MESSAGE => ' Length => '|| LENGTH('SELECT * FROM ( '||l_outer_select ||
					   		' FROM ('||l_custom_sql||') '||
							' ORDER BY SORT_ORDER,UPPER(VIEWBY))'|| l_null_rem_clause));
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


		       x_custom_sql := 'SELECT * FROM ( '||l_outer_select ||
					   		' FROM ('||l_custom_sql||') '||
							' ORDER BY SORT_ORDER,UPPER(VIEWBY))'|| l_null_rem_clause;



                    ELSE -- Product category selected

                     l_cat_assign := bil_bi_util_pkg.getLookupMeaning(p_lookuptype => 'BIL_BI_LOOKUPS'
                                                                          ,p_lookupcode => 'ASSIGN_CATEG');

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || ' Product cat is not all ',
		                                    MESSAGE => ' Product cat '||l_prodcat);

                     END IF;


                          l_inter_select := ' SELECT VIEWBY '||
                                                   ',SORT_ORDER '||
                                                   ',SUM(BIL_MEASURE22) BIL_MEASURE22 '||
                                                   ',SUM(BIL_MEASURE23) BIL_MEASURE23 '||
                                                   ',SUM(BIL_MEASURE2_B1) BIL_MEASURE2_B1 '||
                                                   ',SUM(BIL_MEASURE2_B2) BIL_MEASURE2_B2 '||
                                                   ',SUM(BIL_MEASURE2_B3) BIL_MEASURE2_B3 '||
                                                   ',SUM(BIL_MEASURE2_B4) BIL_MEASURE2_B4 '||
                                                   ',SUM(BIL_MEASURE2_B5) BIL_MEASURE2_B5 '||
                                                   ',SUM(BIL_MEASURE2_B6) BIL_MEASURE2_B6 '||
                                                   ',SUM(BIL_MEASURE2_B7) BIL_MEASURE2_B7 '||
                                                   ',SUM(BIL_MEASURE2_B8) BIL_MEASURE2_B8 '||
                                                   ',SUM(BIL_MEASURE2_B9) BIL_MEASURE2_B9 '||
                                                   ',SUM(BIL_MEASURE2_B10) BIL_MEASURE2_B10 '||
                                                   ',SUM(BIL_MEASURE7) BIL_MEASURE7 '||
                                                   ',SUM(BIL_MEASURE8) BIL_MEASURE8 '||
                                                   ',VIEWBYID '||
                                                   ',  BIL_URL1 '||
                                                   ',BIL_URL2 ';

                          l_custom_sql := l_inter_select ||
                                           'FROM '||
                                           '(SELECT DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',
                                            :l_cat_assign, pcd.value), pcd.value) VIEWBY
                                            ,DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', 1, 2), 2)  '||
                                                   ' '||l_inner_select||
                                                  ',pcd.id VIEWBYID '||
 ', decode(sumry.item_id, ''-1'', decode(pcd.parent_id, pcd.id,NULL,'''||l_drill_link||'''),'''||l_drill_link||''')  BIL_URL1 '||
                                                  ',DECODE(pcd.parent_id, pcd.id, NULL, '''||l_url||''') '||
													   ' BIL_URL2 '||
                                                 'FROM '||l_sumry||' sumry '||
                                                      l_pipe_denorm||
                                               ' WHERE sumry.sales_group_id = :l_sg_id_num '||
						l_parent_sls_grp_where_clause||
						l_pipe_product_where_clause ||
						l_inner_where_clause;

                          IF l_resource_id IS NULL THEN
                             l_custom_sql := l_custom_sql ||' AND sumry.salesrep_id IS NULL ';
                          ELSE
                             l_custom_sql := l_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
                          END IF;

                          l_custom_sql := l_custom_sql ||
                                          ' GROUP BY DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',
                                            :l_cat_assign, pcd.value), pcd.value)
                                            ,DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', 1, 2), 2)
,decode(sumry.item_id, ''-1'', decode(pcd.parent_id, pcd.id,NULL,'''||l_drill_link||'''),'''||l_drill_link||''')
                                                    ,pcd.id '||
                                                  ',DECODE(pcd.parent_id, pcd.id, NULL, '''||l_url||''') ';

                          l_custom_sql := l_custom_sql||' ) GROUP BY SORT_ORDER,VIEWBY,VIEWBYID,BIL_URL1,BIL_URL2';


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| 'Query populating temp table ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


                                         /* The MV contains the value with item_is NULL and item_id -1 for any given product
			 category.The -1 signifies the 'Assigned to category' value and NULL the rolled up value
			 which __includes__ the 'Assigned to category' value as well. Hence we first we pick up
			 the'Assigned to category' row and then in the 2nd part of the 'Union all'
			 substract the 'Assigned to category'value from the value corresponding to the
			 item_id is NULL row. If that turns up to be 0 we dont have to show that row,
			 since that implies that the 'Assig..' row has rolled up. But the value itself
			 could be 0, to detect that we use the ROWNUM logic */


		x_custom_sql := 'SELECT * FROM ( '||l_outer_select ||
					' FROM ('||l_custom_sql||') '||
					'ORDER BY SORT_ORDER,VIEWBY)'|| l_null_rem_clause;

                    END IF;

               END CASE;


               x_custom_sql := REPLACE(x_custom_sql,'   ',' ');
               x_custom_sql := REPLACE(x_custom_sql,'   ',' ');
               x_custom_sql := REPLACE(x_custom_sql,'   ',' ');
               x_custom_sql := REPLACE(x_custom_sql,'  ',' ');
               x_custom_sql := REPLACE(x_custom_sql,'  ',' ');


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
			MODULE => g_pkg || l_proc ||'.'|| ' Query ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


               /* Binds */

               x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
               l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

               l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
               l_custom_rec.attribute_value := l_viewby;
               x_custom_attr.Extend();
               x_custom_attr(1):=l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               l_custom_rec.attribute_name := ':l_snap_date';
               l_custom_rec.attribute_value := TO_CHAR(l_snap_date,'DD/MM/YYYY');
               l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               x_custom_attr.Extend();
               x_custom_attr(l_bind_ctr) := l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               l_custom_rec.attribute_name := ':l_snapshot_date';
               l_custom_rec.attribute_value := TO_CHAR(l_snapshot_date,'DD/MM/YYYY');
               l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               x_custom_attr.Extend();
               x_custom_attr(l_bind_ctr) := l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               l_custom_rec.attribute_name := ':l_prev_snap_date';
               l_custom_rec.attribute_value := TO_CHAR(l_prev_snap_date,'DD/MM/YYYY');
               l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               x_custom_attr.Extend();
               x_custom_attr(l_bind_ctr) := l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               l_custom_rec.attribute_name := ':l_prev_date';
               l_custom_rec.attribute_value := TO_CHAR(l_prev_date,'DD/MM/YYYY');
               l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               x_custom_attr.Extend();
               x_custom_attr(l_bind_ctr) := l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               l_custom_rec.attribute_name := ':l_period_type';
               l_custom_rec.attribute_value := l_period_type;
               l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               x_custom_attr.Extend();
               x_custom_attr(l_bind_ctr) := l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               l_custom_rec.attribute_name := ':l_conv_rate_selected';
               l_custom_rec.attribute_value := l_conv_rate_selected;
               l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               x_custom_attr.Extend();
               x_custom_attr(l_bind_ctr) := l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               l_custom_rec.attribute_name := ':l_sg_id_num';
               l_custom_rec.attribute_value := l_sg_id_num;
               l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               x_custom_attr.Extend();
               x_custom_attr(l_bind_ctr) := l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               IF l_parent_sales_group_id IS NOT NULL THEN
	       	l_custom_rec.attribute_name := ':l_parent_sales_group_id';
               	l_custom_rec.attribute_value := l_parent_sales_group_id;
               	l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
               	l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               	x_custom_attr.Extend();
               	x_custom_attr(l_bind_ctr) := l_custom_rec;
               	l_bind_ctr := l_bind_ctr+1;
	       END IF;

               IF l_resource_id IS NOT NULL THEN
                  l_custom_rec.attribute_name := ':l_resource_id';
                  l_custom_rec.attribute_value := l_resource_id;
                  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
                  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                  x_custom_attr.Extend();
                  x_custom_attr(l_bind_ctr) := l_custom_rec;
                  l_bind_ctr := l_bind_ctr+1;
               END IF;

               l_custom_rec.attribute_name := ':l_yes';
               l_custom_rec.attribute_value := 'Y';
               l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
               l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
               x_custom_attr.Extend();
               x_custom_attr(l_bind_ctr) := l_custom_rec;
               l_bind_ctr := l_bind_ctr+1;

               IF l_prodcat IS NOT NULL THEN
                  l_custom_rec.attribute_name := ':l_prodcat';
                  l_custom_rec.attribute_value := l_prodcat;
                  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
                  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                  x_custom_attr.Extend();
                  x_custom_attr(l_bind_ctr) := l_custom_rec;
                  l_bind_ctr := l_bind_ctr+1;

              END IF;
	      l_custom_rec.attribute_name :=':l_unassigned_value';
           	  l_custom_rec.attribute_value :=l_unassigned_value;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;

		      l_custom_rec.attribute_name :=':l_cat_assign';
           	  l_custom_rec.attribute_value :=l_cat_assign;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;

		   l_custom_rec.attribute_name :=':l_bucket1';
           	  l_custom_rec.attribute_value :=l_bucket1;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;

		  l_custom_rec.attribute_name :=':l_bucket2';
           	  l_custom_rec.attribute_value :=l_bucket2;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;

		 l_custom_rec.attribute_name :=':l_bucket3';
           	  l_custom_rec.attribute_value :=l_bucket3;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;

	     l_custom_rec.attribute_name :=':l_bucket4';
           	  l_custom_rec.attribute_value :=l_bucket4;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;
		 l_custom_rec.attribute_name :=':l_bucket5';
           	  l_custom_rec.attribute_value :=l_bucket5;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;
		 l_custom_rec.attribute_name :=':l_bucket6';
           	  l_custom_rec.attribute_value :=l_bucket6;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;
		l_custom_rec.attribute_name :=':l_bucket7';
           	  l_custom_rec.attribute_value :=l_bucket7;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;
		 l_custom_rec.attribute_name :=':l_bucket8';
           	  l_custom_rec.attribute_value :=l_bucket8;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;
		 l_custom_rec.attribute_name :=':l_bucket9';
           	  l_custom_rec.attribute_value :=l_bucket9;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;
		 l_custom_rec.attribute_name :=':l_bucket10';
           	  l_custom_rec.attribute_value :=l_bucket10;
           	  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           	  l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           	  x_custom_attr.Extend();
           	  x_custom_attr(l_bind_ctr):=l_custom_rec;
           	  l_bind_ctr:=l_bind_ctr+1;

       ELSE --Invalid parameters
           BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                            ,x_sqlstr    => x_custom_sql);




            FOR i IN 1..l_buckets
                LOOP
                    l_default_query1 := l_default_query1 || 'null BIL_MEASURE2_B'||i ||',';
                    l_default_query2 := l_default_query2 || 'null BIL_MEASURE12_B'||i || ',';
	            END LOOP;



            x_custom_sql := REPLACE(x_custom_sql, 'null BIL_MEASURE2,', l_default_query1);
            x_custom_sql := REPLACE(x_custom_sql, 'null BIL_MEASURE12,', l_default_query2);

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
               fnd_message.set_token('ERRNO',SQLCODE);
               fnd_message.set_token('REASON',SQLERRM);
               fnd_message.set_token('ROUTINE',l_proc);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
                                                MODULE => g_pkg || l_proc,
		                                MESSAGE => fnd_message.get );

            END IF;

            RAISE;


 END BIL_BI_WTD_PIPELINE;

 /*******************************************************************************
 * Name    : Procedure BIL_BI_TOP_OPEN_OPP
 * Author  : Prasanna Patil
 * Date    : June 16, 2003
 * Purpose : Top Open Opportunities Report.
 *
 *           Copyright (c) 2003 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl     PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 * Date                 Author                     Description
 * ----                 ------                     -----------
 * 06/16/03             ppatil                     Initial version
 * 04 Jul 2003          krsundar                   B ind variables and logging
 * 24 Dec 2003			ppatil					   stubbed out
 *
 ******************************************************************************/

  PROCEDURE BIL_BI_TOP_OPEN_OPP( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                ,x_custom_sql         OUT NOCOPY VARCHAR2
                                ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
 IS
 BEGIN
    NULL;
 END BIL_BI_TOP_OPEN_OPP;

/*******************************************************************************
 * Name    : Procedure BIL_BI_TOP_OPEN_OPP_PORTLET
 * Author  : Prasanna Patil
 * Date    : June 16, 2003
 * Purpose : Top Open Opportunities Report for Portlet Report
 *
 *           Copyright (c) 2003 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl     PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 * Date                 Author                     Description
 * ----                 ------                     -----------
 * 09/28/03             ppatil                     Initial version
 * 12/24/2003			ppatil					    Stubbed out.
 ******************************************************************************/

  PROCEDURE BIL_BI_TOP_OPEN_OPP_PORTLET( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                ,x_custom_sql         OUT NOCOPY VARCHAR2
                                ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
 IS
  BEGIN
   NULL;
  END BIL_BI_TOP_OPEN_OPP_PORTLET;

 /*******************************************************************************
 * Name    : Procedure BIL_BI_OPPTY_ACTIVITY
 * Author  : Prasanna Patil
 * Date    : July 01, 2002
 * Purpose : Sales Overview Sales Intelligence report and charts.
 *
 *           Copyright (c) 2002 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 *
 * Date     Author      Description
 * ----     ------      -----------
 * 07/01/03 ppatil     	Intial Version - Procedure for Opportunity Activity (DBI 6.0)
 * 05 Feb 2004 krsundar Change as per the new MV structure
 * 09 Feb 2004 krsundar Removed product references
 * 25 Feb 2004 krsundar Uptake fii_time_structures, Pipeline get_Latest_Snap_Date uptake,
 *                      Period start open defn. change uptake
 * 25 Mar 2004 krsundar Drill and pivot fix
 * 26 Nov 2004 hrpandey Drill Down to Oppty Line Detail report
 ******************************************************************************/


PROCEDURE BIL_BI_OPPTY_ACTIVITY (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                ,x_custom_sql         OUT NOCOPY VARCHAR2
                                ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_comp_type                 VARCHAR2(50);
    l_bitand_id                 VARCHAR2(50);
    l_calendar_id               VARCHAR2(50);
    l_period_type               VARCHAR2(50);
    l_sg_id                     VARCHAR2(50);
    l_conv_rate_selected        VARCHAR2(50);
    l_page_period_type          VARCHAR2(50);
    l_fii_struct                VARCHAR2(50);
    l_fst_crdt_type             VARCHAR2(50);
    l_viewby                    VARCHAR2(80);
    l_item_org                  VARCHAR2(80);
    l_prodcat_id                VARCHAR2(50);
    l_prodcat                   VARCHAR2(50);
    l_sql_error_desc            VARCHAR2(4000);
    l_open_where_clause         VARCHAR2(1000);
    l_xtd_where_clause          VARCHAR2(1000);
    l_assicat_where             VARCHAR2(1000);
    l_product_where_clause      VARCHAR2(1000);
    l_product_where_op          VARCHAR2(1000);
    l_null_rem_clause           VARCHAR2(1000);
    l_outer_select              VARCHAR2(8000);
    l_others_select             VARCHAR2(8000);
    l_open_select               VARCHAR2(8000);
    l_inner_select              VARCHAR2(8000);
    l_pc_inner_select		VARCHAR2(8000);
    l_custom_sql                VARCHAR2(32000);
    l_insert_stmt               VARCHAR2(2000);
    l_url                       VARCHAR2(1000);
    l_cat_assign                VARCHAR2(1000);
    l_others_mv                 VARCHAR2(50);
    l_open_mv                   VARCHAR2(50);
    l_denorm                    VARCHAR2(100);
    l_resource_id               VARCHAR2(20);
    l_curr_as_of_date           DATE;
    l_snap_date                 DATE;
    l_prev_date                 DATE;
    l_start_date                DATE;
    l_bis_sysdate               DATE;
    l_curr_page_time_id         NUMBER;
    l_prev_page_time_id         NUMBER;
    l_record_type_id            NUMBER;
    l_sg_id_num                 NUMBER;
    l_bind_ctr                  NUMBER;
    l_parameter_valid           BOOLEAN;
    l_region_id                 VARCHAR2(50);
    l_proc                      VARCHAR2(100);
    l_rpt_str                   VARCHAR2(80);
    l_yes			VARCHAR2(1);
    l_parent_sales_group_id	NUMBER;
    l_parent_sls_grp_where_clause	VARCHAR2(1000);
    l_pipe_product_where_clause	VARCHAR2(1000);
    l_pipe_denorm               VARCHAR2(100);
    l_prodcat_sel		VARCHAr2(100);
    l_unassigned_value          VARCHAR2(1000);
    l_pc_sel			VARCHAR2(200);
    l_currency_suffix           VARCHAR2(5);
    l_drill_link                    VARCHAR2(4000);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

    l_prev_amt               VARCHAR2(1000);
    l_column_type            VARCHAR2(1000);
    l_snapshot_date          DATE;
    l_start_date_new          DATE;
    l_open_mv_new            VARCHAR2(1000);
    l_open_mv_new1           VARCHAR2(1000);
    l_prev_snap_date         DATE;
    l_pipe_select1           varchar2(4000);
    l_pipe_select2           varchar2(4000);
    l_pipe_select3           varchar2(4000);
    l_inner_where_pipe       varchar2(4000);


  BEGIN
	  /* Initializing Variables */
	  g_pkg := 'bil.patch.115.sql.BIL_BI_OPPTY_MGMT_RPTS_PKG_PT.';
	  l_parameter_valid := FALSE;
--      l_open_req := TRUE;
	  l_yes := 'Y';
      l_region_id := 'BIL_BI_OPPTY_ACTIVITY';
      l_proc := 'BIL_BI_OPPTY_ACTIVITY.';
      l_rpt_str := 'BIL_BI_OPACTY_R';
      g_sch_name := 'BIL';

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;


      x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

      BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl => p_page_parameter_tbl
                                     ,p_region_id          => l_region_id
                                     ,x_period_type        => l_period_type
                                     ,x_conv_rate_selected => l_conv_rate_selected
                                     ,x_sg_id              => l_sg_id
				     ,x_parent_sg_id	   => l_parent_sales_group_id
                                     ,x_resource_id        => l_resource_id
                                     ,x_prodcat_id         => l_prodcat_id
                                     ,x_curr_page_time_id  => l_curr_page_time_id
                                     ,x_prev_page_time_id  => l_prev_page_time_id
                                     ,x_comp_type          => l_comp_type
                                     ,x_parameter_valid    => l_parameter_valid
                                     ,x_as_of_date         => l_curr_as_of_date
                                     ,x_page_period_type   => l_page_period_type
                                     ,x_prior_as_of_date   => l_prev_date
                                     ,x_record_type_id     => l_record_type_id
                                     ,x_viewby             => l_viewby);


/*
      BIL_BI_UTIL_PKG.GET_LATEST_SNAP_DATE(p_page_parameter_tbl  => p_page_parameter_tbl
                                           ,p_as_of_date         => l_curr_as_of_date
                                           ,p_period_type        => NULL
                                           ,x_snapshot_date      => l_snap_date);
*/
  /*    IF l_snap_date IS NULL THEN
         l_open_req := FALSE;
      END IF;*/


      IF l_parameter_valid THEN
         BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id   => l_bitand_id
                                         ,x_calendar_id => l_calendar_id
                                         ,x_curr_date   => l_bis_sysdate
                                         ,x_fii_struct  => l_fii_struct);

          IF l_conv_rate_selected = 0 THEN
                l_currency_suffix := '_s';
          ELSE
                l_currency_suffix := '';
          END IF;


        IF l_prodcat_id IS NOT NULL THEN
            l_prodcat := TO_NUMBER(REPLACE(l_prodcat_id,''''));
         END IF;

         l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
         l_resource_id := TO_NUMBER(REPLACE(l_resource_id, ''''));

         IF l_prodcat_id IS NULL THEN
            l_prodcat := 'All';
         END IF;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => ' Product Cat => '||l_prodcat);

                     END IF;



		 l_url := 'pFunctionName='||l_rpt_str||'&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';

         --For Period start open
         IF l_period_type = 16 THEN
            l_start_date := FII_TIME_API.cwk_start(l_curr_as_of_date);
         ELSIF l_period_type = 32 THEN
            l_start_date := FII_TIME_API.ent_cper_start(l_curr_as_of_date);
         ELSIF l_period_type = 64 THEN
            l_start_date := FII_TIME_API.ent_cqtr_start(l_curr_as_of_date);
         ELSIF l_period_type = 128 THEN
            l_start_date := FII_TIME_API.ent_cyr_start(l_curr_as_of_date);
         END IF;


-- Get the Drill Link to the Opty Line Detail Report

l_drill_link := bil_bi_util_pkg.get_drill_links( p_view_by =>  l_viewby,
                                                 p_salesgroup_id =>   l_sg_id,
                                                 p_resource_id   =>    l_resource_id  );



/* Use the  BIL_BI_UTIL_PKG.GET_PIPE_MV proc to get the MV name and snap date for Pipeline/Open Amts. */

-- This API calll is to find whether Period Start_date lies in Current or Historical range.

     BIL_BI_UTIL_PKG.GET_PIPE_MV(
                                     p_asof_date  => l_start_date ,
                                     p_period_type  => l_page_period_type ,
                                     p_compare_to  =>  l_comp_type  ,
                                     p_prev_date  => l_prev_date,
                                     p_page_parameter_tbl => p_page_parameter_tbl,
                                     x_pipe_mv    => l_open_mv_new1 ,
                                     x_snapshot_date => l_snapshot_date  ,
                                     x_prev_snap_date  => l_prev_snap_date
				    );

-- This API calll is to find the snapshot date based on the l_asof_date.

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


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

		     		 l_sql_error_desc := 'l_viewby => '||l_viewby||', '||
                                'l_curr_page_time_id => '|| l_curr_page_time_id ||', ' ||
                                'l_prev_page_time_id => '|| l_prev_page_time_id ||', ' ||
                                'l_curr_as_of_date => '|| l_curr_as_of_date ||', ' ||
                                'l_snapshot_date => '|| l_snapshot_date ||', ' ||
                                'l_prev_snap_date => '|| l_prev_snap_date ||', ' ||
                                'l_conv_rate_selected => '|| l_conv_rate_selected ||', ' ||
                                'l_bitand_id => '|| l_bitand_id ||', ' ||
                                'l_period_type => '|| l_period_type ||', ' ||
                                'l_sg_id_num => '|| l_sg_id ||', ' ||
				'l_parent_sales_group_id => '|| l_parent_sales_group_id||', ' ||
                                'l_calendar_id => '|| l_calendar_id ||', '||
                                'l_record_type_id => '||l_record_type_id;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'Param values ' ,
		                                    MESSAGE => 'Param values '||l_sql_error_desc);

                     END IF;



EXECUTE IMMEDIATE
 'SELECT end_date FROM FII_TIME_WEEK  WHERE :l_start_date BETWEEN start_date AND end_date '
INTO l_start_date_new  USING l_start_date ;



IF (l_open_mv_new1 =  'BIL_BI_PIPE_G_MV') THEN
   l_start_date := l_start_date_new;
END IF;



         /*Mappings...
          * BIL_MEASURE1 Period start open
          * BIL_MEASURE2 New for period
          * BIL_MEASURE3 Won
          * BIL_MEASURE4 Lost
          * BIL_MEASURE5 No opportunity
          * BIL_MEASURE6 Current Open
          * BIL_MEASURE7 Adjustments
          * BIL_MEASURE8 to BIL_MEASURE14 Grand totals
          *  BIL_URL3    URL to Drill to the Opty Line Detail rep from Won Column
          *  BIL_URL4    URL to Drill to the Opty Line Detail rep from Lost Column
          *  BIL_URL5    URL to Drill to the Opty Line Detail rep from No opportunity Column
          */

         l_outer_select :=  'SELECT VIEWBY ';
          IF 'ORGANIZATION+JTF_ORG_SALES_GROUP' = l_viewby THEN
              l_outer_select := l_outer_select ||
			  		',DECODE(BIL_URL1,NULL,VIEWBYID||''.''||:l_sg_id_num,VIEWBYID) VIEWBYID ';
          ELSE
              l_outer_select := l_outer_select ||',VIEWBYID ';
          END IF;
          l_outer_select := l_outer_select ||
		                   ',NVL(BIL_MEASURE28,0) BIL_MEASURE1
                            ,NVL(BIL_MEASURE2,0) BIL_MEASURE2
                            ,NVL(BIL_MEASURE3,0) BIL_MEASURE3
                            ,NVL(BIL_MEASURE4,0) BIL_MEASURE4
                            ,NVL(BIL_MEASURE5,0) BIL_MEASURE5
                            ,NVL(BIL_MEASURE6,0) BIL_MEASURE6
                            ,(NVL(BIL_MEASURE6,0) - ((NVL(BIL_MEASURE28,0) + NVL(BIL_MEASURE2,0))
				- (NVL(BIL_MEASURE3,0) + NVL(BIL_MEASURE4,0) + NVL(BIL_MEASURE5,0)))) BIL_MEASURE7
                            ,SUM(NVL(BIL_MEASURE28,0)) OVER() BIL_MEASURE8
                            ,SUM(NVL(BIL_MEASURE2,0)) OVER() BIL_MEASURE9
                            ,SUM(NVL(BIL_MEASURE3,0)) OVER() BIL_MEASURE10
                            ,SUM(NVL(BIL_MEASURE4,0)) OVER() BIL_MEASURE11
                            ,SUM(NVL(BIL_MEASURE5,0)) OVER() BIL_MEASURE12
                            ,SUM(NVL(BIL_MEASURE6,0)) OVER() BIL_MEASURE13
                            ,(SUM(NVL(BIL_MEASURE6,0)) OVER() - ((SUM(NVL(BIL_MEASURE28,0)) OVER()
				 + SUM(NVL(BIL_MEASURE2,0)) OVER()) - (SUM(NVL(BIL_MEASURE3,0)) OVER()
				 + SUM(NVL(BIL_MEASURE4,0)) OVER()
				 + SUM(NVL(BIL_MEASURE5,0)) OVER()))) BIL_MEASURE14
                            ,BIL_URL1
                            ,BIL_URL2
                            , DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                   DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=WON'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=WON'''||'))
                  BIL_URL3
 , DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                   DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=LOST'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=LOST'''||'))
                  BIL_URL4
 , DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                   DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=No Opportunity'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=No Opportunity'''||'))
                  BIL_URL5
,DECODE('''||l_curr_as_of_date||''',TRUNC(SYSDATE),
                        DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                               DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=OPEN'''||'),
                               DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=OPEN'''||')),
                       NULL) BIL_URL6
';

         --TMP1 does not have BIL_MEASURE1
         l_others_select := ' SORT_ORDER
                            ,NULL BIL_MEASURE28
                            ,(DECODE(:l_period_type,16,sumry.nfp_wk'||l_currency_suffix||',32,sumry.nfp_per'||l_currency_suffix||',64,sumry.nfp_qtr'||l_currency_suffix||'
                                        ,128,sumry.nfp_yr'||l_currency_suffix||')) BIL_MEASURE2
                            ,(sumry.won_opty_amt'||l_currency_suffix||') BIL_MEASURE3
                            ,(sumry.lost_opty_amt'||l_currency_suffix||') BIL_MEASURE4
                            ,(sumry.no_opty_amt'||l_currency_suffix||') BIL_MEASURE5
                            ,NULL BIL_MEASURE6 ';

         l_open_select := ' SORT_ORDER ';

   l_open_select := l_open_select ||
			',(CASE WHEN sumry.snap_date = :l_start_date THEN
				  DECODE(:l_period_type,
                                               16,sumry.open_amt_week'||l_currency_suffix||',
					       32,sumry.open_amt_period'||l_currency_suffix||',
                                               64,sumry.open_amt_quarter'||l_currency_suffix||',
                                               128,sumry.open_amt_year'||l_currency_suffix||'
                                         )
                        ELSE NULL
                  END) BIL_MEASURE28 ';

  /*          l_open_select := l_open_select ||
			',(CASE WHEN sumry.snap_date = :l_start_date THEN
					DECODE(:l_period_type,16,sumry.open_amt_week'||l_currency_suffix||',
					32,sumry.open_amt_period'||l_currency_suffix||',
                                        64,sumry.open_amt_quarter'||l_currency_suffix||'
                                             ,128,sumry.open_amt_year'||l_currency_suffix||')
                        ELSE NULL
                  END) BIL_MEASURE28 ';
*/

      l_open_select := l_open_select || ' ,NULL BIL_MEASURE2,NULL BIL_MEASURE3,NULL BIL_MEASURE4,NULL BIL_MEASURE5 ';


/*  l_open_select := l_open_select ||
	    		',(CASE WHEN sumry.snap_date = :l_snap_date THEN
			     DECODE(:l_period_type,16,sumry.open_amt_week'||l_currency_suffix||',32,sumry.open_amt_period'||l_currency_suffix||',64,sumry.open_amt_quarter'||l_currency_suffix||'
                                             ,128,sumry.open_amt_year'||l_currency_suffix||')
                                 ELSE NULL
                                 END) BIL_MEASURE6 ';
*/

         l_open_select := l_open_select ||
	    		',(CASE WHEN sumry.snap_date = :l_snapshot_date THEN
			     DECODE(:l_period_type,
                                        16,sumry.open_amt_week'||l_currency_suffix||',
                                        32,sumry.open_amt_period'||l_currency_suffix||',
                                        64,sumry.open_amt_quarter'||l_currency_suffix||',
                                        128,sumry.open_amt_year'||l_currency_suffix||'
                                    )
                                 ELSE NULL
                                 END) BIL_MEASURE6 ';

--            l_open_where_clause := ' sumry.snap_date IN (:l_snap_date,:l_start_date) ';

            l_open_where_clause := ' sumry.snap_date IN (:l_snapshot_date,:l_start_date) ';

         l_xtd_where_clause := ' sumry.effective_time_id = cal.time_id
                                   AND sumry.effective_period_type_id = cal.period_type_id
                                   AND BITAND(cal.record_type_id, :l_record_type_id) = :l_record_type_id
                                   AND cal.report_date = :l_curr_as_of_date ';


         l_insert_stmt := ' INSERT INTO BIL_BI_RPT_TMP1(VIEWBY,SORTORDER, BIL_MEASURE28, BIL_MEASURE2,
                                BIL_MEASURE3,BIL_MEASURE4,BIL_MEASURE5,BIL_MEASURE6, VIEWBYID, BIL_URL1,BIL_URL2) ';

         l_null_rem_clause := ' WHERE NOT (BIL_MEASURE28 IS NULL
                                    AND BIL_MEASURE2 IS NULL
                                    AND BIL_MEASURE3 IS NULL
                                    AND BIL_MEASURE4 IS NULL
                                    AND BIL_MEASURE5 IS NULL
                                    AND BIL_MEASURE6 IS NULL) ';

        BIL_BI_UTIL_PKG.GET_PC_NOROLLUP_WHERE_CLAUSE(
                                          p_prodcat      => l_prodcat,
                                          p_viewby       => l_viewby,
                                          x_denorm       => l_pipe_denorm,
                                          x_where_clause => l_pipe_product_where_clause);

         CASE l_viewby
            WHEN 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
	      IF 'All' = l_prodcat THEN
                 l_others_mv := 'BIL_BI_OPTY_G_MV';
--                 l_open_mv := 'BIL_BI_PIPE_G_MV';
                 l_open_mv := ' BIL_BI_PIPE_G_V ';
                 l_product_where_op := ' AND grp_total_flag = 1 ';
		 l_pc_sel :='';
              ELSE
                 l_others_mv := 'BIL_BI_OPTY_PG_MV';
--                 l_open_mv := 'BIL_BI_PIPE_G_MV';
                 l_open_mv := ' BIL_BI_PIPE_G_V ';
		 l_product_where_op := ' AND grp_total_flag = 0 ';
		 l_pc_sel := ' sumry.product_category_id product_category_id, ';
              END IF;

              IF l_resource_id IS NULL THEN
		l_custom_sql := 'SELECT /*+ LEADING(cal) */ '||
					 l_pc_sel||
		 			' sumry.sales_group_id Group_id, sumry.salesrep_id Rep_id, 1 '||
				 	 l_others_select ||
                                ' FROM '||l_fii_struct ||' cal, '||
					l_others_mv ||' sumry '||
                                ' WHERE '|| l_xtd_where_clause ||
                                        ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
                                ' UNION ALL '||
                                ' SELECT '|| l_pc_sel||
					' sumry.sales_group_id Group_id, sumry.salesrep_id Rep_id,1 '||
					l_open_select ||
                                ' FROM '|| l_open_mv ||' sumry '||
                                ' WHERE '|| l_open_where_clause ||
                                ' AND sumry.parent_sales_group_id = :l_sg_id_num '|| l_product_where_op ||' ';

                l_custom_sql := ' SELECT SUM(BIL_MEASURE28) BIL_MEASURE28,SUM(BIL_MEASURE2) BIL_MEASURE2 '||
                                       ',SUM(BIL_MEASURE3) BIL_MEASURE3,SUM(BIL_MEASURE4) BIL_MEASURE4 '||
                                       ',SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE6) BIL_MEASURE6 '||
                                       ',Group_id, Rep_id '||
                                ' FROM ('||l_custom_sql||') sumry '||l_pipe_denorm||' '||
				' WHERE 1=1 '||l_pipe_product_where_clause||' '||
                                ' GROUP BY Group_id, Rep_id ';

                l_custom_sql := 'SELECT /*+ NO_MERGE(inn) */ BIL_MEASURE28,BIL_MEASURE2,'||
								     'BIL_MEASURE3,BIL_MEASURE4,'||
										'BIL_MEASURE5,BIL_MEASURE6 '||
                     ',DECODE(restl.resource_id,NULL,grptl.group_name,restl.resource_name) VIEWBY '||
                                      ',NVL(restl.resource_id,grptl.group_id) VIEWBYID '||
                                      ',DECODE(restl.resource_id,NULL,1,2) SORTORDER '||
                                      ',DECODE(restl.resource_id,NULL,'''|| l_url ||''') BIL_URL1 '||
                                      ',DECODE(inn.rep_id, NULL, NULL,'''||l_drill_link||''') BIL_URL2  '||
                                 'FROM ( '|| l_custom_sql ||' ) inn '||
                                         ',jtf_rs_groups_tl grptl '||
                                         ',jtf_rs_resource_extns_tl restl '||
                                 'WHERE grptl.group_id = inn.group_id '||
                                       'AND restl.resource_id(+) = inn.rep_id '||
                                       'AND restl.language(+) = USERENV(''LANG'') '||
                                       'AND grptl.language = USERENV(''LANG'') ';

                 x_custom_sql := l_outer_select ||' FROM ('|| l_custom_sql ||') '|| l_null_rem_clause ||
				 						' ORDER BY SORTORDER ,UPPER(VIEWBY) ';
              ELSE

		 l_custom_sql := ' SELECT /*+ LEADING(cal) */ '||
					 l_pc_sel||
					' sumry.salesrep_id Rep_id, 1 ' ||
					l_others_select||
                                 ' FROM '||l_fii_struct ||' cal, '||
			 		 l_others_mv ||' sumry '||
                                 ' WHERE '|| l_xtd_where_clause ||
                                     ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
                                     ' AND sumry.salesrep_id = :l_resource_id '||
				     ' AND cal.xtd_flag = :l_yes '||
                                 ' UNION ALL '||
                                 ' SELECT  '||l_pc_sel||
					' sumry.salesrep_id Rep_id,1 ' ||
					l_open_select ||
                                 ' FROM '|| l_open_mv ||' sumry '||
                                 ' WHERE '|| l_open_where_clause ||
                                         'AND sumry.parent_sales_group_id = :l_sg_id_num '||l_product_where_op ||
                                         'AND sumry.salesrep_id = :l_resource_id ';

                 l_custom_sql := ' SELECT SUM(BIL_MEASURE28) BIL_MEASURE28,SUM(BIL_MEASURE2) BIL_MEASURE2 '||
                                       ',SUM(BIL_MEASURE3) BIL_MEASURE3,SUM(BIL_MEASURE4) BIL_MEASURE4 '||
                                       ',SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE6) BIL_MEASURE6 '||

                                       ', Rep_id,DECODE(rep_id, NULL, NULL,'''||l_drill_link||''') BIL_URL2 '||

                                ' FROM ('||l_custom_sql||') sumry '||l_pipe_denorm||' '||
				' WHERE 1=1 '||l_pipe_product_where_clause||' '||
                                ' GROUP BY Rep_id ';

		 l_custom_sql := 'SELECT restl.resource_name VIEWBY,restl.resource_id VIEWBYID '||
                                        ',SUM(BIL_MEASURE28) BIL_MEASURE28,SUM(BIL_MEASURE2) BIL_MEASURE2 '||
                                        ',SUM(BIL_MEASURE3) BIL_MEASURE3,SUM(BIL_MEASURE4) BIL_MEASURE4 '||
                                        ',SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE6) BIL_MEASURE6 '||
                                        ',NULL BIL_URL1, BIL_URL2 '||
                                 'FROM ('|| l_custom_sql ||') inn, '||
                                      'jtf_rs_resource_extns_tl restl '||
                                 'WHERE restl.resource_id = inn.Rep_id '||
                                       'AND restl.language = USERENV(''LANG'') '||

                                 'GROUP BY restl.resource_id, restl.resource_name  '||
                                  ' , bil_url2     ';




                 x_custom_sql := l_outer_select ||' FROM ('|| l_custom_sql ||') '|| l_null_rem_clause ||
				 				' ORDER BY UPPER(VIEWBY) ';

              END IF;

            --View by product category
            WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN

        IF l_parent_sales_group_id IS NULL THEN
            IF l_resource_id IS NULL THEN
		      l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id IS NULL ';
	      ELSE
	           l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id = sumry.sales_group_id ';
          END IF;
        ELSE
	  	    IF l_resource_id IS NULL THEN
		      l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id = :l_parent_sales_group_id ';
	    	ELSE
		      l_parent_sls_grp_where_clause := ' AND sumry.parent_sales_group_id = :l_sg_id_num ';
            END IF;
        END IF;
	      l_others_mv := ' BIL_BI_OPTY_PG_MV ';
--            l_open_mv := ' BIL_BI_PIPE_G_MV ';
              l_open_mv := ' BIL_BI_PIPE_G_V ';
              l_open_where_clause := l_open_where_clause||' AND sumry.grp_total_flag = 0 ';


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
	                                    MODULE => g_pkg || l_proc || ' Prod cat view by.Product where clause ',
		                                    MESSAGE => l_pipe_product_where_clause);

                     END IF;


              l_inner_select :=  'SELECT VIEWBY
                                         ,SORT_ORDER
                                         ,SUM(BIL_MEASURE28) BIL_MEASURE28
                                         ,SUM(BIL_MEASURE2) BIL_MEASURE2
                                         ,SUM(BIL_MEASURE3) BIL_MEASURE3
                                         ,SUM(BIL_MEASURE4) BIL_MEASURE4
                                         ,SUM(BIL_MEASURE5) BIL_MEASURE5
                                         ,SUM(BIL_MEASURE6) BIL_MEASURE6
                                         ,VIEWBYID

                                         ,BIL_URL1

                                         ,BIL_URL2 ';
	     l_pc_inner_select := 'SELECT
					decode(sumry.viewbyid, -1,:l_unassigned_value,
						 mtl.DESCRIPTION || '' ('' || mtl.CATEGORY_CONCAT_SEGS ||'')'') VIEWBY
					,SORT_ORDER
					,VIEWBYID
					,BIL_MEASURE28
					,BIL_MEASURE2
					,BIL_MEASURE3
					,BIL_MEASURE4
					,BIL_MEASURE5
					,BIL_MEASURE6
				 	,  '''||l_drill_link||'''  BIL_URL1
					,DECODE(VIEWBYID,''-1'',NULL,'''||l_url||''') BIL_URL2 ';


              IF 'All' = l_prodcat THEN

		l_unassigned_value := BIL_BI_UTIL_PKG.GET_UNASSIGNED_PC;

                x_custom_sql := l_outer_select ||
                                ' FROM ('||l_inner_select||
                                        ' FROM ( '||
					    l_pc_inner_select||
					    ' FROM ('||
					  	'SELECT
							null VIEWBY
							,SORT_ORDER
							,pcd.parent_id VIEWBYID
							,BIL_MEASURE28
							,BIL_MEASURE2
							,BIL_MEASURE3
							,BIL_MEASURE4
							,BIL_MEASURE5
							,BIL_MEASURE6
				 			,NULL BIL_URL1
							,NULL BIL_URL2
					        FROM ('||
                                              ' SELECT /*+ LEADING(cal) */ '||
                                                    '1 '||l_others_select||
						    ',sumry.product_category_id product_category_id '||
                                              'FROM ' ||l_fii_struct||' cal,'
						      ||l_others_mv||' sumry'||
                                              ' WHERE '|| l_xtd_where_clause ||
                                                    ' AND sumry.sales_group_id = :l_sg_id_num '||
						    l_parent_sls_grp_where_clause||
						    ' AND cal.xtd_flag = :l_yes ';
                IF l_resource_id IS NOT NULL THEN
                   x_custom_sql := x_custom_sql||' AND sumry.salesrep_id = :l_resource_id ';
                ELSE
                   x_custom_sql := x_custom_sql ||' AND sumry.salesrep_id IS NULL ';
                END IF;
		x_custom_sql := x_custom_sql||'
                                 UNION ALL
                                 SELECT 1 '||l_open_select||
					',sumry.product_category_id product_category_id
                                 FROM '|| l_open_mv ||' sumry'||
                               ' WHERE '|| l_open_where_clause ||
                                       ' AND sumry.sales_group_id = :l_sg_id_num '||
				       l_parent_sls_grp_where_clause;
                IF l_resource_id IS NOT NULL THEN
                   x_custom_sql := x_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
                ELSE
                   x_custom_sql := x_custom_sql ||' AND sumry.salesrep_id IS NULL ';
                END IF;
                x_custom_sql := x_custom_sql||
					') sumry '||l_pipe_denorm||' '||
				 	' WHERE 1=1 '||l_pipe_product_where_clause||
				      ') sumry,mtl_categories_v mtl '||
				      ' WHERE mtl.category_id (+) = sumry.viewbyid '||
                                   ') GROUP BY SORT_ORDER, VIEWBY, VIEWBYID, BIL_URL1, BIL_URL2
                                 ) '||l_null_rem_clause ||'
				ORDER BY SORT_ORDER, UPPER(VIEWBY)';

             --Prod cat chosen
              ELSE
                 --For 'Assigned to Category' message
                 l_cat_assign := bil_bi_util_pkg.getLookupMeaning(p_lookuptype => 'BIL_BI_LOOKUPS'
                                                                 ,p_lookupcode => 'ASSIGN_CATEG');

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || ' Product cat is not all ',
		                                    MESSAGE => ' Product cat : '||l_prodcat_id);

                     END IF;

                 l_custom_sql := l_inner_select||
                                 ' FROM
                                       (SELECT /*+ LEADING(cal) */
					       DECODE(pcd.parent_id, pcd.id,
					   	DECODE(sumry.item_id, ''-1'', :l_cat_assign, pcd.value), pcd.value) VIEWBY
                                              ,DECODE(pcd.parent_id, pcd.id,DECODE(sumry.item_id, ''-1'', 1,2),2) '||
                                               l_others_select||
                                             ',pcd.id VIEWBYID
 ,  decode(sumry.item_id, ''-1'', decode(pcd.parent_id, pcd.id,NULL,'''||l_drill_link||'''),'''||l_drill_link||''') BIL_URL1
                                              ,DECODE(pcd.parent_id,pcd.id,NULL,'''||l_url||''') BIL_URL2
                                          FROM '||l_fii_struct||' cal, '
						||l_others_mv||' sumry '||
                                                  l_pipe_denorm||
                                        ' WHERE cal.xtd_flag = :l_yes AND '||
						' sumry.sales_group_id = :l_sg_id_num '||
						l_parent_sls_grp_where_clause||
						l_pipe_product_where_clause||' AND '||
						l_xtd_where_clause;
                IF l_resource_id IS NOT NULL THEN
                   l_custom_sql := l_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
                ELSE
                   l_custom_sql := l_custom_sql ||' AND sumry.salesrep_id IS NULL ';
                END IF;

                l_custom_sql := l_custom_sql||'
                                    UNION ALL
                                    SELECT DECODE(pcd.parent_id, pcd.id,
					   	decode(sumry.item_id, ''-1'', :l_cat_assign, pcd.value), pcd.value) VIEWBY
                                    ,DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', 1, 2), 2) '||
                                      l_open_select||
                                         ',pcd.id VIEWBYID
   , decode(sumry.item_id, ''-1'', decode(pcd.parent_id, pcd.id,NULL,'''||l_drill_link||'''),'''||l_drill_link||''')   BIL_URL1
                                          ,DECODE(pcd.parent_id, pcd.id,NULL,'''||l_url||''') BIL_URL2
                                    FROM '||l_open_mv||' sumry '||
                                            l_pipe_denorm||
                                   ' WHERE sumry.sales_group_id = :l_sg_id_num '||
					   l_parent_sls_grp_where_clause||
					   l_pipe_product_where_clause ||' AND '||
					   l_open_where_clause;
                IF l_resource_id IS NOT NULL THEN
                   l_custom_sql := l_custom_sql ||' AND sumry.salesrep_id = :l_resource_id ';
                ELSE
                   l_custom_sql := l_custom_sql ||' AND sumry.salesrep_id IS NULL ';
                END IF;
                l_custom_sql := l_custom_sql||' ) GROUP BY SORT_ORDER, VIEWBY, VIEWBYID, BIL_URL1, BIL_URL2';

                 execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';

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



                 l_insert_stmt := ' INSERT INTO BIL_BI_RPT_TMP1(VIEWBY,SORTORDER,BIL_MEASURE28, '||
					'BIL_MEASURE2,BIL_MEASURE3,BIL_MEASURE4 '||
                                        ',BIL_MEASURE5,BIL_MEASURE6,VIEWBYID,BIL_URL1,BIL_URL2) ';


                 IF l_parent_sales_group_id IS NULL THEN
          		 IF l_resource_id IS NULL THEN
                          EXECUTE IMMEDIATE l_insert_stmt || l_custom_sql
                          USING l_cat_assign
                               ,l_period_type
                               ,l_yes
			       ,l_sg_id_num
                               ,l_prodcat
                               ,l_record_type_id,l_record_type_id,l_curr_as_of_date
                               ,l_cat_assign
                               ,l_start_date,l_period_type
			       ,l_snapshot_date,l_period_type
                               ,l_sg_id_num
                               ,l_prodcat
                               ,l_snapshot_date,l_start_date;
                    ELSE
                          EXECUTE IMMEDIATE l_insert_stmt || l_custom_sql
                          USING l_cat_assign
                               	,l_period_type
                               	,l_yes
				,l_sg_id_num
                               	,l_prodcat
                               	,l_record_type_id,l_record_type_id,l_curr_as_of_date
                               	,l_resource_id
                               	,l_cat_assign
                               	,l_start_date,l_period_type
				,l_snapshot_date,l_period_type
                               	,l_sg_id_num
                               	,l_prodcat
                               	,l_snapshot_date,l_start_date
                               	,l_resource_id;
                    END IF;
                 ELSE -- parent sales group id is not null
				 	IF l_resource_id IS NULL THEN
                          EXECUTE IMMEDIATE l_insert_stmt || l_custom_sql
                          USING l_cat_assign
                               	,l_period_type
                               	,l_yes
				,l_sg_id_num
				,l_parent_sales_group_id
                               	,l_prodcat
                               	,l_record_type_id,l_record_type_id,l_curr_as_of_date
                               	,l_cat_assign
                               	,l_start_date,l_period_type
				,l_snapshot_date,l_period_type
				,l_sg_id_num
				,l_parent_sales_group_id
                               	,l_prodcat
                               	,l_snapshot_date,l_start_date;
                    ELSE    -- resource id not null
                          EXECUTE IMMEDIATE l_insert_stmt || l_custom_sql
                          USING l_cat_assign
                               	,l_period_type
                               	,l_yes
				,l_sg_id_num
				,l_sg_id_num
                               	,l_prodcat
                               	,l_record_type_id,l_record_type_id,l_curr_as_of_date
                               	,l_resource_id
                               	,l_cat_assign
                               	,l_start_date,l_period_type
				,l_snapshot_date,l_period_type
                               	,l_sg_id_num
				,l_sg_id_num
                               	,l_prodcat
                               	,l_snapshot_date,l_start_date
                               	,l_resource_id;
                    END IF;
                 END IF; --parent sales group id if ends
		 x_custom_sql := l_outer_select || ' FROM BIL_BI_RPT_TMP1 '||
				   		l_null_rem_clause||' ORDER BY SORTORDER ,UPPER(VIEWBY) ';
              END IF; --prod cat if ends


         END CASE;

         --Remove space
         x_custom_sql := REPLACE(x_custom_sql,'   ',' ');
         x_custom_sql := REPLACE(x_custom_sql,'   ',' ');
         x_custom_sql := REPLACE(x_custom_sql,'   ',' ');
         x_custom_sql := REPLACE(x_custom_sql,'   ',' ');
         x_custom_sql := REPLACE(x_custom_sql,'  ',' ');
         x_custom_sql := REPLACE(x_custom_sql,'  ',' ');

         --Log the query being returned

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => ' x_custom_sql length '||LENGTH(x_custom_sql));

                     END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;



         --Bind parameters
         l_bind_ctr := 1;

         l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
         l_custom_rec.attribute_value := l_viewby;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name := ':l_curr_page_time_id';
         l_custom_rec.attribute_value := l_curr_page_time_id;
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name := ':l_curr_as_of_date';
         l_custom_rec.attribute_value := TO_CHAR(l_curr_as_of_date,'DD/MM/YYYY');
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name := ':l_snap_date';
         l_custom_rec.attribute_value := TO_CHAR(l_snap_date,'DD/MM/YYYY');
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name := ':l_snapshot_date';
         l_custom_rec.attribute_value := TO_CHAR(l_snapshot_date,'DD/MM/YYYY');
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name := ':l_record_type_id';
         l_custom_rec.attribute_value := l_record_type_id;
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name := ':l_sg_id_num';
         l_custom_rec.attribute_value := l_sg_id_num;
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

	 IF l_parent_sales_group_id IS NOT NULL THEN
	    l_custom_rec.attribute_name := ':l_parent_sales_group_id';
            l_custom_rec.attribute_value := l_parent_sales_group_id;
            l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
            l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_attr.Extend();
            x_custom_attr(l_bind_ctr) := l_custom_rec;
            l_bind_ctr := l_bind_ctr+1;
	 END IF;
         IF l_resource_id IS NOT NULL THEN
            l_custom_rec.attribute_name := ':l_resource_id';
            l_custom_rec.attribute_value := l_resource_id;
            l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
            l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_attr.Extend();
            x_custom_attr(l_bind_ctr) := l_custom_rec;
            l_bind_ctr := l_bind_ctr+1;
         END IF;

         l_custom_rec.attribute_name := ':l_period_type';
         l_custom_rec.attribute_value := l_period_type;
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name := ':l_start_date';
         l_custom_rec.attribute_value := TO_CHAR(l_start_date,'DD/MM/YYYY');
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name := ':l_yes';
         l_custom_rec.attribute_value := 'Y';
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr) := l_custom_rec;
         l_bind_ctr := l_bind_ctr+1;
	 IF l_prodcat_id IS NOT NULL THEN
                 l_custom_rec.attribute_name :=':l_productcat_id';
                 l_custom_rec.attribute_value :=l_prodcat;
                 l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
                 l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                 x_custom_attr.Extend();
                 x_custom_attr(l_bind_ctr):=l_custom_rec;
                 l_bind_ctr:=l_bind_ctr+1;

                 l_custom_rec.attribute_name :=':l_prodcat_id';
                 l_custom_rec.attribute_value :=l_prodcat;
                 l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
                 l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                 x_custom_attr.Extend();
                 x_custom_attr(l_bind_ctr):=l_custom_rec;
                 l_bind_ctr:=l_bind_ctr+1;

		 l_custom_rec.attribute_name :=':l_prodcat';
                 l_custom_rec.attribute_value :=l_prodcat;
                 l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
                 l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
                 x_custom_attr.Extend();
                 x_custom_attr(l_bind_ctr):=l_custom_rec;
                 l_bind_ctr:=l_bind_ctr+1;

	ELSE
	   l_custom_rec.attribute_name :=':l_unassigned_value';
           l_custom_rec.attribute_value :=l_unassigned_value;
           l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
           l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           x_custom_attr.Extend();
           x_custom_attr(l_bind_ctr):=l_custom_rec;
           l_bind_ctr:=l_bind_ctr+1;
	END IF;

      ELSE
         BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                          ,x_sqlstr => x_custom_sql);

      END IF;

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;

  EXCEPTION
     WHEN OTHERS THEN

            IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

            fnd_message.set_name('FND','SQL_PLSQL_ERROR');
            fnd_message.set_token('ERROR' ,SQLCODE);
            fnd_message.set_token('REASON', SQLERRM);
            fnd_message.set_token('ROUTINE',l_proc);

                              FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
	                                     MODULE => g_pkg || l_proc || 'proc_error',
                                             MESSAGE => fnd_message.get );

         END IF;

         RAISE;

  END BIL_BI_OPPTY_ACTIVITY;

  /*******************************************************************************
 * Name    : Procedure BIL_BI_TOP_OPP
 * Author  : Aananth Solaiyappan
 * Date    : Dec 17th, 2003
 *
 *           Copyright (c) 2002 Oracle Corporation
 *
 * Parameters :
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 *
 * Date     Author     Description
 * ----     ------     -----------
 * 17/12/03 asolaiy  Forecast management page of 7.0.
 *                   Top Opportunties report and top open opportuntites portlet
 * 22/12/03	ppatil   Modified Top Oppty to incorporate window function and
 					 When Rank By is All chnages
* 16-jun-2004 asolaiy  Fix for bug 3696906
 ******************************************************************************/

 PROCEDURE BIL_BI_TOP_OPP(
              p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
              ,x_custom_sql        OUT NOCOPY VARCHAR2
              ,x_custom_attr       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS

    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;
    l_err_msg                   VARCHAR2(320);
    l_err_desc                  VARCHAR2(4000);
    l_bind_ctr                  NUMBER;
    l_select_stmt               VARCHAR2(8000);
    l_proc                      VARCHAR2(30);
    l_max_rows                  NUMBER(4);
    l_period_sel                VARCHAR2(100);
    l_period_where              VARCHAR2(100);
    l_period_where1             VARCHAR2(100);
    l_period_ord                VARCHAR2(100);
    l_rep_r_grp                  VARCHAR2(10);
    l_primary_currency          VARCHAR2(30);
    l_currency                  VARCHAR2(200);
    l_conv_rate_selected        VARCHAR2(50);
    l_sg_id_num                 NUMBER;
    l_salesgroup_id             VARCHAR2(50);
    l_resource_id               VARCHAR2(50);
    l_period_type               VARCHAR2(50);
    l_opty_status               VARCHAR2(20);
    l_inner_sql                 VARCHAR2(3200);
    l_url            		VARCHAR2(1000);
    l_cust_url            		VARCHAR2(1000);
    g_pkg 			varchar2(200);
    l_curr_suffix		VARCHAR2(10);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

  BEGIN

  /* Initializing variables*/

  g_pkg := 'bil.patch.115.sql.BIL_BI_OPPTY_MGMT_RPTS_PKG.';
  l_region_id:= 'BIL_BI_TOP_OPP';
  l_parameter_valid:= TRUE;
  l_bind_ctr:= 1;
  l_proc:= 'BIL_BI_TOP_OPP';
  l_opty_status:= 'OPEN';

    -- log the start of this proc.

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;


    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    FOR i IN 1..p_page_parameter_tbl.count
    LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
          l_currency := p_page_parameter_tbl(i).parameter_id;
          IF l_currency IS NULL THEN
             l_parameter_valid := FALSE;
             l_err_msg := 'Null parameter';
             l_err_desc := 'l_currency';

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'Currency Fail!',
		                                    MESSAGE => ' Mesg '||l_err_msg||' Desc '||l_err_desc);

                     END IF;

           END IF;

       ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
         l_salesgroup_id := p_page_parameter_tbl(i).parameter_id;
         BIL_BI_UTIL_PKG.PARSE_SALES_GROUP_ID
           (
            p_salesgroup_id =>l_salesgroup_id,
            x_resource_id   =>l_resource_id
          );

         IF l_salesgroup_id IS NULL THEN
            l_parameter_valid := FALSE;
           l_err_msg         := 'Null parameter(s)';
           l_err_desc        := l_err_desc ||  ' ,SALES GROUP';

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE =>    g_pkg || l_proc || 'Sales Group Fail!',
		                                    MESSAGE => ' Mesg '||l_err_msg||' Desc '||l_err_desc);

                     END IF;
         END IF;

       ELSIF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
           l_period_type := p_page_parameter_tbl(i).parameter_value;
          IF l_period_type IS NULL THEN
           l_parameter_valid := FALSE;
           l_err_msg := 'Null parameter';
           l_err_desc := 'l_period_type';

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'Period type Fail!',
		                                    MESSAGE => ' Mesg '||l_err_msg||' Desc '||l_err_desc);

                     END IF;

          END IF;

       ELSIF p_page_parameter_tbl(i).parameter_name = 'DIMENSION+DIMENSION1' THEN
          IF p_page_parameter_tbl(i).parameter_id =  '1' THEN
          l_opty_status := 'ALL';
      ELSIF p_page_parameter_tbl(i).parameter_id =  '2' THEN
          l_opty_status := 'OPEN';
      ELSIF p_page_parameter_tbl(i).parameter_id =  '3' THEN
          l_opty_status := 'WON';
      ELSIF p_page_parameter_tbl(i).parameter_id =  '4' THEN
          l_opty_status := 'LOST';
      ELSIF p_page_parameter_tbl(i).parameter_id =  '5' THEN
          l_opty_status := 'NO_OPPORTUNITY';
          ELSE
              l_opty_status := 'OPEN';
               l_err_msg := 'opty status is '||l_opty_status;
               l_err_desc := 'Defaulted to open opportunity';

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'opty status default',
		                                    MESSAGE => ' Mesg '||l_err_msg||' Desc '||l_err_desc);

                     END IF;
          END IF;
      END IF;
    END LOOP;

    l_sg_id_num := TO_NUMBER(REPLACE(l_salesgroup_id, ''''));
    l_resource_id:=TO_NUMBER(REPLACE(l_resource_id, ''''));

    IF l_parameter_valid THEN


       IF INSTR(l_currency,'FII_GLOBAL1') > 0 THEN
         l_curr_suffix := '';
       ELSE
         l_curr_suffix := '_S';
       END IF;

         l_err_desc := l_err_desc||' l_conversion_rate '||l_conv_rate_selected||' Curr date '||SYSDATE;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'Query bind params',
		                                    MESSAGE => ' Mesg '||l_err_msg||' Desc '||l_err_desc);

                     END IF;

    /* Mappings
     * BIL_MEASURE1 => rank(year/qtr/period/week)
     * BIL_MEASURE2 => Opportunity number
     * BIL_MEASURE3 => Opportunity name
     * BIL_MEASURE4 => Customer Name
     * BIL_MEASURE5 => resource name
     * BIL_MEASURE6 => sales group name
     * BIL_MEASURE7 => opty amount
     * BIL_MEASURE8 => Win Probability
     * BIL_MEASURE9 => sales stage
     * BIL_MEASURE10 => Close date
    */

  /* URL for navigating to ASN Opdtl & Customer Page */

   l_url := '''pFunctionName=ASN_OPPTYDETGWAYPG&ASNReqFrmOpptyId=''||smry.OPTY_ID||''&ASNReqAcsErrInDlg=Y&OAHP=BIL_BI_SLSMGR_HOME_MENU&OAPB=BIL_BI_SMALLBRANDING&addBreadCrumb=Y''';
   l_cust_url := '''pFunctionName=ASN_CUSTDETGWAYPG&ASNReqFrmCustId=''||hzp.party_id||''&ASNReqAcsErrInDlg=Y&OAHP=BIL_BI_SLSMGR_HOME_MENU&OAPB=BIL_BI_SMALLBRANDING&addBreadCrumb=Y''';

    IF l_period_type='FII_TIME_ENT_YEAR' THEN
      l_period_sel := ' year_rank AS BIL_MEASURE1 ';
      l_period_where := ' AND yr=1 AND year_rank < 26 ';
    l_period_where1 := ' AND yr=1 ';
      l_period_ord := ' year_rank ';
    ELSIF l_period_type='FII_TIME_ENT_QTR' THEN
      l_period_sel := ' quarter_rank AS BIL_MEASURE1 ';
      l_period_where := ' AND quarter=1 AND quarter_rank < 26 ';
    l_period_where1 := ' AND quarter = 1 ';
      l_period_ord := ' quarter_rank ';
    ELSIF l_period_type='FII_TIME_ENT_PERIOD' THEN
      l_period_sel := ' period_rank AS BIL_MEASURE1 ';
      l_period_where := ' AND period=1 AND period_rank < 26 ';
    l_period_where1 := ' AND period = 1 ';
     l_period_ord := ' period_rank ';
    ELSIF l_period_type='FII_TIME_WEEK' THEN
      l_period_sel := ' week_rank AS BIL_MEASURE1 ';
      l_period_where := ' AND week=1 AND week_rank < 26 ';
    l_period_where1 := ' AND week = 1 ';
      l_period_ord := ' week_rank ';
    END IF;

  IF UPPER(l_opty_status) = 'ALL' THEN
    IF l_resource_id IS NULL THEN
    l_period_sel := 'RANK() OVER(PARTITION BY parent_sales_group_id ORDER BY opty_amt'||l_curr_suffix||' DESC) BIL_MEASURE1';
  ELSE
    l_period_sel := 'RANK() OVER(PARTITION BY smry.sales_group_id,smry.salesrep_id ORDER BY opty_amt'||l_curr_suffix||' DESC) '||
              'BIL_MEASURE1';
  END IF;

  l_period_where := l_period_where1;

  ELSE
    l_period_where := 'AND OPTY_STATUS = :l_opty_status '||l_period_where;
  END IF;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'l_period_where',
		                                    MESSAGE => l_period_where);

                     END IF;


  l_inner_sql := 'SELECT '||l_period_sel||' ,OPTY_NUMBER, (SELECT description FROM as_leads_all ld WHERE smry.opty_id = ld.lead_id) OPTY_NAME,'||
        '(OPTY_AMT'||l_curr_suffix||') OPTY_AMT, '||
                    'WIN_PROBABILITY, OPTY_CLOSE_DATE, OPTY_STATUS, OPTY_STATUS_CODE, '||
        'SUM(opty_amt'||l_curr_suffix||') OVER() GRAND_TOTAL, SMRY.SALES_GROUP_ID SALES_GROUP_ID, '||
                    'SMRY.Customer_id BIL_MEASURE4,SMRY.SALESREP_ID SALESREP_ID, '||
        'SMRY.SALES_STAGE_ID SALES_STAGE_ID, '||l_url||' BIL_URL1 , NULL BIL_URL2 '||
                    'FROM BIL_BI_TOPOP_G_MV SMRY '||
                    'WHERE SMRY.PARENT_SALES_GROUP_ID = :l_sg_id_num '||

                    l_period_where;

  IF l_resource_id IS NOT NULL THEN
    l_inner_sql := l_inner_sql||' AND smry.salesrep_id = :l_resource_id AND smry.umarker=:l_rep_r_grp ';
    l_rep_r_grp := 'SLSREP';
  ELSE
    l_inner_sql := l_inner_sql||' AND smry.umarker=:l_rep_r_grp';
    l_rep_r_grp:='SLSGRP';
  END IF;

  IF l_opty_status = 'ALL' THEN
     l_inner_sql := ' SELECT BIL_MEASURE1,OPTY_NUMBER, OPTY_NAME, OPTY_AMT, '||
          'WIN_PROBABILITY, OPTY_CLOSE_DATE, OPTY_STATUS, OPTY_STATUS_CODE, '||
          'GRAND_TOTAL, SALES_GROUP_ID, '||
          'BIL_MEASURE4,SALESREP_ID,SALES_STAGE_ID, BIL_URL1 , BIL_URL2 '||
          'FROM ( '|| l_inner_sql||') WHERE BIL_MEASURE1 < 26 '||
          ' ORDER BY BIL_MEASURE1, OPTY_NUMBER  ';
  ELSE
    l_inner_sql := l_inner_sql || ' ORDER BY '||l_period_ord||', OPTY_NUMBER ';
  END IF;

  l_inner_sql := 'SELECT (ROWNUM-1) RN, BIL_MEASURE1,OPTY_NUMBER, OPTY_NAME, OPTY_AMT, '||
          'WIN_PROBABILITY, OPTY_CLOSE_DATE, OPTY_STATUS, OPTY_STATUS_CODE, '||
          'GRAND_TOTAL, SALES_GROUP_ID, '||
          'BIL_MEASURE4,SALESREP_ID,SALES_STAGE_ID, BIL_URL1, BIL_URL2 '||
          'FROM ( '|| l_inner_sql||')';

  x_custom_sql :=
    'SELECT '||
       'BIL_MEASURE1,OPTY_NAME BIL_MEASURE3,OPTY_NUMBER BIL_MEASURE2,'||
       'HZP.PARTY_NAME BIL_MEASURE4, RSTL.RESOURCE_NAME BIL_MEASURE5, GRPTL.GROUP_NAME BIL_MEASURE6,'||
       'OPTY_AMT BIL_MEASURE7, WIN_PROBABILITY BIL_MEASURE8, '||
       'STG.NAME BIL_MEASURE9, OPTY_CLOSE_DATE BIL_MEASURE10, STS.MEANING BIL_MEASURE11,'||
       'GRAND_TOTAL BIL_MEASURE12, BIL_URL1, '||l_cust_url||' BIL_URL2 '||
    'FROM '||
       '(SELECT * FROM '||
         '('||l_inner_sql||')' ||
         ' WHERE RN >= &START_INDEX AND RN <= &END_INDEX )IV'||
            ',JTF_RS_RESOURCE_EXTNS_TL RSTL '||
            ',JTF_RS_GROUPS_TL GRPTL '||
            ',AS_SALES_STAGES_ALL_TL STG '||
            ',HZ_PARTIES HZP '||
            ',AS_STATUSES_TL STS '||
         'WHERE '||
           'RSTL.LANGUAGE = USERENV(''LANG'') '||
           'AND RSTL.RESOURCE_ID = IV.SALESREP_ID '||
           'AND GRPTL.LANGUAGE = USERENV(''LANG'') '||
           'AND GRPTL.GROUP_ID = IV.SALES_GROUP_ID '||
           'AND STG.LANGUAGE(+) = USERENV(''LANG'') '||
           'AND STG.SALES_STAGE_ID(+) = IV.SALES_STAGE_ID '||
           'AND STS.STATUS_CODE = IV.OPTY_STATUS_CODE '||
           'AND STS.LANGUAGE = USERENV(''LANG'') '||
           'AND HZP.PARTY_ID = IV.BIL_MEASURE4 '||
         ' ORDER BY BIL_MEASURE1,   OPTY_NUMBER ' ;

         /* Bind parameters */

    l_custom_rec.attribute_name :=':l_sg_id_num';
    l_custom_rec.attribute_value := l_sg_id_num;
    l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    x_custom_attr.Extend();

    x_custom_attr(l_bind_ctr):=l_custom_rec;

    l_bind_ctr:=l_bind_ctr+1;

    IF l_resource_id IS NOT NULL THEN
      l_custom_rec.attribute_name :=':l_resource_id';
      l_custom_rec.attribute_value := l_resource_id;
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;
      l_bind_ctr:=l_bind_ctr+1;
    END IF;

    l_custom_rec.attribute_name :=':l_opty_status';
    l_custom_rec.attribute_value := l_opty_status;
    l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    x_custom_attr.Extend();
    x_custom_attr(l_bind_ctr):=l_custom_rec;
    l_bind_ctr:=l_bind_ctr+1;


    l_custom_rec.attribute_name :=':l_rep_r_grp';
    l_custom_rec.attribute_value := l_rep_r_grp;
    l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    x_custom_attr.Extend();
    x_custom_attr(l_bind_ctr):=l_custom_rec;
    l_bind_ctr:=l_bind_ctr+1;

  ELSE
    BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id,x_sqlstr => l_select_stmt);
    x_custom_sql := l_select_stmt;
  END IF;

                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
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
END BIL_BI_TOP_OPP;

 /*******************************************************************************
 * Name    : Procedure BIL_BI_OPPTY_LINE_DETAIL - Opportunity Line detail report
 * Author  : Hrishikesh Pandey
 * Date    : Nov 24th, 2004
 *
 *           Copyright (c) 2004 Oracle Corporation
 *
 * Parameters :
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 ******************************************************************************/

 PROCEDURE BIL_BI_OPPTY_LINE_DETAIL(
              p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
              ,x_custom_sql        OUT NOCOPY VARCHAR2
              ,x_custom_attr       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS


    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_currency                  VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    l_err_msg                   VARCHAR2(100);
    l_err                       VARCHAR2(500);
    l_salesgroup_id             VARCHAR2(50);
    l_resource_id               VARCHAR2(50);
    l_prodcat_id                VARCHAR2(50);
    l_customer_id                VARCHAR2(3000);
    l_prodcat                   VARCHAR2(50);
    l_asof_date                 DATE;
    l_period_type               VARCHAR2(50);
    l_bind_ctr                  NUMBER;
    l_select                    VARCHAR2(4000);
    l_select1                   VARCHAR2(4000);
    l_select2                   VARCHAR2(4000);
    l_where                     VARCHAR2(4000);
    l_where_clause              VARCHAR2(4000);
    l_custom_sql                VARCHAR2(4000);
    l_status                    VARCHAR2(50) ;
    l_proc                      VARCHAR2(100);
    l_pkg                       VARCHAR2(100);
    l_region_id                 VARCHAR2(100);
    l_where1                    VARCHAR2(1000);
    l_cust_url                  VARCHAR2(1000);
    l_url                       VARCHAR2(1000);
    l_curr_suffix               VARCHAR2(10);
    l_sql_error_desc            VARCHAR2(10000);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;


  BEGIN

  /* Initializing variables*/

    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_bind_ctr := 1;
    l_parameter_valid := TRUE;

    l_region_id := 'BIL_BI_OPPTY_LINE_DETAIL';
    l_proc := 'BIL_BI_OPPTY_LINE_DETAIL.';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '|| l_proc);

                     END IF;


  /* Get the page parameters  */

    FOR i IN 1..p_page_parameter_tbl.count
    LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
          l_currency := p_page_parameter_tbl(i).parameter_id;
          IF l_currency IS NULL THEN
             l_parameter_valid := FALSE;
             l_err_msg := 'Null currency parameter';
             l_err := 'l_currency';
           END IF;
       ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
         l_salesgroup_id := p_page_parameter_tbl(i).parameter_id;
         BIL_BI_UTIL_PKG.PARSE_SALES_GROUP_ID
         (
            p_salesgroup_id =>l_salesgroup_id,
            x_resource_id   =>l_resource_id
          );

         IF l_salesgroup_id IS NULL THEN
            l_parameter_valid := FALSE;
            l_err_msg         := 'Null sales group parameter(s)';
            l_err        := l_err ||  ' ,SALES GROUP';
         END IF;

       ELSIF p_page_parameter_tbl(i).parameter_name = 'BIL_DIMENSION1' THEN
          l_status := p_page_parameter_tbl(i).parameter_id;
       ELSIF p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT' THEN
          l_prodcat_id := p_page_parameter_tbl(i).parameter_id;
       ELSIF p_page_parameter_tbl(i).parameter_name = 'CUSTOMER+PROSPECT' THEN
          l_customer_id := p_page_parameter_tbl(i).parameter_id;
       ELSIF p_page_parameter_tbl(i).parameter_name='BIS_CURRENT_ASOF_DATE'    THEN
         l_asof_date :=  to_date(p_page_parameter_tbl(i).parameter_id,'dd/mm/yyyy');
       ELSIF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
           l_period_type := p_page_parameter_tbl(i).parameter_value;
          IF l_period_type IS NULL THEN
           l_parameter_valid := FALSE;
           l_err_msg := 'Null period type parameter';
           l_err := l_err || ' ,l_period_type';
          END IF;
      END IF;
    END LOOP;


--Find if the currency chosen in primary or secondary

 IF INSTR(l_currency,'FII_GLOBAL1') > 0 THEN
         l_curr_suffix := '';
 ELSE
         l_curr_suffix := '_S';
 END IF;

-- URL to drill to transaction pages
   l_url := '''pFunctionName=ASN_OPPTYDETGWAYPG&ASNReqFrmOpptyId=''||fact.OPTY_ID||''&ASNReqAcsErrInDlg=Y&OAHP=BIL_BI_SLSMGR_HOME_MENU&OAPB=BIL_BI_SMALLBRANDING&addBreadCrumb=Y''';
   l_cust_url := '''pFunctionName=ASN_CUSTDETGWAYPG&ASNReqFrmCustId=''||fact.customer_id||''&ASNReqAcsErrInDlg=Y&OAHP=BIL_BI_SLSMGR_HOME_MENU&OAPB=BIL_BI_SMALLBRANDING&addBreadCrumb=Y''';

/* Get the status of the opportunity to be displayed */
/*
 This parameter is obtained from the report whose hyperlinked measure was cliked.
 The possible statuses of the opportunity are
   OPEN
   PIPELINE
   WON
   LOST
   NO
*/

--l_status := 'Pipeline';
IF UPPER(l_status) = 'WON' THEN
l_where :=  'and base.open_status_flag =''N'' '  ||
' and base.win_loss_indicator = ''W''';
ELSIF UPPER(l_status) = 'OPEN' THEN
l_where :=  'and base.open_status_flag =''Y'' ' ||
'  and base.forecast_rollup_flag= ''Y''';
ELSIF UPPER(l_status) = 'LOST' THEN
l_where :=  'and base.open_status_flag =''N'' ' ||
'  and base.win_loss_indicator = ''L''';
ELSIF UPPER(l_status) = 'NO OPPORTUNITY' THEN
l_where := 'and base.open_status_flag =''N'' '  ||
' and base.win_loss_indicator = ''N''';
ELSIF UPPER(l_status) = 'PIPELINE' THEN
l_where := ' and base.forecast_rollup_flag = ''Y''';
END IF;



--- To handle Pipeline and Open Statuses

IF ((UPPER(l_status) = 'OPEN') OR (UPPER(l_status) = 'PIPELINE')) THEN
 l_where :=  ' and base.opty_close_time_id BETWEEN times.start_date  AND times.end_date  ' || l_where   ;
ELSE

l_where := ' and base.opty_close_time_id BETWEEN times.start_date  AND to_number(to_char(:l_asof_date ,''J''))  ' || l_where  ;
END IF;


-- Check whether Customer is 'ALL'

IF l_customer_id IS NULL THEN
      l_where  := ' '  ||   l_where;
ELSE
      l_customer_id := replace(l_customer_id,'''','');
      l_where  := '  and base.customer_id IN ('||l_customer_id||') ' || l_where;
END IF;


/*
  Sales group, period type, currency & as of date LOVs always have a value chosen
  Only product category may be
    ALL or
    Specific prod cat might be chosen.

   If prod cat is ALL then IF part is executed else ELSE part is executed

*/

 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

		        l_sql_error_desc :=
      'l_curr_as_of_date        => '|| l_asof_date ||',      ' ||
      'l_period_type            => '|| l_period_type ||',    ' ||
      'l_currency               => '|| l_currency ||',       ' ||
      'l_salesgroup_id          => '|| l_salesgroup_id ||',  ' ||
      'l_resource_id            => '|| l_resource_id ||',    ' ||
      'l_prodcat_id             => '|| l_prodcat_id ||',     ' ||
      'l_customer_id            => '|| l_customer_id ;

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc ,
		                                    MESSAGE => 'Parameters => '||l_sql_error_desc);
 END IF;

/*** Query column mapping ******************************************************

*  Internal Name     Region Item Name
* BIL_MEASURE1       Opportunity Name
* BIL_MEASURE2       Opportunity Number
* BIL_MEASURE3       Customer
* BIL_MEASURE4       Forecast Owner
* BIL_MEASURE5       Forecast Owner Sales Group
* BIL_MEASURE6       Product Category
* BIL_MEASURE7       Amount
* BIL_MEASURE8       Win Probability
* BIL_MEASURE9       Sales Stage
* BIL_MEASURE10      Close Date
* BIL_MEASURE11      Status
* BIL_MEASURE12      GRAND TOTAL(BIL_MEASURE7)
* BIL_URL1           Drill to Opportunity Detail page
* BIL_URL2           Drill to customer detail Page

*******************************************************************************/


l_select :=  '
SELECT
  (SELECT description FROM AS_LEADS_ALL ALDL WHERE ALDL.LEAD_ID=FACT.OPTY_ID) BIL_MEASURE1,
  fact.lead_number BIL_MEASURE2,
  (SELECT PARTY_NAME FROM HZ_PARTIES HZP WHERE HZP.PARTY_ID=FACT.CUSTOMER_ID) BIL_MEASURE3,
  (SELECT rstl.resource_name from jtf_rs_resource_extns_tl rstl
    WHERE rstl.resource_id=fact.salesrep_id and USERENV(''LANG'')=rstl.LANGUAGE) BIL_MEASURE4,
  (SELECT group_name from jtf_rs_groups_tl grtl
    WHERE fact.sales_group_id=grtl.group_id and USERENV(''LANG'')=grtl.LANGUAGE) BIL_MEASURE5,
  prod_id_names.value BIL_MEASURE6,
  sum(nvl(sales_credit_amt ,0)) BIL_MEASURE7,
  fact.win_probability BIL_MEASURE8,
  (SELECT stg.NAME FROM AS_SALES_STAGES_ALL_TL stg
    WHERE stg.sales_stage_id = fact.sales_stage_id and USERENV(''LANG'')=stg.LANGUAGE) BIL_MEASURE9,
  TO_DATE(fact.opty_close_time_id,''J'') BIL_MEASURE10,
  (SELECT STS.MEANING FROM as_statuses_tl sts
    WHERE sts.status_code=fact.status and USERENV(''LANG'')=sts.LANGUAGE) BIL_MEASURE11,
  SUM(SUM(NVL(sales_credit_amt ,0)) ) OVER() BIL_MEASURE12,
  '|| l_cust_url ||'  BIL_URL2,
  '|| l_url ||'  BIL_URL1
FROM
  (
   select
        base.lead_number,
        base.opty_id,
        base.sales_stage_id,
        base.status,
        base.win_probability,
        base.customer_id,
        base.salesrep_id,
        base.sales_group_id,
        base.sales_credit_amt'||l_curr_suffix||'   sales_credit_amt,
        base.opty_close_time_id,
        base.product_category_id

    from
      bil_bi_opdtl_mv base,
      (
        SELECT
          to_number(
            to_char(
              (CASE
                 WHEN :l_period_type =''FII_TIME_ENT_YEAR'' THEN day.ent_year_start_date
                 WHEN :l_period_type =''FII_TIME_ENT_QTR'' THEN day.ent_qtr_start_date
                 WHEN :l_period_type =''FII_TIME_ENT_PERIOD'' THEN day.ent_period_start_date
                 WHEN :l_period_type =''FII_TIME_WEEK'' THEN day.week_start_date END
          ),''J''))  start_date,
          to_number(
            to_char(
              (CASE
                WHEN :l_period_type =''FII_TIME_ENT_YEAR'' THEN day.ent_year_end_date
                WHEN :l_period_type =''FII_TIME_ENT_QTR'' THEN day.ent_qtr_end_date
                WHEN :l_period_type =''FII_TIME_ENT_PERIOD'' THEN day.ent_period_end_date
                WHEN :l_period_type =''FII_TIME_WEEK'' THEN day.week_end_date END
          ),''J''))  end_date
        FROM
          fii_time_day day
        WHERE
          :l_asof_date  = day.report_date
      ) times
  where
    base.sales_group_id = :l_salesgroup_id
    and base.salesrep_id =:l_resource_id
    ' || l_where || '
  )fact,   ';


l_select1 := '
  (
    SELECT   /*+ NO_MERGE */
      distinct id,value
    FROM
      eni_item_prod_cat_lookup_v
  ) prod_id_names
  ';

 -- Some product category is Chosen from the dropdown list
   l_select2 :=  '

  (SELECT /*+ NO_MERGE */
    DISTINCT id,value
  FROM
    eni_item_prod_cat_lookup_v
  WHERE id IN
    (SELECT child_id  FROM eni_item_prod_cat_lookup_v a WHERE a.parent_id= :l_prodcat_id)
  )prod_id_names   ' ;



l_where_clause :=  '

WHERE
  fact.product_category_id = prod_id_names.id
GROUP BY
  fact.lead_number,
  fact.opty_id,
  fact.sales_stage_id,
  fact.status,
  fact.win_probability,
  fact.customer_id,
  fact.salesrep_id,
  prod_id_names.value,
  fact.sales_group_id,
  fact.opty_close_time_id
ORDER BY
  BIL_MEASURE7 DESC ,
  UPPER(BIL_MEASURE1),
  BIL_MEASURE2,
  UPPER(BIL_MEASURE6),
  UPPER(BIL_MEASURE5)
  ' ;

IF l_prodcat_id IS NULL THEN

     l_custom_sql :=  l_select   ||
                      l_select1  ||
                      l_where_clause  ;

 ELSE   -- Some product category is Chosen from the dropdown list

      l_custom_sql :=  l_select   ||
                       l_select2  ||
                       l_where_clause  ;

END IF;

  x_custom_sql := l_custom_sql ;

    --Log the query being returned


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'Query Length=>',
		                                    MESSAGE => ' x_custom_sql length '||LENGTH(x_custom_sql));

                     END IF;



                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;



  /* Bind Parameters */

    l_custom_rec.attribute_name :=':l_salesgroup_id';
    l_custom_rec.attribute_value := l_salesgroup_id;
    l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    x_custom_attr.Extend();
    x_custom_attr(l_bind_ctr):=l_custom_rec;
    l_bind_ctr:=l_bind_ctr+1;


      l_custom_rec.attribute_name :=':l_resource_id';
      l_custom_rec.attribute_value := l_resource_id;
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;
      l_bind_ctr:=l_bind_ctr+1;


    IF l_prodcat_id IS NOT NULL THEN
        l_custom_rec.attribute_name :=':l_prodcat_id';
        l_custom_rec.attribute_value := l_prodcat_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;
   END IF;

        l_custom_rec.attribute_name := ':l_asof_date';
        l_custom_rec.attribute_value := TO_CHAR(l_asof_date,'DD/MM/YYYY');
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr) := l_custom_rec;
        l_bind_ctr := l_bind_ctr+1;


    l_custom_rec.attribute_name := ':l_period_type';
    l_custom_rec.attribute_value := l_period_type;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    x_custom_attr.Extend();
    x_custom_attr(l_bind_ctr) := l_custom_rec;
    l_bind_ctr := l_bind_ctr+1;


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'End',
		                                    MESSAGE => 'End of Procedure '||l_proc);

                     END IF;


END BIL_BI_OPPTY_LINE_DETAIL;

END BIL_BI_OPPTY_MGMT_RPTS_PKG;



/
