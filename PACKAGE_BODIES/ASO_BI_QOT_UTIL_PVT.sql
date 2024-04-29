--------------------------------------------------------
--  DDL for Package Body ASO_BI_QOT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_QOT_UTIL_PVT" AS
/* $Header: asovbiutlb.pls 120.1 2005/12/15 04:19:28 jmahendr noship $  */

-- This function returns the record_type_id using the period type from the
-- parameter portlet.

FUNCTION GET_RECORD_TYPE_ID(p_period_type IN VARCHAR2)
RETURN NUMBER IS
  l_record_type_id NUMBER;
BEGIN

  IF(p_period_type = 'FII_TIME_ENT_YEAR') THEN
    l_record_type_id := 119;
  ELSIF(p_period_type = 'FII_TIME_ENT_QTR') THEN
    l_record_type_id := 55;
  ELSIF(p_period_type = 'FII_TIME_ENT_PERIOD') THEN
    l_record_type_id := 23;
  ELSE
    l_record_type_id := 11;
  END IF;

 RETURN l_record_type_id;

END GET_RECORD_TYPE_ID;

-- This function returns the rate of convertion from the primary to the
-- user functional currency.
FUNCTION GET_CUR_CONV_RATE(p_currency_code IN VARCHAR2,p_asof_date IN DATE) RETURN NUMBER IS

  l_conv_rate NUMBER := NULL;
  l_primary_curr VARCHAR2(3200);
  l_jtf_curr_profile VARCHAR2(3200);
  l_asof_date DATE;
BEGIN

  IF p_currency_code IS NULL THEN
     RETURN l_conv_rate;
  END IF;

  l_asof_date := p_asof_date;

  IF ('EUR' = p_currency_code AND TO_DATE('01/01/1999','DD/MM/YYYY') > l_asof_date) THEN
     l_asof_date := TO_DATE('01/01/1999','DD/MM/YYYY');
  END IF;

  l_jtf_curr_profile := FND_PROFILE.Value('JTF_PROFILE_DEFAULT_CURRENCY');

  IF INSTR(p_currency_code,'FII_GLOBAL1') > 0  THEN
      l_conv_rate  := 1;
  ELSIF INSTR(p_currency_code,l_jtf_curr_profile) > 0 THEN

      l_primary_curr := BIS_COMMON_PARAMETERS.Get_currency_code;

      IF (l_primary_curr = l_jtf_curr_profile) THEN
         RETURN 1;
      ELSE
         -- Api requires : From curr, to curr, as of date, conversion rate type
         l_conv_rate := GL_CURRENCY_API.get_rate_sql(
                          l_primary_curr,
                          l_jtf_curr_profile,
                          l_asof_date,
                          fnd_profile.value('AS_MC_DAILY_CONVERSION_TYPE'));
      END IF;

  END IF;

  IF(l_conv_rate < 0) THEN
     l_conv_rate := NULL;
  END IF;

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT ,
                        MODULE => 'ASO_BI_QOT_UTIL_PVT.GET_CUR_CONV_RATE ',
                        MESSAGE =>' l_conv_rate '||l_conv_rate||' l_primary_currency '||l_primary_curr||
                        ' p_currency_code '||p_currency_code||' p_asof_date '||l_asof_date);
  END IF;

  RETURN l_conv_rate;

  EXCEPTION
  WHEN OTHERS THEN
    RETURN l_conv_rate;

END GET_CUR_CONV_RATE;

-- Used for defaulting in the Parameter portlet
FUNCTION GET_DBI_PARAMS(p_region_id IN VARCHAR2)
RETURN VARCHAR2
IS

 l_as_of_date  VARCHAR2(150);
 l_sg_id       VARCHAR2(150);

BEGIN

 BEGIN

    l_sg_id := JTF_RS_DBI_CONC_PUB.GET_SG_ID();

 EXCEPTION
  WHEN OTHERS THEN
    l_sg_id := '-1111';
 END;

 l_as_of_date := TO_CHAR(TRUNC(SYSDATE),'DD-MON-YYYY') ;

 RETURN  '&AS_OF_DATE='|| l_as_of_date ||
  	 '&ASO_YEARLY=TIME_COMPARISON_TYPE+YEARLY&ASO_CURRENCY=FII_GLOBAL1'||
   '&ASO_QTR_ID=TIME+FII_TIME_ENT_QTR'||
    '&ASO_DIMENSION1=2'||
	 '&JTF_ORG_SALES_GROUP='|| l_sg_id;

END GET_DBI_PARAMS;

PROCEDURE PARSE_SALES_GROUP_ID(
        p_sg_id IN VARCHAR2,
        x_salesgroup_id   OUT NOCOPY  NUMBER,
        x_resource_id   OUT NOCOPY NUMBER
       ) AS

l_sg_id         VARCHAR2(20);
l_resource_id   VARCHAR2(20);
l_location      NUMBER;
BEGIN

IF(INSTR(p_sg_id, '.') > 0) then

    l_location := INSTR(p_sg_id,'.');
    x_salesgroup_id := TO_NUMBER(REPLACE(SUBSTR(p_sg_id, l_location + 1),''''));
	  l_resource_id := REPLACE(SUBSTR(p_sg_id,1, l_location - 1),'''');
	  x_resource_id := TO_NUMBER(REPLACE(l_resource_id,'''',''));

ELSE
    x_salesgroup_id := TO_NUMBER(REPLACE(p_sg_id, ''''));
END IF;

END PARSE_SALES_GROUP_ID;

Procedure GET_PAGE_PARAMS(p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                          x_conv_rate  OUT NOCOPY NUMBER,
                          x_record_type_id OUT NOCOPY NUMBER,
                          x_sysdate OUT NOCOPY DATE,
                          x_sg_id OUT NOCOPY NUMBER,
                          x_sr_id OUT NOCOPY NUMBER,
                          x_asof_date  OUT NOCOPY DATE,
                          x_priorasof_date OUT NOCOPY DATE,
                          x_fdcp_date OUT NOCOPY DATE,
                          x_fdpp_date OUT NOCOPY DATE,
                          x_period_type OUT NOCOPY  VARCHAR2,
                          x_comparision_type OUT NOCOPY  VARCHAR2,
                          x_orderBy  OUT NOCOPY  VARCHAR2,
                          x_sortBy OUT NOCOPY VARCHAR2,
                          x_viewby OUT NOCOPY VARCHAR2,
                          x_prodcat_id OUT NOCOPY VARCHAR2,
                          x_product_id OUT NOCOPY VARCHAR2)

AS
  l_parameter_name      VARCHAR2(3200);
  l_currency_type       VARCHAR2(3200);
  l_sg_id               VARCHAR2(3200);
  l_params              VARCHAR2(3200);
  l_order               VARCHAR2(3200);
Begin

 FOR i IN p_pmv_parameters.FIRST..p_pmv_parameters.LAST
  LOOP
    l_parameter_name := p_pmv_parameters(i).parameter_name ;
    IF('BIS_CURRENT_ASOF_DATE' = l_parameter_name)
    THEN
      x_asof_date := p_pmv_parameters(i).PERIOD_DATE;
    ELSIF( l_parameter_name = 'CURRENCY+FII_CURRENCIES')
    THEN
      l_currency_type :=  p_pmv_parameters(i).parameter_id;
    ELSIF( l_parameter_name = 'PERIOD_TYPE')
    THEN
      x_period_type :=  p_pmv_parameters(i).parameter_value ;
    ELSIF( l_parameter_name = 'TIME_COMPARISON_TYPE')
    THEN
      x_comparision_type := p_pmv_parameters(i).parameter_value;
    ELSIF( l_parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
      l_sg_id := p_pmv_parameters(i).parameter_id;
    ELSIF( l_parameter_name = 'BIS_PREVIOUS_ASOF_DATE')
    THEN
      x_priorasof_date := p_pmv_parameters(i).PERIOD_DATE;
    ELSIF ('BIS_CURRENT_EFFECTIVE_START_DATE' = l_parameter_name)
    THEN
     x_fdcp_date := p_pmv_parameters(i).PERIOD_DATE;
    ELSIF ('BIS_PREVIOUS_EFFECTIVE_START_DATE' = l_parameter_name)
    THEN
     x_fdpp_date := p_pmv_parameters(i).PERIOD_DATE;
    ELSIF ('ORDERBY' = l_parameter_name)
    THEN
      l_order := TRIM(p_pmv_parameters(i).parameter_value);
      x_orderBy := TRIM(SUBSTR(l_order,0,INSTR(l_order,' ')));
      x_sortBy := SUBSTR(l_order,INSTR(l_order,' '));
    ELSIF ('VIEW_BY' = l_parameter_name)
    THEN
      x_viewby :=  p_pmv_parameters(i).parameter_value;
    ELSIF ('ITEM+ENI_ITEM_VBH_CAT' = l_parameter_name)
    THEN
      x_prodcat_id := p_pmv_parameters(i).parameter_id;
    ELSIF ('ITEM+ENI_ITEM' = l_parameter_name)
    THEN
      x_product_id := p_pmv_parameters(i).parameter_id;
    END IF;

  END LOOP;

  -- Get the Conversion rate

  -- commented  for DBI7.0 Rup1 10-aug-2004
  -- x_conv_rate := ASO_BI_QOT_UTIL_PVT.GET_CUR_CONV_RATE(
  ---                 l_currency_type, x_asof_date);

  -- 7.0 rup1 changes - secondary Currency uptake. --
   IF INSTR(l_currency_type,'FII_GLOBAL1') > 0
   THEN
     /*  For Primary Currency */
      x_conv_rate := 1;
   ELSIF  INSTR(l_currency_type,'FII_GLOBAL2') > 0
   THEN
     /*  For Secondary Currency */
          x_conv_rate := 0;
   END IF;

  -- Get the Sales group
  PARSE_SALES_GROUP_ID(
    l_sg_id , x_salesgroup_id => x_sg_id, x_resource_id => x_sr_id);

  --Get the record type
  x_record_type_id := ASO_BI_QOT_UTIL_PVT.GET_RECORD_TYPE_ID(x_period_type);

  --Get the Sysdate from BIS_SYSTEM_DATE table
  x_sysdate := BIS_COMMON_PARAMETERS.GET_CURRENT_DATE_ID;

  IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

     l_params :=  ' BIS_CURRENT_ASOF_DATE '|| x_asof_date ||
                  ' CURRENCY+FII_CURRENCIES '|| l_currency_type||
                  ' PERIOD_TYPE '|| x_period_type||
                  ' TIME_COMPARISON_TYPE '|| x_comparision_type||
                  ' ORGANIZATION+JTF_ORG_SALES_GROUP '|| x_sg_id||
                  ' BIS_PREVIOUS_ASOF_DATE '|| x_priorasof_date||
                  ' BIS_CURRENT_EFFECTIVE_START_DATE '|| x_fdcp_date||
                  ' Record Type Id '|| x_record_type_id||
                  ' BIS_PREVIOUS_EFFECTIVE_START_DATE '|| x_fdpp_date||
                  ' ORDERBY '|| x_orderBy||
                  ' Conv Rate '|| x_conv_rate||
                  ' p_sg_id_num '|| x_sg_id||
                  ' p_sr_id_num '|| x_sr_id ||
                  ' p_sortBy ' || x_sortBy;

     FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                MODULE => 'ASO_BI_QOT_UTIL_PVT.GET_PAGE_PARAMS',
                MESSAGE => l_params);
  END IF;

END GET_PAGE_PARAMS;

-- Splits the long queries into different Logging statement
PROCEDURE write_query (p_query IN VARCHAR2, p_module IN VARCHAR2)
AS
  ind NUMBER := 1;
  l_length NUMBER := 0;
BEGIN

    l_length := length(p_query);

    WHILE ind < l_length LOOP
      IF(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                            MODULE => 'ASO_BI_QOT_UTIL_PVT.'||p_module,
                            MESSAGE => substr(p_query, ind+1, 3000));
      END IF;

      ind := ind + 3000;
   END LOOP;

 EXCEPTION
  WHEN OTHERS THEN
   NULL;

END write_query;

END ASO_BI_QOT_UTIL_PVT;

/
