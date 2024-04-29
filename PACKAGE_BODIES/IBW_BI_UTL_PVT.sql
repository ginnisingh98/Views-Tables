--------------------------------------------------------
--  DDL for Package Body IBW_BI_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_BI_UTL_PVT" AS
/* $Header: ibwbutlb.pls 120.5 2005/10/19 02:39 gjothiku noship $ */

/**********************************************************************************************
 *  FUNCTION   : GET_LOOKUPS_MNG 																	                            *
 *  PURPOSE     : This function is used to return FND lookup meaning                          *
 *                given a FND lookup type and FND lookup code                                 *
 *	PRARAMETERS	:                                                                             *
 *					 p_lkp_type      varchar2 IN  This is used to get thr lookup type                 *
 *					 p_lkp_code      varchar2 IN  This is used to get the lookup code                 *
 *	RETURN      :                                                                             *
 *           VARCHAR2  - Lookup meaning                                                       *
**********************************************************************************************/

FUNCTION GET_LOOKUPS_MNG(p_lkp_type IN varchar2,p_lkp_code in  varchar2)
return VARCHAR2 IS

  l_meaning	varchar2(100);
   --FND Logging
  l_full_path   VARCHAR2(50);
  gaflog_value  VARCHAR2(10);

 CURSOR c_meaning (lkp_type varchar2,lkp_code varchar2) IS
  SELECT
    meaning
  FROM
    fnd_lookups
	WHERE
    lookup_type = lkp_type AND
    lookup_code = lkp_code;

BEGIN
  --FND Logging
  l_full_path  := 'ibw.plsql.ibwbutlb.get_lookups_mng';
  --Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,' BEGIN : p_lkp_type '|| p_lkp_type || ' p_lkp_code '|| p_lkp_code);
  END IF;

  OPEN c_meaning(p_lkp_type,p_lkp_code);
  FETCH c_meaning INTO l_meaning;
  CLOSE c_meaning;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,' END : Lookup Meaning = ' || l_meaning );
  END IF;

return l_meaning;

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;
   return null;

END GET_LOOKUPS_MNG;

/**********************************************************************************************
 *  FUNCTION   : GTTL 																	                                      *
 *  PURPOSE     : This function is used to return dynamic graph titles                        *
 *                non trend reports based on the view by selected                             *
 *	PRARAMETERS	:                                                                             *
 *					 p_lkp_code      varchar2 IN  This is used to get the lookup code                 *
 *					 p_region_code   varchar2 IN  This is used to get thr AK region code              *
 *					 p_view_by       varchar2 IN  This is used to get the view by selected            *
 *	RETURN      :                                                                             *
 *           VARCHAR2  - Graph title                                                          *
**********************************************************************************************/

FUNCTION GTTL (p_lkp_code IN varchar2,p_region_code IN varchar2,p_view_by IN varchar2)
return VARCHAR2 IS

  l_first 	    VARCHAR2(100);
  l_attr_code	  VARCHAR2(100);
  l_last		    VARCHAR2(100);
  l_region_code VARCHAR2(100);
  --FND Logging
  l_full_path   VARCHAR2(50);
  gaflog_value  VARCHAR2(10);

 CURSOR c_last  (regioncode varchar2,attributecode varchar2)   IS
	select ATTRIBUTE_LABEL_LONG
	from ak_region_items_vl
	where region_code =  regioncode
	and attribute_code = attributecode;
BEGIN

  --FND Logging
  l_full_path  := 'ibw.plsql.ibwbutlb.get_grph_ttl';
--Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,' BEGIN : p_region_code '|| p_region_code || ' p_lkp_code '|| p_lkp_code || ' p_view_by '|| p_view_by);
  END IF;

-- Based on the short name passed as parameter the appropriate region code is initialised in l_region_code
-- This is done mainly to reduce the length of the long label in Ak region items from
-- where this procedure is called.

  IF p_region_code = 'PAGEINT'
  THEN
    l_region_code := 'IBW_BI_PAGE_INTEREST';

  ELSIF p_region_code = 'CSTACTV'
  THEN
    l_region_code := 'IBW_BI_CUST_ACTY';

  ELSIF p_region_code = 'CMPANLY'
  THEN
    l_region_code := 'IBW_BI_CAMP_ANALYSIS';

  ELSIF p_region_code = 'WEBREF'
  THEN
    l_region_code := 'IBW_BI_WEB_REF_ANALYSIS';

  ELSIF p_region_code = 'WEBPROD'
  THEN
    l_region_code := 'IBW_BI_PROD_INT';

  END IF;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,' l_region_code '|| l_region_code );
  END IF;

-- The lookup meaning gives the first part of the graph title

l_first	:= GET_LOOKUPS_MNG('IBW_GEN_LOOKUP',p_lkp_code);

-- Based on the view by the attribute is initialised in l_attr_code

  IF( p_view_by = 'SITE+SITE')
    THEN
	l_attr_code := 'IBE_MSITE_ID';    --  Changed from IBW_SITE to IBE_MSITE_ID

   ELSIF( p_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS')
    THEN
	l_attr_code := 'IBW_CUST_CLASS';

   ELSIF( p_view_by = 'CUSTOMER+PROSPECT')
    THEN
	l_attr_code := 'IBW_PROSPECT';

   ELSIF( p_view_by = 'ITEM+ENI_ITEM_VBH_CAT')
    THEN
	l_attr_code := 'IBE_PROD_CATG';  -- Changed IBW_PROD_CATG to IBE_PROD_CATG

   ELSIF( p_view_by = 'IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM')   -- Fix for Issue # 19 in Bug # 4636308
    THEN
	l_attr_code := 'IBW_PROD';

   ELSIF( p_view_by = 'IBW_REFERRAL_CATEGORY+IBW_REF_CAT')
    THEN
	l_attr_code := 'IBW_REFERRAL';

   ELSIF( p_view_by = 'CAMPAIGN+CAMPAIGN')
    THEN
	l_attr_code := 'IBW_CAMPAIGN';

   ELSIF( p_view_by = 'IBW_PAGE+IBW_SITE_AREAS')
    THEN
	l_attr_code := 'IBW_SITE_AREA';

   ELSIF( p_view_by = 'IBW_PAGE+IBW_PAGES')
    THEN
	l_attr_code := 'IBW_PAGE';

  END IF;

 OPEN c_last(l_region_code,l_attr_code);
	FETCH c_last INTO l_last;
 CLOSE c_last;

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,' END : l_first '|| l_first || ' l_last '|| l_last);
  END IF;

return l_first||' '||l_last;

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;
   return null;

END  GTTL;

/***********************************************************************************************
*  PROCEDURE   : GET_PAGE_PARAMETERS 																	                         *
*  PURPOSE     : This procedure is used to get the parameters selected in the                  *
*                parameter portlet                                                             *
*	PRARAMETERS	:                                                                                *
*					   p_pmv_parameters      BIS_PMV_PAGE_PARAMETER_TBL IN  This table of records        *
*                                                                is used to get the            *
*                                                                 paremeters  in teh form of   *
*                                                                 (name,id,value) per record   *
*             x_period_type         varchar2 OUT  Period type                                  *
*					    x_site                varchar2 OUT  Site                                         *
*             x_currency_code       varchar2 OUT  Currency code                                *
*             x_site_area           varchar2 OUT  Site Area                                    *
*             x_page                varchar2 OUT  Page                                         *
*             x_referral            varchar2 OUT  Referral Category                            *
*             x_prod_cat            varchar2 OUT  Product Category                             *
*             x_prod                varchar2 OUT  Product                                      *
*             x_cust_class          varchar2 OUT  Customer Classification                      *
*             x_cust                varchar2 OUT  Customer                                     *
*             x_campaign            varchar2 OUT  Campaign                                     *
*             x_view_by             varchar2 OUT  View By                                      *
*                                                                                              *
************************************************************************************************/

PROCEDURE GET_PAGE_PARAMETERS(p_pmv_parameters  IN  BIS_PMV_PAGE_PARAMETER_TBL,
					      x_period_type	    OUT NOCOPY VARCHAR2,
	      				x_site            OUT NOCOPY VARCHAR2,
		      			x_currency_code   OUT NOCOPY VARCHAR2,
			      		x_site_area       OUT NOCOPY VARCHAR2,
      					x_page            OUT NOCOPY VARCHAR2,
	      				x_referral        OUT NOCOPY VARCHAR2,
		      			x_prod_cat        OUT NOCOPY VARCHAR2,
			      		x_prod            OUT NOCOPY VARCHAR2,
      					x_cust_class      OUT NOCOPY VARCHAR2,
	      				x_cust            OUT NOCOPY VARCHAR2,
						    x_campaign	      OUT NOCOPY VARCHAR2,
		      			x_view_by         OUT NOCOPY VARCHAR2)
			AS

  l_parameter_name  varchar2(1000);
   --FND Logging
  l_full_path   VARCHAR2(50);
  gaflog_value  VARCHAR2(10);

BEGIN

  --FND Logging
  l_full_path  := 'ibw.plsql.ibwbutlb.get_page_parameters';
--Profile is : FND: Debug Log Enabled and FND: Debug Log Level for Log Level
  gaflog_value := fnd_profile.value('AFLOG_ENABLED');

  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,' BEGIN : ');
  END IF;

  FOR i IN p_pmv_parameters.FIRST..p_pmv_parameters.LAST
  LOOP
    l_parameter_name := p_pmv_parameters(i).parameter_name;


   IF( l_parameter_name = 'IBW_WEB_ANALYTICS_GROUP1+FII_CURRENCIES')
    THEN
      x_currency_code :=  p_pmv_parameters(i).parameter_id;

  ELSIF( l_parameter_name = 'PERIOD_TYPE')
    THEN
      x_period_type := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'SITE+SITE')
    THEN
       x_site := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'IBW_PAGE+IBW_SITE_AREAS')
    THEN
       x_site_area := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'IBW_PAGE+IBW_PAGES')
    THEN
       x_page := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS')
    THEN
       x_cust_class := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'CUSTOMER+PROSPECT')
    THEN
       x_cust := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'IBW_REFERRAL_CATEGORY+IBW_REF_CAT')
    THEN
       x_referral := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'ITEM+ENI_ITEM_VBH_CAT')
    THEN
      x_prod_cat    := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'IBW_WEB_ANALYTICS_GROUP1+ENI_ITEM')
    THEN
      x_prod := p_pmv_parameters(i).parameter_value;

   ELSIF( l_parameter_name = 'CAMPAIGN+CAMPAIGN')
    THEN
      x_campaign := p_pmv_parameters(i).parameter_value;

   ELSIF ( l_parameter_name = 'VIEW_BY')
    THEN
      x_view_by := p_pmv_parameters(i).parameter_value;

    END IF;
  END LOOP;
  IF gaflog_value ='Y' AND (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string(fnd_log.level_statement,l_full_path,' END : x_period_type ' || x_period_type ||
   ' x_currency_code '|| x_currency_code || ' x_site '|| x_site ||' x_site_area '|| x_site_area ||
   ' x_page '|| x_page || ' x_cust_class '|| x_cust_class || ' x_cust '|| x_cust || ' x_referral ' ||
   x_referral ||' x_prod_cat ' || x_prod_cat || ' x_prod '|| x_prod || ' x_campaign ' || x_campaign || ' x_view_by '||
   x_view_by);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_unexpected,l_full_path,SQLERRM);
    end if;

END GET_PAGE_PARAMETERS;

END IBW_BI_UTL_PVT;

/
