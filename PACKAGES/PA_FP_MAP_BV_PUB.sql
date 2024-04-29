--------------------------------------------------------
--  DDL for Package PA_FP_MAP_BV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_MAP_BV_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPMBTS.pls 120.0 2005/05/30 17:25:45 appldev noship $ */

PROCEDURE  GEN_MAP_BV_TO_TARGET_RL
          (P_SOURCE_BV_ID 	    IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TARGET_FP_COLS_REC     IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_FP_COLS_REC        IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_CB_FP_COLS_REC         IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_COMMIT_FLAG            IN            VARCHAR2 DEFAULT 'N',
           P_INIT_MSG_FLAG          IN            VARCHAR2 DEFAULT 'Y',
           P_ACTUAL_THRU_DATE       IN            PA_PERIODS_ALL.END_DATE%TYPE DEFAULT null,
           X_RETURN_STATUS          OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT              OUT  NOCOPY NUMBER,
           X_MSG_DATA	            OUT  NOCOPY VARCHAR2);

PROCEDURE MAINTAIN_RBS_DTLS
          (P_BUDGET_VERSION_ID     IN   PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC           IN   PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           X_RETURN_STATUS         OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT             OUT  NOCOPY NUMBER,
           X_MSG_DATA	           OUT  NOCOPY VARCHAR2);


END PA_FP_MAP_BV_PUB;

 

/
