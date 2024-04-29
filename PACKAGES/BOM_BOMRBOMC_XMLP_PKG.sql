--------------------------------------------------------
--  DDL for Package BOM_BOMRBOMC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOMRBOMC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMRBOMCS.pls 120.0 2007/12/24 09:37:13 dwkrishn noship $ */
  P_BOM_OR_ENG VARCHAR2(3);

  P_PRINT_OPTION1 VARCHAR2(4);

  P_REVISION VARCHAR2(3);

  P_REVISION_DATE VARCHAR2(32767);

   LP_REVISION_DATE VARCHAR2(32767);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_ORGANIZATION_ID NUMBER;

  P_ORGANIZATION_NAME VARCHAR2(240);

  P_EXPLODE_OPTION_TYPE NUMBER;

  P_EXPLODE_OPTION VARCHAR2(40);

  P_EXPLOSION_QUANTITY NUMBER;

  P_EXPLOSION_LEVEL NUMBER;

  P_IMPL_FLAG NUMBER;

  P_IMPL VARCHAR2(4);

  P_RANGE_OPTION_TYPE NUMBER;

  P_RANGE_OPTION VARCHAR2(40);

  P_ITEM_ID NUMBER;

  P_SPECIFIC_ITEM VARCHAR2(81);

  P_ALTERNATE_DESG VARCHAR2(10);

  P_ITEM_FROM VARCHAR2(40);

  P_ITEM_TO VARCHAR2(40);

  P_CATEGORY_SET_ID NUMBER;

  P_CATEGORY_SET VARCHAR2(40);

  P_CATEGORY_FROM VARCHAR2(40);

  P_CATEGORY_TO VARCHAR2(40);

  P_CATEGORY_STRUCTURE_ID NUMBER;

  P_PRINT_OPTION1_FLAG NUMBER;

  P_GROUP_ID NUMBER;

  P_CAT_BETWEEN VARCHAR2(480);

  P_ASS_BETWEEN VARCHAR2(480);

  P_ITEM_STRUCTURE_ID NUMBER;

  P_ALT_OPTION_TYPE NUMBER;

  P_ALT_OPTION VARCHAR2(40);

  P_QTY_PRECISION NUMBER;

  P_ORDER_BY_TYPE NUMBER;

  P_SEQUENCE_ID NUMBER := 0;

  P_ORDER_BY VARCHAR2(40);

  P_MSG_BUF VARCHAR2(80);

  P_ERR_MSG VARCHAR2(80);

  P_PLAN_FACTOR_FLAG NUMBER;

  P_PLAN_FACTOR VARCHAR2(4);

  P_DEBUG VARCHAR2(2);

  FUNCTION g_filter RETURN boolean;

  FUNCTION GET_REV(D3_COMPO_ORG_ID IN NUMBER
                  ,D3_COMPONENT_ITEM_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION GET_ELE_DESC(M_BOM_ITEM_TYPE IN NUMBER
                       ,D2_ELEMENT_NAME IN VARCHAR2
                       ,M_ITEM_CATALOG_GROUP_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  PROCEDURE EXPLODER_USEREXIT(VERIFY_FLAG IN NUMBER
                             ,ORG_ID IN NUMBER
                             ,ORDER_BY IN NUMBER
                             ,GRP_ID IN NUMBER
                             ,SESSION_ID IN NUMBER
                             ,LEVELS_TO_EXPLODE IN NUMBER
                             ,BOM_OR_ENG IN NUMBER
                             ,IMPL_FLAG IN NUMBER
                             ,PLAN_FACTOR_FLAG IN NUMBER
                             ,EXPLODE_OPTION IN NUMBER
                             ,MODULE IN NUMBER
                             ,CST_TYPE_ID IN NUMBER
                             ,STD_COMP_FLAG IN NUMBER
                             ,EXPL_QTY IN NUMBER
                             ,ITEM_ID IN NUMBER
                             ,ALT_DESG IN VARCHAR2
                             ,COMP_CODE IN VARCHAR2
                             ,REV_DATE IN VARCHAR2
                             ,ERR_MSG OUT NOCOPY VARCHAR2
                             ,ERROR_CODE OUT NOCOPY NUMBER);

  PROCEDURE EXPLOSION_REPORT(VERIFY_FLAG IN NUMBER
                            ,ORG_ID IN NUMBER
                            ,ORDER_BY IN NUMBER
                            ,LIST_ID IN NUMBER
                            ,GRP_ID IN NUMBER
                            ,SESSION_ID IN NUMBER
                            ,LEVELS_TO_EXPLODE IN NUMBER
                            ,BOM_OR_ENG IN NUMBER
                            ,IMPL_FLAG IN NUMBER
                            ,PLAN_FACTOR_FLAG IN NUMBER
                            ,INCL_LT_FLAG IN NUMBER
                            ,EXPLODE_OPTION IN NUMBER
                            ,MODULE IN NUMBER
                            ,CST_TYPE_ID IN NUMBER
                            ,STD_COMP_FLAG IN NUMBER
                            ,EXPL_QTY IN NUMBER
                            ,REPORT_OPTION IN NUMBER
                            ,REQ_ID IN NUMBER
                            ,CST_RLP_ID IN NUMBER
                            ,LOCK_FLAG IN NUMBER
                            ,ROLLUP_OPTION IN NUMBER
                            ,ALT_RTG_DESG IN VARCHAR2
                            ,ALT_DESG IN VARCHAR2
                            ,REV_DATE IN VARCHAR2
                            ,ERR_MSG OUT NOCOPY VARCHAR2
                            ,ERROR_CODE OUT NOCOPY NUMBER);

  PROCEDURE EXPLODERS(VERIFY_FLAG IN NUMBER
                     ,ONLINE_FLAG IN NUMBER
                     ,ORG_ID IN NUMBER
                     ,ORDER_BY IN NUMBER
                     ,GRP_ID IN NUMBER
                     ,SESSION_ID IN NUMBER
                     ,L_LEVELS_TO_EXPLODE IN NUMBER
                     ,BOM_OR_ENG IN NUMBER
                     ,IMPL_FLAG IN NUMBER
                     ,PLAN_FACTOR_FLAG IN NUMBER
                     ,INCL_LT_FLAG IN NUMBER
                     ,L_EXPLODE_OPTION IN NUMBER
                     ,MODULE IN NUMBER
                     ,CST_TYPE_ID IN NUMBER
                     ,STD_COMP_FLAG IN NUMBER
                     ,REV_DATE IN VARCHAR2
                     ,ERR_MSG OUT NOCOPY VARCHAR2
                     ,ERROR_CODE OUT NOCOPY NUMBER);

  PROCEDURE LOOPSTR2MSG(GRP_ID IN NUMBER
                       ,VERIFY_MSG OUT NOCOPY VARCHAR2);

END BOM_BOMRBOMC_XMLP_PKG;


/
