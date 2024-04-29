--------------------------------------------------------
--  DDL for Package PN_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_OPTIONS_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTOPTNS.pls 115.14 2002/11/12 23:09:59 stripath ship $

PROCEDURE Insert_Row (
        X_ROWID                         IN OUT NOCOPY VARCHAR2,
        X_OPTION_ID                     IN OUT NOCOPY NUMBER,
        X_OPTION_NUM                    IN OUT NOCOPY VARCHAR2,
        X_LEASE_ID                      IN     NUMBER,
        X_LEASE_CHANGE_ID               IN     NUMBER,
        X_OPTION_TYPE_CODE              IN     VARCHAR2,
        X_START_DATE                    IN     DATE,
        X_EXPIRATION_DATE               IN     DATE,
        X_OPTION_SIZE                   IN     NUMBER,
        X_UOM_CODE                      IN     VARCHAR2,
        X_OPTION_STATUS_LOOKUP_CODE     IN     VARCHAR2,
        X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
        X_ATTRIBUTE1                    IN     VARCHAR2,
        X_ATTRIBUTE2                    IN     VARCHAR2,
        X_ATTRIBUTE3                    IN     VARCHAR2,
        X_ATTRIBUTE4                    IN     VARCHAR2,
        X_ATTRIBUTE5                    IN     VARCHAR2,
        X_ATTRIBUTE6                    IN     VARCHAR2,
        X_ATTRIBUTE7                    IN     VARCHAR2,
        X_ATTRIBUTE8                    IN     VARCHAR2,
        X_ATTRIBUTE9                    IN     VARCHAR2,
        X_ATTRIBUTE10                   IN     VARCHAR2,
        X_ATTRIBUTE11                   IN     VARCHAR2,
        X_ATTRIBUTE12                   IN     VARCHAR2,
        X_ATTRIBUTE13                   IN     VARCHAR2,
        X_ATTRIBUTE14                   IN     VARCHAR2,
        X_ATTRIBUTE15                   IN     VARCHAR2,
        X_CREATION_DATE                 IN     DATE,
        X_CREATED_BY                    IN     NUMBER,
        X_LAST_UPDATE_DATE              IN     DATE,
        X_LAST_UPDATED_BY               IN     NUMBER,
        X_LAST_UPDATE_LOGIN             IN     NUMBER,
        X_OPTION_EXER_START_DATE        IN     DATE,
        X_OPTION_EXER_END_DATE          IN     DATE,
        X_OPTION_ACTION_DATE            IN     DATE,
        X_OPTION_COST                   IN     VARCHAR2,
        X_OPTION_AREA_CHANGE            IN     NUMBER,
        X_OPTION_REFERENCE              IN     VARCHAR2,
        X_OPTION_NOTICE_REQD            IN     VARCHAR2,
        X_OPTION_COMMENTS               IN     VARCHAR2,
        x_org_id                        IN     NUMBER
        );

PROCEDURE Lock_Row (
        X_OPTION_ID                     IN     NUMBER,
        X_LEASE_ID                      IN     NUMBER,
        X_LEASE_CHANGE_ID               IN     NUMBER,
        X_OPTION_NUM                    IN     VARCHAR2,
        X_OPTION_TYPE_CODE              IN     VARCHAR2,
        X_START_DATE                    IN     DATE,
        X_EXPIRATION_DATE               IN     DATE,
        X_OPTION_SIZE                   IN     NUMBER,
        X_UOM_CODE                      IN     VARCHAR2,
        X_OPTION_STATUS_LOOKUP_CODE     IN     VARCHAR2,
        X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
        X_ATTRIBUTE1                    IN     VARCHAR2,
        X_ATTRIBUTE2                    IN     VARCHAR2,
        X_ATTRIBUTE3                    IN     VARCHAR2,
        X_ATTRIBUTE4                    IN     VARCHAR2,
        X_ATTRIBUTE5                    IN     VARCHAR2,
        X_ATTRIBUTE6                    IN     VARCHAR2,
        X_ATTRIBUTE7                    IN     VARCHAR2,
        X_ATTRIBUTE8                    IN     VARCHAR2,
        X_ATTRIBUTE9                    IN     VARCHAR2,
        X_ATTRIBUTE10                   IN     VARCHAR2,
        X_ATTRIBUTE11                   IN     VARCHAR2,
        X_ATTRIBUTE12                   IN     VARCHAR2,
        X_ATTRIBUTE13                   IN     VARCHAR2,
        X_ATTRIBUTE14                   IN     VARCHAR2,
        X_ATTRIBUTE15                   IN     VARCHAR2,
        X_OPTION_EXER_START_DATE        IN     DATE,
        X_OPTION_EXER_END_DATE          IN     DATE,
        X_OPTION_ACTION_DATE            IN     DATE,
        X_OPTION_COST                   IN     VARCHAR2,
        X_OPTION_AREA_CHANGE            IN     NUMBER,
        X_OPTION_REFERENCE              IN     VARCHAR2,
        X_OPTION_NOTICE_REQD            IN     VARCHAR2,
        X_OPTION_COMMENTS               IN     VARCHAR2
);

PROCEDURE Update_Row (
        X_OPTION_ID                     IN     NUMBER,
        X_LEASE_ID                      IN     NUMBER,
        X_LEASE_CHANGE_ID               IN     NUMBER,
        X_OPTION_NUM                    IN     VARCHAR2,
        X_OPTION_TYPE_CODE              IN     VARCHAR2,
        X_START_DATE                    IN     DATE,
        X_EXPIRATION_DATE               IN     DATE,
        X_OPTION_SIZE                   IN     NUMBER,
        X_UOM_CODE                      IN     VARCHAR2,
        X_OPTION_STATUS_LOOKUP_CODE     IN     VARCHAR2,
        X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
        X_ATTRIBUTE1                    IN     VARCHAR2,
        X_ATTRIBUTE2                    IN     VARCHAR2,
        X_ATTRIBUTE3                    IN     VARCHAR2,
        X_ATTRIBUTE4                    IN     VARCHAR2,
        X_ATTRIBUTE5                    IN     VARCHAR2,
        X_ATTRIBUTE6                    IN     VARCHAR2,
        X_ATTRIBUTE7                    IN     VARCHAR2,
        X_ATTRIBUTE8                    IN     VARCHAR2,
        X_ATTRIBUTE9                    IN     VARCHAR2,
        X_ATTRIBUTE10                   IN     VARCHAR2,
        X_ATTRIBUTE11                   IN     VARCHAR2,
        X_ATTRIBUTE12                   IN     VARCHAR2,
        X_ATTRIBUTE13                   IN     VARCHAR2,
        X_ATTRIBUTE14                   IN     VARCHAR2,
        X_ATTRIBUTE15                   IN     VARCHAR2,
        X_LAST_UPDATE_DATE              IN     DATE,
        X_LAST_UPDATED_BY               IN     NUMBER,
        X_LAST_UPDATE_LOGIN             IN     NUMBER,
        X_OPTION_EXER_START_DATE        IN     DATE,
        X_OPTION_EXER_END_DATE          IN     DATE,
        X_OPTION_ACTION_DATE            IN     DATE,
        X_OPTION_COST                   IN     VARCHAR2,
        X_OPTION_AREA_CHANGE            IN     NUMBER,
        X_OPTION_REFERENCE              IN     VARCHAR2,
        X_OPTION_NOTICE_REQD            IN     VARCHAR2,
        X_OPTION_COMMENTS               IN     VARCHAR2
);

PROCEDURE Delete_Row (
        X_OPTION_ID                     IN     NUMBER
);

END pn_options_pkg;

 

/
