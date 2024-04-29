--------------------------------------------------------
--  DDL for Package PA_PROGRESS_ROLLUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROGRESS_ROLLUP_PKG" AUTHID CURRENT_USER as
/* $Header: PAPRPKGS.pls 120.1 2005/08/19 16:44:31 mwasowic noship $ */

procedure INSERT_ROW(
  X_PROGRESS_ROLLUP_ID              IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,X_PROJECT_ID                      IN NUMBER
 ,X_OBJECT_ID                       IN NUMBER
 ,X_OBJECT_TYPE                     IN VARCHAR2
 ,X_AS_OF_DATE                      IN DATE
 ,X_OBJECT_VERSION_ID               IN NUMBER
 ,X_LAST_UPDATE_DATE                IN  DATE
 ,X_LAST_UPDATED_BY                 IN NUMBER
 ,X_CREATION_DATE                   IN DATE
 ,X_CREATED_BY                      IN NUMBER
 ,X_PROGRESS_STATUS_CODE            IN VARCHAR2
 ,X_LAST_UPDATE_LOGIN               IN NUMBER
 ,X_INCREMENTAL_WORK_QTY            IN NUMBER
 ,X_CUMULATIVE_WORK_QTY             IN NUMBER
 ,X_BASE_PERCENT_COMPLETE           IN NUMBER
 ,X_EFF_ROLLUP_PERCENT_COMP         IN NUMBER
 ,X_COMPLETED_PERCENTAGE            IN NUMBER
 ,X_ESTIMATED_START_DATE            IN DATE
 ,X_ESTIMATED_FINISH_DATE           IN DATE
 ,X_ACTUAL_START_DATE               IN DATE
 ,X_ACTUAL_FINISH_DATE              IN DATE
 ,X_EST_REMAINING_EFFORT            IN NUMBER
 ,X_BASE_PERCENT_COMP_DERIV_CODE    IN VARCHAR2
 ,X_BASE_PROGRESS_STATUS_CODE       IN VARCHAR2
 ,X_EFF_ROLLUP_PROG_STAT_CODE       IN VARCHAR2
 ,x_percent_complete_id             in number
 ,X_STRUCTURE_TYPE        		IN VARCHAR2
 ,X_PROJ_ELEMENT_ID 			IN NUMBER
 ,X_STRUCTURE_VERSION_ID 		IN NUMBER
 ,X_PPL_ACT_EFFORT_TO_DATE  	IN NUMBER
 ,X_EQPMT_ACT_EFFORT_TO_DATE 	IN NUMBER
 ,X_EQPMT_ETC_EFFORT 			IN NUMBER
 ,X_OTH_ACT_COST_TO_DATE_TC 		IN NUMBER
 ,X_OTH_ACT_COST_TO_DATE_FC             IN NUMBER
 ,X_OTH_ACT_COST_TO_DATE_PC             IN NUMBER
 ,X_OTH_ETC_COST_TC			    IN NUMBER
 ,X_OTH_ETC_COST_FC                         IN NUMBER
 ,X_OTH_ETC_COST_PC                         IN NUMBER
 ,X_PPL_ACT_COST_TO_DATE_TC 	IN NUMBER
 ,X_PPL_ACT_COST_TO_DATE_FC         IN NUMBER
 ,X_PPL_ACT_COST_TO_DATE_PC         IN NUMBER
 ,X_PPL_ETC_COST_TC			IN NUMBER
 ,X_PPL_ETC_COST_FC                     IN NUMBER
 ,X_PPL_ETC_COST_PC                     IN NUMBER
 ,X_EQPMT_ACT_COST_TO_DATE_TC       IN NUMBER
 ,X_EQPMT_ACT_COST_TO_DATE_FC       IN NUMBER
 ,X_EQPMT_ACT_COST_TO_DATE_PC       IN NUMBER
 ,X_EQPMT_ETC_COST_TC 			IN NUMBER
 ,X_EQPMT_ETC_COST_FC                   IN NUMBER
 ,X_EQPMT_ETC_COST_PC                   IN NUMBER
 ,X_EARNED_VALUE 			IN NUMBER
 ,X_TASK_WT_BASIS_CODE 			IN VARCHAR2
 ,X_SUBPRJ_PPL_ACT_EFFORT 		IN NUMBER
 ,X_SUBPRJ_EQPMT_ACT_EFFORT 		IN NUMBER
 ,X_SUBPRJ_PPL_ETC_EFFORT 		IN NUMBER
 ,X_SUBPRJ_EQPMT_ETC_EFFORT 		IN NUMBER
 ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC      IN NUMBER
 ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC      IN NUMBER
 ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC      IN NUMBER
 ,X_SUBPRJ_PPL_ACT_COST_TC 		IN NUMBER
 ,X_SUBPRJ_PPL_ACT_COST_FC             IN NUMBER
 ,X_SUBPRJ_PPL_ACT_COST_PC             IN NUMBER
 ,X_SUBPRJ_EQPMT_ACT_COST_TC 	       IN NUMBER
 ,X_SUBPRJ_EQPMT_ACT_COST_FC           IN NUMBER
 ,X_SUBPRJ_EQPMT_ACT_COST_PC           IN NUMBER
 ,X_SUBPRJ_OTH_ETC_COST_TC 		       IN NUMBER
 ,X_SUBPRJ_OTH_ETC_COST_FC                 IN NUMBER
 ,X_SUBPRJ_OTH_ETC_COST_PC                 IN NUMBER
 ,X_SUBPRJ_PPL_ETC_COST_TC 	       IN NUMBER
 ,X_SUBPRJ_PPL_ETC_COST_FC             IN NUMBER
 ,X_SUBPRJ_PPL_ETC_COST_PC             IN NUMBER
 ,X_SUBPRJ_EQPMT_ETC_COST_TC 	       IN NUMBER
 ,X_SUBPRJ_EQPMT_ETC_COST_FC           IN NUMBER
 ,X_SUBPRJ_EQPMT_ETC_COST_PC           IN NUMBER
 ,X_SUBPRJ_EARNED_VALUE	 	       IN NUMBER
 ,X_CURRENT_FLAG		        IN VARCHAR2
,X_PROJFUNC_COST_RATE_TYPE		VARCHAR2
,X_PROJFUNC_COST_EXCHANGE_RATE		NUMBER
,X_PROJFUNC_COST_RATE_DATE		DATE
,X_PROJ_COST_RATE_TYPE			VARCHAR2
,X_PROJ_COST_EXCHANGE_RATE		NUMBER
,X_PROJ_COST_RATE_DATE			DATE
,X_TXN_CURRENCY_CODE			VARCHAR2
,X_PROG_PA_PERIOD_NAME			VARCHAR2
,X_PROG_GL_PERIOD_NAME			VARCHAR2
,X_OTH_QUANTITY_TO_DATE			NUMBER
,X_OTH_ETC_QUANTITY			NUMBER
,X_OTH_ACT_RAWCOST_TO_DATE_TC		IN NUMBER
,X_OTH_ACT_RAWCOST_TO_DATE_FC		IN NUMBER
,X_OTH_ACT_RAWCOST_TO_DATE_PC		IN NUMBER
,X_OTH_ETC_RAWCOST_TC		IN NUMBER
,X_OTH_ETC_RAWCOST_FC		IN NUMBER
,X_OTH_ETC_RAWCOST_PC		IN NUMBER
,X_PPL_ACT_RAWCOST_TO_DATE_TC		IN NUMBER
,X_PPL_ACT_RAWCOST_TO_DATE_FC		IN NUMBER
,X_PPL_ACT_RAWCOST_TO_DATE_PC		IN NUMBER
,X_PPL_ETC_RAWCOST_TC		IN NUMBER
,X_PPL_ETC_RAWCOST_FC		IN NUMBER
,X_PPL_ETC_RAWCOST_PC		IN NUMBER
,X_EQPMT_ACT_RAWCOST_TO_DATE_TC		IN NUMBER
,X_EQPMT_ACT_RAWCOST_TO_DATE_FC		IN NUMBER
,X_EQPMT_ACT_RAWCOST_TO_DATE_PC		IN NUMBER
,X_EQPMT_ETC_RAWCOST_TC		IN NUMBER
,X_EQPMT_ETC_RAWCOST_FC		IN NUMBER
,X_EQPMT_ETC_RAWCOST_PC		IN NUMBER
,X_SP_OTH_ACT_RAWCOST_TODATE_TC		IN NUMBER
,X_SP_OTH_ACT_RAWCOST_TODATE_FC		IN NUMBER
,X_SP_OTH_ACT_RAWCOST_TODATE_PC		IN NUMBER
,X_SUBPRJ_PPL_ACT_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_PPL_ACT_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_PPL_ACT_RAWCOST_PC		IN NUMBER
,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC		IN NUMBER
,X_SUBPRJ_OTH_ETC_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_OTH_ETC_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_OTH_ETC_RAWCOST_PC		IN NUMBER
,X_SUBPRJ_PPL_ETC_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_PPL_ETC_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_PPL_ETC_RAWCOST_PC		IN NUMBER
,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC		IN NUMBER
);

procedure UPDATE_ROW(
  X_PROGRESS_ROLLUP_ID              IN NUMBER
 ,X_PROJECT_ID                      IN NUMBER
 ,X_OBJECT_ID                       IN NUMBER
 ,X_OBJECT_TYPE                     IN VARCHAR2
 ,X_AS_OF_DATE                      IN DATE
 ,X_OBJECT_VERSION_ID               IN NUMBER
 ,X_LAST_UPDATE_DATE                IN  DATE
 ,X_LAST_UPDATED_BY                 IN NUMBER
 ,X_PROGRESS_STATUS_CODE            IN VARCHAR2
 ,X_LAST_UPDATE_LOGIN               IN NUMBER
 ,X_INCREMENTAL_WORK_QTY            IN NUMBER
 ,X_CUMULATIVE_WORK_QTY             IN NUMBER
 ,X_BASE_PERCENT_COMPLETE           IN NUMBER
 ,X_EFF_ROLLUP_PERCENT_COMP         IN NUMBER
 ,X_COMPLETED_PERCENTAGE            IN NUMBER
 ,X_ESTIMATED_START_DATE            IN DATE
 ,X_ESTIMATED_FINISH_DATE           IN DATE
 ,X_ACTUAL_START_DATE               IN DATE
 ,X_ACTUAL_FINISH_DATE              IN DATE
 ,X_EST_REMAINING_EFFORT            IN NUMBER
 ,X_BASE_PERCENT_COMP_DERIV_CODE    IN VARCHAR2
 ,X_BASE_PROGRESS_STATUS_CODE       IN VARCHAR2
 ,X_EFF_ROLLUP_PROG_STAT_CODE       IN VARCHAR2
 ,X_RECORD_VERSION_NUMBER           IN NUMBER
 ,x_percent_complete_id             in number
 ,X_STRUCTURE_TYPE                      IN VARCHAR2
 ,X_PROJ_ELEMENT_ID                     IN NUMBER
 ,X_STRUCTURE_VERSION_ID                IN NUMBER
 ,X_PPL_ACT_EFFORT_TO_DATE          IN NUMBER
 ,X_EQPMT_ACT_EFFORT_TO_DATE        IN NUMBER
 ,X_EQPMT_ETC_EFFORT                    IN NUMBER
 ,X_OTH_ACT_COST_TO_DATE_TC             IN NUMBER
 ,X_OTH_ACT_COST_TO_DATE_FC             IN NUMBER
 ,X_OTH_ACT_COST_TO_DATE_PC             IN NUMBER
 ,X_OTH_ETC_COST_TC                         IN NUMBER
 ,X_OTH_ETC_COST_FC                         IN NUMBER
 ,X_OTH_ETC_COST_PC                         IN NUMBER
 ,X_PPL_ACT_COST_TO_DATE_TC         IN NUMBER
 ,X_PPL_ACT_COST_TO_DATE_FC         IN NUMBER
 ,X_PPL_ACT_COST_TO_DATE_PC         IN NUMBER
 ,X_PPL_ETC_COST_TC                     IN NUMBER
 ,X_PPL_ETC_COST_FC                     IN NUMBER
 ,X_PPL_ETC_COST_PC                     IN NUMBER
 ,X_EQPMT_ACT_COST_TO_DATE_TC       IN NUMBER
 ,X_EQPMT_ACT_COST_TO_DATE_FC       IN NUMBER
 ,X_EQPMT_ACT_COST_TO_DATE_PC       IN NUMBER
 ,X_EQPMT_ETC_COST_TC                   IN NUMBER
 ,X_EQPMT_ETC_COST_FC                   IN NUMBER
 ,X_EQPMT_ETC_COST_PC                   IN NUMBER
 ,X_EARNED_VALUE                        IN NUMBER
 ,X_TASK_WT_BASIS_CODE                  IN VARCHAR2
 ,X_SUBPRJ_PPL_ACT_EFFORT              IN NUMBER
 ,X_SUBPRJ_EQPMT_ACT_EFFORT            IN NUMBER
 ,X_SUBPRJ_PPL_ETC_EFFORT              IN NUMBER
 ,X_SUBPRJ_EQPMT_ETC_EFFORT            IN NUMBER
 ,X_SBPJ_OTH_ACT_COST_TO_DATE_TC     IN NUMBER
 ,X_SBPJ_OTH_ACT_COST_TO_DATE_FC     IN NUMBER
 ,X_SBPJ_OTH_ACT_COST_TO_DATE_PC     IN NUMBER
 ,X_SUBPRJ_PPL_ACT_COST_TC             IN NUMBER
 ,X_SUBPRJ_PPL_ACT_COST_FC             IN NUMBER
 ,X_SUBPRJ_PPL_ACT_COST_PC             IN NUMBER
 ,X_SUBPRJ_EQPMT_ACT_COST_TC           IN NUMBER
 ,X_SUBPRJ_EQPMT_ACT_COST_FC           IN NUMBER
 ,X_SUBPRJ_EQPMT_ACT_COST_PC           IN NUMBER
 ,X_SUBPRJ_OTH_ETC_COST_TC                 IN NUMBER
 ,X_SUBPRJ_OTH_ETC_COST_FC                 IN NUMBER
 ,X_SUBPRJ_OTH_ETC_COST_PC                 IN NUMBER
 ,X_SUBPRJ_PPL_ETC_COST_TC             IN NUMBER
 ,X_SUBPRJ_PPL_ETC_COST_FC             IN NUMBER
 ,X_SUBPRJ_PPL_ETC_COST_PC             IN NUMBER
 ,X_SUBPRJ_EQPMT_ETC_COST_TC           IN NUMBER
 ,X_SUBPRJ_EQPMT_ETC_COST_FC           IN NUMBER
 ,X_SUBPRJ_EQPMT_ETC_COST_PC           IN NUMBER
 ,X_SUBPRJ_EARNED_VALUE                IN NUMBER
 ,X_CURRENT_FLAG                        IN VARCHAR2
,X_PROJFUNC_COST_RATE_TYPE		VARCHAR2
,X_PROJFUNC_COST_EXCHANGE_RATE		NUMBER
,X_PROJFUNC_COST_RATE_DATE		DATE
,X_PROJ_COST_RATE_TYPE			VARCHAR2
,X_PROJ_COST_EXCHANGE_RATE		NUMBER
,X_PROJ_COST_RATE_DATE			DATE
,X_TXN_CURRENCY_CODE			VARCHAR2
,X_PROG_PA_PERIOD_NAME			VARCHAR2
,X_PROG_GL_PERIOD_NAME			VARCHAR2
,X_OTH_QUANTITY_TO_DATE                 NUMBER
,X_OTH_ETC_QUANTITY                     NUMBER
,X_OTH_ACT_RAWCOST_TO_DATE_TC		IN NUMBER
,X_OTH_ACT_RAWCOST_TO_DATE_FC		IN NUMBER
,X_OTH_ACT_RAWCOST_TO_DATE_PC		IN NUMBER
,X_OTH_ETC_RAWCOST_TC		IN NUMBER
,X_OTH_ETC_RAWCOST_FC		IN NUMBER
,X_OTH_ETC_RAWCOST_PC		IN NUMBER
,X_PPL_ACT_RAWCOST_TO_DATE_TC		IN NUMBER
,X_PPL_ACT_RAWCOST_TO_DATE_FC		IN NUMBER
,X_PPL_ACT_RAWCOST_TO_DATE_PC		IN NUMBER
,X_PPL_ETC_RAWCOST_TC		IN NUMBER
,X_PPL_ETC_RAWCOST_FC		IN NUMBER
,X_PPL_ETC_RAWCOST_PC		IN NUMBER
,X_EQPMT_ACT_RAWCOST_TO_DATE_TC		IN NUMBER
,X_EQPMT_ACT_RAWCOST_TO_DATE_FC		IN NUMBER
,X_EQPMT_ACT_RAWCOST_TO_DATE_PC		IN NUMBER
,X_EQPMT_ETC_RAWCOST_TC		IN NUMBER
,X_EQPMT_ETC_RAWCOST_FC		IN NUMBER
,X_EQPMT_ETC_RAWCOST_PC		IN NUMBER
,X_SP_OTH_ACT_RAWCOST_TODATE_TC		IN NUMBER
,X_SP_OTH_ACT_RAWCOST_TODATE_FC		IN NUMBER
,X_SP_OTH_ACT_RAWCOST_TODATE_PC		IN NUMBER
,X_SUBPRJ_PPL_ACT_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_PPL_ACT_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_PPL_ACT_RAWCOST_PC		IN NUMBER
,X_SUBPRJ_EQPMT_ACT_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_EQPMT_ACT_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_EQPMT_ACT_RAWCOST_PC		IN NUMBER
,X_SUBPRJ_OTH_ETC_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_OTH_ETC_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_OTH_ETC_RAWCOST_PC		IN NUMBER
,X_SUBPRJ_PPL_ETC_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_PPL_ETC_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_PPL_ETC_RAWCOST_PC		IN NUMBER
,X_SUBPRJ_EQPMT_ETC_RAWCOST_TC		IN NUMBER
,X_SUBPRJ_EQPMT_ETC_RAWCOST_FC		IN NUMBER
,X_SUBPRJ_EQPMT_ETC_RAWCOST_PC		IN NUMBER
);

Procedure DELETE_ROW(
 p_row_id  VARCHAR2 );


end PA_PROGRESS_ROLLUP_PKG;


 

/
