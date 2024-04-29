--------------------------------------------------------
--  DDL for Package PA_STATUS_LIST_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STATUS_LIST_ITEMS_PVT" AUTHID CURRENT_USER AS
/* $Header: PACISIVS.pls 120.1 2005/08/19 16:18:27 mwasowic noship $ */


-- --------------------------------------------------------------------------
--
--  PROCEDURE
--      Insert_Row
--  PURPOSE
--      This procedure inserts a row into the PA_STATUS_LIST_ITEMS table.
--
--  HISTORY
--      28-JAN-04		svenketa		Created
--

PROCEDURE CreateStatusListItem (
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 PX_STATUS_LIST_ITEM_ID         IN OUT	   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 P_STATUS_LIST_ID               IN	   NUMBER,
 P_PROJECT_STATUS_CODE          IN	   VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE DEFAULT SYSDATE,
 P_LAST_UPDATED_BY              IN         NUMBER DEFAULT fnd_global.user_id,
 P_CREATION_DATE                IN         DATE DEFAULT SYSDATE,
 P_CREATED_BY                   IN         NUMBER DEFAULT fnd_global.user_id,
 P_LAST_UPDATE_LOGIN            IN         NUMBER DEFAULT fnd_global.login_id,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--
--  PROCEDURE
--      Update_Row
--  PURPOSE
--      This procedure updates a row in the pa_status_list_items table.
--
--  HISTORY
--      28-JAN-04		svenketa		Created
--

PROCEDURE UpdateStatusListItem (
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 P_STATUS_LIST_ITEM_ID         IN 	   NUMBER,
 P_STATUS_LIST_ID               IN	   NUMBER,
 P_PROJECT_STATUS_CODE          IN	   VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE DEFAULT SYSDATE,
 P_LAST_UPDATED_BY              IN         NUMBER DEFAULT fnd_global.user_id,
 P_CREATION_DATE                IN         DATE DEFAULT SYSDATE,
 P_CREATED_BY                   IN         NUMBER DEFAULT fnd_global.user_id,
 P_LAST_UPDATE_LOGIN            IN         NUMBER DEFAULT fnd_global.login_id,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--
--  PROCEDURE
--      Delete_Row
--  PURPOSE
--      This procedure deletes a row in the PA_STATUS_LIST_ITEMS table.
--      If a row is deleted, this API returns (S)uccess for the
--      x_return_status.
--
--  HISTORY
--      28-JAN-04		svenketa		Created
--

PROCEDURE DeleteStatusListItem (
 P_STATUS_LIST_ITEM_ID         IN         NUMBER,
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END PA_STATUS_LIST_ITEMS_pvt;

 

/
