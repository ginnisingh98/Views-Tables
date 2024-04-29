--------------------------------------------------------
--  DDL for Package WIP_PARAMETER_WIPBIUTZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PARAMETER_WIPBIUTZ" AUTHID CURRENT_USER AS
/* $Header: wipbiups.pls 115.10 2002/11/28 12:09:22 rmahidha ship $ */

PROCEDURE error(P_FIELD IN VARCHAR2);

FUNCTION Validate_Org(P_ORG_LEVEL     IN VARCHAR2,
              P_ORGANIZATION_ID   IN OUT NOCOPY VARCHAR2,
              P_ORGANIZATION_NAME     IN VARCHAR2 default null) RETURN BOOLEAN;

FUNCTION Validate_Geo(P_GEOGRAPHY_CODE  IN OUT NOCOPY VARCHAR2,
                      P_GEOGRAPHY_NAME  IN VARCHAR2 default null,
                      P_GEO_LEVEL       IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

FUNCTION Validate_Cat(P_ITEM_CODE    IN OUT NOCOPY VARCHAR2,
                      P_ITEM             IN VARCHAR2 default null,
                      P_PROD_LEVEL   IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

FUNCTION Validate_Date(P_FROM_DATE       IN OUT NOCOPY VARCHAR2,
                       P_TO_DATE         IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

FUNCTION Validate_Parameters(
    P_ORG_LEVEL                             VARCHAR2,
    P_ORGANIZATION_ID                IN OUT NOCOPY VARCHAR2,
    P_ORGANIZATION_NAME                     VARCHAR2 default null,
    P_GEO_LEVEL                      IN OUT NOCOPY VARCHAR2,
    P_GEOGRAPHY_CODE                 IN OUT NOCOPY VARCHAR2,
    P_GEOGRAPHY_NAME                        VARCHAR2 default null,
    P_PROD_LEVEL                     IN OUT NOCOPY VARCHAR2,
    P_ITEM_CODE                      IN OUT NOCOPY VARCHAR2,
    P_ITEM                                  VARCHAR2 default null,
    P_FROM_DATE                      IN OUT NOCOPY VARCHAR2,
    P_TO_DATE                        IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

PROCEDURE Init_For_Standard(p_view_by             VARCHAR2,
			    p_org_level           VARCHAR2,
			    l_org_temp_id         VARCHAR2,
			    l_prod_level          VARCHAR2,
			    l_prod_code           VARCHAR2,
			    l_geo_level           VARCHAR2,
			    l_area_code           VARCHAR2,
			    l_view_by           OUT NOCOPY VARCHAR2,
			    l_org_level         OUT NOCOPY VARCHAR2,
			    l_sob_id            OUT NOCOPY VARCHAR2,
			    l_le_id             OUT NOCOPY VARCHAR2,
			    l_ou_id             OUT NOCOPY VARCHAR2,
			    l_org_id            OUT NOCOPY VARCHAR2,
			    l_pg_id             OUT NOCOPY VARCHAR2,
			    l_area_id           OUT NOCOPY VARCHAR2);

PROCEDURE RunReport;
PROCEDURE Build_Parameter_Form;
PROCEDURE Build_Java_Script(outstring IN OUT NOCOPY VARCHAR2);
PROCEDURE WIPBIUTZ_Parameter_PrintOrg(
                   param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
		   i IN NUMBER, l_org_level VARCHAR2, l_sob_id VARCHAR2,
		   l_le_id VARCHAR2, l_ou_id VARCHAR2, l_org_id VARCHAR2);
PROCEDURE WIPBIUTZ_Parameter_PrintGeo(
                   param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
                   i IN NUMBER, l_area_id VARCHAR2);
PROCEDURE WIPBIUTZ_Parameter_PrintCat(
                   param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
                   i IN NUMBER, l_pg_id VARCHAR2);
PROCEDURE WIPBIUTZ_Parameter_PrintTrgt(
                   param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
                   i IN NUMBER, l_plan_id VARCHAR2);
PROCEDURE WIPBIUTZ_Parameter_PrintDate(
                   param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
		   i IN NUMBER, l_date_from VARCHAR2, l_date_to VARCHAR2,
		   need_params_for_date BOOLEAN);
PROCEDURE WIPBIUTZ_Parameter_PrintViewby(
                   param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
                   i IN NUMBER, l_view_by VARCHAR2);

PROCEDURE Before_Parameter_WIPBIUTZ;
PROCEDURE After_Parameter_WIPBIUTZ;
PROCEDURE parameter_formview_wipbiutz(force_display IN VARCHAR2 DEFAULT NULL);
PROCEDURE Parameter_ActionView_WIPBIUTZ(
    P_ORG_LEVEL                             VARCHAR2,
    P_ORGANIZATION_ID                       VARCHAR2 default null,
    P_ORGANIZATION_NAME                     VARCHAR2 default null,
    P_SOB_NAME                              VARCHAR2 default null,
    P_LE_NAME                               VARCHAR2 default null,
    P_OU_NAME                               VARCHAR2 default null,
    P_GEOGRAPHY_CODE                        VARCHAR2 default null,
    P_GEOGRAPHY_NAME                        VARCHAR2 default null,
    P_ITEM_CODE                             VARCHAR2 default null,
    P_ITEM                                  VARCHAR2 default null,
    P_FROM_DATE                             VARCHAR2,
    P_TO_DATE                               VARCHAR2,
    P_TARGET                                VARCHAR2,
    P_VIEW_BY                               VARCHAR2);

PROCEDURE get_saved_params(l_plan_id OUT NOCOPY VARCHAR2,
			   l_org_level OUT NOCOPY VARCHAR2,
			   l_sob_id OUT NOCOPY VARCHAR2,
			   l_le_id OUT NOCOPY VARCHAR2,
			   l_ou_id OUT NOCOPY VARCHAR2,
			   l_org_id OUT NOCOPY VARCHAR2,
			   l_dept_id OUT NOCOPY VARCHAR2,
			   l_res_id OUT NOCOPY VARCHAR2,
			   l_geo_level OUT NOCOPY VARCHAR2,
			   l_area_id OUT NOCOPY VARCHAR2,
			   l_country_id OUT NOCOPY VARCHAR2,
			   l_region_id OUT NOCOPY VARCHAR2,
			   l_prod_level OUT NOCOPY VARCHAR2,
			   l_pg_id OUT NOCOPY VARCHAR2,
			   l_item_id OUT NOCOPY VARCHAR2,
			   l_date_from OUT NOCOPY VARCHAR2,
			   l_date_to OUT NOCOPY VARCHAR2,
			   l_view_by OUT NOCOPY VARCHAR2,
			   need_params_for_org OUT NOCOPY BOOLEAN,
			   need_params_for_geo OUT NOCOPY BOOLEAN,
			   need_params_for_prod OUT NOCOPY BOOLEAN,
			   need_params_for_date OUT NOCOPY BOOLEAN,
			   need_params_for_trgt OUT NOCOPY BOOLEAN,
			   need_params_for_view OUT NOCOPY BOOLEAN);

PROCEDURE run_report_wo_page(l_plan_id IN OUT NOCOPY VARCHAR2,
			     l_org_level IN OUT NOCOPY VARCHAR2,
			     l_sob_id IN OUT NOCOPY VARCHAR2,
			     l_le_id IN OUT NOCOPY VARCHAR2,
			     l_ou_id IN OUT NOCOPY VARCHAR2,
			     l_org_id IN OUT NOCOPY VARCHAR2,
			     l_dept_id IN OUT NOCOPY VARCHAR2,
			     l_res_id IN OUT NOCOPY VARCHAR2,
			     l_geo_level IN OUT NOCOPY VARCHAR2,
			     l_area_id IN OUT NOCOPY VARCHAR2,
			     l_country_id IN OUT NOCOPY VARCHAR2,
			     l_region_id IN OUT NOCOPY VARCHAR2,
			     l_prod_level IN OUT NOCOPY VARCHAR2,
			     l_pg_id IN OUT NOCOPY VARCHAR2,
			     l_item_id IN OUT NOCOPY VARCHAR2,
			     l_date_from IN OUT NOCOPY VARCHAR2,
			     l_date_to IN OUT NOCOPY VARCHAR2,
			     l_view_by IN OUT NOCOPY VARCHAR2);

END WIP_PARAMETER_WIPBIUTZ;

 

/
