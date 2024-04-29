--------------------------------------------------------
--  DDL for Package PN_CONTACT_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_CONTACT_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTCOASS.pls 120.1 2005/07/25 06:41:41 appldev ship $
------------------------------------------------------------------------
-- PROCEDURE : Insert_Row
------------------------------------------------------------------------
PROCEDURE Insert_Row
        (
                 X_ROWID                         IN OUT NOCOPY VARCHAR2
                ,X_CONTACT_ASSIGNMENT_ID         IN OUT NOCOPY NUMBER
                ,X_LAST_UPDATE_DATE              IN     DATE
                ,X_LAST_UPDATED_BY               IN     NUMBER
                ,X_CREATION_DATE                 IN     DATE
                ,X_CREATED_BY                    IN     NUMBER
                ,X_LAST_UPDATE_LOGIN             IN     NUMBER
                ,X_COMPANY_ID                    IN     NUMBER
                ,X_COMPANY_SITE_ID               IN     NUMBER
                ,X_LEASE_ID                      IN     NUMBER
                ,X_LEASE_CHANGE_ID               IN     NUMBER
                ,X_LOCATION_ID                   IN     NUMBER
                ,X_STATUS                        IN     VARCHAR2
                ,X_ATTRIBUTE_CATEGORY            IN     VARCHAR2
                ,X_ATTRIBUTE1                    IN     VARCHAR2
                ,X_ATTRIBUTE2                    IN     VARCHAR2
                ,X_ATTRIBUTE3                    IN     VARCHAR2
                ,X_ATTRIBUTE4                    IN     VARCHAR2
                ,X_ATTRIBUTE5                    IN     VARCHAR2
                ,X_ATTRIBUTE6                    IN     VARCHAR2
                ,X_ATTRIBUTE7                    IN     VARCHAR2
                ,X_ATTRIBUTE8                    IN     VARCHAR2
                ,X_ATTRIBUTE9                    IN     VARCHAR2
                ,X_ATTRIBUTE10                   IN     VARCHAR2
                ,X_ATTRIBUTE11                   IN     VARCHAR2
                ,X_ATTRIBUTE12                   IN     VARCHAR2
                ,X_ATTRIBUTE13                   IN     VARCHAR2
                ,X_ATTRIBUTE14                   IN     VARCHAR2
                ,X_ATTRIBUTE15                   IN     VARCHAR2
                ,x_org_id                        IN     NUMBER
        );

------------------------------------------------------------------------
-- PROCEDURE : Lock_Row
------------------------------------------------------------------------
PROCEDURE Lock_Row
        (
                 X_CONTACT_ASSIGNMENT_ID         IN     NUMBER
                ,X_COMPANY_ID                    IN     NUMBER
                ,X_COMPANY_SITE_ID               IN     NUMBER
                ,X_LEASE_ID                      IN     NUMBER
                ,X_LEASE_CHANGE_ID               IN     NUMBER
                ,X_LOCATION_ID                   IN     NUMBER
                ,X_STATUS                        IN     VARCHAR2
                ,X_ATTRIBUTE_CATEGORY            IN     VARCHAR2
                ,X_ATTRIBUTE1                    IN     VARCHAR2
                ,X_ATTRIBUTE2                    IN     VARCHAR2
                ,X_ATTRIBUTE3                    IN     VARCHAR2
                ,X_ATTRIBUTE4                    IN     VARCHAR2
                ,X_ATTRIBUTE5                    IN     VARCHAR2
                ,X_ATTRIBUTE6                    IN     VARCHAR2
                ,X_ATTRIBUTE7                    IN     VARCHAR2
                ,X_ATTRIBUTE8                    IN     VARCHAR2
                ,X_ATTRIBUTE9                    IN     VARCHAR2
                ,X_ATTRIBUTE10                   IN     VARCHAR2
                ,X_ATTRIBUTE11                   IN     VARCHAR2
                ,X_ATTRIBUTE12                   IN     VARCHAR2
                ,X_ATTRIBUTE13                   IN     VARCHAR2
                ,X_ATTRIBUTE14                   IN     VARCHAR2
                ,X_ATTRIBUTE15                   IN     VARCHAR2
        );


------------------------------------------------------------------------
-- PROCEDURE : Update_Row
------------------------------------------------------------------------
PROCEDURE Update_Row
        (
                 X_CONTACT_ASSIGNMENT_ID         IN     NUMBER
                ,X_LAST_UPDATE_DATE              IN     DATE
                ,X_LAST_UPDATED_BY               IN     NUMBER
                ,X_LAST_UPDATE_LOGIN             IN     NUMBER
                ,X_COMPANY_ID                    IN     NUMBER
                ,X_COMPANY_SITE_ID               IN     NUMBER
                ,X_LEASE_ID                      IN     NUMBER
                ,X_LEASE_CHANGE_ID               IN     NUMBER
                ,X_LOCATION_ID                   IN     NUMBER
                ,X_STATUS                        IN     VARCHAR2
                ,X_ATTRIBUTE_CATEGORY            IN     VARCHAR2
                ,X_ATTRIBUTE1                    IN     VARCHAR2
                ,X_ATTRIBUTE2                    IN     VARCHAR2
                ,X_ATTRIBUTE3                    IN     VARCHAR2
                ,X_ATTRIBUTE4                    IN     VARCHAR2
                ,X_ATTRIBUTE5                    IN     VARCHAR2
                ,X_ATTRIBUTE6                    IN     VARCHAR2
                ,X_ATTRIBUTE7                    IN     VARCHAR2
                ,X_ATTRIBUTE8                    IN     VARCHAR2
                ,X_ATTRIBUTE9                    IN     VARCHAR2
                ,X_ATTRIBUTE10                   IN     VARCHAR2
                ,X_ATTRIBUTE11                   IN     VARCHAR2
                ,X_ATTRIBUTE12                   IN     VARCHAR2
                ,X_ATTRIBUTE13                   IN     VARCHAR2
                ,X_ATTRIBUTE14                   IN     VARCHAR2
                ,X_ATTRIBUTE15                   IN     VARCHAR2
        );

------------------------------------------------------------------------
-- PROCEDURE : Delete_Row
------------------------------------------------------------------------
PROCEDURE Delete_Row
        (
                 X_CONTACT_ASSIGNMENT_ID         IN     NUMBER
        );


END pn_contact_assignments_pkg;

 

/
