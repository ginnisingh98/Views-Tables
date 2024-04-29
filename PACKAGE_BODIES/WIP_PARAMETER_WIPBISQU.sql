--------------------------------------------------------
--  DDL for Package Body WIP_PARAMETER_WIPBISQU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PARAMETER_WIPBISQU" as
/* $Header: wipbisqb.pls 120.1 2005/10/04 17:56:06 weizhou noship $ */

PROCEDURE error(P_FIELD IN VARCHAR2, P_ERROR_NO IN NUMBER) IS
BEGIN
  return;
END error;

FUNCTION Validate_Org(P_ORG_LEVEL         IN OUT NOCOPY VARCHAR2,
                      P_ORGANIZATION_ID   IN OUT NOCOPY VARCHAR2,
                      P_ORGANIZATION_NAME IN VARCHAR2 default null,
                      P_SET_OF_BOOKS      IN OUT NOCOPY VARCHAR2,
                      P_LEGAL_ENTITY      IN OUT NOCOPY VARCHAR2,
                      P_OPERATING_UNIT    IN OUT NOCOPY VARCHAR2,
                      P_INV_ORGANIZATION  IN OUT NOCOPY VARCHAR2
                      )
         RETURN BOOLEAN IS
BEGIN
        return FALSE;
END Validate_Org;

FUNCTION Validate_Geo(P_GEOGRAPHY_CODE   IN OUT NOCOPY VARCHAR2,
                      P_GEOGRAPHY_NAME   IN VARCHAR2 default null,
                      P_GEO_LEVEL        IN OUT NOCOPY VARCHAR2,
                      P_AREA             IN OUT NOCOPY VARCHAR2,
                      P_COUNTRY             IN OUT NOCOPY VARCHAR2,
                      P_REGION             IN OUT NOCOPY VARCHAR2
                      )
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
    P_ORG_LEVEL                      IN OUT NOCOPY VARCHAR2,
    P_ORGANIZATION_ID                IN OUT NOCOPY VARCHAR2,
    P_ORGANIZATION_NAME                     VARCHAR2 default null,
    P_SET_OF_BOOKS                   IN OUT NOCOPY VARCHAR2,
    P_LEGAL_ENTITY                   IN OUT NOCOPY VARCHAR2,
    P_OPERATING_UNIT                 IN OUT NOCOPY VARCHAR2,
    P_INV_ORGANIZATION               IN OUT NOCOPY VARCHAR2,
    P_GEO_LEVEL                      IN OUT NOCOPY VARCHAR2,
    P_GEOGRAPHY_CODE                 IN OUT NOCOPY VARCHAR2,
    P_GEOGRAPHY_NAME                        VARCHAR2 default null,
    P_AREA                           IN OUT NOCOPY VARCHAR2,
    P_COUNTRY                        IN OUT NOCOPY VARCHAR2,
    P_REGION                         IN OUT NOCOPY VARCHAR2,
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

PROCEDURE Before_Parameter_WIPBISQU IS
BEGIN
  return;
END Before_Parameter_WIPBISQU;

PROCEDURE After_Parameter_WIPBISQU IS
BEGIN
    NULL;
END After_Parameter_WIPBISQU;

PROCEDURE Build_Parameter_Form IS
BEGIN
    NULL;
END Build_Parameter_Form;

PROCEDURE Parameter_ActionView_WIPBISQU(
    P_ORG_LEVEL                             NUMBER,
    P_ORGANIZATION_ID                       VARCHAR2,
    P_ORGANIZATION_NAME                     VARCHAR2 default null,
    P_SOB_NAME                              VARCHAR2 default null,
    P_LE_NAME                               VARCHAR2 default null ,
    P_OU_NAME                               VARCHAR2 default null,
    P_TARGET                                VARCHAR2  default null,
    P_GEO_LEVEL                             NUMBER,
    P_GEOGRAPHY_CODE                        VARCHAR2  default null,
    P_GEOGRAPHY_NAME                        VARCHAR2 default null,
    P_ITEM_CODE                             VARCHAR2  default null,
    P_ITEM                                  VARCHAR2 default null,
    P_VIEW_BY                               VARCHAR2,
    P_FROM_DATE                             VARCHAR2  default null,
    P_TO_DATE                               VARCHAR2  default null) AS
BEGIN
  return;
END Parameter_ActionView_WIPBISQU;

PROCEDURE WIPBISQU_Parameter_PrintCat(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER) IS
BEGIN
  return;
END WIPBISQU_Parameter_PrintCat;

PROCEDURE WIPBISQU_Parameter_PrintGeo(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER) IS
BEGIN
  return;
END WIPBISQU_Parameter_PrintGeo;


PROCEDURE WIPBISQU_Parameter_PrintOrg(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER) IS
BEGIN
  return;
END WIPBISQU_Parameter_PrintOrg;

PROCEDURE WIPBISQU_Parameter_PrintView(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER) IS
BEGIN
  return;
END WIPBISQU_Parameter_PrintView;

PROCEDURE WIPBISQU_Parameter_PrintTrgt(
            param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
            i IN NUMBER) IS
BEGIN
  return;
END WIPBISQU_Parameter_PrintTrgt;

PROCEDURE WIPBISQU_Parameter_PrintDate(param IN OUT NOCOPY BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type,
                                       i IN NUMBER) IS
BEGIN
  return;
END WIPBISQU_Parameter_PrintDate;

PROCEDURE Parameter_FormView_WIPBISQU IS
BEGIN
  return;
END Parameter_FormView_WIPBISQU;

END WIP_PARAMETER_WIPBISQU;

/
