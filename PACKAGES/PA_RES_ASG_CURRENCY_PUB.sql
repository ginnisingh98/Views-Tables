--------------------------------------------------------
--  DDL for Package PA_RES_ASG_CURRENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_ASG_CURRENCY_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPRBCS.pls 120.1 2007/02/06 10:10:17 dthakker noship $ */

-- Public P_CALLING_MODULE values
-- NOTE: When adding new calling modules below, the IS_PUBLIC_CALLING_MODULE()
--       function in PAFPRBCB.pls needs to be updated with the new module as well.
G_BUDGET_GENERATION            CONSTANT VARCHAR2(30) := 'BUDGET_GENERATION';
G_FORECAST_GENERATION          CONSTANT VARCHAR2(30) := 'FORECAST_GENERATION';
G_CALCULATE_API                CONSTANT VARCHAR2(30) := 'CALCULATE_API';
G_UPDATE_PLAN_TRANSACTION      CONSTANT VARCHAR2(30) := 'UPDATE_PLAN_TRANSACTION';
G_WORKPLAN                     CONSTANT VARCHAR2(30) := 'WORKPLAN';
G_AMG_API                      CONSTANT VARCHAR2(30) := 'AMG_API';
G_WEBADI                       CONSTANT VARCHAR2(30) := 'WEBADI';
G_CHANGE_MGT                   CONSTANT VARCHAR2(30) := 'CHANGE_MGT';
G_COPY_PLAN                    CONSTANT VARCHAR2(30) := 'COPY_PLAN';
G_UPGRADE                      CONSTANT VARCHAR2(30) := 'UPGRADE';

-- Valid P_COPY_MODE values
G_COPY_ALL                     CONSTANT VARCHAR2(30) := 'COPY_ALL';
G_COPY_OVERRIDES               CONSTANT VARCHAR2(30) := 'COPY_OVERRIDES';

PROCEDURE MAINTAIN_DATA
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_DELETE_FLAG                  IN           VARCHAR2 DEFAULT 'N',
          P_COPY_FLAG                    IN           VARCHAR2 DEFAULT 'N',
          P_SRC_VERSION_ID               IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE DEFAULT NULL,
          P_COPY_MODE                    IN           VARCHAR2 DEFAULT 'COPY_OVERRIDES',
          P_ROLLUP_FLAG                  IN           VARCHAR2 DEFAULT 'N',
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2 DEFAULT 'N',
          P_CALLED_MODE                  IN           VARCHAR2 DEFAULT 'SELF_SERVICE',
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2);

END PA_RES_ASG_CURRENCY_PUB;

/
