--------------------------------------------------------
--  DDL for Package Body WIP_PARAMETER_WIPBIUTZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PARAMETER_WIPBIUTZ" as
/* $Header: wipbiupb.pls 120.1 2005/10/04 17:56:30 weizhou noship $ */

PROCEDURE error(P_FIELD IN VARCHAR2) IS
BEGIN
  return;
END error;

FUNCTION Validate_Org(P_ORG_LEVEL         IN VARCHAR2,
                      P_ORGANIZATION_ID   IN OUT NOCOPY VARCHAR2,
                      P_ORGANIZATION_NAME IN VARCHAR2 default null)
         RETURN BOOLEAN IS
BEGIN
    return FALSE;
END Validate_Org;

FUNCTION Validate_Geo(P_GEOGRAPHY_CODE   IN OUT NOCOPY VARCHAR2,
                      P_GEOGRAPHY_NAME   IN VARCHAR2 default null,
                      P_GEO_LEVEL        IN OUT NOCOPY VARCHAR2)
         RETURN BOOLEAN IS
BEGIN
        return FALSE;
END Validate_Geo;

FUNCTION Validate_Cat(P_ITEM_CODE               IN OUT NOCOPY VARCHAR2,
                      P_ITEM                    IN VARCHAR2 default null,
                      P_PROD_LEVEL              IN OUT NOCOPY VARCHAR2)
         RETURN BOOLEAN IS
BEGIN
        return FALSE;
END Validate_Cat;

FUNCTION Validate_Date(P_FROM_DATE       IN OUT NOCOPY VARCHAR2,
                       P_TO_DATE         IN OUT NOCOPY VARCHAR2)
         RETURN BOOLEAN IS
BEGIN
        return FALSE;
END Validate_Date;

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
    P_TO_DATE                        IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
BEGIN
        return FALSE;
END Validate_Parameters;

PROCEDURE RunReport IS
BEGIN
    NULL;
END RunReport;

PROCEDURE Build_Java_Script (outstring IN OUT NOCOPY VARCHAR2) IS
BEGIN
  return;
END Build_Java_Script;

/* You can put the code that you nomally put in the BeforeParameter Trigger
   in the default report parameter here
 */
PROCEDURE Before_Parameter_WIPBIUTZ IS
  l_org_id  NUMBER;
BEGIN
  return;
END Before_Parameter_WIPBIUTZ;

PROCEDURE After_Parameter_WIPBIUTZ IS
BEGIN
    NULL;
END After_Parameter_WIPBIUTZ;

PROCEDURE Build_Parameter_Form IS
BEGIN
    NULL;
END Build_Parameter_Form;

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
    P_VIEW_BY                               VARCHAR2) IS
BEGIN
  return;
END Parameter_ActionView_WIPBIUTZ;

/* Init_For_Standard
   -----------------
  Assigns appropriate values to local vars in order to construct URL
  that fits new standards.
*/
PROCEDURE Init_For_Standard(p_view_by            VARCHAR2,
                            p_org_level          VARCHAR2,
                            l_org_temp_id        VARCHAR2,
                            l_prod_level         VARCHAR2,
                            l_prod_code          VARCHAR2,
                            l_geo_level          VARCHAR2,
                            l_area_code          VARCHAR2,
                            l_view_by           OUT NOCOPY VARCHAR2,
                            l_org_level         OUT NOCOPY VARCHAR2,
                            l_sob_id            OUT NOCOPY VARCHAR2,
                            l_le_id             OUT NOCOPY VARCHAR2,
                            l_ou_id             OUT NOCOPY VARCHAR2,
                            l_org_id            OUT NOCOPY VARCHAR2,
                            l_pg_id             OUT NOCOPY VARCHAR2,
                            l_area_id           OUT NOCOPY VARCHAR2)
    IS
BEGIN
  return;
END Init_For_Standard;

PROCEDURE WIPBIUTZ_Parameter_PrintCat(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER, l_pg_id VARCHAR2) IS
BEGIN
  return;
END WIPBIUTZ_Parameter_PrintCat;

PROCEDURE WIPBIUTZ_Parameter_PrintGeo(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER, l_area_id VARCHAR2) IS
BEGIN
  return;
END WIPBIUTZ_Parameter_PrintGeo;


PROCEDURE WIPBIUTZ_Parameter_PrintOrg(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
                                      i IN NUMBER, l_org_level VARCHAR2,
                                      l_sob_id VARCHAR2, l_le_id VARCHAR2,
                                      l_ou_id VARCHAR2, l_org_id VARCHAR2
                                      ) IS
BEGIN
  return;
END WIPBIUTZ_Parameter_PrintOrg;

PROCEDURE WIPBIUTZ_Parameter_PrintViewby(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER, l_view_by VARCHAR2) IS
BEGIN
  return;
END WIPBIUTZ_Parameter_PrintViewby;

PROCEDURE WIPBIUTZ_Parameter_PrintTrgt(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER, l_plan_id VARCHAR2) IS
BEGIN
  return;
END WIPBIUTZ_Parameter_PrintTrgt;

PROCEDURE WIPBIUTZ_Parameter_PrintDate(param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
                                       i IN NUMBER,
                                       l_date_from VARCHAR2,
                                       l_date_to VARCHAR2,
                                       need_params_for_date BOOLEAN) IS
BEGIN
  return;
END WIPBIUTZ_Parameter_PrintDate;

/*
  This is where everything starts.  This is the procedure that is seeded
  in seed115 for the function BIS_WIPBIUZ.  It paints the parameter page.
 */
PROCEDURE Parameter_FormView_WIPBIUTZ(force_display IN VARCHAR2 DEFAULT NULL)
    IS
BEGIN
  return;
END Parameter_FormView_WIPBIUTZ;

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
                           need_params_for_view OUT NOCOPY BOOLEAN) IS
BEGIN
  return;
END get_saved_params;

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
                             l_view_by IN OUT NOCOPY VARCHAR2) IS
BEGIN
  return;
END run_report_wo_page;

END WIP_PARAMETER_WIPBIUTZ;

/
