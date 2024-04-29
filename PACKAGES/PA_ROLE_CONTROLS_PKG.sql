--------------------------------------------------------
--  DDL for Package PA_ROLE_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_CONTROLS_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPRRCS.pls 120.1 2005/08/19 17:17:55 mwasowic noship $ */

PROCEDURE INSERT_ROW (
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_ROLE_CONTROL_CODE            IN         VARCHAR2,
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER
);

PROCEDURE LOCK_ROW (
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_RECORD_VERSION_NUMBER        IN         NUMBER
);


PROCEDURE UPDATE_ROW (
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_ROLE_CONTROL_CODE            IN         VARCHAR2,
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER
);

PROCEDURE DELETE_ROW (X_Rowid VARCHAR2);


END pa_role_controls_pkg;
 

/
