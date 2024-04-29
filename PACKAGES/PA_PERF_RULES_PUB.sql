--------------------------------------------------------
--  DDL for Package PA_PERF_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_RULES_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPERLPS.pls 120.1 2005/08/19 16:39:31 mwasowic noship $ */

/*==================================================================
  PROCEDURE
      create_rule
  PURPOSE
      This procedure inserts a row into the pa_perf_rules table.
 ==================================================================*/


PROCEDURE create_rule(
  P_RULE_ID	          IN NUMBER,
  P_RULE_NAME	          IN VARCHAR2,
  P_RULE_DESCRIPTION      IN VARCHAR2,
  P_RULE_TYPE             IN VARCHAR2,
  P_KPA_CODE              IN VARCHAR2,
  P_MEASURE_ID            IN NUMBER,
  P_MEASURE_FORMAT        IN VARCHAR2,
  P_CURRENCY_TYPE         IN VARCHAR2,
  P_PERIOD_TYPE           IN VARCHAR2,
  P_PRECISION             IN NUMBER,
  P_START_DATE_ACTIVE     IN DATE,
  P_END_DATE_ACTIVE       IN DATE,
  P_SCORE_METHOD          IN VARCHAR2,
  P_RECORD_VERSION_NUMBER IN NUMBER,
  P_CREATION_DATE         IN DATE DEFAULT SYSDATE,
  P_CREATED_BY            IN NUMBER DEFAULT fnd_global.user_id,
  P_LAST_UPDATE_DATE      IN DATE DEFAULT SYSDATE,
  P_LAST_UPDATED_BY       IN NUMBER DEFAULT fnd_global.user_id,
  P_LAST_UPDATE_LOGIN     IN NUMBER DEFAULT fnd_global.login_id,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA              OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


/*==================================================================
  PROCEDURE
      update_rule
  PURPOSE
      This procedure updates a row into the pa_perf_rules table.
 ==================================================================*/

PROCEDURE update_rule(
  P_RULE_ID	          IN NUMBER,
  P_RULE_NAME	          IN VARCHAR2,
  P_RULE_DESCRIPTION      IN VARCHAR2,
  P_RULE_TYPE             IN VARCHAR2,
  P_KPA_CODE              IN VARCHAR2,
  P_MEASURE_ID            IN NUMBER,
  P_MEASURE_FORMAT        IN VARCHAR2,
  P_CURRENCY_TYPE         IN VARCHAR2,
  P_PERIOD_TYPE           IN VARCHAR2,
  P_PRECISION             IN NUMBER,
  P_START_DATE_ACTIVE     IN DATE,
  P_END_DATE_ACTIVE       IN DATE,
  P_SCORE_METHOD          IN VARCHAR2,
  P_RECORD_VERSION_NUMBER IN NUMBER,
  P_LAST_UPDATE_DATE      IN DATE DEFAULT SYSDATE,
  P_LAST_UPDATED_BY       IN NUMBER DEFAULT fnd_global.user_id,
  P_LAST_UPDATE_LOGIN     IN NUMBER DEFAULT fnd_global.login_id,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA              OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*==================================================================
  PROCEDURE
      delete_rule
  PURPOSE
      This procedure deletes a row from the pa_perf_rules table.
 ==================================================================*/
PROCEDURE delete_rule (
 P_RULE_ID                IN         NUMBER,
 P_RECORD_VERSION_NUMBER  IN         NUMBER,
 X_RETURN_STATUS          OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT              OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA               OUT        NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

 /*==================================================================
  PROCEDURE
      validate_rule
  PURPOSE
      This procedure validates the performance rule to be inserted .
 ==================================================================*/


PROCEDURE validate_rule(
  P_RULE_ID	              IN     NUMBER,
  P_RULE_NAME	        IN     VARCHAR2,
  P_RULE_TYPE             IN     VARCHAR2,
  P_PRECISION             IN     NUMBER,
  P_START_DATE_ACTIVE     IN     DATE,
  P_END_DATE_ACTIVE       IN     DATE,
  P_THRESHOLD_ID          IN     SYSTEM.PA_NUM_TBL_TYPE,
  P_THRES_OBJ_ID          IN     SYSTEM.PA_NUM_TBL_TYPE,
  P_FROM_VALUE            IN     SYSTEM.PA_NUM_TBL_TYPE,
  P_TO_VALUE              IN     SYSTEM.PA_NUM_TBL_TYPE,
  P_INDICATOR_CODE        IN     SYSTEM.pa_varchar2_30_tbl_type,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  P_WEIGHTING             IN     SYSTEM.PA_NUM_TBL_TYPE );

END PA_PERF_RULES_PUB;

 

/
