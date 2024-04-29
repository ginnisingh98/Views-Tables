--------------------------------------------------------
--  DDL for Package PA_PERF_OBJECT_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_OBJECT_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: PAPEORVS.pls 120.1 2005/08/19 16:39:18 mwasowic noship $ */

/*==================================================================
  PROCEDURE
      create_rule_object
  PURPOSE
      This procedure inserts a row into the pa_perf_object_rules table.
 ==================================================================*/


PROCEDURE create_rule_object(
  P_OBJECT_RULE_ID        IN NUMBER,
  P_OBJECT_TYPE           IN VARCHAR2,
  P_OBJECT_ID             IN NUMBER,
  P_RULE_ID               IN NUMBER,
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
      update_rule_object
  PURPOSE
      This procedure updates a row in the pa_perf_object_rules table.
 ==================================================================*/


PROCEDURE update_rule_object(
  P_OBJECT_RULE_ID        IN NUMBER,
  P_OBJECT_TYPE           IN VARCHAR2,
  P_OBJECT_ID             IN NUMBER,
  P_RULE_ID               IN NUMBER,
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
      delete_rule_object
  PURPOSE
      This procedure deletes a row from the pa_perf_object_rules table.
 ==================================================================*/
PROCEDURE delete_rule_object (
 P_OBJECT_RULE_ID         IN         NUMBER,
 P_RECORD_VERSION_NUMBER  IN         NUMBER,
 X_RETURN_STATUS          OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT              OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA               OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_RULE_NAME              OUT        NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*==================================================================
  PROCEDURE
      validate_rule_object
  PURPOSE
      This procedure Checks the rules associated with a project .
 ==================================================================*/
PROCEDURE validate_rule_object
                  (P_OBJECT_ID       IN         NUMBER,
                   P_OBJECT_TYPE     IN         VARCHAR2,
                   X_RETURN_STATUS   OUT        NOCOPY VARCHAR2,      --File.Sql.39 bug 4440895
                   X_MSG_COUNT       OUT        NOCOPY NUMBER,       --File.Sql.39 bug 4440895
                   X_MSG_DATA        OUT        NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_PERF_OBJECT_RULES_PVT;

 

/
