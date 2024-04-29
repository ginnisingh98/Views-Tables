--------------------------------------------------------
--  DDL for Package PA_ROLE_CONTROLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_CONTROLS_PVT" AUTHID CURRENT_USER AS
/* $Header: PARPRCVS.pls 120.1 2005/08/19 16:58:53 mwasowic noship $ */

--
--  PROCEDURE
--      Insert_Row
--  PURPOSE
--      This procedure inserts a row into the pa_role_controls table.
--
--  HISTORY
--      08-AUG-00		jwhite		Created
--

PROCEDURE INSERT_ROW (
 P_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 P_ROLE_CONTROL_CODE            IN         VARCHAR2,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--
--  PROCEDURE
--      Lock_Row
--  PURPOSE
--      This procedure determines if a row in the pa_role_controls table can
--      be locked. If a row can be locked, this API returns (S)uccess for
--      x_return_status.
--
--  HISTORY
--      08-AUG-00		jwhite		Created
--

PROCEDURE LOCK_ROW (
 P_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 P_RECORD_VERSION_NUMBER        IN         NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


--
--  PROCEDURE
--      Update_Row
--  PURPOSE
--      This procedure updates a row in the pa_role_controls table.
--
--  HISTORY
--      08-AUG-00		jwhite		Created
--

PROCEDURE UPDATE_ROW (
 P_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 P_ROLE_CONTROL_CODE            IN         VARCHAR2,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--
--  PROCEDURE
--      Delete_Row
--  PURPOSE
--      This procedure deletes a row in the pa_role_controls table.
--      If a row is deleted, this API returns (S)uccess for the
--      x_return_status.
--
--  HISTORY
--      08-AUG-00		jwhite		Created
--

PROCEDURE DELETE_ROW (
 P_Rowid                        IN         VARCHAR2,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END pa_role_controls_pvt;
 

/
