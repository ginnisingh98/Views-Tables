--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BOOK_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BOOK_DETAIL_PKG" AS
/* $Header: ISCRGB9B.pls 120.1 2005/08/17 18:30:34 hprathur noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_org				VARCHAR2(10000);
  l_org_where			VARCHAR2(10000);
  l_prod			VARCHAR2(10000);
  l_prod_where			VARCHAR2(10000);
  l_prod_cat			VARCHAR2(10000);
  l_prod_cat_from		VARCHAR2(10000);
  l_prod_cat_where		VARCHAR2(10000);
  l_cust			VARCHAR2(10000);
  l_cust_where			VARCHAR2(10000);
  l_curr			VARCHAR2(10000);
  l_curr_g			VARCHAR2(15) := '''FII_GLOBAL1''';
  l_curr_g1			VARCHAR2(15) := '''FII_GLOBAL2''';
  l_curr_suffix			VARCHAR2(120);
  l_lang			VARCHAR2(10);

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  l_lang := userenv('LANG');

  FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

    IF (p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT')
      THEN l_prod_cat := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_prod := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_cust := p_param(i).parameter_value;
    END IF;

  END LOOP;

  IF (l_curr = l_curr_g)
    THEN l_curr_suffix := 'g';
   ELSIF (l_curr = l_curr_g1)
    THEN l_curr_suffix := 'g1';
    ELSE l_curr_suffix := 'f1';
  END IF;

  IF (l_org IS NULL OR l_org = 'All')
    THEN l_org_where := '
		    AND (EXISTS
			  (SELECT 1
			     FROM org_access o
			    WHERE o.responsibility_id = fnd_global.resp_id
			      AND o.resp_application_id = fnd_global.resp_appl_id
			      AND o.organization_id = fact.item_inv_org_id)
			OR EXISTS
			    (SELECT 1
			       FROM mtl_parameters org
			      WHERE org.organization_id = fact.item_inv_org_id
				AND NOT EXISTS
				 (SELECT 1
				    FROM org_access ora
				   WHERE org.organization_id = ora.organization_id)))';
    ELSE l_org_where := '
		    AND fact.item_inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF ((l_prod_cat IS NULL OR l_prod_cat = 'All')
      AND (l_prod IS NULL OR l_prod = 'All')) -- Prod Cat=All, Product=All
    THEN l_prod_cat_from := '';
	 l_prod_cat_where := '';
	 l_prod_where := '';
  ELSIF (l_prod IS NULL OR l_prod = 'All') -- Prod Cat selected, Product=All
    THEN l_prod_cat_from := ',
			ENI_OLTP_ITEM_STAR		star,
			ENI_DENORM_HIERARCHIES		eni_cat,
			MTL_DEFAULT_CATEGORY_SETS	mdcs';
	 l_prod_cat_where := '
		    AND fact.inventory_item_id = star.inventory_item_id
		    AND fact.item_inv_org_id = star.organization_id
		    AND star.vbh_category_id = eni_cat.child_id
		    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
		    AND	eni_cat.dbi_flag = ''Y''
		    AND eni_cat.object_type = ''CATEGORY_SET''
		    AND eni_cat.object_id = mdcs.category_set_id
		    AND	mdcs.functional_area_id = 11';
	 l_prod_where := '';
  ELSE -- Product selected, Prod Cat selected OR All
    	 l_prod_cat_from := ',
			ENI_OLTP_ITEM_STAR		star';
	 l_prod_cat_where := '
		    AND fact.inventory_item_id = star.inventory_item_id
		    AND fact.item_inv_org_id = star.organization_id';
	 l_prod_where := '
		    AND star.id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;


  IF (l_cust IS NULL OR l_cust = 'All')
    THEN l_cust_where := '';
    ELSE l_cust_where := '
		    AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
  END IF;



  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_stmt := '
 SELECT 			ISC_ATTRIBUTE_1, -- Order Number
				ISC_ATTRIBUTE_2, -- Line Number
	org.name		ISC_ATTRIBUTE_3, -- Organization
				ISC_ATTRIBUTE_4, -- Booked Date
	cust.value		ISC_ATTRIBUTE_5, -- Customer
	items.value		ISC_ATTRIBUTE_6, -- Item
	items.description	ISC_ATTRIBUTE_7, -- Description
	mtl.unit_of_measure	ISC_ATTRIBUTE_8, -- UOM
				ISC_MEASURE_1, -- Booked Quantity
				ISC_MEASURE_2, -- Booked Value
				ISC_MEASURE_3, -- Grand Total - Booked Value
				ISC_MEASURE_4 -- Header ID
   FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE, isc_measure_4, isc_attribute_2))-1 RNK,
		customer_id, inv_org_id, item_id, uom,
		ISC_ATTRIBUTE_1, ISC_ATTRIBUTE_2, ISC_ATTRIBUTE_4,
		ISC_MEASURE_1, ISC_MEASURE_2, ISC_MEASURE_3, ISC_MEASURE_4
   	   FROM	(SELECT	fact.customer_id					CUSTOMER_ID,
			fact.item_inv_org_id					INV_ORG_ID,
			fact.inventory_item_id||''-''||fact.item_inv_org_id	ITEM_ID,
			fact.inv_uom_code					UOM,
			fact.order_number					ISC_ATTRIBUTE_1,
			fact.line_number					ISC_ATTRIBUTE_2,
			fact.time_booked_date_id				ISC_ATTRIBUTE_4,
			fact.booked_qty_inv					ISC_MEASURE_1,
			fact.booked_amt_'||l_curr_suffix||'					ISC_MEASURE_2,
			sum(fact.booked_amt_'||l_curr_suffix||') over ()				ISC_MEASURE_3,
			fact.header_id						ISC_MEASURE_4
   	   	   FROM	ISC_BOOK_SUM2_F			fact'||l_prod_cat_from||'
  		  WHERE fact.time_booked_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						     AND &BIS_CURRENT_ASOF_DATE
		    AND	fact.line_category_code <> ''RETURN''
	  	    AND fact.item_type_code <> ''SERVICE''
		    AND	fact.order_source_id <> 10
		    AND fact.order_source_id <> 27
		    AND	fact.ordered_quantity <> 0
		    AND	fact.unit_selling_price <> 0
		    AND fact.charge_periodicity_code is NULL'
			||l_org_where
			||l_prod_cat_where
			||l_prod_where
			||l_cust_where||')
	)				a,
	FII_CUSTOMERS_V			cust,
	ENI_ITEM_ORG_V			items,
	HR_ALL_ORGANIZATION_UNITS_TL	org,
	MTL_UNITS_OF_MEASURE_TL		mtl
  WHERE	a.customer_id = cust.id
    AND a.item_id = items.id
    AND a.inv_org_id = org.organization_id
    AND org.language = :ISC_LANG
    AND a.uom = mtl.uom_code
    AND mtl.language = :ISC_LANG
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
ORDER BY rnk';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

END Get_Sql;

END ISC_DBI_BOOK_DETAIL_PKG;

/
