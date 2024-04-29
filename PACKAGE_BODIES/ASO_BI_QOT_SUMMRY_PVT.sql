--------------------------------------------------------
--  DDL for Package Body ASO_BI_QOT_SUMMRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_QOT_SUMMRY_PVT" AS
/* $Header: asovbiqsmryb.pls 120.0.12010000.2 2008/11/14 05:29:38 annsrini ship $*/

-- This will return the SQL Query for Approval Rules SUMmary
-- ASO_VALUE1   :  Rule description
-- ASO_VALUE2   :  Percentage of submissions
-- ASO_CHANGE1  :  Change

PROCEDURE BY_APPR_RULES(p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                        x_custom_sql     OUT NOCOPY VARCHAR2,
                        x_custom_output  OUT NOCOPY bis_query_attributes_TBL)
AS
  l_sql_text1           VARCHAR2(32000);
  l_sql_text2           VARCHAR2(32000);
  l_sql_text3           VARCHAR2(32000);
  l_sql_text4           VARCHAR2(32000);
  l_insert_stmt         VARCHAR2(3200);
  l_parameter_name      VARCHAR2(3200);
  l_period_type         VARCHAR2(3200);
  l_comparision_type    VARCHAR2(3200);
  l_orderby             VARCHAR2(200);
  l_sortBy              VARCHAR2(200);
  l_module_name         VARCHAR2(100);
  l_viewby              VARCHAR2(100);
  l_product_id          VARCHAR2(200);
  l_prodcat_id          VARCHAR2(200);
  l_curr_asof_date      DATE;
  l_prev_asof_date      DATE;
  l_fdcp_date           DATE;
  l_fdpp_date           DATE;
  l_sysdate             DATE;
  l_curr_value          NUMBER;
  l_prev_value          NUMBER;
  l_record_type_id      NUMBER;
  l_sg_id_num           NUMBER;
  l_sr_id_num           NUMBER;
  l_conv_rate           NUMBER;
  rec_index             NUMBER := 0;
  l_fdcp_date_j         NUMBER;
  l_fdpp_date_j         NUMBER;
  l_custom_rec          BIS_QUERY_ATTRIBUTES;

BEGIN

         x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
         l_custom_rec    := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
         l_module_name   := 'ASO_BI_QOT_SUMMRY_PVT.BY_APPR_RULES';

         -- Set up the parameters
         ASO_BI_QOT_UTIL_PVT.GET_PAGE_PARAMS(p_pmv_parameters => p_pmv_parameters,
                                             x_conv_rate => l_conv_rate,
                                             x_record_type_id => l_record_type_id,
                                             x_sysdate => l_sysdate,
                                             x_sg_id => l_sg_id_num,
                                             x_sr_id => l_sr_id_num,
                                             x_asof_date => l_curr_asof_date,
                                             x_priorasof_date => l_prev_asof_date,
                                             x_fdcp_date => l_fdcp_date,
                                             x_fdpp_date => l_fdpp_date,
                                             x_period_type => l_period_type,
                                             x_comparision_type => l_comparision_type,
                                             x_orderBy => l_orderBy,
                                             x_sortBy => l_sortBy,
                                             x_viewby => l_viewBy,
                                             x_prodcat_id => l_prodcat_id,
                                             x_product_id => l_product_id);

         l_fdcp_date_j := TO_CHAR(l_fdcp_date,'J');
         l_fdpp_date_j := TO_CHAR(l_fdpp_date,'J');

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                           MODULE => l_module_name,
                           MESSAGE => ' Begining to construct query ..');
         END IF;

         /* Total approvals */

   -- ITD Measures --

   l_sql_text1 := ' SELECT
                 (CASE
 		     WHEN report_date = :l_fdcp_date
                     THEN open_approvals
                     ELSE NULL
                  END) ASO_VALUE1
                 ,(CASE
		      WHEN report_date = :l_fdpp_date
                      THEN open_approvals
                      ELSE NULL
                  END) ASO_VALUE2
                   FROM ASO_BI_QOT_APR_MV sumry,
                        FII_TIME_RPT_STRUCT_V cal
                   WHERE parent_resource_grp_id = :l_sg_id_num
                     AND cal.calendar_id = -1
                     AND cal.report_date in (:l_fdcp_date,:l_fdpp_date)
                     AND sumry.time_id = cal.time_id
                     AND sumry.period_type_id = cal.period_type_id
                     AND BITAND(cal.record_type_id,1143) = cal.record_type_id ';

    IF l_sr_id_num IS NOT NULL THEN
            l_sql_text1 := l_sql_text1 ||'AND sumry.Resource_id = :l_sr_id_num ';
    END IF;

    -- PTD measures --
    l_sql_text2 := ' SELECT
                      (CASE
		           WHEN report_date = :l_curr_asof_date
                           THEN new_approvals
                           ELSE NULL
                       END) ASO_VALUE1
                      ,(CASE
		            WHEN report_date = :l_prev_asof_date
                            THEN new_approvals
                            ELSE NULL
                        END) ASO_VALUE2
                      FROM ASO_BI_QOT_APR_MV sumry,
                             FII_TIME_RPT_STRUCT_V cal
                        WHERE parent_resource_grp_id = :l_sg_id_num
                          AND cal.calendar_id = -1
                          AND cal.report_date in (:l_curr_asof_date,:l_prev_asof_date)
                          AND sumry.time_id = cal.time_id
                          AND sumry.period_type_id = cal.period_type_id
			  AND BITAND(cal.record_type_id,:l_record_type_id) = cal.record_type_id ';

  IF l_sr_id_num IS NOT NULL THEN
            l_sql_text2 := l_sql_text2 ||'AND sumry.Resource_id = :l_sr_id_num ';
         END IF;

 -- Elimination of duplicate Quotes in calculation to Total Quotes --

  l_sql_text3 :=  'SELECT
                   (CASE
		       WHEN sumry.Time_id = :l_fdcp_date_j
		       THEN -1 * open_approvals
		   END) ASO_VALUE1
                  ,(CASE
		      WHEN sumry.Time_id = :l_fdpp_date_j
		      THEN -1 * open_approvals
		   END) ASO_VALUE2
                   FROM ASO_BI_QOT_APR_MV sumry
                   WHERE parent_resource_grp_id=:l_sg_id_num
                    AND sumry.time_id in (:l_fdcp_date_j,:l_fdpp_date_j)
                   AND sumry.period_type_id=1 ';

         IF l_sr_id_num IS NOT NULL THEN
            l_sql_text3 := l_sql_text3 ||'AND sumry.resource_id = :l_sr_id_num ';
         END IF;


         DELETE FROM ASO_BI_RPT_TMP1;
         l_insert_stmt := 'INSERT INTO ASO_BI_RPT_TMP1(ASO_VALUE1,ASO_VALUE2)';

          /* Total approvals */

         IF l_sr_id_num IS NULL THEN

               EXECUTE IMMEDIATE l_insert_stmt || l_sql_text1
               USING l_fdcp_date , l_fdpp_date , l_sg_id_num
                    ,l_fdcp_date ,l_fdpp_date;

               EXECUTE IMMEDIATE l_insert_stmt || l_sql_text2
               USING l_curr_asof_date , l_prev_asof_date , l_sg_id_num
                    ,l_curr_asof_date , l_prev_asof_date , l_record_type_id;

               EXECUTE IMMEDIATE l_insert_stmt || l_sql_text3
               USING   l_fdcp_date_j , l_fdpp_date_j , l_sg_id_num
                      ,l_fdcp_date_j , l_fdpp_date_j;

        ELSE

              EXECUTE IMMEDIATE l_insert_stmt || l_sql_text1
               USING l_fdcp_date , l_fdpp_date , l_sg_id_num
                    ,l_fdcp_date ,l_fdpp_date , l_sr_id_num;

               EXECUTE IMMEDIATE l_insert_stmt || l_sql_text2
               USING l_curr_asof_date , l_prev_asof_date , l_sg_id_num
                    ,l_curr_asof_date , l_prev_asof_date , l_record_type_id
                    ,l_sr_id_num;

               EXECUTE IMMEDIATE l_insert_stmt || l_sql_text3
               USING   l_fdcp_date_j , l_fdpp_date_j , l_sg_id_num
                      ,l_fdcp_date_j , l_fdpp_date_j , l_sr_id_num;

         END IF;


         SELECT SUM(ASO_VALUE1),SUM(ASO_VALUE2) INTO l_curr_value,l_prev_value FROM ASO_BI_RPT_TMP1;

         /* Rules...*/

	l_sql_text4 := 'SELECT sumry.rule_id
                              ,(CASE
		                  WHEN report_date = :l_fdcp_date
                                  THEN open_rules
                                  ELSE NULL
                               END) ASO_VALUE1
                             ,(CASE WHEN report_date = :l_fdpp_date
                                    THEN open_rules
                                    ELSE NULL
                               END) ASO_VALUE2
                        FROM ASO_BI_QOT_RUL_MV sumry,
                             FII_TIME_RPT_STRUCT_V cal
                        WHERE parent_resource_grp_id = :l_sg_id_num
                          AND cal.calendar_id = -1
                          AND cal.report_date in (:l_fdcp_date,:l_fdpp_date)
                          AND sumry.time_id = cal.time_id
                          AND sumry.period_type_id = cal.period_type_id
                          AND BITAND(cal.record_type_id,1143) = cal.record_type_id ';

         IF l_sr_id_num IS NOT NULL THEN
            l_sql_text4 := l_sql_text4 ||'AND sumry.Resource_id = :l_sr_id_num ';
         END IF;

	 l_sql_text4 := l_sql_text4 ||' UNION ALL ' ;

         l_sql_text4 :=  l_sql_text4 ||  ' SELECT sumry.rule_id
                               ,(CASE
			            WHEN report_date = :l_curr_asof_date
                                    THEN new_rules
                                    ELSE NULL
                                 END) ASO_VALUE1
                              ,(CASE
			           WHEN report_date = :l_prev_asof_date
                                   THEN new_rules
                                   ELSE NULL
                                END) ASO_VALUE2
                         FROM ASO_BI_QOT_RUL_MV sumry,
                             FII_TIME_RPT_STRUCT_V cal
                        WHERE parent_resource_grp_id = :l_sg_id_num
                         AND cal.calendar_id = -1
                         AND cal.report_date in (:l_curr_asof_date,:l_prev_asof_date)
                         AND sumry.time_id = cal.time_id
                         AND sumry.period_type_id = cal.period_type_id
                         AND BITAND(cal.record_type_id,:l_record_type_id) = cal.record_type_id ';

         IF l_sr_id_num IS NOT NULL THEN
            l_sql_text4 := l_sql_text4 ||'AND sumry.Resource_id = :l_sr_id_num ';
         END IF;

         l_sql_text4 := l_sql_text4 ||' UNION ALL ' ;


         l_sql_text4 :=  l_sql_text4 || ' SELECT sumry.rule_id
                               ,(CASE
			            WHEN sumry.Time_id = :l_fdcp_date_j
				    THEN -1 * open_rules
				END) ASO_VALUE1
                              ,(CASE
			            WHEN sumry.Time_id = :l_fdpp_date_j
				    THEN -1 * open_rules
			        END) ASO_VALUE2
                            FROM ASO_BI_QOT_RUL_MV sumry
                            WHERE parent_resource_grp_id = :l_sg_id_num
                              AND sumry.time_id in (:l_fdcp_date_j,:l_fdpp_date_j)
                              AND sumry.period_type_id = 1 ';

         IF l_sr_id_num IS NOT NULL THEN
            l_sql_text4 := l_sql_text4 ||'AND sumry.resource_id = :l_sr_id_num ';
         END IF;


         l_sql_text4 := 'SELECT Rule_id, DECODE(SUM(ASO_VALUE1),0,NULL,SUM(ASO_VALUE1)) ASO_VALUE1
                               ,DECODE(SUM(ASO_VALUE2),0,NULL,SUM(ASO_VALUE2)) ASO_VALUE2
                         FROM ('|| l_sql_text4 ||')
                         GROUP BY Rule_id ';

         IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            aso_bi_qot_util_pvt.write_query(l_sql_text2,l_module_name);
         END IF;

         DELETE FROM ASO_BI_RPT_TMP2;
         l_insert_stmt := 'INSERT INTO ASO_BI_RPT_TMP2(ASO_ATTRIBUTE1,ASO_VALUE1,ASO_VALUE2) ';

         IF l_sr_id_num IS NULL THEN

               EXECUTE IMMEDIATE l_insert_stmt || l_sql_text4
               USING l_fdcp_date , l_fdpp_date , l_sg_id_num
                    ,l_fdcp_date , l_fdpp_date , l_curr_asof_date
                    ,l_prev_asof_date ,l_sg_id_num , l_curr_asof_date
                    ,l_prev_asof_date , l_record_type_id , l_fdcp_date_j
                    ,l_fdpp_date_j  , l_sg_id_num , l_fdcp_date_j
                    ,l_fdpp_date_j;
          ELSE
            EXECUTE IMMEDIATE l_insert_stmt || l_sql_text4
            USING  l_fdcp_date , l_fdpp_date , l_sg_id_num
                  ,l_fdcp_date , l_fdpp_date , l_sr_id_num
                  ,l_curr_asof_date , l_prev_asof_date ,l_sg_id_num
                  ,l_curr_asof_date , l_prev_asof_date , l_record_type_id
                  ,l_sr_id_num , l_fdcp_date_j  , l_fdpp_date_j
                  ,l_sg_id_num , l_fdcp_date_j , l_fdpp_date_j
                  ,l_sr_id_num;

         END IF;

         x_custom_sql := 'SELECT MAX(AME.DESCRIPTION) ASO_VALUE1 '||
                               ',MAX(ASO_VALUE2) ASO_VALUE2,MAX(ASO_CHANGE1) ASO_CHANGE1 '||
                           'FROM '||
                                 '(SELECT a.rule_id '||
                                       ', a.description '||
                                  'FROM ame_rules a '||
                                       ',(SELECT rule_id '||
                                                 ',MAX(start_date) start_date '||
                                         'FROM ame_rules '||
                                         'GROUP BY rule_id '||
                                         ') b '||
                                  'WHERE a.rule_id = b.rule_id AND a.start_date = b.start_date '||
                                 ') AME '||
                                 ',(SELECT ASO_VALUE1/DECODE(:l_curr_value,0,NULL,:l_curr_value) * 100 ASO_VALUE2'||
                                         ',((ASO_VALUE1/DECODE(:l_curr_value,0,NULL,:l_curr_value)) - '||
                                           '(ASO_VALUE2/DECODE(:l_prev_value,0,NULL,:l_prev_value))) * 100 ASO_CHANGE1'||
                                         ',ASO_ATTRIBUTE1 '||
                                   'FROM ASO_BI_RPT_TMP2 '||
                                   'WHERE NOT (ASO_VALUE1 IS NULL AND ASO_VALUE2 IS NULL) '||
                                  ') WHERE ASO_ATTRIBUTE1 = ame.rule_id GROUP BY ASO_ATTRIBUTE1 ';

          IF 0 <> INSTR(l_orderby,'ASO_VALUE1')  THEN
             x_custom_sql := x_custom_sql || ' ORDER BY '|| l_orderby ||' '|| l_sortBy ||' NULLS LAST ';
          ELSE
             x_custom_sql := x_custom_sql || ' ORDER BY TO_NUMBER(ASO_VALUE2) '|| l_sortBy ||' NULLS LAST ';
          END IF;

          l_custom_rec.attribute_name := ':l_curr_value';
          l_custom_rec.attribute_value :=  l_curr_value;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
          rec_index := rec_index + 1;
          x_custom_output.EXTEND;
          x_custom_output(rec_index) := l_custom_rec;

          l_custom_rec.attribute_name := ':l_prev_value';
          l_custom_rec.attribute_value :=  l_prev_value;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
          rec_index := rec_index + 1;
          x_custom_output.EXTEND;
          x_custom_output(rec_index) := l_custom_rec;

END BY_APPR_RULES;

/*
  This will return the SQL Query for Approval Summary by sales group
  Mappings...
  ASO_ATTRIBUTE1    -  All Submissions
  ASO_VALUE1        -  All Submission Count (for KPI)
  ASO_VALUE15       -  Count
  ASO_VALUE2        -  Prev Approval Submissions
  ASO_CHANGE1       -  Change
  ASO_VALUE16       -  Approved%
  ASO_VALUE17       -  All Sub Approved % (for KPI)
  ASO_VALUE18       -  Previous Approved % for All Submission
  ASO_CHANGE10      -  Change
  ASO_ATTRIBUTE2    -  Completed Submissions
  ASO_VALUE3        -  Count
  ASO_CHANGE2       -  Change
  ASO_VALUE5        -  Approved %(for KPI)
  ASO_VALUE19       -  Approved%
  ASO_VALUE6        -  Prev Approval Percent
  ASO_CHANGE3       -  Change
  ASO_VALUE7        -  Average Days for Approval
  ASO_VALUE8        -  Prev Average Days For Approval
  ASO_CHANGE4       -  Change
  ASO_VALUE9        -  Average Number of Approvers
  ASO_VALUE10       -  Prev Average Number of Approvers
  ASO_CHANGE5       -  Change
  ASO_GRAND_VALUE1  - Grand Total (Approval Submissions)
  ASO_GRAND_VALUE15 - ASO Grand Value15
  ASO_GRAND_VALUE2  - Grand Total (Prev Approval Submissions)
  ASO_GRAND_CHANGE1 - Grand Change (Approval Submissions)
  ASO_GRAND_VALUE16 - ASO Grand Value16
  ASO_GRAND_VALUE17 - ASO Grand Value17
  ASO_GRAND_VALUE18 - ASO Grand Value18
  ASO_GRAND_CHANGE6 - ASO Grand Change6
  ASO_GRAND_VALUE19 - ASO Grand Value19
  ASO_GRAND_VALUE3  - Grand Total (Completed Submissions)
  ASO_GRAND_CHANGE2 - Grand Change (Completed Submissions)
  ASO_GRAND_VALUE5  - Grand Total (Approval Percent)
  ASO_GRAND_VALUE6  - Grand Total (Prev Approval Percent)
  ASO_GRAND_CHANGE3 - Grand Change (Approval Percent)
  ASO_GRAND_VALUE7  - Grand Total (Days for Approval)
  ASO_GRAND_VALUE8  - Grand Total (Prev Days for Approval)
  ASO_GRAND_CHANGE4 - Grand Change (Days for Approval)
  ASO_GRAND_VALUE9  - Grand Total (Number of Approvers)
  ASO_GRAND_VALUE10 - Grand Total (Prev Number of Approvers)
  ASO_GRAND_CHANGE5 - Grand Change (Number of Approvers)
*/

PROCEDURE APPR_BY_SALESGRP_SQL(p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                               x_custom_sql     OUT NOCOPY VARCHAR2,
                               x_custom_output  OUT NOCOPY bis_query_attributes_TBL)
AS
  l_sql_text1           VARCHAR2(32000);
  l_sql_text2           VARCHAR2(32000);
  l_insert_stmt         VARCHAR2(3200);
  l_outer_sql           VARCHAR2(32000);
  l_parameter_name      VARCHAR2(3200);
  l_period_type         VARCHAR2(3200);
  l_comparision_type    VARCHAR2(3200);
  l_orderby             VARCHAR2(200);
  l_sortBy              VARCHAR2(200);
  l_module_name         VARCHAR2(100);
  l_viewby              VARCHAR2(100);
  l_url                 VARCHAR2(600);
  l_prodcat_id          VARCHAR2(100);
  l_product_id          VARCHAR2(100);
  l_curr_value          NUMBER;
  l_prev_value          NUMBER;
  l_record_type_id      NUMBER;
  l_sg_id_num           NUMBER;
  l_sr_id_num           NUMBER;
  l_conv_rate           NUMBER;
  l_fdcp_date_j         NUMBER;
  l_fdpp_date_j         NUMBER;
  l_curr_asof_date      DATE;
  l_prev_asof_date      DATE;
  l_fdcp_date           DATE;
  l_fdpp_date           DATE;
  l_sysdate             DATE;
  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  rec_index             NUMBER := 0;

BEGIN

      --Initialise here to get around File.sql.35
       l_module_name := 'ASO_BI_QOT_SUMMRY_PVT.APPR_BY_SALESGRP_SQL';
       x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
       l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

       -- Set up the parameters
       ASO_BI_QOT_UTIL_PVT.GET_PAGE_PARAMS(p_pmv_parameters => p_pmv_parameters,
                                           x_conv_rate => l_conv_rate,
                                           x_record_type_id => l_record_type_id,
                                           x_sysdate => l_sysdate,
                                           x_sg_id => l_sg_id_num,
                                           x_sr_id => l_sr_id_num,
                                           x_asof_date => l_curr_asof_date,
                                           x_priorasof_date => l_prev_asof_date,
                                           x_fdcp_date => l_fdcp_date,
                                           x_fdpp_date => l_fdpp_date,
                                           x_period_type => l_period_type,
                                           x_comparision_type => l_comparision_type,
                                           x_orderBy => l_orderBy,
                                           x_sortBy => l_sortBy,
                                           x_viewby => l_viewBy,
                                           x_prodcat_id => l_prodcat_id,
                                           x_product_id => l_product_id);

       l_fdcp_date_j := TO_CHAR(l_fdcp_date,'J');
       l_fdpp_date_j := TO_CHAR(l_fdpp_date,'J');

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                         MODULE => l_module_name,
                         MESSAGE => ' Begining to construct query ..');
       END IF;

      l_outer_sql :=     ' SELECT      VIEWBY ' ||
                           ' ,VIEWBYID  '||
                           ' ,ASO_VALUE1 '||
                           ' ,ASO_VALUE1 ASO_VALUE15 '||
                           ' ,ASO_VALUE2  '||
                           ' ,ASO_CHANGE1 '||
                           ' ,ASO_VALUE16 '||
                           ' ,ASO_VALUE16 ASO_VALUE17 '||
                           ' ,ASO_VALUE18 '||
                           ' ,ASO_CHANGE10 '||
                           ' ,ASO_VALUE3 '||
                           ' ,ASO_CHANGE2 '||
                           ' ,ASO_VALUE5 '||
                           ' ,ASO_VALUE5 ASO_VALUE19 '||
                           ' ,ASO_VALUE6 '||
                           ' ,ASO_CHANGE3 '||
                          '  ,ASO_VALUE7 '||
                          '  ,ASO_VALUE8 '||
                          '  ,ASO_CHANGE4 '||
                          '  ,ASO_VALUE9 '||
                          '  ,ASO_VALUE10 '||
                          '  ,ASO_CHANGE5 '||
                         '  ,ASO_GRAND_VALUE1 '||
                          '  ,ASO_GRAND_VALUE1 ASO_GRAND_VALUE15 '||
                          '  ,ASO_GRAND_VALUE2 '||
                          '  ,ASO_GRAND_CHANGE1 '||
                          '  ,ASO_GRAND_VALUE16 '||
                          '  ,ASO_GRAND_VALUE16 ASO_GRAND_VALUE17 '||
                          '  ,ASO_GRAND_VALUE18 '||
                          '  ,ASO_GRAND_CHANGE6 '||
                          '  ,ASO_GRAND_VALUE5 ASO_GRAND_VALUE19 '||
                          '  ,ASO_GRAND_VALUE3 '||
                          '  ,ASO_GRAND_CHANGE2 '||
                          '  ,ASO_GRAND_VALUE5 '||
                          '  ,ASO_GRAND_VALUE6 '||
                          '  ,ASO_GRAND_CHANGE3 '||
                          '  ,ASO_GRAND_VALUE7 '||
                          '  ,ASO_GRAND_VALUE8 '||
                          '  ,ASO_GRAND_CHANGE4 '||
                          ' ,ASO_GRAND_VALUE9 '||
                          ' ,ASO_GRAND_VALUE10 '||
                          ' ,ASO_GRAND_CHANGE5 '||
                          ' ,ASO_VALUE2 ASO_VALUE11'||
                          ' ,ASO_VALUE1 ASO_VALUE12'||
                          ' ,ASO_VALUE13  '||
                          ' ,ASO_VALUE14  '||
                          ' ,ASO_URL1 '||
                          ' ,NULL ASO_RES_GRP_ID '||
                          ' , NULL ASO_RES_OR_GRP  FROM   '||
                         '  ( SELECT VIEWBY'||
                              ',VIEWBYID'||
                              ',ASO_VALUE1'||
                              ',ASO_VALUE2'||
                              ',DECODE(ASO_VALUE2,0,NULL,(ASO_VALUE1 - ASO_VALUE2) * 100'||
                                                   '/ABS(ASO_VALUE2)) ASO_CHANGE1'||
			      ',DECODE(ASO_VALUE1,0,NULL,(ASO_VALUE5 * 100) / ASO_VALUE1) ASO_VALUE16'||
                              ',DECODE(ASO_VALUE2,0,NULL,(ASO_VALUE6 * 100) / ASO_VALUE2) ASO_VALUE18'||
                              ',(DECODE(ASO_VALUE1,0,NULL,(ASO_VALUE5 * 100) / ASO_VALUE1) - '||
                              'DECODE(ASO_VALUE2,0,NULL,(ASO_VALUE6 * 100) / ASO_VALUE2)) ASO_CHANGE10'||
                              ',ASO_VALUE3'||
                              ',DECODE(ASO_VALUE4,0,NULL,((ASO_VALUE3 - ASO_VALUE4) * 100 / ASO_VALUE4)) ASO_CHANGE2'||
                              ',DECODE(ASO_VALUE3,0,NULL,(ASO_VALUE5 * 100) / ASO_VALUE3) ASO_VALUE5'||
                              ',DECODE(ASO_VALUE4,0,NULL,(ASO_VALUE6 * 100) / ASO_VALUE4) ASO_VALUE6'||
                              ',(DECODE(ASO_VALUE3,0,NULL,(ASO_VALUE5 * 100) / ASO_VALUE3) - '||
                                'DECODE(ASO_VALUE4,0,NULL,(ASO_VALUE6 * 100) / ASO_VALUE4)) ASO_CHANGE3'||
                              ',DECODE(ASO_VALUE3,0,NULL,ASO_VALUE7 / ASO_VALUE3) ASO_VALUE7'||
                              ',DECODE(ASO_VALUE4,0,NULL,ASO_VALUE8 / ASO_VALUE4) ASO_VALUE8'||
                              ',DECODE(DECODE(ASO_VALUE4,0,NULL,ASO_VALUE8 / ASO_VALUE4),0,NULL,'||
                                     '(DECODE(ASO_VALUE3,0,NULL,ASO_VALUE7 / ASO_VALUE3) - '||
                                     'DECODE(ASO_VALUE4,0,NULL,ASO_VALUE8 / ASO_VALUE4)'||
                                     ') * 100 / '||
                                     'DECODE(ASO_VALUE4,0,NULL,ASO_VALUE8 / ASO_VALUE4)) ASO_CHANGE4'||
                              ',DECODE(ASO_VALUE3,0,NULL,ASO_VALUE9 / ASO_VALUE3) ASO_VALUE9'||
                              ',DECODE(ASO_VALUE4,0,NULL,ASO_VALUE10 / ASO_VALUE4) ASO_VALUE10'||
                              ',DECODE(DECODE(ASO_VALUE4,0,NULL,ASO_VALUE10 / ASO_VALUE4),0,0,'||
                                       '(DECODE(ASO_VALUE3,0,NULL,ASO_VALUE9 / ASO_VALUE3) - '||
                                       'DECODE(ASO_VALUE4,0,NULL,ASO_VALUE10 / ASO_VALUE4)) * 100 / '||
                                       'DECODE(ASO_VALUE4,0,NULL,ASO_VALUE10 / ASO_VALUE4)) ASO_CHANGE5'||
                              ',DECODE(ASO_VALUE4,0,NULL,(ASO_VALUE6 * 100) / ASO_VALUE4) ASO_VALUE13'||
                              ',DECODE(ASO_VALUE3,0,NULL,(ASO_VALUE5 * 100) / ASO_VALUE3) ASO_VALUE14'||
                              ',SUM(DECODE(ASO_VALUE1,0,NULL,ASO_VALUE1)) OVER() ASO_GRAND_VALUE1'||
                              ',SUM(ASO_VALUE2) OVER() ASO_GRAND_VALUE2'||
                              ',DECODE(SUM(ASO_VALUE2) OVER(),0,NULL,((SUM(ASO_VALUE1) OVER() - SUM(ASO_VALUE2) OVER()) * 100)'||
                                                   '/ABS(SUM(ASO_VALUE2) OVER())) ASO_GRAND_CHANGE1'||
                              ',DECODE(SUM(ASO_VALUE1) OVER(),0,NULL,(SUM(ASO_VALUE5) OVER() * 100) / SUM(ASO_VALUE1) OVER()) ASO_GRAND_VALUE16'||
                              ',DECODE(SUM(ASO_VALUE2) OVER(),0,NULL,(SUM(ASO_VALUE6) OVER() * 100) / SUM(ASO_VALUE2) OVER()) ASO_GRAND_VALUE18'||
                              ',(DECODE(SUM(ASO_VALUE1) OVER(),0,NULL,(SUM(ASO_VALUE5) OVER() * 100)/SUM(ASO_VALUE1) OVER()) - '||
                                'DECODE(SUM(ASO_VALUE2) OVER(),0,NULL,(SUM(ASO_VALUE6) OVER() * 100) / SUM(ASO_VALUE2) OVER())) ASO_GRAND_CHANGE6'||
                              ',SUM(ASO_VALUE3) OVER() ASO_GRAND_VALUE3'||
                              ',DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,((SUM(ASO_VALUE3) OVER() - SUM(ASO_VALUE4) OVER()) * 100 / SUM(ASO_VALUE4) OVER())) '||
                                'ASO_GRAND_CHANGE2'||
                              ',DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,(SUM(ASO_VALUE5) OVER() * 100) / SUM(ASO_VALUE3) OVER()) ASO_GRAND_VALUE5'||
                              ',DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE6) OVER() * 100) / SUM(ASO_VALUE4) OVER()) ASO_GRAND_VALUE6'||
                              ',(DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,(SUM(ASO_VALUE5) OVER() * 100)/SUM(ASO_VALUE3) OVER()) - '||
                                'DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE6) OVER() * 100) / SUM(ASO_VALUE4) OVER())) ASO_GRAND_CHANGE3'||
                              ',DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,(SUM(ASO_VALUE7) OVER()) / SUM(ASO_VALUE3) OVER()) ASO_GRAND_VALUE7'||
                              ',DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE8) OVER()) / SUM(ASO_VALUE4) OVER()) ASO_GRAND_VALUE8'||
                              ',DECODE(DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE8) OVER()) / SUM(ASO_VALUE4) OVER()),0,NULL,'||
                                     '(DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,(SUM(ASO_VALUE7) OVER()) / SUM(ASO_VALUE3) OVER()) - '||
                                     'DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE8) OVER()) / SUM(ASO_VALUE4) OVER())'||
                                     ') * 100 / '||
                                     'DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE8) OVER()) / SUM(ASO_VALUE4) OVER())) ASO_GRAND_CHANGE4'||
                              ',DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,(SUM(ASO_VALUE9) OVER()) / SUM(ASO_VALUE3) OVER()) ASO_GRAND_VALUE9'||
                              ',DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE10) OVER()) / SUM(ASO_VALUE4) OVER()) ASO_GRAND_VALUE10'||
                              ',DECODE(DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE10) OVER()) / SUM(ASO_VALUE4) OVER()),0,0,'||
                                       '(DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,(SUM(ASO_VALUE9) OVER()) / SUM(ASO_VALUE3) OVER()) - '||
                                       'DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE10) OVER()) / SUM(ASO_VALUE4) OVER())) * 100 / '||
                                       'DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE10) OVER()) / SUM(ASO_VALUE4) OVER())) ASO_GRAND_CHANGE5'||
                              ',ASO_URL1,NULL ASO_RES_GRP_ID,NULL ASO_RES_OR_GRP ';


        -- Query for ITD Measures --

        l_sql_text1 := 'SELECT sumry.Resource_grp_id Res_grp_id,sumry.Resource_id Res_id
	                ,(CASE WHEN report_date = :l_fdcp_date
                               THEN open_approvals
                                ELSE NULL
                          END) ASO_VALUE1
                         ,(CASE WHEN report_date = :l_fdpp_date
                                THEN open_approvals
                                ELSE NULL
                          END) ASO_VALUE2
                          ,NULL ASO_VALUE3
                          ,NULL ASO_VALUE4
                          ,NULL ASO_VALUE5
                          ,NULL ASO_VALUE6
                          ,NULL ASO_VALUE7
                          ,NULL ASO_VALUE8
                          ,NULL ASO_VALUE9
                          ,NULL ASO_VALUE10
                      FROM ASO_BI_QOT_APR_MV sumry,
                           FII_TIME_RPT_STRUCT_V cal
                      WHERE parent_resource_grp_id = :l_sg_id_num
                            AND cal.calendar_id = -1
                            AND cal.report_date in (:l_fdcp_date,:l_fdpp_date)
                            AND sumry.time_id = cal.time_id
                            AND sumry.period_type_id = cal.period_type_id
                            AND BITAND(cal.record_type_id,1143) = cal.record_type_id ';

                        IF l_sr_id_num IS NOT NULL THEN
                           l_sql_text1 := l_sql_text1 ||'AND sumry.Resource_id = :l_sr_id_num ';
                        END IF;

  -- Query for PTD Measures ---

     l_sql_text1 := l_sql_text1 || ' UNION ALL ' ;
     l_sql_text1 := l_sql_text1 || 'SELECT sumry.Resource_grp_id Res_grp_id,sumry.Resource_id Res_id
                            ,(CASE WHEN report_date = :l_curr_asof_date
                                   THEN new_approvals
                                   ELSE NULL
                             END) ASO_VALUE1
                             ,(CASE WHEN report_date = :l_prev_asof_date
                                    THEN new_approvals
                                    ELSE NULL
                             END) ASO_VALUE2
   	                    ,(CASE WHEN report_date = :l_curr_asof_date
                                   THEN complete_approvals
                                   ELSE NULL
                              END) ASO_VALUE3
                             ,(CASE WHEN report_date = :l_prev_asof_date
                                    THEN complete_approvals
                                    ELSE NULL
                               END) ASO_VALUE4
                              ,(CASE WHEN report_date = :l_curr_asof_date
                                     THEN approved_approvals
                                     ELSE NULL
                               END) ASO_VALUE5
                              ,(CASE WHEN report_date = :l_prev_asof_date
                                     THEN approved_approvals
                                     ELSE NULL
                               END) ASO_VALUE6
                               ,(CASE WHEN report_date = :l_curr_asof_date
                                      THEN days_for_approval
                                      ELSE NULL
                                END) ASO_VALUE7
                               ,(CASE WHEN report_date = :l_prev_asof_date
                                      THEN days_for_approval
                                      ELSE NULL
                                END) ASO_VALUE8
                               ,(CASE WHEN report_date = :l_curr_asof_date
                                       THEN number_of_approvers
                                       ELSE NULL
                                  END) ASO_VALUE9
                                ,(CASE WHEN report_date = :l_prev_asof_date
                                       THEN number_of_approvers
                                       ELSE NULL
                                  END) ASO_VALUE10
                      FROM ASO_BI_QOT_APR_MV sumry,
                           FII_TIME_RPT_STRUCT_V cal
                      WHERE parent_resource_grp_id = :l_sg_id_num
                            AND cal.calendar_id = -1
                            AND cal.report_date in (:l_curr_asof_date,:l_prev_asof_date)
                            AND sumry.time_id = cal.time_id
                            AND sumry.period_type_id = cal.period_type_id
                            AND BITAND(cal.record_type_id,:l_record_type_id) = cal.record_type_id ';

                        IF l_sr_id_num IS NOT NULL THEN
                           l_sql_text1 := l_sql_text1 ||'AND sumry.Resource_id = :l_sr_id_num ';
                        END IF;


  --- Elinimianation of Duplicate Values ---

     l_sql_text1 := l_sql_text1 || ' UNION ALL ';
     l_sql_text1 := l_sql_text1 ||'SELECT sumry.Resource_grp_id Res_grp_id
                          ,sumry.Resource_id Res_id
                          ,(CASE WHEN sumry.Time_id=:l_fdcp_date_j
			        THEN -1*open_approvals
			   END) ASO_VALUE1
                          ,(CASE WHEN sumry.Time_id=:l_fdpp_date_j
			         THEN -1*open_approvals
		            END) ASO_VALUE2
                          ,NULL ASO_VALUE3
			  ,NULL ASO_VALUE4
			  ,NULL ASO_VALUE5
			  ,NULL ASO_VALUE6
			  ,NULL ASO_VALUE7
			  ,NULL ASO_VALUE8
			  ,NULL ASO_VALUE9,
			  NULL ASO_VALUE10
     			 FROM ASO_BI_QOT_APR_MV sumry
                         WHERE parent_resource_grp_id=:l_sg_id_num
                           AND sumry.time_id in (:l_fdcp_date_j,:l_fdpp_date_j)
                           AND sumry.period_type_id=1';

          IF l_sr_id_num IS NOT NULL THEN
             l_sql_text1 := l_sql_text1 ||'AND sumry.resource_id = :l_sr_id_num ';
          END IF;


       l_url := 'pFunctionName=ASO_BI_APPR_BY_SG&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP&VIEW_BY_NAME=VIEW_BY_ID';

       l_sql_text2 := ' SELECT DECODE(restl.resource_id,NULL,grptl.group_name,restl.resource_name) VIEWBY
                              ,NVL(restl.resource_id,grptl.group_id) VIEWBYID
                              ,DECODE(restl.resource_id,NULL,'''|| l_url ||''',NULL) ASO_URL1
                              ,DECODE(SUM(Inn.ASO_VALUE1),0,NULL,SUM(Inn.ASO_VALUE1)) ASO_VALUE1,SUM(Inn.ASO_VALUE2) ASO_VALUE2
                              ,DECODE(SUM(Inn.ASO_VALUE3),0,NULL,SUM(Inn.ASO_VALUE3)) ASO_VALUE3,SUM(Inn.ASO_VALUE4) ASO_VALUE4
                              ,SUM(Inn.ASO_VALUE5) ASO_VALUE5,SUM(Inn.ASO_VALUE6) ASO_VALUE6
                              ,SUM(Inn.ASO_VALUE7) ASO_VALUE7,SUM(Inn.ASO_VALUE8) ASO_VALUE8
                              ,SUM(Inn.ASO_VALUE9) ASO_VALUE9,SUM(Inn.ASO_VALUE10) ASO_VALUE10
                        FROM ('||l_sql_text1||') Inn
                            ,JTF_RS_RESOURCE_EXTNS_TL Restl
                            ,JTF_RS_GROUPS_TL Grptl
                        WHERE Inn.Res_id=Restl.Resource_Id(+)
                              AND Inn.Res_grp_id=Grptl.Group_Id
                              AND Restl.Language(+)=USERENV(''LANG'')
                              AND Grptl.Language=USERENV(''LANG'')
                        GROUP BY DECODE(restl.resource_id,NULL,'''|| l_url ||''',NULL)
                                ,DECODE(restl.resource_id,NULL,grptl.group_name,restl.resource_name)
                                ,NVL(restl.resource_id,grptl.group_id) ';

       IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          aso_bi_qot_util_pvt.write_query(l_sql_text2,l_module_name);
       END IF;

       DELETE FROM ASO_BI_RPT_TMP1;
       l_insert_stmt := 'INSERT INTO ASO_BI_RPT_TMP1(VIEWBY,VIEWBYID,ASO_URL1,ASO_VALUE1,ASO_VALUE2,ASO_VALUE3,ASO_VALUE4,ASO_VALUE5
                                                     ,ASO_VALUE6,ASO_VALUE7,ASO_VALUE8,ASO_VALUE9,ASO_VALUE10) ';

       IF l_sr_id_num IS NULL THEN

          EXECUTE IMMEDIATE l_insert_stmt || l_sql_text2
 	  USING  l_fdcp_date , l_fdpp_date , l_sg_id_num
                ,l_fdcp_date , l_fdpp_date

                ,l_curr_asof_date , l_prev_asof_date , l_curr_asof_date
                ,l_prev_asof_date , l_curr_asof_date , l_prev_asof_date
                ,l_curr_asof_date , l_prev_asof_date , l_curr_asof_date
                ,l_prev_asof_date , l_sg_id_num , l_curr_asof_date
                ,l_prev_asof_date , l_record_type_id

                ,l_fdcp_date_j , l_fdpp_date_j , l_sg_id_num
                ,l_fdcp_date_j , l_fdpp_date_j;
        ELSE

          EXECUTE IMMEDIATE l_insert_stmt || l_sql_text2
 	  USING  l_fdcp_date , l_fdpp_date , l_sg_id_num
                ,l_fdcp_date , l_fdpp_date , l_sr_id_num

                ,l_curr_asof_date , l_prev_asof_date , l_curr_asof_date
                ,l_prev_asof_date , l_curr_asof_date , l_prev_asof_date
                ,l_curr_asof_date , l_prev_asof_date , l_curr_asof_date
                ,l_prev_asof_date , l_sg_id_num , l_curr_asof_date
                ,l_prev_asof_date , l_record_type_id , l_sr_id_num

                ,l_fdcp_date_j , l_fdpp_date_j , l_sg_id_num
                ,l_fdcp_date_j , l_fdpp_date_j , l_sr_id_num;

       END IF;

       x_custom_sql := l_outer_sql ||' FROM ASO_BI_RPT_TMP1 WHERE NOT (NVL(ASO_VALUE1,0)=0 AND NVL(ASO_VALUE2,0)=0
                                                                       AND NVL(ASO_VALUE3,0)=0 AND NVL(ASO_VALUE4,0)=0
                                                                       AND NVL(ASO_VALUE5,0)=0 AND NVL(ASO_VALUE6,0)=0
                                                                       AND NVL(ASO_VALUE7,0)=0 AND NVL(ASO_VALUE8,0)=0
                                                                       AND NVL(ASO_VALUE9,0)=0 AND NVL(ASO_VALUE10,0)=0)  )';

       IF 'VIEWBY' = l_orderBy THEN
          x_custom_sql := x_custom_sql ||' ORDER BY VIEWBY '|| l_sortBy ||' NULLS LAST';
       ELSE
          x_custom_sql := x_custom_sql ||' ORDER BY TO_NUMBER('|| l_orderBy ||') '|| l_sortBy ||' NULLS LAST';
       END IF;

       rec_index := 1;

       l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
       l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
       l_custom_rec.attribute_value := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
       x_custom_output.Extend;
       x_custom_output(rec_index):=l_custom_rec;
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR ,
                       MODULE => l_module_name,
                       MESSAGE => 'Error while executing the procedure '|| SQLERRM);
    END IF;
    RAISE;
END APPR_BY_SALESGRP_SQL;


/* This will return the SQL Query for Current/Previous VALUES,
   COUNT of the Total/Converted QUOTES for Sales Group/Person.

     ASO_VALUE1  - Total Amount
     ASO_CHANGE1 - Change
     ASO_VALUE2  - Total Number
     ASO_CHANGE2 - Change
     ASO_VALUE3  - Converted Amount
     ASO_CHANGE3 - Change
     ASO_VALUE4  - Converted Number
     ASO_CHANGE4 - Change
     ASO_VALUE5  - Converted Amount %
     ASO_CHANGE5 - Change
     ASO_VALUE6  - Converted Count %
     ASO_CHANGE6 - Change
     ASO_VALUE7  - Average Days to convert
     ASO_CHANGE7 - Change
     ASO_VALUE8  - Prior Value For Conversion Percent Amount Graph
     ASO_VALUE9  - Current Value For Conversion Percent Amount Graph
     ASO_VALUE10 - Prior Value For Conversion Percent Number Graph
     ASO_VALUE11 - Current Value For Conversion Percent Number Graph
     ASO_VALUE12 - Prior Total Amount
     ASO_VALUE13 - Prior Converted Amount
     ASO_VALUE14 - Prior Conversion Percent - Amount
     ASO_VALUE15 - Prior Average days to convert
     ASO_GRAND_VALUE1 - ASO_GRAND_VALUE11 - Corresponding Grand Totals

     l_fdcp_date_j     : First Date of Current Period
     l_fdpp_date_j     : First Date of Previous Period
*/

PROCEDURE BY_SALESGRP_SQL(p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                          x_custom_sql     OUT NOCOPY VARCHAR2,
                          x_custom_output  OUT NOCOPY bis_query_attributes_TBL)
AS
  l_SQLTEXT1            VARCHAR2(32000);
  l_SQLTEXT2            VARCHAR2(32000);
  l_SQLTEXT3            VARCHAR2(32000);
  l_SQLTEXT10           VARCHAR2(32000);
  l_SQLTEXT11           VARCHAR2(32000);
  l_sql_stmnt1          VARCHAR2(32000);
  l_sql_stmnt2          VARCHAR2(32000);
  l_sql_stmnt3          VARCHAR2(32000);
  l_insert_stmnt        VARCHAR2(32000);
  l_period_type         VARCHAR2(3200);
  l_comparision_type    VARCHAR2(3200);
  l_orderBy             VARCHAR2(200);
  l_sortBy              VARCHAR2(200);
  l_viewby              VARCHAR2(100);
  l_product_id          VARCHAR2(200);
  l_prodcat_id          VARCHAR2(200);
  l_module_name         VARCHAR2(100);
  l_asof_date           DATE;
  l_priorasof_date      DATE;
  l_sysdate             DATE;
  l_fdcp_date           DATE;
  l_fdpp_date           DATE;
  l_fdcp_date_j         NUMBER;
  l_fdpp_date_j         NUMBER;
  l_record_type_id      NUMBER;
  l_conv_rate           NUMBER;
  l_sg_id_num           NUMBER;
  l_sr_id_num           NUMBER;
  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_sec_prefix		VARCHAR2(100);


BEGIN

  --Initialize
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  l_module_name :=  'ASO_BI_QOT_SUMMRY_PVT.BY_SALESGRP_SQL';

  -- Set up the parameters
  ASO_BI_QOT_UTIL_PVT.GET_PAGE_PARAMS(p_pmv_parameters => p_pmv_parameters,
                                    x_conv_rate => l_conv_rate,
                                    x_record_type_id => l_record_type_id,
                                    x_sysdate => l_sysdate,
                                    x_sg_id => l_sg_id_num,
                                    x_sr_id => l_sr_id_num,
                                    x_asof_date => l_asof_date,
                                    x_priorasof_date => l_priorasof_date,
                                    x_fdcp_date => l_fdcp_date,
                                    x_fdpp_date => l_fdpp_date,
                                    x_period_type => l_period_type,
                                    x_comparision_type => l_comparision_type,
                                    x_orderBy => l_orderBy,
                                    x_sortBy => l_sortBy,
                                    x_viewby => l_viewby,
                                    x_prodcat_id => l_prodcat_id,
                                    x_product_id => l_product_id);

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT ,
                    MODULE => l_module_name,
                    MESSAGE => '  Begining to construct query ..');
  END IF;

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT ,
                    MODULE => l_module_name,
                    MESSAGE => '  Resource : ' || l_sr_id_num ||'  Group is :' || l_sg_id_num || 'l_orderbyi :' ||l_orderBy);

  END IF;

  -- Get the julian format
  l_fdcp_date_j := TO_CHAR(l_fdcp_date,'J');
  l_fdpp_date_j := TO_CHAR(l_fdpp_date,'J');


  -- 7.0 rup1 changes - secondary Currency uptake. --

  IF l_conv_rate = 0
  THEN l_sec_prefix := 'sec_';
  ELSE
       l_sec_prefix := NULL;
  END IF;


  -- Query for getting Total quotes values for Resource Groups AND Resources
  -- ASO_VALUE -- Curr TotalQot_amnt
  -- ASO_VALUE -- Curr TotalQot_number
  -- ASO_VALUE -- Perv TotalQot_amnt
  -- ASO_VALUE -- Prev TotalQot_number
  -- ASO_VALUE -- Curr ConvQot_amnt
  -- ASO_VALUE -- Curr ConvQot_number
  -- ASO_VALUE -- Prev ConvQot_amnt
  -- ASO_VALUE -- Prev ConvQot_number
  -- ASO_VALUE -- Curr Conv_days
  -- ASO_VALUE -- Prev Conv_days
  --- ITD Query --

l_SQLTEXT1 :=
              'SELECT FACT.Resource_grp_id ASO_VALUE11,
                      FACT.Resource_id  ASO_VALUE12,
                      (CASE
                          WHEN report_date = :l_fdcp_date
                          THEN '||l_sec_prefix||'openqot_amnt
                          ELSE NULL
                      END) ASO_VALUE1,
                      (CASE
                         WHEN report_date = :l_fdcp_date
                         THEN openqot_number
                         ELSE NULL
                      END) ASO_VALUE2,
                      (CASE
                          WHEN report_date = :l_fdpp_date
                          THEN '||l_sec_prefix||'openqot_amnt
                          ELSE NULL
                      END) ASO_VALUE3,
                      (CASE
                          WHEN report_date = :l_fdpp_date
                          THEN openqot_number
                          ELSE NULL
                      END) ASO_VALUE4,
                      NULL  ASO_VALUE5,
                      NULL  ASO_VALUE6,
                      NULL  ASO_VALUE7,
                      NULL  ASO_VALUE8,
                      NULL  ASO_VALUE9,
                      NULL  ASO_VALUE10
              FROM  FII_TIME_RPT_STRUCT_V CAL,
                    ASO_BI_QOT_SG_MV FACT
              WHERE CAL.Calendar_id = -1
              AND   FACT.Parent_Resource_grp_id = :l_sg_id_num
              AND   FACT.Time_id = CAL.Time_id
              AND   FACT.Period_type_id = CAL.Period_type_id
              AND   CAL.Report_Date IN (:l_fdcp_date,:l_fdpp_date)
              AND   BITAND(CAL.Record_Type_Id, 1143) = CAL.Record_Type_Id';

              -- When a specific resource is selected
              IF l_sr_id_num IS NOT NULL THEN

                 l_SQLTEXT1 := l_SQLTEXT1 || ' AND FACT.Resource_id = :l_sr_id_num ';

              END IF;
    -- PTD Measures --
 l_SQLTEXT2 :=
              'SELECT FACT.Resource_grp_id ASO_VALUE11,
                      FACT.Resource_id  ASO_VALUE12,
                      (CASE
                         WHEN report_date = :l_asof_date
                         THEN '||l_sec_prefix||'newqot_amnt
                         ELSE NULL
                      END) ASO_VALUE1,
                      (CASE
                         WHEN report_date = :l_asof_date
                         THEN newqot_number
                          ELSE NULL
                      END) ASO_VALUE2,
                      (CASE
                          WHEN report_date = :l_priorasof_date
                          THEN '||l_sec_prefix||'newqot_amnt
                          ELSE NULL
                      END) ASO_VALUE3,
                      (CASE
                         WHEN report_date = :l_priorasof_date
                         THEN newqot_number
                          ELSE NULL
                      END) ASO_VALUE4,
                      (CASE
                          WHEN report_date = :l_asof_date
                          THEN '||l_sec_prefix||'convqot_amnt
                          ELSE NULL
                      END) ASO_VALUE5,
                      (CASE
                          WHEN report_date = :l_asof_date
                          THEN convqot_number
                          ELSE NULL
                      END) ASO_VALUE6,
                      (CASE
                          WHEN report_date = :l_priorasof_date
                          THEN '||l_sec_prefix||'convqot_amnt
                          ELSE NULL
                      END) ASO_VALUE7,
                      (CASE
                          WHEN report_date = :l_priorasof_date
                          THEN convqot_number
                          ELSE NULL
                      END) ASO_VALUE8,
                      (CASE
                          WHEN report_date = :l_asof_date
                          THEN conv_days
                          ELSE NULL
                      END) ASO_VALUE9,
                      (CASE
                          WHEN report_date = :l_priorasof_date
                          THEN conv_days
                          ELSE NULL
                      END) ASO_VALUE10
              FROM  FII_TIME_RPT_STRUCT_V CAL,
                    ASO_BI_QOT_SG_MV FACT
              WHERE CAL.Calendar_id = -1
              AND   FACT.Parent_Resource_grp_id = :l_sg_id_num
              AND   FACT.Time_id = CAL.Time_id
              AND   FACT.Period_type_id = CAL.Period_type_id
              AND   CAL.Report_Date IN (:l_asof_date,:l_priorasof_date)
              AND   BITAND(CAL.Record_Type_Id, :l_record_type_id) = CAL.Record_Type_Id';

              -- When a specific resource is selected
              IF l_sr_id_num IS NOT NULL THEN

                 l_SQLTEXT2 := l_SQLTEXT2 || ' AND FACT.Resource_id = :l_sr_id_num ';

              END IF;

    ---Eliminating the Duplicate Quotes  ---

l_SQLTEXT3 := 'SELECT  Resource_grp_id ASO_VALUE11,
               Resource_id  ASO_VALUE12,
               (CASE
	         WHEN Time_id = :l_fdcp_date_j THEN -1 * '||l_sec_prefix||'openqot_amnt
               END)  ASO_VALUE1,
               (CASE
	        WHEN Time_id = :l_fdcp_date_j THEN -1 * openqot_number
               END)  ASO_VALUE2,
              (CASE
	        WHEN Time_id = :l_fdpp_date_j THEN -1 * '||l_sec_prefix||'openqot_amnt
                END)  ASO_VALUE3,
              (CASE
	        WHEN Time_id = :l_fdpp_date_j THEN -1 * openqot_number
              END) ASO_VALUE4,
             NULL ASO_VALUE5,
             NULL ASO_VALUE6,
             NULL ASO_VALUE7,
             NULL ASO_VALUE8,
             NULL ASO_VALUE9,
             NULL ASO_VALUE10
             FROM  ASO_BI_QOT_SG_MV
             WHERE Parent_Resource_grp_id = :l_sg_id_num
             AND   Period_type_id = 1
             AND   Time_id IN (:l_fdcp_date_j,:l_fdpp_date_j)';

	-- When a specific resource is selected
      IF l_sr_id_num IS NOT NULL THEN
        l_SQLTEXT3 := l_SQLTEXT3 || ' AND Resource_id = :l_sr_id_num ';
      END IF;


  IF l_sr_id_num IS NULL THEN

    -- Query for populating 2nd temp table (grps and resources)
    l_SQLTEXT10 := ' SELECT Temp.ASO_VALUE11 VIEWBYID,
                            Grp.Group_Name VIEWBY,
                            SUM(ASO_VALUE1) ASO_VALUE1,
                            SUM(ASO_VALUE3) ASO_VALUE3,
                            SUM(ASO_VALUE2) ASO_VALUE2,
                            SUM(ASO_VALUE4) ASO_VALUE4,
                            SUM(ASO_VALUE5) ASO_VALUE5,
                            SUM(ASO_VALUE7) ASO_VALUE7,
                            SUM(ASO_VALUE6) ASO_VALUE6,
                            SUM(ASO_VALUE8) ASO_VALUE8,
                            DECODE(SUM(ASO_VALUE6),0,NULL,
                                   SUM(ASO_VALUE9) / SUM(ASO_VALUE6)) ASO_VALUE9,
                            DECODE(SUM(ASO_VALUE8),0,NULL,SUM(ASO_VALUE10) / SUM(ASO_VALUE8)) ASO_VALUE10,
                            ''G''  ASO_ATTRIBUTE1,
                            ''pFunctionName=ASO_BI_SUM_BY_SG&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP&VIEW_BY_NAME=VIEW_BY_ID'' ASO_URL1
                    FROM  ASO_BI_RPT_TMP1 Temp,
                          JTF_RS_GROUPS_TL GRP
                    WHERE Temp.ASO_VALUE11 = Grp.Group_Id
                          AND Grp.Language = USERENV(''LANG'')
                          AND temp.ASO_VALUE12 IS NULL
                    GROUP BY  Temp.ASO_VALUE11,Grp.Group_Name
                    UNION ALL
                    SELECT Temp.ASO_VALUE12  VIEWBYID,
                           Res.Resource_Name VIEWBY,
                           SUM(ASO_VALUE1) ASO_VALUE1,
                           SUM(ASO_VALUE3) ASO_VALUE3,
                           SUM(ASO_VALUE2) ASO_VALUE2,
                           SUM(ASO_VALUE4) ASO_VALUE4,
                           SUM(ASO_VALUE5) ASO_VALUE5,
                           SUM(ASO_VALUE7) ASO_VALUE7,
                           SUM(ASO_VALUE6) ASO_VALUE6,
                           SUM(ASO_VALUE8) ASO_VALUE8,
                           DECODE(SUM(ASO_VALUE6),0,NULL,SUM(ASO_VALUE9) / SUM(ASO_VALUE6)) ASO_VALUE9,
                           DECODE(SUM(ASO_VALUE8),0,NULL,SUM(ASO_VALUE10) / SUM(ASO_VALUE8)) ASO_VALUE10,
                           ''R''  ASO_ATTRIBUTE1,
                           NULL ASO_URL1
                    FROM  ASO_BI_RPT_TMP1 Temp,
                         JTF_RS_RESOURCE_EXTNS_TL RES
                    WHERE Temp.ASO_VALUE12 = Res.Resource_Id
                          AND RES.Language  = USERENV(''LANG'')
                    GROUP BY  Temp.ASO_VALUE12, Res.Resource_Name ';

  ELSE

    -- Query for populating 2nd temp table (only resource chosen)
    l_SQLTEXT10 :=
    'SELECT Temp.ASO_VALUE12 VIEWBYID,
            RES.Resource_Name VIEWBY,
            SUM(ASO_VALUE1) ASO_VALUE1,
            SUM(ASO_VALUE3) ASO_VALUE3,
            SUM(ASO_VALUE2) ASO_VALUE2,
            SUM(ASO_VALUE4) ASO_VALUE4,
            SUM(ASO_VALUE5) ASO_VALUE5,
            SUM(ASO_VALUE7) ASO_VALUE7,
            SUM(ASO_VALUE6) ASO_VALUE6,
            SUM(ASO_VALUE8) ASO_VALUE8,
            DECODE(SUM(ASO_VALUE6),0,NULL,
            SUM(ASO_VALUE9) / SUM(ASO_VALUE6)) ASO_VALUE9,
            DECODE(SUM(ASO_VALUE8),0,NULL,
            SUM(ASO_VALUE10) / SUM(ASO_VALUE8)) ASO_VALUE10,
            ''R''  ASO_ATTRIBUTE1,
            NULL ASO_URL1
    FROM  ASO_BI_RPT_TMP1 Temp,
          JTF_RS_RESOURCE_EXTNS_TL RES
    WHERE Res.Resource_Id = temp.ASO_VALUE12
    AND   Res.Language = USERENV(''LANG'')
    GROUP BY Temp.ASO_VALUE12,  Res.Resource_Name';
  END IF;

    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           aso_bi_qot_util_pvt.write_query(l_SQLTEXT10,' Quote Summary From temp table');
    END IF;

  /* Mappings...

     ASO_VALUE1  - Total Amount
     ASO_CHANGE1 - Change
     ASO_VALUE2  - Total Number
     ASO_CHANGE2 - Change
     ASO_VALUE3  - Converted Amount
     ASO_CHANGE3 - Change
     ASO_VALUE4  - Converted Number
     ASO_CHANGE4 - Change
     ASO_VALUE5  - Converted Amount %
     ASO_CHANGE5 - Change
     ASO_VALUE6  - Converted Count %
     ASO_CHANGE6 - Change
     ASO_VALUE7  - Average Days to convert
     ASO_CHANGE7 - Change
     ASO_VALUE8  - Prior Value For Conversion Percent Amount Graph
     ASO_VALUE9  - Current Value For Conversion Percent Amount Graph
     ASO_VALUE10 - Prior Value For Conversion Percent Number Graph
     ASO_VALUE11 - Current Value For Conversion Percent Number Graph
     ASO_VALUE12 - Prior Total Amount
     ASO_VALUE13 - Prior Converted Amount
     ASO_VALUE14 - Prior Conversion Percent - Amount
     ASO_VALUE15 - Prior Average days to convert
     ASO_GRAND_VALUE1 - ASO_GRAND_VALUE11 - Corresponding Grand Totals

  */

  l_SQLTEXT11 := 'SELECT VIEWBYID,
    VIEWBY,
    ASO_VALUE1,
    ASO_VALUE1 ASO_VALUE16,
    DECODE(ASO_VALUE3,0,NULL,
      ((ASO_VALUE1 - ASO_VALUE3) * 100 ) / ABS(ASO_VALUE3)) ASO_CHANGE1,
    DECODE(ASO_VALUE2,0,NULL,ASO_VALUE2) ASO_VALUE2,
    DECODE(ASO_VALUE4,0,NULL,
      ((ASO_VALUE2 - ASO_VALUE4) *100) / ABS(ASO_VALUE4))  ASO_CHANGE2,
    ASO_VALUE5  ASO_VALUE3,
    ASO_VALUE5  ASO_VALUE17,
    DECODE(ASO_VALUE7,0,NULL,
      ((ASO_VALUE5 - ASO_VALUE7) * 100 ) / ABS(ASO_VALUE7)) ASO_CHANGE3,
    ASO_VALUE6  ASO_VALUE4,
    DECODE(ASO_VALUE8,0,NULL,
      ((ASO_VALUE6 - ASO_VALUE8) *100) / ABS(ASO_VALUE8))  ASO_CHANGE4,
    DECODE(ASO_VALUE1,0,NULL,
      (ASO_VALUE5/ABS(ASO_VALUE1))*100) ASO_VALUE5,
    DECODE(ASO_VALUE1,0,NULL,
      (ASO_VALUE5/ABS(ASO_VALUE1))*100) ASO_VALUE18,
    (DECODE(ASO_VALUE1,0,NULL,
      (ASO_VALUE5/ABS(ASO_VALUE1))*100) - DECODE(ASO_VALUE3,0,NULL,
      (ASO_VALUE7/ABS(ASO_VALUE3))*100)) ASO_CHANGE5,
    DECODE(ASO_VALUE2,0,NULL,
      (ASO_VALUE6/ABS(ASO_VALUE2))*100) ASO_VALUE6,
    (DECODE(ASO_VALUE2,0,NULL,
      (ASO_VALUE6/ABS(ASO_VALUE2))*100) - DECODE(ASO_VALUE4,0,NULL,
      (ASO_VALUE8/ABS(ASO_VALUE4))*100))   ASO_CHANGE6,
    ASO_VALUE9 ASO_VALUE7,
    ASO_VALUE9 ASO_VALUE19,
    DECODE(ASO_VALUE10,0,NULL,
    (ASO_VALUE9 - ASO_VALUE10)/ASO_VALUE10)*100 ASO_CHANGE7,
    DECODE(ASO_VALUE3,0,NULL,
    (ASO_VALUE7/ABS(ASO_VALUE3))*100) ASO_VALUE8,
    DECODE(ASO_VALUE1,0,NULL,
    (ASO_VALUE5/ABS(ASO_VALUE1))*100) ASO_VALUE9,
    DECODE(ASO_VALUE4,0,NULL,
      (ASO_VALUE8/ABS(ASO_VALUE4))*100) ASO_VALUE10,
    DECODE(ASO_VALUE2,0,NULL,
      (ASO_VALUE6/ABS(ASO_VALUE2))*100) ASO_VALUE11,
    ASO_VALUE3   ASO_VALUE12,
    ASO_VALUE7  ASO_VALUE13,
    DECODE(ASO_VALUE3,0,NULL,
      (ASO_VALUE7/ABS(ASO_VALUE3))*100) ASO_VALUE14,
    ASO_VALUE10 ASO_VALUE15,
    (SUM(ASO_VALUE1) OVER())  ASO_GRAND_VALUE1,
    DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,
        ((SUM(ASO_VALUE1) OVER() - SUM(ASO_VALUE3) OVER()) * 100)
        /ABS(SUM(ASO_VALUE3) OVER())) ASO_GRAND_CHANGE1,
    SUM(DECODE(ASO_VALUE2,0,NULL,ASO_VALUE2)) OVER() ASO_GRAND_VALUE2,
    DECODE(SUM(ASO_VALUE4) OVER (),0,NULL,
          ((SUM(ASO_VALUE2) OVER() - SUM(ASO_VALUE4) OVER()) * 100)
       /ABS(SUM(ASO_VALUE4) OVER())) ASO_GRAND_CHANGE2,
    (SUM(ASO_VALUE5) OVER()) ASO_GRAND_VALUE3,
    DECODE(SUM(ASO_VALUE7) OVER(),0,NULL,
        ((SUM(ASO_VALUE5) OVER() - SUM(ASO_VALUE7) OVER()) * 100)
        /ABS(SUM(ASO_VALUE7) OVER()))  ASO_GRAND_CHANGE3,
    SUM(ASO_VALUE6) OVER() ASO_GRAND_VALUE4,
    DECODE(SUM(ASO_VALUE8) OVER (),0,NULL,
          ((SUM(ASO_VALUE6) OVER() - SUM(ASO_VALUE8) OVER()) * 100)
          /ABS(SUM(ASO_VALUE8) OVER())) ASO_GRAND_CHANGE4,
    DECODE(SUM(ASO_VALUE1) OVER (),0,NULL,
      ((SUM(ASO_VALUE5) OVER())/ABS((SUM(ASO_VALUE1) OVER())))*100)
      ASO_GRAND_VALUE5,
    DECODE(SUM(ASO_VALUE1) OVER (),0,NULL,
      ((SUM(ASO_VALUE5) OVER())/ABS((SUM(ASO_VALUE1) OVER())))*100) -
    DECODE(SUM(ASO_VALUE3) OVER (),0,NULL,
      ((SUM(ASO_VALUE7) OVER())/ABS((SUM(ASO_VALUE3) OVER())))*100)
      ASO_GRAND_CHANGE5,
    DECODE(SUM(ASO_VALUE2) OVER (),0,NULL,
      ((SUM(ASO_VALUE6) OVER())/ABS((SUM(ASO_VALUE2) OVER())))*100)
      ASO_GRAND_VALUE6,
    DECODE(SUM(ASO_VALUE2) OVER (),0,NULL,
      ((SUM(ASO_VALUE6) OVER())/ABS((SUM(ASO_VALUE2) OVER())))*100) -
    DECODE(SUM(ASO_VALUE4) OVER (),0,NULL,
     ((SUM(ASO_VALUE8) OVER())/ABS((SUM(ASO_VALUE4) OVER())))*100)
     ASO_GRAND_CHANGE6,
    DECODE(SUM(ASO_VALUE6) OVER(),0,NULL,
    (SUM(ASO_VALUE9*ASO_VALUE6) OVER())/(SUM(ASO_VALUE6) OVER()))
    ASO_GRAND_VALUE7,
    ((DECODE(SUM(ASO_VALUE6) OVER(),0,NULL,
    (SUM(ASO_VALUE9*ASO_VALUE6) OVER())/(SUM(ASO_VALUE6) OVER())) -
    DECODE(SUM(ASO_VALUE8) OVER(),0,NULL,
    (SUM(ASO_VALUE10*ASO_VALUE8) OVER())/(SUM(ASO_VALUE8) OVER())))*100/
    DECODE(DECODE(SUM(ASO_VALUE8) OVER(),0,NULL,
    (SUM(ASO_VALUE10*ASO_VALUE8) OVER())/(SUM(ASO_VALUE8) OVER())),0,NULL,
    DECODE(SUM(ASO_VALUE8) OVER(),0,NULL,
    (SUM(ASO_VALUE10*ASO_VALUE8) OVER())/(SUM(ASO_VALUE8) OVER()))  ))
    ASO_GRAND_CHANGE7,
    (SUM(ASO_VALUE3) OVER()) ASO_GRAND_VALUE8,
    (SUM(ASO_VALUE7) OVER()) ASO_GRAND_VALUE9,
    DECODE(SUM(ASO_VALUE3) OVER (),0,NULL,
      ((SUM(ASO_VALUE7) OVER())/ABS((SUM(ASO_VALUE3) OVER())))*100)
      ASO_GRAND_VALUE10,
    DECODE(SUM(ASO_VALUE8) OVER(),0,NULL,
    (SUM(ASO_VALUE10*ASO_VALUE8) OVER())/(SUM(ASO_VALUE8) OVER()))
    ASO_GRAND_VALUE11,
    (SUM(ASO_VALUE1) OVER()) ASO_GRAND_VALUE12,
    (SUM(ASO_VALUE5) OVER()) ASO_GRAND_VALUE13,
    DECODE(SUM(ASO_VALUE1) OVER (),0,NULL,
      ((SUM(ASO_VALUE5) OVER())/ABS((SUM(ASO_VALUE1) OVER())))*100) ASO_GRAND_VALUE14,
    DECODE(SUM(ASO_VALUE6) OVER(),0,NULL,
      (SUM(ASO_VALUE9*ASO_VALUE6) OVER())/(SUM(ASO_VALUE6) OVER())) ASO_GRAND_VALUE15,
    VIEWBYID  ASO_RES_GRP_ID,
    ASO_ATTRIBUTE1 ASO_RES_OR_GRP,
    ASO_URL1
    FROM  ASO_BI_RPT_TMP2';


   --The where clause filters those rows which have
   --total quote measure 0 and both cur conv count
   --and prev conv count NULL

   l_SQLTEXT11 := 'SELECT * FROM ('||l_SQLTEXT11||')
                                 WHERE
                                 NOT ( ASO_VALUE2 = 0
                                 AND ASO_VALUE6 IS NULL
                                 AND ASO_VALUE8 IS NULL) ';

    IF 'VIEWBY' = l_orderBy THEN
       l_SQLTEXT11 := l_SQLTEXT11 ||' ORDER BY UPPER(VIEWBY) '|| l_sortBy;
    ELSE
       l_SQLTEXT11 := l_SQLTEXT11 ||' ORDER BY TO_NUMBER('|| l_orderBy ||') '|| l_sortBy ||' NULLS LAST ';
    END IF;

  -- Clean up the tables
  DELETE FROM ASO_BI_RPT_TMP1;
  DELETE FROM ASO_BI_RPT_TMP2;

  -- Insert of Quotes
  l_sql_stmnt1 := l_SQLTEXT1;
  l_sql_stmnt2 := l_SQLTEXT2;
  l_sql_stmnt3 := l_SQLTEXT3;

  --  Temp1 table mappings
  --  VIEWBYID, -- party_id
  --  ASO_VALUE1, --cur_val_total,
  --  ASO_VALUE2, --cur_num_total,
  --  ASO_VALUE3, --prev_val_total,
  --  ASO_VALUE4, --prev_num_total,
  --  ASO_VALUE5, --cur_val_conv,
  --  ASO_VALUE6, --cur_num_conv,
  --  ASO_VALUE7, --prev_val_conv,
  --  ASO_VALUE8  --prev_num_conv
  --  ASO_VALUE9, --cur_conv_days,
  --  ASO_VALUE10  --prev_conv_days
  l_insert_stmnt := 'INSERT INTO ASO_BI_RPT_TMP1(
                   ASO_VALUE11,
                   ASO_VALUE12,
                   ASO_VALUE1,
                   ASO_VALUE2,
                   ASO_VALUE3,
                   ASO_VALUE4,
                   ASO_VALUE5,
                   ASO_VALUE6,
                   ASO_VALUE7,
                   ASO_VALUE8,
                   ASO_VALUE9,
                   ASO_VALUE10
                   )';

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT ,
                    MODULE => l_module_name,
                    MESSAGE => ' Begining insertion into ASO_BI_RPT_TMP1 ..');
  END IF;

  BEGIN

  IF l_sr_id_num IS NULL -- Sales group is selected from LOV
  THEN
   BEGIN
     -- ITD Measures --
     EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
          USING
             l_fdcp_date
            ,l_fdcp_date
            ,l_fdpp_date
            ,l_fdpp_date
            ,l_sg_id_num
            ,l_fdcp_date
            ,l_fdpp_date;
      -- PTD Measures --
      EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
          USING
             l_asof_date
            ,l_asof_date
            ,l_priorasof_date
            ,l_priorasof_date
            ,l_asof_date
            ,l_asof_date
            ,l_priorasof_date
            ,l_priorasof_date
            ,l_asof_date
            ,l_priorasof_date
            ,l_sg_id_num
            ,l_asof_date
            ,l_priorasof_date
            ,l_record_type_id;

      --  Elimination of duplicate Quotes in Calculation of Total Quotes--
         EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt3
          USING
             l_fdcp_date_j
            ,l_fdcp_date_j
            ,l_fdpp_date_j
            ,l_fdpp_date_j
            ,l_sg_id_num
            ,l_fdcp_date_j
           ,l_fdpp_date_j;
  END;

     ELSE
BEGIN
  -- ITD Measures --
 EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
    USING
       l_fdcp_date
      ,l_fdcp_date
      ,l_fdpp_date
      ,l_fdpp_date
      ,l_sg_id_num
      ,l_fdcp_date
      ,l_fdpp_date
      ,l_sr_id_num ;

  --  PTD Measures --
  EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
    USING
        l_asof_date
       ,l_asof_date
       ,l_priorasof_date
       ,l_priorasof_date
       ,l_asof_date
       ,l_asof_date
       ,l_priorasof_date
       ,l_priorasof_date
       ,l_asof_date
       ,l_priorasof_date
       ,l_sg_id_num
       ,l_asof_date
       ,l_priorasof_date
       ,l_record_type_id
       ,l_sr_id_num;

      --  Elimination of duplicate Quotes in Calculation of Total Quotes --
   EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt3
    USING
       l_fdcp_date_j
      ,l_fdcp_date_j
      ,l_fdpp_date_j
      ,l_fdpp_date_j
      ,l_sg_id_num
      ,l_fdcp_date_j
      ,l_fdpp_date_j
      ,l_sr_id_num;
END;
END IF;

  COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_ERROR ,
                    MODULE => l_module_name,
                    MESSAGE => 'Error while inserting into ASO_BI_RPT_TMP1'
                                || sqlerrm);
      END IF;
    RAISE;
  END;

  --  Temp2 table mappings
  --  VIEWBY, -- party_id
  --  ASO_VALUE1, --cur_val_total,
  --  ASO_VALUE2, --cur_num_total,
  --  ASO_VALUE3, --prev_val_total,
  --  ASO_VALUE4, --prev_num_total,
  --  ASO_VALUE5, --cur_val_conv,
  --  ASO_VALUE6, --cur_num_conv,
  --  ASO_VALUE7, --prev_val_conv,
  --  ASO_VALUE8  --prev_num_conv,
  --  ASO_ATTRIBUTE1 -- Resource 'R' or Group 'G' ,
  --  ASO_URL1  -- URL String for Drill down Report

  l_insert_stmnt :=
    'INSERT INTO ASO_BI_RPT_TMP2 (
                  VIEWBYID,
                  VIEWBY,
                  ASO_VALUE1,
                  ASO_VALUE3,
                  ASO_VALUE2,
                  ASO_VALUE4,
                  ASO_VALUE5,
                  ASO_VALUE7,
                  ASO_VALUE6,
                  ASO_VALUE8,
                  ASO_VALUE9,
                  ASO_VALUE10,
                  ASO_ATTRIBUTE1,
                  ASO_URL1
                  )';

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT ,
                    MODULE => l_module_name,
                    MESSAGE => ' Begining insertion into ASO_BI_RPT_TMP2 ..');
  END IF;

  BEGIN
    IF l_sr_id_num IS NULL THEN
       EXECUTE IMMEDIATE l_insert_stmnt || l_SQLTEXT10;

    ELSE
       EXECUTE IMMEDIATE l_insert_stmnt || l_SQLTEXT10;


    END IF;
    COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_ERROR ,
                    MODULE => l_module_name,
                    MESSAGE => 'Error while inserting into ASO_BI_RPT_TMP2'
                                || sqlerrm);
      END IF;
    RAISE;
  END;


  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT ,
                    MODULE => l_module_name,
                    MESSAGE => ' Construction of query string of length : '
                      || length(l_SQLTEXT11));
  END IF;

  x_custom_sql := l_SQLTEXT11;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value:= 'ORGANIZATION+JTF_ORG_SALES_GROUP';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;

  x_custom_output.Extend();
  x_custom_output(1) := l_custom_rec;

END BY_SALESGRP_SQL;

-- Quote summary by product category

PROCEDURE BY_PRODUCTCAT_SQL(p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
AS
  l_orderBy             VARCHAR2(200);
   l_orderby_cluase     VARCHAR2(2000);
  l_sortBy              VARCHAR2(200);
  l_viewby              VARCHAR2(100);
  l_product_id          VARCHAR2(200);
  l_prodcat_id          VARCHAR2(200);
  l_period_type         VARCHAR2(3200);
  l_comparision_type    VARCHAR2(3200);
  l_module_name         VARCHAR2(100);
  l_outer_select        VARCHAR2(32000);
  l_asof_date           DATE;
  l_priorasof_date      DATE;
  l_sysdate             DATE;
  l_fdcp_date           DATE;
  l_fdpp_date           DATE;
  l_fdcp_date_j         NUMBER;
  l_fdpp_date_j         NUMBER;
  l_record_type_id      NUMBER;
  l_conv_rate           NUMBER;
  l_sg_id_num           NUMBER;
  l_sr_id_num           NUMBER;
  l_url_req             VARCHAR2(1);
  rec_index             NUMBER;
  l_custom_rec          BIS_QUERY_ATTRIBUTES;

BEGIN

  --Initialize
  l_module_name := 'ASO_BI_QOT_SUMMRY_PVT.BY_PRODUCTCAT_SQL';
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

  -- Set up the parameters
  ASO_BI_QOT_UTIL_PVT.GET_PAGE_PARAMS(p_pmv_parameters => p_pmv_parameters,
                                      x_conv_rate => l_conv_rate,
                                      x_record_type_id => l_record_type_id,
                                      x_sysdate => l_sysdate,
                                      x_sg_id => l_sg_id_num,
                                      x_sr_id => l_sr_id_num,
                                      x_asof_date => l_asof_date,
                                      x_priorasof_date => l_priorasof_date,
                                      x_fdcp_date => l_fdcp_date,
                                      x_fdpp_date => l_fdpp_date,
                                      x_period_type => l_period_type,
                                      x_comparision_type => l_comparision_type,
                                      x_orderBy => l_orderBy,
                                      x_sortBy => l_sortBy,
                                      x_viewby => l_viewby,
                                      x_prodcat_id => l_prodcat_id,
                                      x_product_id => l_product_id);

  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                   MODULE => l_module_name,
                   MESSAGE => ' Entered Proc... ');
  END IF;

  -- Get the julian format
  l_fdcp_date_j := TO_CHAR(l_fdcp_date,'J');
  l_fdpp_date_j := TO_CHAR(l_fdpp_date,'J');

  l_viewby := UPPER(TRIM(l_viewby));

  IF l_product_id IS NOT NULL THEN
    l_product_id := REPLACE(l_product_id, '''');
  END IF;


  IF l_product_id IS NOT NULL THEN
    l_product_id := REPLACE(l_product_id, '''');
  END IF;

  -- Initialize to defaults
  IF l_prodcat_id IS NULL THEN
    l_prodcat_id := 'ALL';
  ELSIF UPPER(l_prodcat_id) = 'ALL' THEN
    l_prodcat_id := 'ALL';
  END IF;

 IF l_prodcat_id IS NOT NULL THEN
    l_prodcat_id := REPLACE(l_prodcat_id, '''');
  END IF;

  IF l_product_id IS NULL THEN
    l_product_id := 'ALL';
  ELSIF UPPER(l_product_id) = 'ALL' THEN
    l_product_id := 'ALL';
  END IF;

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                    MODULE => l_module_name,
                    MESSAGE => '  PC id  :' || l_prodcat_id || ' Prod Id :' || l_product_id ||'  l_sg_id :' || l_sg_id_num
                          || ' l_sr_id :' || l_sr_id_num ||'View By :'|| l_viewby ||'l_record_type_id :' ||l_record_type_id
                          || 'l_fdcp_date_j : '||l_fdcp_date_j|| 'l_fdpp_date_j :'||l_fdpp_date_j );
  END IF;

  DELETE FROM ASO_BI_RPT_TMP1;
  DELETE FROM ASO_BI_RPT_TMP2;

  CASE l_viewby
      WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
         l_url_req := 'Y';
         IF l_prodcat_id = 'ALL' AND l_product_id = 'ALL' THEN

            ASO_BI_QOT_PC_PVT.PCAll(l_conv_rate
                                   ,l_record_type_id
                                   ,l_sg_id_num
                                   ,l_sr_id_num
                                   ,l_asof_date
                                   ,l_priorasof_date
                                   ,l_fdcp_date
                                   ,l_fdpp_date
                                   ,l_fdcp_date_j
                                   ,l_fdpp_date_j);

        ELSIF l_prodcat_id <> 'ALL' AND l_product_id = 'ALL' THEN

              ASO_BI_QOT_PC_PVT.PCSPrA(l_asof_date
                                      ,l_priorasof_date
                                      ,l_fdcp_date
                                      ,l_fdpp_date
                                      ,l_conv_rate
                                      ,l_record_type_id
                                      ,l_sg_id_num
                                      ,l_sr_id_num
                                      ,l_fdcp_date_j
                                      ,l_fdpp_date_j
                                      ,l_prodcat_id);

        ELSIF  l_prodcat_id = 'ALL' AND l_product_id <> 'ALL' THEN

               ASO_BI_QOT_PC_PVT.PCAPrS(l_asof_date
                                       ,l_priorasof_date
                                       ,l_fdcp_date
                                       ,l_fdpp_date
                                       ,l_conv_rate
                                       ,l_record_type_id
                                       ,l_sg_id_num
                                       ,l_sr_id_num
                                       ,l_fdcp_date_j
                                       ,l_fdpp_date_j
                                       ,l_product_id);

        ELSE

               ASO_BI_QOT_PC_PVT.PCSPrS(l_asof_date
                                       ,l_priorasof_date
                                       ,l_fdcp_date
                                       ,l_fdpp_date
                                       ,l_conv_rate
                                       ,l_record_type_id
                                       ,l_sg_id_num
                                       ,l_sr_id_num
                                       ,l_fdcp_date_j
                                       ,l_fdpp_date_j
                                       ,l_prodcat_id
                                       ,l_product_id);


        END IF;

      WHEN 'ITEM+ENI_ITEM' THEN
        l_url_req := 'N';
        IF l_product_id = 'ALL' AND l_prodcat_id = 'ALL' THEN

           ASO_BI_QOT_PC_PVT.PCAllProd(l_conv_rate
                                      ,l_record_type_id
                                      ,l_sg_id_num
                                      ,l_sr_id_num
                                      ,l_fdcp_date_j
                                      ,l_fdpp_date_j
                                      ,l_asof_date
                                      ,l_priorasof_date
                                      ,l_fdcp_date
                                      ,l_fdpp_date);

        ELSIF l_product_id <> 'ALL' AND l_prodcat_id = 'ALL'THEN

              ASO_BI_QOT_PC_PVT.PCAPrSProd(l_asof_date
                                          ,l_priorasof_date
                                          ,l_fdcp_date
                                          ,l_fdpp_date
                                          ,l_conv_rate
                                          ,l_record_type_id
                                          ,l_sg_id_num
                                          ,l_sr_id_num
                                          ,l_fdcp_date_j
                                          ,l_fdpp_date_j
                                          ,l_product_id);

        ELSIF l_product_id = 'ALL' AND l_prodcat_id <> 'ALL'THEN

              ASO_BI_QOT_PC_PVT.PCSPrAProd(l_asof_date
                                          ,l_priorasof_date
                                          ,l_fdcp_date
                                          ,l_fdpp_date
                                          ,l_conv_rate
                                          ,l_record_type_id
                                          ,l_sg_id_num
                                          ,l_sr_id_num
                                          ,l_fdcp_date_j
                                          ,l_fdpp_date_j
                                          ,l_prodcat_id);

        ELSE

              ASO_BI_QOT_PC_PVT.PCSPrSProd(l_asof_date
                                          ,l_priorasof_date
                                          ,l_fdcp_date
                                          ,l_fdpp_date
                                          ,l_conv_rate
                                          ,l_record_type_id
                                          ,l_sg_id_num
                                          ,l_sr_id_num
                                          ,l_fdcp_date_j
                                          ,l_fdpp_date_j
                                          ,l_prodcat_id
                                          ,l_product_id);


        END IF;

      ELSE
        NULL;

  END CASE;

  /* Mappings...
  ASO_VALUE1  - Total
  ASO_CHANGE1 - Change
  ASO_VALUE2  - Count
  ASO_CHANGE2 - Change
  ASO_VALUE3  - Conv Quote Amount
  ASO_CHANGE3 - Change
  ASO_VALUE4  - Conv Quote Count
  ASO_CHANGE4 - Change
  ASO_VALUE5  - Conv Amount %
  ASO_CHANGE5 - Change
  ASO_VALUE6  - Conv Count %
  ASO_CHANGE6 - Change
  ASO_VALUE7  - Conv Amount % Graph Current
  ASO_VALUE8  - Conv Amount % Graph Prior
  ASO_VALUE9  - Conv Count % Graph Current
  ASO_VALUE10 - Conv Count % Graph Prior
  */

  l_outer_select := 'SELECT ASO_ATTRIBUTE1 VIEWBYID,
                            VIEWBY,
                            ASO_URL1 ASO_ATTRIBUTE3,
                            ASO_VALUE1
                            ,DECODE(ASO_VALUE3,0,NULL,((ASO_VALUE1 - ASO_VALUE3) * 100)
                            / ABS(ASO_VALUE3)) ASO_CHANGE1
                            ,DECODE(ASO_VALUE2,0,NULL,ASO_VALUE2) ASO_VALUE2
                            ,DECODE(ASO_VALUE4,0,NULL,((ASO_VALUE2 - ASO_VALUE4) * 100)
                            / ABS(ASO_VALUE4)) ASO_CHANGE2
                            ,ASO_VALUE5 ASO_VALUE3
                            ,DECODE(ASO_VALUE7,0,NULL,((ASO_VALUE5 - ASO_VALUE7) * 100)
                            / ABS(ASO_VALUE7)) ASO_CHANGE3
                            ,ASO_VALUE6 ASO_VALUE4
                            ,DECODE(ASO_VALUE8,0,NULL,((ASO_VALUE6 - ASO_VALUE8) * 100)
                            / ABS(ASO_VALUE8)) ASO_CHANGE4
                            ,DECODE(ASO_VALUE1,0,NULL,(ASO_VALUE5/ASO_VALUE1) * 100) ASO_VALUE5
                            ,(DECODE(ASO_VALUE1,0,NULL,(ASO_VALUE5/ASO_VALUE1) * 100) -
                                DECODE(ASO_VALUE3,0,NULL,(ASO_VALUE7/ASO_VALUE3) * 100)) ASO_CHANGE5
                            ,DECODE(ASO_VALUE2,0,NULL,(ASO_VALUE6/ASO_VALUE2) * 100) ASO_VALUE6
                            ,(DECODE(ASO_VALUE2,0,NULL,(ASO_VALUE6/ASO_VALUE2) * 100) -
                              DECODE(ASO_VALUE4,0,NULL,(ASO_VALUE8/ASO_VALUE4) * 100)) ASO_CHANGE6
                            ,SUM(ASO_VALUE1) OVER() ASO_GRAND_VALUE1
                            ,DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,((SUM(ASO_VALUE1) OVER() - SUM(ASO_VALUE3) OVER())  * 100 )
                            / ABS(SUM(ASO_VALUE3) OVER())) ASO_GRAND_CHANGE1
                            ,SUM(DECODE(ASO_VALUE2,0,NULL,ASO_VALUE2)) OVER() ASO_GRAND_VALUE2
                            ,DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,((SUM(ASO_VALUE2) OVER() - SUM(ASO_VALUE4) OVER()) * 100 )
                            / ABS(SUM(ASO_VALUE4) OVER())) ASO_GRAND_CHANGE2
                            ,SUM(ASO_VALUE5) OVER() ASO_GRAND_VALUE3
                            ,DECODE(SUM(ASO_VALUE7) OVER(),0,NULL,((SUM(ASO_VALUE5) OVER() - SUM(ASO_VALUE7) OVER()) * 100 )
                            / ABS(SUM(ASO_VALUE7) OVER())) ASO_GRAND_CHANGE3
                            ,SUM(ASO_VALUE6) OVER() ASO_GRAND_VALUE4
                            ,DECODE(SUM(ASO_VALUE8) OVER(),0,NULL,((SUM(ASO_VALUE6) OVER() - SUM(ASO_VALUE8) OVER()) * 100 )
                            / ABS(SUM(ASO_VALUE8) OVER())) ASO_GRAND_CHANGE4
                            ,DECODE(SUM(ASO_VALUE1) OVER(),0,NULL,(SUM(ASO_VALUE5) OVER()/SUM(ASO_VALUE1) OVER()) * 100)
                              ASO_GRAND_VALUE5
                            ,DECODE(SUM(ASO_VALUE1) OVER(),0,NULL,(SUM(ASO_VALUE5) OVER()/SUM(ASO_VALUE1) OVER()) * 100) -
                             DECODE(SUM(ASO_VALUE3) OVER(),0,NULL,(SUM(ASO_VALUE7) OVER()/SUM(ASO_VALUE3) OVER()) * 100)
                              ASO_GRAND_CHANGE5
                            ,DECODE(SUM(ASO_VALUE2) OVER(),0,NULL,(SUM(ASO_VALUE6) OVER()/SUM(ASO_VALUE2) OVER()) * 100)
                              ASO_GRAND_VALUE6
                            ,DECODE(SUM(ASO_VALUE2) OVER(),0,NULL,(SUM(ASO_VALUE6) OVER()/SUM(ASO_VALUE2) OVER()) * 100) -
                             DECODE(SUM(ASO_VALUE4) OVER(),0,NULL,(SUM(ASO_VALUE8) OVER()/SUM(ASO_VALUE4) OVER())* 100)
                              ASO_GRAND_CHANGE6
                            , DECODE('''||l_url_req||''',''Y'',ASO_URL1,NULL) ASO_URL1
                            ,DECODE(ASO_VALUE3,0,NULL,(ASO_VALUE7/ASO_VALUE3) * 100) ASO_VALUE8
                            ,DECODE(ASO_VALUE1,0,NULL,(ASO_VALUE5/ASO_VALUE1) * 100) ASO_VALUE7
                            ,DECODE(ASO_VALUE4,0,NULL,(ASO_VALUE8/ASO_VALUE4) * 100) ASO_VALUE10
                            ,DECODE(ASO_VALUE2,0,NULL,(ASO_VALUE6/ASO_VALUE2) * 100) ASO_VALUE9
                            FROM ASO_BI_RPT_TMP1';

    l_outer_select := 'SELECT * FROM ('||l_outer_select||')
                               WHERE NOT(ASO_VALUE2 = 0
                               AND ASO_VALUE6 IS NULL
                               AND ASO_VALUE8 IS NULL)';

    IF 'VIEWBY' = l_orderBy THEN
       l_outer_select := l_outer_select ||' ORDER BY VIEWBY '|| l_sortBy ||' NULLS LAST ';
    ELSE
       IF INSTR(l_orderBy,'ATTRIBUTE3') > 0 THEN
          l_orderby_cluase :=l_orderBy||' '||l_sortBy;
       ELSE
         l_orderby_cluase :='TO_NUMBER('|| l_orderBy||') '||l_sortBy;
       END IF;
       l_outer_select := l_outer_select ||' ORDER BY '||l_orderby_cluase||' NULLS LAST ';
    END IF;

    l_outer_select := REPLACE(l_outer_select,'  ',' ');
    l_outer_select := REPLACE(l_outer_select,'  ',' ');

    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       aso_bi_qot_util_pvt.write_query(l_outer_select,'Front end Query returned to PMV :');
    END IF;

    -- Return the values
    x_custom_sql := l_outer_select;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR ,
                       MODULE => l_module_name,
                       MESSAGE => 'Error while executing the procedure '|| SQLERRM);
    END IF;
    RAISE;
END BY_PRODUCTCAT_SQL;

PROCEDURE BY_DISCOUNT_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           )
AS
  l_SQLTEXT1            VARCHAR2(32000);
  l_insert_stmnt        VARCHAR2(32000);
  l_orderBy             VARCHAR2(200);
  l_sortBy              VARCHAR2(200);
  l_period_type         VARCHAR2(3200);
  l_comparision_type    VARCHAR2(3200);
  l_status              VARCHAR2(10000);
  l_query               VARCHAR2(10000);
  l_module_name         VARCHAR2(100);
  l_insert_string       varchar2(32000);
  l_query_string        varchar2(32000);
  l_query_string1       varchar2(32000);
  l_query_string2       varchar2(32000);
  l_query_string3       varchar2(32000);
  l_viewby              VARCHAR2(100);
  l_product_id          VARCHAR2(200);
  l_prodcat_id          VARCHAR2(200);
  l_sec_prefix		VARCHAR2(100);
  l_asof_date           DATE;
  l_priorasof_date      DATE;
  l_sysdate             DATE;
  l_fdcp_date           DATE;
  l_fdpp_date           DATE;
  l_conv_rate           NUMBER;
  l_sg_id_num           NUMBER;
  l_sr_id_num           NUMBER;
  l_record_type_id      NUMBER;
  l_bind_ctr            NUMBER;
  l_fdcp_date_j         NUMBER;
  l_fdpp_date_j         NUMBER;
  rec_index             NUMBER := 0;
  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_bucket_rec          bis_bucket_pub.BIS_BUCKET_REC_TYPE;
  l_error_tbl           bis_utilities_pub.ERROR_TBL_TYPE;

BEGIN

  --Initialize
  l_status := ' ';
  l_module_name := 'ASO_BI_QOT_SUMMRY_PVT.BY_DISCOUNT_SQL';
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

  -- Set up the parameters
  ASO_BI_QOT_UTIL_PVT.GET_PAGE_PARAMS(p_pmv_parameters => p_pmv_parameters,
                                    x_conv_rate => l_conv_rate,
                                    x_record_type_id => l_record_type_id,
                                    x_sysdate => l_sysdate,
                                    x_sg_id => l_sg_id_num,
                                    x_sr_id => l_sr_id_num,
                                    x_asof_date => l_asof_date,
                                    x_priorasof_date => l_priorasof_date,
                                    x_fdcp_date => l_fdcp_date,
                                    x_fdpp_date => l_fdpp_date,
                                    x_period_type => l_period_type,
                                    x_comparision_type => l_comparision_type,
                                    x_orderBy => l_orderBy,
                                    x_sortBy => l_sortBy,
                                    x_viewby => l_viewby,
                                    x_prodcat_id => l_prodcat_id,
                                    x_product_id => l_product_id);

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT ,
                    MODULE => l_module_name,
                    MESSAGE => '  Begining to construct query ..');
  END IF;


  -- Get the julian format
  l_fdcp_date_j := TO_CHAR(l_fdcp_date,'J');
  l_fdpp_date_j := TO_CHAR(l_fdpp_date,'J');

  -- 7.0 rup1 changes - secondary Currency uptake. --

  IF l_conv_rate = 0
  THEN l_sec_prefix := 'sec_';
  ELSE
       l_sec_prefix := NULL;
  END IF;

  -- Retrieve record to get bucket labels
  bis_bucket_pub.RETRIEVE_BIS_BUCKET('ASO_DISCOUNT_PERCENT_BUK', l_bucket_rec, l_status, l_error_tbl);

  l_query := 'SELECT  :range1_low rn,
                      :range1_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range2_low rn,
                      :range2_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range3_low rn,
                      :range3_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range4_low rn,
                      :range4_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range5_low rn,
                      :range5_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range6_low rn,
                      :range6_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range7_low rn,
                      :range7_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range8_low rn,
                      :range8_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range9_low rn,
                      :range9_name buk_name
              FROM DUAL
              UNION ALL
              SELECT  :range10_low rn,
                      :range10_name buk_name
              FROM DUAL';

  l_query:='( '||l_query||') '; -- contains the code to do the outer join

  --A1 => CURRENT TOTAL QUOTE VALUE
  --A2 => CURRENT TOTAL QUOTE COUNT
  --A3 => PREVIOUS TOTAL QUOTE VALUE
  --A4 => PREVIOUS TOTAL QUOTE COUNT
  --A5 => CURRENT CONVERTED VALUE
  --A6 => CURRENT CONVERTED COUNT
  --A7 => PREVIOUS CONVERTED VALUE
  --A8 => PREVIOUS CONVERTED COUNT

   -- ITD Measures --
   l_query_string1 := 'SELECT Low,
                        (CASE
                            WHEN report_date = :l_fdcp_date
                            THEN '||l_sec_prefix||'opn_val
                            ELSE NULL
                        END)  ASO_VALUE1,
                        (CASE
                           WHEN report_date = :l_fdcp_date
                           THEN opn_cnt
                           ELSE NULL
                        END) ASO_VALUE2,
                        (CASE
                            WHEN report_date = :l_fdpp_date
                            THEN '||l_sec_prefix||'opn_val
                            ELSE NULL
                        END)  ASO_VALUE3,
                        (CASE
                           WHEN report_date = :l_fdpp_date
                           THEN opn_cnt
                           ELSE NULL
                        END) ASO_VALUE4,
                        NULL  ASO_VALUE5,
                        NULL  ASO_VALUE6,
                        NULL  ASO_VALUE7,
                        NULL  ASO_VALUE8
            FROM  FII_TIME_RPT_STRUCT_V CAL,
                  ASO_BI_QOT_DISC_MV  FACT
            WHERE   CAL.Calendar_id = -1
              AND   FACT.Resource_grp_id = :l_sg_id_num
              AND   FACT.Time_id = CAL.Time_id
              AND   FACT.Period_type_id = CAL.Period_type_id
              AND   CAL.Report_Date IN (:l_fdcp_date,:l_fdpp_date)
              AND   BITAND(CAL.Record_Type_Id, 1143) = CAL.Record_Type_Id';

    --Handle the resource selection part
    IF l_sr_id_num IS NULL -- Resource Group is selected
    THEN
      l_query_string1 := l_query_string1  || ' AND FACT.Resource_id IS NULL ';
    ELSE
      l_query_string1 := l_query_string1  || ' AND FACT.Resource_id = :l_sr_id_num ';
    END IF;

     -- PTD Measures --

     l_query_string2 := 'SELECT Low,
                        (CASE
                           WHEN report_date = :l_asof_date
                           THEN '||l_sec_prefix||'new_val
                           ELSE NULL
                        END)  ASO_VALUE1,
                        (CASE
                           WHEN report_date = :l_asof_date
                           THEN new_cnt
                           ELSE NULL
                        END) ASO_VALUE2,
                        (CASE
                           WHEN report_date = :l_priorasof_date
                           THEN '||l_sec_prefix||'new_val
                           ELSE NULL
                        END)  ASO_VALUE3,
                        (CASE
                           WHEN report_date = :l_priorasof_date
                           THEN new_cnt
                           ELSE NULL
                        END) ASO_VALUE4,
                        (CASE
                           WHEN report_date = :l_asof_date
                           THEN '||l_sec_prefix||'conv_val
                           ELSE NULL
                        END)  ASO_VALUE5,
                        (CASE
                           WHEN report_date = :l_asof_date
                           THEN conv_cnt
                           ELSE NULL
                        END) ASO_VALUE6,
                        (CASE
                           WHEN report_date = :l_priorasof_date
                           THEN '||l_sec_prefix||'conv_val
                           ELSE NULL
                        END)  ASO_VALUE7,
                        (CASE
                           WHEN report_date = :l_priorasof_date
                           THEN conv_cnt
                           ELSE NULL
                        END) ASO_VALUE8
            FROM  FII_TIME_RPT_STRUCT_V CAL,
                  ASO_BI_QOT_DISC_MV  FACT
            WHERE   CAL.Calendar_id = -1
              AND   FACT.Resource_grp_id = :l_sg_id_num
              AND   FACT.Time_id = CAL.Time_id
              AND   FACT.Period_type_id = CAL.Period_type_id
              AND   CAL.Report_Date IN (:l_asof_date,:l_priorasof_date)
              AND   BITAND(CAL.Record_Type_Id, :l_record_type_id) = CAL.Record_Type_Id';

    --Handle the resource selection part
    IF l_sr_id_num IS NULL -- Resource Group is selected
    THEN
      l_query_string2 := l_query_string2  || ' AND FACT.Resource_id IS NULL ';
    ELSE
      l_query_string2 := l_query_string2  || ' AND FACT.Resource_id = :l_sr_id_num ';
    END IF;

    -- Eliminating Duplicate Quotes IN calculation of Total Quotes --

   l_query_string3 := 'SELECT  Low,
                      (CASE
		         WHEN Time_id = :l_fdcp_date_j
                         THEN -1 *  '||l_sec_prefix||'opn_val
                       END)ASO_VALUE1,
                       (CASE
		         WHEN Time_id = :l_fdcp_date_j
                         THEN -1 * opn_cnt
                       END)  ASO_VALUE2,
                       (CASE
		           WHEN Time_id = :l_fdpp_date_j
                           THEN -1 *  '||l_sec_prefix||'opn_val
                        END)  ASO_VALUE3,
                       (CASE
                          WHEN Time_id = :l_fdpp_date_j
                          THEN -1 * opn_cnt
                       END) ASO_VALUE4,
                       NULL ASO_VALUE5,
                       NULL ASO_VALUE6,
                       NULL ASO_VALUE7,
                       NULL ASO_VALUE8
                       FROM  ASO_BI_QOT_DISC_MV
                       WHERE Resource_grp_id = :l_sg_id_num
                       AND   Period_type_id = 1
                       AND   Time_id IN (:l_fdcp_date_j,:l_fdpp_date_j)';

      -- Handle the resource selection part
      IF l_sr_id_num IS NULL -- Resource Group is selected
      THEN
        l_query_string3 := l_query_string3  || ' AND Resource_id IS NULL ';
      ELSE
        l_query_string3 := l_query_string3  || ' AND Resource_id = :l_sr_id_num ';
      END IF;

    -- Do a outer group by Range for ITD Mesures
     l_query_string1 := 'SELECT Low,
                              SUM(ASO_VALUE1),
                              SUM(ASO_VALUE2),
                              SUM(ASO_VALUE3),
                              SUM(ASO_VALUE4),
                              SUM(ASO_VALUE5),
                              SUM(ASO_VALUE6),
                              SUM(ASO_VALUE7),
                              SUM(ASO_VALUE8)
                      FROM  ('
                            || l_query_string1 ||
                               ' UNION ALL '||
                               l_query_string2 ||
                               ' UNION ALL '|| l_query_string3||' ) GROUP BY Low';


    IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              aso_bi_qot_util_pvt.write_query(l_query_string,' Query Is :  ');
    END IF;

    -- Clean up the temp table
    DELETE FROM ASO_BI_RPT_TMP1;

    --Populate the temptable
    l_insert_string  := 'INSERT INTO ASO_BI_RPT_TMP1' ||
                  ' (ASO_ATTRIBUTE1, ASO_VALUE1,' ||
                  ' ASO_VALUE2, ASO_VALUE3, ASO_VALUE4,' ||
                  ' ASO_VALUE5, ASO_VALUE6, ASO_VALUE7,' ||
                  ' ASO_VALUE8)' ;

 IF l_sr_id_num IS NULL -- Resource Group is selected
  THEN
      EXECUTE IMMEDIATE  l_insert_string || l_query_string1
      USING
          l_fdcp_date
         ,l_fdcp_date
         ,l_fdpp_date
         ,l_fdpp_date
         ,l_sg_id_num
         ,l_fdcp_date
         ,l_fdpp_date
          ,l_asof_date
          ,l_asof_date
          ,l_priorasof_date
          ,l_priorasof_date
          ,l_asof_date
          ,l_asof_date
          ,l_priorasof_date
          ,l_priorasof_date
          ,l_sg_id_num
          ,l_asof_date
          ,l_priorasof_date
          ,l_record_type_id
          , l_fdcp_date_j
          ,l_fdcp_date_j
          ,l_fdpp_date_j
          ,l_fdpp_date_j
          ,l_sg_id_num
          ,l_fdcp_date_j
          ,l_fdpp_date_j;

     ELSE
        EXECUTE IMMEDIATE l_insert_string || l_query_string1
        USING
          l_fdcp_date
         ,l_fdcp_date
         ,l_fdpp_date
         ,l_fdpp_date
         ,l_sg_id_num
         ,l_fdcp_date
         ,l_fdpp_date
         ,l_sr_id_num
          ,l_asof_date
          ,l_asof_date
          ,l_priorasof_date
          ,l_priorasof_date
          ,l_asof_date
          ,l_asof_date
          ,l_priorasof_date
          ,l_priorasof_date
          ,l_sg_id_num
          ,l_asof_date
          ,l_priorasof_date
          ,l_record_type_id
          ,l_sr_id_num
        , l_fdcp_date_j
          ,l_fdcp_date_j
          ,l_fdpp_date_j
          ,l_fdpp_date_j
          ,l_sg_id_num
          ,l_fdcp_date_j
          ,l_fdpp_date_j
          ,l_sr_id_num    ;
 END IF;

/* Mappings ...
ASO_BUCK_NAME - Discount
ASO_ATTRIBUTE3 - Used to sort the RS
ASO_VALUE1    - Total Amount
ASO_CHANGE1   - Change
ASO_VALUE2    - Total Number
ASO_CHANGE2   - Change
ASO_VALUE3    - Converted Amount
ASO_CHANGE3   - Change
ASO_VALUE4    - Converted Number
ASO_CHANGE4   - Change
ASO_VALUE5    - Conversion Percent - Amount
ASO_CHANGE5   - Change
ASO_VALUE6    - Conversion Percent - Number
ASO_CHANGE6   - Change
ASO_VALUE7    - Conversion Percent - Amount Current
ASO_VALUE8    - Conversion Percent - Amount Prior
ASO_CHANGE7   - Conversion Percent - Number Current
ASO_CHANGE8   - Conversion Percent - Number Prior
ASO_GRAND_VALUE1 ... ASO_GRAND_CHANGE6 - Grand Totals
*/

  --fix for bug7453688 start
 l_query_string := ' SELECT buks.buk_name ASO_ATTRIBUTE1
                    ,to_number(buks.rn) ASO_ATTRIBUTE3
                    ,ASO_VALUE1
                    ,ASO_CHANGE1
                    ,DECODE(ASO_VALUE2,0,NULL,ASO_VALUE2) ASO_VALUE2
                    ,ASO_CHANGE2
                    ,ASO_VALUE3
                    ,ASO_CHANGE3
                    ,ASO_VALUE4
                    ,ASO_CHANGE4
                    ,ASO_VALUE5
                    ,ASO_CHANGE5
                    ,ASO_VALUE6
                    ,ASO_CHANGE6
                    ,ASO_VALUE7
                    ,ASO_VALUE8
                    ,ASO_CHANGE7
                    ,ASO_CHANGE8
                    ,ASO_GRAND_VALUE1
                    ,((ASO_GRAND_VALUE1 - ASO_GRAND_TEMP_VALUE3)*100)/ABS(ASO_GRAND_TEMP_VALUE3)  ASO_GRAND_CHANGE1
                    ,DECODE(ASO_GRAND_VALUE2,0,NULL,ASO_GRAND_VALUE2) ASO_GRAND_VALUE2
                    ,((ASO_GRAND_VALUE2 - ASO_GRAND_TEMP_VALUE4)*100)/ABS(ASO_GRAND_TEMP_VALUE4)  ASO_GRAND_CHANGE2
                    ,ASO_GRAND_VALUE3
                    ,((ASO_GRAND_VALUE3 - ASO_GRAND_TEMP_VALUE7)*100)/ABS(ASO_GRAND_TEMP_VALUE7) ASO_GRAND_CHANGE3
                    ,ASO_GRAND_VALUE4
                    ,((ASO_GRAND_VALUE4 - ASO_GRAND_TEMP_VALUE8)*100)/ABS(ASO_GRAND_TEMP_VALUE8) ASO_GRAND_CHANGE4
                    ,ASO_GRAND_VALUE5
                    ,ASO_GRAND_CHANGE5
                    ,ASO_GRAND_VALUE6
                    ,ASO_GRAND_CHANGE6
                    ,NULL ASO_VALUE10
                  FROM
                    (SELECT
                        ASO_ATTRIBUTE1 low
                        ,ASO_VALUE1 ASO_VALUE1
                        ,DECODE(ASO_VALUE3,0,NULL,((ASO_VALUE1 - ASO_VALUE3)*100)
                        /ABS(ASO_VALUE3)) ASO_CHANGE1
                        ,ASO_VALUE2 ASO_VALUE2
                        ,DECODE(ASO_VALUE4,0,NULL,((ASO_VALUE2 - ASO_VALUE4)*100)
                        /ABS(ASO_VALUE4)) ASO_CHANGE2
                        ,ASO_VALUE5 ASO_VALUE3
                        ,DECODE(ASO_VALUE7,0,NULL,((ASO_VALUE5 - ASO_VALUE7)*100)
                        /ABS(ASO_VALUE7)) ASO_CHANGE3
                        ,ASO_VALUE6 ASO_VALUE4
                        ,DECODE(ASO_VALUE8,0,NULL,((ASO_VALUE6 - ASO_VALUE8)*100)
                        /ABS(ASO_VALUE8)) ASO_CHANGE4
                        ,DECODE(ASO_VALUE1,0,NULL,ASO_VALUE5/ABS(ASO_VALUE1)*100) ASO_VALUE5
                        ,DECODE(ASO_VALUE1,0,NULL,ASO_VALUE5/ABS(ASO_VALUE1)*100)
                        - DECODE(ASO_VALUE3,0,NULL,ASO_VALUE7/ABS(ASO_VALUE3)*100) ASO_CHANGE5
                        ,DECODE(ASO_VALUE2,0,NULL,ASO_VALUE6/ABS(ASO_VALUE2)*100) ASO_VALUE6
                        ,DECODE(ASO_VALUE2,0,NULL,ASO_VALUE6/ABS(ASO_VALUE2)*100)
                        - DECODE(ASO_VALUE4,0,NULL,ASO_VALUE8/ABS(ASO_VALUE4)*100) ASO_CHANGE6
                        ,DECODE(ASO_VALUE1,0,NULL,ASO_VALUE5/ABS(ASO_VALUE1)*100) ASO_VALUE7
                        ,DECODE(ASO_VALUE3,0,NULL,ASO_VALUE7/ABS(ASO_VALUE3)*100) ASO_VALUE8
                        ,DECODE(ASO_VALUE2,0,NULL,ASO_VALUE6/ABS(ASO_VALUE2)*100) ASO_CHANGE7
                        ,DECODE(ASO_VALUE4,0,NULL,ASO_VALUE8/ABS(ASO_VALUE4)*100) ASO_CHANGE8
			,SUM(ASO_VALUE1) OVER() ASO_GRAND_VALUE1
                  ,SUM(ASO_VALUE3) OVER() ASO_GRAND_TEMP_VALUE3
			,SUM(ASO_VALUE2) OVER() ASO_GRAND_VALUE2
                  ,SUM(ASO_VALUE4) OVER() ASO_GRAND_TEMP_VALUE4
                  ,SUM(ASO_VALUE5) OVER() ASO_GRAND_VALUE3
			,SUM(ASO_VALUE7) OVER() ASO_GRAND_TEMP_VALUE7
                  ,SUM(ASO_VALUE6) OVER() ASO_GRAND_VALUE4
			,SUM(ASO_VALUE8) OVER() ASO_GRAND_TEMP_VALUE8
                  ,DECODE(SUM(ASO_VALUE1) OVER (),0,NULL,((SUM(ASO_VALUE5) OVER())/ABS((SUM(ASO_VALUE1) OVER())))*100) ASO_GRAND_VALUE5
			,SUM(DECODE(ASO_VALUE1,0,NULL,ASO_VALUE5/ABS(ASO_VALUE1)*100)
                     - DECODE(ASO_VALUE3,0,NULL,ASO_VALUE7/ABS(ASO_VALUE3)*100)) OVER() ASO_GRAND_CHANGE5
			,DECODE(SUM(ASO_VALUE2) OVER (),0,NULL,((SUM(ASO_VALUE6) OVER())/ABS((SUM(ASO_VALUE2) OVER())))*100) ASO_GRAND_VALUE6
			,SUM(DECODE(ASO_VALUE2,0,NULL,ASO_VALUE6/ABS(ASO_VALUE2)*100)
                        - DECODE(ASO_VALUE4,0,NULL,ASO_VALUE8/ABS(ASO_VALUE4)*100)) OVER() ASO_GRAND_CHANGE6
                     FROM ASO_BI_RPT_TMP1),
                  '|| l_query ||' buks
                  WHERE buks.rn = low(+)
                        AND buks.buk_name IS NOT NULL  ';
--fix for bug7453688 end

  IF 0 <> INSTR(l_orderBy,'ASO_ATTRIBUTE1') THEN
     l_query_string := l_query_string ||' ORDER BY ASO_ATTRIBUTE3 '|| SUBSTR(l_sortBy,INSTR(l_sortBy,')') + 1);
  ELSE
     l_query_string := l_query_string ||' ORDER BY TO_NUMBER('|| l_orderBy ||') '|| l_sortBy ||' NULLS LAST ';
  END IF;

  l_query  := replace(l_query_string,'  ',' ');

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     aso_bi_qot_util_pvt.write_query(l_query,' Outer Query Is :  ');
  END IF;

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT ,
                    MODULE => l_module_name,
                    MESSAGE => ' Construction of query string of length : '
                    || length(l_query));
  END IF;

  x_custom_sql := l_query;

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  --20 binds for range low and range name
  l_custom_rec.attribute_name := ':range1_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range1_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range1_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range1_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range2_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range2_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range2_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range2_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range3_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range3_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range3_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range3_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range4_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range4_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range4_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range4_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range5_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range5_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range5_name';
  l_custom_rec.attribute_value := l_bucket_rec.range5_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range6_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range6_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range6_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range6_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range7_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range7_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range7_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range7_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range8_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range8_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range8_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range8_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range9_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range9_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range9_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range9_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range10_low';
  l_custom_rec.attribute_value :=  l_bucket_rec.range10_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

  l_custom_rec.attribute_name := ':range10_name';
  l_custom_rec.attribute_value :=  l_bucket_rec.range10_name;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  rec_index := rec_index + 1;
  x_custom_output.EXTEND;
  x_custom_output(rec_index) := l_custom_rec;

END BY_DISCOUNT_SQL;


--The Measures, SQL Query Returns  for Top Quotes
--Mappings...
/*ASO_VALUE7		-		Quote Rank
ASO_ATTRIBUTE1		-		Quote Name
ASO_VALUE1		-		Quote Number
ASO_ATTRIBUTE2		-		Customer
ASO_ATTRIBUTE3		-		Quote Creation Date
ASO_ATTRIBUTE4		-		Quote Expiration Date
ASO_VALUE2		-		Quote Age
ASO_ATTRIBUTE5		-		Quote owner
ASO_VALUE3		-		Number of Approvers
ASO_VALUE4		-		Amount
ASO_VALUE5		-		Quote Revision
ASO_VALUE6		-		Quote Revision Percent
ASO_GRAND_VALUE1        -		ASO Grand Value1
ASO_GRAND_VALUE2	-		ASO Grand Value2
ASO_GRAND_VALUE3	-		ASO Grand Value3
*/

PROCEDURE BY_TOPQUOT_SQL(p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                      x_custom_sql     OUT NOCOPY VARCHAR2,
                      x_custom_output  OUT NOCOPY bis_query_attributes_TBL)
AS
  l_inner_sql           VARCHAR2(32000);
  l_insert_stmnt        VARCHAR2(32000);
  l_parameter_name      VARCHAR2(3200);
  l_period_type         VARCHAR2(3200);
  l_comparision_type    VARCHAR2(3200);
  l_orderBy             VARCHAR2(200);
  l_sortBy              VARCHAR2(200);
  l_module_name         VARCHAR2(100);
  l_viewby              VARCHAR2(100);
  l_conv_num            VARCHAR2(500);
  l_conv_amt            VARCHAR2(500);
  l_rank_col            VARCHAR2(30);
  l_sec_prefix		VARCHAR2(100);
  l_currency_type       VARCHAR2(100);
  l_sg_id               VARCHAR2(100);
  l_location            NUMBER;
  l_resource_id         VARCHAR2(100);
  l_rep_r_grp		VARCHAR2(100);
  l_report_by          	VARCHAR2(100);
  l_period_sel          VARCHAR2(100);
  l_period_where        VARCHAR2(100);
  l_period_where1       VARCHAR2(100);
  l_period_ord          VARCHAR2(100);
  l_order              VARCHAR2(100);
  l_cust_url            VARCHAR2(200);
  l_sysdate             DATE;
  l_fdpp_date           DATE;
  l_fdcp_date           DATE;
  l_fdcp_date_j         NUMBER;
  l_fdpp_date_j         NUMBER;
  l_record_type_id      NUMBER;
  l_sg_id_num           NUMBER;
  l_sr_id_num           NUMBER;
  l_conv_rate           NUMBER;
  rec_index             NUMBER := 0;
  l_custom_rec          BIS_QUERY_ATTRIBUTES;

BEGIN

    --Initialize
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
    l_module_name := 'ASO_BI_QOT_SUMMRY_PVT.BY_TOPQUOT_SQL';

    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                   MODULE => l_module_name,
                   MESSAGE => ' Entered Proc... ');
    END IF;

   FOR i IN p_pmv_parameters.FIRST..p_pmv_parameters.LAST
    LOOP
        l_parameter_name := p_pmv_parameters(i).parameter_name ;
        IF( l_parameter_name = 'CURRENCY+FII_CURRENCIES')
        THEN
            l_currency_type :=  p_pmv_parameters(i).parameter_id;
        ELSIF( l_parameter_name = 'PERIOD_TYPE')
        THEN
            l_period_type :=  p_pmv_parameters(i).parameter_value ;
        ELSIF( l_parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
        THEN
            l_sg_id := p_pmv_parameters(i).parameter_id;
        ELSIF ('DIMENSION+DIMENSION1' = p_pmv_parameters(i).parameter_name)
        THEN
           l_report_by := p_pmv_parameters(i).parameter_id;
        ELSIF ('ORDERBY' = l_parameter_name)
        THEN
            l_order := TRIM(p_pmv_parameters(i).parameter_value);
            l_orderBy := TRIM(SUBSTR(l_order,0,INSTR(l_order,' ')));
            l_sortBy := SUBSTR(l_order,INSTR(l_order,' '));
        END IF;
   END LOOP;

  IF  l_report_by = '1' THEN
       l_report_by := 'ALL';
   ELSIF  l_report_by = '2' THEN
        l_report_by := 'OPEN';
   ELSIF  l_report_by = '3' THEN
        l_report_by := 'CONV';
   ELSIF  l_report_by = '4' THEN
        l_report_by := 'EXP';
   ELSE
       l_report_by := 'OPEN';
   END IF;

   IF(INSTR(l_sg_id, '.') > 0) then
      l_location := INSTR(l_sg_id,'.');
      l_sg_id_num := TO_NUMBER(REPLACE(SUBSTR(l_sg_id, l_location + 1),''''));
      l_resource_id := REPLACE(SUBSTR(l_sg_id,1, l_location - 1),'''');
      l_sr_id_num := TO_NUMBER(REPLACE(l_resource_id,'''',''));
   ELSE
     l_sg_id_num  := TO_NUMBER(REPLACE(l_sg_id, ''''));
   END IF;

  IF  INSTR(l_currency_type,'FII_GLOBAL2') > 0
   THEN
     l_sec_prefix := 'sec_';
   END IF;

    IF l_period_type='FII_TIME_ENT_YEAR' THEN
       l_period_sel := ' year_rank AS ASO_VALUE7 ';
       l_period_where := ' AND year=1 AND year_rank < 26 ';
       l_period_where1 := ' AND year=1 ';
       l_period_ord := ' year_rank ';
    ELSIF l_period_type='FII_TIME_ENT_QTR' THEN
       l_period_sel := ' quarter_rank AS ASO_VALUE7';
       l_period_where := ' AND quarter=1 AND quarter_rank < 26 ';
       l_period_where1 := ' AND quarter = 1 ';
       l_period_ord := ' quarter_rank ';
    ELSIF l_period_type='FII_TIME_ENT_PERIOD' THEN
      l_period_sel := ' period_rank AS ASO_VALUE7';
      l_period_where := ' AND period=1 AND period_rank < 26 ';
      l_period_where1 := ' AND period = 1 ';
      l_period_ord := ' period_rank ';
    ELSIF l_period_type='FII_TIME_WEEK' THEN
      l_period_sel := ' week_rank AS ASO_VALUE7';
      l_period_where := ' AND week=1 AND week_rank < 26 ';
      l_period_where1 := ' AND week = 1 ';
      l_period_ord := ' week_rank ';
    END IF;


    IF UPPER( l_report_by) = 'ALL' THEN
        IF  l_sr_id_num IS NULL THEN
          l_period_sel := 'RANK() OVER(PARTITION BY parent_group_id ORDER BY '||l_sec_prefix||'quote_amnt DESC) ASO_VALUE7';
        ELSE
           l_period_sel := 'RANK() OVER(PARTITION BY resource_grp_id, resource_id  ORDER BY '||l_sec_prefix||'quote_amnt DESC) '||
                     '  ASO_VALUE7';
        END IF;

     l_period_where := l_period_where1;
   ELSE
     l_period_where :=l_period_where;
   END IF;

   l_inner_sql :='SELECT '||l_period_sel||' ,QUOTE_NUMBER ASO_VALUE1, QUOTE_NAME  ASO_ATTRIBUTE1,'||
                 '('||l_sec_prefix||'QUOTE_AMNT)  ASO_VALUE4, '||
                 'QUOTE_CREATION_DATE  ASO_ATTRIBUTE3, QUOTE_EXPIRATION_DATE ASO_ATTRIBUTE4, '||
	          'SMRY.RESOURCE_GRP_ID SALES_GROUP_ID, '||
                 '  (select party_name from hz_parties hz  where  hz.party_id  = smry.party_id )  ASO_ATTRIBUTE2,'||
                 ' SMRY.RESOURCE_ID SALESREP_ID, '||
                 '(SMRY.'||l_sec_prefix||'QUOTE_AMNT - SMRY.'||l_sec_prefix||'QUOTE_AMOUNT_FIRST) ASO_VALUE5 ,'||
                 'DECODE(SMRY.'||l_sec_prefix||'QUOTE_AMOUNT_FIRST,0,NULL,'||
                 '(SMRY.'||l_sec_prefix||'QUOTE_AMNT - SMRY.'||l_sec_prefix||'QUOTE_AMOUNT_FIRST)'||
                 '/SMRY.'||l_sec_prefix||'QUOTE_AMOUNT_FIRST) * 100 ASO_VALUE6,'||
                 'QUOTE_AGE ASO_VALUE2,NUM_APPROVERS ASO_VALUE3    '||
                 '  FROM aso_bi_top_qot_mv SMRY  WHERE SMRY.PARENT_GROUP_ID = :l_sg_id_num  ';


  l_inner_sql := l_inner_sql||' AND smry.umarker=:l_rep_r_grp';

  IF UPPER( l_report_by) <> 'ALL' THEN
     l_inner_sql := l_inner_sql || '  AND smry.STATUS = :l_report_by';
  END IF;


   IF l_sr_id_num IS NOT NULL THEN
        l_inner_sql := l_inner_sql||' AND smry.resource_id = :l_sr_id_num  ';
        l_rep_r_grp := 'SLSREP';
   ELSE
          l_rep_r_grp := 'SLSGRP';
   END IF;

    l_inner_sql :=  l_inner_sql || l_period_where;

    IF l_report_by = 'ALL' THEN
      l_inner_sql := ' SELECT ASO_VALUE7,ASO_VALUE1,  ASO_ATTRIBUTE1,  ASO_VALUE4, '||
          ' ASO_ATTRIBUTE3, ASO_ATTRIBUTE4, SUM(ASO_VALUE4) OVER() ASO_GRAND_VALUE1, SALES_GROUP_ID,ASO_ATTRIBUTE2,'||
          'SALESREP_ID,ASO_VALUE5,ASO_VALUE6,'||
          'SUM(ASO_VALUE5) OVER() ASO_GRAND_VALUE2, SUM(ASO_VALUE6) OVER() ASO_GRAND_VALUE3, ASO_VALUE2,ASO_VALUE3  '||
           '  FROM ( '|| l_inner_sql||') WHERE ASO_VALUE7 < 26 ' ;

     ELSE
         l_inner_sql := ' SELECT ASO_VALUE7,ASO_VALUE1,  ASO_ATTRIBUTE1,  ASO_VALUE4, '||
          ' ASO_ATTRIBUTE3, ASO_ATTRIBUTE4, SUM(ASO_VALUE4) OVER()  ASO_GRAND_VALUE1, SALES_GROUP_ID,ASO_ATTRIBUTE2,'||
          'SALESREP_ID,ASO_VALUE5,ASO_VALUE6,'||
          'SUM(ASO_VALUE5) OVER() ASO_GRAND_VALUE2, SUM(ASO_VALUE6) OVER() ASO_GRAND_VALUE3, ASO_VALUE2,ASO_VALUE3  '||
           '  FROM ( '|| l_inner_sql||')' ;

     END IF;

    x_custom_sql := 'SELECT  ASO_VALUE7, ASO_ATTRIBUTE1, ASO_VALUE1, ASO_ATTRIBUTE2,'||
                   ' ASO_ATTRIBUTE3, ASO_ATTRIBUTE4 ,ASO_VALUE2,'||
                   '  (SELECT RSTL.RESOURCE_NAME FROM   JTF_RS_RESOURCE_EXTNS_TL RSTL  WHERE RSTL.LANGUAGE = USERENV(''LANG'') AND '||
                   '  RSTL.RESOURCE_ID = SUMRY.SALESREP_ID )  ASO_ATTRIBUTE5,'||
                   ' ASO_VALUE3, ASO_VALUE4, ASO_VALUE5, ASO_VALUE6, ASO_GRAND_VALUE1, '||
                   ' ASO_GRAND_VALUE2,  ASO_GRAND_VALUE3   '||
                   ' FROM ('   ||l_inner_sql|| ')   SUMRY ' ||
                   '    ORDER BY  '|| l_orderBy ||' '|| l_sortBy ||' , UPPER(ASO_ATTRIBUTE1)  NULLS LAST ' ;



   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

   l_custom_rec.attribute_name := ':l_sg_id_num';
   l_custom_rec.attribute_value := l_sg_id_num;
   l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   rec_index := rec_index + 1;
   x_custom_output.EXTEND;
   x_custom_output(rec_index) := l_custom_rec;

   l_custom_rec.attribute_name := ':l_sr_id_num';
   l_custom_rec.attribute_value := l_sr_id_num;
   l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   rec_index := rec_index + 1;
   x_custom_output.EXTEND;
   x_custom_output(rec_index) := l_custom_rec;

   l_custom_rec.attribute_name := ':l_rep_r_grp';
   l_custom_rec.attribute_value := l_rep_r_grp;
   l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   rec_index := rec_index + 1;
   x_custom_output.EXTEND;
   x_custom_output(rec_index) := l_custom_rec;

   l_custom_rec.attribute_name := ':l_report_by';
   l_custom_rec.attribute_value := l_report_by;
   l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   rec_index := rec_index + 1;
   x_custom_output.EXTEND;
   x_custom_output(rec_index) := l_custom_rec;

EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_ERROR ,
                       MODULE => l_module_name,
                       MESSAGE => 'Error while executing the procedure '|| SQLERRM);
    END IF;
    RAISE;
END BY_TOPQUOT_SQL;
END ASO_BI_QOT_SUMMRY_PVT;

/
