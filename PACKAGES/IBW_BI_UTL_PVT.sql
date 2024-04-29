--------------------------------------------------------
--  DDL for Package IBW_BI_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_BI_UTL_PVT" AUTHID CURRENT_USER AS
/* $Header: ibwbutls.pls 120.2 2005/09/15 02:20 rgollapu noship $ */

FUNCTION GET_LOOKUPS_MNG(p_lkp_type IN varchar2,
			 p_lkp_code in  varchar2)
return VARCHAR2;

FUNCTION GTTL (p_lkp_code IN varchar2,
			p_region_code in  varchar2,
			p_view_by varchar2)
return VARCHAR2;

PROCEDURE GET_PAGE_PARAMETERS(p_pmv_parameters  IN  BIS_PMV_PAGE_PARAMETER_TBL,
					     x_period_type	  OUT NOCOPY VARCHAR2,
			     		x_site            OUT NOCOPY VARCHAR2,
				     	x_currency_code   OUT NOCOPY VARCHAR2,
     					x_site_area       OUT NOCOPY VARCHAR2,
	     				x_page            OUT NOCOPY VARCHAR2,
		     			x_referral        OUT NOCOPY VARCHAR2,
			     		x_prod_cat        OUT NOCOPY VARCHAR2,
				     	x_prod            OUT NOCOPY VARCHAR2,
     					x_cust_class      OUT NOCOPY VARCHAR2,
	     				x_cust            OUT NOCOPY VARCHAR2,
					     x_campaign	   OUT NOCOPY VARCHAR2,
		     			x_view_by         OUT NOCOPY VARCHAR2);
END IBW_BI_UTL_PVT;

 

/
