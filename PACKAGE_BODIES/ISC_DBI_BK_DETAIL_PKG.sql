--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BK_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BK_DETAIL_PKG" AS
/* $Header: ISCRGBJB.pls 120.1 2006/05/14 21:12:57 abhdixi noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_sgid 		VARCHAR2(32000);
  l_sg_where     	VARCHAR2(32000);
  l_prod		VARCHAR2(32000);
  l_prod_where		VARCHAR2(32000);
  l_prod_cat		VARCHAR2(32000);
  l_prod_cat_from	VARCHAR2(32000);
  l_prod_cat_where	VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_class		VARCHAR2(32000);
  l_class_where		VARCHAR2(32000);
  l_sg_sg		NUMBER;
  l_sg_res		NUMBER;
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;
  l_curr		VARCHAR2(10000);
  l_curr_g		VARCHAR2(15) := '''FII_GLOBAL1''';
  l_curr_suffix		VARCHAR2(120);

BEGIN
  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
      l_sgid :=  p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT') THEN
       l_prod_cat :=  p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM') THEN
       l_prod :=  p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_cust :=  p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') THEN
       l_class :=  p_param(i).parameter_id;
    END IF;

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

  END LOOP;

  IF (l_curr = l_curr_g)
    THEN l_curr_suffix := 'g';
    ELSE l_curr_suffix := 'g1';
  END IF;

  l_sg_sg   := to_number(replace(substr(l_sgid,instr(l_sgid,'.') + 1),''''));
  l_sg_res  := to_number(replace(substr(l_sgid,1,instr(l_sgid,'.') - 1),''''));

  IF (l_sg_res IS NULL) -- when a sales group is chosen
    THEN
      l_sg_where := '
		AND sc.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP)';
  ELSE -- when the LOV parameter is a SRep (no need to go through the SG hierarchy MV
      l_sg_where := '
		AND sc.sales_grp_id = :ISC_SG
		AND sc.resource_id = :ISC_RES';
  END IF;


  IF (l_cust IS NULL)
    THEN l_cust_where := '';
    ELSE l_cust_where := '
		AND f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
  END IF;

  IF (l_class IS NULL)
    THEN l_class_where:='';
    ELSE l_class_where :='
		AND class.class_code in (&FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  END IF;

  IF ((l_prod_cat IS NULL) AND (l_prod IS NULL)) -- Prod Cat=All, Product=All
    THEN l_prod_cat_from := '';
	 l_prod_cat_where := '';
	 l_prod_where := '';
  ELSIF (l_prod IS NULL) -- Prod Cat selected, Product=All
    THEN l_prod_cat_from := ',
			ENI_DENORM_HIERARCHIES		eni_cat,
			MTL_DEFAULT_CATEGORY_SETS	mdcs';
	 l_prod_cat_where := '
		    AND star.vbh_category_id = eni_cat.child_id
		    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
		    AND	eni_cat.dbi_flag = ''Y''
		    AND eni_cat.object_type = ''CATEGORY_SET''
		    AND eni_cat.object_id = mdcs.category_set_id
		    AND	mdcs.functional_area_id = 11';
	 l_prod_where := '';
  ELSE -- Product selected, Prod Cat selected OR All
    	 l_prod_cat_from := '';
	 l_prod_cat_where := '';
	 l_prod_where := '
		    AND star.master_id IN (&ITEM+ENI_ITEM)';
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_stmt := '
SELECT				ISC_ATTRIBUTE_1, -- Order Number
				ISC_ATTRIBUTE_2, -- Line Number
	ou.value		ISC_ATTRIBUTE_3, -- Operating Unit
				ISC_ATTRIBUTE_4, -- Booked Date
	cust.value		ISC_ATTRIBUTE_5, -- Customer
	cc.value		ISC_ATTRIBUTE_10, -- Customer Classification
	items.value		ISC_ATTRIBUTE_6, -- Item
	items.description	ISC_ATTRIBUTE_7, -- Description
	g.group_name		ISC_ATTRIBUTE_8, -- Sales Group
	r.resource_name		ISC_ATTRIBUTE_9, -- Sales Representative
				ISC_MEASURE_2, -- Booked Order Sales Credit
				ISC_MEASURE_3, -- Grand Total - Booked Order Sales Credit
				ISC_MEASURE_4 -- Header ID
  FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE, isc_attribute_1 desc, isc_attribute_2, org_ou_id))-1 RNK,
		org_ou_id, customer_id, class_code, item_id, sales_grp_id, resource_id,
		ISC_ATTRIBUTE_1, ISC_ATTRIBUTE_2, ISC_ATTRIBUTE_4,
		ISC_MEASURE_2, ISC_MEASURE_3, ISC_MEASURE_4
   	   FROM	(SELECT	f.org_ou_id			ORG_OU_ID,
			f.customer_id			CUSTOMER_ID,
			class.class_code		CLASS_CODE,
			nvl(star.master_id, star.id)	ITEM_ID,
			sc.sales_grp_id			SALES_GRP_ID,
			sc.resource_id			RESOURCE_ID,
			f.order_number			ISC_ATTRIBUTE_1,
			f.line_number			ISC_ATTRIBUTE_2,
			f.time_booked_date_id		ISC_ATTRIBUTE_4,
			f.booked_amt_'||l_curr_suffix||' * sc.sales_credit_percent / 100
							ISC_MEASURE_2,
			sum(f.booked_amt_'||l_curr_suffix||' * sc.sales_credit_percent / 100) over ()
							ISC_MEASURE_3,
			f.header_id			ISC_MEASURE_4
   	   	   FROM	ISC_BOOK_SUM2_F		f,
			ISC_SALES_CREDITS_F	sc,
			ENI_OLTP_ITEM_STAR	star,
			FII_PARTY_MKT_CLASS	class'
			||l_prod_cat_from||'
  		  WHERE f.time_booked_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						  AND &BIS_CURRENT_ASOF_DATE
		    AND	f.line_id = sc.line_id
		    AND f.inventory_item_id = star.inventory_item_id
		    AND f.item_inv_org_id = star.organization_id
		    AND f.customer_id = class.party_id
		    AND f.line_category_code <> ''RETURN''
		    AND f.item_type_code <> ''SERVICE''
		    AND f.order_source_id <> 27
		    AND f.order_source_id <> 10
		    AND f.ordered_quantity <> 0
		    AND f.charge_periodicity_code is NULL'
			||l_sg_where
			||l_prod_cat_where
			||l_prod_where
			||l_cust_where
			||l_class_where||')
	)				a,
	FII_CUSTOMERS_V			cust,
	FII_PARTNER_MKT_CLASS_V		cc,
	ENI_ITEM_V			items,
	FII_OPERATING_UNITS_V		ou,
	JTF_RS_GROUPS_VL		g,
	JTF_RS_RESOURCE_EXTNS_VL	r
  WHERE	a.customer_id = cust.id
    AND a.class_code = cc.id
    AND a.item_id = items.id
    AND a.org_ou_id = ou.id
    AND	a.sales_grp_id = g.group_id
    AND	a.resource_id = r.resource_id
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
ORDER BY rnk';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_SG';
  l_custom_rec.attribute_value := to_char(l_sg_sg);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_RES';
  l_custom_rec.attribute_value := to_char(l_sg_res);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END get_sql;

END ISC_DBI_BK_DETAIL_PKG ;


/
