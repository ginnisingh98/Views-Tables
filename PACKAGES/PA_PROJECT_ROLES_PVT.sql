--------------------------------------------------------
--  DDL for Package PA_PROJECT_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_ROLES_PVT" AUTHID CURRENT_USER AS
 /* $Header: PARPRPVS.pls 120.1 2005/08/19 16:59:39 mwasowic noship $ */

procedure INSERT_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_PROJECT_ROLE_TYPE            IN         VARCHAR2,
 X_MEANING                      IN         VARCHAR2,
 X_QUERY_LABOR_COST_FLAG        IN         VARCHAR2,
 X_START_DATE_ACTIVE            IN         DATE,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_END_DATE_ACTIVE              IN         DATE,
 X_DESCRIPTION                  IN         VARCHAR2,
 X_DEFAULT_MIN_JOB_LEVEL        IN         NUMBER,
 X_DEFAULT_MAX_JOB_LEVEL        IN         NUMBER,
 X_MENU_ID                      IN         NUMBER,
 X_DEFAULT_JOB_ID               IN         NUMBER,
 X_FREEZE_RULES_FLAG            IN         VARCHAR2,
 X_ATTRIBUTE_CATEGORY           IN         VARCHAR2,
 X_ATTRIBUTE1                   IN         VARCHAR2,
 X_ATTRIBUTE2                   IN         VARCHAR2,
 X_ATTRIBUTE3                   IN         VARCHAR2,
 X_ATTRIBUTE4                   IN         VARCHAR2,
 X_ATTRIBUTE5                   IN         VARCHAR2,
 X_ATTRIBUTE6                   IN         VARCHAR2,
 X_ATTRIBUTE7                   IN         VARCHAR2,
 X_ATTRIBUTE8                   IN         VARCHAR2,
 X_ATTRIBUTE9                   IN         VARCHAR2,
 X_ATTRIBUTE10                  IN         VARCHAR2,
 X_ATTRIBUTE11                  IN         VARCHAR2,
 X_ATTRIBUTE12                  IN         VARCHAR2,
 X_ATTRIBUTE13                  IN         VARCHAR2,
 X_ATTRIBUTE14                  IN         VARCHAR2,
 X_ATTRIBUTE15                  IN         VARCHAR2,
 X_DEFAULT_ACCESS_LEVEL         IN         VARCHAR2,
 X_ROLE_PARTY_CLASS             IN         VARCHAR2 DEFAULT 'PERSON',
 X_STATUS_LEVEL                 IN         VARCHAR2 DEFAULT NULL,
 x_return_status                OUT        NOCOPY varchar2, --File.Sql.39 bug 4440895
 x_msg_count                    out        NOCOPY number, --File.Sql.39 bug 4440895
 x_msg_data                     out        NOCOPY varchar2  --File.Sql.39 bug 4440895
);

procedure LOCK_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_RECORD_VERSION_NUMBER        IN         NUMBER,
 x_return_status                OUT        NOCOPY varchar2, --File.Sql.39 bug 4440895
 x_msg_count                    out        NOCOPY number, --File.Sql.39 bug 4440895
 x_msg_data                     out        NOCOPY varchar2 --File.Sql.39 bug 4440895
);

procedure UPDATE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 X_ROWID                        IN OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 X_PROJECT_ROLE_ID              IN         NUMBER,
 X_PROJECT_ROLE_TYPE            IN         VARCHAR2,
 X_MEANING                      IN         VARCHAR2,
 X_QUERY_LABOR_COST_FLAG        IN         VARCHAR2,
 X_START_DATE_ACTIVE            IN         DATE,
 X_LAST_UPDATE_DATE             IN         DATE,
 X_LAST_UPDATED_BY              IN         NUMBER,
 X_CREATION_DATE                IN         DATE,
 X_CREATED_BY                   IN         NUMBER,
 X_LAST_UPDATE_LOGIN            IN         NUMBER,
 X_END_DATE_ACTIVE              IN         DATE,
 X_DESCRIPTION                  IN         VARCHAR2,
 X_DEFAULT_MIN_JOB_LEVEL        IN         NUMBER,
 X_DEFAULT_MAX_JOB_LEVEL        IN         NUMBER,
 X_MENU_ID                      IN         NUMBER,
 X_DEFAULT_JOB_ID               IN         NUMBER,
 X_FREEZE_RULES_FLAG            IN         VARCHAR2,
 X_ATTRIBUTE_CATEGORY           IN         VARCHAR2,
 X_ATTRIBUTE1                   IN         VARCHAR2,
 X_ATTRIBUTE2                   IN         VARCHAR2,
 X_ATTRIBUTE3                   IN         VARCHAR2,
 X_ATTRIBUTE4                   IN         VARCHAR2,
 X_ATTRIBUTE5                   IN         VARCHAR2,
 X_ATTRIBUTE6                   IN         VARCHAR2,
 X_ATTRIBUTE7                   IN         VARCHAR2,
 X_ATTRIBUTE8                   IN         VARCHAR2,
 X_ATTRIBUTE9                   IN         VARCHAR2,
 X_ATTRIBUTE10                  IN         VARCHAR2,
 X_ATTRIBUTE11                  IN         VARCHAR2,
 X_ATTRIBUTE12                  IN         VARCHAR2,
 X_ATTRIBUTE13                  IN         VARCHAR2,
 X_ATTRIBUTE14                  IN         VARCHAR2,
 X_ATTRIBUTE15                  IN         VARCHAR2,
 X_DEFAULT_ACCESS_LEVEL         IN         VARCHAR2,
 X_ROLE_PARTY_CLASS             IN         VARCHAR2 DEFAULT 'PERSON',
 X_STATUS_LEVEL                 IN         VARCHAR2 DEFAULT NULL,
 x_return_status                OUT        NOCOPY varchar2, --File.Sql.39 bug 4440895
 x_msg_count                    out        NOCOPY number, --File.Sql.39 bug 4440895
 x_msg_data                     out        NOCOPY varchar2 --File.Sql.39 bug 4440895
);

procedure DELETE_ROW (
 p_commit                       IN         VARCHAR2:=FND_API.G_FALSE,
 p_debug_mode                   in         varchar2 default 'N',
 X_ROWID in varchar2,
 x_return_status                OUT        NOCOPY varchar2, --File.Sql.39 bug 4440895
 x_msg_count                    out        NOCOPY number, --File.Sql.39 bug 4440895
 x_msg_data                     out        NOCOPY varchar2 --File.Sql.39 bug 4440895
);

end PA_PROJECT_ROLES_PVT;
 

/
