--------------------------------------------------------
--  DDL for Package WMS_EXPRESS_PICK_TASK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_EXPRESS_PICK_TASK" AUTHID CURRENT_USER AS
/* $Header: WMSEXPTS.pls 115.6 2002/12/01 03:56:45 rbande ship $ */

  PRAGMA RESTRICT_REFERENCES(WMS_EXPRESS_PICK_TASK,WNDS,WNPS);

  PROCEDURE LOAD_AND_DROP(
                          X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
                          X_MSG_COUNT           OUT NOCOPY NUMBER,
                          X_MSG_DATA            OUT NOCOPY VARCHAR2,
                          P_ORG_ID              IN  NUMBER,
                          P_TEMP_ID             IN  NUMBER,
                          P_TO_LPN              IN  VARCHAR2,
                          P_TO_SUB              IN  VARCHAR2,
                          P_TO_LOC              IN  NUMBER,
                          P_ACTION              IN  VARCHAR2,
                          P_USER_ID             IN  NUMBER,
                          P_TASK_TYPE           IN  NUMBER
                         );

  PROCEDURE LOAD_TASK(
                 X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT           OUT NOCOPY NUMBER,
                 X_MSG_DATA            OUT NOCOPY VARCHAR2,
                 P_TEMP_ID             IN  NUMBER,
                 P_LPN_ID              IN  NUMBER,
                 P_USER_ID             IN  NUMBER
                );

  PROCEDURE DROP_TASK(
                 X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT           OUT NOCOPY NUMBER,
                 X_MSG_DATA            OUT NOCOPY VARCHAR2,
                 P_ORG_ID              IN  NUMBER,
                 P_TEMP_ID             IN  NUMBER,
                 P_LPN_ID              IN  NUMBER,
                 P_TO_SUB              IN  VARCHAR2,
                 P_TO_LOC              IN  NUMBER,
                 P_USER_ID             IN  NUMBER,
                 P_TASK_TYPE           IN  NUMBER
                );

  PROCEDURE HAS_EXPRESS_PICK_TASKS(
                                   X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                                   X_MSG_COUNT     OUT NOCOPY NUMBER,
                                   X_MSG_DATA      OUT NOCOPY VARCHAR2,
                                   P_USER_ID       IN  NUMBER,
                                   P_ORG_ID        IN  NUMBER
                                  );

  FUNCTION IS_EXPRESS_PICK_TASK( P_TASK_ID IN NUMBER ) RETURN VARCHAR2;
  FUNCTION IS_EXPRESS_PICK_TASK_ELIGIBLE( P_TRANSACTION_TEMP_ID IN NUMBER) RETURN VARCHAR2;

END WMS_EXPRESS_PICK_TASK;

 

/
