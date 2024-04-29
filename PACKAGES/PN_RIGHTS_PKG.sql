--------------------------------------------------------
--  DDL for Package PN_RIGHTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_RIGHTS_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRIGHTS.pls 120.1 2005/07/25 06:38:23 appldev ship $ */

PROCEDURE Insert_Row (
          X_ROWID                         IN OUT NOCOPY VARCHAR2,
          X_RIGHT_ID                      IN OUT NOCOPY NUMBER,
          X_RIGHT_NUM                     IN OUT NOCOPY NUMBER,
          X_LEASE_ID                      IN     NUMBER,
          X_LEASE_CHANGE_ID               IN     NUMBER,
          X_RIGHT_TYPE_CODE               IN     VARCHAR2,
          X_RIGHT_STATUS_CODE             IN     VARCHAR2,
          X_RIGHT_REFERENCE               IN     VARCHAR2,
          X_START_DATE                    IN     DATE,
          X_EXPIRATION_DATE               IN     DATE,
          X_RIGHT_COMMENTS                IN     VARCHAR2,
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
          x_org_id                        IN     NUMBER
        );

PROCEDURE Lock_Row (
          X_RIGHT_ID                      IN     NUMBER,
          X_LEASE_ID                      IN     NUMBER,
          X_LEASE_CHANGE_ID               IN     NUMBER,
          X_RIGHT_NUM                     IN     NUMBER,
          X_RIGHT_TYPE_CODE               IN     VARCHAR2,
          X_RIGHT_STATUS_CODE             IN     VARCHAR2,
          X_RIGHT_REFERENCE               IN     VARCHAR2,
          X_START_DATE                    IN     DATE,
          X_EXPIRATION_DATE               IN     DATE,
          X_RIGHT_COMMENTS                IN     VARCHAR2,
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
          X_ATTRIBUTE15                   IN     VARCHAR2
        );

PROCEDURE Update_Row (
          X_RIGHT_ID                      IN     NUMBER,
          X_LEASE_ID                      IN     NUMBER,
          X_LEASE_CHANGE_ID               IN     NUMBER,
          X_RIGHT_NUM                     IN     NUMBER,
          X_RIGHT_TYPE_CODE               IN     VARCHAR2,
          X_RIGHT_STATUS_CODE             IN     VARCHAR2,
          X_RIGHT_REFERENCE               IN     VARCHAR2,
          X_START_DATE                    IN     DATE,
          X_EXPIRATION_DATE               IN     DATE,
          X_RIGHT_COMMENTS                IN     VARCHAR2,
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
          X_LAST_UPDATE_LOGIN             IN     NUMBER
        );

PROCEDURE Delete_Row (
          X_RIGHT_ID                      IN     NUMBER
        );

END pn_rights_pkg;

 

/
