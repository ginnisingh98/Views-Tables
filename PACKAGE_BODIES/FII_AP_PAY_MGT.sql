--------------------------------------------------------
--  DDL for Package Body FII_AP_PAY_MGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_PAY_MGT" AS
/* $Header: FIIAPPMB.pls 120.2 2006/08/22 12:20:45 sajgeo noship $ */


/* Package for Holds Graph portlet */
PROCEDURE get_hold_cat_graph (
   p_page_parameter_tbl         IN  BIS_PMV_PAGE_PARAMETER_TBL,
   inv_graph_sql                OUT NOCOPY VARCHAR2,
   inv_graph_output	        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_viewby_dim                    VARCHAR2(240);  -- what is the viewby
        l_as_of_date                    DATE;
        l_organization                  VARCHAR2(240);
        l_supplier                      VARCHAR2(240);
        l_currency                      VARCHAR2(240);
        l_viewby_id                     VARCHAR2(240);  -- org_id or supplier_id
        l_record_type_id                NUMBER;         --
        l_gid                           NUMBER;         -- 0,4 or 8
        l_viewby_string                 VARCHAR2(240);
        inv_trend_rec                   BIS_QUERY_ATTRIBUTES;
        l_param_join                    VARCHAR2(240);
        l_cur_period                    NUMBER;
        l_id_column                     VARCHAR2(100);
        sqlstmt                         VARCHAR2(14000);
        l_invoice_number                VARCHAR2(240);
        l_org_WHERE                     VARCHAR2(240);
        l_supplier_WHERE                VARCHAR2(240);
        l_period_type                   VARCHAR2(240);
BEGIN

  FII_PMV_UTIL.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_WHERE,
       l_supplier_WHERE
       );

--       l_record_type_id := 1143;         /*removing this change made for bug no.3118619*/

/*-----------------------------------------------------+
 |  FII_MEASURE1  - Hold Category                      |
 |  FII_MEASURE2  - Number of Holds                    |
 +-----------------------------------------------------*/

-- construct the sql statement

sqlstmt := '
    SELECT DECODE(t.multiplier,1, fnd_message.get_string(''FII'',''FII_AP_HOLD_PO''),
                               2, fnd_message.get_string(''FII'',''FII_AP_HOLD_VAR''),
                               3, fnd_message.get_string(''FII'',''FII_AP_HOLD_INV''),
                               4, fnd_message.get_string(''FII'',''FII_AP_HOLD_USR''),
                               5, fnd_message.get_string(''FII'',''FII_AP_HOLD_OTR''), null)  FII_MEASURE1,
           DECODE(t.multiplier, 1, SUM(po_matching_hold_count),
                                2, SUM(variance_hold_count) ,
                                3, SUM(invoice_hold_count),
                                4, SUM(user_defined_hold_count),
                                5, SUM(other_hold_count))     FII_MEASURE2
            FROM fii_ap_hcat_ib_mv f,
                 gl_row_multipliers t,
                 fii_time_structures cal
           WHERE  f.time_id = cal.time_id
           AND   f.period_type_id = cal.period_type_id
                 '||l_supplier_where||'   '||l_org_where||'
	    AND	bitand(cal.record_type_id,:RECORD_TYPE_ID) = :RECORD_TYPE_ID
	    AND f.hold_release_flag = ''H''    /*added this code for bugno. 3108542*/
	    AND	cal.report_date in (&BIS_CURRENT_ASOF_DATE)
	    AND	f.gid = :GID
            AND t.multiplier in (1,2,3,4,5)
           GROUP by t.multiplier';


FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>inv_graph_sql,
	p_bind_output_table=>inv_graph_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid);

END get_hold_cat_graph;


PROCEDURE get_late_ontime_payment (
   p_page_parameter_tbl         IN  BIS_PMV_PAGE_PARAMETER_TBL,
   inv_graph_sql                OUT NOCOPY VARCHAR2,
   inv_graph_output	        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_viewby_dim                    VARCHAR2(240);  -- what is the viewby
        l_as_of_date                    DATE;
        l_organization                  VARCHAR2(240);
        l_supplier                      VARCHAR2(240);
        l_currency                      VARCHAR2(240);
        l_viewby_id                     VARCHAR2(240);  -- org_id or supplier_id
        l_record_type_id                NUMBER;         --
        l_gid                           NUMBER;         -- 0,4 or 8
        l_viewby_string                 VARCHAR2(240);
        l_param_join                    VARCHAR2(240);
        l_cur_period                    NUMBER;
        l_id_column                     VARCHAR2(100);
        sqlstmt                         VARCHAR2(14000);
        l_invoice_number                VARCHAR2(240);
        l_org_WHERE                     VARCHAR2(240);
        l_supplier_WHERE                VARCHAR2(240);
        l_period_type                   VARCHAR2(240);
        l_period_start                  DATE;
        l_report_start                  DATE;
        l_cur_effective_num             NUMBER;
        l_paid_on_time_count		VARCHAR2(240);
        l_paid_late_count		VARCHAR2(240);
BEGIN

  FII_PMV_UTIL.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_WHERE,
       l_supplier_WHERE
       );


  l_paid_late_count	:= 'paid_late_count'||FII_PMV_UTIL.get_period_type_suffix (l_period_type);
  l_paid_on_time_count	:= 'paid_on_time_count'||FII_PMV_UTIL.get_period_type_suffix (l_period_type);


/*------------------------------------------------------+
 |  FII_MEASURE1  - Prior Paid Late			|
 |  FII_MEASURE2  - Prior Paid on Time			|
 |  FII_MEASURE3  - Invoice Paid Late			|
 |  FII_MEASURE4  - Invoice Paid on Time		|
 +------------------------------------------------------*/

-- construct the sql statement


sqlstmt := '
	SELECT
	    viewby_dim.value		VIEWBY,
	    viewby_dim.id					VIEWBYID,
     sum(f.FII_MEASURE1) FII_MEASURE1,
     sum(f.FII_MEASURE2) FII_MEASURE2,
     sum(f.FII_MEASURE3) FII_MEASURE3,
     sum(f.FII_MEASURE4) FII_MEASURE4
 from
 (select id,
         FII_MEASURE1,
         FII_MEASURE2,
         FII_MEASURE3,
         FII_MEASURE4,
         ( rank() over (order by ID asc)) - 1 rnk
  from
  (select f.'||l_viewby_id||' id,
	     SUM(CASE WHEN  cal.report_date = &BIS_CURRENT_ASOF_DATE
		 THEN f.'||l_paid_late_count||' ELSE 0 END)	FII_MEASURE1,
	     SUM(CASE WHEN  cal.report_date = &BIS_PREVIOUS_ASOF_DATE
 		THEN f.'||l_paid_late_count||' ELSE 0 END)	FII_MEASURE2,
	     SUM(CASE WHEN  cal.report_date = &BIS_CURRENT_ASOF_DATE
		 THEN f.'||l_paid_on_time_count||' ELSE 0 END)	FII_MEASURE3,
	     SUM(CASE WHEN  cal.report_date = &BIS_PREVIOUS_ASOF_DATE
 		THEN f.'||l_paid_on_time_count||' ELSE 0 END)	FII_MEASURE4
	  FROM FII_AP_PAYOL_XB_MV f,
	       fii_time_structures cal
   WHERE f.time_id = cal.time_id
	  AND   f.period_type_id = cal.period_type_id
	  AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
 	 AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
	  AND   f.gid = :GID
   '||l_org_WHERE||' '||l_supplier_WHERE||'
   group by f.'||l_viewby_id||')) f,
 '||l_viewby_string||' viewby_dim
	where f.id = viewby_dim.id
 and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
	GROUP BY viewby_dim.value, viewby_dim.id
	&ORDER_BY_CLAUSE';


FII_PMV_UTIL.bind_variable(
	p_sqlstmt=>sqlstmt,
	p_page_parameter_tbl=>p_page_parameter_tbl,
	p_sql_output=>inv_graph_sql,
	p_bind_output_table=>inv_graph_output,
	p_invoice_number=>l_invoice_number,
	p_record_type_id=>l_record_type_id,
	p_view_by=>l_viewby_id,
	p_gid=>l_gid);

END get_late_ontime_payment;


/* For Invoices Graph Report */

PROCEDURE get_inv_graph (
   p_page_parameter_tbl         IN  BIS_PMV_PAGE_PARAMETER_TBL,
   inv_graph_sql                OUT NOCOPY VARCHAR2,
   inv_graph_output	        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   l_stmt                       VARCHAR2(10000);
   l_page_period_type           VARCHAR2(32000);
   l_pk                         VARCHAR2(30);
   l_name                       VARCHAR2(100);
   l_actual_period_type         NUMBER;
   l_period_type                VARCHAR2(1000);
   l_week_num                   NUMBER;
   inv_graph_rec 	        BIS_QUERY_ATTRIBUTES;
   l_time_comp                  VARCHAR2(20);
   l_as_of_date                 DATE;
   l_p_as_of_date               DATE;
   l_ent_pyr_start              DATE;
   l_ent_pyr_END                DATE;
   l_ent_cyr_start              DATE;
   l_ent_cyr_END                DATE;
   l_cy_period_END              DATE;
   l_start                      DATE;
   l_curr_effective_num         NUMBER;
   i                            NUMBER;
   l_begin_date                 DATE;
   l_currency                   VARCHAR2(240);
   l_organization               VARCHAR2(240);
   l_supplier                   VARCHAR2(240);
   l_org_WHERE                  VARCHAR2(240);
   l_supplier_WHERE             VARCHAR2(240);
   l_invoice_number             NUMBER;
   l_record_type_id             NUMBER;
   l_viewby_dim                 VARCHAR2(240);
   l_viewby_id                  VARCHAR2(240);
   l_viewby_string              VARCHAR2(240);
   l_gid                        NUMBER;
   l_start_date                 DATE;
BEGIN
   FII_PMV_Util.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_WHERE,
       l_supplier_WHERE
       );
 /* Removing the hard coded value for bug # 3262629*/
--  l_gid := 4;

   l_week_num := 13;
   inv_graph_output := BIS_QUERY_ATTRIBUTES_TBL();
   inv_graph_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    IF (p_page_parameter_tbl.count > 0) THEN
        i:=  p_page_parameter_tbl.first;
   FOR cnt in 1..p_page_parameter_tbl.count LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
         l_page_period_type := p_page_parameter_tbl(i).parameter_value;
       ELSIF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
       l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY');
       ELSIF p_page_parameter_tbl(i).parameter_name= 'TIME_COMPARISON_TYPE' THEN
         l_time_comp := p_page_parameter_tbl(i).parameter_value;
       END IF;
        i := p_page_parameter_tbl.next(i);
     END LOOP;
   END IF;


  CASE l_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN l_actual_period_type := 32;
    WHEN 'FII_TIME_ENT_PERIOD' THEN l_actual_period_type := 64;
    WHEN 'FII_TIME_ENT_QTR'    THEN l_actual_period_type := 128;
    WHEN 'FII_TIME_ENT_YEAR'   THEN l_actual_period_type := 256;
  END CASE;

   select nvl(min(start_date), trunc(sysdate)) into l_start_date from fii_time_ent_year;

   --l_ent_pyr_start := fii_time_api.ent_pyr_start(l_as_of_date);
   select nvl(fii_time_api.ent_pyr_END(l_as_of_date), l_start_date-1) into l_ent_pyr_END from dual;
   select nvl(fii_time_api.ent_cyr_start(l_as_of_date), l_start_date) into l_ent_cyr_start from dual;
   select nvl(fii_time_api.ent_cyr_END(l_as_of_date), l_start_date) into l_ent_cyr_END from dual;

   select nvl(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start
             (fii_time_api.ent_pyr_start(l_as_of_date))),l_start_date-1)
   into l_ent_pyr_start from dual;  /* Bug 3325387 */

   CASE l_page_period_type
     WHEN 'FII_TIME_WEEK' THEN
        l_period_type    := 16;
        l_pk             := 'week_id';
        inv_graph_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        inv_graph_rec.attribute_value := 'TIME+FII_TIME_WEEK';
        inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_name           := 'replace(fnd_message.get_string(''FII'',''FII_WEEK_LABEL''),''&WEEK_NUMBER'',t.sequence)';
        select nvl(fii_time_api.pwk_END(l_as_of_date), l_start_date) into l_cy_period_END from dual;
        select nvl(fii_time_api.sd_lyswk(l_as_of_date), l_start_date) into l_p_as_of_date from dual;
        select nvl(fii_time_api.sd_lyswk(l_p_as_of_date), l_start_date) into l_start from dual;
        l_begin_date := l_as_of_date - 91;
        SELECT  sequence  into    l_curr_effective_num
        FROM    fii_time_week
        WHERE   l_as_of_date between start_date AND END_date;

     WHEN 'FII_TIME_ENT_PERIOD' THEN
       l_period_type    := 32;
       l_pk             := 'ent_period_id';
       -- l_bis_map_rec.key:= BIS_PMV_QUERY_PVT.VIEW_BY_KEY;
       -- l_bis_map_rec.value:= 'TIME+FII_TIME_ENT_PERIOD';
       inv_graph_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
       inv_graph_rec.attribute_value :='TIME+FII_TIME_ENT_PERIOD';
       inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
       l_name           := 'to_char(t.start_date,''Mon'')';
       select nvl(fii_time_api.ent_pper_END(l_as_of_date), l_start_date) into l_cy_period_END from dual;
       select nvl(fii_time_api.ent_sd_lysper_END(l_as_of_date), l_start_date) into l_p_as_of_date from dual;
       select nvl(fii_time_api.ent_sd_lysper_END(l_p_as_of_date), l_start_date) into l_start from dual;
       l_begin_date := l_p_as_of_date;
       SELECT  sequence  into    l_curr_effective_num
       FROM    fii_time_ent_period
       WHERE   l_as_of_date between start_date AND END_date;

     WHEN 'FII_TIME_ENT_QTR' THEN
       l_period_type    := 64;
       l_pk             := 'ent_qtr_id';
       -- l_bis_map_rec.key:= BIS_PMV_QUERY_PVT.VIEW_BY_KEY;
       -- l_bis_map_rec.value:= 'TIME+FII_TIME_ENT_QTR';
        inv_graph_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        inv_graph_rec.attribute_value :='TIME+FII_TIME_ENT_QTR';
        inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_name           :=
             'replace(fnd_message.get_string(''FII'',''FII_QUARTER_LABEL''),''&QUARTER_NUMBER'',t.sequence)';
       select nvl(fii_time_api.ent_pqtr_END(l_as_of_date), l_start_date) into l_cy_period_END from dual;
       IF (l_time_comp = 'SEQUENTIAL') THEN
         select nvl(fii_time_api.ent_sd_lysqtr_END(l_as_of_date), l_start_date) into l_p_as_of_date from dual;
         SELECT  ent_qtr_id  into   l_curr_effective_num
         FROM    fii_time_ent_qtr
         WHERE   l_as_of_date between start_date AND END_date;
         select nvl(fii_time_api.ent_sd_lysqtr_END(fii_time_api.ent_sd_lysqtr_END(l_p_as_of_date)), l_start_date) into l_begin_date from dual;
         select nvl(fii_time_api.ent_sd_lysqtr_END(l_p_as_of_date), l_start_date-1) into l_start from dual;
       ELSE
         select nvl(fii_time_api.ent_sd_lysqtr_END(l_as_of_date), l_start_date) into l_p_as_of_date from dual;
         SELECT  sequence  into    l_curr_effective_num
         FROM    fii_time_ent_qtr
         WHERE   l_as_of_date between start_date AND END_date;
         l_begin_date := l_p_as_of_date;
         select nvl(fii_time_api.ent_sd_lysqtr_END(l_p_as_of_date), l_start_date) into l_start from dual;
       END IF;

     WHEN 'FII_TIME_ENT_YEAR' THEN
       l_period_type    := 128;
       l_pk             := 'ent_year_id';
       -- l_bis_map_rec.key:= BIS_PMV_QUERY_PVT.VIEW_BY_KEY;
       -- l_bis_map_rec.value:= 'TIME+FII_TIME_ENT_YEAR';
        inv_graph_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
       inv_graph_rec.attribute_value :='TIME+FII_TIME_ENT_YEAR';
       inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;

       select nvl(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(l_ent_cyr_start))), l_start_date) into l_begin_date from dual;
   END CASE;

   -- p_bis_map_tbl.extEND;
   -- p_bis_map_tbl(p_bis_map_tbl.count) := l_bis_map_rec;
   -- l_bis_map_rec.key := BIS_PMV_QUERY_PVT.QUERY_STR_KEY;
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output.EXTEND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;

/*------------------------------------------------------+
 |  FII_MEASURE1     - Electronic Invoices Entered	|
 |  FII_MEASURE2     - Manual Invoices Entered		|
 |  FII_MEASURE3     - Name of the period		|
 +------------------------------------------------------*/

IF l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
     -- l_bis_map_rec.value := '

inv_graph_sql := 'SELECT
            		t.name                             	FII_MEASURE3,
            		max(inline_view.e_invoice_count)        FII_MEASURE1,
            		max(inline_view.m_invoice_count)        FII_MEASURE2
    		  FROM
      			(SELECT inner_inline_view.FII_SEQUENCE    	FII_SEQUENCE,
                     		SUM(e_invoice_count)                 	e_invoice_count,
                     		SUM(m_invoice_count)                 	m_invoice_count
        		FROM
           			( SELECT
                  		t.sequence                      		FII_SEQUENCE,
                    		f.e_invoice_count  				e_invoice_count,
                    		(f.invoice_count_entered - f.e_invoice_count) 	m_invoice_count

                  		FROM  FII_AP_IVATY_XB_MV f,
                          	'||l_page_period_type||' t
                  		WHERE  f.gid   = :GID
              	  		AND   f.time_id = t.'||l_pk||'
                  		AND   f.period_type_id = :FII_BIND6
                  		AND   t.start_date between
 					to_date(:FII_BIND9, ''DD/MM/YYYY'')  /* Bug 3325387 */

                		AND  to_date(:FII_BIND10, ''DD/MM/YYYY'')
		 		'||l_org_WHERE||' '||l_supplier_WHERE||'

      			UNION ALL
                		SELECT
                        	t.sequence              			FII_SEQUENCE,
                        	f.e_invoice_count   				e_invoice_count,
                        	(f.invoice_count_entered - f.e_invoice_count) 	m_invoice_count

                     		FROM  FII_AP_IVATY_XB_MV 	   f,
                           	      fii_time_structures          cal,
                           	      '||l_page_period_type||'     t ,
                           	      fii_time_day                 day

             			WHERE f.gid = :GID
             			AND   f.period_type_id        = cal.period_type_id
             			AND   f.time_id = cal.time_id
             			AND   bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1  /*made changes for bug no.3108435*/
             			AND   cal.report_date  = &BIS_CURRENT_ASOF_DATE
             			AND   cal.report_date = day.report_date
             			AND  day.'||l_pk||' = t.'||l_pk||'
	     			'||l_org_WHERE||' '||l_supplier_WHERE||'

       			) inner_inline_view
     			GROUP BY inner_inline_view.FII_SEQUENCE

		) inline_view,  '||l_page_period_type||' t

		WHERE FII_SEQUENCE (+)= t.sequence
		AND t.start_date >= to_date(:FII_BIND14, ''DD/MM/YYYY'')
		AND t.END_date   <= to_date(:FII_BIND12, ''DD/MM/YYYY'')
		GROUP BY t.sequence, t.name, t.'||l_pk||'
		ORDER BY t.sequence';


  ELSIF ((l_page_period_type = 'FII_TIME_ENT_QTR') AND (l_time_comp = 'SEQUENTIAL'))THEN

   inv_graph_sql := 'SELECT
            		t.name                             FII_MEASURE3,
            		inline_view.e_invoice_count        FII_MEASURE1,
            		inline_view.m_invoice_count        FII_MEASURE2

        	     FROM
          		( SELECT
                     		inner_inline_view.FII_SEQUENCE   FII_EFFECTIVE_NUM,
                     		SUM(e_invoice_count)             e_invoice_count,
                     		SUM(m_invoice_count)             m_invoice_count

              		FROM
                    	( SELECT
                         	t.'||l_pk||' FII_SEQUENCE,
                        	(CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN
                                          (CASE WHEN t.start_date > to_date(:FII_BIND7,''DD/MM/YYYY'')
                        			AND t.start_date <= to_date(:FII_BIND8, ''DD/MM/YYYY'')
                              	     		THEN f.e_invoice_count ELSE TO_NUMBER(NULL) END)
			      	      ELSE TO_NUMBER(NULL) END ) e_invoice_count,

                        	(CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN
                                          (CASE WHEN t.start_date > to_date(:FII_BIND7,''DD/MM/YYYY'')
                                                AND t.start_date <= to_date(:FII_BIND8, ''DD/MM/YYYY'')
                              			THEN (f.invoice_count_entered - f.e_invoice_count) ELSE TO_NUMBER(NULL) END)
			      	      ELSE TO_NUMBER(NULL) END ) m_invoice_count

                     	FROM  FII_AP_IVATY_XB_MV f,
                          '||l_page_period_type||' t

                     	WHERE  f.gid   = :GID
                     	AND   f.time_id = t.'||l_pk||'
                     	AND   f.period_type_id = :FII_BIND6
                     	AND   t.start_date between to_date(:FII_BIND13, ''DD/MM/YYYY'') AND &BIS_CURRENT_ASOF_DATE
                     	'||l_org_WHERE||' '||l_supplier_WHERE||'
           UNION ALL

                   SELECT
                        t.'||l_pk||' FII_SEQUENCE,
                        (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN
                                          (CASE WHEN  t.start_date > to_date(:FII_BIND13,''DD/MM/YYYY'')
                                                AND t.start_date <= to_date(:FII_BIND7, ''DD/MM/YYYY'')
                                                THEN f.e_invoice_count ELSE TO_NUMBER(NULL) END)
			      ELSE TO_NUMBER(NULL) END ) e_invoice_count,

                        (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN
                                          (CASE WHEN  t.start_date > to_date(:FII_BIND13,''DD/MM/YYYY'')
                                                AND t.start_date <= to_date(:FII_BIND7, ''DD/MM/YYYY'')
                                                THEN (f.invoice_count_entered - f.e_invoice_count)
				ELSE TO_NUMBER(NULL) END) ELSE TO_NUMBER(NULL) END ) m_invoice_count

                   FROM  FII_AP_IVATY_XB_MV f,
                          '||l_page_period_type||' t

                   WHERE  f.gid   = :GID
                   AND   f.time_id = t.'||l_pk||'
                   AND   f.period_type_id        = :FII_BIND6
                   AND   t.start_date between to_date(:FII_BIND14, ''DD/MM/YYYY'')
			 AND to_date(:FII_BIND7, ''DD/MM/YYYY'')
		   '||l_org_WHERE||' '||l_supplier_WHERE||'

          UNION ALL

		   SELECT  :FII_BIND5 FII_SEQUENCE,
                     	   (CASE WHEN  cal.report_date = &BIS_CURRENT_ASOF_DATE AND
				 bitand(cal.record_type_id, :FII_BIND1) = :FII_BIND1
                            THEN f.e_invoice_count  ELSE TO_NUMBER(NULL) END)  e_invoice_count,

                      	   (CASE WHEN  cal.report_date = &BIS_CURRENT_ASOF_DATE AND
		   		 bitand(cal.record_type_id, :FII_BIND1) = :FII_BIND1
                            THEN (f.invoice_count_entered - f.e_invoice_count) ELSE TO_NUMBER(NULL) END)  m_invoice_count

                   FROM  FII_AP_IVATY_XB_MV f,
                          fii_time_structures  cal

                   WHERE  f.gid   = :GID
                   AND   f.time_id               = cal.time_id
            	   AND   f.period_type_id        = cal.period_type_id
                   AND   bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
                   AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE, (to_date(:FII_BIND7, ''DD/MM/YYYY'')) )
	           '||l_org_WHERE||' '||l_supplier_WHERE||'

    	 ) inner_inline_view

      GROUP BY inner_inline_view.FII_SEQUENCE

    ) inline_view,  '||l_page_period_type||' t

  WHERE inline_view.fii_effective_num (+)= t.'||l_pk||'
  AND t.start_date <= &BIS_CURRENT_ASOF_DATE
  AND t.start_date >  to_date(:FII_BIND13, ''DD/MM/YYYY'')
  ORDER BY t.start_date';

ELSE
  inv_graph_sql := '
         SELECT
            t.name                             FII_MEASURE3,
            inline_view.e_invoice_count        FII_MEASURE1,
            inline_view.m_invoice_count        FII_MEASURE2
         FROM
            (
              SELECT inner_inline_view.FII_SEQUENCE   FII_EFFECTIVE_NUM,
                     SUM(e_invoice_count)             e_invoice_count,
                     SUM(m_invoice_count)             m_invoice_count
              FROM
                    (
                    SELECT
                        t.sequence                      FII_SEQUENCE,
                        (CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
                        	    to_date(:FII_BIND7,''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
                              THEN f.e_invoice_count ELSE TO_NUMBER(NULL) END) ELSE TO_NUMBER(NULL) END ) e_invoice_count,

                        (CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
                        	    to_date(:FII_BIND7,''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
                              THEN (f.invoice_count_entered - f.e_invoice_count) ELSE TO_NUMBER(NULL) END) ELSE TO_NUMBER(NULL) END ) m_invoice_count

                     FROM  FII_AP_IVATY_XB_MV 	    f,
                           '||l_page_period_type||' t

                     WHERE  f.gid   = :GID
                     AND   f.time_id = t.'||l_pk||'
                     AND   f.period_type_id = :FII_BIND6
                     AND   t.start_date between to_date(:FII_BIND13, ''DD/MM/YYYY'') AND &BIS_CURRENT_ASOF_DATE
                     '||l_org_WHERE||' '||l_supplier_WHERE||'

            UNION ALL

                SELECT
                         :FII_BIND5 FII_SEQUENCE,
                         (CASE WHEN  cal.report_date = &BIS_CURRENT_ASOF_DATE AND
                                bitand(cal.record_type_id, :FII_BIND1) = :FII_BIND1
                                THEN f.e_invoice_count ELSE TO_NUMBER(NULL) END )  e_invoice_count,

                         (CASE WHEN  cal.report_date = &BIS_CURRENT_ASOF_DATE AND
                                bitand(cal.record_type_id, :FII_BIND1) = :FII_BIND1
                                THEN (f.invoice_count_entered - f.e_invoice_count) ELSE TO_NUMBER(NULL) END ) m_invoice_count

                            FROM  FII_AP_IVATY_XB_MV f,
				  fii_time_structures cal
                            WHERE f.gid = :GID
                            AND   f.period_type_id        = cal.period_type_id
                            AND   f.time_id = cal.time_id
                            AND   bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
                            AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE, (to_date(:FII_BIND7, ''DD/MM/YYYY'')))
                            '||l_org_WHERE||' '||l_supplier_WHERE||'

         ) inner_inline_view

            GROUP BY inner_inline_view.FII_SEQUENCE

       ) inline_view,  '||l_page_period_type||' t
       WHERE inline_view.fii_effective_num (+)= t.sequence
       AND t.start_date <= &BIS_CURRENT_ASOF_DATE
       AND t.start_date >  to_date(:FII_BIND14, ''DD/MM/YYYY'')
       ORDER BY t.start_date';

   END IF;

    inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND1';
   inv_graph_rec.attribute_value := TO_CHAR(l_actual_period_type);
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND5';
   inv_graph_rec.attribute_value := TO_CHAR(l_curr_effective_num);
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND6';
   inv_graph_rec.attribute_value := TO_CHAR(l_period_type);
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND7';
   inv_graph_rec.attribute_value := TO_CHAR(l_p_as_of_date,'DD/MM/YYYY');
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND8';
   inv_graph_rec.attribute_value := TO_CHAR(l_cy_period_END,'DD/MM/YYYY');
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND9';
   inv_graph_rec.attribute_value := TO_CHAR(l_ent_pyr_start,'DD/MM/YYYY');
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND10';
   inv_graph_rec.attribute_value := TO_CHAR(l_ent_pyr_END,'DD/MM/YYYY');
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND11';
   inv_graph_rec.attribute_value := TO_CHAR(l_ent_cyr_start,'DD/MM/YYYY');
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND12';
   inv_graph_rec.attribute_value := TO_CHAR(l_ent_cyr_END,'DD/MM/YYYY');
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND13';
   inv_graph_rec.attribute_value := TO_CHAR(l_start,'DD/MM/YYYY');
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':FII_BIND14';
   inv_graph_rec.attribute_value := TO_CHAR(l_begin_date,'DD/MM/YYYY');
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':GID';
   inv_graph_rec.attribute_value := to_char(l_gid);
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;
   inv_graph_rec.attribute_name := ':SEC_ID';
   inv_graph_rec.attribute_value := fii_pmv_util.get_sec_profile;
   inv_graph_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   inv_graph_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
   inv_graph_output(inv_graph_output.COUNT) := inv_graph_rec;
   inv_graph_output.EXTEND;

END get_inv_graph;


/* For Electronic Invoices and Late Payments  */


PROCEDURE get_elec_late_payment (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
elec_late_payment_sql out NOCOPY VARCHAR2, elec_late_payment_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   l_stmt                       VARCHAR2(10000);
   l_page_period_type           VARCHAR2(32000);
   l_pk                         VARCHAR2(30);
   l_name                       VARCHAR2(100);
   l_actual_period_type         NUMBER;
   l_period_type                VARCHAR2(1000);
   l_week_num                   NUMBER;
   elec_late_payment_rec 	    BIS_QUERY_ATTRIBUTES;
   l_time_comp                  VARCHAR2(20);
   l_as_of_date                 DATE;
   l_p_as_of_date               DATE;
   l_ent_pyr_start              DATE;
   l_ent_pyr_END                DATE;
   l_ent_cyr_start              DATE;
   l_ent_cyr_END                DATE;
   l_cy_period_END              DATE;
   l_start                      DATE;
   l_curr_effective_num         NUMBER;
   i                            NUMBER;
   l_begin_date                 DATE;
   l_period_suffix              VARCHAR2(240);
   l_currency                   VARCHAR2(240);
   l_organization               VARCHAR2(240);
   l_supplier                   VARCHAR2(240);
   l_org_WHERE                  VARCHAR2(240);
   l_supplier_WHERE             VARCHAR2(240);
   l_invoice_number             NUMBER;
   l_record_type_id             NUMBER;
   l_viewby_dim                 VARCHAR2(240);
   l_viewby_id                  VARCHAR2(240);
   l_viewby_string              VARCHAR2(240);
   l_gid                        NUMBER;
   ltd                          VARCHAR2(4);
   l_ent_year_st1               DATE;
   l_ent_year_st2               DATE;

   l_start_date                 DATE;

BEGIN
   FII_PMV_Util.Get_Parameters(
       p_page_parameter_tbl,
       l_as_of_date,
       l_organization,
       l_supplier,
       l_invoice_number,
       l_period_type,
       l_record_type_id,
       l_viewby_dim,
       l_currency,
       l_viewby_id,
       l_viewby_string,
       l_gid,
       l_org_WHERE,
       l_supplier_WHERE
       );


   l_week_num := 13;
   elec_late_payment_output := BIS_QUERY_ATTRIBUTES_TBL();
   elec_late_payment_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    IF (p_page_parameter_tbl.count > 0) THEN
        i:=  p_page_parameter_tbl.first;
   FOR cnt in 1..p_page_parameter_tbl.count LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
         l_page_period_type := p_page_parameter_tbl(i).parameter_value;
       ELSIF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
       l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY');
       ELSIF p_page_parameter_tbl(i).parameter_name= 'TIME_COMPARISON_TYPE' THEN
         l_time_comp := p_page_parameter_tbl(i).parameter_value;

       END IF;
        i := p_page_parameter_tbl.next(i);
     END LOOP;
   END IF;

  CASE l_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN l_actual_period_type := 32;
    WHEN 'FII_TIME_ENT_PERIOD' THEN l_actual_period_type := 64;
    WHEN 'FII_TIME_ENT_QTR'    THEN l_actual_period_type := 128;
    WHEN 'FII_TIME_ENT_YEAR'   THEN l_actual_period_type := 256;
  END CASE;

   select nvl(min(start_date), trunc(sysdate)) into l_start_date from fii_time_ent_year;

   select fii_time_api.ent_pyr_start(l_as_of_date) into l_ent_pyr_start from dual;
   select nvl(fii_time_api.ent_pyr_END(l_as_of_date), l_start_date-1) into l_ent_pyr_END from dual;
   select fii_time_api.ent_cyr_start(l_as_of_date) into l_ent_cyr_start from dual;
   select nvl(fii_time_api.ent_cyr_END(l_as_of_date), l_start_date) into l_ent_cyr_END from dual;


   select nvl(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(l_ent_pyr_start)),l_start_date-1)
   into l_ent_year_st1 from dual;
   select nvl(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(fii_time_api.ent_pyr_start(l_ent_cyr_start))),l_start_date-1)
   into l_ent_year_st2 from dual;

   CASE l_page_period_type
     WHEN 'FII_TIME_WEEK' THEN
        l_period_type    := 16;
        l_pk             := 'week_id';
        ltd             := '_WTD';
        elec_late_payment_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        elec_late_payment_rec.attribute_value := 'TIME+FII_TIME_WEEK';
        elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_name           := 'replace(fnd_message.get_string(''FII'',''FII_WEEK_LABEL''),
				    ''&WEEK_NUMBER'',t.sequence)';
        select nvl(fii_time_api.pwk_END(l_as_of_date), l_start_date) into l_cy_period_END from dual;
        select nvl(fii_time_api.sd_lyswk(l_as_of_date), l_start_date) into l_p_as_of_date from dual;
        select nvl(fii_time_api.sd_lyswk(l_p_as_of_date), l_start_date) into l_start from dual;
        l_begin_date := l_as_of_date - 91;

        SELECT  sequence  into    l_curr_effective_num
        FROM    fii_time_week
        WHERE   l_as_of_date between start_date AND END_date;

     WHEN 'FII_TIME_ENT_PERIOD' THEN
       l_period_type    := 32;
       l_pk             := 'ent_period_id';
       ltd             := '_MTD';
       -- l_bis_map_rec.key:= BIS_PMV_QUERY_PVT.VIEW_BY_KEY;
       -- l_bis_map_rec.value:= 'TIME+FII_TIME_ENT_PERIOD';
       elec_late_payment_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
       elec_late_payment_rec.attribute_value :='TIME+FII_TIME_ENT_PERIOD';
       elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
       l_name           := 'to_char(t.start_date,''Mon'')';
       select nvl(fii_time_api.ent_pper_END(l_as_of_date), l_start_date) into l_cy_period_END from dual;
       select nvl(fii_time_api.ent_sd_lysper_END(l_as_of_date), l_start_date) into l_p_as_of_date from dual;
       select nvl(fii_time_api.ent_sd_lysper_END(l_p_as_of_date), l_start_date) into l_start from dual;
       l_begin_date := l_p_as_of_date;

       SELECT  sequence  into    l_curr_effective_num
       FROM    fii_time_ent_period
       WHERE   l_as_of_date between start_date AND END_date;

     WHEN 'FII_TIME_ENT_QTR' THEN
       l_period_type    := 64;
       l_pk             := 'ent_qtr_id';
       ltd             := '_QTD';
       -- l_bis_map_rec.key:= BIS_PMV_QUERY_PVT.VIEW_BY_KEY;
       -- l_bis_map_rec.value:= 'TIME+FII_TIME_ENT_QTR';
        elec_late_payment_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
        elec_late_payment_rec.attribute_value :='TIME+FII_TIME_ENT_QTR';
        elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        l_name           :=
             'replace(fnd_message.get_string(''FII'',''FII_QUARTER_LABEL''),''&QUARTER_NUMBER'',t.sequence)';
       select nvl(fii_time_api.ent_pqtr_END(l_as_of_date), l_start_date) into l_cy_period_END from dual;
       IF (l_time_comp = 'SEQUENTIAL') THEN
       --  select nvl(fii_time_api.ent_sd_lysqtr_END(l_as_of_date), l_start_date) into l_p_as_of_date from dual;
	select  nvl(fii_time_api.ent_sd_pqtr_END(l_as_of_date), l_start_date) into
	l_p_as_of_date from dual;

         SELECT  ent_qtr_id  into   l_curr_effective_num
         FROM    fii_time_ent_qtr
         WHERE   l_as_of_date between start_date AND END_date;
         --select nvl(fii_time_api.ent_sd_lysqtr_END(fii_time_api.ent_sd_lysqtr_END(l_p_as_of_date)), l_start_date) into l_begin_date from dual;
	select
	nvl(fii_time_api.ent_sd_lysqtr_END(nvl(fii_time_api.ent_sd_lysqtr_END(fii_time_api.ent_sd_lysqtr_END(l_p_as_of_date)),
	l_start_date)), l_start_date) into l_begin_date from dual;

         --select nvl(fii_time_api.ent_sd_lysqtr_END(l_p_as_of_date), l_start_date-1) into l_start from dual;
	select
	fii_time_api.ent_sd_lysqtr_END(nvl(fii_time_api.ent_sd_lysqtr_END(l_as_of_date),
	l_start_date-1)) into l_start  from dual;

       ELSE
         select nvl(fii_time_api.ent_sd_lysqtr_END(l_as_of_date), l_start_date) into l_p_as_of_date from dual;
         SELECT  sequence  into    l_curr_effective_num
         FROM    fii_time_ent_qtr
         WHERE   l_as_of_date between start_date AND END_date;
         l_begin_date := l_p_as_of_date;
         select nvl(fii_time_api.ent_sd_lysqtr_END(l_p_as_of_date), l_start_date) into l_start from dual;
       END IF;
     WHEN 'FII_TIME_ENT_YEAR' THEN
       l_period_type    := 128;
       l_pk             := 'ent_year_id';
       ltd             := '_YTD';
       -- l_bis_map_rec.key:= BIS_PMV_QUERY_PVT.VIEW_BY_KEY;
       -- l_bis_map_rec.value:= 'TIME+FII_TIME_ENT_YEAR';
        elec_late_payment_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
       elec_late_payment_rec.attribute_value :='TIME+FII_TIME_ENT_YEAR';
       elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;

   END CASE;

   -- p_bis_map_tbl.extEND;
   -- p_bis_map_tbl(p_bis_map_tbl.count) := l_bis_map_rec;
   -- l_bis_map_rec.key := BIS_PMV_QUERY_PVT.QUERY_STR_KEY;
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output.EXTEND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;

   l_period_suffix:=FII_PMV_UTIL.get_period_type_suffix(l_page_period_type);

 /*-----------------------------------------------------+
 |  FII_MEASURE1     - Electronic 	    		|
 |  FII_MEASURE2     - Prior Electronic	    		|
 |  FII_MEASURE3     - Paid Late			|
 |  FII_MEASURE4     - Prior Paid Late	    		|
 |  FII_MEASURE5     - Name of the Period		|
 +------------------------------------------------------*/

IF (l_supplier_where  is null) then
/* This part will handle the case wherein Supplier= All */

IF l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
     -- l_bis_map_rec.value := '

  elec_late_payment_sql := 'SELECT   	t.name 					FII_MEASURE5,
                		    	max(inline_view.electronic)             FII_MEASURE1,
                			max(inline_view.prior_electronic)       FII_MEASURE2,
                			max(inline_view.paid_late)              FII_MEASURE3,
                			max(inline_view.prior_paid_late)        FII_MEASURE4
			    FROM
      				( SELECT
           				inner_inline_view.fii_sequence                			    FII_SEQUENCE,
           				(CASE WHEN SUM(invoice_count_entered) = 0 THEN 0
                              		      ELSE (SUM(e_invoice_count)/SUM(invoice_count_entered)*100 ) END)  electronic,
            		    		TO_NUMBER(NULL)    					            prior_electronic,
           				(CASE WHEN  SUM(paid_invoice_count) = 0   THEN 0
			      		      ELSE (SUM(paid_late_count)/SUM(paid_invoice_count)*100 ) END)   paid_late,
            		    		TO_NUMBER(NULL)   						    prior_paid_late
        			FROM
           				( SELECT
                  				t.sequence                      	FII_SEQUENCE,
                  				f.e_invoice_count               	e_invoice_count,
                  				f.invoice_count_entered			invoice_count_entered,
                    				f.paid_late_count'||ltd||'		paid_late_count,
                    				f.paid_inv_count'||ltd||'               paid_invoice_count
                	 		  FROM  FII_AP_MGT_KPI_MV f,
                	       		  '||l_page_period_type||' t
                	 		  WHERE
                                                f.time_id = t.'||l_pk||'
                	 		  AND   f.period_type_id = :FII_BIND6
                	 		  AND   t.start_date between to_date(:FII_BIND15, ''DD/MM/YYYY'') AND to_date(:FII_BIND10, ''DD/MM/YYYY'')
		 			          '||l_org_WHERE||' '||l_supplier_WHERE||'

		 		UNION ALL
                   			SELECT
                          			t.sequence             		   		FII_SEQUENCE,
                          			f.e_invoice_count      		e_invoice_count,
                          			f.invoice_count_entered     	invoice_count_entered,
                          			f.paid_late_count'||ltd||'    	paid_late_count,
                          			f.paid_inv_count'||ltd||'                 paid_invoice_count
             	   			FROM   FII_AP_MGT_KPI_MV 		f,
                         	       	       fii_time_structures           	cal,
                          	       	       '||l_page_period_type||'      	t,
                          	       	       fii_time_day                  	day
            	   			WHERE
                                             f.period_type_id        = cal.period_type_id
                     			AND   f.time_id = cal.time_id
            	     			AND  bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
	             			AND  cal.report_date  = &BIS_CURRENT_ASOF_DATE
	             			AND  cal.report_date = day.report_date
        	     			AND  day.'||l_pk||' = t.'||l_pk||'
		     			'||l_org_WHERE||' '||l_supplier_WHERE||'
                  		) inner_inline_view
            		GROUP BY inner_inline_view.FII_SEQUENCE
			) inline_view,  '||l_page_period_type||' t
 		WHERE   FII_SEQUENCE (+)= t.sequence
		AND t.start_date >=  to_date(:FII_BIND16, ''DD/MM/YYYY'')
		AND t.END_date   <= to_date(:FII_BIND12, ''DD/MM/YYYY'')
        	GROUP BY t.sequence, t.name, t.'||l_pk||'
        	ORDER BY t.sequence';

  ELSIF ((l_page_period_type = 'FII_TIME_ENT_QTR') AND (l_time_comp = 'SEQUENTIAL'))THEN

  elec_late_payment_sql := '
            SELECT  t.name FII_MEASURE5,
                	inline_view.electronic             FII_MEASURE1,
                	inline_view.prior_electronic       FII_MEASURE2,
                	inline_view.paid_late              FII_MEASURE3,
                	inline_view.prior_paid_late        FII_MEASURE4
            FROM
          	( SELECT
                 	inner_inline_view.FII_SEQUENCE   					FII_EFFECTIVE_NUM,
                    	(CASE WHEN  SUM(invoice_count_entered) = 0  THEN 0  ELSE
                        	   (SUM(e_invoice_count)/SUM(invoice_count_entered)*100 )  END) electronic,
                        to_number(null)	                                                        prior_electronic,
                    	(CASE WHEN  SUM(paid_invoice_count) = 0 THEN 0 ELSE
                        	   (SUM(paid_late_count)/SUM(paid_invoice_count)*100   )   END) paid_late,
                        to_number(null) 	                                                prior_paid_late
             FROM
                    (
                   SELECT
                        t.'||l_pk||' FII_SEQUENCE,
                         (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN
                              f.e_invoice_count   ELSE TO_NUMBER(NULL) END ) e_invoice_count,

                         (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN f.invoice_count_entered
                                ELSE TO_NUMBER(NULL) END ) invoice_count_entered,

                         (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN
                              f.paid_late_count'||ltd||'
                              ELSE TO_NUMBER(NULL) END ) paid_late_count,

                         (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN
                              f.paid_inv_count'||ltd||'
                              ELSE TO_NUMBER(NULL) END ) paid_invoice_count

                   FROM  FII_AP_MGT_KPI_MV f,
                          '||l_page_period_type||' t

                   WHERE
                         f.time_id = t.'||l_pk||'
                   AND   f.period_type_id        = :FII_BIND6
                   AND   t.start_date between to_date(:FII_BIND14, ''DD/MM/YYYY'') AND to_date(:FII_BIND7, ''DD/MM/YYYY'')
		    '||l_org_WHERE||' '||l_supplier_WHERE||'

    UNION ALL
              SELECT    :FII_BIND5 FII_SEQUENCE,
                        f.e_invoice_count  e_invoice_count,
                        f.invoice_count_entered   invoice_count_entered,
                        f.paid_late_count'||ltd||' paid_late_count,
                        f.paid_inv_count'||ltd||'  paid_invoice_count

                   FROM  FII_AP_MGT_KPI_MV f,
                          fii_time_structures  cal

                   WHERE
                         f.time_id               = cal.time_id
            	   AND   f.period_type_id        = cal.period_type_id
            	   AND   bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
            	   AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)
	     	   '||l_org_WHERE||' '||l_supplier_WHERE||'
                 ) inner_inline_view
            GROUP BY inner_inline_view.FII_SEQUENCE
    ) inline_view,  '||l_page_period_type||' t
  WHERE inline_view.fii_effective_num (+)= t.'||l_pk||'
  AND t.start_date <= &BIS_CURRENT_ASOF_DATE
  AND t.start_date >  to_date(:FII_BIND13, ''DD/MM/YYYY'')
  ORDER BY t.start_date';

 ELSE

   elec_late_payment_sql := '

       SELECT   t.name FII_MEASURE5,

                inline_view.electronic             FII_MEASURE1,
                inline_view.prior_electronic       FII_MEASURE2,
                inline_view.paid_late              FII_MEASURE3,
                inline_view.prior_paid_late        FII_MEASURE4
        FROM
          ( SELECT
                    inner_inline_view.FII_SEQUENCE   FII_EFFECTIVE_NUM,
                    (CASE WHEN  SUM(invoice_count_entered) = 0  THEN 0  ELSE
                        (SUM(e_invoice_count)/SUM(invoice_count_entered)*100 )  END)               electronic,
                    to_number(null)                                                            prior_electronic,

                    (CASE WHEN  SUM(paid_invoice_count) = 0 THEN 0 ELSE
                        (SUM(paid_late_count)/SUM(paid_invoice_count)*100   )               END)   paid_late,

                    to_number(null)                                                            prior_paid_late
              FROM
                    (   SELECT
                        t.sequence                      FII_SEQUENCE,
                        (CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
                        		to_date(:FII_BIND7,''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
                                THEN f.e_invoice_count    ELSE TO_NUMBER(NULL) END)
                                ELSE TO_NUMBER(NULL) END ) 	e_invoice_count,
                        (CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
                        		to_date(:FII_BIND7,''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
                                THEN f.invoice_count_entered  ELSE TO_NUMBER(NULL) END) ELSE TO_NUMBER(NULL) END ) invoice_count_entered,
                    	(CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
                    			to_date(:FII_BIND7, ''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
                                THEN f.paid_late_count'||ltd||' ELSE TO_NUMBER(NULL) END)
                          	ELSE TO_NUMBER(NULL) END ) 			paid_late_count,
                   	(CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
                    			to_date(:FII_BIND7,''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
                                THEN f.paid_inv_count'||ltd||'
                                ELSE TO_NUMBER(NULL) END) ELSE 	TO_NUMBER(NULL) END ) paid_invoice_count

                        FROM  FII_AP_MGT_KPI_MV f,
                              '||l_page_period_type||' t
                        WHERE
                              f.time_id = t.'||l_pk||'
                        AND   f.period_type_id = :FII_BIND6
                        AND   t.start_date between to_date(:FII_BIND13, ''DD/MM/YYYY'') AND
                                  to_date(:FII_BIND8, ''DD/MM/YYYY'')
                        '||l_org_WHERE||' '||l_supplier_WHERE||'
        UNION ALL
                SELECT
                         :FII_BIND5 FII_SEQUENCE,
                         f.e_invoice_count     e_invoice_count,
                         f.invoice_count_entered  invoice_count_entered,
                         f.paid_late_count'||ltd||' paid_late_count,
                         f.paid_inv_count'||ltd||'  paid_invoice_count

             	FROM  FII_AP_MGT_KPI_MV f,
                        fii_time_structures cal
             	WHERE
                      f.period_type_id        = cal.period_type_id
                AND   f.time_id = cal.time_id
            	AND   bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
            	AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE)
	     	     '||l_org_WHERE||' '||l_supplier_WHERE||'
          ) inner_inline_view
            GROUP BY inner_inline_view.FII_SEQUENCE
       ) inline_view,  '||l_page_period_type||' t
       WHERE inline_view.fii_effective_num (+)= t.sequence
       AND t.start_date <= &BIS_CURRENT_ASOF_DATE
       AND t.start_date >  to_date(:FII_BIND14, ''DD/MM/YYYY'')
       ORDER BY t.start_date';
END IF;

ELSE

/* This part will handle the case when Supplier has been chosen */

IF l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
     -- l_bis_map_rec.value := '

  elec_late_payment_sql := 'SELECT   	t.name 				   	FII_MEASURE5,
                		    max(inline_view.electronic)             FII_MEASURE1,
                			max(inline_view.prior_electronic)       FII_MEASURE2,
                			max(inline_view.paid_late)              FII_MEASURE3,
                			max(inline_view.prior_paid_late)        FII_MEASURE4
			    FROM
      				( SELECT
           				inner_inline_view.fii_sequence                			    FII_SEQUENCE,
           				(CASE WHEN SUM(invoice_count_entered) = 0 THEN 0
                              		      ELSE (SUM(e_invoice_count)/SUM(invoice_count_entered)*100 ) END)  electronic,
            		    		TO_NUMBER(NULL)    					            prior_electronic,
           				(CASE WHEN  SUM(paid_invoice_count) = 0   THEN 0
			      		      ELSE (SUM(paid_late_count)/SUM(paid_invoice_count)*100 ) END)   paid_late,
            		    		TO_NUMBER(NULL)   						    prior_paid_late
        			FROM
           				(
						(
						  SELECT
		                  				t.sequence                      	FII_SEQUENCE,
				  				f.e_invoice_count               	e_invoice_count,
                  						f.invoice_count_entered             invoice_count_entered,
                    						0		paid_late_count,
		                    				0       paid_invoice_count
				                        FROM	FII_AP_IVATY_XB_MV f,
                	       					'||l_page_period_type||' t
								WHERE   f.time_id = t.'||l_pk||'
								AND   f.period_type_id = :FII_BIND6
		                	 			AND   t.start_date between to_date(:FII_BIND15, ''DD/MM/YYYY'') 	AND    to_date(:FII_BIND10, ''DD/MM/YYYY'')
		 						'||l_org_where||' '||l_supplier_WHERE||'


					 	 UNION ALL

						   SELECT
				  				t.sequence         FII_SEQUENCE,
                  						0                  e_invoice_count,
                  						0                  invoice_count_entered,
		                    				f.paid_late_count'||ltd||'		paid_late_count,
				    				(f.paid_late_count'||ltd||' + f.PAID_ON_TIME_COUNT'||ltd||' ) paid_invoice_count
						         FROM    FII_AP_PAYOL_XB_MV f,
			                	       		 '||l_page_period_type||' t
                			 		  WHERE f.time_id = t.'||l_pk||'
		                	 		  AND     f.period_type_id = :FII_BIND6
		                	 		  AND     t.start_date between  to_date(:FII_BIND15, ''DD/MM/YYYY'')
                		  			  AND      to_date(:FII_BIND10, ''DD/MM/YYYY'')
					 			      '||l_org_where||' '||l_supplier_WHERE||'

					           )


				  UNION ALL

							  (
							  SELECT
                          					t.sequence             		   		FII_SEQUENCE,
                          					f.e_invoice_count      		e_invoice_count,
                          					f.invoice_count_entered     	invoice_count_entered,
                          					0    	paid_late_count,
                          					0                 paid_invoice_count
							  FROM  FII_AP_IVATY_XB_MV f,
                         	       				fii_time_structures           	cal,
                          	       				'||l_page_period_type||'      	t,
                          	       				fii_time_day                  	day
            	   					  WHERE
								f.period_type_id        = cal.period_type_id
                     						AND   f.time_id = cal.time_id
            	     						AND  bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
	             						AND  cal.report_date  = &BIS_CURRENT_ASOF_DATE
	             						AND  cal.report_date = day.report_date
        	     						AND  day.'||l_pk||' = t.'||l_pk||'
		     						'||l_org_where||' '||l_supplier_WHERE||'

							UNION ALL


							SELECT
                          					t.sequence             		   		FII_SEQUENCE,
                          					0     		e_invoice_count,
                          					0     	invoice_count_entered,
                          					f.paid_late_count'||ltd||'    	paid_late_count,
                          					(f.paid_late_count'||ltd||' + f.PAID_ON_TIME_COUNT'||ltd||' ) paid_invoice_count
							FROM  FII_AP_PAYOL_XB_MV f,
                         	       			      fii_time_structures           	cal,
                          	       			      '||l_page_period_type||'      	t,
                          	       			      fii_time_day                  	day
            	   					WHERE f.period_type_id        = cal.period_type_id
                     					AND   f.time_id = cal.time_id
            	     					AND  bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
	             					AND  cal.report_date  = &BIS_CURRENT_ASOF_DATE
	             					AND  cal.report_date = day.report_date
        	     					AND  day.'||l_pk||' = t.'||l_pk||'
		     					'||l_org_where||' '||l_supplier_WHERE||'
							)
                  		) inner_inline_view


            		GROUP BY inner_inline_view.FII_SEQUENCE
			) inline_view,  '||l_page_period_type||' t
 		WHERE   FII_SEQUENCE (+)= t.sequence
		AND t.start_date >=  to_date(:FII_BIND16, ''DD/MM/YYYY'')
		AND t.END_date   <= to_date(:FII_BIND12, ''DD/MM/YYYY'')
        	GROUP BY t.sequence, t.name, t.'||l_pk||'
        	ORDER BY t.sequence';


   ELSIF ((l_page_period_type = 'FII_TIME_ENT_QTR') AND (l_time_comp = 'SEQUENTIAL')) THEN

  elec_late_payment_sql := '
            SELECT   	t.name FII_MEASURE5,
                	inline_view.electronic             FII_MEASURE1,
                	inline_view.prior_electronic       FII_MEASURE2,
                	inline_view.paid_late              FII_MEASURE3,
                	inline_view.prior_paid_late        FII_MEASURE4
            FROM
          	( SELECT
                 	inner_inline_view.FII_SEQUENCE   						  FII_EFFECTIVE_NUM,
                    	(CASE WHEN  SUM(invoice_count_entered) = 0  THEN 0  ELSE
                        	   (SUM(e_invoice_count)/SUM(invoice_count_entered)*100 )  END)     	  electronic,
                        to_number(null)	                                                         prior_electronic,
                    	(CASE WHEN  SUM(paid_invoice_count) = 0 THEN 0 ELSE
                        	   (SUM(paid_late_count)/SUM(paid_invoice_count)*100   )     END)   paid_late,
                        to_number(null) 	                                                             prior_paid_late
             FROM
                    (
                            (

                    SELECT
                        t.'||l_pk||' FII_SEQUENCE,
                        (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN f.e_invoice_count
                              ELSE TO_NUMBER(NULL) END ) e_invoice_count,
                        (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN f.invoice_count_entered
                              ELSE TO_NUMBER(NULL) END ) invoice_count_entered,
                        0 paid_late_count,
                        0 paid_invoice_count
                   FROM  FII_AP_IVATY_XB_MV        f,
                          '||l_page_period_type||' t
                   WHERE
                         f.time_id = t.'||l_pk||'
                   AND   f.period_type_id        = :FII_BIND6
                   AND   t.start_date between to_date(:FII_BIND14, ''DD/MM/YYYY'') AND to_date(:FII_BIND7, ''DD/MM/YYYY'')
		    '||l_org_WHERE||' '||l_supplier_WHERE||'
            union all
                    SELECT
                        t.'||l_pk||' FII_SEQUENCE,
                        0  e_invoice_count,
                        0 invoice_count_entered,
                        (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN f.paid_late_count'||ltd||'
                              ELSE TO_NUMBER(NULL) END ) paid_late_count,

                        (CASE WHEN  t.'||l_pk||' <> :FII_BIND5 THEN (f.paid_late_count'||ltd||' + f.PAID_ON_TIME_COUNT'||ltd||')
                              ELSE TO_NUMBER(NULL) END )        paid_invoice_count

                   FROM  FII_AP_PAYOL_XB_MV        f,
                          '||l_page_period_type||' t
                   WHERE
                         f.time_id = t.'||l_pk||'
                   AND   f.period_type_id        = :FII_BIND6
                   AND   t.start_date between to_date(:FII_BIND14, ''DD/MM/YYYY'') AND to_date(:FII_BIND7, ''DD/MM/YYYY'')
		    '||l_org_WHERE||' '||l_supplier_WHERE||'
 UNION ALL

			            SELECT  :FII_BIND5 FII_SEQUENCE,
		                        f.e_invoice_count   e_invoice_count,
					f.invoice_count_entered invoice_count_entered,
                                        0 paid_late_count,
                                        0 paid_invoice_count
		                   FROM  FII_AP_IVATY_XB_MV f,
					     fii_time_structures  cal
                   WHERE f.time_id               = cal.time_id
            	   AND   f.period_type_id        = cal.period_type_id
            	   AND   bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
            	   AND   cal.report_date = (&BIS_CURRENT_ASOF_DATE)
	     	   '||l_org_WHERE||' '||l_supplier_WHERE||'
	       union all
	            SELECT  :FII_BIND5 FII_SEQUENCE,
                        0 e_invoice_count,
                        0  invoice_count_entered,
			f.paid_late_count'||ltd||'   paid_late_count,
                   (f.paid_late_count'||ltd||' + f.PAID_ON_TIME_COUNT'||ltd||' ) paid_invoice_count
                   FROM  FII_AP_PAYOL_XB_MV f,
                          fii_time_structures  cal
                   WHERE f.time_id               = cal.time_id
            	   AND   f.period_type_id        = cal.period_type_id
            	   AND   bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
            	   AND   cal.report_date = (&BIS_CURRENT_ASOF_DATE)
	     	   '||l_org_WHERE||' '||l_supplier_WHERE||'
           )
           ) inner_inline_view
            GROUP BY inner_inline_view.FII_SEQUENCE
    ) inline_view,  '||l_page_period_type||' t
  WHERE inline_view.fii_effective_num (+)= t.'||l_pk||'
  AND t.start_date <= &BIS_CURRENT_ASOF_DATE
  AND t.start_date >  to_date(:FII_BIND13, ''DD/MM/YYYY'')
  ORDER BY t.start_date';

 ELSE

   elec_late_payment_sql := '

       SELECT   t.name FII_MEASURE5,
                inline_view.electronic             FII_MEASURE1,
                inline_view.prior_electronic       FII_MEASURE2,
                inline_view.paid_late              FII_MEASURE3,
                inline_view.prior_paid_late        FII_MEASURE4
        FROM
          (
            SELECT
                    inner_inline_view.FII_SEQUENCE   FII_EFFECTIVE_NUM,
                    (CASE WHEN  SUM(invoice_count_entered) = 0  THEN 0  ELSE
                        (SUM(e_invoice_count)/SUM(invoice_count_entered)*100 )  END)            electronic,
                     to_number(null)                                                            prior_electronic,

                    (CASE WHEN  SUM(paid_invoice_count) = 0 THEN 0 ELSE
                        (SUM(paid_late_count)/SUM(paid_invoice_count)*100   )   END)            paid_late,

                    to_number(null)                                                            prior_paid_late
              FROM
                    (
				         (

				    SELECT
				        t.sequence                      FII_SEQUENCE,
		                        (CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
			        		to_date(:FII_BIND7,''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
						        THEN f.e_invoice_count    ELSE TO_NUMBER(NULL) END)
				                                ELSE TO_NUMBER(NULL) END ) 	e_invoice_count,
		                        (CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
			        		to_date(:FII_BIND7,''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
						        THEN f.invoice_count_entered  ELSE TO_NUMBER(NULL) END)
								ELSE TO_NUMBER(NULL) END ) invoice_count_entered,
		                    	0								     paid_late_count,
		                    	0								     paid_invoice_count
	                            FROM     FII_AP_IVATY_XB_MV f,
					         '||l_page_period_type||' t
				    WHERE   f.time_id = t.'||l_pk||'
	                            AND	 f.period_type_id = :FII_BIND6
			            AND       t.start_date between to_date(:FII_BIND13, ''DD/MM/YYYY'')
				    AND       to_date(:FII_BIND8, ''DD/MM/YYYY'')
			                         '||l_org_WHERE||' '||l_supplier_WHERE||'


			UNION ALL


				    SELECT
				        t.sequence			        FII_SEQUENCE,
		                        0 					e_invoice_count,
		                        0					invoice_count_entered,
		                    	(CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
			    			to_date(:FII_BIND7, ''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
						        THEN f.paid_late_count'||ltd||' ELSE TO_NUMBER(NULL) END)
				                          	ELSE TO_NUMBER(NULL) END ) 			paid_late_count,

                                (CASE WHEN  t.sequence <> :FII_BIND5 THEN (CASE WHEN  t.start_date between
			    			to_date(:FII_BIND7, ''DD/MM/YYYY'') AND to_date(:FII_BIND8, ''DD/MM/YYYY'')
						        THEN (f.paid_late_count'||ltd||' + f.PAID_ON_TIME_COUNT'||ltd||' ) ELSE TO_NUMBER(NULL) END)
				                          	ELSE TO_NUMBER(NULL) END ) 			paid_invoice_count

	                            FROM      FII_AP_PAYOL_XB_MV  f,
				                  '||l_page_period_type||' t
	                            WHERE    f.time_id = t.'||l_pk||'
			            AND        f.period_type_id = :FII_BIND6
				    AND        t.start_date between to_date(:FII_BIND13, ''DD/MM/YYYY'')
				    AND        to_date(:FII_BIND8, ''DD/MM/YYYY'')
				                   '||l_org_WHERE||' '||l_supplier_WHERE||'
		                      )

        UNION ALL
				    (
	      		    SELECT
		                         :FII_BIND5 FII_SEQUENCE,
		                          f.e_invoice_count     e_invoice_count,
		                         f.invoice_count_entered 	invoice_count_entered,
		                           0			 paid_late_count,
					   0			 paid_invoice_count
		              	    FROM  FII_AP_IVATY_XB_MV  f,
			                  fii_time_structures cal
			            WHERE     f.period_type_id        = cal.period_type_id
		                    AND        f.time_id                   = cal.time_id
			            AND        bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
		              	    AND        cal.report_date = (&BIS_CURRENT_ASOF_DATE)
				    '||l_org_WHERE||' '||l_supplier_WHERE||'

		     UNION ALL

				    SELECT
		                    :FII_BIND5 FII_SEQUENCE,
				    0  e_invoice_count,
		                    0  invoice_count_entered,
				    f.paid_late_count'||ltd||'   paid_late_count,
		                    (f.paid_late_count'||ltd||' + f.PAID_ON_TIME_COUNT'||ltd||' ) paid_invoice_count
             			    FROM    FII_AP_PAYOL_XB_MV  f,
			                    fii_time_structures cal
		               	    WHERE  f.period_type_id        = cal.period_type_id
			            AND      f.time_id = cal.time_id
			            AND      bitand(cal.record_type_id,:FII_BIND1)= :FII_BIND1
			            AND      cal.report_date = (&BIS_CURRENT_ASOF_DATE)
				     	     '||l_org_WHERE||' '||l_supplier_WHERE||'
			               )
	            ) inner_inline_view
            GROUP BY inner_inline_view.FII_SEQUENCE
       ) inline_view,  '||l_page_period_type||' t
       WHERE inline_view.fii_effective_num (+)= t.sequence
       AND t.start_date <= &BIS_CURRENT_ASOF_DATE
       AND t.start_date >  to_date(:FII_BIND14, ''DD/MM/YYYY'')
       ORDER BY t.start_date';

  END IF;
 end if;


    elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND1';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_actual_period_type);
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND5';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_curr_effective_num);
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND6';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_period_type);
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND7';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_p_as_of_date,'DD/MM/YYYY');
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND8';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_cy_period_END,'DD/MM/YYYY');
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND10';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_ent_pyr_END,'DD/MM/YYYY');
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND12';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_ent_cyr_END,'DD/MM/YYYY');
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND13';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_start,'DD/MM/YYYY');
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND14';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_begin_date,'DD/MM/YYYY');
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND15';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_ent_year_st1,'DD/MM/YYYY');
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':FII_BIND16';
   elec_late_payment_rec.attribute_value := TO_CHAR(l_ent_year_st2,'DD/MM/YYYY');
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':GID';
   elec_late_payment_rec.attribute_value := to_char(l_gid);
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;
   elec_late_payment_rec.attribute_name := ':SEC_ID';
   elec_late_payment_rec.attribute_value := fii_pmv_util.get_sec_profile;
   elec_late_payment_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   elec_late_payment_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
   elec_late_payment_output(elec_late_payment_output.COUNT) := elec_late_payment_rec;
   elec_late_payment_output.EXTEND;

END get_elec_late_payment;


/* For KPIs  */


 PROCEDURE GET_KPI
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       kpi_sql out NOCOPY VARCHAR2,
       kpi_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)IS
       /* declaration section */
       sqlstmt          VARCHAR2(14000);

        l_viewby_dim            VARCHAR2(240);  -- what is the viewby
        l_as_of_date            DATE;
        l_organization          VARCHAR2(240);
        l_supplier              VARCHAR2(240);
        l_currency              VARCHAR2(240);  -- random size, possibly high
        l_viewby_id             VARCHAR2(240);  -- org_id or supplier_id
        l_record_type_id        NUMBER;         --
        l_gid                   NUMBER;         -- 0,4 or 8
        l_viewby_string         VARCHAR2(240);
        l_org_where             VARCHAR2(240);
        l_sup_where             VARCHAR2(240);
        l_curr_suffix           VARCHAR2(240);
        l_period_type           VARCHAR2(240);
        l_invoice_number        VARCHAR2(240);

       l_paid_inv_count VARCHAR2(240);
       l_paid_on_time_count VARCHAR2(240);
       l_paid_late_count VARCHAR2(240);
       l_per_type       VARCHAR2(240);
       l_payment_count VARCHAR2(50);

 BEGIN
-- Read the parameters passed
  FII_PMV_UTIL.get_parameters(
        p_page_parameter_tbl=>p_page_parameter_tbl,
        p_as_of_date=>l_as_of_date,
        p_operating_unit=>l_organization,
        p_supplier=>l_supplier,
        p_invoice_number=>l_invoice_number,
        p_period_type=>l_period_type,
        p_record_type_id=>l_record_type_id,
        p_view_by=>l_viewby_dim,
        p_currency=>l_curr_suffix,
        p_column_name=>l_viewby_id,
        p_table_name=>l_viewby_string,
        p_gid=>l_gid,
        p_org_where=>l_org_where,
        p_supplier_where=>l_sup_where);

       l_per_type := FII_PMV_Util.get_period_type_suffix(l_period_type);
       l_paid_inv_count :=
   'paid_inv_count'||l_per_type;

       l_paid_on_time_count :=
   'paid_on_time_count'||l_per_type;

       l_paid_late_count :=
   'paid_late_count'||l_per_type;

     /* added by vkazhipu for bug 4424398 */

       l_payment_count :=  'payment_count'||l_per_type;


       /* Main SQL section */

 sqlstmt := '
        SELECT viewby_dim.value                                 VIEWBY,
               viewby_dim.id                                    VIEWBYID,
               f.invoice_count_entered_cur                      FII_MEASURE1,
               f.invoice_count_entered_pre                      FII_MEASURE2,
               decode(f.invoice_count_entered_cur,0,0,
                (f.e_invoice_count_cur * 100 /f.invoice_count_entered_cur))
                                                                 FII_MEASURE3,
               decode(f.invoice_count_entered_pre,0,0,
                (f.e_invoice_count_pre * 100 /f.invoice_count_entered_pre))
                                                                 FII_MEASURE4,
               f.paid_inv_count_cur                             FII_MEASURE5,
               f.paid_inv_count_pre                             FII_MEASURE6,
               decode(f.paid_inv_count_cur,0,0,
                  (f.paid_late_count_cur *100/f.paid_inv_count_cur))
                                                                FII_MEASURE7,
               decode(f.paid_inv_count_pre,0,0,
                  (f.paid_late_count_pre *100/f.paid_inv_count_pre))
                                                                FII_MEASURE8,
               decode(f.paid_amt_cur,0,0,
                  (f.invoice_to_payment_days_cur / f.paid_amt_cur))
                                                                FII_MEASURE9,
               decode(f.paid_amt_pre,0,0,
                  (f.invoice_to_payment_days_pre / f.paid_amt_pre))
                                                               FII_MEASURE10,
               f.payment_count_cur                         FII_MEASURE11,
                f.payment_count_pre                        FII_MEASURE12,
               decode(f.paid_invoice_amt_cur,0,0,
                (f.paid_dis_offered_cur * 100 /f.paid_invoice_amt_cur))
                                                                 FII_MEASURE13,
               decode(f.paid_invoice_amt_pre,0,0,
                (f.paid_dis_offered_pre * 100 /f.paid_invoice_amt_pre))
                                                                 FII_MEASURE14,
               decode(f.total_paid_amt_cur,0,0,
                (f.paid_dis_taken_cur * 100 /f.total_paid_amt_cur))
                                                                 FII_MEASURE15,
               decode(f.total_paid_amt_pre,0,0,
                (f.paid_dis_taken_pre * 100 /f.total_paid_amt_pre))
                                                                 FII_MEASURE16,
               decode(sum(f.e_invoice_count_cur) over(),0,0,
                     sum(f.e_invoice_count_cur) over() *100 /
                       sum(f.invoice_count_entered_cur) over())
                                                                 FII_ATTRIBUTE1,
               decode(sum(f.e_invoice_count_pre) over(),0,0,
                     sum(f.e_invoice_count_pre) over() *100 /
                       sum(f.invoice_count_entered_pre) over())
                                                                 FII_ATTRIBUTE2,
               decode(sum(f.paid_inv_count_cur) over(),0,0,
                     sum(f.paid_late_count_cur) over() *100 /
                       sum(f.paid_inv_count_cur) over())
                                                                 FII_ATTRIBUTE3,
               decode(sum(f.paid_inv_count_pre) over(),0,0,
                     sum(f.paid_late_count_pre) over() *100 /
                       sum(f.paid_inv_count_pre) over())
                                                                 FII_ATTRIBUTE4,
               decode(sum(f.paid_invoice_amt_cur) over(),0,0,
                     sum(f.paid_dis_offered_cur) over() *100 /
                       sum(f.paid_invoice_amt_cur) over())
                                                                 FII_ATTRIBUTE5,
               decode(sum(f.paid_invoice_amt_pre) over(),0,0,
                     sum(f.paid_dis_offered_pre) over() *100 /
                       sum(f.paid_invoice_amt_pre) over())
                                                                 FII_ATTRIBUTE6,
               decode(sum(f.total_paid_amt_cur) over(),0,0,
                     sum(f.paid_dis_taken_cur) over() *100 /
                       sum(f.total_paid_amt_cur) over())
                                                                 FII_ATTRIBUTE7,
               decode(sum(f.total_paid_amt_pre) over(),0,0,
                     sum(f.paid_dis_taken_pre) over() *100 /
                       sum(f.total_paid_amt_pre) over())
                                                                 FII_ATTRIBUTE8,
               decode(sum(f.paid_amt_cur) over(),0,0,
                     sum(f.invoice_to_payment_days_cur) over() /
                       sum(f.paid_amt_cur) over())
                                                              FII_ATTRIBUTE10,
               decode(sum(f.paid_amt_pre) over(),0,0,
                     sum(f.invoice_to_payment_days_pre) over() /
                       sum(f.paid_amt_pre) over())
                                                               FII_ATTRIBUTE11,
               sum(f.invoice_count_entered_cur) over()                     FII_ATTRIBUTE12,
               sum(f.invoice_count_entered_pre) over()                     FII_ATTRIBUTE13,
               sum(f.paid_inv_count_cur) over()               FII_ATTRIBUTE14,
               sum(f.paid_inv_count_pre) over()               FII_ATTRIBUTE15,
               sum(f.payment_count_cur) over()               FII_ATTRIBUTE16,
               sum(f.payment_count_pre) over()                FII_ATTRIBUTE17


        FROM
              (SELECT
               f.'||l_viewby_id||'                              ID,
               sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE
                  then f.invoice_count_entered else to_number(null) end)      invoice_count_entered_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.invoice_count_entered else to_number(null)  end)      invoice_count_entered_pre,
               sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE
                  then f.e_invoice_count else to_number(null) end)            e_invoice_count_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.e_invoice_count else to_number(null) end)            e_invoice_count_pre,
               sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE
                  then f.'||l_paid_inv_count||' else to_number(null) end)     paid_inv_count_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.'||l_paid_inv_count||' else to_number(null) end)     paid_inv_count_pre,
               sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE
                  then f.'||l_paid_on_time_count||' else to_number(null) end) paid_on_time_count_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.'||l_paid_on_time_count||' else to_number(null) end) paid_on_time_count_pre,
               sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE
                  then f.'||l_paid_late_count||' else to_number(null) end)    paid_late_count_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.'||l_paid_late_count||' else to_number(null) end)    paid_late_count_pre,
               sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE
                then f.invoice_to_payment_days else to_number(null) end)
                                                   invoice_to_payment_days_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.invoice_to_payment_days  else to_number(null) end)
                                                   invoice_to_payment_days_pre,
               sum(case when cal.report_date =&BIS_CURRENT_ASOF_DATE
                then f.paid_amt_b else to_number(null) end)
                                                   paid_amt_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.paid_amt_b else to_number(null) end)
                                                   paid_amt_pre,
               sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                  then f.paid_invoice_amt'||l_per_type||l_curr_suffix||' else to_number(null) end)                                                                paid_invoice_amt_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.paid_invoice_amt'||l_per_type||l_curr_suffix||' else to_number(null) end)                                                                paid_invoice_amt_pre,
               sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                  then f.paid_dis_offered'||l_per_type||l_curr_suffix||' else to_number(null) end)                                                                paid_dis_offered_cur,
               sum(case when cal.report_date =&BIS_PREVIOUS_ASOF_DATE
                  then f.paid_dis_offered'||l_per_type||l_curr_suffix||' else to_number(null) end)                                                                paid_dis_offered_pre,
               sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                  then f.'||l_payment_count||' else to_number(null) end)               payment_count_cur,
               sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                  then f.'||l_payment_count||'  else to_number(null) end)               payment_count_pre,
               sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                  then (f.paid_amt'||l_curr_suffix||'+ f.paid_dis_taken'||l_curr_suffix||')  else to_number(null) end)    total_paid_amt_cur,
               sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                  then (f.paid_amt'||l_curr_suffix||'+ f.paid_dis_taken'||l_curr_suffix||')  else to_number(null) end)    total_paid_amt_pre,
               sum(case when cal.report_date = &BIS_CURRENT_ASOF_DATE
                  then f.paid_dis_taken'||l_curr_suffix||' else to_number(null) end)  paid_dis_taken_cur,
               sum(case when cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                  then f.paid_dis_taken'||l_curr_suffix||' else to_number(null) end)  paid_dis_taken_pre
        FROM FII_AP_MGT_KPI_MV f, fii_time_structures cal
        WHERE f.time_id = cal.time_id
        AND   f.period_type_id = cal.period_type_id
            '||l_sup_where||'  '||l_org_where||'
        AND   bitand(cal.record_type_id, :RECORD_TYPE_ID) = :RECORD_TYPE_ID
        AND   cal.report_date in (&BIS_CURRENT_ASOF_DATE,  &BIS_PREVIOUS_ASOF_DATE)
        GROUP BY  f.'||l_viewby_id||')  f,
         ('||l_viewby_string||') viewby_dim
        WHERE   f.id = viewby_dim.id';


      /* Binding Section */
       FII_PMV_Util.bind_variable(
       p_sqlstmt=>sqlstmt,
       p_page_parameter_tbl=>p_page_parameter_tbl,
       p_sql_output=>kpi_sql,
       p_bind_output_table=>kpi_output,
       p_record_type_id=>l_record_type_id,
       p_gid=>l_gid
       );

 END  GET_KPI;


END FII_AP_PAY_MGT;


/
