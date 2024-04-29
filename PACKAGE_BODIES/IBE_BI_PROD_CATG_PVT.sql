--------------------------------------------------------
--  DDL for Package Body IBE_BI_PROD_CATG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_BI_PROD_CATG_PVT" AS
/* $Header: IBEVBICATEGB.pls 120.18 2006/07/26 13:37:12 gjothiku ship $ */

/***************************************************************/
/* Internal Function to Check if a given Node is a Leaf Node   */
/* or not.                                                     */
/***************************************************************/

FUNCTION GETLEAFNODE(l_Category_ID IN VARCHAR2)
         RETURN BOOLEAN
IS L_LEAF_node VARCHAR2(1);
BEGIN

  SELECT DISTINCT LEAF_NODE_FLAG INTO L_LEAF_NODE
  FROM eni_item_prod_cat_lookup_v --4776922
  WHERE ID = replace(l_Category_ID,'''','')
  AND ID = PARENT_ID;

  IF(l_leaf_node = 'Y') THEN
      return TRUE;
  ELSE
      return FALSE;
  END IF;

EXCEPTION
WHEN OTHERS THEN
 return FALSE;
END;

/***************************************************************/
/* This procedure will return the SQL Query for Activity By    */
/* Category Portlet                                            */
/***************************************************************/

PROCEDURE GET_ACTY_BY_CATG_PORT_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           ) IS

  l_custom_sql          VARCHAR2(15000) ; --Final Sql.
  l_parameter_name      VARCHAR2(3200);
  l_from                VARCHAR2(3200) ;
  l_where               VARCHAR2(3200) ;
  l_where2              VARCHAR2(3200) ;
  l_select		VARCHAR2(5000) ;
  l_select1		VARCHAR2(5000) ;
  l_groupby		VARCHAR2(5000) ;
  l_asof_dt		DATE;
  l_prev_dt		DATE;
  l_adate		DATE;
  l_pdate		DATE;
  l_rec_type		NUMBER;
  l_period_type		VARCHAR2(3200);
  l_comparison_type	VARCHAR2(3200);
  l_currency_code	VARCHAR2(3200);
  l_minisite		VARCHAR2(3200);
  l_category_id		VARCHAR2(3200);
  l_category_no		VARCHAR2(3200);
  l_item_id		VARCHAR2(3200);
  l_minisite_id		VARCHAR2(3200);
  l_sysdate		 DATE;
  l_catg_no		NUMBER := 0;
  l_hierarchy_sql	VARCHAR2(3200);
  l_top_node		VARCHAR2(3200);
  l_tableList		VARCHAR2(1000);
  l_msiteFilter		VARCHAR2(1000);
  l_OrdBy		VARCHAR2(2000);
  l_var			VARCHAR2(2000);
  l_view_by VARCHAR2(3200);
  l_custom_rec		BIS_QUERY_ATTRIBUTES :=
			BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  dbg_msg		VARCHAR2(3200);

  l_gl_p		VARCHAR2(15) := '''FII_GLOBAL1''';
  l_gl_s		VARCHAR2(15) := '''FII_GLOBAL2''';
  l_url_str_prod        VARCHAR2(5000);
  l_url_str_prodcatg    VARCHAR2(5000);
  l_url			VARCHAR2(5000);

BEGIN

 /* ********************************************************************** *
     Portlet query for Activity by Product Category is started ....
  * ********************************************************************** */


-- initialization process

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'ibe.plsql.dbi.ibe_bi_prod_catg_pvt.get_acty_by_catg_port_sql.begin','BEGIN');
 END IF;


/* ******************************************************************* *
 *  Get PMV parameters...
 * ******************************************************************* */


  FOR i IN p_pmv_parameters.FIRST..p_pmv_parameters.LAST
  LOOP
    l_parameter_name := p_pmv_parameters(i).parameter_name ;

    IF( l_parameter_name = 'AS_OF_DATE')
    THEN
      l_asof_dt := TO_DATE(p_pmv_parameters(i).parameter_value,'DD/MM/YYYY');
      l_adate   := l_asof_dt;
    ELSIF( l_parameter_name = 'IBW_WEB_ANALYTICS_GROUP1+FII_CURRENCIES')
    THEN
      l_currency_code :=  p_pmv_parameters(i).parameter_id;
    ELSIF( l_parameter_name = 'PERIOD_TYPE')
    THEN
      l_period_type := p_pmv_parameters(i).parameter_value;
    ELSIF( l_parameter_name = 'TIME_COMPARISON_TYPE')
    THEN
      l_comparison_type := p_pmv_parameters(i).parameter_value;
    ELSIF( l_parameter_name = 'SITE+SITE')
    THEN
       l_minisite := p_pmv_parameters(i).parameter_value;
       l_minisite_id := p_pmv_parameters(i).parameter_id;
    ELSIF( l_parameter_name = 'ITEM+ENI_ITEM_VBH_CAT')
    THEN
      l_category_no := replace(p_pmv_parameters(i).parameter_id,'''','');
      l_category_id := p_pmv_parameters(i).parameter_value;
      --Dimension Group included by narao For Bug#:4654974(Issue#4)
    ELSIF( l_parameter_name = 'IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM')
    THEN
      l_item_id := p_pmv_parameters(i).parameter_value;
    ELSIF (l_parameter_name = 'VIEW_BY' )
    THEN
         l_view_by := p_pmv_parameters(i).parameter_value;
    ELSIF ( l_parameter_name = 'ORDERBY')
    THEN
      l_OrdBy := p_pmv_parameters(i).parameter_value;
    END IF;

  END LOOP;

/* ====================================================================== */
/*      Query revamped for bug 5373132 - Start                            */
/* ====================================================================== */

 l_url_str_prod     :='pFunctionName=IBE_BI_ACTY_PROD_STOR_PHP&pParamIds=Y&VIEW_BY=IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM&VIEW_BY_NAME=VIEW_BY_ID';
 l_url_str_prodcatg :='pFunctionName=IBE_BI_ACTY_PROD_STOR_PHP&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID';



 IF l_view_by ='ITEM+ENI_ITEM_VBH_CAT' THEN --View by is Prodcut Category

    l_url     := '   decode(leaf_node_flag,''Y'','||''''||l_url_str_prod||''''||','||''''||l_url_str_prodcatg||''''||' )  IBE_ATTR2 ';
    if (upper(nvl(l_category_id,'ALL')) ='ALL') then
       l_select1:= ' eip.value value,  eip. parent_id  catid,eip.value description ,eip.LEAF_NODE_FLAG ';
       l_groupby:=  ' eip.value ,  eip. parent_id  ,eip.value ,eip.LEAF_NODE_FLAG ';

    elsif (upper(l_category_id) <> 'ALL')  then
       l_select1:= ' eip.value value,  edh.imm_child_id  catid,eip.value description ,eip.LEAF_NODE_FLAG ';
       l_groupby:=  ' eip.value ,  edh.imm_child_id  ,eip.value ,eip.LEAF_NODE_FLAG ';

    end if;

 ELSIF l_view_by = 'IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM' THEN --View by is Product
   l_url := '  null IBE_ATTR2 ';
   l_select1:= ' item.value value,  item.id  catid,item.description  description ';
   l_groupby:=  ' item.value , item.id   ,item.description  ';

 end if;



  --The Select statement is recorded in this variable.

  l_select  := '   VALUE VIEWBY, CATID VIEWBYID, VALUE IBE_ATTR3 , '||
		     '   CATID IBE_ATTR1,  '||
		     '   description IBE_ATTR4, ' ||
		     '   decode(NO_CARTS,0,NULL,CON_ORD/NO_CARTS)*100 IBE_VAL1, '||
		     '   CART_AMT IBE_VAL2, '||
		     '   C_ORD_AMT IBE_VAL3, '||
		     '   P_ORD_AMT IBE_VAL8, '||
                     '   decode(C_ORD_AMT,0,NULL,A_ORD_AMT/C_ORD_AMT)*100 IBE_VAL5, '||
		     '   decode(NO_ORD,0,NULL, C_ORD_AMT/NO_ORD) IBE_VAL6, '||
		     '   decode(LIST_AMT,0,NULL,DISC_AMT/LIST_AMT)*100 IBE_VAL7, '||
		     '   decode(sum(NO_CARTS) over(),0,NULL,sum(CON_ORD) over()/sum(NO_CARTS) over())*100 IBE_TOT_VAL1, '||
		     '   sum(CART_AMT) over() IBE_TOT_VAL2, '||
		     '   sum(C_ORD_AMT) over() IBE_TOT_VAL3, '||
                     '   decode(sum(P_ORD_AMT) over(),0,NULL,(sum(C_ORD_AMT) over()- sum(P_ORD_AMT) over())/sum(P_ORD_AMT) over())*100 IBE_TOT_VAL4, '||
                     '   decode(sum(C_ORD_AMT) over(),0,NULL,sum(A_ORD_AMT) over()/sum(C_ORD_AMT) over())*100 IBE_TOT_VAL5, '||
                     '   decode(sum(NO_ORD) over(),0,NULL,sum(C_ORD_AMT) over()/sum(NO_ORD) over()) IBE_TOT_VAL6, '||
                     '   decode(sum(LIST_AMT) over(),0,NULL,sum(DISC_AMT) over()/sum(LIST_AMT) over())*100 IBE_TOT_VAL7, ' ||l_url ||
		     ' FROM ('||
		     ' SELECT  '||l_select1|| ' , '||
		     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,tot_cart_count,0)) NO_CARTS, '||
		     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,CON_ORD,0)) CON_ORD, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,tot_ord_count,0)) NO_ORD, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE, '||
	             ' decode(:l_ccy,:l_gl_p,carts_amt_g,:l_gl_s,carts_amt_g1,currency_cd_f,carts_amt_F),0)) CART_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE, '||
	             ' decode(:l_ccy,:l_gl_p,booked_amount_g,:l_gl_s,booked_amount_g1,currency_cd_f,booked_amount_f),0)) C_ORD_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_PREVIOUS_ASOF_DATE, '||
	             ' decode(:l_ccy,:l_gl_p,booked_amount_g,:l_gl_s,booked_amount_g1,currency_cd_f,booked_amount_F),0)) P_ORD_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE, '||
	             ' decode(resource_flag,''Y'',decode(:l_ccy,:l_gl_p,booked_amount_g,:l_gl_s,booked_amount_g1,currency_cd_f,booked_amount_f),0),0)) A_ORD_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE, '||
	             ' decode(:l_ccy,:l_gl_p,discount_amount_g,:l_gl_s,discount_amount_g1,currency_cd_f,discount_amount_F),0)) DISC_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE, '||
	             ' decode(:l_ccy,:l_gl_p, booked_list_amt_g,:l_gl_s, booked_list_amt_g1,currency_cd_f, booked_list_amt_F),0)) LIST_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,tot_cart_count, 0)) T_NO_CARTS, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,con_ord, 0)) T_CON_ORD, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,tot_ord_count, 0)) T_NO_ORD, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,decode(:l_ccy,:l_gl_p,carts_amt_g,:l_gl_s,carts_amt_g1,currency_cd_f,carts_amt_f),0)) T_CART_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,decode(:l_ccy,:l_gl_p,booked_amount_g,:l_gl_s,booked_amount_g1,currency_cd_f,booked_amount_f),0)) T_C_ORD_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_PREVIOUS_ASOF_DATE,decode(:l_ccy,:l_gl_p,booked_amount_g,:l_gl_s,booked_amount_g1,currency_cd_f,booked_amount_F),0)) T_P_ORD_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,decode( resource_flag,''Y'','||
	             ' decode(:l_ccy,:l_gl_p,booked_amount_g,:l_gl_s,booked_amount_g1,currency_cd_f,booked_amount_f),0),0)) T_A_ORD_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,decode(:l_ccy,:l_gl_p,discount_amount_g,:l_gl_s,discount_amount_g1,currency_cd_f,discount_amount_F),0)) T_DISC_AMT, '||
                     ' SUM(decode(REPORT_DATE,&BIS_CURRENT_ASOF_DATE,decode(:l_ccy,:l_gl_p,booked_list_amt_g,:l_gl_s,booked_list_amt_g1,currency_cd_f,booked_list_amt_F),0)) T_LIST_AMT  ';






  --The From Clause is recorded in this variable

    l_from          := ' ibe_bi_top_prod_mv prod_mv, ' ||
                      ' ibw_bi_msite_dimn_v  site, ' ||
                      ' fii_time_rpt_struct_v cal, ';

  --The Where Clause is recorded in this variable.
  --&BIS_CURRENT_ASOF_DATE gives the AS OF DATE selected in the report.

    l_where        := ' cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) ' ||
                     ' and cal.period_type_id = prod_mv.period_type_id ' ||
                     ' and bitand(cal.record_type_id,&BIS_NESTED_PATTERN)= cal.record_type_id '||
                     ' and prod_mv.time_id = cal.time_id ' ||
                     ' and cal.calendar_id = -1 '  ||  --Indicates Enterprise Calendar
		     ' and prod_mv.minisite_id = site.id ';





     l_where2          := ' NO_CARTS <> 0  '||
		        'or CART_AMT  <> 0 '||
			'or C_ORD_AMT <> 0 '||
			'or P_ORD_AMT <> 0 '||
			'or LIST_AMT  <> 0 ';


  IF l_view_by ='ITEM+ENI_ITEM_VBH_CAT' THEN --View by is Prodcut Category

    l_from    := l_from ||' eni_denorm_hierarchies edh,'||
		       ' mtl_default_category_sets mdc,'||
		       ' eni_item_prod_cat_lookup_v eip';

    l_where   := l_where ||' AND prod_mv.category_id = edh.child_id '||
		     ' AND edh.object_type = ''CATEGORY_SET'' '||
		     ' AND edh.object_id = mdc.category_set_id '||
		     ' AND mdc.functional_area_id = 11 '||
		     ' AND edh.dbi_flag = ''Y'' ';

    if (upper(nvl(l_category_id,'ALL')) ='ALL') then

       l_where    := l_where ||    ' AND edh.parent_id = eip.child_id ' ||
                                    ' and edh.top_node_flag=''Y''';
    elsif (upper(l_category_id) <> 'ALL')  then

       l_from            := l_from || ' ,eni_oltp_item_star star ';

       l_where           := l_where || ' AND prod_mv. item_id = star.ID '||
				         ' AND star.vbh_category_id = edh.child_id '||
				         ' AND star.master_id IS NULL '||
				         ' AND eip.id = edh.IMM_CHILD_ID '||
				         ' AND eip.ID =eip.child_id   '||
				         ' AND ( ( eip.leaf_node_flag = ''N''' ||
					 ' AND eip.parent_id <> eip.ID) ' ||
					 ' OR eip.leaf_node_flag = ''Y'') '||
					 ' and eip.parent_id=edh.parent_id ';
    end if;

  ELSIF l_view_by = 'IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM' THEN --View by is Product
   l_from := l_from || ' eni_item_v item ';
   l_where    := l_where ||  'and  prod_mv.item_id = item.id ';

  end if;



  /************************/




    IF UPPER(l_minisite_id) <> 'ALL' THEN
      l_where  := l_where || ' AND prod_mv.minisite_id in (&SITE+SITE)';
    END IF;

    IF UPPER(l_category_id) <> 'ALL' THEN
     IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
      l_where           := l_where ||' and edh.parent_id =(&ITEM+ENI_ITEM_VBH_CAT)';
     ELSIF (l_view_by ='IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM' ) THEN
      l_from           := l_from || ' ,eni_item_prod_cat_lookup_v eip ';
      l_where          := l_where ||' and item.vbh_category_id=eip.child_id '||
	  	          ' and eip.parent_id =(&ITEM+ENI_ITEM_VBH_CAT)';
     END IF;
    END IF;

     IF UPPER(l_item_id) <> 'ALL' THEN
     l_where := l_where || ' and prod_mv.item_id = (&IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM)';
  --   l_where2  := l_where2 || ' AND prod_mv.product_id = (&IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM)';
    END IF;


    l_custom_sql  := ' SELECT ' ||  l_select  ||
                   ' FROM ' ||  l_from  ||' where '||l_where ||
		   ' group by '||l_groupby||
		   ') where '||  l_where2||
		   ' &ORDER_BY_CLAUSE ';


    x_custom_sql  := l_custom_sql;

    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_custom_rec.attribute_name := ':l_ccy' ;
  l_custom_rec.attribute_value:= l_currency_code ;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name :=':l_gl_p' ;
  l_custom_rec.attribute_value:= l_gl_p;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_gl_s' ;
  l_custom_rec.attribute_value:= l_gl_s;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;


EXCEPTION
   WHEN OTHERS THEN
   null;

/* ====================================================================== */
/*      Query revamped for bug 5373132 - End                              */
/* ====================================================================== */

END GET_ACTY_BY_CATG_PORT_SQL;

END IBE_BI_PROD_CATG_PVT;

/
