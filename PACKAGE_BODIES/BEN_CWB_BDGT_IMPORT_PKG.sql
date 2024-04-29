--------------------------------------------------------
--  DDL for Package Body BEN_CWB_BDGT_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_BDGT_IMPORT_PKG" as
/* $Header: bencwbbsim.pkb 120.0 2005/05/28 12:46 appldev noship $ */

g_package  Varchar2(30) := 'BEN_CWB_BDGT_IMPORT_PKG.';
g_debug boolean := hr_utility.debug_enabled;

PROCEDURE handle_row
(  P_GROUP_PL_ID                               IN NUMBER      DEFAULT NULL
  ,P_GROUP_PER_IN_LER_ID                       IN VARCHAR2    DEFAULT NULL
  ,P_GROUP_OIPL_ID                             IN VARCHAR2    DEFAULT NULL
  ,P_DUE_DT                                    IN DATE        DEFAULT NULL
  ,P_ACCESS_CD                                 IN VARCHAR2    DEFAULT NULL
  ,P_WS_BDGT_VAL_LAST_UPD_DATE                 IN DATE        DEFAULT NULL
  ,P_DIST_BDGT_VAL_LAST_UPD_DATE               IN DATE        DEFAULT NULL
  ,P_WS_BDGT_VAL_LAST_UPD_BY                   IN NUMBER      DEFAULT NULL
  ,P_DIST_BDGT_VAL_LAST_UPD_BY                 IN NUMBER      DEFAULT NULL
  ,P_OBJECT_VERSION_NUMBER                     IN VARCHAR2    DEFAULT NULL
  ,P_PERSON_ID                                 IN VARCHAR2    DEFAULT NULL
  ,P_FULL_NAME                                 IN VARCHAR2  DEFAULT NULL
  ,P_EMPLOYEE_NUMBER                           IN VARCHAR2  DEFAULT NULL
  ,P_JOB_NAME                                  IN VARCHAR2  DEFAULT NULL
  ,P_LVL_NUM                                   IN NUMBER    DEFAULT NULL
  ,P_UNITS                                     IN VARCHAR2  DEFAULT NULL
  ,P_BDGT_ISS_DATE                             IN DATE      DEFAULT NULL
  ,P_ELIG_COUNT                                IN NUMBER    DEFAULT NULL
  ,P_ELIG_COUNT_DIRECT                         IN NUMBER    DEFAULT NULL
  ,P_ELIG_COUNT_INDIRECT                       IN NUMBER    DEFAULT NULL
  ,P_ELIG_SAL_VAL_IN_PL_UOM                    IN NUMBER    DEFAULT NULL
  ,P_PCT_OF_ELIG_SALS                          IN NUMBER    DEFAULT NULL
  ,P_BDGT_AMT_IN_PL_UOM                        IN NUMBER    DEFAULT NULL
  ,P_ISS_BDGT_AMT_IN_PL_UOM                    IN NUMBER    DEFAULT NULL
  ,P_MISC1_VAL_IN_PL_UOM                       IN NUMBER    DEFAULT NULL
  ,P_MISC2_VAL_IN_PL_UOM                       IN NUMBER    DEFAULT NULL
  ,P_MISC3_VAL_IN_PL_UOM                       IN NUMBER    DEFAULT NULL
  ,P_STAT_SAL_VAL_IN_PL_UOM                    IN NUMBER    DEFAULT NULL
  ,P_TOT_COMP_VAL_IN_PL_UOM                    IN NUMBER    DEFAULT NULL
  ,P_OTH_COMP_VAL_IN_PL_UOM                    IN NUMBER    DEFAULT NULL
  ,P_REC_VAL_IN_PL_UOM                         IN NUMBER    DEFAULT NULL
  ,P_REC_MN_VAL_IN_PL_UOM                      IN NUMBER    DEFAULT NULL
  ,P_REC_MX_VAL_IN_PL_UOM                      IN NUMBER    DEFAULT NULL
  ,P_BDGT_RNDG_CD                              IN VARCHAR2  DEFAULT NULL
  ,P_BDGT_NNMNTRY_UOM                          IN VARCHAR2  DEFAULT NULL
  ,P_MGR_PER_IN_LER_ID                         IN NUMBER    DEFAULT NULL
  ,P_USER_ID                                   IN VARCHAR2  DEFAULT NULL
) IS
BEGIN
 null;
END;

END BEN_CWB_BDGT_IMPORT_PKG;


/
