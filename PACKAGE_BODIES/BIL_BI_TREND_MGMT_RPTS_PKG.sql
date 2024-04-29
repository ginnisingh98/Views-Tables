--------------------------------------------------------
--  DDL for Package Body BIL_BI_TREND_MGMT_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_TREND_MGMT_RPTS_PKG" AS
  /* $Header: bilbtrb.pls 120.6 2006/10/02 18:48:44 esapozhn noship $ */

g_pkg   VARCHAR2(100);
g_sch_name VARCHAR2(100);
/*******************************************************************************
 * Name    : Procedure BIL_BI_FST_WON_QTA_TREND
 * Author  : Prasanna Patil
 * Date    : Aug 01 2003
 * Purpose : Extended Forecast and won report.
 *
 *           Copyright (c) 2002 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 *
 * Date        Author     Description
 * ----        ------     -----------
 * 08/01/03    ppatil      Intial Version
 * 05 Jan 2004 krsundar    1. Made changes as per the new pipeline defn.
 *                         2. Removed product related joins.
 * 25 Feb 2004 krsundar    fii_time_structures uptake
 * 08 Mar 2004 krsundar    Forecast related changes.
 ******************************************************************************/

PROCEDURE BIL_BI_FST_WON_QTA_TREND(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                  ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_output        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
  IS
     l_custom_sql            VARCHAR2(32000);
     l_period_type           VARCHAR2(200);
     l_sg_id                 VARCHAR2(200);
     l_conv_rate_selected    VARCHAR2(200);
     l_comp_type             VARCHAR2(200);
     l_bitand_id             VARCHAR2(10);
     l_calendar_id           VARCHAR2(10);
     l_table_name            VARCHAR2(200);
     l_column_name           VARCHAR2(200);
     l_fst_crdt_type         VARCHAR2(100);
     l_page_period_type      VARCHAR2(100);
     l_fii_struct            VARCHAR2(100);
     l_default_query         VARCHAR2(2000);
     l_sql_stmnt1            VARCHAR2(5000);
     l_sql_stmnt2            VARCHAR2(5000);
     l_sql_stmnt3            VARCHAR2(5000);
     l_insert_stmnt          VARCHAR2(5000);
     l_sql_outer             VARCHAR2(5000);
     l_viewby                VARCHAR2(200);
     l_prodcat_id            VARCHAR2(20);
     l_product_where_clause  VARCHAR2(1000);
     l_product_where_fst     VARCHAR2(1000);
     l_sumry                 VARCHAR2(50);
     l_fst                   VARCHAR(50);
     l_resource_id           VARCHAR2(20);
     l_item                  VARCHAR2(50);
     l_sql_error_desc        VARCHAR2(4000);
     l_curr_page_time_id     NUMBER;
     l_prev_page_time_id     NUMBER;
     l_record_type_id        NUMBER;
     l_sg_id_num             NUMBER;
     l_bind_ctr              NUMBER;
     l_curr_start_date       DATE;
     l_prev_start_date       DATE;
     l_prev_end_date         DATE;
     l_curr_as_of_date       DATE;
     l_bis_sysdate           DATE;
     l_prev_date             DATE;
     l_curr_eff_end_date     DATE;
     l_prev_eff_end_date     DATE;
     l_custom_rec            BIS_QUERY_ATTRIBUTES;
     l_proc                  VARCHAR2(100);
     l_parameter_valid       BOOLEAN;
     l_region_id             VARCHAR2(100);
     l_parent_sls_grp_id     NUMBER;
     l_yes                   VARCHAR2(1);
     l_denorm		     VARCHAR2(1000);
     l_currency_suffix       VARCHAR2(5);

    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

BEGIN
	  /*Intializing Variables */
	  g_pkg := 'bil.patch.115.sql.BIL_BI_TREND_MGMT_RPTS_PKG.';
	  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
     	  l_proc := 'BIL_BI_FST_WON_TREND.';
     	  l_parameter_valid := FALSE;
     	  l_region_id := 'BIL_BI_FRCST_WON_QUOTA_TREND';
          l_yes := 'Y';
          g_sch_name := 'BIL';

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '|| l_proc);

                     END IF;


          BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl   => p_page_parameter_tbl,
                                          p_region_id            => l_region_id,
                                          x_period_type          => l_period_type,
                                          x_conv_rate_selected   => l_conv_rate_selected,
                                          x_sg_id                => l_sg_id,
                                          x_parent_sg_id         => l_parent_sls_grp_id,
                                          x_resource_id          => l_resource_id,
                                          x_prodcat_id           => l_prodcat_id,
                                          x_curr_page_time_id    => l_curr_page_time_id,
                                          x_prev_page_time_id    => l_prev_page_time_id,
                                          x_comp_type            => l_comp_type,
                                          x_parameter_valid      => l_parameter_valid,
                                          x_as_of_date           => l_curr_as_of_date,
                                          x_page_period_type     => l_page_period_type,
                                          x_prior_as_of_date     => l_prev_date,
                                          x_record_type_id       => l_record_type_id,
                                          x_viewby               => l_viewby);

          IF l_parameter_valid THEN

              l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
              BIL_BI_UTIL_PKG.GET_FORECAST_PROFILES(x_FstCrdtType => l_fst_crdt_type);
              BIL_BI_UTIL_PKG.get_trend_params(p_page_parameter_tbl   => p_page_parameter_tbl,
                                               p_page_period_type     => l_page_period_type,
                                               p_comp_type            => l_comp_type,
                                               p_curr_as_of_date      => l_curr_as_of_date,
                                               x_table_name           => l_table_name,
                                               x_column_name          => l_column_name,
                                               x_curr_start_date      => l_curr_start_date,
                                               x_prev_start_date      => l_prev_start_date,
                                               x_curr_eff_end_date    => l_curr_eff_end_date,
                                               x_prev_eff_end_date    => l_prev_eff_end_date);

              BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id          => l_bitand_id,
                                               x_calendar_id        => l_calendar_id,
                                               x_curr_date          => l_bis_sysdate,
                                               x_fii_struct         => l_fii_struct);

              l_prodcat_id := REPLACE(l_prodcat_id,'''','');

           IF l_conv_rate_selected = 0 THEN
                  l_currency_suffix := '_s';
           ELSE
                  l_currency_suffix := '';
           END IF;

              IF l_prodcat_id IS NULL THEN
                 l_prodcat_id := 'All';
              END IF;
              /* Added following code for PC rollup when PC <> All */
              BIL_BI_UTIL_PKG.GET_PC_NOROLLUP_WHERE_CLAUSE(
					p_viewby       => l_viewby,
                                        p_prodcat      => l_prodcat_id,
                                         x_denorm      => l_denorm,
                                   x_where_clause      => l_product_where_clause);
              IF 'All' = l_prodcat_id THEN
                 l_sumry  := 'BIL_BI_OPTY_G_MV';
                 l_fst := 'BIL_BI_FST_G_MV';
                 l_product_where_clause := ' ';
              ELSE
                 l_sumry  := 'BIL_BI_OPTY_PG_MV';
                 l_fst := 'BIL_BI_FST_PG_MV';
                 l_product_where_fst := 'AND sumry.product_category_id = :l_prodcat_id ';
              END IF;

                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Prod cat is '||NVL(l_prodcat_id, 0)||' Lang '||USERENV('LANG'));

                     END IF;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

         	       l_sql_error_desc := ' l_curr_eff_end_date '||l_curr_eff_end_date||' l_curr_start_date '||l_curr_start_date||
                                    ' l_curr_as_of_date '||l_curr_as_of_date||' l_calendar_id '|| l_calendar_id||
                                     ' l_bitand_id '||l_bitand_id||' l_period_type '||l_period_type||
                                     ' l_sg_id_num '||l_sg_id_num||' l_fst_crdt_type '||l_fst_crdt_type||
                                     ' l_prev_eff_end_date '||l_prev_eff_end_date||
                                     ' l_prev_start_date '||l_prev_start_date;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Parameters '||l_sql_error_desc);

                     END IF;

             /* Mappings...
                VIEWBY Period
                BIL_MEASURE3 Forecast
                BIL_MEASURE5 Won
                BIL_MEASURE9 Prior Forecast
                BIL_MEASURE11 Prior Won
             */

            /* Query for all period types sequential comparison, and for period type year  */
	       execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';
	       execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP2';

               IF (l_comp_type = 'SEQUENTIAL' OR (l_comp_type = 'YEARLY' AND l_page_period_type = 'FII_TIME_ENT_YEAR')) THEN


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Sequential OR (Yearly and Year) ');

                     END IF;


			l_sql_stmnt1 := 'SELECT /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */ '||
					    ' ftime.'|| l_column_name ||' timeId '||
                                            ',SUM(DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||')) fstAmt '||
                                            ',0 wonAmt '||
                                     'FROM '|| l_table_name ||' ftime '||
                                           ', '|| l_fii_struct ||' ftrs '||
                                           ', '|| l_fst ||' sumry '||
                                     'WHERE ftime.start_date <= :l_curr_eff_end_date '||
                                           'AND ftime.end_date >= :l_curr_start_date '||
                                           'AND ftrs.report_date = :l_curr_as_of_date '||
                                           'AND BITAND(ftrs.record_type_id,:l_bitand_id) = :l_bitand_id '||
					   'AND ftrs.xtd_flag= :l_yes '||
                                           'AND sumry.txn_time_id = ftrs.time_id '||
                                           'AND sumry.txn_period_type_id = ftrs.period_type_id '||
                                           'AND sumry.effective_period_type_id = :l_period_type '||
                                           'AND sumry.effective_time_id = ftime.'|| l_column_name ||' '||
                                           'AND sumry.sales_group_id = :l_sg_id_num '||
                                           'AND sumry.credit_type_id = :l_fst_crdt_type '|| l_product_where_fst;

                 	if(l_resource_id is not null) then
                		l_sql_stmnt1 := l_sql_stmnt1  ||
                    		' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
            		else
                		l_sql_stmnt1 :=l_sql_stmnt1  ||
                    			' AND sumry.salesrep_id IS NULL ';
                		if l_parent_sls_grp_id IS NULL then
                    			l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                		else
                   			l_sql_stmnt1 :=l_sql_stmnt1  ||
						' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                		end if;
             	 	end if;

                 	l_sql_stmnt1 := l_sql_stmnt1 ||' GROUP BY ftime.'|| l_column_name ||
                                    ' UNION ALL '||
                                    'SELECT /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */
                                            ftime.'|| l_column_name ||' timeId '||
                                          ',0 fstAmt '||
                                          ',SUM(sumry.won_OPTY_amt'||l_currency_suffix||') wonAmt '||
                                    'FROM '|| l_table_name ||' ftime '||
                                          ','|| l_fii_struct ||' ftrs '||
                                          ','|| l_sumry ||' sumry '||l_denorm||' '||
                                    'WHERE ftime.start_date <= :l_curr_eff_end_date '||
                                          'AND ftime.end_date >= :l_curr_start_date '||
                                          'AND ftrs.report_date = LEAST(:l_curr_as_of_date,ftime.end_date) '||
                                          'AND BITAND(ftrs.record_type_id, :l_record_type_id) = :l_record_type_id '||
					  'AND ftrs.xtd_flag= :l_yes '||
                                          'AND sumry.effective_period_type_id = ftrs.period_type_id '||
                                          'AND sumry.effective_time_id = ftrs.time_id '||
                                          'AND sumry.sales_group_id = :l_sg_id_num '||
					  l_product_where_clause;

             		if(l_resource_id is not null) then
                		l_sql_stmnt1 := l_sql_stmnt1  ||
                    		' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             		else
                		l_sql_stmnt1 :=l_sql_stmnt1  ||
                    			' AND sumry.salesrep_id IS NULL ';
                		if l_parent_sls_grp_id IS NULL then
                    			l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                		else
                   			l_sql_stmnt1 :=l_sql_stmnt1  ||
						' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                		end if;
             		end if;
                	l_sql_stmnt1 := l_sql_stmnt1 || l_product_where_clause ||' GROUP BY ftime.'|| l_column_name ;

               		l_sql_outer :='SELECT tmp.timeId timeId
                                          ,SUM(tmp.fstAmt) BIL_MEASURE3
                                          ,SUM(tmp.wonAmt) BIL_MEASURE5
                                          ,NULL BIL_MEASURE9
                                          ,NULL BIL_MEASURE11
                                    FROM ('|| l_sql_stmnt1 ||') tmp
                                    GROUP BY tmp.timeId';

                	l_custom_sql :='SELECT ftime.name VIEWBY
                               ,NVL(SUM(tmp.BIL_MEASURE3) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                   0) BIL_MEASURE3
                               ,NVL(SUM(tmp.BIL_MEASURE5) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                   0) BIL_MEASURE5
                               ,NULL BIL_MEASURE9
                               ,NULL BIL_MEASURE11
                            FROM ('|| l_sql_outer ||') tmp,'|| l_table_name ||' ftime
                            WHERE ftime.start_date <= :l_curr_eff_end_date
                                  AND ftime.end_date > :curr_prd_start_date
                                  AND ftime.'|| l_column_name ||' = tmp.timeId(+)
                             ORDER BY ftime.end_date';

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



               ELSIF (l_comp_type = 'YEARLY' and l_page_period_type = 'FII_TIME_WEEK') THEN/*Query for yearly week only */


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc,
		                                    MESSAGE => 'Yeary and Week ');

                     END IF;


                  execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';
                  execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP2';

                       l_sql_stmnt1 :='SELECT /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */ ftime.sequence timeSequence '||
                                            ',SUM(DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||')) forecast_amt '||
                                            ',0 won_amt '||
                                            ',0 prior_forecast_amt '||
                                            ',0 prior_won_amt '||
                                      'FROM '|| l_table_name ||' ftime '||
                                            ','|| l_fii_struct ||' ftrs '||
                                            ','|| l_fst ||' sumry '||
                                      'WHERE ftime.start_date <=  :l_curr_eff_end_date '||
                                            'AND ftime.end_date >= :l_curr_start_date '||
                                            'AND ftrs.report_date = :l_curr_as_of_date '||
                                            'AND BITAND(ftrs.record_type_id, :l_bitand_id) = :l_bitand_id '||
					    'AND ftrs.xtd_flag= :l_yes '||
                                            'AND sumry.txn_time_id = ftrs.time_id '||
                                            'AND sumry.txn_period_type_id = ftrs.period_type_id '||
                                            'AND sumry.effective_period_type_id = :l_period_type '||
                                            'AND sumry.effective_time_id = ftime.'|| l_column_name ||' '||
                                            'AND sumry.credit_type_id = :l_fst_crdt_type ';

             		if(l_resource_id is not null) then
                	   l_sql_stmnt1 := l_sql_stmnt1  ||
                    		' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             		else
                	   l_sql_stmnt1 :=l_sql_stmnt1  ||
                    		' AND sumry.salesrep_id IS NULL ';
                	   if l_parent_sls_grp_id IS NULL then
                    		l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                	   else
                   		l_sql_stmnt1 :=l_sql_stmnt1  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                	   end if;
             	        end if;

                        l_sql_stmnt1 := l_sql_stmnt1 || 'AND sumry.sales_group_id = :l_sg_id_num
                                                        '|| l_product_where_fst ||
                                      ' GROUP BY ftime.sequence '||
                                      'UNION ALL '||
                                      'SELECT /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */
                                            ftime.sequence timeSequence '||
                                            ',0 forecast_amt '||
                                            ',SUM(sumry.won_opty_amt'||l_currency_suffix||') won_amt '||
                                            ',0 prior_forecast_amt '||
                                            ',0 prior_won_amt '||
                                       'FROM '|| l_table_name ||' ftime '||
                                             ','|| l_fii_struct ||' ftrs '||
                                             ','|| l_sumry ||' sumry '||l_denorm||' '||
                                       ' WHERE ftime.start_date <=  :l_curr_eff_end_date '||
                                              'AND ftime.end_date >= :l_curr_start_date '||
                                              'AND ftrs.report_date = LEAST(:l_curr_as_of_date,ftime.end_date) '||
                                              'AND BITAND(ftrs.record_type_id, :l_record_type_id) = :l_record_type_id '||
					      'AND ftrs.xtd_flag= :l_yes '||
                                              'AND sumry.effective_period_type_id =  ftrs.period_type_id '||
                                              'AND sumry.effective_time_id =  ftrs.time_id ';

             		if(l_resource_id is not null) then
                		l_sql_stmnt1 := l_sql_stmnt1  ||
                    		' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             		else
                		l_sql_stmnt1 :=l_sql_stmnt1  ||
                    		' AND sumry.salesrep_id IS NULL ';
                		if l_parent_sls_grp_id IS NULL then
                    			l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                		else
                   			l_sql_stmnt1 :=l_sql_stmnt1  ||
					' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                		end if;
     	     		end if;
                      	l_sql_stmnt1 := l_sql_stmnt1 || 'AND sumry.sales_group_id = :l_sg_id_num '|| l_product_where_clause
                                                   ||' GROUP BY ftime.sequence';


                      	l_insert_stmnt := 'INSERT INTO BIL_BI_RPT_TMP1(VIEWBY,BIL_MEASURE3,BIL_MEASURE5,'||
                                                                     'BIL_MEASURE9,BIL_MEASURE11)';

                      	BEGIN


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_sql_stmnt1);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_sql_stmnt1, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


                           IF  'All' = l_prodcat_id  THEN
                               IF l_resource_id IS NOT NULL THEN
                                  EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                                  USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                       ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                       ,l_fst_crdt_type,l_resource_id,l_sg_id_num,l_sg_id_num
                                       ,l_curr_eff_end_date,l_curr_start_date, l_curr_as_of_date
                                       ,l_record_type_id,l_record_type_id, l_yes, l_resource_id
                                       ,l_sg_id_num, l_sg_id_num;
                               ELSE
                                IF l_parent_sls_grp_id IS NULL THEN
                                  EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                                  USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                       ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                       ,l_fst_crdt_type,l_sg_id_num
                                       ,l_curr_eff_end_date,l_curr_start_date, l_curr_as_of_date
                                       ,l_record_type_id,l_record_type_id, l_yes, l_sg_id_num;
                               ELSE
                                        EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                                  USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                       ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                       ,l_fst_crdt_type, l_parent_sls_grp_id, l_sg_id_num
                                       ,l_curr_eff_end_date,l_curr_start_date, l_curr_as_of_date
                                       ,l_record_type_id,l_record_type_id, l_yes, l_parent_sls_grp_id, l_sg_id_num;
                               END IF;
                               END IF;
                           ELSIF 'All' <> l_prodcat_id THEN
                              IF l_resource_id IS NOT NULL THEN
                                 EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                                 USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                      ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                      ,l_fst_crdt_type,l_resource_id,l_sg_id_num,l_sg_id_num,REPLACE(l_prodcat_id,'''')
                                      ,l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                      ,l_record_type_id,l_record_type_id, l_yes
                                      ,l_resource_id,l_sg_id_num,l_sg_id_num,REPLACE(l_prodcat_id,'''');
                              ELSE
                                 IF l_parent_sls_grp_id IS NULL THEN
                                 EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                                 USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                      ,l_bitand_id,l_bitand_id,l_yes,l_period_type
                                      ,l_fst_crdt_type,l_sg_id_num,REPLACE(l_prodcat_id,'''')
                                      ,l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                      ,l_record_type_id,l_record_type_id,l_yes,l_sg_id_num
                                      ,REPLACE(l_prodcat_id,'''');
                                ELSE
                                      EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                                 USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                      ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                      ,l_fst_crdt_type,l_parent_sls_grp_id, l_sg_id_num,REPLACE(l_prodcat_id,'''')
                                      ,l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date
                                      ,l_record_type_id,l_record_type_id, l_yes,l_parent_sls_grp_id, l_sg_id_num
                                      ,REPLACE(l_prodcat_id,'''');
                                END IF;
                              END IF;

                           END IF;
                           COMMIT;

                        EXCEPTION
                        	WHEN OTHERS THEN

                      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                                     fnd_message.set_token('ERROR' ,SQLCODE);
                                     fnd_message.set_token('REASON', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

                     END IF;


                     END;

                      l_sql_stmnt2 := 'SELECT /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */ ftime.sequence timeSequence '||
                                            ',0 forecast_amt '||
                                            ',0 won_amt '||
                                            ',SUM(DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||')) prior_forecast_amt '||
                                            ',0 prior_won_amt '||
                                       'FROM '|| l_table_name ||' ftime '||
                                             ','|| l_fii_struct ||' ftrs '||
                                             ','|| l_fst ||' sumry '||
                                       'WHERE ftime.start_date <=  :l_prev_eff_end_date '||
                                             'AND ftime.end_date >= :l_prev_start_date '||
                                             'AND ftrs.report_date = :l_prev_date '||
                                             'AND BITAND(ftrs.record_type_id, :l_bitand_id) = :l_bitand_id '||
                                             'AND ftrs.xtd_flag= :l_yes '||
                                             'AND sumry.txn_time_id = ftrs.time_id '||
                                             'AND sumry.txn_period_type_id = ftrs.period_type_id '||
                                             'AND sumry.effective_period_type_id = :l_period_type '||
                                             'AND sumry.effective_time_id = ftime.'|| l_column_name ||' '||
                                             'AND sumry.sales_group_id = :l_sg_id_num '|| l_product_where_fst ||
                                             'AND sumry.credit_type_id = :l_fst_crdt_type ';

      	     		if(l_resource_id is not null) then
                		l_sql_stmnt2 := l_sql_stmnt2  ||
                    		' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             		else
                		l_sql_stmnt2 :=l_sql_stmnt2  ||
                    			' AND sumry.salesrep_id IS NULL ';
                		if l_parent_sls_grp_id IS NULL then
                    			l_sql_stmnt2 :=l_sql_stmnt2  || ' AND sumry.parent_sales_group_id IS NULL ';
                		else
                   			l_sql_stmnt2 :=l_sql_stmnt2  ||
						' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
             			end if;
     			end if;

                      	l_sql_stmnt2 := l_sql_stmnt2 ||' GROUP BY ftime.sequence '||
                                     'UNION ALL '||
                                     'SELECT /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */
                                            ftime.sequence timeSequence '||
                                           ',0 forecast_amt '||
                                           ',0 won_amt '||
                                           ',0 prior_forecast_amt '||
                                           ',SUM(sumry.won_opty_amt'||l_currency_suffix||') prior_won_amt '||
                                     'FROM '|| l_table_name ||' ftime '||
                                           ','|| l_fii_struct ||' ftrs '||
                                           ','|| l_sumry ||' sumry '||l_denorm||' '||
                                     'WHERE ftime.start_date <=  :l_prev_eff_end_date '||
                                           'AND ftime.end_date >= :l_prev_start_date '||
                                           'AND ftrs.report_date = LEAST(:l_prev_date,ftime.end_date) '||
                                           'AND BITAND(ftrs.record_type_id, :l_record_type_id) = :l_record_type_id '||
                                           'AND ftrs.xtd_flag= :l_yes '||
                                           'AND sumry.effective_period_type_id = ftrs.period_type_id '||
                                           'AND sumry.effective_time_id = ftrs.time_id '||
                                           'AND sumry.sales_group_id = :l_sg_id_num';
    			if(l_resource_id is not null) then
                		l_sql_stmnt2 := l_sql_stmnt2  ||
                    		' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
    			else
                		l_sql_stmnt2 :=l_sql_stmnt2  ||
                    			' AND sumry.salesrep_id IS NULL ';
                		if l_parent_sls_grp_id IS NULL then
                    			l_sql_stmnt2 :=l_sql_stmnt2  || ' AND sumry.parent_sales_group_id IS NULL ';
                		else
                   			l_sql_stmnt2 :=l_sql_stmnt2  ||
						' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                		end if;
     			end if;

                      	l_sql_stmnt2 := l_sql_stmnt2 || l_product_where_clause ||' GROUP BY ftime.sequence';

                      	l_insert_stmnt := 'INSERT INTO BIL_BI_RPT_TMP1(VIEWBY, BIL_MEASURE3, BIL_MEASURE5, '||
                                                                     'BIL_MEASURE9, BIL_MEASURE11)';

                      	BEGIN


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_sql_stmnt2);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_sql_stmnt2, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


                           IF  'All' = l_prodcat_id  THEN
                              IF l_resource_id IS NOT NULL THEN
                                 EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                 USING l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                      ,l_bitand_id,l_bitand_id, l_yes,l_period_type
                                      ,l_sg_id_num,l_fst_crdt_type,l_resource_id, l_sg_id_num
                                      ,l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                      ,l_record_type_id,l_record_type_id,l_yes, l_sg_id_num,l_resource_id, l_sg_id_num;
                              ELSE
                              IF l_parent_sls_grp_id IS NULL THEN
                                 EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                 USING l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                      ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                      ,l_sg_id_num,l_fst_crdt_type
                                      ,l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                      ,l_record_type_id,l_record_type_id, l_yes, l_sg_id_num;
                             ELSE
                                     EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                 USING l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                      ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                      ,l_sg_id_num,l_fst_crdt_type, l_parent_sls_grp_id
                                      ,l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                      ,l_record_type_id,l_record_type_id, l_yes, l_sg_id_num, l_parent_sls_grp_id;
                             END IF;

                              END IF;
                           ELSIF 'All' <> l_prodcat_id THEN
                               IF l_resource_id IS NOT NULL THEN
                                  EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                  USING l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                       ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                       ,l_sg_id_num,REPLACE(l_prodcat_id,''''),l_fst_crdt_type,l_resource_id, l_sg_id_num
                                       ,l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                       ,l_record_type_id,l_record_type_id, l_yes
                                       ,l_sg_id_num,l_resource_id, l_sg_id_num, REPLACE(l_prodcat_id,'''');
                               ELSE
                                 IF l_parent_sls_grp_id IS NULL THEN
                                  EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                  USING l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                       ,l_bitand_id,l_bitand_id,l_yes, l_period_type
                                       ,l_sg_id_num,REPLACE(l_prodcat_id,''''),l_fst_crdt_type
                                       ,l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                       ,l_record_type_id,l_record_type_id, l_yes
                                       ,l_sg_id_num,REPLACE(l_prodcat_id,'''');
                                 ELSE
                                      EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                  USING l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                       ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                       ,l_sg_id_num,REPLACE(l_prodcat_id,''''),l_fst_crdt_type, l_parent_sls_grp_id
                                       ,l_prev_eff_end_date,l_prev_start_date,l_prev_date
                                       ,l_record_type_id,l_record_type_id, l_yes
                                       ,l_sg_id_num, l_parent_sls_grp_id,REPLACE(l_prodcat_id,'''');
                                 END IF;
                               END IF;
                           END IF;
                           COMMIT;

                      	EXCEPTION
                          	WHEN OTHERS THEN

                     IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                 fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                                 fnd_message.set_token('ERROR' ,SQLCODE);
                                 fnd_message.set_token('REASON', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

                     END IF;


              	END;

                     	l_sql_outer := 'SELECT VIEWBY
                                            ,SUM(BIL_MEASURE3) BIL_MEASURE3
                                            ,SUM(BIL_MEASURE5) BIL_MEASURE5
                                            ,SUM(BIL_MEASURE9) BIL_MEASURE9
                                            ,SUM(BIL_MEASURE11) BIL_MEASURE11
                                      FROM BIL_BI_RPT_TMP1
                                      GROUP BY VIEWBY';

                      	l_insert_stmnt := 'INSERT INTO BIL_BI_RPT_TMP2(VIEWBY, BIL_MEASURE3, BIL_MEASURE5,'||
                                                                    ' BIL_MEASURE9, BIL_MEASURE11)';

                      	BEGIN
                           EXECUTE IMMEDIATE l_insert_stmnt || l_sql_outer;
                           COMMIT;
                      	EXCEPTION
                        	WHEN OTHERS THEN
                      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                               		fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                               		fnd_message.set_token('ERROR' ,SQLCODE);
                               		fnd_message.set_token('REASON', SQLERRM);


                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

                     END IF;
               	END;

                     	l_custom_sql := 'Select ftime.name VIEWBY
                             ,NVL(SUM(tmp.BIL_MEASURE3) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                 0) BIL_MEASURE3
                             ,NVL(SUM(tmp.BIL_MEASURE5) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                 0) BIL_MEASURE5
                             ,NVL(SUM(tmp.BIL_MEASURE9) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                 0) BIL_MEASURE9
                             ,NVL(SUM(tmp.BIL_MEASURE11) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                 0) BIL_MEASURE11
                             FROM BIL_BI_RPT_TMP2 tmp,  '||l_table_name||' ftime
                             WHERE ftime.start_date <= :l_curr_eff_end_date
                             AND ftime.end_date > :curr_prd_start_date
                             AND ftime.sequence = tmp.VIEWBY (+)
                             ORDER BY ftime.end_date ';



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


              /* Query for month and quarter year/year comparison*/
               ELSE

                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE =>    g_pkg || l_proc,
		                                    MESSAGE => 'Query for month and quarter year/year comparison ');

                     END IF;

                     execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';
                     execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP2';


                   	l_sql_stmnt1 := 'SELECT /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */ ftime.sequence time_sequence '||
                                        ',(CASE WHEN ftrs.report_date = :l_curr_as_of_date AND ftime.end_date > :l_curr_start_date '||
                                               ' THEN DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||') else 0 end) currFstAmt '||
                                        ',0 currWonAmt '||
                                        ',(CASE WHEN ftrs.report_date = :l_prev_date AND ftime.end_date < :l_curr_start_date '||
                                              ' THEN DECODE(:l_resource_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||') ELSE 0 END) prevFstAmt '||
                                        ',0 prevWonAmt '||
                                   'FROM '|| l_table_name ||' ftime '||
                                         ','|| l_fii_struct ||' ftrs '||
                                         ','|| l_fst ||' sumry '||
                                   'WHERE ftime.start_date <= :l_curr_eff_end_date '||
                                         'AND ftime.end_date >= :l_prev_start_date '||
                                         'AND ftrs.report_date IN (:l_prev_date,:l_curr_as_of_date) '||
                                         'AND BITAND(ftrs.record_type_id,:l_bitand_id) = :l_bitand_id '||
                                         'AND ftrs.xtd_flag= :l_yes '||
                                         'AND sumry.txn_time_id = ftrs.time_id '||
                                         'AND sumry.txn_period_type_id = ftrs.period_type_id '||
                                         'AND sumry.effective_period_type_id = :l_period_type '||
                                         'AND sumry.effective_time_id = ftime.'|| l_column_name ||' '||
                                         'AND sumry.credit_type_id = :l_fst_crdt_type ';

       			if(l_resource_id is not null) then
                		l_sql_stmnt1 := l_sql_stmnt1  ||
                    		' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             		else
                		l_sql_stmnt1 :=l_sql_stmnt1  ||
                    			' AND sumry.salesrep_id IS NULL ';
                		if l_parent_sls_grp_id IS NULL then
                    			l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                		else
                   			l_sql_stmnt1 :=l_sql_stmnt1  ||
						' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                		end if;
     			end if;

                   	l_sql_stmnt1 := l_sql_stmnt1 ||'AND sumry.sales_group_id = :l_sg_id_num
                                                    '|| l_product_where_fst ||
                                  'UNION ALL '||
                                  'SELECT /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */
                                         ftime.sequence time_sequence '||
                                         ',0 currFstAmt  '||
                                         ',(CASE WHEN ftime.end_date >= :l_curr_start_date '||
                                              '  THEN sumry.won_opty_amt'||l_currency_suffix||' ELSE 0 END) currWonAmt '||
                                         ',0 prevFstAmt '||
                                         ',(CASE WHEN ftime.end_date < :l_curr_start_date '||
                                               ' THEN sumry.won_opty_amt'||l_currency_suffix||' ELSE 0 END) prevWonAmt '||
                                   'FROM '|| l_table_name ||' ftime '||
                                         ','|| l_fii_struct ||' ftrs '||
                                         ','|| l_sumry ||' sumry '||l_denorm||' '||
                                   'WHERE ftime.start_date <= :l_curr_eff_end_date '||
                                         'AND ftime.end_date >= :l_prev_start_date  '||
                                         'AND ftrs.report_date = LEAST((CASE WHEN :l_prev_date BETWEEN ftime.start_date AND ftime.end_date
                                                                             THEN :l_prev_date ELSE ftime.end_date END),:l_curr_as_of_date) '||
                                        'AND BITAND(ftrs.record_type_id, :l_record_type_id) = :l_record_type_id '||
                                        'AND ftrs.xtd_flag= :l_yes '||
                                        'AND sumry.effective_period_type_id = ftrs.period_type_id '||
                                        'AND sumry.effective_time_id = ftrs.time_id ';

             		if(l_resource_id is not null) then
                		l_sql_stmnt1 := l_sql_stmnt1  ||
                    		' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             		else
                		l_sql_stmnt1 :=l_sql_stmnt1  ||
                   		 ' AND sumry.salesrep_id IS NULL ';
                		if l_parent_sls_grp_id IS NULL then
                    			l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                		else
                   			l_sql_stmnt1 :=l_sql_stmnt1  ||
						' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
             			end if;
     			end if;

                   	l_sql_stmnt1 := l_sql_stmnt1 ||' AND sumry.sales_group_id = :l_sg_id_num '||l_product_where_clause;


                   	l_sql_outer := 'SELECT tmp.time_sequence VIEWBY
                                          ,SUM(tmp.currFstAmt) BIL_MEASURE3
                                          ,SUM(tmp.currWonAmt) BIL_MEASURE5
                                          ,SUM(tmp.prevFstAmt) BIL_MEASURE9
                                          ,SUM(tmp.prevWonAmt) BIL_MEASURE11
                                    FROM ('||l_sql_stmnt1||') tmp
                                    GROUP BY tmp.time_sequence ';

			l_custom_sql := 'SELECT ftime.name VIEWBY
                                   ,NVL(SUM(BIL_MEASURE3) OVER(ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                       0) BIL_MEASURE3
                                   ,NVL(SUM(BIL_MEASURE5) OVER(ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                       0) BIL_MEASURE5
                                   ,NVL(SUM(BIL_MEASURE9) OVER(ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                       0) BIL_MEASURE9
                                   ,NVL(SUM(BIL_MEASURE11) OVER(ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
                                       0) BIL_MEASURE11
                        FROM ('|| l_sql_outer ||') tmp, '|| l_table_name ||' ftime
                        WHERE ftime.start_date <= :l_curr_eff_end_date
                              AND ftime.end_date > :curr_prd_start_date
                              AND tmp.VIEWBY(+) = ftime.sequence
                        ORDER BY ftime.end_date ';

               END IF;

          ELSE --p_valid_param false
                BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                                 ,x_sqlstr     => l_default_query);
                l_custom_sql := l_default_query;
          END IF;

          x_custom_sql := l_custom_sql;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' Final Query to PMV ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                    END IF;


          l_bind_ctr := 1;

          x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

          l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
          l_custom_rec.attribute_value := l_viewby;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name := ':curr_prd_start_date';
          l_custom_rec.attribute_value := TO_CHAR(l_curr_start_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr + 1;

          l_custom_rec.attribute_name := ':l_curr_eff_end_date';
          l_custom_rec.attribute_value := TO_CHAR(l_curr_eff_end_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr + 1;

          l_custom_rec.attribute_name := ':l_curr_start_date';
          l_custom_rec.attribute_value := TO_CHAR(l_curr_start_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_prev_start_date';
          l_custom_rec.attribute_value := TO_CHAR(l_prev_start_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_curr_as_of_date';
          l_custom_rec.attribute_value := TO_CHAR(l_curr_as_of_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_record_type_id';
          l_custom_rec.attribute_value := l_record_type_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_bitand_id';
          l_custom_rec.attribute_value := l_bitand_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

         l_custom_rec.attribute_name :=':l_yes';
         l_custom_rec.attribute_value :=l_yes;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_output.Extend();
         x_custom_output(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_period_type';
          l_custom_rec.attribute_value := l_period_type;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_sg_id_num';
          l_custom_rec.attribute_value := l_sg_id_num;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

	  IF l_parent_sls_grp_id IS NOT NULL THEN
            l_custom_rec.attribute_name := ':l_parent_sls_grp_id';
            l_custom_rec.attribute_value := l_parent_sls_grp_id;
            l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
            l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_output.Extend();
            x_custom_output(l_bind_ctr) := l_custom_rec;

            l_bind_ctr := l_bind_ctr+1;
          END IF;


          l_custom_rec.attribute_name := ':l_resource_id';
          l_custom_rec.attribute_value := l_resource_id;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;


          l_custom_rec.attribute_name := ':l_fst_crdt_type';
          l_custom_rec.attribute_value := l_fst_crdt_type;
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

          l_custom_rec.attribute_name := ':l_prev_date';
          l_custom_rec.attribute_value := TO_CHAR(l_prev_date,'DD/MM/YYYY');
          l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
          l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
          x_custom_output.Extend();
          x_custom_output(l_bind_ctr) := l_custom_rec;

          l_bind_ctr := l_bind_ctr+1;

          IF l_prodcat_id IS NOT NULL THEN
             l_custom_rec.attribute_name :=':l_prodcat_id';
             l_custom_rec.attribute_value :=l_prodcat_id;
             l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
             l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
             x_custom_output.Extend();
             x_custom_output(l_bind_ctr):=l_custom_rec;

            l_bind_ctr:=l_bind_ctr+1;
          END IF;
	  IF l_prodcat_id IS NOT NULL THEN
             l_custom_rec.attribute_name :=':l_prodcat';
             l_custom_rec.attribute_value :=l_prodcat_id;
             l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
             l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
             x_custom_output.Extend();
             x_custom_output(l_bind_ctr):=l_custom_rec;

            l_bind_ctr:=l_bind_ctr+1;
          END IF;

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc||'end',
		                                    MESSAGE => 'End of Procedure '|| l_proc);

                     END IF;


EXCEPTION
   WHEN OTHERS THEN

      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
         fnd_message.set_token('ERROR',SQLCODE);
         fnd_message.set_token('REASON',SQLERRM);
         fnd_message.set_token('ROUTINE',l_proc);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

       END IF;


END BIL_BI_FST_WON_QTA_TREND;

/*******************************************************************************
 * Name    : Procedure BIL_BI_FRCST_PIPE_TREND
 * Author  :
 * Date    :
 * Purpose : Forecast to Pipeline Trend Report
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
 *
 * 17/09/03 oanandam   DBI 6.1 Initial Version
 * 30 Jan 04 krsundar  Made changes as per new pipeline, forecast definitions
 * 25 Feb 04 krsundar  fii_time_structures uptake, pipeline : get_Latest_Snap_Date uptake
 * 08 Mar 04 krsundar  Pipeline : grp_total_flag = 1 and forecsat related changes
 * 03 Jun 04 ctoba     Pipeline related changes (due to obsoletion of bil_bi_pipe_pg_mv
                       Performance fixes
 * 09 Jun 04 ctoba     Fix for bug 3681057
 * 14 Jun 04 ppatil    Fix for Bug 3690434
 ******************************************************************************/

PROCEDURE BIL_BI_FRCST_PIPE_TREND(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                 ,x_custom_sql         OUT NOCOPY VARCHAR2
                                 ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
  IS
     l_custom_sql            VARCHAR2(10000);
     l_period_type           VARCHAR2(200);
     l_sg_id                 VARCHAR2(200);
     l_conv_rate_selected    VARCHAR2(200);
     l_fst_crdt_type         VARCHAR2(100);
     l_comp_type             VARCHAR2(200);
     l_bitand_id             VARCHAR2(10);
     l_calendar_id           VARCHAR2(10);
     l_table_name            VARCHAR2(200);
     l_column_name           VARCHAR2(200);
     l_page_period_type      VARCHAR2(100);
     l_fii_struct            VARCHAR2(100);
     l_default_query         VARCHAR2(2000);
     l_sql_stmnt1            VARCHAR2(5000);
     l_sql_stmnt2            VARCHAR2(5000);
     l_sql_stmnt3            VARCHAR2(5000);
     l_insert_stmnt          VARCHAR2(5000);
     l_sql_outer             VARCHAR2(5000);
     l_viewby                VARCHAR2(200);
     l_prodcat            VARCHAR2(20);
     l_product_where_clause  VARCHAR2(1000);
     l_product_where_fst     VARCHAR2(1000);
     l_sumry                 VARCHAR2(50);
     l_fst                   VARCHAR(50);
     l_resource_id           VARCHAR2(20);
     l_sql_error_desc        VARCHAR2(4000);
     l_pipe_col              VARCHAR2(100);
     l_curr_page_time_id     NUMBER;
     l_prev_page_time_id     NUMBER;
     l_record_type_id        NUMBER;
     l_sg_id_num             NUMBER;
     l_bind_ctr              NUMBER;
     l_curr_start_date       DATE;
     l_prev_start_date       DATE;
     l_prev_end_date         DATE;
     l_curr_as_of_date       DATE;
     l_bis_sysdate           DATE;
     l_prev_date             DATE;
     l_snap_date             DATE;
     l_curr_eff_end_date     DATE;
     l_prev_eff_end_date     DATE;
     l_custom_rec            BIS_QUERY_ATTRIBUTES;
     l_parameter_valid       BOOLEAN;
--     l_pipeline_req          BOOLEAN;
     l_region_id             VARCHAR2(100);
     l_proc                  VARCHAR2(100);
     l_denorm                VARCHAR2(100);
     l_pipe_group_by         VARCHAR2(50);
     l_prod_where_clause_pipe VARCHAR2(500);
     l_parent_sls_grp_id     NUMBER;
     l_yes                   VARCHAR2(1);
     l_currency_suffix       VARCHAR2(5);
     l_prev_snap_date        DATE;
     l_ind       NUMBER;
     l_str       VARCHAR2(4000);
     l_len       NUMBER;

BEGIN
	  /* Intializing Variables */
	  g_pkg := 'bil.patch.115.sql.BIL_BI_TREND_MGMT_RPTS_PKG.';
	  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
      l_parameter_valid := FALSE;
--      l_pipeline_req := TRUE;
      l_region_id := 'BIL_BI_FRCST_PIPE_TREND';
      l_proc := 'BIL_BI_FRCST_PIPE_TREND.';
      l_yes := 'Y';
      g_sch_name := 'BIL';


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'begin',
		                                    MESSAGE => 'Start of Procedure '|| l_proc);

                     END IF;


     BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl =>p_page_parameter_tbl,
                           p_region_id                 =>l_region_id,
                           x_period_type               =>l_period_type,
                           x_conv_rate_selected        =>l_conv_rate_selected,
                           x_sg_id                     =>l_sg_id,
                           x_parent_sg_id              =>l_parent_sls_grp_id,
                           x_resource_id               =>l_resource_id,
                           x_prodcat_id                =>l_prodcat,
                           x_curr_page_time_id         =>l_curr_page_time_id,
                           x_prev_page_time_id         =>l_prev_page_time_id,
                           x_comp_type                 =>l_comp_type,
                           x_parameter_valid           =>l_parameter_valid,
                           x_as_of_date                =>l_curr_as_of_date,
                           x_page_period_type          =>l_page_period_type,
                           x_prior_as_of_date          =>l_prev_date,
                           x_record_type_id            =>l_record_type_id,
                           x_viewby                    =>l_viewby);


      IF l_parameter_valid THEN

          BIL_BI_UTIL_PKG.GET_FORECAST_PROFILES(x_FstCrdtType => l_fst_crdt_type);

/*          bil_bi_util_pkg.get_Latest_Snap_Date(p_page_parameter_tbl  => p_page_parameter_tbl
                                              ,p_as_of_date          => l_curr_as_of_date
                                              ,p_period_type         => NULL
                                              ,x_snapshot_date       => l_snap_date);
*/

         BIL_BI_UTIL_PKG.GET_PIPE_TREND_SOURCE(p_as_of_date    => l_curr_as_of_date
                                             ,p_prev_date     => l_prev_date
                                             ,p_trend_type    => 'E'
                                             ,p_period_type   => l_page_period_type
                                             ,p_page_parameter_tbl  => p_page_parameter_tbl
                                             ,x_pipe_mv       => l_sumry
                                             ,x_snap_date     => l_snap_date
                                             ,x_prev_snap_date => l_prev_snap_date);

          l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
          l_prodcat := REPLACE(l_prodcat,'''','');

          BIL_BI_UTIL_PKG.get_trend_params(p_page_parameter_tbl   => p_page_parameter_tbl,
                                           p_page_period_type    => l_page_period_type,
                                           p_comp_type           => l_comp_type,
                                           p_curr_as_of_date     => l_curr_as_of_date,
                                           x_table_name          => l_table_name,
                                           x_column_name         => l_column_name,
                                           x_curr_start_date     => l_curr_start_date,
                                           x_prev_start_date     => l_prev_start_date,
                                           x_curr_eff_end_date   => l_curr_eff_end_date,
                                           x_prev_eff_end_date   => l_prev_eff_end_date);

          BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id          => l_bitand_id,
                                           x_calendar_id        => l_calendar_id,
                                           x_curr_date          => l_bis_sysdate,
                                           x_fii_struct         => l_fii_struct);

           BIL_BI_UTIL_PKG.GET_PC_NOROLLUP_WHERE_CLAUSE(p_prodcat => l_viewby
                                  ,p_viewby => l_prodcat
                                  ,x_denorm => l_denorm
                                  ,x_where_clause => l_prod_where_clause_pipe);

          IF l_prodcat IS NULL THEN
             l_prodcat := 'All';
          END IF;

          IF l_conv_rate_selected = 0 THEN
             l_currency_suffix := '_s';
          ELSE
             l_currency_suffix := '';
          END IF;


          IF l_prodcat = 'All' THEN
--             l_sumry  := ' BIL_BI_PIPE_G_MV ';
             l_fst := ' BIL_BI_FST_G_MV ';
             l_product_where_clause := ' AND grp_total_flag = 1 ';
             l_pipe_group_by := ' ';
             l_denorm := ' ';
          ELSE
--             l_sumry  := ' BIL_BI_PIPE_G_MV ';
             l_fst := ' BIL_BI_FST_PG_MV ';
             l_product_where_clause := l_prod_where_clause_pipe ||  ' AND grp_total_flag = 0 ';
             l_product_where_fst := ' AND sumry.product_category_id = :l_prodcat ';
             l_pipe_group_by := ' ,eni1.parent_id';
          END IF;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc ,
		                                    MESSAGE => 'Prod cat is '||NVL(l_prodcat, 0)||' Lang '||USERENV('LANG'));

                     END IF;



                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

	               l_sql_error_desc := ' l_curr_eff_end_date '||l_curr_eff_end_date||' l_curr_start_date '||l_curr_start_date||
                               ' l_curr_as_of_date '||l_curr_as_of_date||' l_calendar_id '|| l_calendar_id||
                               ' l_bitand_id '||l_bitand_id||' l_period_type '||l_period_type||
                               ' l_sg_id_num '||l_sg_id_num||' l_fst_crdt_type '||l_fst_crdt_type||' l_prev_eff_end_date '||l_prev_eff_end_date||
                               ' l_prev_start_date '||l_prev_start_date;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc ,
		                                    MESSAGE => 'Parameters '||l_sql_error_desc);

                     END IF;


          /* Mappings...
             VIEWBY Period
             BIL_MEASURE2 Forecast
             BIL_MEASURE3 Pipeline
             BIL_MEASURE4 Prior Forecast
             BIL_MEASURE5 Prior Pipeline
          */

          /* Query for all period types sequential comparison, and for period type year  */
             execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';
             execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP2';


          IF (l_comp_type = 'SEQUENTIAL' OR (l_comp_type = 'YEARLY' AND l_page_period_type = 'FII_TIME_ENT_YEAR')) THEN

              l_sql_stmnt1 := 'SELECT  /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */ ftime.'|| l_column_name ||' timeId '||
                                     ',SUM(DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||')) fstAmt '||
                                     ',0 pipeAmt '||
                              'FROM '|| l_table_name ||' ftime '||
                                      ','|| l_fii_struct ||' ftrs '||
                                      ','|| l_fst ||' sumry '||
                              'WHERE ftime.start_date <= :l_curr_eff_end_date '||
                                    'AND ftime.end_date >= :l_curr_start_date '||
                                    'AND ftrs.report_date = :l_curr_as_of_date '||
                                    'AND BITAND(ftrs.record_type_id,:l_bitand_id) = :l_bitand_id '||
                                    'AND ftrs.xtd_flag = :l_yes '||
                                    'AND sumry.txn_time_id = ftrs.time_id '||
                                    'AND sumry.txn_period_type_id = ftrs.period_type_id '||
                                    'AND sumry.effective_period_type_id = :l_period_type '||
                                    'AND sumry.effective_time_id = ftime.'|| l_column_name ||' '||
                                    'AND sumry.sales_group_id = :l_sg_id_num '||
                                    'AND sumry.credit_type_id = :l_fst_crdt_type '|| l_product_where_fst;
             if(l_resource_id is not null) then
                l_sql_stmnt1 := l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             else
                l_sql_stmnt1 :=l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_sql_stmnt1 :=l_sql_stmnt1  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;


              l_sql_stmnt1 := l_sql_stmnt1 ||' GROUP BY ftime.'|| l_column_name ;

/*            IF 'FII_TIME_WEEK' = l_page_period_type THEN
                 l_pipe_col := ' sumry.pipeline_amt_week'||l_currency_suffix||' ';
              ELSIF 'FII_TIME_ENT_PERIOD' = l_page_period_type THEN
                 l_pipe_col := ' sumry.pipeline_amt_period'||l_currency_suffix||' ';
              ELSIF 'FII_TIME_ENT_QTR' = l_page_period_type THEN
                 l_pipe_col := ' sumry.pipeline_amt_quarter'||l_currency_suffix||' ';
              ELSIF 'FII_TIME_ENT_YEAR' = l_page_period_type THEN
                 l_pipe_col := ' sumry.pipeline_amt_year'||l_currency_suffix||' ';
              END IF;
*/

                 l_pipe_col := bil_bi_util_pkg.get_pipe_col_names(l_page_period_type, NULL, 'P', l_currency_suffix);

                 l_sql_stmnt1 := l_sql_stmnt1 ||' UNION ALL '||
                                 'SELECT ftime.'|| l_column_name ||' timeId '||
                                        ',0 fstAmt '||
                                        ',SUM(sumry.'||l_pipe_col||') pipeAmt '||
                                 'FROM '|| l_table_name ||' ftime '||
                                       ','|| l_sumry ||' sumry '|| l_denorm ||
                                 'WHERE ftime.start_date <= :l_curr_eff_end_date '||
                                       'AND ftime.end_date >= :l_curr_start_date '||
                                       'AND sumry.snap_date = LEAST(ftime.end_date,:l_snap_date) '||
                                       'AND sumry.sales_group_id = :l_sg_id_num '|| l_product_where_clause;


                if(l_resource_id is not null) then
                l_sql_stmnt1 := l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             else
                l_sql_stmnt1 :=l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_sql_stmnt1 :=l_sql_stmnt1  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;

  l_sql_stmnt1 := l_sql_stmnt1 ||' GROUP BY ftime.'|| l_column_name || l_pipe_group_by ;


              l_sql_outer :='SELECT tmp.timeId timeId
                                   ,SUM(tmp.fstAmt) BIL_MEASURE2
                                   ,SUM(tmp.pipeAmt) BIL_MEASURE3
                                   ,NULL BIL_MEASURE4
                                   ,NULL BIL_MEASURE5
                             FROM ( '||l_sql_stmnt1||') tmp
                             GROUP BY tmp.timeId';

              l_custom_sql :='SELECT ftime.name VIEWBY
                                 ,NVL(SUM(tmp.BIL_MEASURE2) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),0)  BIL_MEASURE2
                                 ,NVL(SUM(tmp.BIL_MEASURE3) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),0)  BIL_MEASURE3
                                  ,NULL BIL_MEASURE4
                                  ,NULL BIL_MEASURE5
                              FROM ( '||l_sql_outer||') tmp,'||l_table_name||' ftime
                              WHERE ftime.start_date <= :l_curr_eff_end_date
                                    AND ftime.end_date > :curr_prd_start_date
                                    AND ftime.'||l_column_name||' = tmp.timeId(+)
                              ORDER BY ftime.end_date';



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


           ELSIF (l_comp_type = 'YEARLY' AND l_page_period_type = 'FII_TIME_WEEK') THEN       /*query for yearly week only */

                execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';
                execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP2';

                 l_pipe_col := bil_bi_util_pkg.get_pipe_col_names(l_page_period_type, NULL, 'P', l_currency_suffix);

                 l_sql_stmnt1 :='SELECT  /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */ ftime.sequence timeSequence '||
                                      ',SUM(DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||')) forecast_amt '||
                                      ',0 pipe_amt '||
                                      ',0 prior_forecast_amt '||
                                      ',0 prior_pipe_amt '||
                                'FROM '|| l_table_name ||' ftime '||
                                      ','|| l_fii_struct ||' ftrs '||
                                      ','|| l_fst ||' sumry '||
                                'WHERE ftime.start_date <=  :l_curr_eff_end_date '||
                                      'AND ftime.end_date >= :l_curr_start_date '||
                                      'AND ftrs.report_date = :l_curr_as_of_date '||
                                      'AND BITAND(ftrs.record_type_id, :l_bitand_id) = :l_bitand_id '||
                                      'AND ftrs.xtd_flag = :l_yes '||
                                      'AND sumry.txn_time_id = ftrs.time_id '||
                                      'AND sumry.txn_period_type_id = ftrs.period_type_id '||
                                      'AND sumry.effective_period_type_id = :l_period_type '||
                                      'AND sumry.effective_time_id = ftime.'|| l_column_name ||' '||
                                      'AND sumry.credit_type_id = :l_fst_crdt_type ';

            if(l_resource_id is not null) then
                l_sql_stmnt1 := l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             else
                l_sql_stmnt1 :=l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_sql_stmnt1 :=l_sql_stmnt1  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;

                 l_sql_stmnt1 := l_sql_stmnt1 ||
                                 ' AND sumry.sales_group_id = :l_sg_id_num '|| l_product_where_fst ||
                                 ' GROUP BY ftime.sequence ';

                    l_sql_stmnt1 := l_sql_stmnt1 ||
                                    ' UNION ALL '||
                                    'SELECT ftime.sequence timeSequence '||
                                            ',0 forecast_amt '||
                                            ',SUM(sumry.'||l_pipe_col||') pipe_amt '||
                                            ',0 prior_forecast_amt '||
                                            ',0 prior_pipe_amt '||
                                     'FROM '|| l_table_name ||' ftime '||
                                           ','|| l_sumry ||' sumry '|| l_denorm ||
                                     'WHERE ftime.start_date <=  :l_curr_eff_end_date '||
                                           'AND ftime.end_date >= :l_curr_start_date '||
                                           'AND sumry.snap_date = LEAST(:l_snap_date,ftime.end_date) ';

                    -- ',SUM(sumry.pipeline_amt_week'||l_currency_suffix||') pipe_amt '||

           if(l_resource_id is not null) then
                l_sql_stmnt1 := l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             else
                l_sql_stmnt1 :=l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_sql_stmnt1 :=l_sql_stmnt1  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;


                 l_sql_stmnt1 := l_sql_stmnt1 ||'AND sumry.sales_group_id = :l_sg_id_num '|| l_product_where_clause ||
                                    ' GROUP BY ftime.sequence' || l_pipe_group_by;

                 l_insert_stmnt := 'INSERT INTO BIL_BI_RPT_TMP1(VIEWBY, BIL_MEASURE2, BIL_MEASURE3, BIL_MEASURE4, BIL_MEASURE5)';

                 BEGIN


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_sql_stmnt1);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_sql_stmnt1, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


                   IF 'All' = l_prodcat THEN
                         IF l_resource_id IS NULL THEN
                         IF l_parent_sls_grp_id IS NOT NULL THEN
                               EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                               USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date,l_bitand_id
                                    ,l_bitand_id, l_yes, l_period_type,l_fst_crdt_type,l_parent_sls_grp_id, l_sg_id_num
                                    ,l_curr_eff_end_date,l_curr_start_date,l_snap_date,l_parent_sls_grp_id,l_sg_id_num;
                          ELSE
                               EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                               USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date,l_bitand_id
                                    ,l_bitand_id,l_yes, l_period_type,l_fst_crdt_type, l_sg_id_num
                                    ,l_curr_eff_end_date,l_curr_start_date,l_snap_date,l_sg_id_num;
                         END IF;
                         ELSE
                               EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                               USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date,l_bitand_id
                                    ,l_bitand_id, l_yes, l_period_type,l_fst_crdt_type,l_resource_id,l_sg_id_num, l_sg_id_num
                                    ,l_curr_eff_end_date,l_curr_start_date,l_snap_date,l_resource_id, l_sg_id_num, l_sg_id_num;
                         END IF;
                     ELSIF 'All' <> l_prodcat THEN
                         IF l_resource_id IS NULL THEN
                          IF l_parent_sls_grp_id IS NULL THEN
                               EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                               USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date,l_bitand_id,l_bitand_id,l_yes, l_period_type
                                    ,l_fst_crdt_type,l_sg_id_num,REPLACE(l_prodcat,'''')
                                    ,l_curr_eff_end_date,l_curr_start_date,l_snap_date,l_sg_id_num,REPLACE(l_prodcat,'''');
                         ELSE
                               EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                               USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                    ,l_fst_crdt_type,l_parent_sls_grp_id, l_sg_id_num,REPLACE(l_prodcat,'''')
                                    ,l_curr_eff_end_date,l_curr_start_date,l_snap_date,l_parent_sls_grp_id, l_sg_id_num,REPLACE(l_prodcat,'''');
                         END IF;
                         ELSE
                                EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt1
                                USING l_curr_eff_end_date,l_curr_start_date,l_curr_as_of_date,l_bitand_id,l_bitand_id, l_yes, l_period_type,
                                     l_fst_crdt_type,l_resource_id,l_sg_id_num, l_sg_id_num, REPLACE(l_prodcat,'''')
                                     ,l_curr_eff_end_date,l_curr_start_date,l_snap_date,l_resource_id,l_sg_id_num, l_sg_id_num, REPLACE(l_prodcat,'''');
                         END IF;
                     END IF;
                     COMMIT;

                 EXCEPTION
                 WHEN OTHERS THEN

                      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                         fnd_message.set_token('ERROR' ,SQLCODE);
                         fnd_message.set_token('REASON', SQLERRM);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

                     END IF;

                 END;

                 l_sql_stmnt2 := 'SELECT  /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */ ftime.sequence timeSequence '||
                                        ',0 forecast_amt '||
                                        ',0 pipe_amt '||
                                        ',SUM(DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||')) prior_forecast_amt '||
                                        ',0 prior_pipe_amt '||
                                 'FROM '|| l_table_name ||' ftime '||
                                       ','|| l_fii_struct ||' ftrs '||
                                       ','|| l_fst ||' sumry '||
                                 'WHERE ftime.start_date <=  :l_prev_eff_end_date '||
                                       'AND ftime.end_date >= :l_prev_start_date '||
--                                       'AND ftrs.report_date = :l_prev_date '||
                                       'AND ftrs.report_date = :l_prev_snap_date '||
                                       'AND BITAND(ftrs.record_type_id, :l_bitand_id) = :l_bitand_id '||
                                       'AND ftrs.xtd_flag = :l_yes '||
                                       'AND sumry.txn_time_id = ftrs.time_id '||
                                       'AND sumry.txn_period_type_id = ftrs.period_type_id '||
                                       'AND sumry.effective_period_type_id = :l_period_type '||
                                       'AND sumry.effective_time_id = ftime.'|| l_column_name ||' '||
                                       'AND sumry.sales_group_id = :l_sg_id_num '|| l_product_where_fst ||
                                       'AND sumry.credit_type_id = :l_fst_crdt_type ';

              if(l_resource_id is not null) then
                l_sql_stmnt2 := l_sql_stmnt2  ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             else
                l_sql_stmnt2 :=l_sql_stmnt2  ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_sql_stmnt2 :=l_sql_stmnt2  || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_sql_stmnt2 :=l_sql_stmnt2  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;

                 l_sql_stmnt2 := l_sql_stmnt2 ||' GROUP BY ftime.sequence ';

                     l_sql_stmnt2 := l_sql_stmnt2 || 'UNION ALL '||
                                    'SELECT ftime.sequence timeSequence '||
                                           ',0 forecast_amt '||
                                           ',0 pipe_amt '||
                                           ',0 prior_forecast_amt '||
                                           ',SUM(sumry.'||l_pipe_col||') prior_pipe_amt '||
--                                          ',SUM(sumry.pipeline_amt_week'||l_currency_suffix||') prior_pipe_amt '||
                                     'FROM '|| l_table_name ||' ftime '||
                                           ','|| l_sumry ||' sumry '|| l_denorm ||
                                     ' WHERE ftime.start_date <=  :l_prev_eff_end_date '||
                                           'AND ftime.end_date >= :l_prev_start_date '||
                                           'AND sumry.snap_date = LEAST(:l_prev_snap_date,ftime.end_date) '||
                                           'AND sumry.sales_group_id = :l_sg_id_num ';

              if(l_resource_id is not null) then
                l_sql_stmnt2 := l_sql_stmnt2  ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             else
                l_sql_stmnt2 :=l_sql_stmnt2  ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_sql_stmnt2 :=l_sql_stmnt2  || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_sql_stmnt2 :=l_sql_stmnt2  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;

                 l_sql_stmnt2 := l_sql_stmnt2 || l_product_where_clause ||' GROUP BY ftime.sequence'|| l_pipe_group_by;

                 l_insert_stmnt := 'INSERT INTO BIL_BI_RPT_TMP1(VIEWBY, BIL_MEASURE2, BIL_MEASURE3, BIL_MEASURE4, BIL_MEASURE5)';

                 BEGIN


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(l_sql_stmnt2);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(l_sql_stmnt2, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' statement ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                     END IF;


                     IF 'All' = l_prodcat THEN
                        IF l_resource_id IS NULL THEN
                          IF l_parent_sls_grp_id IS NULL THEN
                              EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                              USING l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_bitand_id,l_bitand_id, l_yes
                                   ,l_period_type,l_sg_id_num,l_fst_crdt_type
                                   ,l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_sg_id_num;
                         ELSE
                              EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                              USING l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_bitand_id,l_bitand_id, l_yes
                                   ,l_period_type, l_sg_id_num,l_fst_crdt_type, l_parent_sls_grp_id
                                   ,l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date, l_sg_id_num, l_parent_sls_grp_id;
                         END IF;
                        ELSE
                              EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                              USING l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_bitand_id,l_bitand_id, l_yes
                                   ,l_period_type,l_sg_id_num,l_fst_crdt_type,l_resource_id, l_sg_id_num
                                   ,l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_sg_id_num,l_resource_id, l_sg_id_num;
                        END IF;

                     ELSIF 'All' <> l_prodcat THEN
                          IF l_resource_id IS NULL THEN
                           IF l_parent_sls_grp_id IS NULL THEN
                                EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                USING l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                     ,l_sg_id_num,REPLACE(l_prodcat,''''),l_fst_crdt_type
                                     ,l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_sg_id_num,REPLACE(l_prodcat,'''');
                          ELSE
                                EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                USING l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_bitand_id,l_bitand_id,l_yes, l_period_type
                                     ,l_sg_id_num,REPLACE(l_prodcat,''''),l_fst_crdt_type, l_parent_sls_grp_id
                                     ,l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_sg_id_num,l_parent_sls_grp_id, REPLACE(l_prodcat,'''');
                          END IF;

                          ELSE
                                EXECUTE IMMEDIATE l_insert_stmnt || l_sql_stmnt2
                                USING l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date
                                ,l_bitand_id,l_bitand_id, l_yes, l_period_type
                                     ,l_sg_id_num,REPLACE(l_prodcat,''''),l_fst_crdt_type
                                     ,l_resource_id, l_sg_id_num
                                     ,l_prev_eff_end_date,l_prev_start_date,l_prev_snap_date,l_sg_id_num, l_resource_id,l_sg_id_num, REPLACE(l_prodcat,'''');
                          END IF;
                     END IF;
                     COMMIT;

                     EXCEPTION
                     WHEN OTHERS THEN

                     IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                             fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                             fnd_message.set_token('ERROR',SQLCODE);
                             fnd_message.set_token('REASON',SQLERRM);
                             fnd_message.set_token('ROUTINE',l_proc);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

                     END IF;

                     END;

                     l_sql_outer := 'SELECT VIEWBY
                                           ,SUM(BIL_MEASURE2) BIL_MEASURE2
                                           ,SUM(BIL_MEASURE3) BIL_MEASURE3
                                           ,SUM(BIL_MEASURE4) BIL_MEASURE4
                                           ,SUM(BIL_MEASURE5) BIL_MEASURE5
                                     FROM BIL_BI_RPT_TMP1
                                     GROUP BY VIEWBY';

                    l_insert_stmnt := 'INSERT INTO BIL_BI_RPT_TMP2(VIEWBY, BIL_MEASURE2, BIL_MEASURE3, BIL_MEASURE4, BIL_MEASURE5)';

                    BEGIN
                        EXECUTE IMMEDIATE l_insert_stmnt || l_sql_outer;
                        COMMIT;
                        EXCEPTION
                          WHEN OTHERS THEN

                     IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                 fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                                 fnd_message.set_token('ERROR',SQLCODE);
                                 fnd_message.set_token('REASON',SQLERRM);
                                 fnd_message.set_token('ROUTINE',l_proc);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

                     END IF;

                    END;

                    l_custom_sql := 'Select ftime.name VIEWBY
                                ,NVL(SUM(tmp.BIL_MEASURE2) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),0) BIL_MEASURE2
                                ,NVL(SUM(tmp.BIL_MEASURE3) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),0) BIL_MEASURE3
                                ,NVL(SUM(tmp.BIL_MEASURE4) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),0) BIL_MEASURE4
                                ,NVL(SUM(tmp.BIL_MEASURE5) OVER (ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),0) BIL_MEASURE5
                                FROM BIL_BI_RPT_TMP2 tmp,  '||l_table_name||' ftime
                                WHERE ftime.start_date <= :l_curr_eff_end_date
                                      AND ftime.end_date > :curr_prd_start_date
                                      AND ftime.sequence = tmp.VIEWBY(+)
                                ORDER BY ftime.end_date ';



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


          /* Query for month and quarter year/year comparison*/
          ELSE

               execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';
               execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP2';


/*            IF 'FII_TIME_ENT_PERIOD' = l_page_period_type THEN
                 l_pipe_col := ' sumry.pipeline_amt_period'||l_currency_suffix||' ';
              ELSE
                 l_pipe_col := ' sumry.pipeline_amt_quarter'||l_currency_suffix||' ';
              END IF;
*/
            l_pipe_col := bil_bi_util_pkg.get_pipe_col_names(l_page_period_type, NULL, 'P', l_currency_suffix);


            l_sql_stmnt1 := 'SELECT  /*+ ORDERED INDEX (ftime, '||l_page_period_type||'_N1) USE_NL (ftime ftrs sumry) */ ftime.sequence time_sequence '||
                                     ',(CASE WHEN ftrs.report_date = :l_curr_as_of_date AND ftime.end_date > :l_curr_start_date '||
                                           ' THEN DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||') ELSE 0 END) currFstAmt '||
                                     ',0 currpipeAmt '||
                                     ',(CASE WHEN ftrs.report_date = :l_prev_snap_date AND ftime.end_date < :l_curr_start_date'||
                                           ' THEN DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',sumry.forecast_amt'||l_currency_suffix||') ELSE 0 END) prevFstAmt '||
                                     ',0 prevpipeAmt '||
                              'FROM '|| l_table_name ||' ftime '||
                                    ','|| l_fii_struct ||' ftrs '||
                                    ','|| l_fst ||' sumry '||
                              'WHERE ftime.start_date <= :l_curr_eff_end_date '||
                                    'AND ftime.end_date >= :l_prev_start_date '||
                                    'AND ftrs.report_date IN (:l_prev_snap_date,:l_curr_as_of_date) '||
                                    'AND BITAND(ftrs.record_type_id, :l_bitand_id) = :l_bitand_id '||
                                    'AND ftrs.xtd_flag = :l_yes '||
                                    'AND sumry.txn_time_id = ftrs.time_id '||
                                    'AND sumry.txn_period_type_id = ftrs.period_type_id '||
                                    'AND sumry.effective_period_type_id = :l_period_type '||
                                    'AND sumry.effective_time_id = ftime.'|| l_column_name ||' '||
                                    'AND sumry.credit_type_id = :l_fst_crdt_type ';

             if(l_resource_id is not null) then
                l_sql_stmnt1 := l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             else
                l_sql_stmnt1 :=l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_sql_stmnt1 :=l_sql_stmnt1  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;

                 l_sql_stmnt1 := l_sql_stmnt1 ||' AND sumry.sales_group_id = :l_sg_id_num '|| l_product_where_fst;

                 l_sql_stmnt1 := l_sql_stmnt1 ||'UNION ALL '||
                                'SELECT ftime.sequence time_sequence '||
                                       ',0 currFstAmt  '||
                                       ',sum(CASE WHEN ftime.end_date > :l_curr_start_date '||
                                             ' THEN '|| l_pipe_col ||' ELSE 0 END) currpipeAmt '||
                                       ',0 prevFstAmt '||
                                       ',sum(CASE WHEN ftime.end_date < :l_curr_start_date '||
                                             ' THEN '|| l_pipe_col ||' ELSE 0 END) prevpipeAmt '||
                                'FROM '|| l_table_name ||' ftime '||
                                      ','|| l_sumry ||' sumry '|| l_denorm ||
                                'WHERE ftime.start_date <= :l_curr_eff_end_date '||
                                      'AND ftime.end_date >= :l_prev_start_date '||
                                      'AND sumry.snap_date = LEAST((CASE WHEN :l_prev_snap_date BETWEEN ftime.start_date AND ftime.end_date
                                                                    THEN :l_prev_snap_date ELSE ftime.end_date END),:l_snap_date) ';

            if(l_resource_id is not null) then
                l_sql_stmnt1 := l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id_num ';
             else
                l_sql_stmnt1 :=l_sql_stmnt1  ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_sql_stmnt1 :=l_sql_stmnt1  || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_sql_stmnt1 :=l_sql_stmnt1  ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;

               l_sql_stmnt1 := l_sql_stmnt1||' AND sumry.sales_group_id = :l_sg_id_num '||
				l_product_where_clause ||' GROUP BY ftime.sequence'|| l_pipe_group_by;

              l_sql_outer := 'SELECT tmp.time_sequence VIEWBY
                                    ,SUM(tmp.currFstAmt) BIL_MEASURE2
                                    ,SUM(tmp.currpipeAmt) BIL_MEASURE3
                                    ,SUM(tmp.prevFstAmt) BIL_MEASURE4
                                    ,SUM(tmp.prevpipeAmt) BIL_MEASURE5
                              FROM ('||l_sql_stmnt1||') tmp
                              GROUP BY tmp.time_sequence';

              l_custom_sql := 'SELECT ftime.name VIEWBY
                              ,NVL(SUM(BIL_MEASURE2) OVER(ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
					0) BIL_MEASURE2
                              ,NVL(SUM(BIL_MEASURE3) OVER(ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
					0) BIL_MEASURE3
                              ,NVL(SUM(BIL_MEASURE4) OVER(ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
					0) BIL_MEASURE4
                              ,NVL(SUM(BIL_MEASURE5) OVER(ORDER BY ftime.end_date RANGE UNBOUNDED PRECEDING),
					0) BIL_MEASURE5
                               FROM ( '||l_sql_outer||') tmp,'||l_table_name||' ftime
                               WHERE ftime.start_date <= :l_curr_eff_end_date
                                      AND ftime.end_date > :curr_prd_start_date
                                      AND ftime.sequence = tmp.VIEWBY(+)
                               ORDER BY ftime.end_date ';


          END IF;

      ELSE --p_valid_param false
         BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                          ,x_sqlstr     => l_default_query);
         l_custom_sql := l_default_query;
      END IF;

      x_custom_sql := l_custom_sql;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' Final Query to PMV ',
		        MESSAGE => l_str);

                        l_ind := l_ind + 4000;

                       END LOOP;
                    END IF;


      l_bind_ctr := 1;

      x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

      l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
      l_custom_rec.attribute_value := l_viewby;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name :=':curr_prd_start_date';
      l_custom_rec.attribute_value := TO_CHAR(l_curr_start_date,'dd/mm/yyyy');
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr := l_bind_ctr + 1;

      l_custom_rec.attribute_name :=':l_curr_eff_end_date';
      l_custom_rec.attribute_value :=TO_CHAR(l_curr_eff_end_date,'dd/mm/yyyy');
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr := l_bind_ctr + 1;

      l_custom_rec.attribute_name := ':l_curr_start_date';
      l_custom_rec.attribute_value := TO_CHAR(l_curr_start_date,'dd/mm/yyyy');
      l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
      l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name := ':l_prev_start_date';
      l_custom_rec.attribute_value := TO_CHAR(l_prev_start_date,'dd/mm/yyyy');
      l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
      l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name := ':l_curr_as_of_date';
      l_custom_rec.attribute_value := TO_CHAR(l_curr_as_of_date,'dd/mm/yyyy');
      l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
      l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name := ':l_snap_date';
      l_custom_rec.attribute_value := TO_CHAR(l_snap_date,'dd/mm/yyyy');
      l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
      l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name := ':l_record_type_id';
      l_custom_rec.attribute_value := l_record_type_id;
      l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
      l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
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


              l_custom_rec.attribute_name :=':l_yes';
         l_custom_rec.attribute_value :=l_yes;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
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

      l_custom_rec.attribute_name :=':l_sg_id_num';
      l_custom_rec.attribute_value := l_sg_id_num;
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;


      if(l_parent_sls_grp_id is not null) then
         l_custom_rec.attribute_name :=':l_parent_sls_grp_id';
         l_custom_rec.attribute_value :=l_parent_sls_grp_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
    end if;

      l_custom_rec.attribute_name := ':l_resource_id';
      l_custom_rec.attribute_value := l_resource_id;
      l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
      l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr) := l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name :=':l_fst_crdt_type';
      l_custom_rec.attribute_value :=l_fst_crdt_type;
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;

      l_custom_rec.attribute_name := ':l_prev_snap_date';
      l_custom_rec.attribute_value := to_char(l_prev_snap_date,'dd/mm/yyyy');
      l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
      l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;

      l_bind_ctr:=l_bind_ctr+1;

      IF l_prodcat IS NOT NULL THEN
         l_custom_rec.attribute_name :=':l_prodcat';
         l_custom_rec.attribute_value :=l_prodcat;
         l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
      END IF;

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc||'end',
		                                    MESSAGE => 'End of Procedure '|| l_proc);

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

END BIL_BI_FRCST_PIPE_TREND;


 /*******************************************************************************
 * Name    : Procedure BIL_BI_FRCST_PIPE_WON_TREND
 * Author  : Krishna
 * Date    : 24 Dec, 2003
 * Purpose : Forecast, Pipeline, Won - Opportunity Performance Reports
 *
 *           Copyright (c) 2003 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 *
 * Date        Author     Description
 * ----        ------     -----------
 * 24 Dec 2003 krsundar   Created
 * 25 Feb 2004 krsundar   Snap date logic for pipeline and changed, fii_time_structures uptake
 * 08 Mar 2004 krsundar   Forecast related changes, pipeline : grp_total_flag = 1
 * 28 May 2004 ctoba      Performance fixes
 * 02 Jun 2004 ctoba       Pipeline related changes (do rollup on product in front end)
 ******************************************************************************/
PROCEDURE BIL_BI_FRCST_PIPE_WON_TREND(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                     ,x_custom_sql OUT NOCOPY VARCHAR2
                                     ,x_custom_attr OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_period_type             VARCHAR2(200);
    l_conv_rate_selected      VARCHAR2(200);
    l_sg_id                   VARCHAR2(200);
    l_resource_id             VARCHAR2(20);
    l_prodcat                 VARCHAR2(100);
    l_product_id              VARCHAR2(20);
    l_curr_page_time_id       NUMBER;
    l_prev_page_time_id       NUMBER;
    l_comp_type               VARCHAR2(50);
    l_parameter_valid         BOOLEAN;
    l_curr_as_of_date         DATE;
    l_page_period_type        VARCHAR2(100);
    l_prev_date               DATE;
    l_record_type_id          NUMBER;
    l_viewby                  VARCHAR2(200);
    l_bitand_id               VARCHAR2(10);
    l_calendar_id             VARCHAR2(10);
    l_bis_sysdate             Date;
    l_fii_struct              VARCHAR2(100);
    l_custom_rec              BIS_QUERY_ATTRIBUTES;
    l_sg_id_num               NUMBER;
    l_custom_sql              VARCHAR2(10000);
    l_prior_str               VARCHAR2(5000);
    l_bind_ctr                NUMBER;
    l_default_query           VARCHAR2(2000);
    l_time_sql                VARCHAR2(3200);
    l_frcst_tab               VARCHAR2(50);
    l_won_tab                 VARCHAR2(100);
    l_pipe_tab                VARCHAR2(100);
    l_sg_where                VARCHAR2(200);
    l_sg_where_fst            VARCHAR2(200);
    l_fst_crdt_type           VARCHAR2(100);
    l_show_period             VARCHAR2(50);
    l_pipe_col                VARCHAR2(100);
    l_snapshot_date           DATE;
    l_proc                    VARCHAR2(100);
    l_region_id               VARCHAR2(100);
    l_where_pipe              VARCHAR2(500);
    l_productcat_where_fst    VARCHAR2(200);
    l_parent_sls_grp_id       NUMBER;
    l_curr_eff_end_date       DATE;
    l_curr_eff_start_date     DATE;
    l_pipe_group_by           VARCHAR2(100);
    l_yes                     VARCHAR2(1);
    l_denorm                  VARCHAR2(100);
    l_pc_norollup_where       VARCHAR2(500);
    l_currency_suffix         VARCHAR2(5);
    l_prev_snap_date          DATE;
    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

BEGIN
	/* Intializing Variables*/
	g_pkg := 'bil.patch.115.sql.BIL_BI_TREND_MGMT_RPTS_PKG.';
	l_parameter_valid := FALSE;
	l_proc := 'BIL_BI_FRCST_PIPE_WON_TREND.';

    l_region_id := 'BIL_BI_FRCST_PIPE_WON_TREND';
    l_productcat_where_fst := ' ';
    l_yes := 'Y';
    g_sch_name := 'BIL';


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                         FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                        MODULE => g_pkg || l_proc || 'begin',
                                        MESSAGE => ' Start of Procedure '|| l_proc);

    END IF;


    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

     BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl =>p_page_parameter_tbl,
                           p_region_id                 =>l_region_id,
                           x_period_type               =>l_period_type,
                           x_conv_rate_selected        =>l_conv_rate_selected,
                           x_sg_id                     =>l_sg_id,
                           x_parent_sg_id              => l_parent_sls_grp_id,
                           x_resource_id               =>l_resource_id,
                           x_prodcat_id                =>l_prodcat,
                           x_curr_page_time_id         =>l_curr_page_time_id,
                           x_prev_page_time_id         =>l_prev_page_time_id,
                           x_comp_type                 =>l_comp_type,
                           x_parameter_valid           =>l_parameter_valid,
                           x_as_of_date                =>l_curr_as_of_date,
                           x_page_period_type          =>l_page_period_type,
                           x_prior_as_of_date          =>l_prev_date,
                           x_record_type_id            =>l_record_type_id,
                           x_viewby                    =>l_viewby);

    IF p_page_parameter_tbl IS NOT NULL THEN
        FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
            CASE p_page_parameter_tbl(i).parameter_name
			WHEN 'BIS_CURRENT_EFFECTIVE_START_DATE' THEN
                 		l_curr_eff_start_date := p_page_parameter_tbl(i).PERIOD_DATE;
			WHEN 'BIS_CURRENT_EFFECTIVE_END_DATE' THEN
                 		l_curr_eff_end_date := p_page_parameter_tbl(i).PERIOD_DATE;
		ELSE
			NULL;
		END CASE;
	END LOOP;
   END IF;

   IF l_parameter_valid THEN

        l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));

        BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id   => l_bitand_id,
                                         x_calendar_id => l_calendar_id,
                                         x_curr_date   => l_bis_sysdate,
                                         x_fii_struct  => l_fii_struct);

        bil_bi_util_pkg.get_forecast_profiles(x_FstCrdtType => l_fst_crdt_type);

        IF l_conv_rate_selected = 0 THEN         /*this part moved for BUG 4000977*/
            l_currency_suffix := '_s';
        ELSE
            l_currency_suffix := '';
        END IF;

        IF 'FII_TIME_ENT_YEAR' = l_page_period_type THEN
            l_viewby:='TIME+FII_TIME_ENT_PERIOD';
            l_show_period := 'FII_TIME_ENT_PERIOD ';
--            l_pipe_col := ' sumry.pipeline_amt_year'||l_currency_suffix;
        ELSIF 'FII_TIME_ENT_QTR' = l_page_period_type THEN
            l_viewby:='TIME+FII_TIME_WEEK';
            l_show_period := ' FII_TIME_WEEK ';
--            l_pipe_col := ' sumry.pipeline_amt_quarter'||l_currency_suffix;
        ELSIF 'FII_TIME_ENT_PERIOD' = l_page_period_type THEN
            l_viewby:='TIME+FII_TIME_WEEK';
            l_show_period := ' FII_TIME_WEEK ';
--            l_pipe_col := ' sumry.pipeline_amt_period'||l_currency_suffix;
        ELSIF 'FII_TIME_WEEK' = l_page_period_type THEN
            l_viewby:='TIME+FII_TIME_DAY';
            l_show_period := ' FII_TIME_DAY ';
--            l_pipe_col := ' sumry.pipeline_amt_week'||l_currency_suffix;
        END IF;

        l_pipe_col := bil_bi_util_pkg.get_pipe_col_names(l_page_period_type, NULL, 'P', l_currency_suffix);


/*        BIL_BI_UTIL_PKG.GET_LATEST_SNAP_DATE(p_page_parameter_tbl  => p_page_parameter_tbl,
                                             p_as_of_date          => l_curr_as_of_date,
                                             p_period_type         => l_page_period_type,
                                             x_snapshot_date       => l_snapshot_date);
*/


         BIL_BI_UTIL_PKG.get_PC_NoRollup_Where_Clause(
						p_prodcat   => l_prodcat,
						p_viewby    => l_viewby,
						x_denorm    => l_denorm,
						x_where_clause => l_pc_norollup_where);


        IF 'ALL' = UPPER(l_prodcat) OR l_prodcat IS NULL THEN
            l_where_pipe := ' AND grp_total_flag = 1 ';
            l_frcst_tab := ' bil_bi_fst_g_mv ';
            l_won_tab  := ' bil_bi_opty_g_mv sumry';
--            l_pipe_tab := l_pipe_tab||' sumry';
        ELSE
            l_where_pipe := ' AND sumry.grp_total_flag = 0';
            l_productcat_where_fst := ' AND sumry.product_category_id(+) = :l_prodcat ';
            l_frcst_tab := ' bil_bi_fst_pg_mv ';
            l_won_tab   := ' bil_bi_opty_pg_mv sumry ';
--            l_pipe_tab  := l_pipe_tab||' sumry';
        END IF;

        IF l_resource_id IS NULL THEN
            IF l_parent_sls_grp_id IS NOT NULL THEN
                l_sg_where_fst := ' AND sumry.salesrep_id IS NULL AND sumry.sales_group_id(+) = :l_sg_id
                                AND sumry.parent_sales_group_id(+) = :l_parent_sls_grp_id ';
                l_sg_where := ' AND sumry.salesrep_id IS NULL AND sumry.sales_group_id = :l_sg_id
                               AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
            ELSE
                l_sg_where_fst := ' AND sumry.salesrep_id IS NULL AND sumry.sales_group_id(+) = :l_sg_id
                                AND sumry.parent_sales_group_id IS NULL ';
                l_sg_where := ' AND sumry.salesrep_id IS NULL AND sumry.sales_group_id = :l_sg_id
                               AND sumry.parent_sales_group_id IS NULL ';
            END IF;

        ELSE
           l_sg_where_fst := ' AND sumry.salesrep_id(+) = :l_resource_id AND sumry.sales_group_id(+) = :l_sg_id
                                AND sumry.parent_sales_group_id(+) = :l_sg_id ';
           l_sg_where := ' AND sumry.salesrep_id = :l_resource_id AND sumry.sales_group_id = :l_sg_id
                             AND   sumry.parent_sales_group_id = :l_sg_id ';
        END IF;

            l_time_sql := 'SELECT rownum viewbyid, start_date, end_date FROM
                          (SELECT (CASE WHEN show_period.end_date > :l_curr_eff_end_date
                                       THEN :l_curr_eff_end_date
                                       ELSE show_period.end_date
                                 END) end_date
                                ,show_period.start_date
                          FROM '||
                          l_show_period ||' show_period
                          WHERE
                          show_period.start_date <= :l_curr_eff_end_date
                          AND show_period.end_date >= :l_curr_eff_start_date
                          ORDER BY show_period.start_date)';

        begin
            execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';
        end;

    	BEGIN
      execute immediate 'insert into BIL_BI_RPT_TMP1 (viewbyid, date1, date2)  ('||l_time_sql||') '
					using  l_curr_eff_end_date, l_curr_eff_end_date,
							l_curr_eff_end_date, l_curr_eff_start_date;
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
         END;
           /*Mappings...
            * BIL_MEASURE1 - Forecast
            * BIL_MEASURE2 - Pipeline
            * BIL_MEASURE3 - Won
            */


         BIL_BI_UTIL_PKG.GET_PIPE_TREND_SOURCE(p_as_of_date    => l_curr_as_of_date
                                             ,p_prev_date      => NULL
                                             ,p_trend_type    => 'P'
                                             ,p_period_type   => l_page_period_type
                                             ,p_page_parameter_tbl  => p_page_parameter_tbl
                                             ,x_pipe_mv       => l_pipe_tab
                                             ,x_snap_date     => l_snapshot_date
                                             ,x_prev_snap_date => l_prev_snap_date);

              l_custom_sql := 'SELECT  temp.date2 VIEWBY, SUM(opty.BIL_MEASURE1) BIL_MEASURE1
                             ,SUM(opty.BIL_MEASURE2) BIL_MEASURE2
                             ,(CASE WHEN opty.viewby_date > &BIS_CURRENT_ASOF_DATE THEN NULL ELSE
				NVL(SUM(opty.BIL_MEASURE3),0) END) BIL_MEASURE3
                              FROM (SELECT /*+ leading(time) */ time.date2 VIEWBY,time.date1 viewby_date
                        ,SUM(CASE WHEN time.date1 > &BIS_CURRENT_ASOF_DATE
                             THEN NULL
                             ELSE DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',
                             sumry.forecast_amt'||l_currency_suffix||') END)  BIL_MEASURE1
                        ,NULL BIL_MEASURE2
                        ,NULL BIL_MEASURE3
                        FROM
                         bil_bi_rpt_tmp1 time
                        ,'||l_frcst_tab||' sumry
                        ,'||l_fii_struct||' cal
                        WHERE
                           cal.report_date = LEAST(&BIS_CURRENT_ASOF_DATE,time.date2)
                           AND cal.period_type_id = sumry.txn_period_type_id(+)
                           AND BITAND(cal.record_type_id,:l_bitand_id) = :l_bitand_id
                           AND sumry.effective_time_id(+) = :l_curr_page_time_id
                           AND sumry.effective_period_type_id(+) = :l_period_type
                           AND sumry.txn_time_id(+) = cal.time_id
                           AND cal.xtd_flag = :l_yes
                           AND sumry.credit_type_id(+) = :l_fst_crdt_type '
                           || l_productcat_where_fst || l_sg_where_fst;
                 l_custom_sql := l_custom_sql ||' GROUP BY time.date2,time.date1
                                                UNION ALL';

          IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN
                l_custom_sql := l_custom_sql ||' SELECT
                           VIEWBY,
                           viewby_date,
                           SUM(BIL_MEASURE1) BIL_MEASURE1,
                           SUM(BIL_MEASURE2) BIL_MEASURE2,
                           SUM(BIL_MEASURE3) BIL_MEASURE3
                           FROM
                          (';
          END IF;

                 l_custom_sql := l_custom_sql || ' SELECT  time.date2 VIEWBY,time.date1 viewby_date ';

                  IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN
                   l_custom_sql := l_custom_sql || '  ,sumry.product_category_id ';
                  END IF;


                  IF (l_page_period_type = 'FII_TIME_WEEK' AND l_pipe_tab = 'BIL_BI_PIPE_G_MV') THEN

                     l_custom_sql := l_custom_sql || ' ,NULL BIL_MEASURE1
                                       ,SUM(CASE WHEN time.date1 > &BIS_CURRENT_ASOF_DATE
                                                 THEN NULL
                                                 ELSE '||l_pipe_col||'
                                            END) BIL_MEASURE2
                                       ,NULL BIL_MEASURE3
                                 FROM bil_bi_rpt_tmp1 time
                                      ,'||l_pipe_tab||' sumry
                                 WHERE sumry.snap_date = :l_snapshot_date '||
                                 l_where_pipe || l_sg_where || 'GROUP BY time.date2,time.date1 ';

                  ELSE

                     l_custom_sql := l_custom_sql || ' ,NULL BIL_MEASURE1
                                       ,SUM(CASE WHEN time.date1 > &BIS_CURRENT_ASOF_DATE
                                                 THEN NULL
                                                 ELSE '||l_pipe_col||'
                                            END) BIL_MEASURE2
                                       ,NULL BIL_MEASURE3
                                 FROM bil_bi_rpt_tmp1 time
                                      ,'||l_pipe_tab||' sumry
                                 WHERE sumry.snap_date = LEAST(:l_snapshot_date,time.date2)'||
                                 l_where_pipe || l_sg_where || 'GROUP BY time.date2,time.date1 ';

                  END IF;

                  IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN
                   l_custom_sql := l_custom_sql || '  ,sumry.product_category_id';
                  END IF;

            l_custom_sql := l_custom_sql || ' UNION ALL ';

              l_custom_sql := l_custom_sql ||'
                         SELECT  tmp.date2 VIEWBY,tmp.date1 viewby_date ';

                 IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN
                   l_custom_sql := l_custom_sql || '  ,opty.product_category_id ';
                  END IF;

              l_custom_sql := l_custom_sql ||'           ,NULL BIL_MEASURE1
                         ,NULL BIL_MEASURE2
                        ,SUM(CASE WHEN tmp.date1 > &BIS_CURRENT_ASOF_DATE
                             THEN NULL
                             ELSE opty.won_opty_amt  END)  BIL_MEASURE3
                         FROM ';

            l_custom_sql := l_custom_sql ||' (SELECT  viewbyid sequence, SUM(won_opty_amt) won_opty_amt';


                 IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN
                   l_custom_sql := l_custom_sql || '  ,product_category_id ';
                 END IF;


            l_custom_sql := l_custom_sql ||' FROM  (SELECT time_id, SUM(sumry.won_opty_amt'||l_currency_suffix||') won_opty_amt ';

                 IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN
                   l_custom_sql := l_custom_sql || '  ,sumry.product_category_id product_category_id ';
                 END IF;


           l_custom_sql := l_custom_sql ||' FROM (select /*+ NO_MERGE */
                                               time_id, period_type_id
                                                from bil_bi_rpt_tmp1     temp,
                                                     FII_TIME_STRUCTURES cal
                                               where cal.report_date = LEAST(&BIS_CURRENT_ASOF_DATE, temp.date2)
                                                 and cal.xtd_flag = :l_yes
                                                 and BITAND(cal.record_type_id, :l_record_type_id) = :l_record_type_id
                                               group by time_id, period_type_id) temp,
                                             bil_bi_opty_pg_mv sumry
                                       WHERE temp.period_type_id = sumry.effective_period_type_id
                                         and sumry.effective_time_id = temp.time_id '||l_sg_where||
                                       ' GROUP BY temp.time_id';

                 IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN
                   l_custom_sql := l_custom_sql ||'  , sumry.product_category_id ';
                 END IF;

              l_custom_sql := l_custom_sql ||' ) timeslice,
                              (Select viewbyid, time_id
                                    from (select viewbyid,
                                                 cal.time_id,
                                                 cal.period_type_id
                                         from  bil_bi_rpt_tmp1     temp,
                                               FII_TIME_STRUCTURES cal
                                          where cal.report_date = LEAST(&BIS_CURRENT_ASOF_DATE, temp.date2)
                                         and cal.xtd_flag = :l_yes
                                         and BITAND(cal.record_type_id, :l_record_type_id) = :l_record_type_id) time_pieces
                                         group by  viewbyid, time_id ) mapping
                             WHERE  timeslice.time_id(+) = mapping.time_id
                             GROUP BY   viewbyid';


                          IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN
                   l_custom_sql := l_custom_sql ||'  , product_category_id ';
                 END IF;


               l_custom_sql := l_custom_sql ||') opty ,
                          bil_bi_rpt_tmp1 tmp
                          where opty.sequence = tmp.viewbyid
                 GROUP BY tmp.date2, tmp.date1 ';


                          IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN

                   l_custom_sql := l_custom_sql ||' ,opty.product_category_id
                          ) sumry,
                         (SELECT /*+ NO_MERGE */
                                 eni1.child_id
                          FROM  eni_denorm_hierarchies    eni1,
                                mtl_default_category_sets d
                          WHERE eni1.object_type = ''CATEGORY_SET''
                          AND eni1.object_id = d.category_set_id
                          AND d.functional_area_id = 11
                          AND eni1.dbi_flag = :l_yes
                          AND eni1.parent_id = :l_prodcat) eni1
                        WHERE sumry.product_category_id = eni1.child_id
                        GROUP BY viewby, viewby_date';

                          END IF;

                         l_custom_sql := l_custom_sql ||') opty, BIL_BI_RPT_TMP1 temp where opty.viewby(+) = temp.date2
                           GROUP BY temp.date2,opty.viewby_date,opty.viewby  order by temp.date2';

    ELSE
        BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                         ,x_sqlstr     => l_default_query);
        l_custom_sql := l_default_query;
    END IF;

        l_custom_sql := REPLACE(l_custom_sql,'   ',' ');
        l_custom_sql := REPLACE(l_custom_sql,'   ',' ');
        l_custom_sql := REPLACE(l_custom_sql,'   ',' ');
        l_custom_sql := REPLACE(l_custom_sql,'   ',' ');
        l_custom_sql := REPLACE(l_custom_sql,'  ',' ');
        l_custom_sql := REPLACE(l_custom_sql,'  ',' ');
        x_custom_sql := l_custom_sql;


                    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		       l_ind :=1;
                       l_len:= length(x_custom_sql);

                       WHILE l_ind <= l_len LOOP
                        l_str:= substr(x_custom_sql, l_ind, 4000);

                        FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		        MODULE => g_pkg || l_proc ||'.'|| ' Final Query to PMV ',
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
        x_custom_attr(l_bind_ctr) := l_custom_rec;
        l_bind_ctr := l_bind_ctr+1;

        l_custom_rec.attribute_name := ':l_curr_page_time_id';
        l_custom_rec.attribute_value := l_curr_page_time_id;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
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

        l_custom_rec.attribute_name := ':l_snapshot_date';
        l_custom_rec.attribute_value := TO_CHAR(l_snapshot_date,'DD/MM/YYYY');
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr) := l_custom_rec;
        l_bind_ctr := l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_sg_id';
        l_custom_rec.attribute_value := l_sg_id;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr) := l_custom_rec;
        l_bind_ctr := l_bind_ctr+1;

        l_custom_rec.attribute_name := ':l_resource_id';
        l_custom_rec.attribute_value := l_resource_id;
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

        l_custom_rec.attribute_name := ':l_bitand_id';
        l_custom_rec.attribute_value := l_bitand_id;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
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

        IF(l_prodcat IS NOT NULL) THEN
            l_custom_rec.attribute_name := ':l_prodcat';
            l_custom_rec.attribute_value := l_prodcat;
            l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
            l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_attr.Extend();
            x_custom_attr(l_bind_ctr) := l_custom_rec;
            l_bind_ctr := l_bind_ctr+1;
        END IF;

        l_custom_rec.attribute_name := ':l_fst_crdt_type';
        l_custom_rec.attribute_value := l_fst_crdt_type;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr) := l_custom_rec;
        l_bind_ctr := l_bind_ctr+1;

        l_custom_rec.attribute_name := ':l_page_period_type';
        l_custom_rec.attribute_value := l_page_period_type;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr) := l_custom_rec;
        l_bind_ctr := l_bind_ctr+1;

     if(l_parent_sls_grp_id is not null) then
         l_custom_rec.attribute_name :=':l_parent_sls_grp_id';
         l_custom_rec.attribute_value :=l_parent_sls_grp_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
       end if;

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'end',
		                                    MESSAGE => ' End of Procedure '|| l_proc);

                     END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
           fnd_message.set_token('ERROR' ,SQLCODE);
           fnd_message.set_token('REASON', SQLERRM);
           fnd_message.set_token('ROUTINE', l_proc);

                                 FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_UNEXPECTED,
		                                MODULE => g_pkg || l_proc || 'proc_error',
		                                MESSAGE => fnd_message.get );

       END IF;

    COMMIT;
    RAISE;
END BIL_BI_FRCST_PIPE_WON_TREND;


/*******************************************************************************
 * Name    : Procedure BIL_BI_PIPELINE_MOMENTUM_TREND
 * Author  : Elena
 * Date    : 01-Feb-2004
 * Purpose : Pipeline Trend
 *
 *           Copyright (c) 2004 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 *
 * Date        Author     Description
 * ----        ------     -----------
 * 01/02/04    ESAPOZHN   Intial Version
 ******************************************************************************/
PROCEDURE BIL_BI_PIPELINE_MOMENTUM_TREND( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                    ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )

  IS

    --page params
    l_region_id               VARCHAR2(100);
    l_period_type             VARCHAR2(200);
    l_conv_rate_selected      VARCHAR2(200);
    l_sg_id                   VARCHAR2(200);
    l_psg_id                  NUMBER;
    l_productcat_id              VARCHAR2(100);
    l_resource_id             VARCHAR2(20);
    l_curr_page_time_id       NUMBER;
    l_prev_page_time_id       NUMBER;
    l_comp_type               VARCHAR2(50);
    l_parameter_valid         BOOLEAN;
    l_curr_as_of_date         DATE;
    l_page_period_type        VARCHAR2(100);
    l_prev_date               DATE;
    l_record_type_id          NUMBER;
    l_viewby                  VARCHAR2(200);
    l_denorm                  VARCHAR2(100);
	l_product_where_clause    VARCHAR2(1000);

    --debug mode profile
    l_DebugMode               VARCHAR2(10);

    --global params
    l_bitand_id               VARCHAR2(10);
    l_calendar_id             VARCHAR2(10);
    l_bis_sysdate             Date;
    l_fii_struct              VARCHAR2(100);

    --trend params
    l_table_name              VARCHAR2(20);
    l_column_name             VARCHAR2(20);
    l_curr_start_date         DATE;
    l_prev_start_date         DATE;
    l_curr_eff_end_date       DATE;
    l_prev_eff_end_date       DATE;

    --procedure specific vars
    l_custom_rec              BIS_QUERY_ATTRIBUTES;
    l_sg_id_num               NUMBER;
    l_custom_sql              VARCHAR2(12000);
    l_prior_str               VARCHAR2(5000);
    l_inner_select            VARCHAR2(2000);
    l_inner_select_prior      VARCHAR2(2000);
    l_sumry                   VARCHAR2(50);
    g_SQL_Error_Msg           VARCHAR2(500);
    l_sql_error_desc          VARCHAR2(2000);
    l_bind_ctr                NUMBER;
    l_default_query           VARCHAR2(2000);
    l_proc                    VARCHAR2(100);
    l_pipe_col                VARCHAR2(100);    /*changed for BUG 4001011*/
    l_group_flag              VARCHAR2(30);
    l_group_by_sql            VARCHAR2(300);
    l_snapshot_date           DATE;
    l_currency_suffix         VARCHAR2(5);
    l_prev_snap_date          DATE;
    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;

  BEGIN

	/* Intializing Variables*/
	g_pkg := 'bil.patch.115.sql.BIL_BI_TREND_MGMT_RPTS_PKG.';
	l_region_id := 'BIL_BI_PIPELINE_MOMENTUM_TREND';
	l_parameter_valid := FALSE;
    l_proc := 'BIL_BI_PIPELINE_MOMENTUM_TREND';


       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                       FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                      MODULE => g_pkg || l_proc || '.begin ',
		                      MESSAGE => ' Start of Procedure '|| l_proc);

       END IF;


    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;


    BIL_BI_UTIL_PKG.GET_OTHER_PROFILES(x_DebugMode => l_DebugMode);

    BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl  =>p_page_parameter_tbl,
                          p_region_id                 =>l_region_id,
                          x_period_type               =>l_period_type,
                          x_conv_rate_selected        =>l_conv_rate_selected,
                          x_sg_id                     =>l_sg_id,
                          x_parent_sg_id              =>l_psg_id,
                          x_resource_id               =>l_resource_id,
                          x_prodcat_id                =>l_productcat_id,
                          x_curr_page_time_id         =>l_curr_page_time_id,
                          x_prev_page_time_id         =>l_prev_page_time_id,
                          x_comp_type                 =>l_comp_type,
                          x_parameter_valid           =>l_parameter_valid,
                          x_as_of_date                =>l_curr_as_of_date,
                          x_page_period_type          =>l_page_period_type,
                          x_prior_as_of_date          =>l_prev_date,
                          x_record_type_id            =>l_record_type_id,
                          x_viewby                    =>l_viewby);


   IF (l_parameter_valid) THEN

        BIL_BI_UTIL_PKG.get_trend_params(p_page_parameter_tbl  =>p_page_parameter_tbl,
                                    p_page_period_type    =>l_page_period_type,
                                    p_comp_type        =>l_comp_type,
                                    p_curr_as_of_date  =>l_curr_as_of_date,
                                    x_table_name       =>l_table_name,
                                    x_column_name      =>l_column_name,
                                    x_curr_start_date  =>l_curr_start_date,
                                    x_prev_start_date  =>l_prev_start_date,
                                    x_curr_eff_end_date  => l_curr_eff_end_date,
                                    x_prev_eff_end_date  => l_prev_eff_end_date);


        l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));


        BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id     =>l_bitand_id,
                                    x_calendar_id        =>l_calendar_id,
                                    x_curr_date          =>l_bis_sysdate,
                                    x_fii_struct         =>l_fii_struct);


        IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
        ELSE
            l_currency_suffix := '';
        END IF;

        IF l_productcat_id IS NULL THEN
           l_productcat_id := 'All';
        END IF;

        BIL_BI_UTIL_PKG.GET_PC_NOROLLUP_WHERE_CLAUSE(
					                      p_viewby		 => l_viewby,
					                      p_prodcat      => l_productcat_id,
                                          x_denorm       => l_denorm,
					                      x_where_clause => l_product_where_clause
					                   );

/*        BIL_BI_UTIL_PKG.GET_LATEST_SNAP_DATE(p_page_parameter_tbl  =>p_page_parameter_tbl,
                                            p_as_of_date    => l_curr_as_of_date,
                                            p_period_type =>null,
                                            x_snapshot_date => l_snapshot_date);
*/


         BIL_BI_UTIL_PKG.GET_PIPE_TREND_SOURCE(p_as_of_date    => l_curr_as_of_date
                                             ,p_prev_date      => NULL
                                             ,p_trend_type    => 'E'
                                             ,p_period_type   => l_page_period_type
                                             ,p_page_parameter_tbl  => p_page_parameter_tbl
                                             ,x_pipe_mv       => l_sumry
                                             ,x_snap_date     => l_snapshot_date
                                             ,x_prev_snap_date => l_prev_snap_date);

/*      CASE l_page_period_type
        WHEN 'FII_TIME_ENT_YEAR' THEN
             l_pipe_col := 'pipeline_amt_year'||l_currency_suffix;

        WHEN 'FII_TIME_ENT_QTR' THEN --&BIS_CURRENT_EFFECTIVE_END_DATE, &BIS_PREVIOUS_EFFECTIVE_END_DATE
            l_pipe_col := 'pipeline_amt_quarter'||l_currency_suffix;

        WHEN 'FII_TIME_ENT_PERIOD' THEN
             l_pipe_col := 'pipeline_amt_period'||l_currency_suffix;
        ELSE
            --week
            l_pipe_col := 'pipeline_amt_week'||l_currency_suffix;
        END CASE;
*/

        l_pipe_col := bil_bi_util_pkg.get_pipe_col_names(l_page_period_type, NULL, 'P', l_currency_suffix);

        IF(l_productcat_id = 'All') THEN
--            l_sumry := 'bil_bi_pipe_g_mv';
            l_group_flag := ' AND sumry.grp_total_flag = 1 ';
            l_group_by_sql := ' Group By ftime1.start_date,
		                    ftime1.sequence ';
        ELSE
--            l_sumry := 'bil_bi_pipe_g_mv';
            l_group_flag := ' AND sumry.grp_total_flag = 0 ';
            l_group_by_sql := ' Group By ftime1.start_date,
		                    ftime1.sequence, eni1.parent_id ';
        END IF;


                    l_custom_sql:=
	            'SELECT
	                ftime.name VIEWBY
					,ftime.end_date end_date
	                ,DECODE(prior_pipeline,0,NULL,prior_pipeline)
	                      BIL_MEASURE2
	                ,DECODE(current_pipeline,0,NULL,current_pipeline)  BIL_MEASURE3
	                ,(DECODE(current_pipeline,0,NULL,current_pipeline)
	                    - DECODE(prior_pipeline,0,NULL,prior_pipeline) )
	                    /ABS(DECODE(prior_pipeline, 0, NULL, prior_pipeline))*100  BIL_MEASURE4
	            FROM
	            (  ';



		            l_custom_sql := l_custom_sql || '
		                SELECT /*+ ORDERED */ ftime1.start_date start_date,
		                    ftime1.sequence viewby';

                    IF (l_comp_type = 'SEQUENTIAL' OR (l_comp_type = 'YEARLY' AND l_page_period_type = 'FII_TIME_ENT_YEAR')) THEN

                    	l_custom_sql := l_custom_sql ||',lag(SUM((CASE WHEN sumry.snap_date >= :l_prev_start_date THEN
	                                  sumry.'||l_pipe_col|| ' ELSE NULL END)),1) over(order by ftime1.start_date)
	                                  prior_pipeline ';

                    ELSE

                    l_custom_sql := l_custom_sql ||'
		                    ,SUM((CASE WHEN sumry.snap_date < :l_curr_start_date
                                THEN sumry.'||l_pipe_col|| ' ELSE NULL END)) prior_pipeline
                                ';
                     END IF;

                     l_custom_sql := l_custom_sql ||'
		                    ,SUM((CASE WHEN sumry.snap_date >= :l_curr_start_date
                            THEN sumry.'||l_pipe_col||' ELSE NULL END)) current_pipeline
		                FROM '||l_table_name||' ftime1
		                    , '||l_sumry||' sumry ';


                IF l_productcat_id <> 'All' THEN
                    l_custom_sql := l_custom_sql ||' , mtl_default_category_sets d,eni_denorm_hierarchies eni1 ';
                END IF;

	         l_custom_sql := l_custom_sql ||'
                                    WHERE ftime1.start_date < :l_curr_eff_end_date
		                    AND ftime1.end_date >= :l_prev_start_date
		                    AND sumry.snap_date = least (:l_snapshot_date, ftime1.end_date)
                            '||l_group_flag||'
		                    AND sumry.sales_group_id = :l_sg_id';

	          if(l_resource_id is not null) then
                l_custom_sql:= l_custom_sql ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id';
          else
                l_custom_sql:=l_custom_sql ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_psg_id IS NULL then
                    l_custom_sql:=l_custom_sql || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_custom_sql:=l_custom_sql ||   ' AND sumry.parent_sales_group_id = :l_psg_id ';
                end if;
          end if;

		             l_custom_sql:=l_custom_sql ||l_product_where_clause ||l_group_by_sql;



	            l_custom_sql := l_custom_sql ||'
	            ) temp1
	                ,'||l_table_name||' ftime
	            WHERE
	                ftime.start_date <= :l_curr_eff_end_date
	                AND ftime.end_date >= :l_curr_start_date
	                AND ftime.sequence = temp1.VIEWBY(+) ';

				IF (l_comp_type = 'SEQUENTIAL') THEN
					l_custom_sql := l_custom_sql ||'
								AND ftime.start_date = temp1.start_date(+) ';
				END IF;

				l_custom_sql :=
				  'SELECT VIEWBY, '||
                                   'SUM(BIL_MEASURE2) BIL_MEASURE5, '||
      				   'SUM(BIL_MEASURE3) BIL_MEASURE3, '||
					   'SUM(BIL_MEASURE2) BIL_MEASURE2, '||
					   '(SUM(BIL_MEASURE3)-SUM(BIL_MEASURE2))/'||
					   		'ABS(DECODE(SUM(BIL_MEASURE2),0,null,SUM(BIL_MEASURE2)))*100 BIL_MEASURE4 '||
					   ' FROM ('||
						   	l_custom_sql ||' ORDER BY ftime.end_date '||
						     ') GROUP BY VIEWBY,end_date '||
							 ' ORDER BY end_date ';

   ELSE

        BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                     ,x_sqlstr    => l_default_query);

        l_custom_sql := l_default_query;

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
		                                    MODULE => g_pkg || l_proc || '.statement ',
		                                    MESSAGE => ' Binds: '||
                                                               ' l_viewby: '||l_viewby||
                                                               ',l_conv_rate_selected: '||l_conv_rate_selected||
                                                               ',l_curr_start_date: '||to_char(l_curr_start_date, 'MM/DD/YYYY')||
                                                               ',l_curr_page_time_id: '||l_curr_page_time_id||
                                                               ',l_prev_page_time_id: '||l_prev_page_time_id||
                                                               ',l_prev_start_date: '||to_char(l_prev_start_date, 'MM/DD/YYYY')||
                                                               ',l_calendar_id: '||l_calendar_id||
                                                               ',l_sg_id: '||l_sg_id||
                                                               ',l_psg_id: '||l_psg_id||
                                                               ',l_resource_id: '||l_resource_id||
                                                               ',l_bitand_id: '||l_bitand_id||
                                                               ',l_period_type: '||l_period_type||
                                                               ',l_productcat_id: '||l_productcat_id||
                                                               ',l_prev_eff_end_date: '||to_char(l_prev_eff_end_date, 'MM/DD/YYYY')||
				                               ',l_curr_eff_end_date: '||to_char(l_curr_eff_end_date, 'MM/DD/YYYY')||
				                               ',l_snapshot_date" '||l_snapshot_date);

                     END IF;

     x_custom_sql := l_custom_sql;

        /* Bind parameters */
        l_bind_ctr:=1;

        l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_custom_rec.attribute_value :=l_viewby;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_curr_start_date';
        l_custom_rec.attribute_value :=to_char(l_curr_start_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_curr_as_of_date';
        l_custom_rec.attribute_value :=to_char(l_curr_as_of_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

		l_custom_rec.attribute_name :=':l_curr_eff_end_date';
        l_custom_rec.attribute_value :=to_char(l_curr_eff_end_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

		l_custom_rec.attribute_name :=':l_prev_eff_end_date';
        l_custom_rec.attribute_value :=to_char(l_prev_eff_end_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_snapshot_date';
        l_custom_rec.attribute_value :=to_char(l_snapshot_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_prev_snap_date';
        l_custom_rec.attribute_value :=to_char(l_prev_snap_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
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

        l_custom_rec.attribute_name :=':l_prev_start_date';
        l_custom_rec.attribute_value :=to_char(l_prev_start_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
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

        l_custom_rec.attribute_name :=':l_sg_id';
        l_custom_rec.attribute_value :=l_sg_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_psg_id';
        l_custom_rec.attribute_value :=l_psg_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;


		if(l_resource_id is not null) then
	        l_custom_rec.attribute_name :=':l_resource_id';
	        l_custom_rec.attribute_value :=l_resource_id;
	        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	        x_custom_attr.Extend();
	        x_custom_attr(l_bind_ctr):=l_custom_rec;
	        l_bind_ctr:=l_bind_ctr+1;
		end if;

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

        IF(l_productcat_id IS NOT NULL) THEN
            l_custom_rec.attribute_name :=':l_productcat_id';
            l_custom_rec.attribute_value :=l_productcat_id;
            l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
            l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_attr.Extend();
            x_custom_attr(l_bind_ctr):=l_custom_rec;
            l_bind_ctr:=l_bind_ctr+1;
        END IF;

        IF(l_productcat_id IS NOT NULL) THEN
            l_custom_rec.attribute_name :=':l_prodcat';
            l_custom_rec.attribute_value :=l_productcat_id;
            l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
            l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_attr.Extend();
            x_custom_attr(l_bind_ctr):=l_custom_rec;
            l_bind_ctr:=l_bind_ctr+1;
        END IF;


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || '.end',
		                                    MESSAGE => ' End of Procedure '|| l_proc);

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

 END BIL_BI_PIPELINE_MOMENTUM_TREND;



 /*******************************************************************************
 * Name    : Procedure BIL_BI_WIN_LOSS_CONV_TREND
 * Author  : Elena
 * Date    : 01-Feb-2004
 * Purpose : Win Loss Trend.
 *
 *           Copyright (c) 2004 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 *
 * Date        Author     Description
 * ----        ------     -----------
 * 01/02/04    ESAPOZHN   Intial Version
 ******************************************************************************/

 PROCEDURE BIL_BI_WIN_LOSS_CONV_TREND( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                    ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
  IS

    --page params
    l_region_id               VARCHAR2(100);
    l_period_type             VARCHAR2(200);
    l_conv_rate_selected      VARCHAR2(200);
    l_sg_id                   VARCHAR2(200);
    l_resource_id             VARCHAR2(20);
    l_productcat_id           VARCHAR2(100);
    l_curr_page_time_id       NUMBER;
    l_prev_page_time_id       NUMBER;
    l_comp_type               VARCHAR2(50);
    l_parameter_valid         BOOLEAN;
    l_curr_as_of_date         DATE;
    l_page_period_type        VARCHAR2(100);
    l_prev_date               DATE;
    l_record_type_id          NUMBER;
    l_viewby                  VARCHAR2(200);
    l_denorm                  VARCHAR2(100);
    l_product_where_clause    VARCHAR2(1000);

    --global params
    l_bitand_id               VARCHAR2(10);
    l_calendar_id             VARCHAR2(10);
    l_bis_sysdate             Date;
    l_fii_struct              VARCHAR2(100);

    --trend params
    l_table_name              VARCHAR2(20);
    l_column_name             VARCHAR2(20);
    l_curr_start_date         DATE;
    l_prev_start_date         DATE;
    l_curr_eff_end_date       DATE;
    l_prev_eff_end_date       DATE;

    --procedure specific vars
    l_custom_rec              BIS_QUERY_ATTRIBUTES;
    l_sg_id_num               NUMBER;
    l_custom_sql              VARCHAR2(10000);
    l_prior_str               VARCHAR2(5000);
    l_inner_select            VARCHAR2(2000);
    l_inner_select_prior      VARCHAR2(2000);
    l_sumry                   VARCHAR2(50);
    l_sumry1                   VARCHAR2(50);
    g_SQL_Error_Msg           VARCHAR2(500);
    l_sql_error_desc          VARCHAR2(2000);
    l_bind_ctr                NUMBER;
    l_default_query           VARCHAR2(2000);
    l_proc                    VARCHAR2(100);
    l_open_col                VARCHAR2(20);
    l_group_flag              VARCHAR2(30);
    l_snapshot_date           DATE;
    l_parent_sls_grp_id       NUMBER;
    l_denorm_pipe             VARCHAr2(100);
    l_yes                     VARCHAR2(1);
    l_currency_suffix         VARCHAR2(5);
    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;


  BEGIN
	/* Intializing Variables*/
	g_pkg := 'bil.patch.115.sql.BIL_BI_TREND_MGMT_RPTS_PKG.';
	l_region_id := 'BIL_BI_WIN_LOSS_CONV_TREND';
	l_parameter_valid := FALSE;
	l_proc := 'BIL.BI.WIN.LOSS.CONV.TREND';
    l_yes := 'Y';

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg ||'.'||l_proc || '.begin ',
		                                    MESSAGE => ' Start of Procedure '|| l_proc);

                     END IF;

    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

     BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl =>p_page_parameter_tbl,
                           p_region_id                 =>l_region_id,
                           x_period_type               =>l_period_type,
                           x_conv_rate_selected        =>l_conv_rate_selected,
                           x_sg_id                     =>l_sg_id,
                           x_parent_sg_id              =>l_parent_sls_grp_id,
                           x_resource_id               =>l_resource_id,
                           x_prodcat_id                =>l_productcat_id,
                           x_curr_page_time_id         =>l_curr_page_time_id,
                           x_prev_page_time_id         =>l_prev_page_time_id,
                           x_comp_type                 =>l_comp_type,
                           x_parameter_valid           =>l_parameter_valid,
                           x_as_of_date                =>l_curr_as_of_date,
                           x_page_period_type          =>l_page_period_type,
                           x_prior_as_of_date          =>l_prev_date,
                           x_record_type_id            =>l_record_type_id,
                           x_viewby                    =>l_viewby);

   IF (l_parameter_valid) THEN

        BIL_BI_UTIL_PKG.get_trend_params(p_page_parameter_tbl  =>p_page_parameter_tbl,
                                    p_page_period_type    =>l_page_period_type,
                                    p_comp_type        =>l_comp_type,
                                    p_curr_as_of_date  =>l_curr_as_of_date,
                                    x_table_name       =>l_table_name,
                                    x_column_name      =>l_column_name,
                                    x_curr_start_date  =>l_curr_start_date,
                                    x_prev_start_date  =>l_prev_start_date,
                                    x_curr_eff_end_date  => l_curr_eff_end_date,
                                    x_prev_eff_end_date  => l_prev_eff_end_date);


        l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));

        BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id          =>l_bitand_id,
                                    x_calendar_id        =>l_calendar_id,
                                    x_curr_date          =>l_bis_sysdate,
                                    x_fii_struct         =>l_fii_struct);

        --l_fii_struct := 'FII_TIME_STRUCTURES';

        IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
        ELSE
            l_currency_suffix := '';
        END IF;

        IF l_productcat_id IS NULL THEN
           l_productcat_id := 'All';
        END IF;

        BIL_BI_UTIL_PKG.get_PC_NoRollup_Where_Clause( p_prodcat  => l_productcat_id,
			                               p_viewby  => l_viewby,
                                                       x_denorm  => l_denorm,
					               x_where_clause => l_product_where_clause
					                   );
/* LATEST SNAPSHOT IMPLEMENTATION */


        BIL_BI_UTIL_PKG.GET_LATEST_SNAP_DATE(p_page_parameter_tbl  =>p_page_parameter_tbl,
                                            p_as_of_date    => l_curr_as_of_date,
                                            p_period_type =>null,
                                            x_snapshot_date => l_snapshot_date);


/* END LATEST SNAPSHOT IMPLEMENTATION */

        CASE l_page_period_type
        WHEN 'FII_TIME_ENT_YEAR' THEN
            l_open_col := 'open_amt_year'||l_currency_suffix;

        WHEN 'FII_TIME_ENT_QTR' THEN
            l_open_col := 'open_amt_quarter'||l_currency_suffix;

        WHEN 'FII_TIME_ENT_PERIOD' THEN
            l_open_col := 'open_amt_period'||l_currency_suffix;

        ELSE
            --week

            l_open_col := 'open_amt_week'||l_currency_suffix;

        END CASE;


        IF(l_productcat_id = 'All') THEN
            l_sumry := 'bil_bi_opty_g_mv';
            l_sumry1:= 'bil_bi_pipe_g_mv';
            l_group_flag := ' AND sumry.grp_total_flag = 1 ';
        ELSE
            l_sumry := 'bil_bi_opty_pg_mv';
            l_sumry1:= 'bil_bi_pipe_g_mv';
            l_group_flag := ' AND sumry.grp_total_flag = 0';
        END IF;
        l_custom_sql:=
            'SELECT /*+ use_nl(ftime,temp1) */
                ftime.name VIEWBY
                ,DECODE(SUM(current_opty), 0, NULL, SUM(current_opty))
                    BIL_MEASURE1
                ,DECODE(SUM(current_won),0,NULL,SUM(current_won)) BIL_MEASURE4
                ,DECODE(SUM(prior_won),0,NULL,SUM(prior_won))  BIL_MEASURE5
                ,DECODE((SUM(current_won)/
                            SUM(DECODE(current_opty, 0, NULL
                                , current_opty)) )*100,0,NULL,
                                (SUM(current_won)/
                            SUM(DECODE(current_opty, 0, NULL
                                , current_opty)) )*100) BIL_MEASURE7

                ,DECODE(SUM(current_lost),0,NULL,SUM(current_lost)) BIL_MEASURE10
                ,DECODE(SUM(prior_lost),0,NULL,SUM(prior_lost))  BIL_MEASURE11
                ,DECODE((SUM(current_lost)/
                            SUM(DECODE(current_opty, 0, NULL
                                , current_opty)) )*100,0,NULL,
                                (SUM(current_lost)/
                            SUM(DECODE(current_opty, 0, NULL
                                , current_opty)) )*100) BIL_MEASURE13
            FROM
             ';

            IF(l_productcat_id <> 'All') THEN

            l_custom_sql:= l_custom_sql ||  ' (SELECT /*+ NO_MERGE(sumry) ordered */ viewby
                    ,SUM(prior_won) prior_won
                    ,SUM(prior_lost) prior_lost
                    ,SUM(current_opty) current_opty
                    ,SUM(current_won) current_won
                    ,SUM(current_lost) current_lost
            FROM  ';

              IF(l_productcat_id <> 'All') THEN
                l_custom_sql:=l_custom_sql||' mtl_default_category_sets d,eni_denorm_hierarchies eni1, ';
              END IF;


           END IF;
            /* get current period opty */
         l_custom_sql:= l_custom_sql||' ( SELECT /*+ leading(ftime1, ftrs) index(sumry,BIL_BI_OPTY_G_MV_N1) use_nl(sumry) */
                    ftime1.'||l_column_name||' viewby ';

             IF(l_productcat_id <> 'All') THEN

                l_custom_sql:= l_custom_sql || ' , sumry.product_category_id';

             END IF;

             l_custom_sql:= l_custom_sql || '       ,NULL prior_won
                    ,NULL prior_lost
                    ,SUM(NVL(sumry.won_opty_amt'||l_currency_suffix||',0)) +
                        SUM(NVL(sumry.lost_opty_amt'||l_currency_suffix||',0)) +
                        SUM(NVL(sumry.no_opty_amt'||l_currency_suffix||',0)) current_opty
                    ,sum(sumry.won_opty_amt'||l_currency_suffix||') current_won
                    ,sum(sumry.lost_opty_amt'||l_currency_suffix||') current_lost
                FROM '||l_table_name||' ftime1
                    , '||l_sumry||' sumry
                    , '||l_fii_struct||' ftrs
                WHERE ftime1.start_date < :l_curr_eff_end_date
                    AND ftime1.end_date >= :l_curr_start_date
                    AND ftrs.report_date = least(&BIS_CURRENT_ASOF_DATE, ftime1.end_date)
                    AND ftrs.xtd_flag= :l_yes
                    AND BITAND(ftrs.record_type_id, :l_record_type_id) = :l_record_type_id
                    AND sumry.effective_time_id = ftrs.time_id
                    AND sumry.effective_period_type_id = ftrs.period_type_id
                    AND sumry.sales_group_id =  :l_sg_id';
                if(l_resource_id is not null) then
                l_custom_sql:= l_custom_sql ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id';
             else
                l_custom_sql:=l_custom_sql ||
                    ' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_custom_sql:=l_custom_sql || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_custom_sql:=l_custom_sql ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;

             l_custom_sql:=l_custom_sql ||' GROUP BY ftime1.'||l_column_name||'
                /* end get current period opty */ ';

             IF(l_productcat_id <> 'All') THEN

                l_custom_sql:= l_custom_sql || ' , sumry.product_category_id';

             END IF;

/* LATEST SNAPSHOT IMPLEMENTATION */

                l_custom_sql := l_custom_sql ||
                ' /* get open opty to be counted towards total opty */
                UNION ALL
                SELECT /*+ leading(ftime1) */
                    ftime1.'||l_column_name||' viewby ';

             IF(l_productcat_id <> 'All') THEN

                l_custom_sql:= l_custom_sql || ' , sumry.product_category_id';

             END IF;

                l_custom_sql:= l_custom_sql || '       ,NULL prior_won
                    ,NULL prior_lost
                    ,SUM(NVL(sumry.'||l_open_col||', 0)) current_opty
                    ,NULL current_won
                    ,NULL current_lost
                FROM '||l_table_name||' ftime1
                    , '||l_sumry1||' sumry
                WHERE ftime1.start_date < :l_curr_eff_end_date
                    AND ftime1.end_date >= :l_curr_start_date
                    AND sumry.snap_date= LEAST(:l_snapshot_date,  ftime1.end_date)

                 '||l_group_flag ||'
                    AND sumry.sales_group_id =  :l_sg_id';
                if(l_resource_id is not null) then
                l_custom_sql:= l_custom_sql ||
                    ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id';
             else
                l_custom_sql:=l_custom_sql ||
                    ' AND sumry.salesrep_id IS NULL ';
                  if l_parent_sls_grp_id IS NULL then
                     l_custom_sql:=l_custom_sql || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                     l_custom_sql:=l_custom_sql ||  ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
                end if;
             end if;

             l_custom_sql:=l_custom_sql ||
             ' GROUP BY ftime1.'||l_column_name;
             IF(l_productcat_id <> 'All') THEN
                l_custom_sql:= l_custom_sql || ' , sumry.product_category_id';
             END IF;

                    /* end get open opty */

/* END LATEST SNAPSHOT IMPLEMENTATION */
              IF(l_productcat_id <> 'All') THEN
                l_custom_sql := l_custom_sql || ' ) sumry '||
								' WHERE  1=1  ' || l_product_where_clause || ' GROUP BY VIEWBY ';
               END IF;

            l_custom_sql := l_custom_sql ||
            ' ) temp1
                ,'||l_table_name||' ftime
            WHERE
                ftime.start_date <= :l_curr_eff_end_date
                AND ftime.end_date >= :l_curr_start_date
                AND ftime.'||l_column_name||' = temp1.VIEWBY(+)
            GROUP BY ftime.end_date, ftime.name
            ORDER BY ftime.end_date';


    ELSE
        BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                     ,x_sqlstr    => l_default_query);

        l_custom_sql := l_default_query;

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
		                                    MODULE => g_pkg || l_proc || g_pkg ||'.'||l_proc || '.statement ',
		                                    MESSAGE => ' Binds: '||
                                                               ' l_viewby: '||l_viewby||
                                                               ',l_conv_rate_selected: '||l_conv_rate_selected||
                                                               ',l_curr_start_date: '||to_char(l_curr_start_date, 'MM/DD/YYYY')||
                                                               ',l_curr_page_time_id: '||l_curr_page_time_id||
                                                               ',l_prev_page_time_id: '||l_prev_page_time_id||
                                                               ',l_prev_start_date: '||to_char(l_prev_start_date, 'MM/DD/YYYY')||
                                                               ',l_calendar_id: '||l_calendar_id||
                                                               ',l_sg_id: '||l_sg_id||
                                                               ',l_resource_id: '||l_resource_id||
                                                               ',l_bitand_id: '||l_bitand_id||
                                                               ',l_record_type_id: '||l_record_type_id||
                                                               ',l_period_type: '||l_period_type||
                                                               ',l_productcat_id: '||l_productcat_id||
                                                               ',l_prev_eff_end_date: '||to_char(l_prev_eff_end_date, 'MM/DD/YYYY')||
                                                               ',l_snapshot_date: '||l_snapshot_date);

                     END IF;


        x_custom_sql := l_custom_sql;

        /* Bind parameters */
        l_bind_ctr:=1;

        l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_custom_rec.attribute_value :=l_viewby;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_curr_start_date';
        l_custom_rec.attribute_value :=to_char(l_curr_start_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

		l_custom_rec.attribute_name :=':l_curr_eff_end_date';
        l_custom_rec.attribute_value :=to_char(l_curr_eff_end_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_record_type_id';
        l_custom_rec.attribute_value :=l_record_type_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;


         l_custom_rec.attribute_name :=':l_yes';
         l_custom_rec.attribute_value :=l_yes;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_sg_id';
        l_custom_rec.attribute_value :=l_sg_id;
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

		IF(l_resource_id is not null) THEN
		        l_custom_rec.attribute_name :=':l_resource_id';
		        l_custom_rec.attribute_value :=l_resource_id;
		        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
		        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		        x_custom_attr.Extend();
		        x_custom_attr(l_bind_ctr):=l_custom_rec;
		        l_bind_ctr:=l_bind_ctr+1;
		END IF;

if(l_parent_sls_grp_id is not null) then
         l_custom_rec.attribute_name :=':l_parent_sls_grp_id';
         l_custom_rec.attribute_value :=l_parent_sls_grp_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
end if;





        IF(l_productcat_id IS NOT NULL) THEN
            l_custom_rec.attribute_name :=':l_productcat_id';
            l_custom_rec.attribute_value :=l_productcat_id;
            l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
            l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_attr.Extend();
            x_custom_attr(l_bind_ctr):=l_custom_rec;
            l_bind_ctr:=l_bind_ctr+1;
        END IF;

         IF(l_productcat_id IS NOT NULL) THEN
            l_custom_rec.attribute_name :=':l_prodcat';
            l_custom_rec.attribute_value :=l_productcat_id;
            l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
            l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
            x_custom_attr.Extend();
            x_custom_attr(l_bind_ctr):=l_custom_rec;
            l_bind_ctr:=l_bind_ctr+1;
        END IF;

  /* LATEST SNAPSHOT IMPLEMENTATION */

        l_custom_rec.attribute_name :=':l_snapshot_date';
        l_custom_rec.attribute_value :=to_char(l_snapshot_date,'dd/mm/yyyy');
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

  /* LATEST SNAPSHOT IMPLEMENTATION */


                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg ||'.'||l_proc || '.end ',
		                                    MESSAGE => ' End of Procedure '|| l_proc);
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
 END BIL_BI_WIN_LOSS_CONV_TREND;


 /*******************************************************************************
 * Name    : Procedure BIL_BI_FRCST_WON_TREND
 * Author  : Elena
 * Date    : 01-Feb-2004
 * Purpose : Forecast versus Won Period in Detail report.
 *
 *           Copyright (c) 2004 Oracle Corporation
 *
 * Parameters
 * p_page_parameter_tbl    PL/SQL table containing dimension parameters
 * x_custom_sql             string containing sql query
 * x_custom_attr            PL/SQL table containing our bind vars
 *
 *
 * Date        Author     Description
 * ----        ------     -----------
 * 01/02/04    ESAPOZHN   Intial Version
 ******************************************************************************/

 PROCEDURE BIL_BI_FRCST_WON_TREND(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                     ,x_custom_sql    OUT NOCOPY VARCHAR2
                                     ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL )
 IS
     l_region_id               VARCHAR2(100);
     l_period_type             VARCHAR2(200);
     l_conv_rate_selected      VARCHAR2(200);
     l_sg_id                   VARCHAR2(200);
     l_resource_id             VARCHAR2(200);
     l_prodcat                 VARCHAR2(4000);
     l_product_id              VARCHAR2(20);
     l_curr_page_time_id       NUMBER;
     l_prev_page_time_id       NUMBER;
     l_comp_type               VARCHAR2(50);
     l_parameter_valid         BOOLEAN;
     l_curr_as_of_date         DATE;
     l_page_period_type        VARCHAR2(100);
     l_prev_date               DATE;
     l_record_type_id          NUMBER;
     l_viewby                  VARCHAR2(200);
     --debug mode profil
     l_DebugMode               VARCHAR2(10);
     --global params
     l_bitand_id               VARCHAR2(10);
     l_calendar_id             VARCHAR2(10);
     l_bis_sysdate             DATE;
     l_fii_struct              VARCHAR2(100);
     --procedure specific vars
     l_custom_rec              BIS_QUERY_ATTRIBUTES;
     l_sg_id_num               NUMBER;
     l_custom_sql              VARCHAR2(32000);
     l_prior_str               VARCHAR2(5000);
     g_SQL_Error_Msg           VARCHAR2(500);
     l_bind_ctr                NUMBER;
     l_default_query           VARCHAR2(2000);
     l_proc                    VARCHAR2(100);
     l_time_sql                VARCHAR2(3200);
     l_prev_time_sql           VARCHAR2(3200);
     l_frcst_tab               VARCHAR2(50);
     l_won_tab                 VARCHAR2(200);
     l_productcat_where        VARCHAR2(500);
     l_productcat_where_fst    VARCHAR2(100);
     l_sg_where                VARCHAR2(100);
     l_fst_crdt_type           VARCHAR2(100);
     l_show_period             VARCHAR2(50);
     l_table_name	       VARCHAR2(50);
     l_column_name	       VARCHAR2(50);
     l_curr_eff_start_date      DATE;
     l_prev_eff_start_date      DATE;
     l_curr_eff_end_date	DATE;
     l_prev_eff_end_date	DATE;
     l_insert_stmnt	       VARCHAR2(32000);
     l_curr_weeks              NUMBER;
     l_prev_weeks              NUMBER;
     l_yes                     VARCHAR2(5);
    l_parent_sls_grp_id       NUMBER;
    l_pc_norollup_where       VARCHAR2(500);
    l_denorm                  VARCHAR2(200);
    l_currency_suffix          VARCHAR2(5);
    l_sql_error_desc          VARCHAR2(15000);
    l_ind       NUMBER;
    l_str       VARCHAR2(4000);
    l_len       NUMBER;


BEGIN
	 /* Intializing variables*/
	 g_pkg := 'bil.patch.115.sql.BIL_BI_TREND_MGMT_RPTS_PKG.';
	 l_region_id := 'BIL_BI_FRCST_WON_TREND';
	 l_parameter_valid := FALSE;
	 l_proc := 'BIL_BI_FRCST_WON_TREND';
	 l_yes := 'Y';
         g_sch_name := 'BIL';

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

               FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		              MODULE => g_pkg || l_proc || '.begin ',
		              MESSAGE => ' Start of Procedure '|| l_proc);

         END IF;


     x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
     l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;


     BIL_BI_UTIL_PKG.GET_OTHER_PROFILES(x_DebugMode => l_DebugMode);

     BIL_BI_UTIL_PKG.GET_PAGE_PARAMS(p_page_parameter_tbl =>p_page_parameter_tbl,
                           p_region_id                 =>l_region_id,
                           x_period_type               =>l_period_type,
                           x_conv_rate_selected        =>l_conv_rate_selected,
                           x_sg_id                     =>l_sg_id,
                           x_parent_sg_id              =>l_parent_sls_grp_id,
                           x_resource_id               =>l_resource_id,
                           x_prodcat_id                =>l_prodcat,
                           x_curr_page_time_id         =>l_curr_page_time_id,
                           x_prev_page_time_id         =>l_prev_page_time_id,
                           x_comp_type                 =>l_comp_type,
                           x_parameter_valid           =>l_parameter_valid,
                           x_as_of_date                =>l_curr_as_of_date,
                           x_page_period_type          =>l_page_period_type,
                           x_prior_as_of_date          =>l_prev_date,
                           x_record_type_id            =>l_record_type_id,
                           x_viewby                    =>l_viewby);


 l_prodcat := REPLACE(l_prodcat,'''','');

    IF (l_parameter_valid = TRUE) THEN
         l_sg_id_num := TO_NUMBER(REPLACE(l_sg_id, ''''));
         BIL_BI_UTIL_PKG.GET_GLOBAL_CONTS(x_bitand_id =>l_bitand_id,
                                     x_calendar_id =>l_calendar_id,
                                     x_curr_date =>l_bis_sysdate,
                                     x_fii_struct =>l_fii_struct);

         bil_bi_util_pkg.get_forecast_profiles(x_FstCrdtType => l_fst_crdt_type);

	     if l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
	             l_viewby:='TIME+FII_TIME_ENT_PERIOD';
	             l_show_period := 'FII_TIME_ENT_PERIOD ';
	     elsif l_page_period_type = 'FII_TIME_ENT_QTR' THEN
	             l_viewby:='TIME+FII_TIME_WEEK';
	             l_show_period := ' FII_TIME_WEEK ';
	     elsif l_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
	             l_viewby:='TIME+FII_TIME_WEEK';
	             l_show_period := ' FII_TIME_WEEK ';
	     elsif l_page_period_type = 'FII_TIME_WEEK' THEN
	             l_viewby:='TIME+FII_TIME_DAY';
	             l_show_period := ' FII_TIME_DAY ';
	     end if;

   IF p_page_parameter_tbl IS NOT NULL THEN
        FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
            CASE p_page_parameter_tbl(i).parameter_name
		WHEN 'BIS_CURRENT_EFFECTIVE_START_DATE' THEN
                		l_curr_eff_start_date := p_page_parameter_tbl(i).PERIOD_DATE;
		WHEN 'BIS_CURRENT_EFFECTIVE_END_DATE' THEN
                 		l_curr_eff_end_date := p_page_parameter_tbl(i).PERIOD_DATE;
                 WHEN 'BIS_PREVIOUS_EFFECTIVE_START_DATE' THEN
                 		l_prev_eff_start_date := p_page_parameter_tbl(i).PERIOD_DATE;
                 WHEN 'BIS_PREVIOUS_EFFECTIVE_END_DATE' THEN
				l_prev_eff_end_date :=p_page_parameter_tbl(i).PERIOD_DATE;
	    ELSE
			NULL;
	   END CASE;
	END LOOP;
   END IF;

                   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN


                     l_sql_error_desc :=  'l_period_type        =>'||l_period_type ||',' ||
                                          'l_bitand_id          =>'||l_bitand_id || ', '||
                                          'l_conv_rate_selected =>'||l_conv_rate_selected ||',' ||
                                          'l_sg_id              =>'||l_sg_id ||',' ||
                                          'l_parent_sg_id       =>'||l_parent_sls_grp_id ||',' ||
                                          'l_resource_id        =>'||l_resource_id ||',' ||
                                          'l_prodcat_id         =>'||l_prodcat ||',' ||
                                          'l_curr_page_time_id  =>'||l_curr_page_time_id  ||',' ||
                                          'l_prev_page_time_id  =>'||l_prev_page_time_id ||',' ||
                                          'l_comp_type          =>'||l_comp_type ||',' ||
                                          'l_as_of_date         =>'||l_curr_as_of_date ||',' ||
                                          'l_page_period_type   =>'||l_page_period_type ||',' ||
                                          'l_prior_as_of_date   =>'||l_prev_date ||',' ||
                                          'l_record_type_id     =>'||l_record_type_id ||',' ||
                                          'l_viewby             =>'||l_viewby||',' ||
                                          'l_curr_eff_start_date=>'||l_curr_eff_start_date||',' ||
                                          'l_curr_eff_end_date  =>'||l_curr_eff_end_date||',' ||
                                          'l_prev_eff_start_date=>'||l_prev_eff_start_date||',' ||
                                          'l_prev_eff_end_date: =>'||l_prev_eff_end_date ||',' ||
                                          'l_parent_sls_grp_id: =>'||l_parent_sls_grp_id;


                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || g_pkg ||'.'||l_proc || '.debug ',
		                                    MESSAGE => 'Parameters '||l_sql_error_desc);

                   END IF;


        IF l_conv_rate_selected = 0 THEN
            l_currency_suffix := '_s';
        ELSE
            l_currency_suffix := '';
        END IF;

       IF 'ALL' = UPPER(l_prodcat) OR l_prodcat IS NULL THEN
                l_productcat_where := ' ';
                l_productcat_where_fst := ' ';
                l_frcst_tab := ' bil_bi_fst_g_mv ';
                l_won_tab := ' bil_bi_opty_g_mv sumry ';
        ELSE
                l_productcat_where := ' WHERE eni1.object_type = ''CATEGORY_SET''
                                             AND eni1.object_id = d.category_set_id
                                             AND d.functional_area_id = 11
                                             AND eni1.dbi_flag = ''Y''
                                             AND eni1.parent_id = :l_prodcat ';
                l_denorm := 'eni_denorm_hierarchies eni1, mtl_default_category_sets d ';
                l_productcat_where_fst := ' AND sumry.product_category_id(+) = :l_prodcat ';
                l_frcst_tab := ' bil_bi_fst_pg_mv ';
                l_won_tab := ' bil_bi_opty_pg_mv sumry ';

        END IF;


        l_time_sql :=   'SELECT rownum, start_date, end_date, ''C'' FROM
                        (SELECT show_period.start_date
                        ,(CASE WHEN show_period.end_date > :l_curr_eff_end_date
                                       THEN :l_curr_eff_end_date
                                       ELSE show_period.end_date
                                 END) end_date
                          FROM '||
                          l_show_period ||' show_period
                          WHERE
                          show_period.start_date <= :l_curr_eff_end_date
                          AND show_period.end_date >= :l_curr_eff_start_date
                          ORDER BY show_period.start_date desc)
                          UNION ALL
                          SELECT rownum, start_date, end_date, ''P'' FROM (
                          SELECT  show_period.start_date start_date
                         ,(CASE WHEN show_period.end_date > :l_prev_eff_end_date
                                       THEN :l_prev_eff_end_date
                                       ELSE show_period.end_date
                                 END) end_date
                          FROM '||
                          l_show_period ||' show_period
                          WHERE
                          show_period.start_date <= :l_prev_eff_end_date
                          AND show_period.end_date >= :l_prev_eff_start_date
                          ORDER BY show_period.start_date desc)';


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || g_pkg ||'.'||l_proc || '.debug ',
		                                    MESSAGE => 'l_time_sql: '||l_time_sql);
                     END IF;


        begin
            execute immediate 'TRUNCATE TABLE '||g_sch_name||'.'||'BIL_BI_RPT_TMP1';
        end;


/*
Get the current start and end dates, and previous start and end dates
Insert them into date1, date2 columns of bil_bi_rpt_tmp1
Insert a flag that will indicate whether they are
current or previous dates in sortorder column: 'C' for current, 'P' for prev
Insert the sequence of the current, prev dates into viewbyId
This will be used to combine current and previous dates
*/
	BEGIN
	  execute immediate 'insert into bil_bi_rpt_tmp1 (viewbyid, date1, date2, sortorder)  ('||l_time_sql||') '
	  using  l_curr_eff_end_date, l_curr_eff_end_date,
	         l_curr_eff_end_date, l_curr_eff_start_date,
                 l_prev_eff_end_date, l_prev_eff_end_date,
                 l_prev_eff_end_date,l_prev_eff_start_date;

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
         END;


                     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || g_pkg ||'.'||l_proc || '.debug ',
		                                    MESSAGE => 'Comp type: '||l_comp_type);

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || g_pkg ||'.'||l_proc || '.debug ',
		                                    MESSAGE => ' curr: '||l_curr_weeks||', prev: '||l_prev_weeks);

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
		                                    MODULE => g_pkg || l_proc || g_pkg ||'.'||l_proc || '.debug ',
		                                    MESSAGE => ' as of date: '||l_curr_as_of_date);
                     END IF;

       l_custom_sql :=  '
          SELECT    opty.VIEWBY VIEWBY,SUM(opty.BIL_MEASURE1) BIL_MEASURE1
	           ,SUM(opty.BIL_MEASURE2) BIL_MEASURE2
                   ,NVL(SUM(opty.BIL_MEASURE3),0) BIL_MEASURE3
		   ,CASE WHEN opty.viewby_date > &BIS_CURRENT_ASOF_DATE OR opty.viewby IS NULL THEN NULL
                          ELSE NVL(SUM(opty.BIL_MEASURE4),0) END  BIL_MEASURE4
                  ,NULL BIL_MEASURE5
                  ,NULL BIL_MEASURE6
          FROM (select temp.date2 viewby, temp.date1 viewby_date
		          ,SUM(CASE WHEN temp.date1 > &BIS_CURRENT_ASOF_DATE THEN
     		          NULL else DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt'||l_currency_suffix||',NULL) end) BIL_MEASURE1
				  ,SUM(CASE WHEN temp.date1 > &BIS_CURRENT_ASOF_DATE THEN NULL
					             else DECODE(sumry.salesrep_id,NULL,sumry.forecast_amt_sub'||l_currency_suffix||',
                                 sumry.forecast_amt'||l_currency_suffix||')
						  end) BIL_MEASURE2
					,NULL BIL_MEASURE3
					,NULL BIL_MEASURE4
					,temp.viewbyid sequence
					FROM
					  bil_bi_rpt_tmp1 temp,
					  '||l_frcst_tab||' sumry,
					  '||l_fii_struct||' cal
					  WHERE
					    cal.report_date = least(&BIS_CURRENT_ASOF_DATE,temp.date2)
					    and cal.xtd_flag = :l_yes
						AND cal.period_type_id = sumry.txn_period_type_id(+)
						AND bitand(cal.record_type_id,:l_bitand_id) = :l_bitand_id
						and sumry.effective_time_id(+) = :l_curr_page_time_id
						and sumry.effective_period_type_id(+) = :l_period_type
						AND sumry.txn_time_id(+) = cal.time_id
						AND sumry.credit_type_id(+) = :l_fst_crdt_type
						AND temp.sortorder = ''C'''
						||l_productcat_where_fst||
						' AND sumry.sales_group_id(+) = :l_sg_id ';
						/* Changed by Krishna as per forecast MV changes */

             if(l_resource_id is not null) then
                        l_custom_sql:= l_custom_sql ||
					' AND sumry.salesrep_id(+) = :l_resource_id AND sumry.parent_sales_group_id(+) = :l_sg_id';
             else
                l_custom_sql:=l_custom_sql ||
				' AND sumry.salesrep_id IS NULL ';
                if l_parent_sls_grp_id IS NULL then
                    l_custom_sql:=l_custom_sql || ' AND sumry.parent_sales_group_id IS NULL ';
                else
                   l_custom_sql:=l_custom_sql ||   ' AND sumry.parent_sales_group_id(+) = :l_parent_sls_grp_id ';
                end if;
             end if;

          l_custom_sql := l_custom_sql ||' GROUP BY temp.date2, temp.viewbyid,temp.date1 ';

          l_custom_sql := l_custom_sql||'UNION ALL
						SELECT tmp.date2 viewby,tmp.date1 viewby_date,
						null BIL_MEASURE1,
						null BIL_MEASURE2,
						sum(opty.BIL_MEASURE3) BIL_MEASURE3,
						sum(opty.BIL_MEASURE4) BIL_MEASURE4,
                                                opty.sequence sequence
                           from  ';


        l_custom_sql :=  l_custom_sql|| ' (
                          SELECT to_char(viewbyid_c) sequence,
                            BIL_MEASURE4, DECODE(viewbyid_p,NULL,LAST_VALUE(BIL_MEASURE3)OVER(),BIL_MEASURE3) BIL_MEASURE3 FROM
                            (select MAX(DECODE(mapping.sortorder, ''P'',to_number(mapping.viewbyid), null)) viewbyid_p
                                   ,MAX(DECODE(mapping.sortorder, ''C'',to_number(mapping.viewbyid), null)) viewbyid_c
                                   ,SUM(decode(mapping.sortorder, ''P'',NVL(timeslice.won_opty_amt,0), null)) BIL_MEASURE3
                                   ,SUM(DECODE(mapping.sortorder, ''C'',NVL(timeslice.won_opty_amt,0), null)) BIL_MEASURE4
                            from (select time_id,sumry.won_opty_amt won_opty_amt';

        IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN

                  l_custom_sql :=  l_custom_sql|| ' , sumry.product_category_id ';

        END IF;

                  l_custom_sql :=  l_custom_sql|| ' from (select time_id, sum(sumry.won_opty_amt'||l_currency_suffix||') won_opty_amt';


        IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN

                  l_custom_sql :=  l_custom_sql|| ',sumry.product_category_id from
                                   (select /*+ NO_MERGE */  eni1.child_id from  '|| l_denorm ||''||l_productcat_where||') eni1,';
        ELSE
                  l_custom_sql :=  l_custom_sql||' from ';

        END IF;

                  l_custom_sql :=  l_custom_sql||
                             ' (select /*+ NO_MERGE */  time_id, period_type_id
                                       from  bil_bi_rpt_tmp1 temp ,FII_TIME_STRUCTURES cal
                                       where cal.report_date = LEAST(&BIS_CURRENT_ASOF_DATE,temp.date2)
                                       and cal.xtd_flag = :l_yes
                                       and BITAND(cal.record_type_id,:l_record_type_id) = :l_record_type_id
                                       group by time_id, period_type_id )temp, '||l_won_tab||'
                                       WHERE temp.period_type_id = sumry.effective_period_type_id
                                       and sumry.effective_time_id = temp.time_id
                                       and sumry.sales_group_id = :l_sg_id ';

          IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN

                  l_custom_sql :=  l_custom_sql||' and sumry.product_category_id = eni1.child_id ';

          END IF;


            if(l_resource_id is not null) then
                  l_custom_sql:= l_custom_sql ||
                                 ' AND sumry.salesrep_id = :l_resource_id AND sumry.parent_sales_group_id = :l_sg_id';
             else
                  l_custom_sql:=l_custom_sql ||
                                ' AND sumry.salesrep_id IS NULL ';
               if l_parent_sls_grp_id IS NULL then
                  l_custom_sql:=l_custom_sql || ' AND sumry.parent_sales_group_id IS NULL ';
               else
                  l_custom_sql:=l_custom_sql ||   ' AND sumry.parent_sales_group_id = :l_parent_sls_grp_id ';
               end if;
             end if;


         IF 'ALL' <> UPPER(l_prodcat) OR l_prodcat IS NOT NULL THEN

                 l_custom_sql:=l_custom_sql ||' group  BY temp.time_id ,sumry.product_category_id )sumry ) timeslice,';

         ELSE

                 l_custom_sql:=l_custom_sql ||' group  BY temp.time_id )sumry ) timeslice,';

         END IF;


                 l_custom_sql:=l_custom_sql ||' (Select viewbyid,sortorder,time_id
                                         from
                                         (select viewbyid, cal.time_id, cal.period_type_id, sortorder
                                           from  bil_bi_rpt_tmp1 temp,FII_TIME_STRUCTURES cal
                                           where cal.report_date = LEAST(&BIS_CURRENT_ASOF_DATE,temp.date2)
                                           and cal.xtd_flag = :l_yes
                                           and BITAND(cal.record_type_id,:l_record_type_id) = :l_record_type_id ) time_pieces
                                           group by viewbyid, time_id, sortorder) mapping
                                         where timeslice.time_id(+) = mapping.time_id
                                         group by mapping.viewbyid order by viewbyid_p NULLS FIRST)) opty ,BIL_BI_RPT_TMP1 tmp
                                          WHERE opty.sequence = tmp.viewbyid
                                          AND tmp.sortorder=''C'' group by tmp.DATE1, opty.sequence,tmp.DATE2)  opty, BIL_BI_RPT_TMP1 tmp
                                          where opty.sequence=tmp.viewbyid(+)
                                          and tmp.sortorder(+)=''P'' group by opty.viewby, tmp.date1,opty.viewby_date
                                          ORDER BY opty.viewby';


    ELSE
         BIL_BI_UTIL_PKG.get_default_query(p_regionname => l_region_id
                                      ,x_sqlstr    => l_default_query);
            l_custom_sql := l_default_query;
    END IF;

      x_custom_sql := l_custom_sql;


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


         /* Bind parameters */
         l_bind_ctr:=1;

         l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
         l_custom_rec.attribute_value := l_viewby;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;

/*         l_custom_rec.attribute_name :=':l_no_comp_period';
         l_custom_rec.attribute_value :=l_no_comp_period;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;*/

         l_custom_rec.attribute_name :=':l_yes';
         l_custom_rec.attribute_value :=l_yes;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;


         l_custom_rec.attribute_name :=':l_curr_as_of_date';
         l_custom_rec.attribute_value :=TO_CHAR(l_curr_as_of_date,'DD/MM/YYYY');
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.DATE_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;

         l_custom_rec.attribute_name :=':l_curr_page_time_id';
         l_custom_rec.attribute_value :=l_curr_page_time_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
         l_custom_rec.attribute_name :=':l_prev_page_time_id';
         l_custom_rec.attribute_value :=l_prev_page_time_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
         l_custom_rec.attribute_name :=':l_calendar_id';
         l_custom_rec.attribute_value :=l_calendar_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
         l_custom_rec.attribute_name :=':l_sg_id';
         l_custom_rec.attribute_value :=l_sg_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;

       if(l_resource_id is not null) then
         l_custom_rec.attribute_name :=':l_resource_id';
         l_custom_rec.attribute_value :=l_resource_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
       end if;
       if(l_parent_sls_grp_id is not null) then
         l_custom_rec.attribute_name :=':l_parent_sls_grp_id';
         l_custom_rec.attribute_value :=l_parent_sls_grp_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
        end if;
         l_custom_rec.attribute_name :=':l_bitand_id';
         l_custom_rec.attribute_value :=l_bitand_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
         l_custom_rec.attribute_name :=':l_record_type_id';
         l_custom_rec.attribute_value :=l_record_type_id;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;
         l_custom_rec.attribute_name :=':l_period_type';
         l_custom_rec.attribute_value :=l_period_type;
         l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):=l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;

         IF (l_prodcat IS NOT NULL) THEN
             l_custom_rec.attribute_name :=':l_prodcat';
             l_custom_rec.attribute_value :=l_prodcat;
             l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
             l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
             x_custom_attr.Extend();
             x_custom_attr(l_bind_ctr):=l_custom_rec;
             l_bind_ctr:=l_bind_ctr+1;
         END IF;

         IF(l_product_id IS NOT NULL) THEN
             l_custom_rec.attribute_name :=':l_product_id';
             l_custom_rec.attribute_value :=l_product_id;
             l_custom_rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
             l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
             x_custom_attr.Extend();
             x_custom_attr(l_bind_ctr):=l_custom_rec;
             l_bind_ctr:=l_bind_ctr+1;
         END IF;


         l_custom_rec.attribute_name := ':l_fst_crdt_type';
         l_custom_rec.attribute_value := l_fst_crdt_type;
         l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
         l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
         x_custom_attr.Extend();
         x_custom_attr(l_bind_ctr):= l_custom_rec;
         l_bind_ctr:=l_bind_ctr+1;

                     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                     FND_LOG.STRING(LOG_LEVEL => fnd_log.LEVEL_PROCEDURE,
		                                    MODULE => g_pkg || l_proc || 'end',
		                                    MESSAGE => ' End of Procedure '|| l_proc);

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
END BIL_BI_FRCST_WON_TREND;

END BIL_BI_TREND_MGMT_RPTS_PKG;

/
