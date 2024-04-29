--------------------------------------------------------
--  DDL for Package PA_FP_COMMITMENT_AMOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_COMMITMENT_AMOUNTS" AUTHID CURRENT_USER as
/* $Header: PAFPCMTS.pls 120.1 2005/08/19 16:25:27 mwasowic noship $ */

PROCEDURE GET_COMMITMENT_AMTS
          (P_PROJECT_ID                     IN              PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN              PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           PX_GEN_RES_ASG_ID_TAB            IN OUT          NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
           PX_DELETED_RES_ASG_ID_TAB        IN OUT          NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,   --File.Sql.39 bug 4440895
           X_RETURN_STATUS                  OUT   NOCOPY    VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY    NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY    VARCHAR2);

 END PA_FP_COMMITMENT_AMOUNTS;

 

/
