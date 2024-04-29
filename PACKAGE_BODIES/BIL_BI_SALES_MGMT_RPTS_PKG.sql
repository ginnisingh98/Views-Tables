--------------------------------------------------------
--  DDL for Package Body BIL_BI_SALES_MGMT_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_SALES_MGMT_RPTS_PKG" AS
/* $Header: bilbssb.pls 120.16 2006/01/13 04:18:02 hrpandey noship $ */

  g_pkg		       VARCHAR2(100);
  g_sch_name VARCHAR2(100);

/*******************************************************************************
 * Name    : Sales Results vs Forecast
 * Author  : Prasanna Patil
 * Date    : July 27, 2003
 * Purpose : Sales Managment Sumry Sales Intelligence report and charts.
 *
 *           Copyright (c) 2002 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 * Date     Author     Description
 * ----     ------     -----------
 * 07/21/03 ppatil     Intial Version
 *
 * 17-Mar-2004 krsundar Fixed issues pertaining to forecast measure, view by product category
 * 25-Mar-2004 krsundar Drill and pivot fix
 * 26 Nov 2004 hrpandey Drill Down to Oppty Line Detail report
 ******************************************************************************/
PROCEDURE BIL_BI_SALES_MGMT_SUMRY(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                 ,x_custom_sql         OUT NOCOPY VARCHAR2
                                 ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
AS

     l_page_period_type        VARCHAR2(100);
     l_period_type             VARCHAR2(200);
     l_sg_id                   VARCHAR2(200);
     l_conv_rate_selected      VARCHAR2(200);
     l_fst_crdt_type           VARCHAR2(100);
     l_fii_struct              VARCHAR2(100);
     l_comp_type               VARCHAR2(20);
     l_bitand_id               VARCHAR2(10);
     l_calendar_id             VARCHAR2(10);
     l_viewby                  VARCHAR2(100);
     l_currency                VARCHAR2(50);
     l_sql_stmnt1              VARCHAR2(5000);
     l_sql_stmnt2              VARCHAR2(5000);
     l_sql_stmnt3              VARCHAR2(5000);
     l_sql_stmnt4              VARCHAR2(5000);
     l_outer_select            VARCHAR2(5000);
     l_insert_stmnt            VARCHAR2(5000);
     l_inner_select            VARCHAR2(5000);
     l_sql_error_desc          VARCHAR2(8000);
     l_where_clause1           VARCHAR2(1000);
     l_where_clause2           VARCHAR2(1000);
     l_where_clause3           VARCHAR2(1000);
     l_where_clause4           VARCHAR2(1000);
     l_where_clause5           VARCHAR2(1000);
     l_where_clause6           VARCHAR2(1000);
     l_product_where_clause    VARCHAR2(1000);
     l_product_where_clause1   VARCHAR2(1000);
     l_product_where_clause2   VARCHAR2(1000);
     l_from1                   VARCHAR2(500);
     l_from2                   VARCHAR2(500);
     l_from3                   VARCHAR2(500);
     l_url_str                 VARCHAR2(1000);
     l_cat_assign              VARCHAR2(50);
     l_resource_id             VARCHAR2(20);
     l_null_rem_clause         VARCHAR2(1000);
     l_prodcat_id              VARCHAR2(50);
     l_denorm                  VARCHAR2(50);
     l_opty_denorm             VARCHAR2(200);
     l_sumry1                  VARCHAR2(50);
     l_sumry2                  VARCHAR2(50);
     l_sumry3                  VARCHAR2(50);
     l_cat_url                 VARCHAR2(500);
     l_netBooked_URL           VARCHAR2(1000);
     l_Revenue_URL             VARCHAR2(1000);
     l_curr_page_time_id       NUMBER;
     l_prev_page_time_id       NUMBER;
     l_sg_id_num               NUMBER;
     l_record_type_id          NUMBER;
     l_productcat_id           NUMBER;
     l_bind_ctr                NUMBER;
     l_curr_as_of_date         DATE;
     l_prev_date               DATE;
     l_bis_sysdate             DATE;
     l_custom_rec              BIS_QUERY_ATTRIBUTES;
     l_userCurrency            BOOLEAN;
     l_proc                    VARCHAR2(100);
     l_rpt_str                 VARCHAR2(80);
     l_parameter_valid         BOOLEAN;
     l_region_id               VARCHAR2(100);
     l_assign_cat			   BOOLEAN;
     l_dummy_cnt			   INTEGER;
     l_yes                     VARCHAR2(1);
     l_parent_sg_id_num        NUMBER;
     l_unassigned_value		   VARCHAR2(1000);
     l_currency_suffix         VARCHAR2(5);
     l_isc_currency_suffix     VARCHAR2(5);
     l_drill_link              varchar2(4000);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

BEGIN

     g_pkg := 'bil.patch.115.sql.BIL_BI_SALES_MGMT_RPTS_PKG.';
     l_proc := 'BIL_BI_SALES_MGMT_SUMRY.';
     l_rpt_str := 'BIL_BI_SLSMGMT_R';
     l_parameter_valid := FALSE;
     l_region_id := 'BIL_BI_SALES_MGMT_SUMRY';
     l_yes := 'Y';
     g_sch_name := 'BIL';


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
                                     ,x_parent_sg_id        => l_parent_sg_id_num
                                     ,x_resource_id         => l_resource_id
                                     ,x_prodcat_id          => l_prodcat_id
                                     ,x_curr_page_time_id   => l_curr_page_time_id
                                     ,x_prev_page_time_id   => l_prev_page_time_id
                                     ,x_comp_type           => l_comp_type
                                     ,x_parameter_valid     => l_parameter_valid
                                     ,x_as_of_date          => l_curr_as_of_date
                                     ,x_page_period_type    => l_page_period_type
                                     ,x_prior_as_of_date    => l_prev_date
                                     ,x_record_type_id      => l_record_type_id
                                     ,x_viewby              => l_viewby );

      IF l_parameter_valid THEN

          BIL_BI_UTIL_PKG.GET_FORECAST_PROFILES(x_FstCrdtType => l_fst_crdt_type);

          l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
          l_prodcat_id := TO_NUMBER(REPLACE(l_prodcat_id,''''));

          BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id   => l_bitand_id,
                                           x_calendar_id => l_calendar_id,
                                           x_curr_date   => l_bis_sysdate,
                                           x_fii_struct  => l_fii_struct);

        IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
            l_isc_currency_suffix := '1';
        ELSE
            l_currency_suffix := '';
            l_isc_currency_suffix := '';
        END IF;

          IF l_prodcat_id IS NULL THEN
             l_prodcat_id := 'All';
          END IF;


          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN


             l_sql_error_desc := 'l_viewby                => '|| l_viewby||', '||
                                 'l_curr_page_time_id     => '|| l_curr_page_time_id ||', ' ||
                                 'l_prev_page_time_id     => '|| l_prev_page_time_id ||', ' ||
                                 'l_curr_as_of_date       => '|| l_curr_as_of_date ||', ' ||
                                 'l_prev_date             => '|| l_prev_date ||', ' ||
                                 'l_conv_rate_selected    => '|| l_conv_rate_selected ||', ' ||
                                 'l_bitand_id             => '|| l_bitand_id ||', ' ||
                                 'l_period_type           => '|| l_period_type ||', ' ||
                                 'l_sg_id                 => '|| l_sg_id ||', ' ||
                                 'l_resource_id           => '|| l_resource_id ||', ' ||
                                 'l_bis_sysdate           => '|| l_bis_sysdate ||', ' ||
                                 'l_fst_crdt_type         => '|| l_fst_crdt_type ||', '||
                                 'l_prodcat_id            => '|| l_prodcat_id ||', '||
                                 'l_record_type_id        => '|| l_record_type_id ||', '||
                                 'l_prodcat_id            => '|| l_prodcat_id;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE =>    g_pkg || l_proc,
		                                    MESSAGE =>   'Binds =>'||l_sql_error_desc);

              END IF;


          l_netBooked_URL := 'pFunctionName=ISC_DBI_NET_BOOK_FULF&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
          l_Revenue_URL := 'pFunctionName=FII_AR_SG_PROD_REV&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';


----  Changes for Drill Links to opty Line Detail Report


-- Get the Drill Link to the Opty Line Detail Report

l_drill_link := bil_bi_util_pkg.get_drill_links( p_view_by =>  l_viewby,
                                                 p_salesgroup_id =>   l_sg_id,
                                                 p_resource_id   =>    l_resource_id  );



          l_outer_select := 'SELECT VIEWBY ';
          IF 'ORGANIZATION+JTF_ORG_SALES_GROUP' = l_viewby THEN
              l_outer_select := l_outer_select ||',DECODE(BIL_URL1,NULL,VIEWBYID||''.''||:l_sg_id_num,VIEWBYID) VIEWBYID ';
          ELSE
              l_outer_select := l_outer_select ||',VIEWBYID ';
          END IF;
          l_outer_select := l_outer_select ||',(BIL_MEASURE5/DECODE(BIL_MEASURE2,0,NULL,BIL_MEASURE2)) * 100 BIL_MEASURE1 '||
                                  ',BIL_MEASURE2 '||
                                  ',BIL_MEASURE3 '||
                                  ',(BIL_MEASURE2-BIL_MEASURE3)/ABS(DECODE(BIL_MEASURE3,0,NULL,BIL_MEASURE3))*100 BIL_MEASURE4 '||
                                  ',BIL_MEASURE5 '||
                                  ',BIL_MEASURE6 '||
                                  ',(BIL_MEASURE5-BIL_MEASURE6)/ABS(DECODE(BIL_MEASURE6,0,NULL,BIL_MEASURE6))*100 BIL_MEASURE7 '||
                                  ',DECODE(BIL_MEASURE8,0,NULL,BIL_MEASURE8) BIL_MEASURE8 '||
                                  ',BIL_MEASURE9 '||
                                  ',(BIL_MEASURE8-BIL_MEASURE9)/ABS(DECODE(BIL_MEASURE9, 0, NULL, BIL_MEASURE9))*100 BIL_MEASURE10 '||
                                  ',DECODE(BIL_MEASURE14,0,NULL,BIL_MEASURE14) BIL_MEASURE14 '||
                                  ',BIL_MEASURE15 '||
                                  ',(BIL_MEASURE14-BIL_MEASURE15)/ABS(DECODE(BIL_MEASURE15, 0, NULL, BIL_MEASURE15))*100 BIL_MEASURE16 '||
                                  ',(BIL_MEASURE14/(DECODE(BIL_MEASURE2,0,NULL,BIL_MEASURE2))*100) BIL_MEASURE17 '||
                                  ',(SUM(BIL_MEASURE5) OVER()/DECODE(SUM(BIL_MEASURE2) OVER(),0,NULL,SUM(BIL_MEASURE2) OVER())) * 100 BIL_MEASURE24 '||
                                  ',SUM(BIL_MEASURE2) OVER() BIL_MEASURE25 '||
                                  ',SUM(BIL_MEASURE3) OVER() BIL_MEASURE26'||
                                  ',(SUM(BIL_MEASURE2) OVER() - SUM(BIL_MEASURE3) OVER())/ABS(DECODE(SUM(BIL_MEASURE3) OVER(), 0, NULL, '||
                                                                    ' SUM(BIL_MEASURE3) OVER()))*100 BIL_MEASURE27 '||
                                  ',SUM(BIL_MEASURE5) OVER() BIL_MEASURE28 '||
                                  ',SUM(BIL_MEASURE6) OVER() BIL_MEASURE29 '||
                                  ',(SUM(BIL_MEASURE5) OVER() - SUM(BIL_MEASURE6) OVER())/ABS(DECODE(SUM(BIL_MEASURE6) OVER(), 0, NULL, '||
                                                                   ' SUM(BIL_MEASURE6) OVER()))*100 BIL_MEASURE30 '||
                                  ',SUM(DECODE(BIL_MEASURE8,0,NULL,BIL_MEASURE8)) OVER() BIL_MEASURE31 '||
                                  ',SUM(BIL_MEASURE9) OVER() BIL_MEASURE32 '||
                                  ',(SUM(BIL_MEASURE8) OVER() - SUM(BIL_MEASURE9) OVER())/ABS(DECODE(SUM(BIL_MEASURE9) OVER(), 0, NULL, '||
                                                                    ' SUM(BIL_MEASURE9) OVER()))*100 BIL_MEASURE33 '||
                                  ',SUM(DECODE(BIL_MEASURE14,0,NULL,BIL_MEASURE14)) OVER() BIL_MEASURE37 '||
                                  ',SUM(BIL_MEASURE15) OVER() BIL_MEASURE38 '||
                                  ',(SUM(BIL_MEASURE14) OVER() - SUM(BIL_MEASURE15) OVER())/ABS(DECODE(SUM(BIL_MEASURE15) OVER(), 0, NULL '||
                                                               ' , SUM(BIL_MEASURE15) OVER()))*100 BIL_MEASURE39 '||
                                  ',(SUM(BIL_MEASURE14) OVER()/(DECODE(SUM(BIL_MEASURE2) OVER(),0,NULL,SUM(BIL_MEASURE2) OVER())))*100 BIL_MEASURE40 '||
                                  ',BIL_URL1 '||
                                  ',BIL_URL2 '||
                                  ','''||l_netBooked_URL||''' BIL_URL3 ' ||
                                  ','''||l_Revenue_URL||''' BIL_URL4
,DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
		DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=WON'''||'),
                DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=WON'''||'))
                  BIL_URL5

';

          --Opportunity amounts for sales groups and sales reps

          l_sql_stmnt1 := 'NULL BIL_MEASURE2,
                           NULL BIL_MEASURE3,
                           SUM(CASE WHEN cal.report_date=:l_curr_as_of_date
                           THEN sumry.won_opty_amt'||l_currency_suffix||'
                                    ELSE NULL END)  BIL_MEASURE5,
                           SUM(CASE WHEN  cal.report_date =:l_prev_date
                           THEN sumry.won_opty_amt'||l_currency_suffix||'
                                   ELSE NULL END) BIL_MEASURE6,
                           NULL BIL_MEASURE8,
                           NULL BIL_MEASURE9,
                           NULL BIL_MEASURE14,
                           NULL BIL_MEASURE15 ';


          l_where_clause1 := ' WHERE sumry.effective_time_id = cal.time_id
                              AND sumry.effective_period_type_id = cal.period_type_id
                              AND BITAND(cal.record_type_id, :l_record_type_id)= :l_record_type_id
                              AND sumry.parent_sales_group_id = :l_sg_id_num
                              AND cal.xtd_flag =  ''Y''
                              AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date) ';

          l_where_clause4:= ' WHERE sumry.effective_time_id = cal.time_id
                             AND sumry.effective_period_type_id = cal.period_type_id
                             AND BITAND(cal.record_type_id, :l_record_type_id)= :l_record_type_id
                             AND sumry.sales_group_id = :l_sg_id_num ';

        if(l_resource_id is not null) then
                l_where_clause4:= l_where_clause4 ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num';
             else
                l_where_clause4:=l_where_clause4 ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sg_id_num IS NULL then
                    l_where_clause4:=l_where_clause4 || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_where_clause4:=l_where_clause4 ||   ' AND sumry.parent_sales_group_id = :l_parent_sg_id_num ';
                end if;
             end if;

             l_where_clause4 := l_where_clause4 ||
             ' AND cal.xtd_flag =  ''Y''
             AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date) ';

          --Forecast amount by sales group and sales rep

          l_sql_stmnt2 :=  'SUM(CASE WHEN sumry.effective_time_id = :l_curr_page_time_id
                            AND cal.report_date=:l_curr_as_of_date
                            THEN sumry.forecast_amt'||l_currency_suffix||'
                                     ELSE NULL
                                     END)  BIL_MEASURE2,
                            SUM(CASE WHEN sumry.effective_time_id = :l_prev_page_time_id
                            AND cal.report_date =:l_prev_date
                            THEN sumry.forecast_amt'||l_currency_suffix||'
                                     ELSE NULL
                                     END)  BIL_MEASURE3,
                            NULL BIL_MEASURE5,
                            NULL BIL_MEASURE6,
                            NULL BIL_MEASURE8,
                            NULL BIL_MEASURE9,
                            NULL BIL_MEASURE14,
                            NULL BIL_MEASURE15 ';

          l_sql_stmnt4 :=  'SUM(CASE WHEN sumry.effective_time_id = :l_curr_page_time_id AND cal.report_date=:l_curr_as_of_date
                            THEN DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||'
                                        ,sumry.forecast_amt'||l_currency_suffix||')
                                     ELSE NULL
                                     END)  BIL_MEASURE2,
                            SUM(CASE WHEN sumry.effective_time_id = :l_prev_page_time_id AND cal.report_date =:l_prev_date
                            THEN DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||'
                                         ,sumry.forecast_amt'||l_currency_suffix||')
                                     ELSE NULL
                                     END)  BIL_MEASURE3,
                            NULL BIL_MEASURE5,
                            NULL BIL_MEASURE6,
                            NULL BIL_MEASURE8,
                            NULL BIL_MEASURE9,
                            NULL BIL_MEASURE14,
                            NULL BIL_MEASURE15 ';


          l_where_clause2 := ' WHERE sumry.txn_time_id = cal.time_id
                              AND sumry.txn_period_type_id = cal.period_type_id
                              AND BITAND(cal.record_type_id, :l_bitand_id)= :l_bitand_id
                              AND sumry.effective_period_type_id = :l_period_type
                              AND sumry.parent_sales_group_id = :l_sg_id_num
                               AND NVL(sumry.credit_type_id, :l_fst_crdt_type) = :l_fst_crdt_type
                              AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)
                              AND cal.xtd_flag =  ''Y''
                              AND sumry.effective_time_id IN (:l_curr_page_time_id, :l_prev_page_time_id) ';

            l_where_clause5 := ' WHERE sumry.txn_time_id = cal.time_id
                              AND sumry.txn_period_type_id = cal.period_type_id
                              AND BITAND(cal.record_type_id, :l_bitand_id)= :l_bitand_id
                              AND sumry.effective_period_type_id = :l_period_type
                              AND sumry.sales_group_id = :l_sg_id_num ';

             if(l_resource_id is not null) then
                l_where_clause5:= l_where_clause5 ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num';
             else
                l_where_clause5:=l_where_clause5 ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sg_id_num IS NULL then
                    l_where_clause5:=l_where_clause5 || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_where_clause5:=l_where_clause5 ||   ' AND sumry.parent_sales_group_id = :l_parent_sg_id_num ';
                end if;
             end if;

             l_where_clause5 := l_where_clause5 ||
                              ' AND NVL(sumry.credit_type_id, :l_fst_crdt_type) = :l_fst_crdt_type
                              AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)
                              AND cal.xtd_flag =  ''Y''
                              AND sumry.effective_time_id IN (:l_curr_page_time_id, :l_prev_page_time_id) ';

          --Booked and recogrnized by sales group and sales rep

          l_sql_stmnt3 := 'NULL BIL_MEASURE2,
                           NULL BIL_MEASURE3,
                           NULL BIL_MEASURE5,
                           NULL BIL_MEASURE6,
                           SUM(CASE WHEN cal.report_date=:l_curr_as_of_date THEN
                                (sumry.net_booked_amt_g'||l_isc_currency_suffix||')
                                     ELSE NULL
                                     END)  BIL_MEASURE8,
                           SUM(CASE WHEN cal.report_date =:l_prev_date
                                    THEN net_booked_amt_g'||l_isc_currency_suffix||'
                                     ELSE NULL
                                     END)  BIL_MEASURE9,
                           SUM(CASE WHEN cal.report_date=:l_curr_as_of_date THEN
                                (sumry.recognized_amt_g'||l_isc_currency_suffix||')
                                     ELSE NULL
                                     END)  BIL_MEASURE14,
                           SUM(CASE WHEN cal.report_date =:l_prev_date
                                    THEN sumry.recognized_amt_g'||l_isc_currency_suffix||'
                                     ELSE NULL
                                     END)  BIL_MEASURE15 ';
--Removed sumry.cat_top_node_flag =''Y'' for bug 3640113

          l_where_clause3 := ' WHERE  sumry.parent_grp_id = :l_sg_id_num
                                AND sumry.grp_marker <> ''TOP GROUP''
                               AND sumry.time_id = cal.time_id
                               AND cal.report_date in (:l_curr_as_of_date, :l_prev_date)
                               AND cal.period_type_id = sumry.period_type_id
                               AND cal.xtd_flag =  ''Y''
                               AND BITAND(cal.record_type_id,:l_record_type_id) = :l_record_type_id';

          l_where_clause6 := ' WHERE sumry.sales_grp_id = :l_sg_id_num ';
          if(l_resource_id is not null) then
                l_where_clause6:= l_where_clause6 ||
                    ' AND sumry.resource_id = :l_resource_id AND sumry.parent_grp_id = :l_sg_id_num';
             else
                l_where_clause6:=l_where_clause6 ||
                    ' AND sumry.resource_id IS NULL ';
                if l_parent_sg_id_num IS NULL then
                    l_where_clause6:=l_where_clause6 || ' AND sumry.parent_grp_id = sumry.sales_grp_id ';
                else
                   l_where_clause6:=l_where_clause6 ||   ' AND sumry.parent_grp_id = :l_parent_sg_id_num ';
                end if;
             end if;

             l_where_clause6 := l_where_clause6 ||
                               ' AND sumry.time_id = cal.time_id
                               AND cal.report_date in (:l_curr_as_of_date, :l_prev_date)
                               AND cal.period_type_id = sumry.period_type_id
                               AND cal.xtd_flag =  ''Y''
                               AND BITAND(cal.record_type_id,:l_record_type_id) = :l_record_type_id';

          l_insert_stmnt  := 'INSERT INTO BIL_BI_RPT_TMP1 (VIEWBY, VIEWBYID, SORTORDER,BIL_MEASURE2,BIL_MEASURE3,
                                                           BIL_MEASURE5,BIL_MEASURE6,BIL_MEASURE8, BIL_MEASURE9,
                                                           BIL_MEASURE14,BIL_MEASURE15, BIL_URL1, BIL_URL2)';

          l_inner_select := ' SELECT VIEWBY,VIEWBYID,SORTORDER,SUM(BIL_MEASURE2) BIL_MEASURE2,SUM(BIL_MEASURE3) BIL_MEASURE3
                                    ,SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE6) BIL_MEASURE6
                                    ,SUM(BIL_MEASURE8) BIL_MEASURE8,SUM(BIL_MEASURE9) BIL_MEASURE9
                                    ,SUM(BIL_MEASURE14) BIL_MEASURE14,SUM(BIL_MEASURE15) BIL_MEASURE15 ';

          execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';


            --l_denorm is used in the forecast and ISC query, product where clause
            --is ignored since it is assigned locally.
          BIL_BI_UTIL_PKG.GET_PRODUCT_WHERE_CLAUSE(p_viewby       => l_viewby,
                                                   p_prodcat      => l_prodcat_id,
                                                   x_denorm       => l_denorm,
                                                   x_where_clause => l_product_where_clause);

            --reusing the local var for product where clause
        BIL_BI_UTIL_PKG.get_PC_NoRollup_Where_Clause(p_viewby       => l_viewby,
                                                   p_prodcat      => l_prodcat_id,
                                                   x_denorm       => l_opty_denorm,
                                                   x_where_clause => l_product_where_clause);

          l_null_rem_clause := ' WHERE NOT ((BIL_MEASURE2 IS NULL OR BIL_MEASURE2 = 0)
                                           AND (BIL_MEASURE5 IS NULL OR BIL_MEASURE5 = 0)
                                           AND (BIL_MEASURE8 IS NULL OR BIL_MEASURE8 = 0)
                                           AND (BIL_MEASURE14 IS NULL OR BIL_MEASURE14 = 0)) ';

          CASE l_viewby
               WHEN 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
                   l_url_str := 'pFunctionName=BIL_BI_SLSMGMT_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
                   l_inner_select := l_inner_select ||',BIL_URL1, NULL BIL_URL2 FROM (';

                   IF l_prodcat_id = 'All'  THEN
                      l_sumry1 := 'BIL_BI_OPTY_G_MV';
                      l_sumry2 := 'BIL_BI_FST_G_MV';
                      --used for forecast
                      l_product_where_clause1 := ' ';
                      --used for booked and recognized
                      l_product_where_clause2 := ' AND sumry.cat_top_node_flag = ''Y'' ';
                   ELSE
                      l_sumry1 := 'BIL_BI_OPTY_PG_MV';
                      l_sumry2 := 'BIL_BI_FST_PG_MV';
                      --used for forecast
                      l_product_where_clause1 := ' AND sumry.product_category_id = :l_prodcat ';
                      --used for booked and recognized
                      l_product_where_clause2:= ' AND sumry.item_category_id = :l_prodcat ';

                   END IF;

                   l_sumry3 := 'ISC_DBI_SCR_002_MV';


                   l_from1 :=  ' FROM '||l_sumry1||' sumry, '||l_fii_struct ||' cal ';
                   l_from2 :=  ' FROM '||l_sumry2||' sumry, '||l_fii_struct ||' cal ';
                   l_from3 :=  ' FROM '||l_sumry3||' sumry, '||l_fii_struct ||' cal ';

                   x_custom_sql := 'SELECT decode(sumry.salesrep_id, NULL, grptl.group_name,
                    restl.resource_name) VIEWBY,
                    decode(sumry.salesrep_id, NULL, sumry.sales_group_id,
                    sumry.salesrep_id) VIEWBYID,
                    SORTORDER,BIL_MEASURE2,BIL_MEASURE3,BIL_MEASURE5,BIL_MEASURE6,
                    BIL_MEASURE8,BIL_MEASURE9,BIL_MEASURE14,BIL_MEASURE15 ,
                    BIL_URL1,
                    DECODE(sumry.salesrep_id, NULL, NULL,'''||l_drill_link||''') BIL_URL2
                    FROM (
                    SELECT /*+ NO_MERGE */ salesrep_id, sales_group_id,
                    SORTORDER,SUM(BIL_MEASURE2) BIL_MEASURE2,SUM(BIL_MEASURE3) BIL_MEASURE3
                    ,SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE6) BIL_MEASURE6
                    ,SUM(BIL_MEASURE8) BIL_MEASURE8,SUM(BIL_MEASURE9) BIL_MEASURE9
                    ,SUM(BIL_MEASURE14) BIL_MEASURE14,SUM(BIL_MEASURE15) BIL_MEASURE15
                    ,BIL_URL1
                    ,NULL  BIL_URL2
                    FROM (';

                   --Oppty by sales group and sales rep
                   x_custom_sql := x_custom_sql ||'SELECT  /*+ leading (cal) */ sumry.salesrep_id, sumry.sales_group_id
                                    ,(CASE WHEN sumry.salesrep_id IS NULL THEN 1 ELSE 2 END) SORTORDER
                                    ,'||l_sql_stmnt1||
                                   ',(CASE WHEN sumry.salesrep_id IS NULL THEN '''||l_url_str||''' ELSE NULL END) BIL_URL1
                                    ,NULL BIL_URL2
                                   '||l_from1||'
                                   '||l_opty_denorm||'
                                   '||l_where_clause1||'
                                   '||l_product_where_clause;
                IF l_resource_id IS NOT NULL THEN
                    x_custom_sql := x_custom_sql||' AND sumry.salesrep_id = :l_resource_id';
                END IF;

                x_custom_sql := x_custom_sql||'
                                   GROUP BY  (CASE WHEN sumry.salesrep_id IS NULL THEN 1 ELSE 2 END)
                                           ,sumry.salesrep_id , sumry.sales_group_id
                                           ,(CASE WHEN sumry.salesrep_id IS NULL THEN '''||l_url_str||''' ELSE NULL END) ';

                   -- Forecast by sales group and sales rep
                   x_custom_sql := x_custom_sql ||
                                  ' UNION ALL
                                   SELECT  /*+ leading (cal) */ sumry.salesrep_id, sumry.sales_group_id
                                         ,(CASE WHEN sumry.salesrep_id IS NULL THEN 1 ELSE 2 END) SORTORDER
                                         ,'||l_sql_stmnt2||
                                        ',(CASE WHEN sumry.salesrep_id IS NULL THEN '''||l_url_str||''' ELSE NULL END) BIL_URL1
                                         ,NULL BIL_URL2
                                        '||l_from2||'
                                        '||l_denorm||'
                                        '||l_where_clause2||'
                                         '||l_product_where_clause1;
                IF l_resource_id IS NOT NULL THEN
                    x_custom_sql := x_custom_sql||' AND sumry.salesrep_id = :l_resource_id';
                END IF;

                x_custom_sql := x_custom_sql||'
                                   GROUP BY (CASE WHEN sumry.salesrep_id IS NULL THEN 1 ELSE 2 END)
                                           ,sumry.salesrep_id, sumry.sales_group_id
                                           ,(CASE WHEN sumry.salesrep_id IS NULL THEN '''||l_url_str||''' ELSE NULL END) ';

                   --booked and recognized by sales group and sales rep
                   x_custom_sql := x_custom_sql ||
                                  ' UNION ALL
                                   SELECT  /*+ leading (cal) */ sumry.resource_id salesrep_id,sumry.sales_grp_id sales_group_id
                                          ,(CASE WHEN sumry.resource_id IS NULL THEN 1 ELSE 2 END) SORTORDER
                                          ,'||l_sql_stmnt3||
                                         ',(CASE WHEN sumry.resource_id IS NULL THEN '''||l_url_str||''' ELSE NULL END) BIL_URL1
                                          ,NULL BIL_URL2
                                         '||l_from3||'
                                         '||l_denorm||'
                                         '||l_where_clause3||'
                                         '||l_product_where_clause2;
                IF l_resource_id IS NOT NULL THEN
                    x_custom_sql := x_custom_sql||' AND sumry.resource_id = :l_resource_id';
                END IF;

                x_custom_sql := x_custom_sql||'
                                   GROUP BY (CASE WHEN sumry.resource_id IS NULL THEN 1 ELSE 2 END)
                                           , sumry.resource_id, sumry.sales_grp_id
                                           ,(CASE WHEN sumry.resource_id IS NULL THEN '''||l_url_str||''' ELSE NULL END) ';

                   x_custom_sql := x_custom_sql ||' ) group by salesrep_id, sales_group_id,
                                        sortorder, BIL_URL1
                                    ) sumry, jtf_rs_groups_tl grptl,jtf_rs_resource_extns_tl restl
                                    where grptl.group_id = sumry.sales_group_id
                                           AND grptl.language = USERENV(''LANG'')
                                           AND restl.language(+) = USERENV(''LANG'')
                                           AND restl.resource_id(+) = sumry.salesrep_id ';


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


                  IF l_resource_id IS NULL THEN
                      IF l_prodcat_id = 'All'  THEN
                         EXECUTE IMMEDIATE l_insert_stmnt || x_custom_sql
                         USING l_curr_as_of_date
                             , l_prev_date, l_record_type_id, l_record_type_id
                             , l_sg_id_num, l_curr_as_of_date, l_prev_date --Opp

                             , l_curr_page_time_id, l_curr_as_of_date
                             , l_prev_page_time_id, l_prev_date,  l_bitand_id
                             , l_bitand_id,l_period_type, l_sg_id_num
                             , l_fst_crdt_type, l_fst_crdt_type
                             , l_curr_as_of_date, l_prev_date
                             , l_curr_page_time_id, l_prev_page_time_id --Frcst

                             , l_curr_as_of_date,  l_prev_date
                             , l_curr_as_of_date,  l_prev_date
                             , l_sg_id_num, l_curr_as_of_date
                             , l_prev_date, l_record_type_id, l_record_type_id;

                      ELSE
                         EXECUTE IMMEDIATE l_insert_stmnt || x_custom_sql
                         USING l_curr_as_of_date
                             , l_prev_date, l_record_type_id, l_record_type_id
                             , l_sg_id_num, l_curr_as_of_date
                             , l_prev_date,  l_prodcat_id --Opp

                             , l_curr_page_time_id, l_curr_as_of_date,  l_prev_page_time_id
                             , l_prev_date,  l_bitand_id,l_bitand_id, l_period_type, l_sg_id_num
                             , l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                             , l_prev_date, l_curr_page_time_id, l_prev_page_time_id, l_prodcat_id --Frcst

                             , l_curr_as_of_date, l_prev_date
                             , l_curr_as_of_date,  l_prev_date
                             , l_sg_id_num, l_curr_as_of_date
                             , l_prev_date, l_record_type_id,l_record_type_id,l_prodcat_id;
                      END IF;
                   ELSE
                      IF l_prodcat_id = 'All'  THEN
                         EXECUTE IMMEDIATE l_insert_stmnt || x_custom_sql
                         USING l_curr_as_of_date, l_prev_date
                             , l_record_type_id, l_record_type_id,l_sg_id_num, l_curr_as_of_date
                             , l_prev_date,l_resource_id --Opp

                             , l_curr_page_time_id, l_curr_as_of_date, l_prev_page_time_id
                             , l_prev_date,  l_bitand_id, l_bitand_id,l_period_type, l_sg_id_num
                             , l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                             , l_prev_date, l_curr_page_time_id, l_prev_page_time_id,l_resource_id --Frcst

                             , l_curr_as_of_date,  l_prev_date
                             , l_curr_as_of_date, l_prev_date
                             , l_sg_id_num, l_curr_as_of_date
                             , l_prev_date, l_record_type_id, l_record_type_id,l_resource_id;

                      ELSE
                         EXECUTE IMMEDIATE l_insert_stmnt || x_custom_sql
                         USING l_curr_as_of_date, l_prev_date
                             , l_record_type_id, l_record_type_id, l_sg_id_num, l_curr_as_of_date
                             , l_prev_date,  l_prodcat_id,l_resource_id --Opp

                             , l_curr_page_time_id, l_curr_as_of_date,  l_prev_page_time_id
                             , l_prev_date,  l_bitand_id,l_bitand_id, l_period_type, l_sg_id_num
                             , l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                             , l_prev_date, l_curr_page_time_id, l_prev_page_time_id, l_prodcat_id,l_resource_id --Frcst

                             , l_curr_as_of_date,  l_prev_date
                             , l_curr_as_of_date,  l_prev_date
                             , l_sg_id_num, l_curr_as_of_date
                             , l_prev_date, l_record_type_id,l_record_type_id,l_prodcat_id,l_resource_id;
                      END IF;
                   END IF;

                   COMMIT;

                   x_custom_sql := ' SELECT * FROM ('|| l_outer_select ||' FROM
                                    (SELECT VIEWBY,VIEWBYID,SORTORDER,SUM(BIL_MEASURE2) BIL_MEASURE2,
                                    SUM(BIL_MEASURE3) BIL_MEASURE3
                                    ,SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE6) BIL_MEASURE6
                                    ,SUM(BIL_MEASURE8) BIL_MEASURE8,SUM(BIL_MEASURE9) BIL_MEASURE9
                                    ,SUM(BIL_MEASURE14) BIL_MEASURE14,SUM(BIL_MEASURE15) BIL_MEASURE15, BIL_URL1, BIL_URL2 FROM BIL_BI_RPT_TMP1
                                    GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1, BIL_URL2) ORDER BY SORTORDER,UPPER(VIEWBY))'|| l_null_rem_clause;


WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN

                  l_cat_assign := bil_bi_util_pkg.getLookupMeaning(p_lookuptype => 'BIL_BI_LOOKUPS'
                                                                           ,p_lookupcode => 'ASSIGN_CATEG');

                   l_cat_url := 'pFunctionName=BIL_BI_SLSMGMT_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
                   l_inner_select := l_inner_select ||
          ',DECODE(VIEWBY,'''||l_cat_assign||''',NULL,'''||l_drill_link||''') BIL_URL1 '||
                             ',BIL_URL2 FROM ';

                   IF (l_prodcat_id = 'All') THEN

                        l_product_where_clause1 := ' AND pcd.top_node_flag = ''Y'' '||
                                            ' AND sumry.product_category_id = pcd.id '||
                                            ' AND sumry.product_category_id = pcd.parent_id '||
					    ' AND sumry.product_category_id = pcd.child_id ';

                    --change following as per Surbhi's proposal?

                       l_product_where_clause2 := ' AND pcd.top_node_flag = ''Y''
                                                    AND pcd.parent_id = sumry.item_category_id
                                                    AND pcd.child_id = sumry.item_category_id
                                                    AND sumry.item_category_id = pcd.id
                                                    AND sumry.cat_top_node_flag = ''Y'' ';


                   ELSE

                        l_product_where_clause1 :=  '  AND sumry.product_category_id = pcd.child_id '||
				                    '  AND pcd.parent_id=:l_prodcat_id AND pcd.child_id = pcd.id AND '||
				                    ' NOT((assign_to_cat = 0 AND pcd.child_id = pcd.parent_id)) ' ;

                       l_product_where_clause2 := ' AND pcd.parent_id = :l_prodcat
                                                    AND pcd.id = pcd.child_id
                                                    AND sumry.item_category_id = pcd.child_id
                                                    AND sumry.item_category_id = pcd.id
                                                    AND ((pcd.child_id <> pcd.parent_id AND pcd.leaf_node_flag = ''N'')
                                                         OR pcd.leaf_node_flag = ''Y'') ';
                   END IF;


                   l_sumry1 := 'BIL_BI_OPTY_PG_MV';
                   l_sumry2 := 'BIL_BI_FST_PG_MV';
                   l_sumry3 := 'ISC_DBI_SCR_002_MV';

                   l_from1 :=  ' FROM '|| l_sumry1 ||' sumry, '|| l_fii_struct ||' cal ';
                   l_from2 :=  ' FROM '|| l_sumry2 ||' sumry, '|| l_fii_struct ||' cal ';
                   l_from3 :=   l_fii_struct ||' cal, '|| l_sumry3 ||' sumry ';

                   IF l_prodcat_id = 'All' THEN

                   	l_unassigned_value:= bil_bi_util_pkg.GET_UNASSIGNED_PC;

                        --Opportunity by prod cat
                        x_custom_sql := l_inner_select ||

                          ' (select decode(opty.viewbyid, -1,:l_unassigned_value,
                                               mtl.DESCRIPTION || '' ('' || mtl.CATEGORY_CONCAT_SEGS ||'')'') VIEWBY, VIEWBYID, SORTORDER,BIL_MEASURE2,
                           BIL_MEASURE3,
                           BIL_MEASURE5,
                           BIL_MEASURE6,
                           BIL_MEASURE8,
                           BIL_MEASURE9,
                           BIL_MEASURE14,
                           BIL_MEASURE15,
                           NULL  BIL_URL1,
                            DECODE(opty.viewbyid,''-1'',NULL,'''||l_cat_url||''') BIL_URL2 '||
                            ' from (
                                       SELECT /*+ leading (cal) */
                                               pcd.parent_id VIEWBYID
                                               ,1 SORTORDER
                                               ,'||l_sql_stmnt1||
                                           l_from1 ||'  '||l_opty_denorm||' '|| l_where_clause4 ||
                                           ' '||l_product_where_clause||'
                                           GROUP BY pcd.parent_id
                                           ) opty,
                                           mtl_categories_v mtl '||
				      ' WHERE mtl.category_id (+) = opty.viewbyid';


                        --Forecast by prod cat
                        x_custom_sql := x_custom_sql ||' UNION ALL
                                        SELECT /*+ leading (cal) */  pcd.value VIEWBY
                                               ,pcd.id VIEWBYID
                                               ,1 SORTORDER
                                               ,'||l_sql_stmnt4||
                                               ',NULL BIL_URL1
                                               ,DECODE(pcd.id, ''-1'',NULL, '''||l_cat_url||''') BIL_URL2 '||
                                          l_from2 ||' '|| l_denorm ||' '|| l_where_clause5 ||' '|| l_product_where_clause1
                                          ||' GROUP BY pcd.value, pcd.id';

                        --Booked and recognized by prod cat
                        x_custom_sql := x_custom_sql ||' UNION ALL
                                        SELECT /*+ leading (cal) */ pcd.value VIEWBY
                                                ,pcd.id VIEWBYID
                                                ,1 SORTORDER
                                                ,'||l_sql_stmnt3||
                                               ',NULL BIL_URL1
                                                ,DECODE(pcd.id, ''-1'',NULL, '''||l_cat_url||''') BIL_URL2
                                                FROM '||
                                          l_from3 ||' '|| l_denorm ||' '|| l_where_clause6 ||' '|| l_product_where_clause2
                                          ||' GROUP BY pcd.value, pcd.id';

                        x_custom_sql := x_custom_sql ||') GROUP BY SORTORDER,VIEWBYID,VIEWBY,BIL_URL1,BIL_URL2 ORDER BY SORTORDER, VIEWBY';


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


 if(l_resource_id is not null) then
            EXECUTE IMMEDIATE l_insert_stmnt||x_custom_sql
                USING l_unassigned_value, l_curr_as_of_date,l_prev_date
                                ,l_record_type_id, l_record_type_id
                                ,l_sg_id_num,l_resource_id,l_sg_id_num,l_curr_as_of_date
                                ,l_prev_date,'Y' --Opp

                                ,l_curr_page_time_id, l_curr_as_of_date,  l_prev_page_time_id
                                ,l_prev_date,l_bitand_id, l_bitand_id,l_period_type
                                 ,l_sg_id_num,l_resource_id,l_sg_id_num
                                 ,l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                                ,l_prev_date, l_curr_page_time_id, l_prev_page_time_id --Forecast

                                ,l_curr_as_of_date,  l_prev_date
                                ,l_curr_as_of_date,  l_prev_date
                                ,l_sg_id_num,l_resource_id,l_sg_id_num,l_curr_as_of_date
                                ,l_prev_date,l_record_type_id,l_record_type_id;
            COMMIT;
        else
            if (l_parent_sg_id_num is not null) then
            EXECUTE IMMEDIATE l_insert_stmnt||x_custom_sql
                USING l_unassigned_value, l_curr_as_of_date,l_prev_date
                                ,l_record_type_id, l_record_type_id
                                ,l_sg_id_num,l_parent_sg_id_num,l_curr_as_of_date
                                ,l_prev_date,'Y' --Opp

                                ,l_curr_page_time_id, l_curr_as_of_date,  l_prev_page_time_id
                                ,l_prev_date,  l_bitand_id, l_bitand_id,l_period_type
                                ,l_sg_id_num,l_parent_sg_id_num ,l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                                ,l_prev_date, l_curr_page_time_id, l_prev_page_time_id --Forecast

                                ,l_curr_as_of_date,  l_prev_date
                                ,l_curr_as_of_date,  l_prev_date
                                ,l_sg_id_num,l_parent_sg_id_num,l_curr_as_of_date
                                ,l_prev_date,l_record_type_id,l_record_type_id;

            COMMIT;
            else
                  EXECUTE IMMEDIATE l_insert_stmnt||x_custom_sql
                USING l_unassigned_value, l_curr_as_of_date,l_prev_date
                                ,l_record_type_id, l_record_type_id
                                ,l_sg_id_num,l_curr_as_of_date
                                ,l_prev_date,'Y' --Opp

                                ,l_curr_page_time_id, l_curr_as_of_date,  l_prev_page_time_id
                                ,l_prev_date,  l_bitand_id, l_bitand_id,l_period_type
                                ,l_sg_id_num,l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                                ,l_prev_date, l_curr_page_time_id, l_prev_page_time_id --Forecast

                                ,l_curr_as_of_date, l_prev_date
                                ,l_curr_as_of_date,  l_prev_date
                                ,l_sg_id_num,l_curr_as_of_date
                                ,l_prev_date,l_record_type_id,l_record_type_id;
                COMMIT;
            end if;
        end if;

 x_custom_sql := ' SELECT * FROM ('|| l_outer_select ||' FROM
                                    (SELECT VIEWBY,VIEWBYID,SORTORDER,SUM(BIL_MEASURE2) BIL_MEASURE2,
                                    SUM(BIL_MEASURE3) BIL_MEASURE3
                                    ,SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE6) BIL_MEASURE6
                                    ,SUM(BIL_MEASURE8) BIL_MEASURE8,SUM(BIL_MEASURE9) BIL_MEASURE9
                                    ,SUM(BIL_MEASURE14) BIL_MEASURE14,SUM(BIL_MEASURE15) BIL_MEASURE15, BIL_URL1, BIL_URL2 FROM BIL_BI_RPT_TMP1
                                    GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1, BIL_URL2) ORDER BY SORTORDER,UPPER(VIEWBY))'|| l_null_rem_clause;


                   ELSE -- prodcat selected

--                           l_cat_assign := bil_bi_util_pkg.getLookupMeaning(p_lookuptype => 'BIL_BI_LOOKUPS'
--                                                                           ,p_lookupcode => 'ASSIGN_CATEG');


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE =>    g_pkg ||l_proc || ' Product cat is not all ',
		                                    MESSAGE =>   'Product cat '||l_prodcat_id);

                     END IF;


                            --forecast with prodcat selected
                           x_custom_sql := l_inner_select;
                            x_custom_sql := x_custom_sql||
                                          ' (SELECT /*+ leading (cal) */ decode(pcd.parent_id,pcd.child_id,'||
								            ' decode(sumry.assign_to_cat,0,pcd.value,:l_cat_assign), '||
								            ' pcd.value) VIEWBY '||
								              ',pcd.id VIEWBYID'||
							                  ', decode(pcd.parent_id,pcd.id, 1, 2) sortorder,'
                                                 ||l_sql_stmnt4||
                                                 '   ,       NULL   BIL_URL1
                                                  ,DECODE(pcd.parent_id, pcd.child_id, NULL, '''||l_cat_url||''') BIL_URL2 '||
                                           l_from2 ||' '|| l_denorm || l_where_clause5 || l_product_where_clause1||
                                           ' GROUP BY decode(pcd.parent_id,pcd.child_id,'||
								            ' decode(sumry.assign_to_cat,0,pcd.value,:l_cat_assign), '||
			     ' pcd.value),pcd.id,decode(pcd.parent_id,pcd.id, 1, 2),
  DECODE(pcd.parent_id, pcd.child_id, NULL, '''||l_cat_url||''')  ';

                            x_custom_sql := x_custom_sql ||') GROUP BY SORTORDER,VIEWBYID,VIEWBY,BIL_URL1,BIL_URL2 ';


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


 if(l_resource_id is not null) then
            EXECUTE IMMEDIATE l_insert_stmnt||x_custom_sql
                USING l_cat_assign,l_curr_page_time_id, l_curr_as_of_date
                                  , l_prev_page_time_id, l_prev_date
                                  , l_bitand_id, l_bitand_id, l_period_type
                                  , l_sg_id_num,l_resource_id,l_sg_id_num,l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                                  , l_prev_date, l_curr_page_time_id, l_prev_page_time_id
                                  , l_prodcat_id,l_cat_assign --Frcst
                                  ;
                COMMIT;
        else
            if (l_parent_sg_id_num is not null) then
            EXECUTE IMMEDIATE l_insert_stmnt||x_custom_sql
                USING l_cat_assign,l_curr_page_time_id, l_curr_as_of_date
                                  , l_prev_page_time_id, l_prev_date
                                  , l_bitand_id, l_bitand_id, l_period_type
                                  , l_sg_id_num,l_parent_sg_id_num, l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                                  , l_prev_date, l_curr_page_time_id, l_prev_page_time_id
                                  , l_prodcat_id,l_cat_assign --Frcst
                                  ;
                COMMIT;
            else
                 EXECUTE IMMEDIATE l_insert_stmnt||x_custom_sql
                USING l_cat_assign,l_curr_page_time_id, l_curr_as_of_date
                                  , l_prev_page_time_id, l_prev_date
                                  , l_bitand_id, l_bitand_id, l_period_type
                                  ,l_sg_id_num,l_fst_crdt_type, l_fst_crdt_type,  l_curr_as_of_date
                                  , l_prev_date, l_curr_page_time_id, l_prev_page_time_id
                                  , l_prodcat_id,l_cat_assign --Frcst
                                  ;
                COMMIT;
            end if;
        end if;

                              --Oppty with prodcat selected
                            x_custom_sql := l_inner_select;
                           x_custom_sql := x_custom_sql ||' (SELECT /*+ leading (cal) */
                           DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', :l_cat_assign, pcd.value), pcd.value) VIEWBY
                                                ,pcd.id VIEWBYID
                                                ,DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', 1, 2), 2) SORTORDER '||
                                                 ','||l_sql_stmnt1||
                                                 ',NULL BIL_URL1
                                                  ,DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL2 '||
                                           l_from1 ||' '|| l_opty_denorm ||' '|| l_where_clause4 ||' '|| l_product_where_clause||
                                           '  GROUP BY DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', :l_cat_assign, pcd.value), pcd.value),pcd.id,
                                                                   DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', 1, 2), 2),
                                                                           DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''')';

                            --Booked and recognized with prodcat selected
                           x_custom_sql := x_custom_sql ||
                                           ' UNION ALL
                                             SELECT  pcd.value VIEWBY
                                                   ,pcd.id VIEWBYID
                                                   ,2 SORTORDER,'||l_sql_stmnt3||
                                                  ',NULL BIL_URL1
                                                   ,DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL2
                                                   FROM  ENI_ITEM_PROD_CAT_LOOKUP_V pcd, ' || l_from3 ||' '|| l_where_clause6 ||' '|| l_product_where_clause2
                                            ||' GROUP BY 2,
pcd.value,pcd.id,DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') ';

                           x_custom_sql := x_custom_sql ||') GROUP BY SORTORDER,VIEWBYID,VIEWBY,BIL_URL1,BIL_URL2 ';


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

if(l_resource_id is not null) then
            EXECUTE IMMEDIATE l_insert_stmnt||x_custom_sql
                USING l_cat_assign,l_curr_as_of_date, l_prev_date
                                  , l_record_type_id, l_record_type_id
                                  , l_sg_id_num,l_resource_id,l_sg_id_num, l_curr_as_of_date
                                  , l_prev_date,l_prodcat_id,l_cat_assign --Oppty

                                  , l_curr_as_of_date, l_prev_date
                                  , l_curr_as_of_date, l_prev_date
                                  , l_sg_id_num,l_resource_id,l_sg_id_num
                                  ,l_curr_as_of_date
                                  , l_prev_date, l_record_type_id, l_record_type_id,l_prodcat_id;
                COMMIT;
        else
            if (l_parent_sg_id_num is not null) then
            EXECUTE IMMEDIATE l_insert_stmnt||x_custom_sql
                USING l_cat_assign, l_curr_as_of_date, l_prev_date
                                  , l_record_type_id, l_record_type_id
                                  , l_sg_id_num,l_parent_sg_id_num, l_curr_as_of_date
                                  , l_prev_date,l_prodcat_id,l_cat_assign --Oppty

                                  , l_curr_as_of_date, l_prev_date
                                  , l_curr_as_of_date, l_prev_date
                                  , l_sg_id_num,l_parent_sg_id_num
                                  , l_curr_as_of_date
                                  , l_prev_date, l_record_type_id, l_record_type_id,l_prodcat_id;
                COMMIT;
            else
                 EXECUTE IMMEDIATE  l_insert_stmnt||x_custom_sql
                USING l_cat_assign, l_curr_as_of_date, l_prev_date
                                  , l_record_type_id, l_record_type_id
                                  , l_sg_id_num,l_curr_as_of_date
                                  , l_prev_date,l_prodcat_id,l_cat_assign --Oppty

                                  , l_curr_as_of_date, l_prev_date
                                  , l_curr_as_of_date, l_prev_date
                                  , l_sg_id_num,l_curr_as_of_date
                                  , l_prev_date, l_record_type_id, l_record_type_id,l_prodcat_id;


                COMMIT;
            end if;
        end if;


                           IF bil_bi_util_pkg.isleafnode(l_prodcat_id) THEN
                              x_custom_sql := 'SELECT * FROM ('|| l_outer_select ||
                                             ' FROM ('||
                                                  ' SELECT VIEWBY, VIEWBYID, sortorder,BIL_MEASURE2,
                                                           BIL_MEASURE3, BIL_MEASURE5,BIL_MEASURE6,
                                                           BIL_MEASURE8, BIL_MEASURE9,  '||
                                                          'BIL_MEASURE14,BIL_MEASURE15, BIL_URL1, BIL_URL2 '||
                                                  ' FROM BIL_BI_RPT_TMP1 '||
                                                  ' WHERE SORTORDER = 1 '||
                                                  ' UNION ALL '||
                                                  ' SELECT VIEWBY, VIEWBYID, ''2'' SORTORDER, BIL_MEASURE2,
                                                           BIL_MEASURE3, BIL_MEASURE5,BIL_MEASURE6,
                                                           BIL_MEASURE8, BIL_MEASURE9,  '||
                                                          'BIL_MEASURE14,BIL_MEASURE15, '||
                                       'DECODE(viewby,'''||l_cat_assign||''',NULL,'''||l_drill_link||''') BIL_URL1, ' ||
                                                           ' NULL BIL_URL2 '||
                                                  ' FROM ('||
                                                          ' SELECT SUM(RN) RN, MAX(VIEWBY) VIEWBY, MAX(VIEWBYID) VIEWBYID, '||
                                                          ' SUM(BIL_MEASURE2) BIL_MEASURE2, SUM(BIL_MEASURE3) BIL_MEASURE3, '||
                                                          ' SUM(BIL_MEASURE5) BIL_MEASURE5, SUM(BIL_MEASURE6) BIL_MEASURE6, '||
                                                          ' SUM(BIL_MEASURE8) BIL_MEASURE8, SUM(BIL_MEASURE9) BIL_MEASURE9, '||
                                                          ' SUM(BIL_MEASURE14) BIL_MEASURE14, SUM(BIL_MEASURE15) BIL_MEASURE15 '||
                                                          ' FROM ('||
                                                                  ' SELECT ROWNUM RN, VIEWBY, VIEWBYID, TRUNC(BIL_MEASURE2,3) BIL_MEASURE2,'||
                                                                  ' TRUNC(BIL_MEASURE3,3) BIL_MEASURE3, BIL_MEASURE5, BIL_MEASURE6,TRUNC(BIL_MEASURE8,3) BIL_MEASURE8, '||
                                                                  ' TRUNC(BIL_MEASURE9,3) BIL_MEASURE9,  TRUNC(BIL_MEASURE14,3) BIL_MEASURE14, TRUNC(BIL_MEASURE15,3) BIL_MEASURE15 '||
                                                                  ' FROM BIL_BI_RPT_TMP1 '||
                                                                  ' WHERE SORTORDER <> 1 '||
                                                                  ' UNION ALL '||
                                                                  ' SELECT -ROWNUM RN, NULL VIEWBY, VIEWBYID, NULL BIL_MEASURE2,'||
                                                                  ' NULL BIL_MEASURE3, NULL BIL_MEASURE5, NULL BIL_MEASURE6,-TRUNC(BIL_MEASURE8,3) BIL_MEASURE8, '||
                                                                  ' -TRUNC(BIL_MEASURE9,3) BIL_MEASURE9,  -TRUNC(BIL_MEASURE14,3) BIL_MEASURE14, -TRUNC(BIL_MEASURE15,3) BIL_MEASURE15 '||
                                                                  ' FROM BIL_BI_RPT_TMP1 '||
                                                                  ' WHERE SORTORDER = 1 '||
                                                               ' ) '||
                                                          ' ) '||
                                                  ' WHERE NOT(RN = 0 AND  BIL_MEASURE2 = 0 AND BIL_MEASURE3 = 0 '||
                                                              ' AND BIL_MEASURE5 = 0 AND BIL_MEASURE6 = 0 AND BIL_MEASURE8 = 0'||
                                                              ' AND BIL_MEASURE9 = 0 AND BIL_MEASURE14 = 0 AND BIL_MEASURE15 = 0 ) '||
                                                  ' ) ORDER BY SORTORDER, UPPER(VIEWBY)'||
                                                  ') '|| l_null_rem_clause;

                           ELSE
                               x_custom_sql := ' SELECT * FROM ('|| l_outer_select ||' FROM
                                    (SELECT VIEWBY,VIEWBYID,SORTORDER,SUM(BIL_MEASURE2) BIL_MEASURE2,
                                    SUM(BIL_MEASURE3) BIL_MEASURE3
                                    ,SUM(BIL_MEASURE5) BIL_MEASURE5,SUM(BIL_MEASURE6) BIL_MEASURE6
                                    ,SUM(BIL_MEASURE8) BIL_MEASURE8,SUM(BIL_MEASURE9) BIL_MEASURE9
                                    ,SUM(BIL_MEASURE14) BIL_MEASURE14,SUM(BIL_MEASURE15) BIL_MEASURE15, BIL_URL1, BIL_URL2 FROM BIL_BI_RPT_TMP1
                                    GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1, BIL_URL2) ORDER BY SORTORDER,UPPER(VIEWBY))'|| l_null_rem_clause;


                           END IF;

                   END IF; -- End category selected check
          END CASE;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| 'Final Query to PMV ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


          x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
          l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

          l_bind_ctr := 1;
          l_custom_rec.attribute_name :=':l_sg_id_num';
          l_custom_rec.attribute_value := l_sg_id_num;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

      ELSE --No valid parameters
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

           fnd_message.set_name('FND','SQL_PLSQL_ERROR');
           fnd_message.set_token('ERROR' ,SQLCODE);
           fnd_message.set_token('REASON',SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

          END IF;

        RAISE;

 END BIL_BI_SALES_MGMT_SUMRY;




/*******************************************************************************
 * Name    : Procedure BIL_BI_OPPTY_OVERVIEW
 * Author  : W.Mirza
 * Date    : August 16, 2002
 * Purpose : Opportunity Overview Sales Intelligence report and charts.
 *
 *           Copyright (c) 2002 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * p_bis_map_tbl           PL/SQL table containing sql query
 *
 *
 * Date     Author     Description
 * ----     ------     -----------
 * 08/16/02 wmirza     Initial version
 * 10/14/02 wmirza     Added date check to CASE stmts in query.
 * 10/27/02 spraturi   Converted procedure to use temporary tables.
 * 11/15/02 wmirza     Added debug blocks and NOCOPY hint.
 *
 * 09/08/03 oanandam   DBI 6.1 Initial Version
 * 09/02/04 ppatil     DBI 7.0 Initial Version
 * 11/02/04 ppatil     Open Count Related changes.
 * 26 Nov 2004 hrpandey Drill Down to Oppty Line Detail report
 ******************************************************************************/
PROCEDURE BIL_BI_OPPTY_OVERVIEW( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                               ,x_custom_sql         OUT NOCOPY VARCHAR2
                               ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
  IS

    l_period_type               VARCHAR2(50);
    l_sg_id                     VARCHAR2(50);
    l_resource_id               VARCHAR2(50);
    l_conv_rate_selected        VARCHAR2(50);
    l_curr_page_time_id         NUMBER;
    l_prev_page_time_id         NUMBER;
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
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
    l_sql_error_desc            VARCHAR2(5000);
    l_sg_id_num                 NUMBER;
    l_fst_category              VARCHAR2(50);
    l_fst_crdt_type             VARCHAR2(50);
    l_debug_mode                VARCHAR2(50);
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_inner_where_clause        VARCHAR2(1000);
    l_inner_where_clause1       VARCHAR2(1000);
    l_inner_where_clause2    	VARCHAR2(1000);
    l_inner_where_clause3    	VARCHAR2(1000);
    l_null_rem_where_clause    	VARCHAR2(4000);
    l_outer_select              VARCHAR2(8000);
    l_inner_select              VARCHAR2(8000);
    l_inner_select1             VARCHAR2(8000);
    l_inner_select2             VARCHAR2(8000);
    l_inner_select3            	VARCHAR2(8000);

    l_custom_sql                VARCHAR2(32000);
    l_custom_sql1               VARCHAR2(32000);
    l_using                     VARCHAR2(10000);
    l_insert_stmnt              VARCHAR2(8000);
    l_prodcat_id                VARCHAR2(20);
    l_productcat_id             VARCHAR2(20);
    l_product_where_clause      VARCHAR2(1000);

    l_sumry                     VARCHAR2(50);
    l_denorm                    VARCHAR2(100);
    l_url                       VARCHAR2(1000);
    l_cat_assign                VARCHAR2(1000);
    l_productcat_cl             VARCHAR2(500);
    l_product_cl                VARCHAR2(500);
    l_cat_url                   VARCHAR2(500);
    l_prod_url                  VARCHAR2(500);
    l_sumry1                    VARCHAR2(50);
    l_sumry2                    VARCHAR2(50);
    l_url_str                   VARCHAR2(1000);
    l_cat_denorm         	    VARCHAR2(50);
    l_from1            		    VARCHAR2(1000);
    l_from2            		    VARCHAR2(1000);

    l_item            		    VARCHAR2(100);
    l_snap_date          	    DATE;
    l_proc                     	VARCHAR2(100);

    l_parent_sales_group_id	    NUMBER;
    l_yes			            VARCHAR2(1);
    l_parent_sls_grp_where_clause VARCHAR2(1000);

    l_unassigned_value 		   VARCHAR2(50);
    l_select			       VARCHAR2(4000);
    l_pc_sel			       VARCHAR2(500);
    l_pc_grp_by			       VARCHAR2(500);
    l_currency_suffix          VARCHAR2(5);
	l_drill_link              varchar2(4000);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

    l_prev_amt           VARCHAR2(1000);
    l_column_type        VARCHAR2(1000);
    l_snapshot_date      DATE;
    l_open_mv_new        VARCHAR2(1000);
    l_open_mv_new1       VARCHAR2(1000);
    l_prev_snap_date     DATE;
    l_pipe_select1       varchar2(4000);
    l_pipe_select2       varchar2(4000);
    l_pipe_select3       varchar2(4000);
    l_inner_where_pipe   varchar2(4000);


  BEGIN
    g_pkg := 'bil.patch.115.sql.BIL_BI_SALES_MGMT_RPTS_PKG.';
    l_region_id:= 'BIL_BI_OPPTY_OVERVIEW';
    l_parameter_valid:= FALSE;
    l_proc := 'BIL_BI_OPPTY_OVERVIEW.';
    l_yes := 'Y';
    g_sch_name := 'BIL';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '|| l_proc);

                     END IF;


    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl => p_page_parameter_tbl
                                    ,p_region_id       => l_region_id
                                    ,x_period_type       => l_period_type
                                    ,x_conv_rate_selected => l_conv_rate_selected
                                    ,x_sg_id         => l_sg_id
                    		    ,x_parent_sg_id		=> l_parent_sales_group_id
				    ,x_resource_id       => l_resource_id
                                    ,x_prodcat_id       => l_prodcat_id
                                    ,x_curr_page_time_id  => l_curr_page_time_id
                                    ,x_prev_page_time_id  => l_prev_page_time_id
                                    ,x_comp_type       => l_comp_type
                                    ,x_parameter_valid     => l_parameter_valid
                                    ,x_as_of_date       => l_curr_as_of_date
                                    ,x_page_period_type   => l_page_period_type
                                    ,x_prior_as_of_date   => l_prev_date
                                    ,x_record_type_id     => l_record_type_id
                                    ,x_viewby             => l_viewby );

/*
  bil_bi_util_pkg.get_latest_snap_date(p_page_parameter_tbl  => p_page_parameter_tbl
                                           ,p_as_of_date          => l_curr_as_of_date
                                           ,p_period_type         => NULL
                                           ,x_snapshot_date       => l_snap_date);
*/


   IF l_parameter_valid THEN
        --retrieve 'Item unassigned' message here. We should be retireving from Message dicts?
        l_cat_assign:=FND_MESSAGE.GET_STRING('BIL', 'BIL_BI_ASSIGN_CATEGORY');


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => ' l_cat_assign is '||l_cat_assign );


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Prod cat is '||nvl(l_prodcat_id, 0)||' Product is'||
                                            ' Lang '||USERENV('LANG'));

                     END IF;


        IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
        ELSE
            l_currency_suffix := '';
        END IF;

    --Not sure what PMV returns for 'All', as of now it returns NULL, so convert it to 'All'.
        IF l_prodcat_id IS NULL THEN
           l_prodcat_id := 'All';
        END IF;
        BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS( x_bitand_id => l_bitand_id
                                     ,x_calendar_id => l_calendar_id
                                     ,x_curr_date => l_bis_sysdate
                                     ,x_fii_struct => l_fii_struct );


        l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
        l_bitand_id := TO_NUMBER(REPLACE(l_bitand_id, ''''));
        l_calendar_id := TO_NUMBER(REPLACE(l_calendar_id, ''''));
        l_period_type  := TO_NUMBER(REPLACE(l_period_type , ''''));
    l_prodcat_id := replace(l_prodcat_id,'''','');

        l_rpt_str:='BIL_BI_OPOVER_R';


-- Get the Drill Link to the Opty Line Detail Report

l_drill_link := bil_bi_util_pkg.get_drill_links( p_view_by =>  l_viewby,
                                                 p_salesgroup_id =>   l_sg_id,
                                                 p_resource_id   =>    l_resource_id  );

/* Get the Prefix for the Open amt based upon Period Type and Compare To Params */


l_prev_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'O',
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

	    l_sql_error_desc := 'l_viewby              => '|| l_viewby||', '||
      'l_curr_page_time_id   => '|| l_curr_page_time_id ||', ' ||
      'l_prev_page_time_id   => '|| l_prev_page_time_id ||', ' ||
      'l_curr_as_of_date     => '|| l_curr_as_of_date ||', ' ||
      'l_prev_date          => '|| l_prev_date ||', ' ||
      'l_conv_rate_selected  => '|| l_conv_rate_selected ||', ' ||
      'l_bitand_id          => '|| l_bitand_id ||', ' ||
      'l_period_type          => '|| l_period_type ||', ' ||
      'l_sg_id               => '|| l_sg_id ||', ' ||
      'l_resource_id          => '|| l_resource_id ||', ' ||
      'l_bis_sysdate          => '|| l_bis_sysdate ||', ' ||
      'l_record_type_id      => '|| l_record_type_id ||', ' ||
      'l_calendar_id          => '|| l_calendar_id;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Parameters =>'||l_sql_error_desc);

  END IF;





--
/*** Query column mapping ***********************************************************************
*  Internal Name  Grand Total  Region Item Name
*  BIL_MEASURE1  BIL_MEASURE35   Total Opportunity Count
*  BIL_MEASURE2  BIL_MEASURE36  Total Opportunity
*  BIL_MEASURE3  BIL_MEASURE37  Prior Total Opportunity
*  BIL_MEASURE4  BIL_MEASURE38  Total Opportunity Change
*  BIL_MEASURE5  BIL_MEASURE39  Won Count
*  BIL_MEASURE6  BIL_MEASURE40  Won
*  BIL_MEASURE7  BIL_MEASURE41  Prior Won / KPI Prior Won
*  BIL_MEASURE8  BIL_MEASURE42  Won Change
*  BIL_MEASURE9  BIL_MEASURE43  Lost Count
*  BIL_MEASURE10  BIL_MEASURE44  Lost
*  BIL_MEASURE11  BIL_MEASURE45  Prior Lost / KPI Prior Lost
*  BIL_MEASURE12  BIL_MEASURE46  Lost Change
*  BIL_MEASURE13  BIL_MEASURE47  Open Count
*  BIL_MEASURE14  BIL_MEASURE48  Open
*  BIL_MEASURE15  BIL_MEASURE49  Prior Open / KPI Prior Open
*  BIL_MEASURE16  BIL_MEASURE50  Open Change
*  BIL_MEASURE17  BIL_MEASURE51  New Count
*  BIL_MEASURE18  BIL_MEASURE52  New
*  BIL_MEASURE19  BIL_MEASURE53  Prior New
*  BIL_MEASURE20  BIL_MEASURE54  New Change
*  BIL_MEASURE21  BIL_MEASURE55  No Opportunity Count
*  BIL_MEASURE22  BIL_MEASURE56  No Opportunity
*  BIL_MEASURE23  BIL_MEASURE57  Prior No Opportunity / KPI Prior No
*  BIL_MEASURE24  BIL_MEASURE58  No Opportunity Change
*  BIL_MEASURE25  BIL_MEASURE59  Won %
*  BIL_MEASURE74  BIL_MEASURE76  Won% Prior
*  BIL_MEASURE26  BIL_MEASURE60  Loss %
*  BIL_MEASURE27  BIL_MEASURE61  Open %
*  BIL_MEASURE28  BIL_MEASURE62  Win/Loss Ratio
*  BIL_MEASURE34  BIL_MEASURE68  KPI Prior Win/Loss Ratio
*  BIL_URL1            Sales Group URL
*  BIL_URL2            Product Category URL
*  BIL_TITLE1            Won, Lost, Open Opportunity Value
*  BIL_TITLE2            Won, Lost, Open % of Total
*  BIL_TITLE3            Won, Lost, Open Opportunity Count
*  BIL_URL3            URL to Drill to the Opty Line Detail rep from Won Column
*  BIL_URL4            URL to Drill to the Opty Line Detail rep from Lost Column
*  BIL_URL5            URL to Drill to the Opty Line Detail rep from Open Column
*  BIL_URL6            URL to Drill to the Opty Line Detail rep from No Opportunity Column
**************************************************************************************************/

   l_outer_select:= 'SELECT VIEWBY
      ,VIEWBYID
      , BIL_MEASURE2
      , BIL_MEASURE3
      ,(((BIL_MEASURE2 - BIL_MEASURE3) / ABS(DECODE(BIL_MEASURE3, 0, NULL, BIL_MEASURE3))) * 100) BIL_MEASURE4
      ,BIL_MEASURE6
      ,BIL_MEASURE7
      ,(((BIL_MEASURE6 - BIL_MEASURE7) / ABS(DECODE(BIL_MEASURE7, 0, NULL, BIL_MEASURE7))) * 100) BIL_MEASURE8
      ,BIL_MEASURE10
      ,BIL_MEASURE11
      ,(((BIL_MEASURE10 - BIL_MEASURE11) / ABS(DECODE(BIL_MEASURE11, 0, NULL, BIL_MEASURE11))) * 100) BIL_MEASURE12
      ,BIL_MEASURE14
      ,BIL_MEASURE15
      ,(((BIL_MEASURE14 - BIL_MEASURE15) / ABS(DECODE(BIL_MEASURE15, 0, NULL, BIL_MEASURE15))) * 100) BIL_MEASURE16
      ,BIL_MEASURE18
      ,BIL_MEASURE19
      ,(((BIL_MEASURE18 - BIL_MEASURE19) / ABS(DECODE(BIL_MEASURE19, 0, NULL, BIL_MEASURE19))) * 100) BIL_MEASURE20
      ,BIL_MEASURE22
      ,BIL_MEASURE23
      ,(((BIL_MEASURE22 - BIL_MEASURE23) / ABS(DECODE(BIL_MEASURE23, 0, NULL, BIL_MEASURE23))) * 100) BIL_MEASURE24
      ,(((BIL_MEASURE6) / DECODE(BIL_MEASURE2, 0, NULL, BIL_MEASURE2)) * 100) BIL_MEASURE25
      ,(((BIL_MEASURE7) / DECODE(BIL_MEASURE3,  0, NULL, BIL_MEASURE3)) * 100) BIL_MEASURE74
      ,(((BIL_MEASURE10) / DECODE(BIL_MEASURE2, 0, NULL, BIL_MEASURE2)) * 100) BIL_MEASURE26
      ,(((BIL_MEASURE14) / DECODE(BIL_MEASURE2, 0, NULL, BIL_MEASURE2)) * 100) BIL_MEASURE27
      ,(BIL_MEASURE6 / DECODE(BIL_MEASURE10, 0, NULL, BIL_MEASURE10)) BIL_MEASURE28
      ,(BIL_MEASURE7 / DECODE(BIL_MEASURE11, 0, NULL, BIL_MEASURE11)) BIL_MEASURE34
      ,(SUM(BIL_MEASURE2) OVER()) BIL_MEASURE36
      ,(SUM(BIL_MEASURE3) OVER()) BIL_MEASURE37
      ,(((( SUM(BIL_MEASURE2) OVER() ) - ( SUM(BIL_MEASURE3) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE3) OVER(), 0, NULL, SUM(BIL_MEASURE3)OVER()))) * 100) BIL_MEASURE38
      ,SUM(BIL_MEASURE6) OVER() BIL_MEASURE40
      ,SUM(BIL_MEASURE7) OVER() BIL_MEASURE41
      ,(((( SUM(BIL_MEASURE6) OVER() ) - ( SUM(BIL_MEASURE7) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE7) OVER(), 0, NULL, SUM(BIL_MEASURE7) OVER()) )) * 100) BIL_MEASURE42
      ,(SUM(BIL_MEASURE10) OVER()) BIL_MEASURE44
      ,(SUM(BIL_MEASURE11) OVER()) BIL_MEASURE45
      ,(((( SUM(BIL_MEASURE10) OVER() ) - ( SUM(BIL_MEASURE11) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE11) OVER(), 0, NULL, SUM(BIL_MEASURE11) OVER()) )) * 100) BIL_MEASURE46
      ,(SUM(BIL_MEASURE14) OVER()) BIL_MEASURE48
      ,(SUM(BIL_MEASURE15) OVER()) BIL_MEASURE49
      ,(((( SUM(BIL_MEASURE14) OVER() ) - ( SUM(BIL_MEASURE15) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE15) OVER(), 0, NULL, SUM(BIL_MEASURE15) OVER()) )) * 100) BIL_MEASURE50
      ,(SUM(BIL_MEASURE18) OVER()) BIL_MEASURE52
      ,(SUM(BIL_MEASURE19) OVER()) BIL_MEASURE53
      ,(((( SUM(BIL_MEASURE18) OVER() ) - ( SUM(BIL_MEASURE19) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE19) OVER(), 0, NULL, SUM(BIL_MEASURE19) OVER()) )) * 100) BIL_MEASURE54
      ,(SUM(BIL_MEASURE22) OVER()) BIL_MEASURE56
      ,(SUM(BIL_MEASURE23) OVER()) BIL_MEASURE57
      ,(((( SUM(BIL_MEASURE22) OVER() ) - ( SUM(BIL_MEASURE23) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE23) OVER(), 0, NULL, SUM(BIL_MEASURE23) OVER()) )) * 100) BIL_MEASURE58
      ,( SUM(BIL_MEASURE6) OVER() / (DECODE(SUM(BIL_MEASURE2) OVER(), 0, NULL, SUM(BIL_MEASURE2) OVER())) * 100 ) BIL_MEASURE59
	,( SUM(BIL_MEASURE7) OVER() / (DECODE(SUM(BIL_MEASURE3) OVER(), 0, NULL, SUM(BIL_MEASURE3) OVER())) * 100 )
BIL_MEASURE76
      ,( SUM(BIL_MEASURE10) OVER() / (DECODE(SUM(BIL_MEASURE2) OVER(), 0, NULL, SUM(BIL_MEASURE2) OVER())) * 100 ) BIL_MEASURE60
      ,(SUM(BIL_MEASURE14) OVER() / (DECODE(SUM(BIL_MEASURE2) OVER(), 0, NULL, SUM(BIL_MEASURE2) OVER())) *100 ) BIL_MEASURE61
      ,( SUM(BIL_MEASURE6) OVER() / (DECODE(SUM(BIL_MEASURE10) OVER(), 0, NULL, SUM(BIL_MEASURE10) OVER()) ) ) BIL_MEASURE62
      ,( SUM(BIL_MEASURE7) OVER() / (DECODE(SUM(BIL_MEASURE11) OVER(), 0, NULL, SUM(BIL_MEASURE11) OVER()) ) ) BIL_MEASURE68 '||
      ' ,BIL_URL1
       , BIL_URL2
       ,DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                   DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=WON'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=WON'''||'))
                  BIL_URL3
      ,DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                   DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=LOST'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=LOST'''||'))
                  BIL_URL4
      ,DECODE('''||l_curr_as_of_date||''',TRUNC(SYSDATE),
                        DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                               DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=OPEN'''||'),
                               DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=OPEN'''||')),
                       NULL) BIL_URL5
      ,DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                   DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=NO OPPORTUNITY'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=NO OPPORTUNITY'''||') )
                   BIL_URL6      ';


        l_insert_stmnt  := 'INSERT INTO BIL_BI_RPT_TMP1 (VIEWBY, VIEWBYID, SORTORDER, BIL_MEASURE2,'||
              'BIL_MEASURE3, '||
                      'BIL_MEASURE6,BIL_MEASURE7, BIL_MEASURE10, BIL_MEASURE11, '||
                'BIL_MEASURE14,BIL_MEASURE15,BIL_MEASURE18,BIL_MEASURE19, '||
             'BIL_MEASURE22,BIL_MEASURE23,BIL_URL1, BIL_URL2)';

	l_inner_select:=' select VIEWBY '||
        ' ,VIEWBYID '||
        ' ,SORTORDER '||
        ' ,(CASE  '||
        	' WHEN NOT(SUM(BIL_MEASURE2) IS NULL AND SUM(BIL_MEASURE14) IS NULL) '||
        	' THEN  '||
        	'    NVL(SUM(BIL_MEASURE2),0) + NVL(SUM(BIL_MEASURE14),0) '||
        	' ELSE NULL  '||
        '   END) BIL_MEASURE2 '||
        ' ,(CASE  '||
        	' WHEN NOT(SUM(BIL_MEASURE3) IS NULL AND SUM(BIL_MEASURE15) IS NULL) '||
        	' THEN  '||
          	' NVL(SUM(BIL_MEASURE3),0) + NVL(SUM(BIL_MEASURE15),0) '||
        	' ELSE NULL  '||
        ' END) BIL_MEASURE3 '||
        ' ,SUM(BIL_MEASURE6) BIL_MEASURE6  '||
        ' ,SUM(BIL_MEASURE7) BIL_MEASURE7  '||
        ' ,SUM(BIL_MEASURE10) BIL_MEASURE10 '||
        ' ,SUM(BIL_MEASURE11) BIL_MEASURE11 '||
        ' ,SUM(BIL_MEASURE14) BIL_MEASURE14 '||
        ' ,SUM(BIL_MEASURE15) BIL_MEASURE15 '||
        ' ,SUM(BIL_MEASURE18) BIL_MEASURE18 '||
        ' ,SUM(BIL_MEASURE19) BIL_MEASURE19 '||
        ' ,SUM(BIL_MEASURE22) BIL_MEASURE22 '||
        ' ,SUM(BIL_MEASURE23) BIL_MEASURE23 '||
        ' ,BIL_URL1  '||
        ' ,BIL_URL2  '||
        ' from ';

	   l_inner_select1:=
              ' (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                      '  THEN   '||
               '   (CASE '||
              '   WHEN NOT(sumry.won_opty_amt'||l_currency_suffix||' IS NULL
                AND sumry.lost_opty_amt'||l_currency_suffix||' IS NULL AND '||
                '    sumry.no_opty_amt'||l_currency_suffix||' IS NULL)   '||
                ' THEN    '||
                ' (NVL(sumry.won_opty_amt'||l_currency_suffix||',0) + '||
                     ' NVL(sumry.lost_opty_amt'||l_currency_suffix||',0) +   '||
                 ' NVL(sumry.no_opty_amt'||l_currency_suffix||',0)  '||
                ' )  '||
                ' ELSE NULL '||
              ' END)  '||
                 '  ELSE NULL  '||
              ' END)  BIL_MEASURE2 '||
            ' , (CASE WHEN cal.report_date =:l_prev_date  '||
                       ' THEN  '||
                 ' (CASE '||
                ' WHEN NOT(sumry.won_opty_amt'||l_currency_suffix||' IS NULL
                    AND sumry.lost_opty_amt'||l_currency_suffix||' IS NULL '||
                   ' AND sumry.no_opty_amt'||l_currency_suffix||' IS NULL)   '||
                ' THEN   '||
                   ' (NVL(sumry.won_opty_amt'||l_currency_suffix||',0) + '||
                    ' NVL(sumry.lost_opty_amt'||l_currency_suffix||',0)  +   '||
                 ' NVL(sumry.no_opty_amt'||l_currency_suffix||',0)  '||
                ' )  '||
                ' ELSE NULL '||
              ' END)  '||
               ' ELSE NULL '||
              ' END) BIL_MEASURE3 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.won_opty_amt'||l_currency_suffix||' '||
                  ' ELSE NULL '||
             '  END)  BIL_MEASURE6 '||
            ' , (CASE WHEN cal.report_date =:l_prev_date '||
                       ' THEN sumry.won_opty_amt'||l_currency_suffix||' '||
                  ' ELSE NULL '||
             ' END)  BIL_MEASURE7 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.lost_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL '||
             ' END)  BIL_MEASURE10 '||
            ' , (CASE WHEN cal.report_date =:l_prev_date '||
                       ' THEN sumry.lost_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL  '||
             ' END)  BIL_MEASURE11 '||
      ' , NULL BIL_MEASURE14  '||
            ' , NULL BIL_MEASURE15  '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.new_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL  '||
             ' END)  BIL_MEASURE18 '||
            ' , (CASE WHEN cal.report_date =:l_prev_date  '||
                       ' THEN sumry.new_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL  '||
             ' END)  BIL_MEASURE19 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.no_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL  '||
             ' END)  BIL_MEASURE22 '||
           '  , (CASE WHEN cal.report_date =:l_prev_date  '||
                       ' THEN sumry.no_opty_amt'||l_currency_suffix||'  '||
               ' ELSE NULL  '||
             ' END)  BIL_MEASURE23';


   l_inner_where_clause := ' sumry.effective_time_id = cal.time_id '||
                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id '||
                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date) '||
             'AND sumry.parent_sales_group_id = :l_sg_id_num  ';
   IF l_parent_sales_group_id IS NULL THEN
        IF l_resource_id IS NULL THEN
            l_inner_where_clause1 := ' sumry.effective_time_id = cal.time_id '||
                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id'||
                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)'||
	                    ' AND sumry.parent_sales_group_id IS NULL '||
                    ' AND sumry.sales_group_id = :l_sg_id_num ';
        ELSE
            l_inner_where_clause1 := ' sumry.effective_time_id = cal.time_id '||
                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id'||
                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)'||
	                    ' AND sumry.parent_sales_group_id = sumry.sales_group_id '||
                    ' AND sumry.sales_group_id = :l_sg_id_num ';

        END IF;
   ELSE
   	  IF l_resource_id IS NULL THEN
		 l_inner_where_clause1 := ' sumry.effective_time_id = cal.time_id '||
		                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
		                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id'||
		                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)'||
		                    ' AND sumry.parent_sales_group_id = :l_parent_sales_group_id '||
							' AND sumry.sales_group_id = :l_sg_id_num ';
	  ELSE
	  	l_inner_where_clause1 := ' sumry.effective_time_id = cal.time_id '||
		                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
		                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id'||
		                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)'||
		                    ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
							' AND sumry.sales_group_id = :l_sg_id_num ';
	  END IF;
   END IF;



/*
   l_inner_select3:= '  NULL BIL_MEASURE2 '||
                 ' ,NULL BIL_MEASURE3 '||
                 ' ,NULL BIL_MEASURE6 '||
                 ' ,NULL BIL_MEASURE7 '||
                 ' ,NULL BIL_MEASURE10 '||
                 ' ,NULL BIL_MEASURE11 '||
             ' ,(CASE WHEN sumry.snap_date =:l_snap_date THEN '||
                    ' decode(:l_period_type, '||
                      ' 128,open_amt_year'||l_currency_suffix||', '||
                  ' 64,open_amt_quarter'||l_currency_suffix||', '||
                  ' 32,open_amt_period'||l_currency_suffix||', '||
                  ' 16,open_amt_week'||l_currency_suffix||' '||
                   ' )  '||
                           ' ELSE NULL '||
                 ' END) BIL_MEASURE14 '||
                   ' ,(CASE WHEN sumry.snap_date =:l_prev_date THEN '||
                    ' decode(:l_period_type, '||
                      ' 128,open_amt_year'||l_currency_suffix||', '||
                  ' 64,open_amt_quarter'||l_currency_suffix||', '||
                  ' 32,open_amt_period'||l_currency_suffix||', '||
                  ' 16,open_amt_week'||l_currency_suffix||' '||
                   ' ) '||
                           ' ELSE NULL '||
                 ' END)  BIL_MEASURE15 '||
                   ' ,NULL BIL_MEASURE18 '||
                   ' ,NULL BIL_MEASURE19 '||
                     ' ,NULL BIL_MEASURE22 '||
                   ' ,NULL BIL_MEASURE23';
*/

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
   l_inner_where_pipe := ' sumry.snap_date in (:l_snapshot_date, :l_prev_snap_date) ';
ELSE
   l_inner_where_pipe := ' sumry.snap_date in (:l_snapshot_date) ';
END IF;


--   l_inner_select3:=


    l_pipe_select1 :=  '  NULL BIL_MEASURE2 '||
                 ' ,NULL BIL_MEASURE3 '||
                 ' ,NULL BIL_MEASURE6 '||
                 ' ,NULL BIL_MEASURE7 '||
                 ' ,NULL BIL_MEASURE10 '||
                 ' ,NULL BIL_MEASURE11 '||
             ' ,(CASE WHEN sumry.snap_date =:l_snapshot_date THEN '||
                    ' decode(:l_period_type, '||
                      ' 128,open_amt_year'||l_currency_suffix||', '||
                  ' 64,open_amt_quarter'||l_currency_suffix||', '||
                  ' 32,open_amt_period'||l_currency_suffix||', '||
                  ' 16,open_amt_week'||l_currency_suffix||' '||
                   ' )  '||
                           ' ELSE NULL '||
                 ' END) BIL_MEASURE14 ';


IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
       l_pipe_select2 :=    ' ,(CASE WHEN sumry.snap_date =:l_prev_snap_date THEN '||
                    ' decode(:l_period_type, '||
                      ' 128,open_amt_year'||l_currency_suffix||', '||
                  ' 64,open_amt_quarter'||l_currency_suffix||', '||
                  ' 32,open_amt_period'||l_currency_suffix||', '||
                  ' 16,open_amt_week'||l_currency_suffix||' '||
                   ' ) '||
                           ' ELSE NULL '||
                 ' END)  BIL_MEASURE15 ';
ELSE
    l_pipe_select2 := ' ,(CASE WHEN sumry.snap_date =:l_snapshot_date THEN '||
                          ''||l_prev_amt||' '||
                           ' ELSE NULL '||
                 ' END)  BIL_MEASURE15 ';
END IF;

    l_pipe_select3 := ' ,NULL BIL_MEASURE18 '||
                   ' ,NULL BIL_MEASURE19 '||
                     ' ,NULL BIL_MEASURE22 '||
                   ' ,NULL BIL_MEASURE23';


 l_inner_select3:= l_pipe_select1 || l_pipe_select2 || l_pipe_select3;


	  l_inner_where_clause2:= l_inner_where_pipe ||
              				  ' AND sumry.parent_sales_group_id = :l_sg_id_num  ';


/*
	  l_inner_where_clause2:= ' sumry.snap_date in (:l_snap_date, :l_prev_date) '||
              				  ' AND sumry.parent_sales_group_id = :l_sg_id_num  ';
*/

    IF l_parent_sales_group_id IS NULL THEN
        IF l_resource_id IS NULL THEN
    	   l_inner_where_clause3:= l_inner_where_pipe ||
	              				' AND sumry.parent_sales_group_id IS NULL '||
              					' AND sumry.sales_group_id = :l_sg_id_num  '||
								' AND sumry.grp_total_flag = 0 ';
        ELSE
    	   l_inner_where_clause3:= l_inner_where_pipe ||
	              				' AND sumry.parent_sales_group_id = sumry.sales_group_id '||
              					' AND sumry.sales_group_id = :l_sg_id_num  '||
								' AND sumry.grp_total_flag = 0 ';
        END IF;
	ELSE
		IF l_resource_id IS NULL THEN
			l_inner_where_clause3:= l_inner_where_pipe ||
	              				' AND sumry.parent_sales_group_id = :l_parent_sales_group_id '||
								' AND sumry.sales_group_id = :l_sg_id_num  '||
								' AND sumry.grp_total_flag = 0 ';
		ELSE
			l_inner_where_clause3:= l_inner_where_pipe ||
	              				' AND sumry.parent_sales_group_id = :l_sg_id_num '||
								' AND sumry.sales_group_id = :l_sg_id_num  '||
								' AND sumry.grp_total_flag = 0 ';
		END IF;
	END IF;

   	l_null_rem_where_clause := ' (BIL_MEASURE2 IS NULL OR BIL_MEASURE2 = 0)  '||
                   '  AND (BIL_MEASURE6 IS NULL OR BIL_MEASURE6 = 0) '||
               ' AND (BIL_MEASURE10 IS NULL OR BIL_MEASURE10 = 0) '||
               ' AND (BIL_MEASURE14 IS NULL OR BIL_MEASURE14 = 0) '||
               ' AND (BIL_MEASURE18 IS NULL OR BIL_MEASURE18 = 0)'||
               ' AND (BIL_MEASURE22 IS NULL OR BIL_MEASURE22 = 0)';



	l_select := ' SELECT '||
			' sumry.sales_group_id sales_group_id '||
                    	' ,sumry.salesrep_id salesrep_id '||
                     	' ,SUM(sumry.BIL_MEASURE2) BIL_MEASURE2 '||
                     	' ,SUM(sumry.BIL_MEASURE3) BIL_MEASURE3 '||
                     	' ,SUM(sumry.BIL_MEASURE6) BIL_MEASURE6 '||
                     	' ,SUM(sumry.BIL_MEASURE7) BIL_MEASURE7 '||
                     	' ,SUM(sumry.BIL_MEASURE10) BIL_MEASURE10 '||
                     	' ,SUM(sumry.BIL_MEASURE11) BIL_MEASURE11 '||
                 	' ,SUM(sumry.BIL_MEASURE14) BIL_MEASURE14 '||
                 	' ,SUM(sumry.BIL_MEASURE15) BIL_MEASURE15 '||
                       	' ,SUM(sumry.BIL_MEASURE18) BIL_MEASURE18 '||
                       	' ,SUM(sumry.BIL_MEASURE19) BIL_MEASURE19 '||
                        ' ,SUM(sumry.BIL_MEASURE22) BIL_MEASURE22 '||
                       	' ,SUM(sumry.BIL_MEASURE23) BIL_MEASURE23 '||
                 	' ,BIL_URL1 '||
                 	' ,BIL_URL2 ';

      execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';

      BIL_BI_UTIL_PKG.get_PC_NoRollup_Where_Clause(
                                          p_prodcat      => l_prodcat_id,
                                          p_viewby       => l_viewby,
                                          x_denorm       => l_denorm,
                                          x_where_clause => l_product_where_clause);
	CASE l_viewby
            WHEN 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN

    l_url_str:='pFunctionName=BIL_BI_OPOVER_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';


    IF l_prodcat_id = 'All' THEN
         l_sumry1 := 'BIL_BI_OPTY_G_MV';
--       l_sumry2 := 'BIL_BI_PIPE_G_MV';
         l_sumry2  :=  l_open_mv_new  ;
         l_from1 := ' FROM '||l_fii_struct ||' cal, '||l_sumry1||' sumry '||l_denorm;
         l_from2 := ' FROM '||l_sumry2||' sumry ';

         l_inner_where_clause2 := l_inner_where_clause2||' AND sumry.grp_total_flag = 1 ';

    ELSE
         l_sumry1 := 'BIL_BI_OPTY_PG_MV';
--       l_sumry2 := 'BIL_BI_PIPE_G_MV';
         l_sumry2  :=  l_open_mv_new  ;
         l_from1 :=  ' FROM '||l_fii_struct ||' cal, '||l_sumry1||' sumry ';
         l_from2 := ' FROM '||l_sumry2||' sumry ';

		 l_inner_where_clause2 := l_inner_where_clause2||' AND sumry.grp_total_flag = 0 ';
	l_pc_sel := 'sumry.product_category_id product_category_id, ';
	l_pc_grp_by := ',sumry.product_category_id ';

     END IF;

       /*
        * 1. Need jtf_rs_grp_relations table to get the parent sales group
        * 2. In the case of sales reps, sales group and parent sales group are the same ,
        *    so filtering on sales group directly
        */

        IF l_resource_id IS NULL THEN
          l_custom_sql :=l_insert_stmnt || l_inner_select ||
                     ' ('||
               ' SELECT  /*+ NO_MERGE(tmp1) */ '||
                     '  DECODE(tmp1.salesrep_id, NULL, grptl.group_name,restl.resource_name) VIEWBY '||
                     ' ,DECODE(tmp1.salesrep_id, NULL, to_char(tmp1.sales_group_id),  '||
						' tmp1.salesrep_id||''.''||tmp1.sales_group_id) VIEWBYID '||
                     ' ,DECODE(tmp1.salesrep_id, NULL, 1,  2) sortorder '||
                     ' ,SUM(tmp1.BIL_MEASURE2) BIL_MEASURE2 '||
                     ' ,SUM(tmp1.BIL_MEASURE3) BIL_MEASURE3 '||
                     ' ,SUM(tmp1.BIL_MEASURE6) BIL_MEASURE6 '||
                     ' ,SUM(tmp1.BIL_MEASURE7) BIL_MEASURE7 '||
                     ' ,SUM(tmp1.BIL_MEASURE10) BIL_MEASURE10 '||
                     ' ,SUM(tmp1.BIL_MEASURE11) BIL_MEASURE11 '||
                     ' ,SUM(tmp1.BIL_MEASURE14) BIL_MEASURE14 '||
                     ' ,SUM(tmp1.BIL_MEASURE15) BIL_MEASURE15 '||
                     ' ,SUM(tmp1.BIL_MEASURE18) BIL_MEASURE18 '||
                     ' ,SUM(tmp1.BIL_MEASURE19) BIL_MEASURE19 '||
                     ' ,SUM(tmp1.BIL_MEASURE22) BIL_MEASURE22 '||
                     ' ,SUM(tmp1.BIL_MEASURE23) BIL_MEASURE23 '||
                     ' ,DECODE(tmp1.salesrep_id, NULL, BIL_URL1, NULL) BIL_URL1 '||
                     ' ,DECODE(tmp1.salesrep_id, NULL, NULL,'''||l_drill_link||''') BIL_URL2 '||
            ' FROM ('||
		l_select||
	        ' FROM ('||
              		'SELECT /*+ LEADING(cal) */ '||
				l_pc_sel||' '||
                  		l_inner_select1||
                               	',sumry.sales_group_id sales_group_id '||
                 		',sumry.salesrep_id salesrep_id '||
                              	','''||l_url_str||''' BIL_URL1 '||
                               	',null BIL_URL2 '||  l_from1 ||
                               	' WHERE cal.xtd_flag=:l_yes AND '
				 ||l_inner_where_clause||' ';

	           l_custom_sql := l_custom_sql||
	              ' UNION ALL '||
	                'SELECT '||
				l_pc_sel||' '||
				l_inner_select3||
	                        ',sumry.sales_group_id sales_group_id '||
	                 	',sumry.salesrep_id salesrep_id '||
	                        ','''||l_url_str||''' BIL_URL1 '||
	                        ',null BIL_URL2 '||
	                 l_from2 ||
	                 ' WHERE '||l_inner_where_clause2||' ';

	       l_custom_sql := l_custom_sql||
			') sumry '||l_denorm||
			' WHERE 1=1 '||l_product_where_clause||
			' GROUP BY sales_group_id, salesrep_id '||l_pc_grp_by||', BIL_URL1, BIL_URL2'||
	             ') tmp1 '||
	                  ' ,jtf_rs_groups_tl grptl'||
	             ' ,jtf_rs_resource_extns_tl restl'||
	             ' WHERE  grptl.group_id = tmp1.sales_group_id'||
	                          ' AND grptl.language = USERENV(''LANG'')'||
	                ' AND restl.resource_id(+) = tmp1.salesrep_id'||
	                           ' AND restl.language(+) = USERENV(''LANG'') '||
	             ' GROUP BY DECODE(tmp1.salesrep_id, NULL, grptl.group_name,restl.resource_name),'||
	                      ' DECODE(tmp1.salesrep_id, NULL, to_char(tmp1.sales_group_id),  '||
							' tmp1.salesrep_id||''.''||tmp1.sales_group_id), '||
	                  ' DECODE(tmp1.salesrep_id, NULL, 1,  2), '||
	                     ' DECODE(tmp1.salesrep_id, NULL, BIL_URL1, NULL), '||
                            ' DECODE(tmp1.salesrep_id, NULL, NULL,'''||l_drill_link||''') '||
	          ') GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1,BIL_URL2';
	    ELSE
          	l_custom_sql :=l_insert_stmnt || l_inner_select ||
                     ' ('||
			               ' SELECT  /*+ NO_MERGE(tmp1) */ '||
			                    '  resource_name VIEWBY '||
			                    ' ,tmp1.salesrep_id||''.''||tmp1.sales_group_id VIEWBYID '||
			                 	' ,tmp1.sortorder sortorder '||
			                     ' ,SUM(tmp1.BIL_MEASURE2) BIL_MEASURE2 '||
			                     ' ,SUM(tmp1.BIL_MEASURE3) BIL_MEASURE3 '||
			                     ' ,SUM(tmp1.BIL_MEASURE6) BIL_MEASURE6 '||
			                     ' ,SUM(tmp1.BIL_MEASURE7) BIL_MEASURE7 '||
			                     ' ,SUM(tmp1.BIL_MEASURE10) BIL_MEASURE10 '||
			                     ' ,SUM(tmp1.BIL_MEASURE11) BIL_MEASURE11 '||
			                 	 ' ,SUM(tmp1.BIL_MEASURE14) BIL_MEASURE14 '||
			                 	 ' ,SUM(tmp1.BIL_MEASURE15) BIL_MEASURE15 '||
			                     ' ,SUM(tmp1.BIL_MEASURE18) BIL_MEASURE18 '||
			                     ' ,SUM(tmp1.BIL_MEASURE19) BIL_MEASURE19 '||
			                     ' ,SUM(tmp1.BIL_MEASURE22) BIL_MEASURE22 '||
			                     ' ,SUM(tmp1.BIL_MEASURE23) BIL_MEASURE23 '||
			                 ' ,DECODE(tmp1.salesrep_id, NULL, BIL_URL1, NULL) BIL_URL1 '||
			                 ' ,'''||l_drill_link||''' BIL_URL2 '||
			            ' FROM ('||
					l_select||',sortorder '||
					' FROM ('||
					              'SELECT /*+ LEADING(cal) */ '||
							l_pc_sel||
							'1 sortorder, '||
					                  l_inner_select1||
					                 ',sumry.sales_group_id '||
					                 ',sumry.salesrep_id salesrep_id '||
					                 ','''||l_url_str||''' BIL_URL1 '||
					                 ',null BIL_URL2 '||  l_from1 ||
					               ' WHERE cal.xtd_flag=:l_yes AND '
								         ||l_inner_where_clause;

				             l_custom_sql := l_custom_sql||
				              ' UNION ALL '||
				                'SELECT '||l_pc_sel||' 1 sortorder, '||
				                                l_inner_select3||
				                               ',sumry.sales_group_id sales_group_id '||
				                 ',sumry.salesrep_id salesrep_id '||
				                              ','''||l_url_str||''' BIL_URL1 '||
				                               ',null BIL_URL2 '||
				                 l_from2 ||
				                               ' WHERE '||l_inner_where_clause2;

				         l_custom_sql := l_custom_sql||
						') sumry '||l_denorm||' '||
						' WHERE 1=1 '||l_product_where_clause||
						' GROUP BY sumry.sales_group_id, sumry.salesrep_id '||l_pc_grp_by||
							', sumry.sortorder, BIL_URL1, BIL_URL2 '||
				             ') tmp1 '||
				             ' ,jtf_rs_resource_extns_tl restl'||
				             ' WHERE  restl.resource_id = tmp1.salesrep_id'||
				                           ' AND restl.language = USERENV(''LANG'') '||
				                ' AND tmp1.salesrep_id = :l_resource_id '||
				             ' GROUP BY restl.resource_name,'||
				                      ' tmp1.salesrep_id||''.''||tmp1.sales_group_id, '||
				                  ' tmp1.sortorder, '||
				                     ' DECODE(tmp1.salesrep_id, NULL, BIL_URL1, NULL), BIL_URL2 '||
				  ') GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1,BIL_URL2';
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


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'length of query l_custom_sql is '|| length(l_custom_sql));

                     END IF;

            IF l_prodcat_id = 'All' THEN
	           IF l_resource_id IS NULL THEN

                      IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	              EXECUTE IMMEDIATE l_custom_sql
	              USING
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
		             l_curr_as_of_date,l_prev_date,l_yes,l_record_type_id,
                             l_record_type_id,l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                             l_sg_id_num;
                         ELSE
                            EXECUTE IMMEDIATE l_custom_sql
	              USING
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
		             l_curr_as_of_date,l_prev_date,l_yes,l_record_type_id,
                             l_record_type_id,l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                             l_sg_id_num;
                       END IF;

       ELSE

                           IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN

		           EXECUTE IMMEDIATE l_custom_sql
		                USING
		            l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                            l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
		            l_curr_as_of_date,l_prev_date,l_yes,l_record_type_id,
                            l_record_type_id,l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                            l_sg_id_num,l_resource_id;
                           ELSE
                             	EXECUTE IMMEDIATE l_custom_sql
		                USING
		            l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                            l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
		            l_curr_as_of_date,l_prev_date,l_yes,l_record_type_id,
                            l_record_type_id,l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                            l_sg_id_num,l_resource_id;
                          END IF;
      	             END IF;
            ELSIF l_prodcat_id <> 'All' THEN
	           IF l_resource_id IS NULL THEN


                      IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN

	               EXECUTE IMMEDIATE l_custom_sql
	               USING
	            	l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	            	l_curr_as_of_date,l_prev_date,l_yes,l_record_type_id,
                        l_record_type_id,l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                        l_sg_id_num,l_prodcat_id;

                        ELSE
                              EXECUTE IMMEDIATE l_custom_sql
	               USING
	            	l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	            	l_curr_as_of_date,l_prev_date,l_yes,l_record_type_id,
                        l_record_type_id,l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                        l_sg_id_num,l_prodcat_id;
                        END IF;

          ELSE

                       IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN

	               EXECUTE IMMEDIATE l_custom_sql
	                USING
	            	l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	            	l_curr_as_of_date,l_prev_date,l_yes,l_record_type_id,
                        l_record_type_id,l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                        l_sg_id_num,l_prodcat_id,
                        l_resource_id;
                      ELSE
	               EXECUTE IMMEDIATE l_custom_sql
	                USING
	            	l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	            	l_curr_as_of_date,l_prev_date,l_yes,l_record_type_id,
                        l_record_type_id,l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                        l_sg_id_num,l_prodcat_id,
                        l_resource_id;
                        END IF;

	           END IF;
            END IF;

        COMMIT;
        x_custom_sql := ' SELECT * FROM ( '||
                l_outer_select||' FROM BIL_BI_RPT_TMP1 '||
                       ' ORDER BY SORTORDER, UPPER(VIEWBY) '||
             ' ) WHERE NOT('||l_null_rem_where_clause||')';
                --view by Product category
      WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN

		l_sumry := ' BIL_BI_OPTY_PG_MV';
--		l_sumry1 := ' BIL_BI_PIPE_G_MV';
                l_sumry1  :=  l_open_mv_new  ;
		     IF 'All' = l_prodcat_id THEN
		          l_from1 := ' FROM '||l_fii_struct ||' cal, '||l_sumry||' sumry ';
		          l_from2 := ' FROM '||l_sumry1||' sumry ';
		    ELSE
		          l_from1 := ' FROM '||l_fii_struct ||' cal, '||l_sumry||' sumry '||l_denorm||' ';
		          l_from2 := ' FROM '||l_sumry1||' sumry '||l_denorm||' ';
            END IF;
		   -- l_from3 := ' FROM '||l_sumry||' sumry '||l_denorm;
		    l_productcat_id := l_prodcat_id;

         /* Basically the only case when a parent_id = id (immediate child id) will be if we have selected a
            self node (see the new code in the l_product_where).  So the first time we show a leaf category (C)
            it will be when we select its parent (A),so we show Assigned to Category for the parent (A), plus
            that  categorys children - category (C).  In that case parent_id <> child_id for category C, so we
            assign l_cat_url.  When we click on it, we re-run the query.  Now we get Assigned to category for
            category C, and in the second part of the union all we select self (see the new code in
            product where clause).  So now parent_id=id, and we can assign l_prod_url to switch the view by to
            product
          */

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || ' Prod cat view by ',
		                                    MESSAGE => 'Product where clause '||l_product_where_clause);

                     END IF;


         l_cat_url := 'pFunctionName='||l_rpt_str||'&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
               /* Product category 'All' is chosen, so need to display only categories, need not display
                * assigned to category
                */

      IF 'All' = l_prodcat_id THEN

         IF l_resource_id is NULL THEN
              l_custom_sql :=l_insert_stmnt || l_inner_select ||
                                  '('||
                                         ' SELECT /*+ LEADING(cal) */ null VIEWBY ,'||
                                              '1 sortorder, '||
                            l_inner_select1||
                                              ',sumry.product_category_id VIEWBYID'||
                                              ',NULL BIL_URL1'||
                                              ',NULL BIL_URL2 '||
                                               l_from1 ||
                                   ' WHERE cal.xtd_flag = :l_yes AND '||l_inner_where_clause1||
                             ' AND sumry.salesrep_id IS NULL ';

                l_custom_sql :=  l_custom_sql||
                           ' UNION ALL '||
                           ' SELECT null VIEWBY ,'||
                                              '1 sortorder, '||
                            l_inner_select3||
                                              ',sumry.product_category_id VIEWBYID'||
                                              ',NULL BIL_URL1'||
                                              ',NULL BIL_URL2 '||
                                               l_from2 ||
                                   ' WHERE '||l_inner_where_clause3||
                             ' AND sumry.salesrep_id IS NULL ';

	        l_custom_sql := l_custom_sql||
                                  ' ) GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1, BIL_URL2 ';

         ELSE -- salesrep is selected
              l_custom_sql :=l_insert_stmnt || l_inner_select ||
                                  '('||
                                         ' SELECT /*+ LEADING(cal) */ null VIEWBY ,'||
                                              '1 sortorder, '||
                            l_inner_select1||
                                              ',sumry.product_category_id VIEWBYID'||
                                              ',NULL BIL_URL1'||
                                              ',NULL BIL_URL2 '||
                                               l_from1 ||
                                   ' WHERE  cal.xtd_flag = :l_yes AND '||l_inner_where_clause1||

                           ' AND sumry.salesrep_id = :l_resource_id ';

          l_custom_sql := l_custom_sql||
                           ' UNION ALL '||
                           ' SELECT null VIEWBY ,'||
                                              '1 sortorder, '||
                            l_inner_select3||
                                              ',sumry.product_category_id VIEWBYID'||
                                              ',NULL BIL_URL1'||
                                              ',NULL BIL_URL2 '||
                                               l_from2 ||
                                   ' WHERE '||l_inner_where_clause3||

                           ' AND sumry.salesrep_id = :l_resource_id ';

        l_custom_sql := l_custom_sql||
                                  ' ) GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1, BIL_URL2 ';

       END IF;
       l_sql_error_desc := '';


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
          EXECUTE IMMEDIATE l_custom_sql
             USING
              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
              l_curr_as_of_date,l_prev_date,l_yes,
	      l_record_type_id,l_record_type_id,
              l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
              l_sg_id_num;
             ELSE
               EXECUTE IMMEDIATE l_custom_sql
             USING
              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
              l_curr_as_of_date,l_prev_date,l_yes,
	      l_record_type_id,l_record_type_id,
              l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
              l_sg_id_num;
             END IF;

ELSE

        IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
           EXECUTE IMMEDIATE l_custom_sql
             USING
              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
              l_curr_as_of_date,l_prev_date,l_yes,
              l_record_type_id,l_record_type_id,
              l_curr_as_of_date, l_prev_date,
              l_sg_id_num,l_resource_id,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
              l_sg_id_num,l_resource_id;

              ELSE

                     EXECUTE IMMEDIATE l_custom_sql
             USING
              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
              l_curr_as_of_date,l_prev_date,l_yes,
              l_record_type_id,l_record_type_id,
              l_curr_as_of_date, l_prev_date,
              l_sg_id_num,l_resource_id,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
              l_sg_id_num,l_resource_id;
                END IF;
         END IF;
	   ELSE -- parent_sales_group_is is not null
	         IF l_resource_id IS NULL THEN

               IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN

	          EXECUTE IMMEDIATE l_custom_sql
	             USING
	              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	              l_curr_as_of_date,l_prev_date,l_yes,
		      l_record_type_id,l_record_type_id,
	              l_curr_as_of_date, l_prev_date,
		      l_parent_sales_group_id,
		      l_sg_id_num,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                      l_parent_sales_group_id, l_sg_id_num;
	       ELSE
                   EXECUTE IMMEDIATE l_custom_sql
	             USING
	              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	              l_curr_as_of_date,l_prev_date,l_yes,
		      l_record_type_id,l_record_type_id,
	              l_curr_as_of_date, l_prev_date,
		      l_parent_sales_group_id,
		      l_sg_id_num,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                      l_parent_sales_group_id, l_sg_id_num;
                  END IF;

  ELSE

             IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	           EXECUTE IMMEDIATE l_custom_sql
	             USING
	              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                      l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	              l_curr_as_of_date,l_prev_date,l_yes,
		      l_record_type_id,l_record_type_id,
                      l_curr_as_of_date, l_prev_date,
	              l_sg_id_num,l_sg_id_num,l_resource_id,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                      l_sg_id_num,l_sg_id_num, l_resource_id;
                    ELSE
	           EXECUTE IMMEDIATE l_custom_sql
	             USING
	              l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                      l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	              l_curr_as_of_date,l_prev_date,l_yes,
		      l_record_type_id,l_record_type_id,
                      l_curr_as_of_date, l_prev_date,
	              l_sg_id_num,l_sg_id_num,l_resource_id,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                      l_sg_id_num,l_sg_id_num, l_resource_id;
                    END IF;
	         END IF;
       END IF;

     l_unassigned_value:= bil_bi_util_pkg.GET_UNASSIGNED_PC;

      x_custom_sql :=
	' SELECT * FROM ('||
		  l_outer_select||' FROM
                    (SELECT VIEWBY, VIEWBYID,SUM(BIL_MEASURE2) BIL_MEASURE2,
                    SUM(BIL_MEASURE3) BIL_MEASURE3, SUM(BIL_MEASURE6) BIL_MEASURE6,
                    SUM(BIL_MEASURE7) BIL_MEASURE7, SUM(BIL_MEASURE10) BIL_MEASURE10,
                    SUM(BIL_MEASURE11) BIL_MEASURE11, SUM(BIL_MEASURE14) BIL_MEASURE14,
                    SUM(BIL_MEASURE15) BIL_MEASURE15, SUM(BIL_MEASURE18) BIL_MEASURE18,
                    SUM(BIL_MEASURE19) BIL_MEASURE19, SUM(BIL_MEASURE22) BIL_MEASURE22,
                    SUM(BIL_MEASURE23) BIL_MEASURE23, '''||l_drill_link||''' BIL_URL1, BIL_URL2
                    FROM
                    (SELECT  decode(opty.viewbyid, -1,:l_unassigned_value,
                                               mtl.DESCRIPTION || '' ('' || mtl.CATEGORY_CONCAT_SEGS ||'')'') VIEWBY,
                    VIEWBYID, product_category_id,
                   SORTORDER, BIL_MEASURE2,'||
                   'BIL_MEASURE3, '||
                   'BIL_MEASURE6,BIL_MEASURE7, BIL_MEASURE10, BIL_MEASURE11, '||
                'BIL_MEASURE14,BIL_MEASURE15,BIL_MEASURE18,BIL_MEASURE19, '||
             'BIL_MEASURE22,BIL_MEASURE23
             ,NULL BIL_URL1
             ,DECODE(opty.viewbyid,''-1'',NULL,'''||l_cat_url||''') BIL_URL2 '||
              '     FROM
                   (select  pcd.parent_id VIEWBYID, product_category_id,
                   SORTORDER, BIL_MEASURE2,'||
                   'BIL_MEASURE3, '||
                   'BIL_MEASURE6,BIL_MEASURE7, BIL_MEASURE10, BIL_MEASURE11, '||
                'BIL_MEASURE14,BIL_MEASURE15,BIL_MEASURE18,BIL_MEASURE19, '||
             'BIL_MEASURE22,BIL_MEASURE23
             from (select VIEWBYID, VIEWBYID product_category_id,
                   SORTORDER, BIL_MEASURE2,'||
                   'BIL_MEASURE3, '||
                   'BIL_MEASURE6,BIL_MEASURE7, BIL_MEASURE10, BIL_MEASURE11, '||
                'BIL_MEASURE14,BIL_MEASURE15,BIL_MEASURE18,BIL_MEASURE19, '||
             'BIL_MEASURE22,BIL_MEASURE23 FROM BIL_BI_RPT_TMP1) sumry '||l_denorm||' where
             sortorder = 1 '||l_product_where_clause||
             ') OPTY,  mtl_categories_v mtl '||
				      ' WHERE mtl.category_id (+) = opty.viewbyid '
              ||
                ') GROUP BY VIEWBY, VIEWBYID, '''||l_drill_link||''', BIL_URL2
              ) '||
	  ' ) WHERE NOT('||l_null_rem_where_clause||') ORDER BY UPPER(VIEWBY)';

       ELSE --drill down on specific product category
                /* The first part of the union all gets the 'Assigned to Category' row
                 * for the category selected, (which used to be called unassigned) the second part of
                 * the union all gets the children categories
                 */
          IF l_resource_id is NULL THEN
             l_custom_sql := l_inner_select ||
                   '('||
                   ' SELECT  /*+ LEADING(cal) */ decode(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',  :l_cat_assign, pcd.value), pcd.value) VIEWBY ,'||
                      ' decode(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',1, 2),2) SORTORDER, '||
                  l_inner_select1||
                         ',pcd.id VIEWBYID'||
                         ',NULL BIL_URL1'||
                   ',decode(pcd.parent_id, pcd.id, NULL, '||
                        ' '''||l_cat_url||''')'||
                        ' BIL_URL2 '||
                                 l_from1 ||
                          ' WHERE cal.xtd_flag = :l_yes AND '||l_inner_where_clause1||
                ' AND sumry.salesrep_id IS NULL '||
                  ' '||l_product_where_clause||' ';


             l_custom_sql := l_custom_sql||
              'UNION ALL '||
              ' SELECT decode(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',  :l_cat_assign, pcd.value), pcd.value) VIEWBY ,'||
                      ' decode(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',1, 2),2) SORTORDER, '||
                  l_inner_select3||
                         ',pcd.id VIEWBYID'||
                         ',NULL BIL_URL1'||
                   ',DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL2 '||
                                 l_from2 ||
                          ' WHERE '||l_inner_where_clause3||
                ' AND sumry.salesrep_id IS NULL '||
                  ' '||l_product_where_clause;

             l_custom_sql := l_custom_sql||
              ' ) GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1,BIL_URL2 ';
         ELSE -- resource id is not null
                 l_custom_sql := l_inner_select ||
                  '('||
                    ' SELECT /*+ LEADING(cal) */ decode(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',  :l_cat_assign, pcd.value), pcd.value) VIEWBY ,'||
                      ' decode(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',1, 2),2) SORTORDER, '||
                    l_inner_select1||
                       ',pcd.id VIEWBYID'||
',decode(sumry.item_id, ''-1'', decode(pcd.parent_id, pcd.id,NULL,'''||l_drill_link||'''),'''||l_drill_link||''') BIL_URL1'||

                 ',decode(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''')'||
                  ' BIL_URL2 '||
              l_from1 ||
              ' WHERE  cal.xtd_flag = :l_yes AND '||l_inner_where_clause1||
                ' AND sumry.salesrep_id = :l_resource_id '||
                ' '||l_product_where_clause||' ';

             l_custom_sql := l_custom_sql||
              ' UNION ALL '||
              ' SELECT decode(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',  :l_cat_assign, pcd.value), pcd.value) VIEWBY ,'||
                      ' decode(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'',1, 2),2) SORTORDER, '||
                   l_inner_select3||
                       ',pcd.id VIEWBYID'||
  ',decode(sumry.item_id, ''-1'', decode(pcd.parent_id, pcd.id,NULL,'''||l_drill_link||'''),'''||l_drill_link||''') BIL_URL1'||
                 ',DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL2 '||
              l_from2 ||
              ' WHERE '||l_inner_where_clause3||
                ' AND sumry.salesrep_id = :l_resource_id '||
                ' '||l_product_where_clause||' ';


         l_custom_sql :=l_custom_sql||
                        ' ) GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1,BIL_URL2 ';
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


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'length of query l_custom_sql is '|| length(l_custom_sql));

                     END IF;


         IF l_parent_sales_group_id IS NULL THEN
           IF l_resource_id IS NULL THEN

   IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
             EXECUTE IMMEDIATE l_insert_stmnt || l_custom_sql
               USING  l_cat_assign,
                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                l_curr_as_of_date,l_prev_date,l_yes,
                l_record_type_id,l_record_type_id,
                l_curr_as_of_date, l_prev_date,
                l_sg_id_num,l_prodcat_id,
		l_cat_assign,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                l_sg_id_num,l_prodcat_id;
            ELSE
             EXECUTE IMMEDIATE l_insert_stmnt || l_custom_sql
               USING  l_cat_assign,
                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                l_curr_as_of_date,l_prev_date,l_yes,
                l_record_type_id,l_record_type_id,
                l_curr_as_of_date, l_prev_date,
                l_sg_id_num,l_prodcat_id,
		l_cat_assign,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                l_sg_id_num,l_prodcat_id;
               END IF;

ELSE

         IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
              EXECUTE IMMEDIATE l_insert_stmnt || l_custom_sql
               USING l_cat_assign,
                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                l_curr_as_of_date,l_prev_date,l_yes,
		l_record_type_id,l_record_type_id,
                l_curr_as_of_date, l_prev_date,
                l_sg_id_num,l_resource_id,
                l_prodcat_id,
		l_cat_assign,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                l_sg_id_num,l_resource_id,
                l_prodcat_id;
            ELSE
              EXECUTE IMMEDIATE l_insert_stmnt || l_custom_sql
               USING l_cat_assign,
                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
                l_curr_as_of_date,l_prev_date,l_yes,
		l_record_type_id,l_record_type_id,
                l_curr_as_of_date, l_prev_date,
                l_sg_id_num,l_resource_id,
                l_prodcat_id,
		l_cat_assign,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                l_sg_id_num,l_resource_id,
                l_prodcat_id;
             END IF;

     END IF;

	   ELSE -- l_parent_sales_group_is not null
	           IF l_resource_id IS NULL THEN

                  IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	             EXECUTE IMMEDIATE l_insert_stmnt || l_custom_sql
	               USING  l_cat_assign,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_yes,
			l_record_type_id,l_record_type_id,
	                l_curr_as_of_date, l_prev_date,
			l_parent_sales_group_id,l_sg_id_num,l_prodcat_id,
			l_cat_assign,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                        l_parent_sales_group_id,
					l_sg_id_num,l_prodcat_id;
                     ELSE
	             EXECUTE IMMEDIATE l_insert_stmnt || l_custom_sql
	               USING  l_cat_assign,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_yes,
			l_record_type_id,l_record_type_id,
	                l_curr_as_of_date, l_prev_date,
			l_parent_sales_group_id,l_sg_id_num,l_prodcat_id,
			l_cat_assign,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                        l_parent_sales_group_id,
					l_sg_id_num,l_prodcat_id;
                       END IF;

             ELSE

                IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
	              EXECUTE IMMEDIATE l_insert_stmnt || l_custom_sql
	               USING l_cat_assign,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_yes,
			l_record_type_id,l_record_type_id,
	                l_curr_as_of_date, l_prev_date,
			l_sg_id_num,l_sg_id_num,l_resource_id,l_prodcat_id,
			l_cat_assign,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                        l_sg_id_num,
					l_sg_id_num,l_resource_id,l_prodcat_id;
                  ELSE
         	              EXECUTE IMMEDIATE l_insert_stmnt || l_custom_sql
	               USING l_cat_assign,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_curr_as_of_date,l_prev_date,
	                l_curr_as_of_date,l_prev_date,l_yes,
			l_record_type_id,l_record_type_id,
	                l_curr_as_of_date, l_prev_date,
			l_sg_id_num,l_sg_id_num,l_resource_id,l_prodcat_id,
			l_cat_assign,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date, l_prev_snap_date,
                        l_sg_id_num,
					l_sg_id_num,l_resource_id,l_prodcat_id;
                   END IF;

            END IF;
       END IF;
       IF bil_bi_util_pkg.isleafnode(l_prodcat_id) THEN

x_custom_sql := ' SELECT * FROM ( '||
           l_outer_select||
            ' FROM ('||
				  ' SELECT VIEWBY, VIEWBYID, SORTORDER, '||
				    ' CASE WHEN NOT(BIL_MEASURE6 IS NULL AND BIL_MEASURE10 IS NULL AND BIL_MEASURE14 IS NULL AND '||
						           ' BIL_MEASURE22 IS NULL) '||
						' THEN '||
							' (NVL(BIL_MEASURE6,0)+NVL(BIL_MEASURE10,0)+NVL(BIL_MEASURE14,0)+NVL(BIL_MEASURE22,0)) '||
						' ELSE NULL '||
					' END BIL_MEASURE2,'||
                  ' CASE WHEN NOT(BIL_MEASURE7 IS NULL AND BIL_MEASURE11 IS NULL AND BIL_MEASURE15 IS NULL AND '||
						           ' BIL_MEASURE23 IS NULL) '||
						' THEN '||
							' (NVL(BIL_MEASURE7,0)+NVL(BIL_MEASURE11,0)+NVL(BIL_MEASURE15,0)+NVL(BIL_MEASURE23,0)) '||
						' ELSE NULL '||
				   ' END  BIL_MEASURE3, '||
				  ' BIL_MEASURE6,BIL_MEASURE7, '||
                  ' BIL_MEASURE10, BIL_MEASURE11, '||
                  ' BIL_MEASURE14, BIL_MEASURE15, '||
                  ' BIL_MEASURE18,BIL_MEASURE19, BIL_MEASURE22, '||
                  ' BIL_MEASURE23,BIL_URL1, BIL_URL2 '||
				  ' FROM ('||
		                ' SELECT VIEWBY, VIEWBYID, SORTORDER, BIL_MEASURE2,'||
		                  ' BIL_MEASURE3,  BIL_MEASURE6,BIL_MEASURE7, '||
		                  ' BIL_MEASURE10, BIL_MEASURE11, '||
		                  ' BIL_MEASURE14, BIL_MEASURE15, '||
		                  ' BIL_MEASURE18,BIL_MEASURE19, BIL_MEASURE22, '||
		                  ' BIL_MEASURE23,BIL_URL1, BIL_URL2 '||
		                ' FROM BIL_BI_RPT_TMP1 '||
		                ' WHERE SORTORDER = 1 '||
		                ' UNION ALL
		                SELECT VIEWBY, VIEWBYID, SORTORDER, BIL_MEASURE2,'||
		                  ' BIL_MEASURE3,  BIL_MEASURE6,BIL_MEASURE7, '||
		                  ' BIL_MEASURE10, BIL_MEASURE11, '||
		                  ' BIL_MEASURE14, BIL_MEASURE15, '||
		                  ' BIL_MEASURE18,BIL_MEASURE19, BIL_MEASURE22, '||
		                  ' BIL_MEASURE23,BIL_URL1, NULL BIL_URL2 '||
		                ' FROM BIL_BI_RPT_TMP1 '||
		                ' WHERE SORTORDER = 2 '||
	              	' ) '||
				')'||' ORDER BY SORTORDER, UPPER(VIEWBY) '||
        ' ) WHERE NOT('||l_null_rem_where_clause||')';


       ELSE
            x_custom_sql := ' SELECT * FROM ( '||
                l_outer_select||' FROM BIL_BI_RPT_TMP1 '||
                   ' ORDER BY SORTORDER, UPPER(VIEWBY) '||
                  ') WHERE NOT('||l_null_rem_where_clause||')';
       END IF;


     END IF;--end drill down on specific product cat

     commit;

                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' Final Query to PMF ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;



  x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
          l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

          l_bind_ctr := 1;
          l_custom_rec.attribute_name :=':l_yes';
          l_custom_rec.attribute_value := 'Y';
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name :=':l_unassigned_value';
          l_custom_rec.attribute_value := l_unassigned_value;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;

     END CASE;
   ELSE --no valid parameters
       BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                     ,x_sqlstr    => x_custom_sql);

                     IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_ERROR,
		                                    MODULE => g_pkg || l_proc || 'Parameter_Error',
		                                    MESSAGE => 'Invalid Parameter '|| l_proc);

                     END IF;

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
      COMMIT;
      RAISE;
 END  BIL_BI_OPPTY_OVERVIEW;





/*******************************************************************************
 * Name    : Procedure BIL_BI_OPPTY_WIN_LOSS_COUNTS
 * Author  : Elena Sapozhnikova
 * Date    : June 16, 2004
 * Purpose : Opportunity Win/Loss with Counts Sales Intelligence report and charts.
 *
 *           Copyright (c) 2002 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * p_bis_map_tbl           PL/SQL table containing sql query
 *
 *
 * Date     Author     Description
 * ----     ------     -----------
 * 06/07/04 esapozhn   initial version
 * 26 Nov 2004 hrpandey Drill Down to Oppty Line Detail report
 ******************************************************************************/


PROCEDURE BIL_BI_OPPTY_WIN_LOSS_COUNTS( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                               ,x_custom_sql         OUT NOCOPY VARCHAR2
                               ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
  IS

    l_period_type               VARCHAR2(50);
    l_sg_id                     VARCHAR2(50);
    l_resource_id               VARCHAR2(50);
    l_conv_rate_selected        VARCHAR2(50);
    l_curr_page_time_id         NUMBER;
    l_prev_page_time_id         NUMBER;
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
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
    l_sql_error_desc            VARCHAR2(5000);
    l_sg_id_num                 NUMBER;
    l_fst_category              VARCHAR2(50);
    l_fst_crdt_type             VARCHAR2(50);
    l_debug_mode                VARCHAR2(50);
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80) ;
    l_bind_ctr                  NUMBER;
    l_inner_where_clause        VARCHAR2(1000);
    l_inner_where_clause1       VARCHAR2(1000);
    l_inner_where_clause2       VARCHAR2(1000);
    l_inner_where_clause3       VARCHAR2(1000);
    l_inner_where_clause4       VARCHAR2(1000);
    l_null_rem_where_clause     VARCHAR2(4000);
    l_outer_select              VARCHAR2(8000);
    l_inner_select              VARCHAR2(8000);
    l_inner_select1             VARCHAR2(8000);
    l_inner_select2             VARCHAR2(8000);
    l_inner_select3             VARCHAR2(8000);
    l_inner_select4             VARCHAR2(8000);
    l_custom_sql                VARCHAR2(32000);
    l_custom_sql1               VARCHAR2(32000);
    l_using                     VARCHAR2(10000);
    l_insert_stmnt              VARCHAR2(8000);
    l_prodcat_id                VARCHAR2(20);
    l_productcat_id             VARCHAR2(20);
    l_product_where_clause      VARCHAR2(1000);
    l_product_where_clause1     VARCHAR2(1000);
    l_sumry                     VARCHAR2(50);
    l_denorm                    VARCHAR2(100);
    l_url                       VARCHAR2(1000);
    l_cat_assign                VARCHAR2(1000);
    l_productcat_cl             VARCHAR2(500);
    l_product_cl                VARCHAR2(500);
    l_cat_url                   VARCHAR2(500);
    l_prod_url                  VARCHAR2(500);
    l_sumry1                    VARCHAr2(50);
    l_sumry2                    VARCHAr2(50);
    l_url_str                   VARCHAR2(1000);
    l_cat_denorm                VARCHAR2(50);
    l_from1                     VARCHAR2(1000);
    l_from2                     VARCHAR2(1000);
    l_from3                     VARCHAR2(1000);
    l_item                      VARCHAR2(100);
  	l_snap_date                 DATE;
    l_proc                      VARCHAR2(100);
	l_parent_sales_group_id		NUMBER;
	l_yes				        VARCHAR2(1);
	l_parent_sls_grp_where_clause VARCHAR2(1000);
	l_pipe_product_where_clause	VARCHAR2(1000);
	l_pipe_denorm               VARCHAR2(100);
	l_currency_suffix           VARCHAR2(5);
	l_drill_link                varchar2(4000);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;


    l_prev_amt           VARCHAR2(1000);
    l_column_type        VARCHAR2(1000);
    l_snapshot_date      DATE;
    l_open_mv_new        VARCHAR2(1000);
    l_open_mv_new1       VARCHAR2(1000);
    l_prev_snap_date     DATE;
    l_pipe_select1       varchar2(4000);
    l_pipe_select2       varchar2(4000);
    l_pipe_select3       varchar2(4000);
    l_inner_where_pipe   VARCHAR2(1000);



  BEGIN
    g_pkg := 'bil.patch.115.sql.BIL_BI_SALES_MGMT_RPTS_PKG.';
    l_region_id:= 'BIL_BI_OPPTY_OVERVIEW';
    l_parameter_valid:= FALSE;
    l_proc := 'BIL_BI_OPPTY_OVERVIEW.';
    l_yes := 'Y';
    g_sch_name := 'BIL';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '|| l_proc);

                     END IF;

    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl => p_page_parameter_tbl
                                    ,p_region_id       => l_region_id
                                    ,x_period_type       => l_period_type
                                    ,x_conv_rate_selected => l_conv_rate_selected
                                    ,x_sg_id         => l_sg_id
                    				,x_parent_sg_id		=> l_parent_sales_group_id
									,x_resource_id       => l_resource_id
                                    ,x_prodcat_id       => l_prodcat_id
                                    ,x_curr_page_time_id  => l_curr_page_time_id
                                    ,x_prev_page_time_id  => l_prev_page_time_id
                                    ,x_comp_type       => l_comp_type
                                    ,x_parameter_valid     => l_parameter_valid
                                    ,x_as_of_date       => l_curr_as_of_date
                                    ,x_page_period_type   => l_page_period_type
                                    ,x_prior_as_of_date   => l_prev_date
                                    ,x_record_type_id     => l_record_type_id
                                    ,x_viewby             => l_viewby );

/*
   bil_bi_util_pkg.get_latest_snap_date(p_page_parameter_tbl  => p_page_parameter_tbl
                                           ,p_as_of_date          => l_curr_as_of_date
                                           ,p_period_type         => NULL
                                           ,x_snapshot_date       => l_snap_date);
*/

   IF l_parameter_valid THEN
        --retrieve 'Item unassigned' message here. We should be retireving from Message dicts?
        l_cat_assign:=FND_MESSAGE.GET_STRING('BIL', 'BIL_BI_ASSIGN_CATEGORY');

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => ' l_cat_assign is '||l_cat_assign );

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Prod cat is '||nvl(l_prodcat_id, 0)||' Product is'||
                                                                ' Lang '||USERENV('LANG'));

                     END IF;


        IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
        ELSE
            l_currency_suffix := '';
        END IF;

    --Not sure what PMV returns for 'All', as of now it returns NULL, so convert it to 'All'.
           l_prodcat_id := 'All';
        BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS( x_bitand_id => l_bitand_id
                                     ,x_calendar_id => l_calendar_id
                                     ,x_curr_date => l_bis_sysdate
                                     ,x_fii_struct => l_fii_struct );


        l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
        l_bitand_id := TO_NUMBER(REPLACE(l_bitand_id, ''''));
        l_calendar_id := TO_NUMBER(REPLACE(l_calendar_id, ''''));
        l_conv_rate_selected := TO_NUMBER(REPLACE(l_conv_rate_selected, ''''));
        l_period_type  := TO_NUMBER(REPLACE(l_period_type , ''''));
    l_prodcat_id := replace(l_prodcat_id,'''','');

        l_rpt_str:='BIL_BI_OPOVER_R';

/*

Include changes for the Drill to the Opty Line Detail Rep

*/


--

-- Get the Drill Link to the Opty Line Detail Report

l_drill_link := bil_bi_util_pkg.get_drill_links( p_view_by =>  l_viewby,
                                                 p_salesgroup_id =>   l_sg_id,
                                                 p_resource_id   =>    l_resource_id  );


--


/* Get the Prefix for the Open amt based upon Period Type and Compare To Params */


l_prev_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'O',
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

       l_sql_error_desc := 'l_viewby              => '|| l_viewby||', '||
      'l_curr_page_time_id   => '|| l_curr_page_time_id ||', ' ||
      'l_prev_page_time_id   => '|| l_prev_page_time_id ||', ' ||
      'l_curr_as_of_date     => '|| l_curr_as_of_date ||', ' ||
      'l_prev_date          => '|| l_prev_date ||', ' ||
      'l_conv_rate_selected  => '|| l_conv_rate_selected ||', ' ||
      'l_bitand_id          => '|| l_bitand_id ||', ' ||
      'l_period_type          => '|| l_period_type ||', ' ||
      'l_sg_id               => '|| l_sg_id ||', ' ||
      'l_resource_id          => '|| l_resource_id ||', ' ||
      'l_bis_sysdate          => '|| l_bis_sysdate ||', ' ||
      'l_record_type_id      => '|| l_record_type_id ||', ' ||
      'l_calendar_id          => '|| l_calendar_id;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Parameters =>'||l_sql_error_desc);

    END IF;



/*** Query column mapping ******************************************************
*  Internal Name  Grand Total  Region Item Name
*  BIL_MEASURE1  BIL_MEASURE35   Total Opportunity Count
*  BIL_MEASURE2  BIL_MEASURE36  Total Opportunity
*  BIL_MEASURE3  BIL_MEASURE37  Prior Total Opportunity
*  BIL_MEASURE4  BIL_MEASURE38  Total Opportunity Change
*  BIL_MEASURE5                 Won Count
*  BIL_MEASURE6  BIL_MEASURE40  Won
*  BIL_MEASURE7  BIL_MEASURE41  Prior Won / KPI Prior Won
*  BIL_MEASURE8  BIL_MEASURE42  Won Change
*  BIL_MEASURE9                 Lost Count
*  BIL_MEASURE10  BIL_MEASURE44  Lost
*  BIL_MEASURE11  BIL_MEASURE45  Prior Lost / KPI Prior Lost
*  BIL_MEASURE12  BIL_MEASURE46  Lost Change
*  BIL_MEASURE13                 Open Count
*  BIL_MEASURE14  BIL_MEASURE48  Open
*  BIL_MEASURE15  BIL_MEASURE49  Prior Open / KPI Prior Open
*  BIL_MEASURE16  BIL_MEASURE50  Open Change
*  BIL_MEASURE17                 New Count
*  BIL_MEASURE18  BIL_MEASURE52  New
*  BIL_MEASURE19  BIL_MEASURE53  Prior New
*  BIL_MEASURE20  BIL_MEASURE54  New Change
*  BIL_MEASURE21                 No Opportunity Count
*  BIL_MEASURE22  BIL_MEASURE56  No Opportunity
*  BIL_MEASURE23  BIL_MEASURE57  Prior No Opportunity / KPI Prior No
*  BIL_MEASURE24  BIL_MEASURE58  No Opportunity Change
*  BIL_MEASURE25  BIL_MEASURE59  Win %
*  BIL_MEASURE26  BIL_MEASURE60  Loss %
*  BIL_MEASURE27  BIL_MEASURE61  Open %
*  BIL_MEASURE28  BIL_MEASURE62  Win/Loss Ratio
*  BIL_MEASURE34  BIL_MEASURE68  KPI Prior Win/Loss Ratio
*  BIL_URL1            Sales Group URL
*  BIL_URL2            Product Category URL
*  BIL_TITLE1            Won, Lost, Open Opportunity Value
*  BIL_TITLE2            Won, Lost, Open % of Total
*  BIL_TITLE3            Won, Lost, Open Opportunity Count
*  BIL_URL3            URL to Drill to the Opty Line Detail rep from Lost Column
*  BIL_URL4            URL to Drill to the Opty Line Detail rep from No Opportunity Column
*  BIL_URL5            URL to Drill to the Opty Line Detail rep from Won Column
*  BIL_URL6            URL to Drill to the Opty Line Detail rep from Open Column
*******************************************************************************/

   l_outer_select:= 'SELECT VIEWBY
      ,VIEWBYID
      , BIL_MEASURE2
      , BIL_MEASURE3
      ,(((BIL_MEASURE2 - BIL_MEASURE3) / ABS(DECODE(BIL_MEASURE3, 0, NULL, BIL_MEASURE3))) * 100) BIL_MEASURE4
      ,BIL_MEASURE5
      ,BIL_MEASURE6
      ,BIL_MEASURE7
      ,(((BIL_MEASURE6 - BIL_MEASURE7) / ABS(DECODE(BIL_MEASURE7, 0, NULL, BIL_MEASURE7))) * 100) BIL_MEASURE8
      ,BIL_MEASURE9
      ,BIL_MEASURE10
      ,BIL_MEASURE11
      ,(((BIL_MEASURE10 - BIL_MEASURE11) / ABS(DECODE(BIL_MEASURE11, 0, NULL, BIL_MEASURE11))) * 100) BIL_MEASURE12
      ,BIL_MEASURE13
      ,BIL_MEASURE14
      ,BIL_MEASURE15
      ,(((BIL_MEASURE14 - BIL_MEASURE15) / ABS(DECODE(BIL_MEASURE15, 0, NULL, BIL_MEASURE15))) * 100) BIL_MEASURE16
      ,BIL_MEASURE17
      ,BIL_MEASURE18
      ,BIL_MEASURE19
      ,(((BIL_MEASURE18 - BIL_MEASURE19) / ABS(DECODE(BIL_MEASURE19, 0, NULL, BIL_MEASURE19))) * 100) BIL_MEASURE20
      ,BIL_MEASURE21
      ,BIL_MEASURE22
      ,BIL_MEASURE23
      ,(((BIL_MEASURE22 - BIL_MEASURE23) / ABS(DECODE(BIL_MEASURE23, 0, NULL, BIL_MEASURE23))) * 100) BIL_MEASURE24
      ,(((BIL_MEASURE6) / DECODE(BIL_MEASURE2, 0, NULL, BIL_MEASURE2)) * 100) BIL_MEASURE25
      ,(((BIL_MEASURE10) / DECODE(BIL_MEASURE2, 0, NULL, BIL_MEASURE2)) * 100) BIL_MEASURE26
      ,(((BIL_MEASURE14) / DECODE(BIL_MEASURE2, 0, NULL, BIL_MEASURE2)) * 100) BIL_MEASURE27
      ,(BIL_MEASURE6 / DECODE(BIL_MEASURE10, 0, NULL, BIL_MEASURE10)) BIL_MEASURE28
      ,(SUM(BIL_MEASURE2) OVER()) BIL_MEASURE36
      ,(SUM(BIL_MEASURE3) OVER()) BIL_MEASURE37
      ,(((( SUM(BIL_MEASURE2) OVER() ) - ( SUM(BIL_MEASURE3) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE3) OVER(), 0, NULL, SUM(BIL_MEASURE3) OVER())) '||
      '  )) * 100 BIL_MEASURE38
      ,SUM(BIL_MEASURE6) OVER() BIL_MEASURE40
      ,SUM(BIL_MEASURE7) OVER() BIL_MEASURE41
      ,(((( SUM(BIL_MEASURE6) OVER() ) - ( SUM(BIL_MEASURE7) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE7) OVER(), 0, NULL, SUM(BIL_MEASURE7) OVER())) '||
      ' )) * 100 BIL_MEASURE42
      ,(SUM(BIL_MEASURE10) OVER()) BIL_MEASURE44
      ,(SUM(BIL_MEASURE11) OVER()) BIL_MEASURE45
      ,(((( SUM(BIL_MEASURE10) OVER() ) - ( SUM(BIL_MEASURE11) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE11) OVER(), 0, NULL, SUM(BIL_MEASURE11) OVER()))'||
      '  )) * 100 BIL_MEASURE46
      ,(SUM(BIL_MEASURE14) OVER()) BIL_MEASURE48
      ,(SUM(BIL_MEASURE15) OVER()) BIL_MEASURE49
      ,(((( SUM(BIL_MEASURE14) OVER() ) - ( SUM(BIL_MEASURE15) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE15) OVER(), 0, NULL, SUM(BIL_MEASURE15) OVER() '||
      ' ))  )) * 100 BIL_MEASURE50
      ,(SUM(BIL_MEASURE18) OVER()) BIL_MEASURE52
      ,(SUM(BIL_MEASURE19) OVER()) BIL_MEASURE53
      ,(((( SUM(BIL_MEASURE18) OVER() ) - ( SUM(BIL_MEASURE19) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE19) OVER(), 0, NULL, SUM(BIL_MEASURE19) OVER() '||
      ' ))  )) * 100 BIL_MEASURE54
      ,(SUM(BIL_MEASURE22) OVER()) BIL_MEASURE56
      ,(SUM(BIL_MEASURE23) OVER()) BIL_MEASURE57
      ,(((( SUM(BIL_MEASURE22) OVER() ) - ( SUM(BIL_MEASURE23) OVER() )) / ABS(DECODE(SUM(BIL_MEASURE23) OVER(), 0, NULL, SUM(BIL_MEASURE23) OVER() '||
      ' ))  )) * 100 BIL_MEASURE58
      ,( SUM(BIL_MEASURE6) OVER() / (DECODE(SUM(BIL_MEASURE2) OVER(), 0, NULL, SUM(BIL_MEASURE2) OVER()))  ) * 100  BIL_MEASURE59
      ,( SUM(BIL_MEASURE10) OVER() / (DECODE(SUM(BIL_MEASURE2) OVER(), 0, NULL, SUM(BIL_MEASURE2) OVER()))  ) * 100  BIL_MEASURE60
      ,( SUM(BIL_MEASURE14) OVER() / (DECODE(SUM(BIL_MEASURE2) OVER(), 0, NULL, SUM(BIL_MEASURE2) OVER()))  ) *100  BIL_MEASURE61
      ,( SUM(BIL_MEASURE6) OVER() / (DECODE(SUM(BIL_MEASURE10) OVER(), 0, NULL, SUM(BIL_MEASURE10) OVER()))  )  BIL_MEASURE62
       ,BIL_URL1
      ,BIL_URL2
,DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
		DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=LOST'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=LOST'''||'))
                  BIL_URL3
,DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
		DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=No Opportunity'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=No Opportunity'''||'))
                  BIL_URL4
,DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
		DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=WON'''||'),
                   DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=WON'''||'))
                  BIL_URL5
,DECODE('''||l_curr_as_of_date||''',TRUNC(SYSDATE),
                        DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                               DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=OPEN'''||'),
                               DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=OPEN'''||')),
                       NULL) BIL_URL6
  ' ;


        l_insert_stmnt  := 'INSERT INTO BIL_BI_RPT_TMP1 (VIEWBY, VIEWBYID, SORTORDER, BIL_MEASURE2,'||
              'BIL_MEASURE3, '||
                      'BIL_MEASURE5,BIL_MEASURE6,BIL_MEASURE7, BIL_MEASURE9, BIL_MEASURE10, BIL_MEASURE11, '||
                'BIL_MEASURE13,BIL_MEASURE14,BIL_MEASURE15,BIL_MEASURE17,BIL_MEASURE18,BIL_MEASURE19, '||
             'BIL_MEASURE21,BIL_MEASURE22,BIL_MEASURE23,BIL_URL1, BIL_URL2)';

		l_inner_select:=' select VIEWBY '||
              ' ,VIEWBYID '||
        ' ,SORTORDER '||
              ' ,(CASE  '||
          ' WHEN NOT(SUM(BIL_MEASURE2) IS NULL AND SUM(BIL_MEASURE14) IS NULL) '||
        ' THEN  '||
        '    NVL(SUM(BIL_MEASURE2),0) + NVL(SUM(BIL_MEASURE14),0) '||
        ' ELSE NULL  '||
        '   END) BIL_MEASURE2 '||
            ' ,(CASE  '||
          ' WHEN NOT(SUM(BIL_MEASURE3) IS NULL AND SUM(BIL_MEASURE15) IS NULL) '||
        ' THEN  '||
          ' NVL(SUM(BIL_MEASURE3),0) + NVL(SUM(BIL_MEASURE15),0) '||
        ' ELSE NULL  '||
        ' END) BIL_MEASURE3 '||
              ' ,SUM(BIL_MEASURE5) BIL_MEASURE5 '||
              ' ,SUM(BIL_MEASURE6) BIL_MEASURE6  '||
            ' ,SUM(BIL_MEASURE7) BIL_MEASURE7  '||
              ' ,SUM(BIL_MEASURE9) BIL_MEASURE9  '||
              ' ,SUM(BIL_MEASURE10) BIL_MEASURE10 '||
            ' ,SUM(BIL_MEASURE11) BIL_MEASURE11 '||
              ' ,SUM(BIL_MEASURE13) BIL_MEASURE13 '||
        ' ,SUM(BIL_MEASURE14) BIL_MEASURE14 '||
            ' ,SUM(BIL_MEASURE15) BIL_MEASURE15 '||
              ' ,SUM(BIL_MEASURE17) BIL_MEASURE17 '||
              ' ,SUM(BIL_MEASURE18) BIL_MEASURE18 '||
            ' ,SUM(BIL_MEASURE19) BIL_MEASURE19 '||
              ' ,SUM(BIL_MEASURE21) BIL_MEASURE21 '||
              ' ,SUM(BIL_MEASURE22) BIL_MEASURE22 '||
            ' ,SUM(BIL_MEASURE23) BIL_MEASURE23 '||
            ' ,BIL_URL1  '||
            ' ,BIL_URL2  '||
            ' from ';

	   l_inner_select1:=
              ' (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                      '  THEN   '||
               '   (CASE '||
              '   WHEN NOT(sumry.won_opty_amt'||l_currency_suffix||' IS NULL
                    AND sumry.lost_opty_amt'||l_currency_suffix||' IS NULL AND '||
                '    sumry.no_opty_amt'||l_currency_suffix||' IS NULL)   '||
                ' THEN    '||
                ' (NVL(sumry.won_opty_amt'||l_currency_suffix||',0) + '||
                     ' NVL(sumry.lost_opty_amt'||l_currency_suffix||',0) +   '||
                 ' NVL(sumry.no_opty_amt'||l_currency_suffix||',0)  '||
                ' )  '||
                ' ELSE NULL '||
              ' END)  '||
                 '  ELSE NULL  '||
              ' END)  BIL_MEASURE2 '||
            ' , (CASE WHEN cal.report_date =:l_prev_date  '||
                       ' THEN  '||
                 ' (CASE '||
                ' WHEN NOT(sumry.won_opty_amt'||l_currency_suffix||' IS NULL
                    AND sumry.lost_opty_amt'||l_currency_suffix||' IS NULL '||
                   ' AND sumry.no_opty_amt'||l_currency_suffix||' IS NULL)   '||
                ' THEN   '||
                   ' (NVL(sumry.won_opty_amt'||l_currency_suffix||',0) + '||
                    ' NVL(sumry.lost_opty_amt'||l_currency_suffix||',0)  +   '||
                 ' NVL(sumry.no_opty_amt'||l_currency_suffix||',0)  '||
                ' )  '||
                ' ELSE NULL '||
              ' END)  '||
               ' ELSE NULL '||
              ' END) BIL_MEASURE3 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.won_opty_cnt  '||
                  ' ELSE NULL '||
               ' END) BIL_MEASURE5 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.won_opty_amt'||l_currency_suffix||' '||
                  ' ELSE NULL '||
             '  END)  BIL_MEASURE6 '||
            ' , (CASE WHEN cal.report_date =:l_prev_date '||
                       ' THEN sumry.won_opty_amt'||l_currency_suffix||' '||
                  ' ELSE NULL '||
             ' END)  BIL_MEASURE7 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.lost_opty_cnt '||
                  ' ELSE NULL '||
              ' END) BIL_MEASURE9 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.lost_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL '||
             ' END)  BIL_MEASURE10 '||
            ' , (CASE WHEN cal.report_date =:l_prev_date '||
                       ' THEN sumry.lost_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL  '||
             ' END)  BIL_MEASURE11 '||
            ' , NULL BIL_MEASURE13  '||
      ' , NULL BIL_MEASURE14  '||
            ' , NULL BIL_MEASURE15  '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                      '  THEN sumry.new_opty_cnt  '||
                  ' ELSE NULL  '||
             '  END) BIL_MEASURE17 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.new_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL  '||
             ' END)  BIL_MEASURE18 '||
            ' , (CASE WHEN cal.report_date =:l_prev_date  '||
                       ' THEN sumry.new_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL  '||
             ' END)  BIL_MEASURE19 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.no_opty_cnt  '||
                  ' ELSE NULL  '||
             ' END) BIL_MEASURE21 '||
            ' , (CASE WHEN cal.report_date =:l_curr_as_of_date '||
                       ' THEN sumry.no_opty_amt'||l_currency_suffix||'  '||
                  ' ELSE NULL  '||
             ' END)  BIL_MEASURE22 '||
           '  , (CASE WHEN cal.report_date =:l_prev_date  '||
                       ' THEN sumry.no_opty_amt'||l_currency_suffix||'  '||
               ' ELSE NULL  '||
             ' END) BIL_MEASURE23';


   l_inner_where_clause := ' sumry.effective_time_id = cal.time_id '||
                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id '||
                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date) '||
             'AND sumry.parent_sales_group_id = :l_sg_id_num  ';
   IF l_parent_sales_group_id IS NULL THEN
        IF l_resource_id IS NULL THEN
            l_inner_where_clause1 := ' sumry.effective_time_id = cal.time_id '||
                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id'||
                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)'||
	                    ' AND sumry.parent_sales_group_id IS NULL '||
                    ' AND sumry.sales_group_id = :l_sg_id_num ';
        ELSE
            l_inner_where_clause1 := ' sumry.effective_time_id = cal.time_id '||
                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id'||
                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)'||
	                    ' AND sumry.parent_sales_group_id = sumry.sales_group_id '||
                    ' AND sumry.sales_group_id = :l_sg_id_num ';
        END IF;
   ELSE
   	  IF l_resource_id IS NULL THEN
		 l_inner_where_clause1 := ' sumry.effective_time_id = cal.time_id '||
		                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
		                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id'||
		                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)'||
		                    ' AND sumry.parent_sales_group_id = :l_parent_sales_group_id '||
							' AND sumry.sales_group_id = :l_sg_id_num ';
	  ELSE
	  	l_inner_where_clause1 := ' sumry.effective_time_id = cal.time_id '||
		                    ' AND sumry.effective_period_type_id = cal.period_type_id '||
		                    ' AND bitand(cal.record_type_id, :l_record_type_id)= :l_record_type_id'||
		                    ' AND cal.report_date IN (:l_curr_as_of_date, :l_prev_date)'||
		                    ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
							' AND sumry.sales_group_id = :l_sg_id_num ';
	  END IF;
   END IF;

/*
   l_inner_select3:= '  NULL BIL_MEASURE2 '||
                 ' ,NULL BIL_MEASURE3 '||
                 ' ,NULL BIL_MEASURE5 '||
                 ' ,NULL BIL_MEASURE6 '||
                 ' ,NULL BIL_MEASURE7 '||
                 ' ,NULL BIL_MEASURE9 '||
                 ' ,NULL BIL_MEASURE10 '||
                 ' ,NULL BIL_MEASURE11 '||
             ' ,NULL BIL_MEASURE13 '||
             ' ,(CASE WHEN sumry.snap_date =:l_snap_date THEN '||
                    ' decode(:l_period_type, '||
                      ' 128,open_amt_year'||l_currency_suffix||', '||
                  ' 64,open_amt_quarter'||l_currency_suffix||', '||
                  ' 32,open_amt_period'||l_currency_suffix||', '||
                  ' 16,open_amt_week'||l_currency_suffix||' '||
                   ' )  '||
                           ' ELSE NULL '||
                 ' END) BIL_MEASURE14 '||
                   ' ,(CASE WHEN sumry.snap_date =:l_prev_date THEN '||
                    ' decode(:l_period_type, '||
                      ' 128,open_amt_year'||l_currency_suffix||', '||
                  ' 64,open_amt_quarter'||l_currency_suffix||', '||
                  ' 32,open_amt_period'||l_currency_suffix||', '||
                  ' 16,open_amt_week'||l_currency_suffix||' '||
                   ' ) '||
                           ' ELSE NULL '||
                 ' END) BIL_MEASURE15 '||
             ' ,NULL BIL_MEASURE17 '||
                   ' ,NULL BIL_MEASURE18 '||
                   ' ,NULL BIL_MEASURE19 '||
                     ' ,NULL BIL_MEASURE21 '||
                     ' ,NULL BIL_MEASURE22 '||
                   ' ,NULL BIL_MEASURE23';
*/


IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
   l_inner_where_pipe := ' sumry.snap_date in (:l_snapshot_date, :l_prev_snap_date) ';
ELSE
   l_inner_where_pipe := ' sumry.snap_date in (:l_snapshot_date) ';
END IF;


--   l_inner_select3:=


    l_pipe_select1 := '  NULL BIL_MEASURE2 '||
                 ' ,NULL BIL_MEASURE3 '||
                 ' ,NULL BIL_MEASURE5 '||
                 ' ,NULL BIL_MEASURE6 '||
                 ' ,NULL BIL_MEASURE7 '||
                 ' ,NULL BIL_MEASURE9 '||
                 ' ,NULL BIL_MEASURE10 '||
                 ' ,NULL BIL_MEASURE11 '||
             ' ,NULL BIL_MEASURE13 '||
             ' ,(CASE WHEN sumry.snap_date =:l_snapshot_date THEN '||
                    ' decode(:l_period_type, '||
                      ' 128,open_amt_year'||l_currency_suffix||', '||
                  ' 64,open_amt_quarter'||l_currency_suffix||', '||
                  ' 32,open_amt_period'||l_currency_suffix||', '||
                  ' 16,open_amt_week'||l_currency_suffix||' '||
                   ' )  '||
                           ' ELSE NULL '||
                 ' END) BIL_MEASURE14 ';

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
       l_pipe_select2 :=     ' ,(CASE WHEN sumry.snap_date =:l_prev_snap_date THEN '||
                    ' decode(:l_period_type, '||
                      ' 128,open_amt_year'||l_currency_suffix||', '||
                  ' 64,open_amt_quarter'||l_currency_suffix||', '||
                  ' 32,open_amt_period'||l_currency_suffix||', '||
                  ' 16,open_amt_week'||l_currency_suffix||' '||
                   ' )  '||
                           ' ELSE NULL '||
                 ' END) BIL_MEASURE14 ';
ELSE
    l_pipe_select2 := ' ,(CASE WHEN sumry.snap_date =:l_snapshot_date THEN '||
                          ''||l_prev_amt||' '||
                           ' ELSE NULL '||
                 ' END)  BIL_MEASURE15 ';
END IF;

    l_pipe_select3 :=  ' ,NULL BIL_MEASURE17 '||
                   ' ,NULL BIL_MEASURE18 '||
                   ' ,NULL BIL_MEASURE19 '||
                     ' ,NULL BIL_MEASURE21 '||
                     ' ,NULL BIL_MEASURE22 '||
                   ' ,NULL BIL_MEASURE23';


 l_inner_select3:= l_pipe_select1 || l_pipe_select2 || l_pipe_select3;

	  l_inner_where_clause2:= l_inner_where_pipe ||
              				  ' AND sumry.parent_sales_group_id = :l_sg_id_num  ';



/*
	  l_inner_where_clause2:= ' sumry.snap_date in (:l_snap_date, :l_prev_date) '||
              				  ' AND sumry.parent_sales_group_id = :l_sg_id_num  ';
*/

    IF l_parent_sales_group_id IS NULL THEN
        IF l_resource_id IS NULL THEN
    	   l_inner_where_clause3:= l_inner_where_pipe ||
	              				' AND sumry.parent_sales_group_id IS NULL '||
              					' AND sumry.sales_group_id = :l_sg_id_num  '||
								' AND sumry.grp_total_flag = 0 ';
        ELSE
  	   l_inner_where_clause3:= l_inner_where_pipe ||
	              				' AND sumry.parent_sales_group_id = sumry.sales_group_id '||
              					' AND sumry.sales_group_id = :l_sg_id_num  '||
								' AND sumry.grp_total_flag = 0 ';
        END IF;
	ELSE
		IF l_resource_id IS NULL THEN
			l_inner_where_clause3:= l_inner_where_pipe ||
	              				' AND sumry.parent_sales_group_id = :l_parent_sales_group_id '||
								' AND sumry.sales_group_id = :l_sg_id_num  '||
								' AND sumry.grp_total_flag = 0 ';
		ELSE
			l_inner_where_clause3:=  l_inner_where_pipe ||
	              				' AND sumry.parent_sales_group_id = :l_sg_id_num '||
								' AND sumry.sales_group_id = :l_sg_id_num  '||
								' AND sumry.grp_total_flag = 0 ';
		END IF;
	END IF;
    l_inner_select4:= ' NULL BIL_MEASURE2 '||
                 ' ,NULL BIL_MEASURE3 '||
                 ' ,NULL BIL_MEASURE5 '||
                 ' ,NULL BIL_MEASURE6 '||
                 ' ,NULL BIL_MEASURE7 '||
                 ' ,NULL BIL_MEASURE9 '||
                 ' ,NULL BIL_MEASURE10 '||
                 ' ,NULL BIL_MEASURE11 '||
             ' ,(sumry.latest_open_opty_cnt) BIL_MEASURE13 '||
             ' ,NULL BIL_MEASURE14 '||
                   ' ,NULL BIL_MEASURE15 '||
             ' ,NULL BIL_MEASURE17 '||
                   ' ,NULL BIL_MEASURE18 '||
                   ' ,NULL BIL_MEASURE19 '||
                     ' ,NULL BIL_MEASURE21 '||
                     ' ,NULL BIL_MEASURE22 '||
                   ' ,NULL BIL_MEASURE23';

   l_inner_where_clause4 :=
                  ' sumry.effective_period_type_id = :l_period_type '||
                   ' AND sumry.effective_time_id = :l_curr_page_time_id ';

   l_null_rem_where_clause := ' BIL_MEASURE2 IS NULL  '||
                   ' AND BIL_MEASURE5 IS NULL AND BIL_MEASURE6 IS NULL '||
               ' AND BIL_MEASURE9 IS NULL '||
               ' AND BIL_MEASURE10 IS NULL '||
               ' AND BIL_MEASURE13 IS NULL AND BIL_MEASURE14 IS NULL '||
               ' AND BIL_MEASURE17 IS NULL '||
               ' AND BIL_MEASURE18 IS NULL '||
               ' AND BIL_MEASURE21 IS NULL AND BIL_MEASURE22 IS NULL ';


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => ' l_from3 '||l_from3);

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => ' l_inner_where_clause4 '||l_inner_where_clause4);

                     END IF;


      execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';

      BIL_BI_UTIL_PKG.get_PC_NoRollup_Where_Clause(
                                          p_prodcat      => l_prodcat_id,
                                          p_viewby       => l_viewby,
                                          x_denorm       => l_pipe_denorm,
                                          x_where_clause => l_pipe_product_where_clause);

    l_url_str:='pFunctionName=BIL_BI_OPCOUNTS_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';


         l_sumry1 := 'BIL_BI_OPTY_G_MV';
--       l_sumry2 := 'BIL_BI_PIPE_G_MV';
         l_sumry2  :=  l_open_mv_new  ;
         l_from1 := ' FROM '||l_fii_struct ||' cal, '||l_sumry1||' sumry '||l_denorm;
         l_from2 := ' FROM '||l_sumry2||' sumry ';
         l_from3 := ' FROM '||l_sumry1||' sumry '||l_denorm;
         l_inner_where_clause2 := l_inner_where_clause2||' AND sumry.grp_total_flag = 1 ';
         l_product_where_clause := '';


       /*
        * 1. Need jtf_rs_grp_relations table to get the parent sales group
        * 2. In the case of sales reps, sales group and parent sales group are the same ,
        *    so filtering on sales group directly
        */

        IF l_resource_id IS NULL THEN
          l_custom_sql :=l_insert_stmnt || l_inner_select ||
                     ' ('||
               ' SELECT '||
                    '  DECODE(tmp1.salesrep_id, NULL, grptl.group_name,restl.resource_name) VIEWBY '||
                    ' ,DECODE(tmp1.salesrep_id, NULL, to_char(tmp1.sales_group_id),  '||
						' tmp1.salesrep_id||''.''||tmp1.sales_group_id) VIEWBYID '||
                 ' ,DECODE(tmp1.salesrep_id, NULL, 1,  2) sortorder '||
                     ' ,SUM(tmp1.BIL_MEASURE2) BIL_MEASURE2 '||
                     ' ,SUM(tmp1.BIL_MEASURE3) BIL_MEASURE3 '||
                     ' ,SUM(tmp1.BIL_MEASURE5) BIL_MEASURE5 '||
                     ' ,SUM(tmp1.BIL_MEASURE6) BIL_MEASURE6 '||
                     ' ,SUM(tmp1.BIL_MEASURE7) BIL_MEASURE7 '||
                     ' ,SUM(tmp1.BIL_MEASURE9) BIL_MEASURE9 '||
                     ' ,SUM(tmp1.BIL_MEASURE10) BIL_MEASURE10 '||
                     ' ,SUM(tmp1.BIL_MEASURE11) BIL_MEASURE11 '||
                 ' ,SUM(tmp1.BIL_MEASURE13) BIL_MEASURE13 '||
                 ' ,SUM(tmp1.BIL_MEASURE14) BIL_MEASURE14 '||
                 ' ,SUM(tmp1.BIL_MEASURE15) BIL_MEASURE15 '||
                 ' ,SUM(tmp1.BIL_MEASURE17) BIL_MEASURE17 '||
                       ' ,SUM(tmp1.BIL_MEASURE18) BIL_MEASURE18 '||
                       ' ,SUM(tmp1.BIL_MEASURE19) BIL_MEASURE19 '||
                         ' ,SUM(tmp1.BIL_MEASURE21) BIL_MEASURE21 '||
                         ' ,SUM(tmp1.BIL_MEASURE22) BIL_MEASURE22 '||
                       ' ,SUM(tmp1.BIL_MEASURE23) BIL_MEASURE23 '||
                 ' ,DECODE(tmp1.salesrep_id, NULL, BIL_URL1, NULL) BIL_URL1 '||
                 ' ,DECODE(tmp1.salesrep_id, NULL, NULL,'''||l_drill_link||''') BIL_URL2 '||
            ' FROM ('||
              'SELECT /*+ LEADING(cal) */ '||
                  l_inner_select1||
                               ',sumry.sales_group_id '||
                 ',sumry.salesrep_id salesrep_id '||
                              ','''||l_url_str||''' BIL_URL1 '||
                               ',null BIL_URL2 '||  l_from1 ||
                               ' WHERE cal.xtd_flag=:l_yes AND '
							   		 ||l_inner_where_clause||
                                     l_product_where_clause ;

	           l_custom_sql := l_custom_sql||
	              ' UNION ALL '||
	                'SELECT '||
	                                l_inner_select3||
	                               ',sumry.sales_group_id sales_group_id '||
	                 ',sumry.salesrep_id salesrep_id '||
	                              ','''||l_url_str||''' BIL_URL1 '||
	                               ',null BIL_URL2 '||
	                 l_from2 ||
	                               ' WHERE '||l_inner_where_clause2||
	                                     l_pipe_product_where_clause||
	              ' UNION ALL '||
	                'SELECT '||
	                                l_inner_select4||
	                               ',sumry.sales_group_id sales_group_id '||
	                 ',sumry.salesrep_id salesrep_id '||
	                              ','''||l_url_str||''' BIL_URL1 '||
	                               ',null BIL_URL2 '||
	                 l_from3 ||
	                               ' WHERE '||l_inner_where_clause4||
	                   ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
	                                     l_product_where_clause||' ' ;

	       l_custom_sql := l_custom_sql||
	             ') tmp1 '||
	                  ' ,jtf_rs_groups_tl grptl'||
	             ' ,jtf_rs_resource_extns_tl restl'||
	             ' WHERE  grptl.group_id = tmp1.sales_group_id'||
	                          ' AND grptl.language = USERENV(''LANG'')'||
	                ' AND restl.resource_id(+) = tmp1.salesrep_id'||
	                           ' AND restl.language(+) = USERENV(''LANG'') '||
	             ' GROUP BY DECODE(tmp1.salesrep_id, NULL, grptl.group_name,restl.resource_name),'||
	                      ' DECODE(tmp1.salesrep_id, NULL, to_char(tmp1.sales_group_id),  '||
							' tmp1.salesrep_id||''.''||tmp1.sales_group_id), '||
	                  ' DECODE(tmp1.salesrep_id, NULL, 1,  2), '||
	                     ' DECODE(tmp1.salesrep_id, NULL, BIL_URL1, NULL),  '||
   ' DECODE(tmp1.salesrep_id, NULL, NULL,'''||l_drill_link||''') '||
	          ') GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1,BIL_URL2';
	    ELSE
          l_custom_sql :=l_insert_stmnt || l_inner_select ||
                     ' ('||
			               ' SELECT '||
			                    '  resource_name VIEWBY '||
			                    ' ,tmp1.salesrep_id||''.''||tmp1.sales_group_id VIEWBYID '||
			                 	' ,tmp1.sortorder sortorder '||
			                     ' ,SUM(tmp1.BIL_MEASURE2) BIL_MEASURE2 '||
			                     ' ,SUM(tmp1.BIL_MEASURE3) BIL_MEASURE3 '||
			                     ' ,SUM(tmp1.BIL_MEASURE5) BIL_MEASURE5 '||
			                     ' ,SUM(tmp1.BIL_MEASURE6) BIL_MEASURE6 '||
			                     ' ,SUM(tmp1.BIL_MEASURE7) BIL_MEASURE7 '||
			                     ' ,SUM(tmp1.BIL_MEASURE9) BIL_MEASURE9 '||
			                     ' ,SUM(tmp1.BIL_MEASURE10) BIL_MEASURE10 '||
			                     ' ,SUM(tmp1.BIL_MEASURE11) BIL_MEASURE11 '||
			                 	 ' ,SUM(tmp1.BIL_MEASURE13) BIL_MEASURE13 '||
			                 	 ' ,SUM(tmp1.BIL_MEASURE14) BIL_MEASURE14 '||
			                 	 ' ,SUM(tmp1.BIL_MEASURE15) BIL_MEASURE15 '||
			                 	 ' ,SUM(tmp1.BIL_MEASURE17) BIL_MEASURE17 '||
			                     ' ,SUM(tmp1.BIL_MEASURE18) BIL_MEASURE18 '||
			                     ' ,SUM(tmp1.BIL_MEASURE19) BIL_MEASURE19 '||
			                     ' ,SUM(tmp1.BIL_MEASURE21) BIL_MEASURE21 '||
			                     ' ,SUM(tmp1.BIL_MEASURE22) BIL_MEASURE22 '||
			                     ' ,SUM(tmp1.BIL_MEASURE23) BIL_MEASURE23 '||
			                 ' ,DECODE(tmp1.salesrep_id, NULL, BIL_URL1, NULL) BIL_URL1 '||
			                 ' ,'''||l_drill_link||''' BIL_URL2 '||
			            ' FROM ('||
					              'SELECT /*+ LEADING(cal) */ 1 sortorder, '||
					                  l_inner_select1||
					                 ',sumry.sales_group_id '||
					                 ',sumry.salesrep_id salesrep_id '||
					                 ','''||l_url_str||''' BIL_URL1 '||
					                 ',null BIL_URL2 '||  l_from1 ||
					               ' WHERE cal.xtd_flag=:l_yes AND '
								         ||l_inner_where_clause||
					                      l_product_where_clause ;

				             l_custom_sql := l_custom_sql||
				              ' UNION ALL '||
				                'SELECT 1 sortorder, '||
				                                l_inner_select3||
				                               ',sumry.sales_group_id sales_group_id '||
				                 ',sumry.salesrep_id salesrep_id '||
				                              ','''||l_url_str||''' BIL_URL1 '||
				                               ',null BIL_URL2 '||
				                 l_from2 ||
				                               ' WHERE '||l_inner_where_clause2||
				                                     l_pipe_product_where_clause ||
				              ' UNION ALL '||
				                'SELECT 1 sortorder, '||
				                                l_inner_select4||
				                               ',sumry.sales_group_id sales_group_id '||
				                 ',sumry.salesrep_id salesrep_id '||
				                              ','''||l_url_str||''' BIL_URL1 '||
				                               ',null BIL_URL2 '||
				                 l_from3 ||
				                               ' WHERE '||l_inner_where_clause4||
				                    ' AND sumry.parent_sales_group_id = :l_sg_id_num '||
				                                     l_product_where_clause;

				         l_custom_sql := l_custom_sql||
				             ') tmp1 '||
				             ' ,jtf_rs_resource_extns_tl restl'||
				             ' WHERE  restl.resource_id = tmp1.salesrep_id'||
				                           ' AND restl.language = USERENV(''LANG'') '||
				                ' AND tmp1.salesrep_id = :l_resource_id '||
				             ' GROUP BY restl.resource_name,'||
				                      ' tmp1.salesrep_id||''.''||tmp1.sales_group_id, '||
				                  ' tmp1.sortorder, '||
				                     ' DECODE(tmp1.salesrep_id, NULL, BIL_URL1, NULL), BIL_URL2 '||
				  ') GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1,BIL_URL2';
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



                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'length of query l_custom_sql is '|| length(l_custom_sql));

                     END IF;


	           IF l_resource_id IS NULL THEN

                         IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                             EXECUTE IMMEDIATE l_custom_sql
	                     USING
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		             l_curr_as_of_date,l_prev_date,l_yes,
		             l_record_type_id,l_record_type_id,
		             l_curr_as_of_date, l_prev_date,
		             l_sg_id_num,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                             l_sg_id_num,
		             l_period_type,l_curr_page_time_id,l_sg_id_num;
                           ELSE
                             EXECUTE IMMEDIATE l_custom_sql
	                     USING
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		             l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		             l_curr_as_of_date,l_prev_date,l_yes,
		             l_record_type_id,l_record_type_id,
		             l_curr_as_of_date, l_prev_date,
		             l_sg_id_num,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_prev_snap_date,
                             l_sg_id_num,
		             l_period_type,l_curr_page_time_id,l_sg_id_num;
                            END IF;


		       ELSE
                           IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
		             EXECUTE IMMEDIATE l_custom_sql
                           USING
                    l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
                    l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
                    l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		            l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		            l_curr_as_of_date,l_prev_date,l_yes,
		            l_record_type_id,l_record_type_id,
                    l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_snapshot_date,
l_snapshot_date,
                    l_sg_id_num,
                    l_period_type,l_curr_page_time_id,l_sg_id_num,l_resource_id;
                     ELSE
		             EXECUTE IMMEDIATE l_custom_sql
                           USING
                    l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
                    l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
                    l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		            l_curr_as_of_date,l_prev_date,l_curr_as_of_date,
		            l_curr_as_of_date,l_prev_date,l_yes,
		            l_record_type_id,l_record_type_id,
                    l_curr_as_of_date, l_prev_date,l_sg_id_num,
l_snapshot_date,l_period_type,
l_prev_snap_date,l_period_type,
l_snapshot_date,l_prev_snap_date,
                    l_sg_id_num,
                    l_period_type,l_curr_page_time_id,l_sg_id_num,l_resource_id;
               END IF;
            END IF;



        COMMIT;
        x_custom_sql := ' SELECT * FROM ( '||
                l_outer_select||' FROM BIL_BI_RPT_TMP1 '||
                       ' ORDER BY SORTORDER, UPPER(VIEWBY) '||
             ' ) WHERE NOT('||l_null_rem_where_clause||')';
                --view by Product category


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
			MODULE => g_pkg || l_proc ||'.'|| ' Query to PMV ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


   ELSE --no valid parameters
       BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                     ,x_sqlstr    => x_custom_sql);

                     IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_ERROR,
		                                    MODULE => g_pkg || l_proc || 'Parameter_Error',
		                                    MESSAGE => 'Invalid Parameter '|| l_proc);

                     END IF;
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

    COMMIT;
      RAISE;
 END  BIL_BI_OPPTY_WIN_LOSS_COUNTS;


 /*******************************************************************************
 * Name    : Procedure BIL_BI_GRP_FRCST
 * Author  : Prasanna Patil
 * Date    : June 26, 2003
 * Purpose : Revenue KPI for SMD.
 *
 *           Copyright (c) 2003 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl     PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 * Date     Author     Description
 * ----     ------     -----------
 * 26/16/03 ppatil   Initial version
 * 20/10/05 vchahal  changed to return revenue
 *                   This proc is used by revenue KPI (BIL_BI_REV_KPI) on SMD
 *
 ******************************************************************************/


PROCEDURE BIL_BI_GRP_FRCST ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                ,x_custom_sql         OUT NOCOPY VARCHAR2
                                ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )

 IS

    l_period_type               VARCHAR2(50);
    l_sg_id                     VARCHAR2(50);
    l_conv_rate_selected        VARCHAR2(50);
    l_curr_page_time_id         NUMBER;
    l_prev_page_time_id         NUMBER;
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
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
    l_debug_mode                VARCHAR2(50);
    l_bind_ctr                  NUMBER;
    l_inner_where_clause        VARCHAR2(1000);
    l_sql_stmt                	VARCHAR2(8000);
    l_from1            		VARCHAR2(50);
    l_prodcat_id                VARCHAR2(20);
    l_viewby                    VARCHAR2(200);
    l_resource_id    		VARCHAR2(20);
    l_proc                      VARCHAR2(100);
    l_parent_sales_group_id	NUMBER;
    l_parent_sls_grp_where_clause	VARCHAR2(1000);
    l_currency_suffix            VARCHAR2(5);
    l_yes                        VARCHAR2(1);
    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

  BEGIN

  g_pkg := 'bil.patch.115.sql.BIL_BI_SALES_MGMT_RPTS_PKG.';
  l_region_id := 'BIL_BI_GRP_FRCST';
  l_proc := 'BIL_BI_GRP_FRCST.';
  l_parameter_valid := FALSE;
  l_yes := 'Y';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;


    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    BIL_BI_UTIL_PKG.GET_PAGE_PARAMS( p_page_parameter_tbl => p_page_parameter_tbl
                                    ,p_region_id       => l_region_id
                                    ,x_period_type     => l_period_type
                                    ,x_conv_rate_selected => l_conv_rate_selected
                                    ,x_sg_id          => l_sg_id
                      		    ,x_parent_sg_id   => l_parent_sales_group_id
				    ,x_resource_id    => l_resource_id
                                    ,x_prodcat_id     => l_prodcat_id
                                    ,x_curr_page_time_id  => l_curr_page_time_id
                                    ,x_prev_page_time_id  => l_prev_page_time_id
                                    ,x_comp_type          => l_comp_type
                                    ,x_parameter_valid    => l_parameter_valid
                                    ,x_as_of_date         => l_curr_as_of_date
                                    ,x_page_period_type   => l_page_period_type
                                    ,x_prior_as_of_date   => l_prev_date
                                    ,x_record_type_id     => l_record_type_id
                                    ,x_viewby             => l_viewby);


    l_sg_id_num := replace(l_sg_id,'''');

   IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '1';
   ELSE
            l_currency_suffix := '';
   END IF;

  IF l_parameter_valid THEN
        BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS( x_bitand_id   => l_bitand_id
                                        ,x_calendar_id => l_calendar_id
                                        ,x_curr_date   => l_bis_sysdate
                                        ,x_fii_struct   => l_fii_struct );
        BIL_BI_UTIL_PKG.GET_OTHER_PROFILES( x_debugmode => l_debug_mode );
        l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
        /*Mappings
        *BIL_MEASURE1 => Revenue
        *BIL_MEASURE2 => Prior Revenue
        *BIL_MEASURE3 => Grand Total for BIL_MEASURE1
        *BIL_MEASURE4 => Grand Total for BIL_MEASURE2
        */
           l_inner_where_clause := ' WHERE  sumry.parent_grp_id = :l_sg_id_num
                               AND sumry.grp_marker <> ''TOP GROUP''
                               AND sumry.time_id = cal.time_id
                               AND cal.report_date in (:l_curr_as_of_date, :l_prev_date)
                               AND cal.period_type_id = sumry.period_type_id
                               AND cal.xtd_flag =  :l_yes
                               AND BITAND(cal.record_type_id,:l_record_type_id) = :l_record_type_id
                               AND sumry.cat_top_node_flag = :l_yes ';

l_from1 := ' ISC_DBI_SCR_002_MV ';

IF l_resource_id IS NULL THEN
        l_sql_stmt :=
       'SELECT grptl.group_name VIEWBY
        ,SUM(revenue) BIL_MEASURE1
        ,SUM(priorRevenue) BIL_MEASURE2
        ,SUM(SUM(revenue)) over() BIL_MEASURE3
        ,SUM(SUM(priorRevenue)) over() BIL_MEASURE4
            ,VIEWBYID FROM
        (
         SELECT /*+ leading (cal) */
               SUM(CASE WHEN cal.report_date=:l_curr_as_of_date THEN
                        sumry.recognized_amt_g'||l_currency_suffix||'
                   ELSE NULL
                   END)  revenue
               ,SUM(CASE WHEN cal.report_date =:l_prev_date THEN
                         sumry.recognized_amt_g'||l_currency_suffix||'
                    ELSE NULL
                    END)  priorRevenue
                 ,sumry.sales_grp_id AS VIEWBYID
         FROM '||l_from1 ||'sumry, '||l_fii_struct||'  cal '||
         l_inner_where_clause||' '||
         ' GROUP BY sumry.sales_grp_id
        ) tmp1,
        jtf_rs_groups_tl grptl
      WHERE grptl.group_id = tmp1.viewbyid
        AND grptl.language = USERENV(''LANG'')
      GROUP BY grptl.group_name, VIEWBYID';
ELSE
     l_sql_stmt :=
       'SELECT grptl.resource_name VIEWBY
        ,SUM(revenue) BIL_MEASURE1
        ,SUM(priorRevenue) BIL_MEASURE2
        ,SUM(SUM(revenue)) over() BIL_MEASURE3
        ,SUM(SUM(priorRevenue)) over() BIL_MEASURE4
            ,VIEWBYID FROM
        (
         SELECT /*+ LEADING(cal) */
               SUM(CASE WHEN cal.report_date=:l_curr_as_of_date THEN
                        sumry.recognized_amt_g'||l_currency_suffix||'
                   ELSE NULL
                   END)  revenue,
                SUM(CASE WHEN cal.report_date =:l_prev_date THEN
                         sumry.recognized_amt_g'||l_currency_suffix||'
                    ELSE NULL
                    END)  priorRevenue
              ,sumry.sales_grp_id, sumry.resource_id AS VIEWBYID
         FROM '||l_from1 ||'sumry, '||l_fii_struct||'  cal '||
         l_inner_where_clause||' '||
        ' AND sumry.resource_id = :l_resource_id '||
        ' GROUP BY sumry.sales_grp_id, sumry.resource_id
        ) tmp1,
        jtf_rs_resource_extns_tl grptl
      WHERE grptl.resource_id = tmp1.viewbyid
        AND grptl.language = USERENV(''LANG'')
      GROUP BY grptl.resource_name, VIEWBYID';
END IF;

          x_custom_sql := l_sql_stmt;


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


      /* Bind parameters */
        l_bind_ctr:=1;

        l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_custom_rec.attribute_value := l_viewby;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_curr_page_time_id';
        l_custom_rec.attribute_value :=l_curr_page_time_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_prev_page_time_id';
        l_custom_rec.attribute_value :=l_prev_page_time_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_bitand_id';
        l_custom_rec.attribute_value :=l_bitand_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_period_type';
        l_custom_rec.attribute_value :=l_period_type;
         l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_calendar_id';
        l_custom_rec.attribute_value :=l_calendar_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_curr_as_of_date';
        l_custom_rec.attribute_value := to_char(l_curr_as_of_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_prev_date';
        l_custom_rec.attribute_value := to_char(l_prev_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_sg_id_num';
        l_custom_rec.attribute_value := l_sg_id_num;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        IF l_parent_sales_group_id IS NOT NULL THEN
	   l_custom_rec.attribute_name :=':l_parent_sales_group_id';
           l_custom_rec.attribute_value := l_parent_sales_group_id;
           l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           x_custom_attr.Extend();
           x_custom_attr(l_bind_ctr):=l_custom_rec;
           l_bind_ctr:=l_bind_ctr+1;
        END IF;

      l_custom_rec.attribute_name :=':l_record_type_id';
        l_custom_rec.attribute_value := l_record_type_id;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


        IF (l_resource_id IS NOT NULL) THEN
           l_custom_rec.attribute_name :=':l_resource_id';
           l_custom_rec.attribute_value :=l_resource_id;
           l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
           l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           x_custom_attr.Extend();
           x_custom_attr(l_bind_ctr):=l_custom_rec;
           l_bind_ctr:=l_bind_ctr+1;
        END IF;

        l_custom_rec.attribute_name :=':l_yes';
        l_custom_rec.attribute_value := 'Y';
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):= l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_no';
        l_custom_rec.attribute_value := 'N';
         l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):= l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


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
        'l_calendar_id => '|| l_calendar_id;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'l_sql_error_desc',
		                                    MESSAGE => l_sql_error_desc);

     END IF;


   ELSE --no valid parameters
       BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                         ,x_sqlstr    => x_custom_sql);
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
END BIL_BI_GRP_FRCST;


/*******************************************************************************
 * Name    : Leads, Opportunities and Backlog
 * Author  : Prasanna Patil
 * Date    : July 1, 2003
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
 * Date     Author     Description
 * ----     ------     -----------
 * 07/01/03 ppatil     Intial Version
 * 06/09/04 ctoba      Uptake marketing changes
 * 26 Nov 2004 hrpandey Drill Down to Oppty Line Detail report
 *****************************************************************************/
PROCEDURE BIL_BI_OPEN_LDOPBKLOG (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                           ,x_custom_sql         OUT NOCOPY VARCHAR2
                           ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 AS

    l_start_date            DATE;
    l_period_type           VARCHAR2(50);
    l_sg_id                 VARCHAR2(50);
    l_conv_rate_selected    VARCHAR2(50);
    l_curr_page_time_id     NUMBER;
    l_prev_page_time_id     NUMBER;
    l_custom_rec            BIS_QUERY_ATTRIBUTES;
    l_region_id             VARCHAR2(50);
    l_comp_type             VARCHAR2(50);
    l_parameter_valid       BOOLEAN;
    l_bitand_id             VARCHAR2(50);
    l_calendar_id           VARCHAR2(50);
    l_curr_as_of_date       DATE;
    l_prev_date             DATE;
    l_page_period_type      VARCHAR2(50);
    l_bis_sysdate           DATE;
    l_fii_struct            VARCHAR2(50);
    l_record_type_id        NUMBER;
    l_sql_error_msg         VARCHAR2(1000);
    l_sql_error_desc        VARCHAR2(8000);
    l_sg_id_num             NUMBER;
    l_fst_category          VARCHAR2(50);
    l_fst_crdt_type         VARCHAR2(50);
    l_rpt_str               VARCHAR2(80);
    l_viewby                VARCHAR2(80) ;
    l_bind_ctr              NUMBER;
    l_outer_select          VARCHAR2(8000);
    l_inner_select          VARCHAR2(4000);
    l_prodcat_id            VARCHAR2(50);
    l_null_item             VARCHAR2(50);
    l_product_where_clause  VARCHAR2(1000);
    l_product_where_clause1 VARCHAR2(1000);


    l_url                   VARCHAR2(1000);
    l_cat_assign            VARCHAR2(1000);
    l_cat_url               VARCHAR2(500);
    l_proc                  VARCHAR2(100);
    l_custom_sql            VARCHAR2(32000);

    l_cat_denorm            VARCHAR2(50);
    l_denorm                VARCHAR2(100);

    l_sql_stmt1             VARCHAR2(4000);
    l_sql_stmt2             VARCHAR2(4000);
    l_sql_stmt3             VARCHAR2(8000);

    l_where_clause1         VARCHAR2(1000);
    l_where_clause2         VARCHAR2(1000);
    l_where_clause3         VARCHAR2(1000);
    l_where_clause4         VARCHAR2(1000);
    l_where_clause5         VARCHAR2(1000);
    l_where_clause6         VARCHAR2(1000);

    l_sumry1                VARCHAR2(50);
    l_sumry2                VARCHAR2(50);
    l_sumry3                VARCHAR2(50);

    l_url_str               VARCHAR2(1000);
    l_insert_stmnt          VARCHAR2(32000);
    l_resource_id           VARCHAR2(20);

    l_group_flag            VARCHAR2(30);
    l_open_col              VARCHAR2(20);
    l_null_rem_clause       VARCHAR2(1000);
    l_snapshot_date         DATE;
    l_parent_sg_id_num      NUMBER;
    l_group_by              VARCHAR2(800);
    l_yes                   VARCHAR2(1);
    l_unassigned_value		VARCHAR2(1000);
    l_prodcat_flag          VARCHAR2(200);
    l_currency_suffix       VARCHAR2(5);
    l_isc_currency_suffix   VARCHAR2(5);
	l_drill_link              varchar2(4000);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;


    l_prev_amt           VARCHAR2(1000);
    l_column_type        VARCHAR2(1000);
    l_snap_date          DATE;
    l_open_mv_new        VARCHAR2(1000);
    l_open_mv_new1       VARCHAR2(1000);
    l_prev_snap_date     DATE;
    l_pipe_select1       varchar2(4000);
    l_pipe_select2       varchar2(4000);
    l_pipe_select3       varchar2(4000);
    l_inner_where_pipe   varchar2(4000);


BEGIN

    g_pkg := 'bil.patch.115.sql.BIL_BI_SALES_MGMT_RPTS_PKG.';
    l_region_id := 'BIL_BI_OPEN_LDOPBKLOG';
    l_parameter_valid:= FALSE;
    l_proc := 'BIL_BI_OPEN_LDOPBKLOG.';
    l_yes :='Y';
    g_sch_name := 'BIL';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '||l_proc);

                     END IF;

    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl      => p_page_parameter_tbl
                                    ,p_region_id                  => l_region_id
                                    ,x_period_type                => l_period_type
                                    ,x_conv_rate_selected         => l_conv_rate_selected
                                    ,x_sg_id                      => l_sg_id
                                    ,x_parent_sg_id               => l_parent_sg_id_num
                                    ,x_resource_id                => l_resource_id
                                    ,x_prodcat_id                 => l_prodcat_id
                                    ,x_curr_page_time_id          => l_curr_page_time_id
                                    ,x_prev_page_time_id          => l_prev_page_time_id
                                    ,x_comp_type                  => l_comp_type
                                    ,x_parameter_valid            => l_parameter_valid
                                    ,x_as_of_date                 => l_curr_as_of_date
                                    ,x_page_period_type           => l_page_period_type
                                    ,x_prior_as_of_date           => l_prev_date
                                    ,x_record_type_id             => l_record_type_id
                                    ,x_viewby                     => l_viewby );

        IF l_parameter_valid THEN

    BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS( x_bitand_id => l_bitand_id
                                     ,x_calendar_id => l_calendar_id
                                     ,x_curr_date => l_bis_sysdate
                                     ,x_fii_struct => l_fii_struct );

        l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
        l_prodcat_id := TO_NUMBER(REPLACE(l_prodcat_id,''''));



    IF l_conv_rate_selected = 0 THEN
        l_currency_suffix := '_s';
        l_isc_currency_suffix := '1';
    ELSE
        l_currency_suffix := '';
        l_isc_currency_suffix := '';
    END IF;

    IF l_prodcat_id IS NULL THEN
       l_prodcat_id := 'All';
    END IF;

    CASE  l_page_period_type
            WHEN 'FII_TIME_ENT_YEAR' THEN
                l_open_col := 'open_amt_year'||l_currency_suffix;
            WHEN 'FII_TIME_ENT_QTR' THEN
                l_open_col := 'open_amt_quarter'||l_currency_suffix;
            WHEN 'FII_TIME_ENT_PERIOD' THEN
                l_open_col := 'open_amt_period'||l_currency_suffix;
            ELSE--week
                l_open_col := 'open_amt_week'||l_currency_suffix;
        END CASE;

        IF(l_viewby = 'ORGANIZATION+JTF_ORG_SALES_GROUP' and l_prodcat_id = 'All') THEN
            l_group_flag := ' AND sumry.grp_total_flag = 1 ';
        ELSE
            l_group_flag := ' AND sumry.grp_total_flag = 0 ';
        END IF;

           BIL_BI_UTIL_PKG.GET_PC_NOROLLUP_WHERE_CLAUSE(
                                          p_prodcat      => l_prodcat_id,
                                          p_viewby       => l_viewby,
                                          x_denorm       => l_denorm,
                                          x_where_clause => l_product_where_clause
                                                           );
/*
        BIL_BI_UTIL_PKG.GET_LATEST_SNAP_DATE(p_page_parameter_tbl  =>p_page_parameter_tbl,
                                            p_as_of_date    => l_curr_as_of_date,
                                            p_period_type =>null,
                                            x_snapshot_date => l_snapshot_date);
*/

----  Changes for Drill Links to opty Line Detail Report


-- Get the Drill Link to the Opty Line Detail Report

l_drill_link := bil_bi_util_pkg.get_drill_links( p_view_by =>  l_viewby,
                                                 p_salesgroup_id =>   l_sg_id,
                                                 p_resource_id   =>    l_resource_id  );




/* Get the Prefix for the Open amt based upon Period Type and Compare To Params */


l_prev_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'O',
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
                                     x_snapshot_date => l_snap_date  ,
                                     x_prev_snap_date  => l_prev_snap_date
				    );


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

		             l_sql_error_desc:= 'l_viewby              => '||l_viewby||', '||
                                'l_curr_page_time_id  => '|| l_curr_page_time_id ||', ' ||
                                'l_prev_page_time_id  => '|| l_prev_page_time_id ||', ' ||
                                'l_curr_as_of_date        => '|| l_curr_as_of_date ||', ' ||
                                'l_prev_date              => '|| l_prev_date ||', ' ||
                                'l_conv_rate_selected => '|| l_conv_rate_selected ||', ' ||
                                'l_bitand_id              => '|| l_bitand_id ||', ' ||
                                'l_period_type            => '|| l_period_type ||', ' ||
                                'l_sg_id_num              => '|| l_sg_id_num ||', ' ||
                                'l_resource_id            => '|| l_resource_id ||', '||
                                'l_bis_sysdate            => '|| l_bis_sysdate ||', ' ||
                                'l_fst_crdt_type          => ' || l_fst_crdt_type||', '||
                                'l_record_type_id            => '|| l_record_type_id;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc ||'Param values ',
		                                    MESSAGE =>  'Param values '||l_sql_error_desc);

                     END IF;





   l_outer_select:=  'SELECT VIEWBY';
    IF 'ORGANIZATION+JTF_ORG_SALES_GROUP' = l_viewby THEN
     l_outer_select := l_outer_select ||',DECODE(BIL_URL1,NULL,VIEWBYID||''.''||:l_sg_id_num,VIEWBYID) VIEWBYID ';
    ELSE
     l_outer_select := l_outer_select ||',VIEWBYID ';
    END IF;

   l_outer_select := l_outer_select ||',DECODE(BIL_MEASURE28,0,NULL,BIL_MEASURE28) BIL_MEASURE1'||
                             ',BIL_MEASURE2'||
              ',(BIL_MEASURE28-BIL_MEASURE2)/ABS(DECODE(BIL_MEASURE2,0,null,BIL_MEASURE2)) * 100 BIL_MEASURE3 '||
               ',BIL_MEASURE4'||
                             ',BIL_MEASURE5'||
               ',(BIL_MEASURE4-BIL_MEASURE5)/ABS(DECODE(BIL_MEASURE5,0,null,BIL_MEASURE5)) * 100 BIL_MEASURE6'||
                             ',DECODE(BIL_MEASURE7,0,NULL,BIL_MEASURE7) BIL_MEASURE7'||
                             ',BIL_MEASURE8'||
               ',(BIL_MEASURE7-BIL_MEASURE8)/ABS(DECODE(BIL_MEASURE8,0,null,BIL_MEASURE8)) * 100 BIL_MEASURE9'||
                             ',DECODE(BIL_MEASURE10,0,NULL,BIL_MEASURE10) BIL_MEASURE10'||
                             ',BIL_MEASURE11'||
              ',(BIL_MEASURE10-BIL_MEASURE11)/ABS(DECODE(BIL_MEASURE11,0,null,BIL_MEASURE11)) * 100 BIL_MEASURE12 '||
                             ', BIL_MEASURE4 BIL_MEASURE25 '||
                             ',SUM(DECODE(BIL_MEASURE28,0,NULL,BIL_MEASURE28)) OVER() BIL_MEASURE13'||
                             ',SUM(BIL_MEASURE2) OVER() BIL_MEASURE14'||
                             ',(SUM(BIL_MEASURE28) OVER() - SUM(BIL_MEASURE2) OVER())/ABS(DECODE(SUM(BIL_MEASURE2) OVER(), 0, null, SUM(BIL_MEASURE2)
                                 OVER()))*100 BIL_MEASURE15 '||
                             ',SUM(BIL_MEASURE4) OVER() BIL_MEASURE16'||
                             ',SUM(BIL_MEASURE5) OVER() BIL_MEASURE17'||
                             ',(SUM(BIL_MEASURE4) OVER() - SUM(BIL_MEASURE5) OVER())/ABS(DECODE(SUM(BIL_MEASURE5) OVER(), 0, null, SUM(BIL_MEASURE5)
                                  OVER()))*100 BIL_MEASURE18 '||
                             ',SUM(DECODE(BIL_MEASURE7,0,NULL,BIL_MEASURE7)) OVER() BIL_MEASURE19'||
                             ',SUM(BIL_MEASURE8) OVER() BIL_MEASURE20'||
                             ',(SUM(BIL_MEASURE7) OVER() - SUM(BIL_MEASURE8) OVER())/ABS(DECODE(SUM(BIL_MEASURE8) OVER(), 0, null, SUM(BIL_MEASURE8)
                                  OVER()))*100 BIL_MEASURE21 '||
                             ',SUM(DECODE(BIL_MEASURE10,0,NULL,BIL_MEASURE10)) OVER() BIL_MEASURE22'||
                             ',SUM(BIL_MEASURE11) OVER() BIL_MEASURE23'||
                             ',(SUM(BIL_MEASURE10) OVER() - SUM(BIL_MEASURE11) OVER())/ABS(DECODE(SUM(BIL_MEASURE11) OVER(), 0, null, SUM(BIL_MEASURE11)
                                 OVER()))*100 BIL_MEASURE24 '||
                             ',SUM(BIL_MEASURE4) OVER() BIL_MEASURE26'||
                             ',BIL_URL1'||
                             ',BIL_URL2
,DECODE('''||l_curr_as_of_date||''',TRUNC(SYSDATE),
                        DECODE('''||l_viewby||''',''ORGANIZATION+JTF_ORG_SALES_GROUP'',
                               DECODE(BIL_URL2,NULL,NULL,BIL_URL2||'||'''BIL_DIMENSION1=OPEN'''||'),
                               DECODE(BIL_URL1,NULL,NULL,BIL_URL1||'||'''BIL_DIMENSION1=OPEN'''||')),
                       NULL) BIL_URL3
   ';

l_inner_select :=  'SELECT VIEWBY
                                         ,SORTORDER
                                         ,SUM(BIL_MEASURE28) BIL_MEASURE28
                                         ,SUM(BIL_MEASURE2) BIL_MEASURE2
                                         ,SUM(BIL_MEASURE4) BIL_MEASURE4
                                         ,SUM(BIL_MEASURE5) BIL_MEASURE5
                                         ,SUM(BIL_MEASURE7) BIL_MEASURE7
                                         ,SUM(BIL_MEASURE8) BIL_MEASURE8
                                         ,SUM(BIL_MEASURE10) BIL_MEASURE10
                                         ,SUM(BIL_MEASURE11) BIL_MEASURE11
                                         ,VIEWBYID
                                         ,BIL_URL1
                                         ,BIL_URL2 ';

           l_rpt_str:='BIL_BI_LDOPBKLOG_R';
           l_insert_stmnt := ' INSERT INTO bil_bi_rpt_tmp1(VIEWBY,VIEWBYID,SORTORDER,
                                BIL_MEASURE28, BIL_MEASURE2,'||
                                'BIL_MEASURE4,BIL_MEASURE5,BIL_MEASURE7,BIL_MEASURE8,'||
                                'BIL_MEASURE10,BIL_MEASURE11, BIL_URL1,BIL_URL2)';

           l_null_rem_clause := ' WHERE NOT ((BIL_MEASURE28 IS NULL OR BIL_MEASURE28 = 0)
                                           AND (BIL_MEASURE4 IS NULL OR BIL_MEASURE4 = 0)
                                           AND (BIL_MEASURE7 IS NULL OR BIL_MEASURE7 = 0)
                                           AND (BIL_MEASURE10 IS NULL OR BIL_MEASURE10 = 0)) ';

         execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';

/* The following section is dedicated to Open oppty amount */

/*
        l_sql_stmt1:=' NULL BIL_MEASURE28 '||
                        ',NULL BIL_MEASURE2 '||
                        ',  '||
                        'SUM(CASE WHEN sumry.snap_date =:l_snapshot_date THEN '||
                        'sumry.'||l_open_col ||' '||
                        'ELSE NULL '||
                        'END '||
                        ' ) BIL_MEASURE4 '||
                        ',SUM(  '||
                        'CASE WHEN sumry.snap_date =:l_prev_date THEN '||
                        'sumry.'||l_open_col ||' '||
                        'ELSE NULL '||
                        'END '||
                        ' ) BIL_MEASURE5 '||
                        ',NULL BIL_MEASURE7 '||
                        ',NULL BIL_MEASURE8 '||
                        ',NULL BIL_MEASURE10 '||
                        ',NULL BIL_MEASURE11 ';
*/

l_pipe_select1 := ' NULL BIL_MEASURE28 '||
                        ',NULL BIL_MEASURE2 '||
                        ',  '||
                        'SUM(CASE WHEN sumry.snap_date =:l_snap_date THEN '||
                        'sumry.'||l_open_col ||' '||
                        'ELSE NULL '||
                        'END '||
                        ' ) BIL_MEASURE4 ';

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN

    l_pipe_select2 := ',SUM(  '||
                        'CASE WHEN sumry.snap_date =:l_prev_snap_date THEN '||
                        'sumry.'||l_open_col ||' '||
                        'ELSE NULL '||
                        'END '||
                        ' ) BIL_MEASURE5 ';
ELSE
    l_pipe_select2 := ',SUM(  '||
                        'CASE WHEN sumry.snap_date =:l_snap_date THEN '||
                        ''||l_prev_amt||' '||
                        'ELSE NULL '||
                        'END '||
                        ' ) BIL_MEASURE5 ';
END IF;


l_pipe_select3 :=      ',NULL BIL_MEASURE7 '||
                        ',NULL BIL_MEASURE8 '||
                        ',NULL BIL_MEASURE10 '||
                        ',NULL BIL_MEASURE11 ';

        l_sql_stmt1:= l_pipe_select1 || l_pipe_select2 || l_pipe_select3;


/*
        l_where_clause1 :=' WHERE sumry.parent_sales_group_id = :l_sg_id_num '||
                                ' AND sumry.snap_date in (:l_snapshot_date, :l_prev_date) ';

        l_where_clause4 :=' WHERE sumry.snap_date in (:l_snapshot_date, :l_prev_date)
                                AND sumry.sales_group_id = :l_sg_id_num ';
*/

IF (l_open_mv_new =  'BIL_BI_PIPE_G_MV') THEN
   l_inner_where_pipe := '  sumry.snap_date in (:l_snap_date, :l_prev_snap_date)  ';
ELSE
   l_inner_where_pipe := '  sumry.snap_date in (:l_snap_date)  ';
END IF;


        l_where_clause1 :=' WHERE sumry.parent_sales_group_id = :l_sg_id_num AND  '||
                              l_inner_where_pipe   ;


        l_where_clause4 := l_inner_where_pipe ||
                                ' AND sumry.sales_group_id = :l_sg_id_num ';

        if(l_resource_id is not null) then
                l_where_clause4:= l_where_clause4 ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num';
             else
                l_where_clause4:=l_where_clause4 ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sg_id_num IS NULL then
                    l_where_clause4:=l_where_clause4 || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_where_clause4:=l_where_clause4 ||   ' AND sumry.parent_sales_group_id = :l_parent_sg_id_num ';
                end if;
             end if;




/*The following section is dedicated to Leads open count */

           l_sql_stmt2:='SUM( '||
                        'CASE WHEN cal.report_date=:l_curr_as_of_date THEN '||
                        '(sumry.leads-(sumry.leads_closed+sumry.leads_dead+sumry.leads_converted))  '||
                        'ELSE NULL '||
                        'END '||
                        ') BIL_MEASURE28 '||
                        ',SUM( '||
                        'CASE WHEN cal.report_date=:l_prev_date THEN'||
                        '(sumry.leads-(sumry.leads_closed+sumry.leads_dead+sumry.leads_converted)) '||
                        'ELSE NULL '||
                        'END '||
                        ') BIL_MEASURE2 '||
                        ',NULL BIL_MEASURE4 '||
                        ',NULL BIL_MEASURE5 '||
                        ',NULL BIL_MEASURE7 '||
                        ',NULL BIL_MEASURE8 '||
                        ',NULL BIL_MEASURE10 '||
                        ',NULL BIL_MEASURE11 ';

        l_where_clause2 := ' WHERE sumry.time_id=cal.time_id  '||
                            'AND sumry.period_type_id=cal.period_type_id '||
                            'AND bitand(cal.record_type_id, :l_bitand_id)= :l_bitand_id '||
                            'AND cal.report_date in (:l_curr_as_of_date, :l_prev_date)  AND cal.xtd_flag=''Y'' '||
                            ' AND sumry.update_time_id = ''-1'' '||
                            ' AND sumry.update_period_type_id = ''-1''';



        l_where_clause5 :=' WHERE sumry.TIME_ID = cal.TIME_ID '||
                            'AND sumry.PERIOD_TYPE_ID = cal.PERIOD_TYPE_ID '||
                            'AND bitand(cal.record_type_id, :l_bitand_id)= :l_bitand_id '||
                            'AND cal.report_date in (:l_curr_as_of_date, :l_prev_date) AND cal.xtd_flag=''Y'' '||
                            'AND sumry.group_id = :l_sg_id_num '||
                            'AND sumry.update_time_id = ''-1'' '||
                            'AND sumry.update_period_type_id = ''-1'' ';


/* The following section is dedicated to backlog amt and deferred amt*/



           l_sql_stmt3:='NULL BIL_MEASURE28
                    ,NULL BIL_MEASURE2
                    ,NULL BIL_MEASURE4
                    ,NULL BIL_MEASURE5
                    ,SUM( '||
                    'CASE WHEN  cal.report_date=:l_curr_as_of_date THEN '||
                    '(sumry.backlog_amt_g'||l_isc_currency_suffix||') '||
                    'ELSE NULL '||
                    'END '||
                    ')  BIL_MEASURE7 '||
                    ',SUM( '||
                    'CASE WHEN cal.report_date=:l_prev_date THEN '||
                    '(sumry.backlog_amt_g'||l_isc_currency_suffix||') '||
                    'ELSE NULL '||
                    'END '||
                    ')  BIL_MEASURE8 '||
                    ',SUM( '||
                    'CASE WHEN cal.report_date=:l_curr_as_of_date THEN '||
                    '(sumry.deferred_amt_g'||l_isc_currency_suffix||') '||
                    'ELSE NULL '||
                    'END '||
                    ')  BIL_MEASURE10 '||
                    ',SUM( '||
                    'CASE WHEN cal.report_date=:l_prev_date THEN '||
                    '(sumry.deferred_amt_g'||l_isc_currency_suffix||') '||
                    'ELSE NULL '||
                    'END '||
                    ')  BIL_MEASURE11 ';
--For issue similar to that in bug 3640113 removed sumry.cat_top_node_flag =''Y''
        l_where_clause3 := ' WHERE  sumry.parent_grp_id = :l_sg_id_num
                            AND sumry.grp_marker <> ''TOP GROUP''
                            AND sumry.time_id = cal.time_id AND cal.xtd_flag=''Y''
                            AND cal.report_date in (:l_curr_as_of_date, :l_prev_date)
                            AND cal.period_type_id = sumry.period_type_id
                             AND bitand(cal.record_type_id,:l_bitand_id) = :l_bitand_id';


        l_where_clause6 := ' WHERE sumry.time_id = cal.time_id
                                AND sumry.sales_grp_id = :l_sg_id_num ';


if(l_resource_id is not null) then
                l_where_clause6:= l_where_clause6 ||
                    ' AND sumry.resource_id = :l_resource_id AND sumry.parent_grp_id = :l_sg_id_num';
             else
                l_where_clause6:=l_where_clause6 ||
                    ' AND sumry.resource_id IS NULL ';
                if l_parent_sg_id_num IS NULL then
                    l_where_clause6:=l_where_clause6 || ' AND sumry.parent_grp_id = sumry.sales_grp_id ';
                else
                   l_where_clause6:=l_where_clause6 ||   ' AND sumry.parent_grp_id = :l_parent_sg_id_num ';
                end if;
             end if;

             l_where_clause6 := l_where_clause6 ||
             '  AND cal.report_date in (:l_curr_as_of_date, :l_prev_date)
                            AND cal.period_type_id = sumry.period_type_id AND cal.xtd_flag=''Y''
                            AND bitand(cal.record_type_id,:l_bitand_id) = :l_bitand_id';

CASE l_viewby
WHEN 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN



l_url_str:='pFunctionName=BIL_BI_LDOPBKLOG_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
            IF l_prodcat_id = 'All'  THEN
                    l_prodcat_flag := ' ';
                    l_sumry2 := 'BIM_I_LD_GEN_SG_MV';
                    l_product_where_clause1 := ' AND sumry.cat_top_node_flag =''Y''';
                    l_group_by := ' group by sumry.salesrep_id,sumry.sales_group_id, '||
                                '(CASE WHEN sumry.salesrep_id IS NULL THEN 1 ELSE 2 END),
                                (CASE WHEN sumry.salesrep_id IS NULL
                                THEN '''||l_url_str||''' ELSE NULL END)  ';

            ELSE
                    l_prodcat_flag := 'sumry.product_category_id, ';
                    l_sumry2 := 'BIM_I_LP_GEN_SG_MV';
                    l_product_where_clause1:= ' AND sumry.item_category_id = :l_prodcat ';
                    l_group_by := ' GROUP BY  sumry.salesrep_id,sumry.sales_group_id,
                                    '||l_prodcat_flag||'
                                    (CASE WHEN sumry.salesrep_id IS NULL THEN 1 ELSE 2 END),
                                (CASE WHEN sumry.salesrep_id IS NULL
                                THEN  '''||l_url_str||''' ELSE NULL END) ';

            END IF;

--          l_sumry1 := 'BIL_BI_PIPE_G_MV';
            l_sumry1 := l_open_mv_new ;
            l_sumry3 := 'ISC_DBI_SCR_002_MV';



            l_custom_sql:= 'SELECT decode(sumry.salesrep_id, NULL, grptl.group_name,
                restl.resource_name) VIEWBY, decode(sumry.salesrep_id, NULL,
                sumry.sales_group_id, sumry.salesrep_id) VIEWBYID,
                SORTORDER, BIL_MEASURE28, BIL_MEASURE2, BIL_MEASURE4,
                BIL_MEASURE5, BIL_MEASURE7, BIL_MEASURE8, BIL_MEASURE10,
                BIL_MEASURE11, BIL_URL1,
                     DECODE(sumry.salesrep_id, NULL, NULL,'''||l_drill_link||''') BIL_URL2
                FROM (
                    SELECT /*+ NO_MERGE */ salesrep_id, sales_group_id, sortorder,
                    sum(bil_measure28) bil_measure28,sum(bil_measure2) bil_measure2,
                    sum(bil_measure4) bil_measure4, sum(bil_measure5) bil_measure5,
                    SUM(BIL_MEASURE7) BIL_MEASURE7 ,SUM(BIL_MEASURE8) BIL_MEASURE8 ,
                    SUM(BIL_MEASURE10) BIL_MEASURE10,
                    SUM(BIL_MEASURE11) BIL_MEASURE11, BIL_URL1, NULL BIL_URL2
                    FROM (
                        SELECT salesrep_id, sales_group_id, sortorder,
                        sum(bil_measure28) bil_measure28,
                        sum(bil_measure2) bil_measure2,
                        sum(bil_measure4) bil_measure4,
                        sum(bil_measure5) bil_measure5,
                        NULL BIL_MEASURE7 ,NULL BIL_MEASURE8 ,
                        NULL BIL_MEASURE10 ,NULL BIL_MEASURE11,
                        BIL_URL1, NULL BIL_URL2
                        FROM ( ';

            --Open Opportunity by sales group and sales rep

                l_custom_sql :=l_custom_sql||'SELECT  sumry.salesrep_id,sumry.sales_group_id,
                                '||l_prodcat_flag||'
                                (CASE WHEN sumry.salesrep_id IS NULL THEN 1 ELSE 2 END) SORTORDER' ||
                                ','||l_sql_stmt1||
                                ',(CASE WHEN sumry.salesrep_id IS NULL
                                THEN '''||l_url_str||''' ELSE NULL END) BIL_URL1
                                ,NULL BIL_URL2
                                FROM '||l_sumry1||' sumry
                                '||l_where_clause1||'
                                '||l_group_flag;

                IF l_resource_id IS NOT NULL THEN
                    l_custom_sql := l_custom_sql||' AND sumry.salesrep_id = '||l_resource_id;
                END IF;

                l_custom_sql := l_custom_sql||l_group_by;

            --Leads open count by sales group

            IF l_resource_id IS NULL THEN
                l_custom_sql := l_custom_sql||' UNION ALL SELECT  /*+ leading (cal) */ null salesrep_id,
                                sumry.group_id sales_group_id , '||l_prodcat_flag||
                                         '1 SORTORDER,' ||
                                        ' '||l_sql_stmt2||
                                        ','''||l_url_str||''' BIL_URL1 '||
                                        ',null BIL_URL2 '||
                                        ' FROM '||l_sumry2||' sumry,
                                        jtf_rs_grp_relations rels, '||
                                        l_fii_struct||' cal '||
                                        l_where_clause2||
                                        ' AND rels.related_group_id = :l_sg_id_num '||
                                        ' AND rels.relation_type = ''PARENT_GROUP'' '||
                                        ' AND rels.group_id <> rels.related_group_id '||
                                        ' AND :l_bis_sysdate BETWEEN rels.start_date_active '||
                                        ' AND NVL(rels.end_date_active, :l_bis_sysdate) '||
                                        ' AND NVL(rels.delete_flag, ''N'') <> ''Y'' '||
                                        ' AND sumry.group_id = rels.group_id '||
                                        ' AND sumry.resource_id = ''-1'' ' ||
                                        ' GROUP BY  '||l_prodcat_flag||' sumry.group_id ';

        END IF; -- if resource id is null ends

        --Leads open count by sales rep
        l_custom_sql := l_custom_sql||' UNION ALL SELECT /*+ leading (cal) */ sumry.resource_id salesrep_id ,
                                 sumry.group_id sales_group_id, '||l_prodcat_flag||
                                ' 2 SORTORDER '||
                                ','||l_sql_stmt2||
                                ',NULL BIL_URL1 '||
                                ',NULL BIL_URL2 '||
                                ' FROM '||l_sumry2||' sumry '||
                                ','||l_fii_struct||' cal '||
                                ' '||l_where_clause2||
                                ' AND sumry.group_id = :l_sg_id_num ';

        IF l_resource_id IS NULL THEN
            l_custom_sql := l_custom_sql||' AND sumry.resource_id <>''-1''';
        ELSE
            l_custom_sql := l_custom_sql||' AND sumry.resource_id = '||l_resource_id;
        END IF;

        l_custom_sql := l_custom_sql||
                            ' GROUP BY '||l_prodcat_flag||' sumry.resource_id, sumry.group_id ';

        l_custom_sql := l_custom_sql||') sumry '||l_denorm ;

        if(l_prodcat_id is not NULL) then
            l_custom_sql := l_custom_sql||' where 1=1 '||l_product_where_clause||
                'group by salesrep_id, sales_group_id, sortorder, bil_url1 ';
        end if;


        -- Backlog amt and deferred amt by sales group and sales rep

            l_custom_sql := l_custom_sql||' UNION ALL SELECT  /*+ leading (cal) */ sumry.resource_id salesrep_id,
                                sumry.sales_grp_id sales_group_id  '||
                                ',(CASE WHEN sumry.resource_id IS NULL THEN 1 ELSE 2 END) SORTORDER' ||
                                ','||l_sql_stmt3||
                                ',(CASE WHEN sumry.resource_id IS NULL
                                THEN '''||l_url_str||''' ELSE NULL END) BIL_URL1
                                ,NULL BIL_URL2
                                FROM '||l_sumry3||' sumry
                                ,'||l_fii_struct||' cal '
                                ||l_where_clause3||'
                                 '||l_product_where_clause1;
              IF l_resource_id IS NOT NULL THEN
                    l_custom_sql := l_custom_sql||' AND sumry.resource_id = '||l_resource_id;
                END IF;

                     l_custom_sql := l_custom_sql||'
                                 GROUP BY (CASE WHEN sumry.resource_id IS NULL THEN 1 ELSE 2 END) ,
                                sumry.resource_id ,
                                sumry.sales_grp_id  ,
                                (CASE WHEN sumry.resource_id IS NULL
                                THEN '''||l_url_str||''' ELSE NULL END)';

                l_custom_sql := l_custom_sql||' ) group by salesrep_id,
                                sales_group_id, sortorder, BIL_URL1
                                ) sumry, jtf_rs_groups_tl grptl,
                                jtf_rs_resource_extns_tl restl
                                where grptl.group_id = sumry.sales_group_id
                                           AND grptl.language = USERENV(''LANG'')
                                           AND restl.language(+) = USERENV(''LANG'')
                                           AND restl.resource_id(+) = sumry.salesrep_id ';


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


IF l_prodcat_id = 'All'  THEN
   if l_resource_id is null then
         IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
           EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                --open oppties
                USING l_snap_date,
                l_snap_date, l_sg_id_num,
                l_snap_date,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date
                , l_sg_id_num, l_bis_sysdate, l_bis_sysdate,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date,
                l_sg_id_num,
                --backlog
                l_curr_as_of_date,
                l_prev_date,
                l_curr_as_of_date,
                l_prev_date,
                l_sg_id_num,l_curr_as_of_date, l_prev_date,
                l_bitand_id,l_bitand_id
                ;
          ELSE
               EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                --open oppties
                USING l_snap_date,
                l_prev_snap_date, l_sg_id_num,
                l_snap_date, l_prev_snap_date,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date
                , l_sg_id_num, l_bis_sysdate, l_bis_sysdate,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date,
                l_sg_id_num,
                --backlog
                l_curr_as_of_date,
                l_prev_date,
                l_curr_as_of_date,
                l_prev_date,
                l_sg_id_num,l_curr_as_of_date, l_prev_date,
                l_bitand_id,l_bitand_id
                ;
          END IF;
      else
           IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_snap_date,
                l_snap_date, l_sg_id_num,
                l_snap_date,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date,
                l_sg_id_num,
                --backlog
                l_curr_as_of_date,
                l_prev_date,
                l_curr_as_of_date,
                l_prev_date,
                l_sg_id_num,l_curr_as_of_date, l_prev_date,
                l_bitand_id,l_bitand_id
                ;
           ELSE
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_snap_date,
                l_prev_snap_date, l_sg_id_num,
                l_snap_date, l_prev_snap_date,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date,
                l_sg_id_num,
                --backlog
                l_curr_as_of_date,
                l_prev_date,
                l_curr_as_of_date,
                l_prev_date,
                l_sg_id_num,l_curr_as_of_date, l_prev_date,
                l_bitand_id,l_bitand_id
                ;
           END IF;
      end if;
ELSE  --prodcat selected
    if l_resource_id is null then
           IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                 --open oppties
                USING l_snap_date,
                l_snap_date, l_sg_id_num,
                l_snap_date,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date
                ,  l_sg_id_num,l_bis_sysdate, l_bis_sysdate,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date
                , l_sg_id_num, l_prodcat_id,
                --backlog
                l_curr_as_of_date,
                l_prev_date,
                l_curr_as_of_date,
                l_prev_date,
                l_sg_id_num,l_curr_as_of_date, l_prev_date,
                l_bitand_id, l_bitand_id, l_prodcat_id;
            ELSE
                 EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                 --open oppties
                USING l_snap_date,
                l_prev_snap_date, l_sg_id_num,
                l_snap_date, l_prev_snap_date,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date
                ,  l_sg_id_num,l_bis_sysdate, l_bis_sysdate,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date
                , l_sg_id_num, l_prodcat_id,
                --backlog
                l_curr_as_of_date,
                l_prev_date,
                l_curr_as_of_date,
                l_prev_date,
                l_sg_id_num,l_curr_as_of_date, l_prev_date,
                l_bitand_id, l_bitand_id, l_prodcat_id;
             END IF;
    else
             IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                 --open oppties
                USING l_snap_date,
                l_snap_date, l_sg_id_num,
                l_snap_date,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date
                , l_sg_id_num, l_prodcat_id,
                --backlog
                l_curr_as_of_date,
                l_prev_date,
                l_curr_as_of_date,
                l_prev_date,
                l_sg_id_num,l_curr_as_of_date, l_prev_date,
                l_bitand_id, l_bitand_id, l_prodcat_id;
             ELSE
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                 --open oppties
                USING l_snap_date,
                l_prev_snap_date, l_sg_id_num,
                l_snap_date, l_prev_snap_date,
                --open leads
                l_curr_as_of_date, l_prev_date
                , l_bitand_id, l_bitand_id, l_curr_as_of_date, l_prev_date
                , l_sg_id_num, l_prodcat_id,
                --backlog
                l_curr_as_of_date,
                l_prev_date,
                l_curr_as_of_date,
                l_prev_date,
                l_sg_id_num,l_curr_as_of_date, l_prev_date,
                l_bitand_id, l_bitand_id, l_prodcat_id;
             END IF;
    end if;
END IF;
COMMIT;


            x_custom_sql:= l_outer_select ||
                            ' FROM( '||
                            'SELECT VIEWBY, SORTORDER,
                            SUM(BIL_MEASURE28) BIL_MEASURE28, '||
                            'SUM(BIL_MEASURE2) BIL_MEASURE2, '||
                            'SUM(BIL_MEASURE4) BIL_MEASURE4,
                            SUM(BIL_MEASURE5) BIL_MEASURE5, '||
                            'SUM(BIL_MEASURE7) BIL_MEASURE7,
                            SUM(BIL_MEASURE8) BIL_MEASURE8, '||
                            'SUM(BIL_MEASURE10) BIL_MEASURE10,
                            SUM(BIL_MEASURE11) BIL_MEASURE11, '||
                            'VIEWBYID, BIL_URL1, BIL_URL2 '||
                            ' FROM BIL_BI_RPT_TMP1 GROUP BY VIEWBY, SORTORDER, VIEWBYID, BIL_URL1, BIL_URL2 '||
                            ') '|| l_null_rem_clause ||' ORDER BY SORTORDER, VIEWBY ';



WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN

        l_cat_url := 'pFunctionName='||l_rpt_str||'&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';

--      l_sumry1 := 'BIL_BI_PIPE_G_MV ';
        l_sumry1 := l_open_mv_new ;
        l_sumry2 := 'BIM_I_LP_GEN_SG_MV ';
        l_sumry3 := 'ISC_DBI_SCR_002_MV ';

        IF (l_prodcat_id = 'All') THEN
            l_product_where_clause1 := ' AND pcd.top_node_flag = :l_yes
                            AND pcd.parent_id = sumry.item_category_id
                            AND pcd.child_id = sumry.item_category_id
                            AND sumry.item_category_id = pcd.child_id
                            AND sumry.cat_top_node_flag = :l_yes ';
            l_group_by := ' group by pcd.value, pcd.id';
        ELSE
            l_product_where_clause1 := ' AND pcd.parent_id = :l_prodcat
                                         AND pcd.id = pcd.child_id
                                         AND sumry.item_category_id = pcd.child_id
                                         AND sumry.item_category_id = pcd.id
                                         AND ((pcd.child_id <> pcd.parent_id AND pcd.leaf_node_flag = ''N'')
                                              OR pcd.leaf_node_flag = ''Y'') ';
            l_group_by := ' group by sumry.product_category_id, sumry.item_id';
        END IF;




        IF l_prodcat_id = 'All' THEN

        l_unassigned_value:= bil_bi_util_pkg.GET_UNASSIGNED_PC;


            --Open Opportunity by prod cat
            l_custom_sql := ' SELECT null VIEWBY'||
            ',sumry.product_category_id VIEWBYID'||
            ', 1 SORTORDER'||
            ','||l_sql_stmt1||
            ',NULL BIL_URL1'||
            ',NULL BIL_URL2 '||
             ' FROM '||l_sumry1||' sumry'||
            ' '||l_where_clause4||
            ' '||l_group_flag||
            ' GROUP BY  sumry.product_category_id';

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


if(l_resource_id is not null) then
      IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
            EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_snap_date,
                    l_snap_date,
                    l_snap_date,
                    l_sg_id_num,l_resource_id,l_sg_id_num;
            COMMIT;
       ELSE
             EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_snap_date,
                    l_prev_snap_date,
                    l_snap_date, l_prev_snap_date,
                    l_sg_id_num,l_resource_id,l_sg_id_num;
            COMMIT;
       END IF;
else
  if (l_parent_sg_id_num is not null) then
       IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
             EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_snap_date,
                    l_snap_date,
                    l_snap_date,
                    l_sg_id_num,l_parent_sg_id_num;
            COMMIT;
        ELSE
              EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_snap_date,
                    l_prev_snap_date,
                    l_snap_date, l_prev_snap_date,
                    l_sg_id_num,l_parent_sg_id_num;
            COMMIT;
        END IF;
  else
         IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_snap_date,
                    l_snap_date,
                    l_snap_date,  l_sg_id_num;
                COMMIT;
         ELSE
                  EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_snap_date,
                    l_prev_snap_date,
                    l_snap_date, l_prev_snap_date,l_sg_id_num;
                COMMIT;
          END IF;
  end if;
end if;





        --Leads open count by prod cat


        l_custom_sql := ' SELECT /*+ leading (cal) */ null VIEWBY'||
                        ',sumry.product_category_id VIEWBYID'||
                        ', 1 SORTORDER'||
                        ','||l_sql_stmt2||
                        ',NULL BIL_URL1'||
                        ',NULL BIL_URL2 '||
                        ' FROM '||l_sumry2||' sumry'||
                        ','||l_fii_struct||' cal'||
                        ' '||l_where_clause5;


        IF l_resource_id IS NULL THEN
            l_custom_sql := l_custom_sql||' AND sumry.resource_id = ''-1'' ';
        ELSE
            l_custom_sql := l_custom_sql||' AND sumry.resource_id = :l_resource_id ';
        END IF;

       l_custom_sql := l_custom_sql||' GROUP BY sumry.product_category_id ';


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| 'Leads by PC ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


IF l_resource_id IS NULL THEN
    EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
    USING l_curr_as_of_date,l_prev_date,
    l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date,l_sg_id_num;
ELSE
        EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
    USING l_curr_as_of_date,l_prev_date,
    l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date,l_sg_id_num,l_resource_id;

END IF;

        --Backlog amt and deferred amt by prod cat

 x_custom_sql := l_outer_select||' FROM (
                    SELECT VIEWBY, VIEWBYID, SORTORDER, SUM(BIL_MEASURE28) BIL_MEASURE28,
                    SUM(BIL_MEASURE2) BIL_MEASURE2, SUM(BIL_MEASURE4) BIL_MEASURE4,
                    SUM(BIL_MEASURE5) BIL_MEASURE5, SUM(BIL_MEASURE7) BIL_MEASURE7,
                    SUM(BIL_MEASURE8) BIL_MEASURE8, SUM(BIL_MEASURE10) BIL_MEASURE10,
                    SUM(BIL_MEASURE11) BIL_MEASURE11, BIL_URL1, BIL_URL2 FROM
                    (select decode(parent_id, -1,:l_unassigned_value,
                                               mtl.DESCRIPTION || '' ('' || mtl.CATEGORY_CONCAT_SEGS ||'')'') VIEWBY,
                                               parent_id VIEWBYID,
                   1 SORTORDER, BIL_MEASURE28,'||
                   'BIL_MEASURE2, '||
                   'BIL_MEASURE4,BIL_MEASURE5, BIL_MEASURE7, BIL_MEASURE8, '||
                'BIL_MEASURE10,BIL_MEASURE11,BIL_URL1, DECODE(parent_id,''-1'',NULL,'''||l_cat_url||''') BIL_URL2
from (select pcd.parent_id parent_id,
                   SORTORDER, BIL_MEASURE28,'||
                   'BIL_MEASURE2, '||
                   'BIL_MEASURE4,BIL_MEASURE5, BIL_MEASURE7, BIL_MEASURE8, '||
                'BIL_MEASURE10,BIL_MEASURE11,
                '''||l_drill_link||''' BIL_URL1, BIL_URL2

             from (select VIEWBYID product_category_id,
                   SORTORDER, BIL_MEASURE28,'||
                   'BIL_MEASURE2, '||
                   'BIL_MEASURE4,BIL_MEASURE5, BIL_MEASURE7, BIL_MEASURE8, '||
                'BIL_MEASURE10,BIL_MEASURE11,BIL_URL1, BIL_URL2 FROM BIL_BI_RPT_TMP1) sumry '||l_denorm||' where
             sortorder = 1 '||l_product_where_clause||') opty, mtl_categories_v mtl '||
				      ' WHERE mtl.category_id (+) = opty.parent_id
              UNION ALL
             SELECT /*+ leading (cal) */ pcd.value VIEWBY'||
                        ',pcd.id VIEWBYID'||
                        ', 1 SORTORDER'||
                        ','||l_sql_stmt3||
                        ', '''||l_drill_link||''' BIL_URL1'||
                        ',decode(pcd.id, ''-1'',NULL, '''||l_cat_url||''') BIL_URL2 '||
                        ' FROM '||l_sumry3||' sumry'||
                        ','||l_fii_struct||' cal,ENI_ITEM_PROD_CAT_LOOKUP_V  pcd
                         '||l_where_clause6||
                        ' '||l_product_where_clause1
                        ||' GROUP BY pcd.value, pcd.id '||
                ')
                '|| l_null_rem_clause||
                ' GROUP BY VIEWBY, VIEWBYID, SORTORDER,
                     BIL_URL1, BIL_URL2)
                ORDER BY SORTORDER, VIEWBY ';


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


--PRODCAT NOT ALL
        ELSE -- if prod cat is not All


                           l_cat_assign := bil_bi_util_pkg.getLookupMeaning(p_lookuptype => 'BIL_BI_LOOKUPS'
                                                                           ,p_lookupcode => 'ASSIGN_CATEG');


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg ||l_proc || ' Product cat is not all ',
		                                    MESSAGE => 'Product cat '||l_prodcat_id);

                     END IF;


                   l_custom_sql := 'SELECT DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', :l_cat_assign, pcd.value), pcd.value) VIEWBY
                                    ,pcd.id VIEWBYID'||
                                    ',DECODE(pcd.parent_id, pcd.id, decode(sumry.item_id, ''-1'', 1, 2), 2) SORTORDER '||
                                    ',BIL_MEASURE28,BIL_MEASURE2, BIL_MEASURE4,BIL_MEASURE5,
                                    NULL BIL_MEASURE7 ,NULL BIL_MEASURE8 ,NULL BIL_MEASURE10 ,
                                    NULL BIL_MEASURE11,
         decode(sumry.item_id, ''-1'', decode(pcd.parent_id, pcd.id,NULL,'''||l_drill_link||'''),'''||l_drill_link||''') BIL_URL1,
                                    DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL2
                                    FROM
                                    ( ';

                        l_custom_sql := l_custom_sql ||'
                                    SELECT sumry.product_category_id, to_char(sumry.item_id) item_id '||
                                    ','||l_sql_stmt1||
                                    ',NULL BIL_URL1'||
                                    ',NULL BIL_URL2
                                    FROM '||l_sumry1||' sumry'||
                                   ' '||
                                    l_where_clause4||' '
                                    ||l_group_flag
                                    || l_group_by;

                    l_custom_sql := l_custom_sql||
                                   '  UNION ALL ';


                    --Get Leads values
                    l_custom_sql := l_custom_sql || '
                                    SELECT sumry.product_category_id, sumry.item_id,
                                    '||l_sql_stmt2||
                                          ',NULL BIL_URL1
                                          ,NULL BIL_URL2
                                    FROM '||l_sumry2||' sumry '||
                                            ','||l_fii_struct||' cal'||
                                    l_where_clause5  ;

                                    IF l_resource_id IS NOT NULL THEN
                                       l_custom_sql := l_custom_sql||' AND sumry.resource_id = :l_resource_id ';
                                    ELSE
                                       l_custom_sql := l_custom_sql ||' AND sumry.resource_id = ''-1'' ';
                                    END IF;

                    l_custom_sql := l_custom_sql||' '||
                                  l_group_by;

                     l_custom_sql := l_custom_sql||') sumry '||l_denorm||
                                    'where 1=1 '|| l_product_where_clause;


                    l_custom_sql := l_custom_sql||
                                  '      UNION ALL
                                            SELECT  pcd.value VIEWBY
                                            ,pcd.id VIEWBYID
                                          ,2 SORTORDER,'||l_sql_stmt3||
                                          ', DECODE(pcd.parent_id, pcd.id, NULL, '''||l_drill_link||''') BIL_URL1
                                          , DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') BIL_URL2
                                    FROM ENI_ITEM_PROD_CAT_LOOKUP_V  pcd,'||l_fii_struct||' cal, '||l_sumry3||' sumry '||
                                    l_where_clause6 ||' '
                                  ||l_product_where_clause1||
                                  ' GROUP BY  2
                                            ,pcd.value
                                            ,pcd.id
                                            ,DECODE(pcd.parent_id, pcd.id, NULL, '''||l_drill_link||''')
                                            , DECODE(pcd.parent_id, pcd.id, NULL, '''||l_cat_url||''') ';


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' View by PC, PC not null: ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;

if(l_resource_id is not null) then
         IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
            EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_cat_assign,
                    l_snap_date, l_snap_date,
                    l_snap_date,
                    l_sg_id_num,l_resource_id,l_sg_id_num,
                     l_curr_as_of_date,l_prev_date,
                    l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date,
                    l_sg_id_num,  l_resource_id, l_prodcat_id,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_sg_id_num,l_resource_id,l_sg_id_num,l_curr_as_of_date, l_prev_date,
                    l_bitand_id, l_bitand_id, l_prodcat_id;
            COMMIT;
          ELSE
            EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_cat_assign,
                    l_snap_date, l_prev_snap_date,
                    l_snap_date, l_prev_snap_date,
                    l_sg_id_num,l_resource_id,l_sg_id_num,
                     l_curr_as_of_date,l_prev_date,
                    l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date,
                    l_sg_id_num,  l_resource_id, l_prodcat_id,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_sg_id_num,l_resource_id,l_sg_id_num,l_curr_as_of_date, l_prev_date,
                    l_bitand_id, l_bitand_id, l_prodcat_id;
            COMMIT;
          END IF;
else
    if (l_parent_sg_id_num is not null) then
         IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
            EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_cat_assign,
                    l_snap_date, l_snap_date,
                    l_snap_date,
                    l_sg_id_num,l_parent_sg_id_num,
                    l_curr_as_of_date,l_prev_date,
                    l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date,
                    l_sg_id_num,l_prodcat_id,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_sg_id_num,l_parent_sg_id_num,l_curr_as_of_date, l_prev_date,
                    l_bitand_id, l_bitand_id, l_prodcat_id;
                COMMIT;
          ELSE
            EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_cat_assign,
                    l_snap_date, l_prev_snap_date,
                    l_snap_date, l_prev_snap_date,
                    l_sg_id_num,l_parent_sg_id_num,
                    l_curr_as_of_date,l_prev_date,
                    l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date,
                    l_sg_id_num,l_prodcat_id,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_sg_id_num,l_parent_sg_id_num,l_curr_as_of_date, l_prev_date,
                    l_bitand_id, l_bitand_id, l_prodcat_id;
                COMMIT;
           END IF;
    else
         IF (l_open_mv_new <>  'BIL_BI_PIPE_G_MV') THEN
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_cat_assign,
                    l_snap_date, l_snap_date,
                    l_snap_date,
                    l_sg_id_num,
                    l_curr_as_of_date,l_prev_date,
                    l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date,
                    l_sg_id_num,l_prodcat_id,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_sg_id_num,l_curr_as_of_date, l_prev_date,
                    l_bitand_id, l_bitand_id, l_prodcat_id;
                COMMIT;
          ELSE
                EXECUTE IMMEDIATE l_insert_stmnt||l_custom_sql
                USING l_cat_assign,
                    l_snap_date, l_prev_snap_date,
                    l_snap_date, l_prev_snap_date,
                    l_sg_id_num,
                    l_curr_as_of_date,l_prev_date,
                    l_bitand_id,l_bitand_id,l_curr_as_of_date,l_prev_date,
                    l_sg_id_num,l_prodcat_id,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_curr_as_of_date,
                    l_prev_date,
                    l_sg_id_num,l_curr_as_of_date, l_prev_date,
                    l_bitand_id, l_bitand_id, l_prodcat_id;
                COMMIT;
          END IF;
    end if;
end if;


IF bil_bi_util_pkg.isleafnode(l_prodcat_id) THEN

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Leaf Node');

                     END IF;


           x_custom_sql := l_outer_select||
                     ' FROM

(SELECT VIEWBY, VIEWBYID,  SORTORDER,
                       SUM(BIL_MEASURE28) BIL_MEASURE28, SUM(BIL_MEASURE2) BIL_MEASURE2,
                       SUM(BIL_MEASURE4) BIL_MEASURE4, SUM(BIL_MEASURE5) BIL_MEASURE5,
                       SUM(BIL_MEASURE7) BIL_MEASURE7,SUM(BIL_MEASURE8) BIL_MEASURE8,
                       SUM(BIL_MEASURE10) BIL_MEASURE10,
                       SUM(BIL_MEASURE11) BIL_MEASURE11, BIL_URL1, BIL_URL2 FROM

                     ('||
                       ' SELECT VIEWBY, VIEWBYID, 1 SORTORDER,
                       SUM(BIL_MEASURE28) BIL_MEASURE28, SUM(BIL_MEASURE2) BIL_MEASURE2,
                       SUM(BIL_MEASURE4) BIL_MEASURE4, SUM(BIL_MEASURE5) BIL_MEASURE5,
                       SUM(BIL_MEASURE7) BIL_MEASURE7,SUM(BIL_MEASURE8) BIL_MEASURE8,
                       SUM(BIL_MEASURE10) BIL_MEASURE10,
                       SUM(BIL_MEASURE11) BIL_MEASURE11, BIL_URL1, BIL_URL2 '||
                  ' FROM bil_bi_rpt_tmp1 '||
                  ' WHERE SORTORDER = 1 GROUP BY VIEWBY, VIEWBYID, SORTORDER,
                        BIL_URL1, BIL_URL2

                        '||
                  ' UNION ALL '||
                  ' SELECT VIEWBY, VIEWBYID, 2 SORTORDER, BIL_MEASURE28, BIL_MEASURE2,
                                       BIL_MEASURE4, BIL_MEASURE5,BIL_MEASURE7,
                                       BIL_MEASURE8, BIL_MEASURE10,  '||
                              'BIL_MEASURE11,'''||l_drill_link||''' BIL_URL1, NULL BIL_URL2 '||
                  ' FROM

                  ('||
                      ' SELECT SUM(RN) RN, MAX(VIEWBY) VIEWBY, MAX(VIEWBYID) VIEWBYID, '||
                           ' SUM(BIL_MEASURE28) BIL_MEASURE28, SUM(BIL_MEASURE2) BIL_MEASURE2, '||
                         ' SUM(BIL_MEASURE4) BIL_MEASURE4, SUM(BIL_MEASURE5) BIL_MEASURE5, '||
                         ' SUM(BIL_MEASURE7) BIL_MEASURE7, SUM(BIL_MEASURE8) BIL_MEASURE8, '||
                         ' SUM(BIL_MEASURE10) BIL_MEASURE10, SUM(BIL_MEASURE11) BIL_MEASURE11 '||
                    ' FROM

                    ('||
                      ' SELECT ROWNUM RN, VIEWBY, VIEWBYID, BIL_MEASURE28,'||
                          ' BIL_MEASURE2, BIL_MEASURE4, BIL_MEASURE5,TRUNC(BIL_MEASURE7,3) BIL_MEASURE7, '||
                        ' TRUNC(BIL_MEASURE8,3) BIL_MEASURE8,
                        TRUNC(BIL_MEASURE10,3) BIL_MEASURE10, TRUNC(BIL_MEASURE11,3) BIL_MEASURE11 '||
                      ' FROM

                      bil_bi_rpt_tmp1 '||
                      ' WHERE SORTORDER <> 1

                      '||
                      ' UNION ALL '||
                      ' SELECT -ROWNUM RN, NULL VIEWBY, VIEWBYID, NULL BIL_MEASURE28,'||
                          'NULL BIL_MEASURE2,  NULL BIL_MEASURE4, NULL BIL_MEASURE5,-TRUNC(BIL_MEASURE7,3) BIL_MEASURE7, '||
                        ' -TRUNC(BIL_MEASURE8,3) BIL_MEASURE8,  -TRUNC(BIL_MEASURE10,3) BIL_MEASURE10,
                        -TRUNC(BIL_MEASURE11,3) BIL_MEASURE11 '||
                        '   FROM

                      ( SELECT VIEWBYID, SUM(BIL_MEASURE28) BIL_MEASURE28,
                      SUM(BIL_MEASURE2) BIL_MEASURE2, SUM(BIL_MEASURE4) BIL_MEASURE4,
                      SUM(BIL_MEASURE5) BIL_MEASURE5, SUM(BIL_MEASURE7) BIL_MEASURE7,
                      SUM(BIL_MEASURE8) BIL_MEASURE8, SUM(BIL_MEASURE10) BIL_MEASURE10,
                      SUM(BIL_MEASURE11) BIL_MEASURE11

                       FROM bil_bi_rpt_tmp1 '||
                      ' WHERE SORTORDER = 1 GROUP BY VIEWBYID

                      )'||
                    ') '||
                  ' ) '||
                  ' WHERE NOT( RN = 0 AND  BIL_MEASURE28 = 0 AND BIL_MEASURE2 = 0 '||
                        ' AND BIL_MEASURE4 = 0 AND BIL_MEASURE5 = 0 AND BIL_MEASURE7 = 0'||
                        ' AND BIL_MEASURE8 = 0 AND BIL_MEASURE10 = 0 AND BIL_MEASURE11 = 0 ) '||
                '  )

 GROUP BY VIEWBY, VIEWBYID, SORTORDER, BIL_URL1, BIL_URL2
)'|| l_null_rem_clause||'
                ORDER BY SORTORDER, VIEWBY  ';

          ELSE

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Not a Leaf Node');

                     END IF;

                x_custom_sql:= l_outer_select ||
                    ' FROM( '||
                    'SELECT VIEWBY, SORTORDER, SUM(BIL_MEASURE28) BIL_MEASURE28, '||
                    'SUM(BIL_MEASURE2) BIL_MEASURE2, '||
                    'SUM(BIL_MEASURE4) BIL_MEASURE4, SUM(BIL_MEASURE5) BIL_MEASURE5, '||
                    'SUM(BIL_MEASURE7) BIL_MEASURE7, SUM(BIL_MEASURE8) BIL_MEASURE8, '||
                    'SUM(BIL_MEASURE10) BIL_MEASURE10, SUM(BIL_MEASURE11) BIL_MEASURE11, '||
                    'VIEWBYID, BIL_URL1, BIL_URL2 '||
                    ' FROM BIL_BI_RPT_TMP1 GROUP BY VIEWBY, SORTORDER, VIEWBYID, BIL_URL1, BIL_URL2 '||
                    ') '|| l_null_rem_clause||' ORDER BY SORTORDER, VIEWBY';


            END IF;

 END IF; -- end category selected check

END CASE;

                   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

		              l_sql_error_desc := length(x_custom_sql);

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => ' x_custom_sql length '||l_sql_error_desc);

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



          l_bind_ctr := 1;

          l_custom_rec.attribute_name :=':l_unassigned_value';
          l_custom_rec.attribute_value := l_unassigned_value;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name :=':l_sg_id_num';
          l_custom_rec.attribute_value := l_sg_id_num;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;

    IF(l_resource_id IS NOT NULL) THEN
           l_custom_rec.attribute_name :=':l_resource_id';
          l_custom_rec.attribute_value := l_resource_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;
    END IF;

          l_custom_rec.attribute_name := ':l_curr_as_of_date';
          l_custom_rec.attribute_value := TO_CHAR(l_curr_as_of_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_prev_date';
          l_custom_rec.attribute_value := TO_CHAR(l_prev_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_prev_snap_date';
          l_custom_rec.attribute_value := TO_CHAR(l_prev_snap_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_snap_date';
          l_custom_rec.attribute_value := TO_CHAR(l_snap_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_bitand_id';
          l_custom_rec.attribute_value := l_bitand_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name :=':l_yes';
         l_custom_rec.attribute_value :=l_yes;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;


	  IF l_parent_sg_id_num IS NOT NULL THEN
            l_custom_rec.attribute_name := ':l_parent_sg_id_num';
            l_custom_rec.attribute_value := l_parent_sg_id_num;
            l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
            l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_attr.Extend();
            x_custom_attr(l_bind_ctr) := l_custom_rec;

            l_bind_ctr := l_bind_ctr+1;
          END IF;


ELSE -- params not valid
                BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                           ,x_sqlstr    => x_custom_sql);
END IF;

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'end',
		                                    MESSAGE => 'End of Procedure '|| l_proc);

                     END IF;

  EXCEPTION
        WHEN OTHERS THEN
           IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
             fnd_message.set_token('LDOPBKLOG Error is : ' ,SQLCODE);
             fnd_message.set_token('Reason is : ', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );
            END IF;

             BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                           ,x_sqlstr    => x_custom_sql);
  END BIL_BI_OPEN_LDOPBKLOG;


/*******************************************************************************
 * Name    : Procedure BIL_LDOPP_CAMP
 * Author  : Aananth Solaiyappan
 * Date    : 18th Feb 2004
 * Purpose : Lead and Oppty by Campaign Report.
 *
 *           Copyright (c) 2003 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl     PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 ******************************************************************************/

PROCEDURE BIL_LDOPP_CAMP
  (
    p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
    ,x_custom_sql         OUT NOCOPY VARCHAR2
    ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
  )
  IS

    l_period_type               VARCHAR2(50);
    l_period_type_num           Number;

    l_sg_id                     VARCHAR2(50);
    l_sg_id_num                 NUMBER;

    l_resource_id               VARCHAR2(50);

    l_campaign_id               VARCHAR2(50);
    l_campaign_id_num           Number;

    l_bitand_id                 VARCHAR2(50);

    l_conv_rate_selected        VARCHAR2(50);
    l_conv_rate_selected_num    Number;

    l_curr_page_time_id         NUMBER;
    l_prev_page_time_id         NUMBER;

    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_region_id                 VARCHAR2(50);
    l_comp_type                 VARCHAR2(50);
    l_parameter_valid           BOOLEAN;

    l_calendar_id               VARCHAR2(50);
    l_calendar_id_num           Number;

    l_curr_as_of_date           DATE;
    l_prev_date                 DATE;
    l_page_period_type          VARCHAR2(50);
    l_bis_sysdate               DATE;
    l_fii_struct                VARCHAR2(50);
    l_record_type_id            NUMBER;

    l_sql_error_desc            VARCHAR2(1000);
    l_rpt_str                   VARCHAR2(80);
    l_viewby                    VARCHAR2(80);
    l_bind_ctr                  NUMBER;

    l_inner_where_clause        VARCHAR2(1000);
    l_inner_where_clause1       VARCHAR2(1000);

    l_outer_select              VARCHAR2(8000);
    l_outer_query               VARCHAR2(8000);
    l_outer_query1              VARCHAR2(8000);

    l_inner_select              VARCHAR2(8000);
    l_inner_select1             VARCHAR2(8000);
    l_inner_select2             VARCHAR2(8000);

    l_custom_sql                VARCHAR2(32000);
    l_custom_sql1               VARCHAR2(32000);

    l_insert_stmnt              VARCHAR2(8000);

    l_product_where_clause      VARCHAR2(1000);

    l_sumry                     VARCHAR2(50);
    l_denorm                    VARCHAR2(50);

    l_url_str                   VARCHAR2(1000);
    l_proc                      VARCHAR2(100);
    l_null_camp                 VARCHAR2(100);

    l_salesrep_where            VARCHAR2(100);
    l_prodcat_from              VARCHAR2(1000);
    l_prodcat_where             VARCHAR2(1000);
    l_prodcat_id                VARCHAR2(20);

    l_null_rem_clause           VARCHAR2(4000);
    l_parent_sg_id_num          NUMBER;
    l_currency_suffix           VARCHAR2(5);

    l_category_set              VARCHAR2(15);
    l_yes                       VARCHAR2(1);
    l_func_area_id              NUMBER;

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;


  BEGIN

    g_pkg := 'bil.patch.115.sql.BIL_BI_SALES_MGMT_RPTS_PKG.';
    l_region_id := 'BIL_BI_LEAD_OPP_CAMP';
    l_parameter_valid := FALSE;
    l_proc := 'BIL_LDOPP_CAMP.';
    l_category_set:='CATEGORY_SET';
    l_yes:='Y';
    l_func_area_id:=11;
    g_sch_name := 'BIL';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '|| l_proc);

                     END IF;

    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(
      p_page_parameter_tbl         => p_page_parameter_tbl
      ,p_region_id                 => l_region_id
      ,x_period_type               => l_period_type
      ,x_conv_rate_selected        => l_conv_rate_selected
      ,x_sg_id                     => l_sg_id
      ,x_parent_sg_id              => l_parent_sg_id_num
      ,x_resource_id               => l_resource_id
      ,x_prodcat_id                => l_prodcat_id
      ,x_curr_page_time_id         => l_curr_page_time_id
      ,x_prev_page_time_id         => l_prev_page_time_id
      ,x_comp_type                 => l_comp_type
      ,x_parameter_valid           => l_parameter_valid
      ,x_as_of_date                => l_curr_as_of_date
      ,x_page_period_type          => l_page_period_type
      ,x_prior_as_of_date          => l_prev_date
      ,x_record_type_id            => l_record_type_id
      ,x_viewby                    => l_viewby
    );


    IF l_parameter_valid THEN

        IF (p_page_parameter_tbl.count > 0) THEN
          FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
            IF p_page_parameter_tbl(i).parameter_name = 'CAMPAIGN+CAMPAIGN' THEN
              l_campaign_id :=p_page_parameter_tbl(i).parameter_id;
              l_campaign_id_num := TO_NUMBER(REPLACE(l_campaign_id, ''''));
            END IF;
         END LOOP;
       END IF;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Prod cat is '||nvl(l_prodcat_id, 0)||' Lang '||USERENV('LANG'));

                     END IF;


  --Not sure what PMV returns for 'All', as of now it returns NULL, so convert it to 'All'.
        IF l_prodcat_id IS NULL THEN
           l_prodcat_id := 'All';
        END IF;

       IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
       ELSE
            l_currency_suffix := '';
       END IF;


        BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS
          (
            x_bitand_id    => l_bitand_id
            ,x_calendar_id => l_calendar_id
            ,x_curr_date   => l_bis_sysdate
            ,x_fii_struct  => l_fii_struct
          );

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Date '||l_bis_sysdate);

                     END IF;

   l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
 --  l_bitand_id_num := TO_NUMBER(REPLACE(l_bitand_id, ''''));
   l_calendar_id_num := TO_NUMBER(REPLACE(l_calendar_id, ''''));
   l_conv_rate_selected_num := TO_NUMBER(REPLACE(l_conv_rate_selected, ''''));
   l_period_type_num  := TO_NUMBER(REPLACE(l_period_type , ''''));

   l_rpt_str:='BIL_BI_LEAD_OPP_CAMP';

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN


		         l_sql_error_desc := 'l_viewby              => '|| l_viewby||', '||
                        'l_curr_page_time_id   => '|| l_curr_page_time_id ||', ' ||
                        'l_prev_page_time_id   => '|| l_prev_page_time_id ||', ' ||
                        'l_curr_as_of_date     => '|| l_curr_as_of_date ||', ' ||
                        'l_prev_date           => '|| l_prev_date ||', ' ||
                        'l_conv_rate_selected  => '|| l_conv_rate_selected ||', ' ||
                        'l_bitand_id           => '|| l_bitand_id ||', ' ||
                        'l_period_type         => '|| l_period_type ||', ' ||
                        'l_sg_id               => '|| l_sg_id ||', ' ||
                        'l_resource_id         => '|| l_resource_id ||', ' ||
                        'l_record_type_id         => '|| l_record_type_id||', ' ||
                        'l_calendar_id         => '|| l_calendar_id||', ' ||
                        'l_campaign_id:        => '||l_campaign_id;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Parameters =>'||l_sql_error_desc);

                     END IF;


/*
  l_insert_stmnt is used to insert into temp table1.
  l_innerselect is the core select that hits the MVs.
*/

--BIL_BI_RPT_TMP1
     l_insert_stmnt  :=
      'INSERT INTO BIL_BI_RPT_TMP1
      (
        VIEWBYID,
        BIL_MEASURE28,
        BIL_MEASURE2,
        BIL_MEASURE3,
        BIL_MEASURE5,
        BIL_MEASURE6,
        BIL_MEASURE7,
        BIL_MEASURE8,
        BIL_MEASURE9,
        BIL_MEASURE10,
        BIL_MEASURE11,
        BIL_MEASURE12,
        BIL_MEASURE13,
        BIL_MEASURE14,
        BIL_MEASURE15
      ) ';

     l_inner_select :=
     ' SELECT /*+ NO_MERGE */
        VIEWBYID
        ,SUM(BIL_MEASURE28) BIL_MEASURE28
        ,SUM(BIL_MEASURE2) BIL_MEASURE2
        ,SUM(BIL_MEASURE3) BIL_MEASURE3
        ,SUM(BIL_MEASURE5) BIL_MEASURE5
        ,SUM(BIL_MEASURE6) BIL_MEASURE6
        ,SUM(BIL_MEASURE7) BIL_MEASURE7
        ,SUM(BIL_MEASURE8) BIL_MEASURE8
        ,SUM(BIL_MEASURE9) BIL_MEASURE9
        ,SUM(BIL_MEASURE10) BIL_MEASURE10
        ,SUM(BIL_MEASURE11) BIL_MEASURE11
        ,SUM(BIL_MEASURE12) BIL_MEASURE12
        ,SUM(BIL_MEASURE13) BIL_MEASURE13
        ,SUM(BIL_MEASURE14) BIL_MEASURE14
        ,BIL_MEASURE15
       FROM ';


        execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';

/*
     --   CASE l_viewby
     --       WHEN 'CAMPAIGN+CAMPAIGN' THEN

    --l_url_str:='pFunctionName=BIL_BI_LDOPCAMP_R&pParamIds=Y&VIEW_BY='||l_viewby||'&VIEW_BY_NAME=VIEW_BY_ID';
*/

        BIL_BI_UTIL_PKG.GET_PRODUCT_WHERE_CLAUSE
        (
          p_viewby       => l_viewby,--Timebeing used  as there is no case stmt
          p_prodcat      => l_prodcat_id,
          x_denorm       => l_denorm,
          x_where_clause => l_product_where_clause
        );

        IF l_prodcat_id = 'All' THEN
          l_sumry  := 'BIL_BI_OPLDC_GC_MV';
        ELSE
          l_sumry :=  'BIL_BI_OPLPC_GC_MV';
        END IF;

       /*
        * 1. Need jtf_rs_grp_relations table to get the parent sales group
        * 2. In the case of sales reps, sales group and parent sales group are the same ,
        *    so filtering on sales group directly
        */

        IF l_resource_id IS NULL THEN
          l_salesrep_where := ' AND sumry.salesrep_id IS NULL ';
        ELSE
          l_salesrep_where := ' AND sumry.salesrep_id= :l_resource_id ';
        END IF;


        If l_prodcat_id = 'All' THEN
          l_prodcat_from :='';
          l_prodcat_where :='';
        ELSE

          l_prodcat_from := ' , eni_denorm_hierarchies vbh , mtl_default_category_sets vct ';
          l_prodcat_where := ' inner.product_category_id = vbh.child_id AND vbh.object_type = :l_category_set
				AND vbh.object_id = vct.category_set_id AND vbh.dbi_flag = :l_yes
				AND vct.functional_area_id = :l_func_area_id AND vbh.parent_id = :l_prodcat_id ';

         -- l_prodcat_id_num := TO_NUMBER(REPLACE(l_prodcat_id, ''''));
          NULL;
        END IF;

/*
  BIL_MEASURE15 is used to identify those leaf level rows whose URL has to be suppressed
    (does not apply for campaign unassigned row!).
  The values are
    -1 - suppress URL
    1 - DOnt suppress URL
*/

       l_custom_sql1 :=
        'SELECT sumry.source_code_id VIEWBYID
          ,SUM(CASE WHEN cal.report_date =:l_curr_as_of_date
               THEN new_leads_cnt ELSE NULL END) BIL_MEASURE28
          ,SUM(CASE WHEN cal.report_date =:l_curr_as_of_date
               THEN cnv_leads_cnt ELSE NULL END) BIL_MEASURE2
          ,NULL BIL_MEASURE3
          ,SUM(CASE WHEN cal.report_date =:l_curr_as_of_date
               THEN sumry.new_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE5
          ,SUM(CASE WHEN cal.report_date =:l_prev_date
               THEN sumry.new_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE6
          ,SUM(CASE WHEN cal.report_date =:l_curr_as_of_date
               THEN sumry.cnv_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE7
          ,SUM(CASE WHEN cal.report_date =:l_prev_date
               THEN sumry.cnv_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE8
          ,SUM(CASE WHEN cal.report_date =:l_curr_as_of_date
               THEN sumry.won_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE9
          ,SUM(CASE WHEN cal.report_date =:l_prev_date
               THEN sumry.won_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE10
          ,SUM(CASE WHEN cal.report_date =:l_curr_as_of_date
               THEN sumry.lost_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE11
          ,SUM(CASE WHEN cal.report_date =:l_prev_date
               THEN sumry.lost_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE12
          ,SUM(CASE WHEN cal.report_date =:l_curr_as_of_date
               THEN sumry.no_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE13
          ,SUM(CASE WHEN cal.report_date =:l_prev_date
               THEN sumry.no_opty_amt'||l_currency_suffix||' ELSE NULL END) BIL_MEASURE14
          ,DECODE(sumry.leaf_node_flag,''Y'', -1,1) BIL_MEASURE15';

			 IF l_prodcat_id <> 'All' THEN
			   l_custom_sql1 := l_custom_sql1||',product_category_id ';
			 END IF;

       l_custom_sql1:=l_custom_sql1||'
       FROM
         '||l_sumry||' sumry,'||
         l_fii_struct||' cal
       WHERE
           sumry.effective_time_id = cal.time_id
           AND sumry.effective_period_type_id = cal.period_type_id
           AND BITAND(cal.record_type_id, :l_record_type_id) = :l_record_type_id
           AND cal.report_date IN (:l_curr_as_of_date , :l_prev_date) ';
IF l_campaign_id is NULL THEN
       l_custom_sql1:=l_custom_sql1||'
           AND sumry.parent_source_code_id IS NULL
           and sumry.top_node_flag = ''Y''';
else
       l_custom_sql1:=l_custom_sql1||'
       AND sumry.parent_source_code_id = :l_campaign_id ';
end if;
       l_custom_sql1:=l_custom_sql1||'
           AND sumry.sales_group_id = :l_sg_id_num '||l_salesrep_where||'
       GROUP BY DECODE(sumry.leaf_node_flag,''Y'', -1,1), sumry.source_code_id';
			 IF l_prodcat_id <> 'All' THEN
			   l_custom_sql1 := l_custom_sql1||',product_category_id';
			 END IF;

    l_custom_sql1:=l_custom_sql1||'
    UNION ALL
      SELECT  VIEWBYID
          ,NULL BIL_MEASURE28
          ,NULL BIL_MEASURE2
          ,(CASE WHEN (new - (closed+cnv+dead))=0 THEN NULL ELSE (new - (closed+cnv+dead)) END) BIL_MEASURE3
          ,NULL BIL_MEASURE5
          ,NULL BIL_MEASURE6
          ,NULL BIL_MEASURE7
          ,NULL BIL_MEASURE8
          ,NULL BIL_MEASURE9
          ,NULL BIL_MEASURE10
          ,NULL BIL_MEASURE11
          ,NULL BIL_MEASURE12
          ,NULL BIL_MEASURE13
          ,NULL BIL_MEASURE14
          ,BIL_MEASURE15';

			 IF l_prodcat_id <> 'All' THEN
			   l_custom_sql1 := l_custom_sql1||',product_category_id ';
			 END IF;

       l_custom_sql1:=l_custom_sql1||'

        FROM
        (
          SELECT sumry.source_code_id VIEWBYID
            ,NVL(SUM(new_leads_cnt),0) new
            ,NVL(SUM(cnv_leads_cnt),0) cnv
            ,NVL(SUM(dead_leads_cnt),0) dead
            ,NVL(SUM(closed_leads_cnt),0) closed
            ,DECODE(sumry.leaf_node_flag,''Y'', -1,1) BIL_MEASURE15';

			 IF l_prodcat_id <> 'All' THEN
			   l_custom_sql1 := l_custom_sql1||',product_category_id ';
			 END IF;

       l_custom_sql1:=l_custom_sql1||'
       FROM
         '||l_sumry||' sumry, '||
         l_fii_struct||' cal
       WHERE
           sumry.effective_time_id = cal.time_id
           AND sumry.effective_period_type_id = cal.period_type_id
           AND BITAND(cal.record_type_id, :l_bitand_id) = :l_bitand_id
           AND cal.report_date = :l_curr_as_of_date ';
IF l_campaign_id is NULL THEN
       l_custom_sql1:=l_custom_sql1||'
           AND sumry.parent_source_code_id IS NULL
           and sumry.top_node_flag = ''Y''';
else
       l_custom_sql1:=l_custom_sql1||'
       AND sumry.parent_source_code_id = :l_campaign_id ';
end if;
       l_custom_sql1:=l_custom_sql1||'
           AND sumry.sales_group_id = :l_sg_id_num '||l_salesrep_where||'
        GROUP BY DECODE(sumry.leaf_node_flag,''Y'', -1,1), sumry.source_code_id';


			 IF l_prodcat_id <> 'All' THEN
			   l_custom_sql1 := l_custom_sql1||',product_category_id ) ';
			 ELSE
			   l_custom_sql1 := l_custom_sql1||' ) ';
			 END IF;



 IF l_prodcat_id <> 'All' THEN
     l_custom_sql :=l_inner_select ||' ( select * from ('|| l_custom_sql1 ||' )
     where NOT (BIL_MEASURE28 IS NULL AND BIL_MEASURE2 IS NULL AND BIL_MEASURE3 IS NULL AND BIL_MEASURE5 IS NULL
  AND BIL_MEASURE7 IS NULL AND BIL_MEASURE9 IS NULL AND BIL_MEASURE11 IS NULL AND BIL_MEASURE13 IS NULL )  )inner'||l_prodcat_from||
		   ' WHERE '||l_prodcat_where||
     ' GROUP BY BIL_MEASURE15, VIEWBYID ';
	 ELSE
     l_custom_sql := l_inner_select ||' ('|| l_custom_sql1 ||' )
     where NOT (BIL_MEASURE28 IS NULL AND BIL_MEASURE2 IS NULL AND BIL_MEASURE3 IS NULL AND BIL_MEASURE5 IS NULL
  AND BIL_MEASURE7 IS NULL AND BIL_MEASURE9 IS NULL AND BIL_MEASURE11 IS NULL AND BIL_MEASURE13 IS NULL )  '||
       ' GROUP BY BIL_MEASURE15, VIEWBYID ';
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



/*** Query column mapping ******************************************************
*  Internal Name  Grand Total  Region Item Name
*  BIL_MEASURE1                  Leads (Count)
*  BIL_MEASURE2  BIL_MEASURE18  New
*  BIL_MEASURE3  BIL_MEASURE19  Open
*  BIL_MEASURE4  BIL_MEASURE20  Converted to Opportunities
*  BIL_MEASURE5             New Opportunities (Amount)
*  BIL_MEASURE6  BIL_MEASURE21  New
*  BIL_MEASURE7  BIL_MEASURE22  Change
*  BIL_MEASURE8  BIL_MEASURE23  Converted from Leads
*  BIL_MEASURE9  BIL_MEASURE24  Change
*  BIL_MEASURE10            Converted
*  BIL_MEASURE11            Won, Lost, Open Opportunities (Amount)
*  BIL_MEASURE12  BIL_MEASURE25  Won
*  BIL_MEASURE13  BIL_MEASURE26  Change
*  BIL_MEASURE14  BIL_MEASURE27  Lost
*  BIL_MEASURE15  BIL_MEASURE28  Change
*  BIL_MEASURE16  BIL_MEASURE29  no
*  BIL_MEASURE17  BIL_MEASURE30  Change
*******************************************************************************/


l_url_str:='pFunctionName=BIL_BI_LDOPCAMP_R&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';


l_outer_select :='SELECT * FROM ('||
  'SELECT '||
  'VIEWBY'||
  ',VIEWBYID'||
  ',BIL_MEASURE28 BIL_MEASURE2 '||
  ',BIL_MEASURE28 BIL_MEASURE31 '||
  ',BIL_MEASURE3 BIL_MEASURE3 '||
  ',BIL_MEASURE3 BIL_MEASURE32 '||
  ',BIL_MEASURE2 BIL_MEASURE4 '||
  ',BIL_MEASURE2 BIL_MEASURE33 '||
  ',BIL_MEASURE5 BIL_MEASURE6 '||
  ',(((BIL_MEASURE5 - BIL_MEASURE6) / ABS(DECODE(BIL_MEASURE6, 0, NULL, BIL_MEASURE6))) * 100) BIL_MEASURE7 '||
  ',BIL_MEASURE7 BIL_MEASURE8 '||
  ',(((BIL_MEASURE7 - BIL_MEASURE8) / ABS(DECODE(BIL_MEASURE8, 0, NULL, BIL_MEASURE8))) * 100) BIL_MEASURE9 '||
  ',BIL_MEASURE9 BIL_MEASURE10 '||
  ',BIL_MEASURE9 BIL_MEASURE12 '||
  ',BIL_MEASURE9 BIL_MEASURE34 '||
  ',(((BIL_MEASURE9 - BIL_MEASURE10) / ABS(DECODE(BIL_MEASURE10, 0, NULL, BIL_MEASURE10))) * 100) BIL_MEASURE13 '||
  ',BIL_MEASURE11 BIL_MEASURE14 '||
  ',BIL_MEASURE11 BIL_MEASURE35 '||
  ',(((BIL_MEASURE11 - BIL_MEASURE12) / ABS(DECODE(BIL_MEASURE12, 0, NULL, BIL_MEASURE12))) * 100) BIL_MEASURE15 '||
  ',BIL_MEASURE13 BIL_MEASURE16 '||
  ',(((BIL_MEASURE13 - BIL_MEASURE14) / ABS(DECODE(BIL_MEASURE14, 0, NULL, BIL_MEASURE14))) * 100) BIL_MEASURE17 '||
  ',SUM(BIL_MEASURE28) OVER() BIL_MEASURE18 '||
  ',SUM(BIL_MEASURE3) OVER() BIL_MEASURE19 '||
  ',SUM(BIL_MEASURE2) OVER() BIL_MEASURE20 '||
  ',SUM(BIL_MEASURE5) OVER() BIL_MEASURE21 '||
  ',(((( SUM(BIL_MEASURE5) OVER() ) - ( SUM(BIL_MEASURE6) OVER() )) / '||
  'ABS(DECODE(SUM(BIL_MEASURE6) OVER(), 0, NULL, SUM(BIL_MEASURE6) OVER()))  )) * 100 BIL_MEASURE22 '||
  ',(SUM(BIL_MEASURE7) OVER()) BIL_MEASURE23 '||
  ',(((( SUM(BIL_MEASURE7) OVER() ) - ( SUM(BIL_MEASURE8) OVER() )) / '||
  'ABS(DECODE(SUM(BIL_MEASURE8) OVER(), 0, NULL, SUM(BIL_MEASURE8) OVER()))   )) * 100 BIL_MEASURE24 '||
  ',(SUM(BIL_MEASURE9) OVER()) BIL_MEASURE25 '||
  ',(((( SUM(BIL_MEASURE9) OVER() ) - ( SUM(BIL_MEASURE10) OVER() )) / '||
  'ABS(DECODE(SUM(BIL_MEASURE10) OVER(), 0, NULL, SUM(BIL_MEASURE10) OVER()))  )) * 100 BIL_MEASURE26 '||
  ',(SUM(BIL_MEASURE11) OVER()) BIL_MEASURE27 '||
  ',(((( SUM(BIL_MEASURE11) OVER() ) - ( SUM(BIL_MEASURE12) OVER() )) / '||
  'ABS(DECODE(SUM(BIL_MEASURE12) OVER(), 0, NULL, SUM(BIL_MEASURE12) OVER()))  )) * 100 BIL_MEASURE28 '||
  ',(SUM(BIL_MEASURE13) OVER()) BIL_MEASURE29 '||
  ',(((( SUM(BIL_MEASURE13) OVER() ) - ( SUM(BIL_MEASURE14) OVER() )) / '||
  'ABS(DECODE(SUM(BIL_MEASURE14) OVER(), 0, NULL, SUM(BIL_MEASURE14) OVER())) )) * 100 BIL_MEASURE30 '||
  ', (CASE WHEN VIEWBYID = -1 THEN NULL WHEN BIL_MEASURE15 = -1 THEN NULL '||
           'ELSE '''||l_url_str||''' END) BIL_URL1 ' ;


/*
  There are 2 possibilities for the URL to be NULL(suppressed)
    1.When unassigned campaign = viewby id is null
    2.when leaflevel = BIL_MEASURE15 is 1
*/

    l_inner_select1 :=
      ',VIEWBYID'||
      ',SUM(BIL_MEASURE28) BIL_MEASURE28'||
      ',SUM(BIL_MEASURE2) BIL_MEASURE2'||
      ',SUM(BIL_MEASURE3) BIL_MEASURE3'||
      ',SUM(BIL_MEASURE5) BIL_MEASURE5'||
      ',SUM(BIL_MEASURE6) BIL_MEASURE6'||
      ',SUM(BIL_MEASURE7) BIL_MEASURE7'||
      ',SUM(BIL_MEASURE8) BIL_MEASURE8'||
      ',SUM(BIL_MEASURE9) BIL_MEASURE9'||
      ',SUM(BIL_MEASURE10) BIL_MEASURE10'||
      ',SUM(BIL_MEASURE11) BIL_MEASURE11'||
      ',SUM(BIL_MEASURE12) BIL_MEASURE12'||
      ',SUM(BIL_MEASURE13) BIL_MEASURE13'||
      ',SUM(BIL_MEASURE14) BIL_MEASURE14'||
      ',BIL_MEASURE15'||
      ' FROM ('||l_custom_sql||') mv, ';


/*
  Get the look up value for UNASSIGNED to be shown in the UI.
*/
    SELECT MEANING
    INTO
      l_null_camp
    FROM
      FND_LOOKUP_VALUES
    WHERE
      LOOKUP_TYPE = 'BIL_BI_LOOKUPS'
      AND LOOKUP_CODE = 'UNASSIGN'
      AND LANGUAGE = USERENV('LANG');


l_outer_query1 :=
  ' ( '||
     ' SELECT '||
       ' camp.name VIEWBY, '
       ||' decode(mv.VIEWBYID, -1,2,1) SORTORDER '
       || l_inner_select1 ||
       ' bim_i_obj_name_mv camp '||
     ' where '||
       ' mv.VIEWBYID = camp.source_code_id '||
       ' and camp.language= USERENV(''LANG'')'||
     ' group by '||
        ' mv.VIEWBYID, '||
        ' camp.name, '||
        ' decode(mv.VIEWBYID, -1,2,1),'
        ||'BIL_MEASURE15'
        ||') '||
   ' GROUP BY '||
      'VIEWBY,VIEWBYID,BIL_MEASURE15,SORTORDER ';

     l_inner_select2 :=
       ' SELECT '||
          'VIEWBY'||
          ',VIEWBYID'||
          ',SUM(BIL_MEASURE28) BIL_MEASURE28'||
          ',SUM(BIL_MEASURE2) BIL_MEASURE2'||
          ',SUM(BIL_MEASURE3) BIL_MEASURE3'||
          ',SUM(BIL_MEASURE5) BIL_MEASURE5'||
          ',SUM(BIL_MEASURE6) BIL_MEASURE6'||
          ',SUM(BIL_MEASURE7) BIL_MEASURE7'||
          ',SUM(BIL_MEASURE8) BIL_MEASURE8'||
          ',SUM(BIL_MEASURE9) BIL_MEASURE9'||
          ',SUM(BIL_MEASURE10) BIL_MEASURE10'||
          ',SUM(BIL_MEASURE11) BIL_MEASURE11'||
          ',SUM(BIL_MEASURE12) BIL_MEASURE12'||
          ',SUM(BIL_MEASURE13) BIL_MEASURE13'||
          ',SUM(BIL_MEASURE14) BIL_MEASURE14'||
          ',SORTORDER'||
          ',BIL_MEASURE15'||
        ' FROM '||l_outer_query1;


l_null_rem_clause := ' WHERE NOT (BIL_MEASURE2 IS NULL  AND BIL_MEASURE31 IS NULL AND BIL_MEASURE3 IS NULL '||
' AND BIL_MEASURE32 IS NULL AND BIL_MEASURE4 IS NULL AND BIL_MEASURE33 IS NULL AND BIL_MEASURE6 IS NULL '||
' AND BIL_MEASURE8 IS NULL AND BIL_MEASURE10 IS NULL AND BIL_MEASURE12  IS NULL AND BIL_MEASURE34 IS NULL '||
' AND BIL_MEASURE14 IS NULL AND BIL_MEASURE35 IS NULL AND BIL_MEASURE15 IS NULL AND BIL_MEASURE16 IS NULL)';


    x_custom_sql:=
      l_outer_select ||' FROM ( '||l_inner_select2 ||' ) ORDER BY SORTORDER,VIEWBY) ';


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



         /* Bind parameters */
        l_bind_ctr:=1;
        l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_custom_rec.attribute_value := l_viewby;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


        l_custom_rec.attribute_name := ':l_null_camp';
        l_custom_rec.attribute_value := l_null_camp;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr) := l_custom_rec;
        l_bind_ctr := l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_sg_id_num';
          l_custom_rec.attribute_value := l_sg_id_num;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;

    IF(l_resource_id IS NOT NULL) THEN
           l_custom_rec.attribute_name :=':l_resource_id';
          l_custom_rec.attribute_value := l_resource_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;
    END IF;

          l_custom_rec.attribute_name := ':l_curr_as_of_date';
          l_custom_rec.attribute_value := TO_CHAR(l_curr_as_of_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

          l_bind_ctr:=l_bind_ctr+1;


          l_custom_rec.attribute_name := ':l_prev_date';
          l_custom_rec.attribute_value := TO_CHAR(l_prev_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_bitand_id';
          l_custom_rec.attribute_value := l_bitand_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

            l_custom_rec.attribute_name := ':l_record_type_id';
          l_custom_rec.attribute_value := l_record_type_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name :=':l_yes';
         l_custom_rec.attribute_value :=l_yes;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;

          IF(l_prodcat_id <> 'All') THEN
           l_custom_rec.attribute_name :=':l_prodcat_id';
           l_custom_rec.attribute_value :=l_prodcat_id;
           l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
           l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           x_custom_attr.Extend();
           x_custom_attr(l_bind_ctr):=l_custom_rec;
           l_bind_ctr:=l_bind_ctr+1;
        END IF;

         l_custom_rec.attribute_name :=':l_func_area_id';
          l_custom_rec.attribute_value := l_func_area_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_attr.Extend();
          x_custom_attr(l_bind_ctr) := l_custom_rec;
          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name :=':l_category_set';
           l_custom_rec.attribute_value :=l_category_set;
           l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
           l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           x_custom_attr.Extend();
           x_custom_attr(l_bind_ctr):=l_custom_rec;
           l_bind_ctr:=l_bind_ctr+1;


            l_custom_rec.attribute_name :=':l_campaign_id';
           l_custom_rec.attribute_value :=l_campaign_id;
           l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
           l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
           x_custom_attr.Extend();
           x_custom_attr(l_bind_ctr):=l_custom_rec;
           l_bind_ctr:=l_bind_ctr+1;



 ELSE --no valid parameters
   BIL_BI_UTIL_PKG.get_default_query
    (
      p_regionname => l_region_id
      ,x_sqlstr    => x_custom_sql
    );
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
      BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                           ,x_sqlstr    => x_custom_sql);

      RAISE;

 END  BIL_LDOPP_CAMP;




/*******************************************************************************
 * Name    : Procedure BIL_BI_SLS_PERF - Top Sales Performers Report
 * Author  : Hrishikesh Pandey
 * Date    : Aug 10th, 2005
 *
 *           Copyright (c) 2004 Oracle Corporation
 *
 * Parameters :
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 ******************************************************************************/

PROCEDURE BIL_BI_SLS_PERF(
              p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
              ,x_custom_sql        OUT NOCOPY VARCHAR2
              ,x_custom_attr       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_currency                  VARCHAR2(100);
    l_parameter_valid           BOOLEAN;
    l_salesgroup_id             VARCHAR2(50);
    l_resource_id               VARCHAR2(50);
    l_region_id                 VARCHAR2(3000);
    l_asof_date                 DATE;
    l_prev_date                 DATE;
    l_page_period_type          VARCHAR2(50);
    l_period_type               NUMBER;
    l_per_type                  VARCHAR2(200);
    l_bind_ctr                  NUMBER;
    l_select                    VARCHAR2(4000);
    l_select1                    VARCHAR2(4000);
    l_select3                    VARCHAR2(4000);
    l_select2                    VARCHAR2(4000);
    l_viewby                    VARCHAR2(4000);
    l_comp_type                 VARCHAR2(4000);
    l_err                       VARCHAR2(4000);
    l_err_msg                   VARCHAR2(4000);
    l_where_clause              VARCHAR2(4000);
    l_status_report             VARCHAR2(50) ;
    l_rank_pre                  VARCHAR2(200) ;
    l_status_rank               VARCHAR2(50) ;
    l_proc                      VARCHAR2(100);
    l_curr_suffix               VARCHAR2(10);
    l_booked_suffix             VARCHAR2(10);
    l_sql_error_desc            VARCHAR2(10000);
    l_nulls                     VARCHAR2(200);
    l_rank                      VARCHAR2(200);
    l_rank_where                VARCHAR2(200);
    l_order_rank                VARCHAR2(3000);
    l_orderBy                   VARCHAR2(4000);
    l_order                     VARCHAR2(4000);
    l_comp                      VARCHAR2(200);
    l_sortby                    VARCHAR2(4000);
    l_rep_suffix                VARCHAR2(2000);
    l_rank_select               VARCHAR2(2000);
    l_group_by                  VARCHAR2(2000);
    l_where                     VARCHAR2(2000);
    l_drill_link                VARCHAR2(4000);
    l_drill_link1               VARCHAR2(4000);
    l_drill_link2               VARCHAR2(4000);
    l_drill_link3               VARCHAR2(4000);
    l_umarker                   VARCHAR2(2000);
    l_outer_where_clause        VARCHAR2(4000);
    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

    l_prev_page_time_id              NUMBER;
    l_curr_page_time_id              NUMBER;
    l_fst_crdt_type             VARCHAR2(50);
    l_bitand_id                 VARCHAR2(50);
    l_calendar_id               VARCHAR2(50);
    l_bis_sysdate               DATE;
    l_fii_struct                VARCHAR2(50);
    l_record_type_id            NUMBER;
    l_rep_select1                varchar2(4000);
    l_rep_select2                varchar2(4000);
    l_rep_select3                varchar2(4000);
    l_rep_where1                 varchar2(4000);
    l_rep_where2                 varchar2(4000);

    l_prev_amt           VARCHAR2(1000);
    l_column_type        VARCHAR2(1000);
    l_snapshot_date          	    DATE;
    l_open_mv_new        VARCHAR2(1000);
    l_open_mv_new1        VARCHAR2(1000);
    l_prev_snap_date     DATE;
    l_amt_where                 varchar2(4000);

  BEGIN
  /* Initializing variables*/
    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_bind_ctr := 1;
    l_parameter_valid := TRUE;
    g_pkg := 'bil.patch.115.sql.BIL_BI_SALES_MGMT_RPTS_PKG.';
    l_region_id := 'BIL_BI_SLS_PERF';
    l_proc := 'BIL_BI_SLS_PERF.';
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
        ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
                 l_viewby := p_page_parameter_tbl(i).parameter_value;

        ELSIF p_page_parameter_tbl(i).parameter_name='BIS_CURRENT_ASOF_DATE'    THEN
                 l_asof_date :=  p_page_parameter_tbl(i).PERIOD_DATE;

        ELSIF p_page_parameter_tbl(i).parameter_name='BIS_P_ASOF_DATE'    THEN
                 l_prev_date :=  p_page_parameter_tbl(i).PERIOD_DATE;


        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME_COMPARISON_TYPE' THEN
          l_comp_type := p_page_parameter_tbl(i).parameter_id;
             IF l_comp_type IS NULL THEN
              l_parameter_valid := FALSE;
              l_err_msg := 'Null period type parameter';
              l_err := l_err || ' ,l_comp_type';
             END IF;

        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_WEEK_PFROM' THEN
              l_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_PFROM' THEN
              l_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_PFROM' THEN
              l_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_PFROM'  THEN
              l_prev_page_time_id := p_page_parameter_tbl(i).parameter_value;

        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_WEEK_FROM' THEN
              l_curr_page_time_id := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
              l_curr_page_time_id := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
              l_curr_page_time_id := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM'  THEN
              l_curr_page_time_id := p_page_parameter_tbl(i).parameter_value;

       ELSIF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
           l_page_period_type := p_page_parameter_tbl(i).parameter_value;
          IF l_page_period_type IS NULL THEN
           l_parameter_valid := FALSE;
           l_err_msg := 'Null period type parameter';
           l_err := l_err || ' ,l_page_period_type';
          END IF;
       ELSIF ( p_page_parameter_tbl(i).parameter_name = 'ORDERBY' )
            THEN
              l_order := TRIM(p_page_parameter_tbl(i).parameter_value);
              l_orderBy := TRIM(SUBSTR(l_order,0,INSTR(l_order,' ')));
              l_sortBy := SUBSTR(l_order,INSTR(l_order,' '));
       ELSIF p_page_parameter_tbl(i).parameter_name = 'DIMENSION+DIMENSION11' THEN
            IF p_page_parameter_tbl(i).parameter_id =  '1' THEN
            l_status_report := 'Top';
            ELSIF p_page_parameter_tbl(i).parameter_id =  '2' THEN
            l_status_report := 'Bottom';
            ELSE
            l_status_report := 'Top';
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc ,
		                                    MESSAGE => 'Defaulted thru code to => '||l_status_report);
            END IF;
            END IF;
       ELSIF p_page_parameter_tbl(i).parameter_name = 'DIMENSION+DIMENSION12' THEN
              IF p_page_parameter_tbl(i).parameter_id =  '1' THEN
              l_status_rank := 'Booked';
              ELSIF p_page_parameter_tbl(i).parameter_id =  '2' THEN
              l_status_rank := 'Won';
              ELSIF p_page_parameter_tbl(i).parameter_id =  '3' THEN
              l_status_rank := 'Win/Loss Ratio';
              ELSE
              l_status_rank := 'Won';
 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc ,
		                                    MESSAGE => 'Defaulted thru code to => '||l_status_report);
            END IF;
              END IF;



    END IF;
END LOOP;


/* Check for Currency whether it is Primary or Secondary */
IF INSTR(l_currency,'FII_GLOBAL1') > 0 THEN
         l_curr_suffix := '';
         l_booked_suffix := '';
 ELSE
         l_curr_suffix := '_S';
         l_booked_suffix := '1';
 END IF;


  BIL_BI_UTIL_PKG.GET_FORECAST_PROFILES( x_fstcrdttype => l_fst_crdt_type );

BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id          =>l_bitand_id,
			                             x_calendar_id        =>l_calendar_id,
			                             x_curr_date          =>l_bis_sysdate,
			                             x_fii_struct         =>l_fii_struct);


l_prev_amt :=  BIL_BI_UTIL_PKG.GET_PIPE_COL_NAMES(
                                     p_period_type => l_page_period_type ,
                                     p_compare_to  => l_comp_type,
                                     p_column_type => 'P',
                                     p_curr_suffix    => l_curr_suffix
				    );

    BIL_BI_UTIL_PKG.GET_PIPE_MV(
                                     p_asof_date  => l_asof_date ,
                                     p_period_type  => l_page_period_type ,
                                     p_compare_to  =>  l_comp_type  ,
                                     p_prev_date  => l_prev_date,
                                     p_page_parameter_tbl => p_page_parameter_tbl,
                                     x_pipe_mv    => l_open_mv_new ,
                                     x_snapshot_date => l_snapshot_date  ,
                                     x_prev_snap_date  => l_prev_snap_date
				    );

IF(l_status_report = 'Top') THEN
    l_nulls := ' DESC  NULLS LAST ' ;
    l_rank := '';
l_rank_pre := 'TOP_';
    l_rank_where := ' WHERE ranking < 26 ';
    l_order_rank := ' ORDER BY  BIL_MEASURE1,  BIL_MEASURE3 ';
ELSE
    l_nulls := ' ASC NULLS LAST ' ;
    l_rank := ' DESC ';
l_rank_pre := 'BOTTOM_';
    l_rank_where := ' WHERE ranking > last_rank - 25 ';
    l_order_rank := ' ORDER BY  BIL_MEASURE1   DESC,BIL_MEASURE3  ';
END IF;
/* Check for column based on that sorting is to be done */
IF(l_orderby is not null ) THEN
    l_order_rank := ' ORDER BY  '||l_orderby||' '|| l_sortby||' , BIL_MEASURE3 ';
END IF;

/* Check for Period Type selected */
IF  l_page_period_type = 'FII_TIME_WEEK' THEN
       l_per_type :=  'WEEK';
       l_record_type_id :=  32;
       l_period_type := 16;
ELSIF  l_page_period_type ='FII_TIME_ENT_PERIOD' THEN
      l_per_type :=  'PERIOD';
      l_record_type_id :=  64;
       l_period_type := 32;
ELSIF  l_page_period_type = 'FII_TIME_ENT_QTR' THEN
      l_per_type :=  'QTR';
      l_record_type_id :=  128;
       l_period_type := 64;
ELSIF  l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
      l_per_type :=  'YEAR';
      l_record_type_id :=  256;
       l_period_type := 128;
END IF ;
/*
CASE l_period_type
        WHEN 'FII_TIME_WEEK' THEN l_per_type :=  'WEEK';
        WHEN 'FII_TIME_ENT_PERIOD' THEN l_per_type :=  'PERIOD';
        WHEN 'FII_TIME_ENT_QTR' THEN l_per_type :=  'QTR';
        WHEN 'FII_TIME_ENT_YEAR' THEN l_per_type :=  'YEAR';
END CASE;
*/


IF UPPER(l_status_rank) = 'BOOKED' THEN
              l_rep_suffix :=  'BOOKED_';
              l_umarker :=  'BOOKED_RANK';
              l_amt_where := '  booked_amt_'||l_per_type||''||l_curr_suffix||' ';
ELSIF UPPER(l_status_rank) = 'WON' THEN
              l_rep_suffix :=  'WON_';
              l_umarker :=  'WON_RANK';
              l_amt_where := '  won_amt_'||l_per_type||''||l_curr_suffix||' ';
ELSIF UPPER(l_status_rank) = 'WIN/LOSS RATIO' THEN
              l_rep_suffix :=  'WINLOSS_';
              l_umarker :=  'WON_RANK';
              l_amt_where := ' winloss_ratio_'||l_per_type||''||l_curr_suffix||'  ';
END IF;
/*
 CASE UPPER(l_status_rank)
        WHEN 'NET BOOKED' THEN
              l_rep_suffix :=  'BOOKED_';
              l_umarker :=  'BOOKED_RANK';
        WHEN 'WON' THEN
              l_rep_suffix :=  'WON_';
              l_umarker :=  'WON_RANK';
        WHEN 'WIN/LOSS RATIO' THEN
              l_rep_suffix :=  'WINLOSS_';
              l_umarker :=  'WON_RANK';
  END CASE;
*/



IF UPPER(l_status_report) = 'TOP'
       THEN  l_rank_select := ' '||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK '   ;
ELSIF UPPER(l_status_report) = 'BOTTOM'
       THEN l_rank_select := ' ('||l_rep_suffix||''||l_per_type||'_LAST_RANK + 1 ) -
                                '||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK ';
END IF;
/*
CASE  UPPER(l_status_report)
   WHEN 'TOP' THEN  l_rank_select := ' '||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK '   ;
   WHEN 'BOTTOM'
       THEN l_rank_select := ' ('||l_rep_suffix||''||l_per_type||'_LAST_RANK + 1 ) -
                                '||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK ';
END CASE;
*/
IF UPPER(l_status_report) = 'TOP'  THEN
            l_group_by := ''||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK ';
            l_where := ''||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK ';
ELSIF UPPER(l_status_report) = 'BOTTOM'  THEN
            l_where := ''||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK ';
            l_group_by := ''||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK,
                                '||l_rep_suffix||''||l_per_type||'_LAST_RANK  ';
END IF;



/*
CASE  UPPER(l_status_report)
   WHEN 'TOP' THEN  l_group_by := ''||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK ';
                l_where := ''||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK ';
   WHEN 'BOTTOM'
       THEN l_where := ''||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK ';
            l_group_by := ''||l_rank_pre||''||l_rep_suffix||''||l_per_type||'_RANK,
                                '||l_rep_suffix||''||l_per_type||'_LAST_RANK  ';
END CASE;
*/
IF UPPER(l_status_rank) = 'BOOKED' THEN
    l_umarker :=  'BOOKED_RANK';
ELSE
    l_umarker :=  'WON_RANK';
END IF ;
IF l_resource_id IS  NULL THEN
    l_where_clause := ' WHERE
	         parent_sales_group_id = :l_salesgroup_id
	         AND '||l_where||'  < 26
                 and '|| l_amt_where || ' is NOT NULL
	         AND  UMARKER = '''|| L_UMARKER   ||'''
	      GROUP BY
		  salesrep_id,
		  sales_group_id,
		  '||l_group_by||'  ';
l_outer_where_clause := 'where bil_measure1 > 0';
ELSE
    l_where_clause := ' WHERE
	         parent_sales_group_id = :l_salesgroup_id
                 and parent_sales_group_id = sales_group_id
                 and salesrep_id = :l_resource_id
	         AND  UMARKER = '''|| L_UMARKER   ||'''
	      GROUP BY
		  salesrep_id,
		  sales_group_id ';
    l_rank_select := 'NULL';
    l_order_rank  := NULL;
    l_outer_where_clause := NULL;
END IF;
IF l_comp_type = 'YEARLY'
      THEN l_comp :=  'PREV_YR_';
ELSIF l_comp_type = 'SEQUENTIAL'
      THEN l_comp :=  'PREV_PER_';
END IF;


/*
CASE l_comp_type
        WHEN 'YEARLY' THEN l_comp :=  'PREV_YR_';
        WHEN 'SEQUENTIAL' THEN l_comp :=  'PREV_PER_';
END CASE;
*/


/* Drill Links to Opportunity Line Detail report */
 l_drill_link3 :=  '&ORGANIZATION';
 l_drill_link2 := 'JTF_ORG_SALES_GROUP=';
 l_drill_link1 := '&BIL_DIMENSION2=';
 l_drill_link  := 'pFunctionName=BIL_BI_OPPTY_LINE_DETAIL_R&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID
                     &BIL_DIMENSION3=Y&BIL_DIMENSION10=';
 l_sql_error_desc :=
      'l_status_rank                => '|| l_status_rank ||',      ' ||
      'l_viewby                 => '|| l_viewby ||',      ' ||
      'l_status_report                 => '|| l_status_report ||',      ' ||
      'l_page_period_type            => '|| l_page_period_type ||',    ' ||
      'l_currency               => '|| l_currency ||',       ' ||
      'l_salesgroup_id          => '|| l_salesgroup_id ||',  ' ||
      'l_resource_id            => '|| l_resource_id ||',    ' ||
      'l_order                  => '|| l_order ||',  ' ||
      'l_orderBy                => '|| l_orderBy ||',        ' ||
      'l_sortBy            => '|| l_sortBy ||',    ' ||
      'l_comp_type              => '|| l_comp_type ;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc ,
		                                    MESSAGE => 'Parameters => '||l_sql_error_desc);
     END IF;
/*** Query column mapping ******************************************************
*  Internal Name     Region Item Name
* BIL_MEASURE1       Rank
* BIL_MEASURE2       Job Title
* BIL_MEASURE3       Name
* BIL_MEASURE4       Sales Group
* BIL_MEASURE6       Forecast
* BIL_MEASURE7       Prior Forecast
* BIL_MEASURE8       Change
* BIL_MEASURE9       Pipeline
* BIL_MEASURE10      Prior Pipeline
* BIL_MEASURE11      Change
* BIL_MEASURE12      Won
* BIL_MEASURE13      Prior Won
* BIL_MEASURE14      Change
* BIL_MEASURE15      Win/Loss Ratio
* BIL_MEASURE16      Prior Win/Loss Ratio
* BIL_MEASURE17      Change
* BIL_MEASURE18      Booked
* BIL_MEASURE19      Prior Booked
* BIL_MEASURE20      Change
* BIL_MEASURE21      GRAND TOTAL(NetBooked)
* BIL_MEASURE22      GRAND TOTAL(Forecast)
* BIL_MEASURE23      GRAND TOTAL(Pipeline)
* BIL_MEASURE24      GRAND TOTAL(Won)
* BIL_URL1           Link to Oppty Line Detail Report for Pipeline measure
* BIL_URL2           Link to Oppty Line Detail Report for Won measure
*******************************************************************************/
/************************************
Front END Query
*************************************/
l_select1 := 	'SELECT
	    BIL_MEASURE1,
	    (SELECT source_job_title FROM Jtf_rs_resource_extns WHERE resource_id = BIL_MEASURE3) BIL_MEASURE2,
	    (SELECT rstl.resource_name FROM jtf_rs_resource_extns_tl rstl
	         WHERE rstl.resource_id=BIL_MEASURE3 AND USERENV(''LANG'')=rstl.LANGUAGE) BIL_MEASURE3,
	    (SELECT group_name FROM jtf_rs_groups_tl grtl
	         WHERE BIL_MEASURE4=grtl.group_id AND USERENV(''LANG'')=grtl.LANGUAGE) BIL_MEASURE4,
	    BIL_MEASURE6,
	    BIL_MEASURE7,
	    BIL_MEASURE8,
	    BIL_MEASURE9,
	    BIL_MEASURE10,
	    BIL_MEASURE11,
	    BIL_MEASURE12,
	    BIL_MEASURE13,
	    BIL_MEASURE14,
	    BIL_MEASURE15,
	    BIL_MEASURE16,
	    BIL_MEASURE17,
	    BIL_MEASURE18,
	    BIL_MEASURE19,
	    BIL_MEASURE20,
	    BIL_MEASURE21,
	    BIL_MEASURE22,
	    BIL_MEASURE23,
	    BIL_MEASURE24,
            BIL_URL1||'||'''BIL_DIMENSION1=WON'''||' BIL_URL1,
            BIL_URL1||'||'''BIL_DIMENSION1=PIPELINE'''||' BIL_URL2
	FROM
	   (
            ';


l_select3 := 	'
select * from(
select
              (ROWNUM - 1) RN,
	    BIL_MEASURE1,
	    BIL_MEASURE2,
	    BIL_MEASURE3,
      BIL_MEASURE4,
	    BIL_MEASURE6,
	    BIL_MEASURE7,
	    BIL_MEASURE8,
	    BIL_MEASURE9,
	    BIL_MEASURE10,
	    BIL_MEASURE11,
	    BIL_MEASURE12,
	    BIL_MEASURE13,
	    BIL_MEASURE14,
	    BIL_MEASURE15,
	    BIL_MEASURE16,
	    BIL_MEASURE17,
	    BIL_MEASURE18,
	    BIL_MEASURE19,
	    BIL_MEASURE20,
	    BIL_MEASURE21,
	    BIL_MEASURE22,
	    BIL_MEASURE23,
	    BIL_MEASURE24,
	    BIL_URL1
 from
	   (
            ';


 l_select2 :=   ' SELECT
		'||l_rank_select||'   BIL_MEASURE1 ,
	        NULL BIL_MEASURE2,
	          salesrep_id BIL_MEASURE3 ,
		  sales_group_id  BIL_MEASURE4 ,
		  SUM(frcst_amt_'||l_per_type||''||l_curr_suffix||')  bil_measure6,
	          SUM('||l_comp||''||l_per_type||'_frcst_amt'||l_curr_suffix||')   bil_measure7,
	          (((SUM(frcst_amt_'||l_per_type||''||l_curr_suffix||') -
                             SUM('||l_comp||''||l_per_type||'_frcst_amt'||l_curr_suffix||'))/
	              DECODE(SUM('||l_comp||''||l_per_type||'_frcst_amt'||l_curr_suffix||'),0,NULL,
                             SUM('||l_comp||''||l_per_type||'_frcst_amt'||l_curr_suffix||'))) * 100) bil_measure8,
	          SUM( pipeline_amt_'||l_per_type||''||l_curr_suffix||')   bil_measure9,
	          SUM('||l_comp||''||l_per_type||'_pip_amt'||l_curr_suffix||')   bil_measure10,
	          (((SUM( pipeline_amt_'||l_per_type||''||l_curr_suffix||') -
               SUM('||l_comp||''||l_per_type||'_pip_amt'||l_curr_suffix||'))/
        DECODE(SUM('||l_comp||''||l_per_type||'_pip_amt'||l_curr_suffix||'),0,NULL,
               SUM('||l_comp||''||l_per_type||'_pip_amt'||l_curr_suffix||'))) * 100) bil_measure11,
	          SUM(won_amt_'||l_per_type||''||l_curr_suffix||')  bil_measure12,
	          SUM('||l_comp||''||l_per_type||'_won_amt'||l_curr_suffix||')   bil_measure13,
          (((SUM(won_amt_'||l_per_type||''||l_curr_suffix||') -
               SUM('||l_comp||''||l_per_type||'_won_amt'||l_curr_suffix||'))/
        DECODE(SUM('||l_comp||''||l_per_type||'_won_amt'||l_curr_suffix||'),0,NULL,
               SUM('||l_comp||''||l_per_type||'_won_amt'||l_curr_suffix||'))) * 100) bil_measure14,
	          SUM(winloss_ratio_'||l_per_type||''||l_curr_suffix||')  bil_measure15,
	          SUM('||l_comp||''||l_per_type||'_wlratio'||l_curr_suffix||')  bil_measure16,
	         (SUM(winloss_ratio_'||l_per_type||''||l_curr_suffix||') -
                    SUM('||l_comp||''||l_per_type||'_wlratio'||l_curr_suffix||'))  bil_measure17,
	          SUM(booked_amt_'||l_per_type||''||l_curr_suffix||')   bil_measure18,
	          SUM('||l_comp||''||l_per_type||'_booked_amt'||l_curr_suffix||')  bil_measure19 ,
	          (((SUM(booked_amt_'||l_per_type||''||l_curr_suffix||') -
                    SUM('||l_comp||''||l_per_type||'_booked_amt'||l_curr_suffix||'))/
            DECODE(SUM('||l_comp||''||l_per_type||'_booked_amt'||l_curr_suffix||'),0,
        NULL,SUM('||l_comp||''||l_per_type||'_booked_amt'||l_curr_suffix||'))) * 100) bil_measure20,
	          SUM(SUM(frcst_amt_'||l_per_type||''||l_curr_suffix||')) OVER() BIL_MEASURE22 ,
	          SUM(SUM(pipeline_amt_'||l_per_type||''||l_curr_suffix||')) OVER() BIL_MEASURE23,
	          SUM(SUM(won_amt_'||l_per_type||''||l_curr_suffix||')) OVER() BIL_MEASURE24,
	          SUM(SUM(booked_amt_'||l_per_type||''||l_curr_suffix||')) OVER() BIL_MEASURE21,
 '''||l_drill_link||'''||MV.salesrep_id||'''||l_drill_link3||'''||''+''||'''||l_drill_link2||'''||MV.salesrep_id||
''.''||MV.sales_group_id||'''||l_drill_link1||'''||MV.sales_group_id||''&''||''''  BIL_URL1
            FROM
                BIL_BI_SLS_PERF_MV   MV
              '|| l_where_clause ||'

)
order by BIL_MEASURE1
  )
where
RN >= &START_INDEX
AND RN <= &END_INDEX
	)
'|| l_outer_where_clause ||'
         '|| l_order_rank ||'
';









l_rep_select2 := '
(
SELECT
salesrep_id BIL_MEASURE3,
sales_group_id BIL_MEASURE4,
SUM(frcst) BIL_MEASURE6,
sum(priorFrcst) BIL_MEASURE7,
sum(pipeline) BIL_MEASURE9,
sum(priorPipeline) BIL_MEASURE10,
sum(won) BIL_MEASURE12,
sum(priorWon) BIL_MEASURE13,

 sum(won) / DECODE(sum(lost), 0, NULL, sum(lost)) BIL_MEASURE15,
 sum(priorWon) / DECODE(sum(priorLost), 0, NULL, sum(priorLost)) BIL_MEASURE16,
sum(booked) BIL_MEASURE18,
SUM(priorBooked) BIL_MEASURE19,
'''||l_drill_link||'''||salesrep_id||'''||l_drill_link3||'''||''+''||'''||l_drill_link2||'''||salesrep_id||
''.''||sales_group_id||'''||l_drill_link1||'''||sales_group_id||''&''||'''' BIL_URL1
 from (
  SELECT /*+ LEADING(cal) */
sumry.salesrep_id,
 sumry.sales_group_id,
 NULL AS frcst,
 NULL AS priorFrcst,
 NULL pipeline,
 NULL priorPipeline,
 (case
 when cal.report_date = :l_asof_date then
sumry.won_opty_amt'||l_curr_suffix||'
 else
NULL
 end) AS won,
 (case
 when cal.report_date = :l_prev_date then
sumry.won_opty_amt'||l_curr_suffix||'
 else
NULL
 end) AS priorWon,
 (case
 when cal.report_date = :l_asof_date then
sumry.lost_opty_amt'||l_curr_suffix||'
 else
NULL
 end) AS lost,
 (case
 when cal.report_date = :l_prev_date then
sumry.lost_opty_amt'||l_curr_suffix||'
 else
NULL
 end) AS priorLost,
 NULL booked,
 NULL priorBooked
 FROM FII_TIME_STRUCTURES cal, BIL_BI_OPTY_G_MV sumry
WHERE sumry.effective_time_id = cal.time_id
AND sumry.effective_period_type_id = cal.PERIOD_TYPE_ID
AND bitand(cal.record_type_id, :l_record_type_id) = :l_record_type_id
AND cal.report_date in (:l_asof_date, :l_prev_date)
AND sumry.parent_sales_group_id = :l_salesgroup_id
AND cal.xtd_flag = ''Y''
AND sumry.salesrep_id = :l_resource_id
AND sumry.sales_group_id = :l_salesgroup_id
AND sumry.won_opty_amt is not NULL
 UNION ALL
  SELECT /*+ leading (cal) */
sumry.salesrep_id,
sumry.sales_group_id,
NULL AS frcst,
NULL AS priorFrcst,
(case
when  sumry.snap_date = :l_snapshot_date  then
 decode(:l_period_type,
128,
PIPELINE_AMT_YEAR'||l_curr_suffix||',
64,
PIPELINE_AMT_QUARTER'||l_curr_suffix||',
32,
PIPELINE_AMT_PERIOD'||l_curr_suffix||',
16,
PIPELINE_AMT_WEEK'||l_curr_suffix||')
end) AS pipeline,
(CASE
WHEN sumry.snap_date = :l_snapshot_date THEN
 '|| l_prev_amt ||'
ELSE
 NULL
END) AS priorPipeline,
NULL AS won,
NULL AS priorWon,
NULL AS lost,
NULL AS prorLost,
NULL booked,
NULL priorBooked
FROM
'|| l_open_mv_new ||'  sumry
WHERE sumry.snap_date in (:l_snapshot_date)
AND sumry.grp_total_flag = 1
AND sumry.parent_sales_group_id = :l_salesgroup_id
AND sumry.salesrep_id = :l_resource_id
AND sumry.sales_group_id = :l_salesgroup_id
 UNION ALL
';

l_rep_select3 := '
 SELECT /*+ LEADING(cal) */
sumry.salesrep_id,
sumry.sales_group_id,
(case
when sumry.effective_time_id = :l_curr_page_time_id AND
 cal.report_date = :l_asof_date then
 sumry.forecast_amt'||l_curr_suffix||'
else
 NULL
end) AS frcst,
(case
when sumry.effective_time_id = :l_prev_page_time_id AND
 cal.report_date = :l_prev_date then
 sumry.forecast_amt'||l_curr_suffix||'
else
 NULL
end) AS priorFrcst,
NULL AS pipeline,
NULL AS priorPipeline,
NULL AS won,
NULL AS priorWon,
NULL AS lost,
NULL AS prorLost,
NULL booked,
NULL priorBooked
 FROM FII_TIME_STRUCTURES cal, BIL_BI_FST_G_MV sumry
WHERE sumry.TXN_TIME_ID = cal.TIME_ID
AND sumry.TXN_PERIOD_TYPE_ID = cal.PERIOD_TYPE_ID
AND bitand(cal.record_type_id, :l_bitand_id) = :l_bitand_id
AND sumry.EFFECTIVE_PERIOD_TYPE_ID = :l_period_type
AND NVL(sumry.credit_type_id, :l_fst_crdt_type) = :l_fst_crdt_type
AND cal.report_date in (:l_asof_date, :l_prev_date)
AND sumry.effective_time_id in
(:l_curr_page_time_id, :l_prev_page_time_id)
AND sumry.parent_sales_group_id = :l_salesgroup_id
AND cal.xtd_flag = ''Y''
AND sumry.forecast_amt is not NULL
AND sumry.salesrep_id = :l_resource_id
AND sumry.sales_group_id = :l_salesgroup_id
UNION ALL
SELECT /*+ leading (cal) */
resource_id salesrep_id,
sales_grp_id sales_group_id,
NULL AS frcst,
NULL AS priorFrcst,
NULL AS pipeline,
NULL AS priorPipeline,
NULL AS won,
NULL AS priorWon,
NULL AS lost,
NULL AS priorLost,
(CASE
WHEN cal.report_date = :l_asof_date THEN
 (sumry.net_booked_amt_g'||l_booked_suffix||')
ELSE
 NULL
END) As booked,
(CASE
WHEN cal.report_date = :l_prev_date THEN
 (sumry.net_booked_amt_g'||l_booked_suffix||')
ELSE
 NULL
END) AS priorBooked
 FROM FII_TIME_STRUCTURES cal, isc_dbi_scr_001_mv sumry
WHERE sumry.time_id = cal.time_id
AND sumry.period_type_id = cal.period_type_id
AND cal.xtd_flag = ''Y''
AND cal.report_date in (:l_asof_date, :l_prev_date)
AND bitand(cal.record_type_id, :l_record_type_id) = :l_record_type_id
AND sumry.GRP_MARKER = ''SALES REP''
AND sumry.resource_id = :l_resource_id
AND sumry.customer_flag = 0
AND sumry.item_cat_flag = 0
AND sumry.net_booked_amt_g is not NULL
AND sumry.sales_grp_id = :l_salesgroup_id
AND sumry.parent_grp_id = :l_salesgroup_id)
 GROUP BY  salesrep_id, sales_group_id
)
';


l_rep_select1 := '
SELECT
	NULL BIL_MEASURE1,
	 (SELECT source_job_title FROM Jtf_rs_resource_extns WHERE resource_id = BIL_MEASURE3) BIL_MEASURE2,
	 (SELECT rstl.resource_name FROM jtf_rs_resource_extns_tl rstl
	WHERE rstl.resource_id=BIL_MEASURE3 AND USERENV(''LANG'')=rstl.LANGUAGE) BIL_MEASURE3,
	 (SELECT group_name FROM jtf_rs_groups_tl grtl
	WHERE BIL_MEASURE4=grtl.group_id AND USERENV(''LANG'')=grtl.LANGUAGE) BIL_MEASURE4,
	 BIL_MEASURE6,
	 BIL_MEASURE7,
(((BIL_MEASURE6 - BIL_MEASURE7) / (DECODE(BIL_MEASURE7, 0, NULL, BIL_MEASURE7))) * 100) BIL_MEASURE8,

	 BIL_MEASURE9,
	 BIL_MEASURE10,
(((BIL_MEASURE9 - BIL_MEASURE10) / (DECODE(BIL_MEASURE10, 0, NULL, BIL_MEASURE10))) * 100) BIL_MEASURE11,

	 BIL_MEASURE12,
	 BIL_MEASURE13,
(((BIL_MEASURE12 - BIL_MEASURE13) / (DECODE(BIL_MEASURE13, 0, NULL, BIL_MEASURE13))) * 100) BIL_MEASURE14,

	 BIL_MEASURE15,
	 BIL_MEASURE16,
 (BIL_MEASURE15 - BIL_MEASURE16) BIL_MEASURE17,

	 BIL_MEASURE18,
	 BIL_MEASURE19,
(((BIL_MEASURE18 - BIL_MEASURE19) / (DECODE(BIL_MEASURE19, 0, NULL, BIL_MEASURE19))) * 100) BIL_MEASURE20,

SUM(BIL_MEASURE18) OVER() BIL_MEASURE21 ,
SUM(BIL_MEASURE6) OVER() BIL_MEASURE22 ,
SUM(BIL_MEASURE9) OVER() BIL_MEASURE23 ,
SUM(BIL_MEASURE12) OVER() BIL_MEASURE24 ,
 BIL_URL1||'||'''BIL_DIMENSION1=WON'''||' BIL_URL1,
 BIL_URL1||'||'''BIL_DIMENSION1=PIPELINE'''||' BIL_URL2
FROM
';


IF l_resource_id IS  NULL THEN
  x_custom_sql := l_select1 ||
                  l_select3 ||
                  l_select2   ;
ELSE
  x_custom_sql := l_rep_select1 ||
                  l_rep_select2 ||
                  l_rep_select3 ;
END IF;




 --Log the query being returned
                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || 'Query LENGTH=>',
		                                    MESSAGE => ' x_custom_sql LENGTH '||LENGTH(x_custom_sql));
                     END IF;
                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= LENGTH(x_custom_sql);
                       WHILE l_ind <= l_len LOOP
                        l_str:= SUBSTR(x_custom_sql, l_ind, 4000);
                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);
                        l_ind := l_ind + 4000;
                       END LOOP;
                     END IF;
  /* Bind Parameters */

        l_custom_rec.attribute_name := ':l_asof_date';
        l_custom_rec.attribute_value := TO_CHAR(l_asof_date,'DD/MM/YYYY');
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

        l_custom_rec.attribute_name := ':l_snapshot_date';
        l_custom_rec.attribute_value := TO_CHAR(l_snapshot_date,'DD/MM/YYYY');
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

    l_custom_rec.attribute_name := ':l_record_type_id';
    l_custom_rec.attribute_value := l_record_type_id ;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
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

    l_custom_rec.attribute_name := ':l_prev_page_time_id';
    l_custom_rec.attribute_value := l_prev_page_time_id;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    x_custom_attr.Extend();
    x_custom_attr(l_bind_ctr) := l_custom_rec;
    l_bind_ctr := l_bind_ctr+1;

      l_custom_rec.attribute_name :=':l_bitand_id';
      l_custom_rec.attribute_value := l_bitand_id;
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;
      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name :=':l_fst_crdt_type';
      l_custom_rec.attribute_value := l_fst_crdt_type;
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;
      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name :=':l_salesgroup_id';
      l_custom_rec.attribute_value := l_salesgroup_id;
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
                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'END',
		                                    MESSAGE => 'END of Procedure '||l_proc);
                     END IF;
END BIL_BI_SLS_PERF ;




END BIL_BI_SALES_MGMT_RPTS_PKG;

/
