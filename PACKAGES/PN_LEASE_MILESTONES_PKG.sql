--------------------------------------------------------
--  DDL for Package PN_LEASE_MILESTONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LEASE_MILESTONES_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTMLSTS.pls 115.14 2002/11/12 23:09:12 stripath ship $

PROCEDURE Insert_Row (
                       X_ROWID                         IN OUT NOCOPY VARCHAR2,
                       X_LEASE_MILESTONE_ID            IN OUT NOCOPY NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_MILESTONE_TYPE_CODE           IN     VARCHAR2,
                       X_OPTION_ID                     IN     NUMBER,
                       X_INSURANCE_REQUIREMENT_ID      IN     NUMBER,
                       X_PAYMENT_TERM_ID               IN     NUMBER,
                       X_LEAD_DAYS                     IN     NUMBER,
                       X_EVERY_DAYS                    IN     NUMBER,
                       X_ACTION_TAKEN                  IN     VARCHAR2,
                       X_ACTION_DATE                   IN     DATE,
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
                       X_MILESTONE_DATE                IN     DATE,
                       X_USER_ID                       IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_CREATION_DATE                 IN     DATE,
                       X_CREATED_BY                    IN     NUMBER,
                       X_LAST_UPDATE_DATE              IN     DATE,
                       X_LAST_UPDATED_BY               IN     NUMBER,
                       X_LAST_UPDATE_LOGIN             IN     NUMBER,
                       x_org_id                        IN     NUMBER
                     );

PROCEDURE Lock_Row   (
                       X_LEASE_MILESTONE_ID            IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_MILESTONE_TYPE_CODE           IN     VARCHAR2,
                       X_OPTION_ID                     IN     NUMBER,
                       X_INSURANCE_REQUIREMENT_ID      IN     NUMBER,
                       X_PAYMENT_TERM_ID               IN     NUMBER,
                       X_LEAD_DAYS                     IN     NUMBER,
                       X_EVERY_DAYS                    IN     NUMBER,
                       X_ACTION_TAKEN                  IN     VARCHAR2,
                       X_ACTION_DATE                   IN     DATE,
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
                       X_MILESTONE_DATE                IN     DATE,
                       X_USER_ID                       IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER
                      );

PROCEDURE Update_Row (
                       X_LEASE_MILESTONE_ID            IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_MILESTONE_TYPE_CODE           IN     VARCHAR2,
                       X_OPTION_ID                     IN     NUMBER,
                       X_INSURANCE_REQUIREMENT_ID      IN     NUMBER,
                       X_PAYMENT_TERM_ID               IN     NUMBER,
                       X_LEAD_DAYS                     IN     NUMBER,
                       X_EVERY_DAYS                    IN     NUMBER,
                       X_ACTION_TAKEN                  IN     VARCHAR2,
                       X_ACTION_DATE                   IN     DATE,
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
                       X_MILESTONE_DATE                IN     DATE,
                       X_USER_ID                       IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LAST_UPDATE_DATE              IN     DATE,
                       X_LAST_UPDATED_BY               IN     NUMBER,
                       X_LAST_UPDATE_LOGIN             IN     NUMBER
                     );

PROCEDURE Delete_Row (
                       X_LEASE_MILESTONE_ID            IN     NUMBER
                     );

END pn_lease_milestones_pkg;

 

/
