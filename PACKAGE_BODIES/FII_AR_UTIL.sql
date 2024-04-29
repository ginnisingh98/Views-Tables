--------------------------------------------------------
--  DDL for Package Body FII_AR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_UTIL" AS
/* $Header: FIIARPMV1B.pls 115.1 2004/05/19 02:38:35 ilavenil noship $ */

-- -------------------------------------------------
-- Re-set the globals variables to NULL
-- -------------------------------------------------
PROCEDURE reset_globals IS
BEGIN
p_as_of_date	    := NULL;
p_period_type	    := NULL;
p_view_by	    := NULL;
p_sgid		    := NULL;
p_prod_cat	    := NULL;
p_cust		    := NULL;
p_curr		    := NULL;
p_record_type_id    := NULL;



END reset_globals;

-- -------------------------------------------------
-- Parse thru the parameter talbe and set globals
-- -------------------------------------------------


PROCEDURE get_parameters (p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL


			) IS

BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
          IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
             p_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value, 'DD-MM-YYYY');
         END IF;
          IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
             p_period_type := p_page_parameter_tbl(i).parameter_value;
          END IF;
          IF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
             p_view_by := p_page_parameter_tbl(i).parameter_value;
          END IF;
	   IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
      p_sgid :=  p_page_parameter_tbl(i).parameter_id;
    END IF;

    IF(p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT') THEN
       p_prod_cat :=  p_page_parameter_tbl(i).parameter_id;
    END IF;

    IF(p_page_parameter_tbl(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') THEN
       p_cust :=  p_page_parameter_tbl(i).parameter_id;
    END IF;

    IF (p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN p_curr := p_page_parameter_tbl(i).parameter_id;
    END IF;

     END LOOP;
  END IF;
  If p_period_type is not null then
    CASE p_period_type
      WHEN 'FII_TIME_WEEK'       THEN p_record_type_id := 32;
      WHEN 'FII_TIME_ENT_PERIOD' THEN p_record_type_id := 64;
      WHEN 'FII_TIME_ENT_QTR'    THEN p_record_type_id := 128;
      WHEN 'FII_TIME_ENT_YEAR'   THEN p_record_type_id := 256;
    END CASE;
  End if;



END get_parameters;

FUNCTION get_label(sequence IN VARCHAR2) RETURN VARCHAR2 IS

stmt		VARCHAR2(240);
l_asof_date     DATE := FII_AR_Util.p_as_of_date;
l_temp_date	DATE := NULL;

 BEGIN

IF FII_AR_Util.p_period_type = 'FII_TIME_ENT_YEAR' THEN

	CASE sequence

	WHEN '1' THEN
			l_temp_date := fii_time_api.ent_pqtr_end(fii_time_api.ent_pqtr_end(fii_time_api.ent_pqtr_end(l_asof_date)));
        WHEN '2' THEN
			l_temp_date := fii_time_api.ent_pqtr_end(fii_time_api.ent_pqtr_end(l_asof_date));
	WHEN '3' THEN
			l_temp_date := fii_time_api.ent_pqtr_end(l_asof_date);
	WHEN '4' THEN
			stmt := FND_Message.get_string('FII', 'FII_QTD');
			RETURN stmt;
	WHEN '5' THEN
			stmt := FND_Message.get_string('FII', 'FII_ROLL4_QTS_REV');
				RETURN stmt;
	ELSE
		RETURN NULL;

        END CASE;

        SELECT name INTO  stmt
        FROM fii_time_ent_qtr
        WHERE l_temp_date = end_date;



ELSIF FII_AR_Util.p_period_type = 'FII_TIME_ENT_QTR' THEN

	CASE sequence

	WHEN '1' THEN
			l_temp_date := fii_time_api.ent_pqtr_end(fii_time_api.ent_pqtr_end(fii_time_api.ent_pqtr_end(l_asof_date)));
        WHEN '2' THEN
			l_temp_date := fii_time_api.ent_pper_end(fii_time_api.ent_pper_end(l_asof_date));
	WHEN '3' THEN
			l_temp_date := fii_time_api.ent_pper_end(l_asof_date);
	WHEN '4' THEN
			stmt := FND_Message.get_string('FII', 'FII_MTD');
			RETURN stmt;
	WHEN '5' THEN
			stmt := FND_Message.get_string('FII', 'FII_ROLL3_MTH_REV');
				RETURN stmt;
	ELSE
		RETURN NULL;

        END CASE;

        SELECT name INTO  stmt
        FROM fii_time_ent_period
        WHERE l_temp_date = end_date;

  ELSE
	RETURN NULL;

END IF;

RETURN stmt;

END get_label;


  /*public procedure.  binding variables is done here.*/
PROCEDURE Bind_variable
     (p_sqlstmt IN Varchar2,
     p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
     p_sql_output OUT NOCOPY Varchar2,
     p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
     p_record_type_id IN Number Default Null,
     p_view_by IN Varchar2 Default Null,
     p_fiibind1          IN Varchar2 Default null,
     p_fiibind2          IN Varchar2 Default null
   ) IS
     l_bind_rec       BIS_QUERY_ATTRIBUTES;

BEGIN
       p_bind_output_table := BIS_QUERY_ATTRIBUTES_TBL();
       l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
       p_sql_output := p_sqlstmt;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIIBIND1';
       l_bind_rec.attribute_value := to_char(p_fiibind1);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIIBIND2';
       l_bind_rec.attribute_value := to_char(p_fiibind2);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':VIEW_BY';
       l_bind_rec.attribute_value := to_char(p_view_by);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':RECORD_TYPE_ID';
       l_bind_rec.attribute_value := to_char(p_record_type_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;


END;

END fii_AR_util;

/
