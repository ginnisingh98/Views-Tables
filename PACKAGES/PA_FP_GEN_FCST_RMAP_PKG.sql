--------------------------------------------------------
--  DDL for Package PA_FP_GEN_FCST_RMAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_GEN_FCST_RMAP_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPFGRS.pls 120.0 2005/06/03 13:27:18 appldev noship $ */
PROCEDURE FCST_SRC_TXNS_RMAP
          ( P_PROJECT_ID         IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
            P_BUDGET_VERSION_ID  IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
            P_FP_COLS_REC        IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
            X_RETURN_STATUS      OUT  NOCOPY   VARCHAR2,
            X_MSG_COUNT          OUT  NOCOPY   NUMBER,
            X_MSG_DATA	         OUT  NOCOPY   VARCHAR2 );

END PA_FP_GEN_FCST_RMAP_PKG;

 

/
