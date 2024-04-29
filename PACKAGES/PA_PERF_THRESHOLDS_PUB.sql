--------------------------------------------------------
--  DDL for Package PA_PERF_THRESHOLDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_THRESHOLDS_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPETHPS.pls 120.1 2005/08/19 16:39:55 mwasowic noship $ */

/*==================================================================
  PROCEDURE
      create_rule_det
  PURPOSE
      This procedure inserts a row into the pa_perf_thersholds table.
 ==================================================================*/


PROCEDURE create_rule_det(
  P_THRESHOLD_ID          IN NUMBER,
  P_RULE_TYPE             IN VARCHAR2,
  P_THRES_OBJ_ID          IN NUMBER,
  P_FROM_VALUE            IN NUMBER,
  P_TO_VALUE              IN NUMBER,
  P_INDICATOR_CODE        IN VARCHAR2,
  P_EXCEPTION_FLAG        IN VARCHAR2,
  P_WEIGHTING             IN NUMBER,
  P_ACCESS_LIST_ID        IN NUMBER,
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
      update_rule_det
  PURPOSE
      This procedure updates a row into the pa_perf_thersholds table.
 ==================================================================*/

PROCEDURE update_rule_det(
  P_THRESHOLD_ID          IN NUMBER,
  P_RULE_TYPE             IN VARCHAR2,
  P_THRES_OBJ_ID          IN NUMBER,
  P_FROM_VALUE            IN NUMBER,
  P_TO_VALUE              IN NUMBER,
  P_INDICATOR_CODE        IN VARCHAR2,
  P_EXCEPTION_FLAG        IN VARCHAR2,
  P_WEIGHTING             IN NUMBER,
  P_ACCESS_LIST_ID        IN NUMBER,
  P_RECORD_VERSION_NUMBER IN NUMBER,
  P_LAST_UPDATE_DATE      IN DATE DEFAULT SYSDATE,
  P_LAST_UPDATED_BY       IN NUMBER DEFAULT fnd_global.user_id,
  P_LAST_UPDATE_LOGIN     IN NUMBER DEFAULT fnd_global.login_id,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA              OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*==================================================================
  PROCEDURE
      delete_rule_det
  PURPOSE
      This procedure deletes a row from the pa_perf_thersholds table.
 ==================================================================*/
PROCEDURE delete_rule_det (
 P_THRESHOLD_ID           IN         NUMBER,
 P_RECORD_VERSION_NUMBER  IN         NUMBER,
 X_RETURN_STATUS          OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT              OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA               OUT        NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_PERF_THRESHOLDS_PUB;

 

/
