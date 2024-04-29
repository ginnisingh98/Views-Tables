--------------------------------------------------------
--  DDL for Package PA_ROLE_STATUS_MENU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_STATUS_MENU_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRSMTS.pls 120.1 2005/08/19 17:19:30 mwasowic noship $ */

PROCEDURE INSERT_ROW (
 --P_ROWID                        IN OUT     VARCHAR2,
 P_ROLE_STATUS_MENU_ID          OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 P_ROLE_ID                      IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_STATUS_CODE                  IN         VARCHAR2,
 P_MENU_ID                      IN	   NUMBER,
 P_OBJECT_VERSION_NUMBER        OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER
);

PROCEDURE LOCK_ROW (
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER
);


PROCEDURE UPDATE_ROW (
 --P_ROWID                        IN OUT     VARCHAR2,
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_ROLE_ID                      IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_STATUS_CODE                  IN         VARCHAR2,
 P_MENU_ID                      IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER
);

PROCEDURE DELETE_ROW (
 P_ROLE_STATUS_MENU_ID          IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER);

END pa_role_status_menu_pkg ;

 

/
