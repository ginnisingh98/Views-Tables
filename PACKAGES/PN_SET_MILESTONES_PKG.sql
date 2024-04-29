--------------------------------------------------------
--  DDL for Package PN_SET_MILESTONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_SET_MILESTONES_PKG" AUTHID CURRENT_USER As
/* $Header: PNTSTMLS.pls 120.1 2005/08/05 06:25:04 appldev ship $ */

procedure INSERT_ROW (
                       X_ROWID                in out NOCOPY VARCHAR2,
                       X_MILESTONES_SET_ID    in out NOCOPY NUMBER,
                       X_SET_ID               in NUMBER,
                       X_USER_ID              in NUMBER,
                       X_NOTIFICATION_DATE    in DATE,
                       X_LEAD_DAYS            in NUMBER,
                       X_ATTRIBUTE_CATEGORY   in VARCHAR2,
                       X_ATTRIBUTE1           in VARCHAR2,
                       X_ATTRIBUTE2           in VARCHAR2,
                       X_ATTRIBUTE3           in VARCHAR2,
                       X_ATTRIBUTE4           in VARCHAR2,
                       X_ATTRIBUTE5           in VARCHAR2,
                       X_ATTRIBUTE6           in VARCHAR2,
                       X_ATTRIBUTE7           in VARCHAR2,
                       X_ATTRIBUTE8           in VARCHAR2,
                       X_ATTRIBUTE9           in VARCHAR2,
                       X_ATTRIBUTE10          in VARCHAR2,
                       X_ATTRIBUTE11          in VARCHAR2,
                       X_ATTRIBUTE12          in VARCHAR2,
                       X_ATTRIBUTE13          in VARCHAR2,
                       X_ATTRIBUTE14          in VARCHAR2,
                       X_ATTRIBUTE15          in VARCHAR2,
                       X_MILESTONE_TYPE_CODE  in VARCHAR2,
                       X_FREQUENCY            in NUMBER,
                       X_CREATION_DATE        in DATE,
                       X_CREATED_BY           in NUMBER,
                       X_LAST_UPDATE_DATE     in DATE,
                       X_LAST_UPDATED_BY      in NUMBER,
                       X_LAST_UPDATE_LOGIN    in NUMBER
                    );

procedure LOCK_ROW (
                       X_MILESTONES_SET_ID    in NUMBER,
                       X_SET_ID               in NUMBER,
                       X_USER_ID              in NUMBER,
                       X_NOTIFICATION_DATE    in DATE,
                       X_LEAD_DAYS            in NUMBER,
                       X_ATTRIBUTE_CATEGORY   in VARCHAR2,
                       X_ATTRIBUTE1           in VARCHAR2,
                       X_ATTRIBUTE2           in VARCHAR2,
                       X_ATTRIBUTE3           in VARCHAR2,
                       X_ATTRIBUTE4           in VARCHAR2,
                       X_ATTRIBUTE5           in VARCHAR2,
                       X_ATTRIBUTE6           in VARCHAR2,
                       X_ATTRIBUTE7           in VARCHAR2,
                       X_ATTRIBUTE8           in VARCHAR2,
                       X_ATTRIBUTE9           in VARCHAR2,
                       X_ATTRIBUTE10          in VARCHAR2,
                       X_ATTRIBUTE11          in VARCHAR2,
                       X_ATTRIBUTE12          in VARCHAR2,
                       X_ATTRIBUTE13          in VARCHAR2,
                       X_ATTRIBUTE14          in VARCHAR2,
                       X_ATTRIBUTE15          in VARCHAR2,
                       X_MILESTONE_TYPE_CODE  in VARCHAR2,
                       X_FREQUENCY            in NUMBER
                     );

procedure UPDATE_ROW (
                       X_MILESTONES_SET_ID    in NUMBER,
                       X_SET_ID               in NUMBER,
                       X_USER_ID              in NUMBER,
                       X_NOTIFICATION_DATE    in DATE,
                       X_LEAD_DAYS            in NUMBER,
                       X_ATTRIBUTE_CATEGORY   in VARCHAR2,
                       X_ATTRIBUTE1           in VARCHAR2,
                       X_ATTRIBUTE2           in VARCHAR2,
                       X_ATTRIBUTE3           in VARCHAR2,
                       X_ATTRIBUTE4           in VARCHAR2,
                       X_ATTRIBUTE5           in VARCHAR2,
                       X_ATTRIBUTE6           in VARCHAR2,
                       X_ATTRIBUTE7           in VARCHAR2,
                       X_ATTRIBUTE8           in VARCHAR2,
                       X_ATTRIBUTE9           in VARCHAR2,
                       X_ATTRIBUTE10          in VARCHAR2,
                       X_ATTRIBUTE11          in VARCHAR2,
                       X_ATTRIBUTE12          in VARCHAR2,
                       X_ATTRIBUTE13          in VARCHAR2,
                       X_ATTRIBUTE14          in VARCHAR2,
                       X_ATTRIBUTE15          in VARCHAR2,
                       X_MILESTONE_TYPE_CODE  in VARCHAR2,
                       X_FREQUENCY            in NUMBER,
                       X_LAST_UPDATE_DATE     in DATE,
                       X_LAST_UPDATED_BY      in NUMBER,
                       X_LAST_UPDATE_LOGIN    in NUMBER
                     );

procedure DELETE_ROW (
                       X_MILESTONES_SET_ID    in NUMBER
                     );

end PN_SET_MILESTONES_PKG;

 

/
