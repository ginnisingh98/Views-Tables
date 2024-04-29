--------------------------------------------------------
--  DDL for Package Body ENI_DBI_TOO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_TOO_PKG" AS
/* $Header: ENITOOPB.pls 120.0 2005/05/26 19:33:56 appldev noship $ */

PROCEDURE get_sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			        VARCHAR2(10000);
  l_curr			        VARCHAR2(10000);
  l_category 			    VARCHAR2(500) := NULL;
  l_item 			        VARCHAR2(500) := NULL;
  l_category_where 	  VARCHAR2(1000);
  l_item_where 			  VARCHAR2(1000);
  l_from			        VARCHAR2(2000);
  l_order_by          VARCHAR2(100);
  l_curr_select       VARCHAR2(100);
  l_extra_where 		  VARCHAR2(1000);
  l_extra_outer_where VARCHAR2(1000);
  l_custom_rec			  BIS_QUERY_ATTRIBUTES;

BEGIN

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

-- Ideally  we should be calling ENI_DBI_UTIL_PKG.get_parameters(..) . But since we are concerned with only
-- the following three parameters, looping through the parameters table here, instead.

  FOR i IN 1..p_param.COUNT
  LOOP
    case (p_param(i).parameter_name)
      when ('CURRENCY+FII_CURRENCIES')
        then l_curr := p_param(i).parameter_id;

      when ('ITEM+ENI_ITEM_VBH_CAT' )
	      then l_category := replace(p_param(i).parameter_id, '''')	  ;

      when ('ITEM+ENI_ITEM')
	      then  l_item := p_param(i).parameter_id;
      when ('ORDERBY')
	      then  l_order_by := p_param(i).parameter_value;  -- Bug : 3991419
        	  	  -- note: parameter_id will be "'8000-200'" where 8000 is item_id, 200 is org, and single quotes enclose it
      else
        null;
      end case;
  END LOOP;

  IF ( l_item IS NULL and l_category IS NULL )
  THEN
    l_extra_where :=' AND rank_all < = 25 ';
    l_extra_outer_where :='';
  ELSE
    l_extra_where := '';
    l_extra_outer_where :='AND rownum <=25 ';
    IF l_item IS NOT NULL
    THEN
      l_item_where := ' AND fact.item_id in (&'||'ITEM+ENI_ITEM )';
    END IF;

    IF l_category IS NOT NULL
    THEN
      l_category_where := ' AND edh.parent_id = :CATEGORY
                            AND edh.child_id = fact.product_category_id ';
      l_from := ' , eni_denorm_hierarchies edh ';
      l_custom_rec.attribute_name := ':CATEGORY';
      l_custom_rec.attribute_value := l_category;
      l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
      l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
      x_custom_output.extend;
      x_custom_output(1) := l_custom_rec;
    END IF;
  END IF;

  IF INSTR(l_curr,ENI_DBI_UTIL_PKG.get_curr_prim) > 0 -- for Primary Currency
  THEN
    l_curr_select := ' fact.SALES_CREDIT_AMT as ENI_ATTRIBUTE5, ' ;
  ELSIF INSTR(l_curr,ENI_DBI_UTIL_PKG.get_curr_sec) > 0
  THEN
    l_curr_select := ' fact.SALES_CREDIT_AMT_S as ENI_ATTRIBUTE5, ' ;
  ELSE
    l_curr_select := ' fact.SALES_CREDIT_AMT as ENI_ATTRIBUTE5, ' ;
  END IF;

  l_stmt := '
  SELECT
    cust.party_name as ENI_ATTRIBUTE2,
    fact.opty_id ENI_ATTRIBUTE3,
    hdr.description as ENI_ATTRIBUTE4,
    ENI_ATTRIBUTE5,
    ENI_ATTRIBUTE6,
    ENI_ATTRIBUTE7,
    item.value as ENI_ATTRIBUTE9,
    eni.value as ENI_ATTRIBUTE8,
    nvl(r.resource_name, decode(	fact.salesrep_id, -1,
      ''Unassigned'',
    NULL))	ENI_ATTRIBUTE11,
    g.group_name	ENI_ATTRIBUTE12
  FROM
	  (SELECT
			  fact.opty_id ,
			  '||l_curr_select||'
			  fact.win_probability as ENI_ATTRIBUTE6,
			  fact.close_date as ENI_ATTRIBUTE7,
			  fact.salesrep_id,
        fact. item_id,
        fact.product_category_id,
        fact.customer_id,
        fact.sales_group_id
		  FROM  ENI_DBI_TOO_MV			fact ' ||
	          l_from || '
      WHERE   fact.SALES_CREDIT_AMT > 0 '
        || l_item_where
        || l_category_where
        || l_extra_where ||
	      ' ORDER BY ENI_ATTRIBUTE5 desc
     ) fact,
  ENI_ITEM_VBH_NODES_V		eni,
  ENI_ITEM_V			item,
  HZ_PARTIES			CUST,
  AS_LEADS_ALL HDR,
  JTF_RS_GROUPS_VL		g,
  JTF_RS_RESOURCE_EXTNS_VL	r
  WHERE   fact.item_id = item.id
  AND     fact.opty_id = hdr.lead_id
	AND     fact.product_category_id = eni.id
  AND     eni.parent_id = eni.child_id
	AND     fact.customer_id = cust.party_id
	AND     fact.sales_group_id = g.group_id
	AND     fact.salesrep_id = r.resource_id(+)
  '|| l_extra_outer_where ||'
  ORDER BY  '||l_order_by ; -- Bug : 3991419

  x_custom_sql := l_stmt;

END get_sql;

END ENI_DBI_TOO_PKG;

/
