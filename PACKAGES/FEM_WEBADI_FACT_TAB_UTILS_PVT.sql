--------------------------------------------------------
--  DDL for Package FEM_WEBADI_FACT_TAB_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_WEBADI_FACT_TAB_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVADIFCTRUTILS.pls 120.1 2008/02/20 06:49:12 jcliving noship $ */

PROCEDURE UPLOAD_FACTOR_TABLE1_INTERFACE(
P_RULE_NAME                        VARCHAR2,
P_FOLDER_NAME                      VARCHAR2,
P_RULE_DESCRIPTION                 VARCHAR2,
P_VERSION_NAME                     VARCHAR2,
P_START_DATE                       VARCHAR2,
P_END_DATE                         VARCHAR2,
P_VERSION_DESCRIPTION              VARCHAR2,
P_FACTOR_TYPE                      VARCHAR2,
P_MATCHING_DIM1                    VARCHAR2,
P_HIERARCHY1                       VARCHAR2,
P_HIER1_VER                        VARCHAR2,
P_LEVEL1                           VARCHAR2,
P_HIERARCHY_REL1                   VARCHAR2,
P_MATCHING_DIM2                    VARCHAR2,
P_HIERARCHY2                       VARCHAR2,
P_HIER2_VER                        VARCHAR2,
P_LEVEL2                           VARCHAR2,
P_HIERARCHY_REL2                   VARCHAR2,
P_MATCHING_DIM3                    VARCHAR2,
P_HIERARCHY3                       VARCHAR2,
P_HIER3_VER                        VARCHAR2,
P_LEVEL3                           VARCHAR2,
P_HIERARCHY_REL3                   VARCHAR2,
P_DISTRIBUTION_DIM                 VARCHAR2,
P_FORCE_TO_HUNDRED                 VARCHAR2,
P_OBJECT_ACCESS_CODE               VARCHAR2,
P_MATCHING_DIM1_MEM                VARCHAR2,
P_MATCHING_DIM2_MEM                VARCHAR2,
P_MATCHING_DIM3_MEM                VARCHAR2,
P_DISTRIBUTION_DIM_MEM             VARCHAR2,
P_AMOUNT                           VARCHAR2);

PROCEDURE UPLOAD_FACTOR_TABLE2_INTERFACE(
P_RULE_NAME                        VARCHAR2,
P_FOLDER_NAME                      VARCHAR2,
P_RULE_DESCRIPTION                 VARCHAR2,
P_VERSION_NAME                     VARCHAR2,
P_START_DATE                       VARCHAR2,
P_END_DATE                         VARCHAR2,
P_VERSION_DESCRIPTION              VARCHAR2,
P_FACTOR_TYPE                      VARCHAR2,
P_MATCHING_DIM1                    VARCHAR2,
P_HIERARCHY1                       VARCHAR2,
P_HIER1_VER                        VARCHAR2,
P_LEVEL1                           VARCHAR2,
P_HIERARCHY_REL1                   VARCHAR2,
P_MATCHING_DIM2                    VARCHAR2,
P_HIERARCHY2                       VARCHAR2,
P_HIER2_VER                        VARCHAR2,
P_LEVEL2                           VARCHAR2,
P_HIERARCHY_REL2                   VARCHAR2,
P_MATCHING_DIM3                    VARCHAR2,
P_HIERARCHY3                       VARCHAR2,
P_HIER3_VER                        VARCHAR2,
P_LEVEL3                           VARCHAR2,
P_HIERARCHY_REL3                   VARCHAR2,
P_FORCE_TO_HUNDRED                 VARCHAR2,
P_OBJECT_ACCESS_CODE               VARCHAR2,
P_MATCHING_DIM1_MEM                VARCHAR2,
P_MATCHING_DIM2_MEM                VARCHAR2,
P_MATCHING_DIM3_MEM                VARCHAR2,
P_AMOUNT                           VARCHAR2);

PROCEDURE UPLOAD_FACTOR_TABLE3_INTERFACE(
P_RULE_NAME                        VARCHAR2,
P_FOLDER_NAME                      VARCHAR2,
P_RULE_DESCRIPTION                 VARCHAR2,
P_VERSION_NAME                     VARCHAR2,
P_START_DATE                       VARCHAR2,
P_END_DATE                         VARCHAR2,
P_VERSION_DESCRIPTION              VARCHAR2,
P_FACTOR_TYPE                      VARCHAR2,
P_DISTRIBUTION_DIM                 VARCHAR2,
P_FORCE_TO_HUNDRED                 VARCHAR2,
P_OBJECT_ACCESS_CODE               VARCHAR2,
P_DISTRIBUTION_DIM_MEM             VARCHAR2,
P_AMOUNT                           VARCHAR2);

PROCEDURE POPULATE_RULE_DETAILS(
P_RULE_NAME                        VARCHAR2,
P_FOLDER_NAME                      VARCHAR2,
P_RULE_DESCRIPTION                 VARCHAR2,
P_VERSION_NAME                     VARCHAR2,
P_START_DATE                       VARCHAR2,
P_END_DATE                         VARCHAR2,
P_VERSION_DESCRIPTION              VARCHAR2,
P_VS_COMBO_ID                      VARCHAR2,
P_OBJECT_ACCESS_CODE               VARCHAR2);

PROCEDURE POPULATE_FACTOR_TABLE_DIMS(
P_VERSION_NAME                     VARCHAR2,
P_FACTOR_TYPE                      VARCHAR2,
P_MATCHING_DIM1                    VARCHAR2,
P_HIERARCHY1                       VARCHAR2,
P_HIER1_VER                        VARCHAR2,
P_LEVEL1                           VARCHAR2,
P_HIERARCHY_REL1                   VARCHAR2,
P_MATCHING_DIM2                    VARCHAR2,
P_HIERARCHY2                       VARCHAR2,
P_HIER2_VER                        VARCHAR2,
P_LEVEL2                           VARCHAR2,
P_HIERARCHY_REL2                   VARCHAR2,
P_MATCHING_DIM3                    VARCHAR2,
P_HIERARCHY3                       VARCHAR2,
P_HIER3_VER                        VARCHAR2,
P_LEVEL3                           VARCHAR2,
P_HIERARCHY_REL3                   VARCHAR2,
P_DISTRIBUTION_DIM                 VARCHAR2,
P_FORCE_TO_HUNDRED                 VARCHAR2);


END FEM_WEBADI_FACT_TAB_UTILS_PVT;


/
