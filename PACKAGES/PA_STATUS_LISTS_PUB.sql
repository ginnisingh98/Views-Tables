--------------------------------------------------------
--  DDL for Package PA_STATUS_LISTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STATUS_LISTS_PUB" AUTHID CURRENT_USER AS
/* $Header: PACISLPS.pls 120.1 2005/08/19 16:18:35 mwasowic noship $ */

--
--  PROCEDURE
--      CreateStatusList
--  PURPOSE
--      This procedure inserts a row into the pa_status_lists table.
--
--  HISTORY
--      16-JAN-04		rasinha		Created
--

PROCEDURE CreateStatusList (
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 P_STATUS_LIST_ID               IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_NAME                         IN         VARCHAR2,
 P_START_DATE_ACTIVE            IN         DATE,
 P_END_DATE_ACTIVE              IN         DATE,
 P_DESCRIPTION                  IN         VARCHAR2,
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
--      UpdateStatusList
--  PURPOSE
--      This procedure updates a row in the pa_status_lists table.
--
--  HISTORY
--      16-JAN-04		rasinha		Created
--

PROCEDURE UpdateStatusList (
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 P_STATUS_LIST_ID               IN         NUMBER,
 P_STATUS_TYPE                  IN         VARCHAR2,
 P_NAME                         IN         VARCHAR2,
 P_START_DATE_ACTIVE            IN         DATE,
 P_END_DATE_ACTIVE              IN         DATE,
 P_DESCRIPTION                  IN         VARCHAR2,
 P_LAST_UPDATE_DATE             IN         DATE DEFAULT SYSDATE,
 P_LAST_UPDATED_BY              IN         NUMBER DEFAULT fnd_global.user_id,
 P_LAST_UPDATE_LOGIN            IN         NUMBER DEFAULT fnd_global.login_id,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--
--  PROCEDURE
--      DeleteStatusList
--  PURPOSE
--      This procedure deletes a row in the pa_status_lists table.
--      If a row is deleted, this API returns (S)uccess for the
--      x_return_status.
--
--  HISTORY
--      16-JAN-04		rasinha		Created
--

PROCEDURE DeleteStatusList (
 P_STATUS_LIST_ID               IN         NUMBER,
 P_RECORD_VERSION_NUMBER        IN	   NUMBER,
 X_RETURN_STATUS                OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_MSG_COUNT                    OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
 X_MSG_DATA                     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END pa_status_lists_pub;

 

/
