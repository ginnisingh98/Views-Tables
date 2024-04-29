--------------------------------------------------------
--  DDL for Package PN_LANDLORD_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LANDLORD_SERVICES_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTLNSRS.pls 115.16 2002/11/12 23:08:35 stripath ship $

PROCEDURE Insert_Row (
                       X_ROWID                         IN OUT NOCOPY VARCHAR2,
                       X_LANDLORD_SERVICE_ID           IN OUT NOCOPY NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_SERVICE_TYPE_LOOKUP_CODE      IN     VARCHAR2,
                       X_START_DATE                    IN     DATE,
                       X_END_DATE                      IN     DATE,
                       X_STATUS                        IN     VARCHAR2,
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
                       X_OBLIGATION_NUM                IN OUT NOCOPY VARCHAR2,
                       X_RESPONSIBILITY_CODE           IN     VARCHAR2,
                       X_COMMON_AREA_RESP              IN     VARCHAR2,
                       X_FINANCIAL_RESP_PARTY_CODE     IN     VARCHAR2,
                       X_FINANCIAL_PCT_RESP            IN     VARCHAR2,
                       X_RESPONSIBILITY_MAINT          IN     VARCHAR2,
                       X_COMPANY_ID                    IN     NUMBER,
                       X_OBLIGATION_REFERENCE          IN     VARCHAR2,
                       X_OBLIGATION_COMMENTS           IN     VARCHAR2,
                       x_org_id                        IN     NUMBER
                      );

PROCEDURE Lock_Row (
                       X_LANDLORD_SERVICE_ID           IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_SERVICE_TYPE_LOOKUP_CODE      IN     VARCHAR2,
                       X_START_DATE                    IN     DATE,
                       X_END_DATE                      IN     DATE,
                       X_STATUS                        IN     VARCHAR2,
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
                       X_OBLIGATION_NUM                IN     VARCHAR2,
                       X_RESPONSIBILITY_CODE           IN     VARCHAR2,
                       X_COMMON_AREA_RESP              IN     VARCHAR2,
                       X_FINANCIAL_RESP_PARTY_CODE     IN     VARCHAR2,
                       X_FINANCIAL_PCT_RESP            IN     VARCHAR2,
                       X_RESPONSIBILITY_MAINT          IN     VARCHAR2,
                       X_COMPANY_ID                    IN     NUMBER,
                       X_OBLIGATION_REFERENCE          IN     VARCHAR2,
                       X_OBLIGATION_COMMENTS           IN     VARCHAR2
                      );

PROCEDURE Update_Row (
                       X_LANDLORD_SERVICE_ID           IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_SERVICE_TYPE_LOOKUP_CODE      IN     VARCHAR2,
                       X_START_DATE                    IN     DATE,
                       X_END_DATE                      IN     DATE,
                       X_STATUS                        IN     VARCHAR2,
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
                       X_OBLIGATION_NUM                IN     VARCHAR2,
                       X_RESPONSIBILITY_CODE           IN     VARCHAR2,
                       X_COMMON_AREA_RESP              IN     VARCHAR2,
                       X_FINANCIAL_RESP_PARTY_CODE     IN     VARCHAR2,
                       X_FINANCIAL_PCT_RESP            IN     VARCHAR2,
                       X_RESPONSIBILITY_MAINT          IN     VARCHAR2,
                       X_COMPANY_ID                    IN     NUMBER,
                       X_OBLIGATION_REFERENCE          IN     VARCHAR2,
                       X_OBLIGATION_COMMENTS           IN     VARCHAR2
                      );

PROCEDURE Delete_Row (
                       X_LANDLORD_SERVICE_ID           IN     NUMBER
                      );

END pn_landlord_services_pkg;

 

/
