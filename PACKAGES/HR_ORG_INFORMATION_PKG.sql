--------------------------------------------------------
--  DDL for Package HR_ORG_INFORMATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORG_INFORMATION_PKG" AUTHID CURRENT_USER as
/* $Header: peori01t.pkh 120.1.12010000.6 2008/08/06 09:20:20 ubhat ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Org_Information_Id                   IN OUT NOCOPY NUMBER,
                     X_Org_Information_Context              VARCHAR2,
                     X_Organization_Id                      NUMBER,
                     X_Org_Information1                     VARCHAR2,
                     X_Org_Information10                    VARCHAR2,
                     X_Org_Information11                    VARCHAR2,
                     X_Org_Information12                    VARCHAR2,
                     X_Org_Information13                    VARCHAR2,
                     X_Org_Information14                    VARCHAR2,
                     X_Org_Information15                    VARCHAR2,
                     X_Org_Information16                    VARCHAR2,
                     X_Org_Information17                    VARCHAR2,
                     X_Org_Information18                    VARCHAR2,
                     X_Org_Information19                    VARCHAR2,
                     X_Org_Information2                     VARCHAR2,
                     X_Org_Information20                    VARCHAR2,
                     X_Org_Information3                     VARCHAR2,
                     X_Org_Information4                     VARCHAR2,
                     X_Org_Information5                     VARCHAR2,
                     X_Org_Information6                     VARCHAR2,
                     X_Org_Information7                     VARCHAR2,
                     X_Org_Information8                     VARCHAR2,
                     X_Org_Information9                     VARCHAR2,
                     X_Attribute_Category                   VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Attribute16                          VARCHAR2,
                     X_Attribute17                          VARCHAR2,
                     X_Attribute18                          VARCHAR2,
                     X_Attribute19                          VARCHAR2,
                     X_Attribute20                          VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Org_Information_Id                     NUMBER,
                   X_Org_Information_Context                VARCHAR2,
                   X_Organization_Id                        NUMBER,
                   X_Org_Information1                       VARCHAR2,
                   X_Org_Information10                      VARCHAR2,
                   X_Org_Information11                      VARCHAR2,
                   X_Org_Information12                      VARCHAR2,
                   X_Org_Information13                      VARCHAR2,
                   X_Org_Information14                      VARCHAR2,
                   X_Org_Information15                      VARCHAR2,
                   X_Org_Information16                      VARCHAR2,
                   X_Org_Information17                      VARCHAR2,
                   X_Org_Information18                      VARCHAR2,
                   X_Org_Information19                      VARCHAR2,
                   X_Org_Information2                       VARCHAR2,
                   X_Org_Information20                      VARCHAR2,
                   X_Org_Information3                       VARCHAR2,
                   X_Org_Information4                       VARCHAR2,
                   X_Org_Information5                       VARCHAR2,
                   X_Org_Information6                       VARCHAR2,
                   X_Org_Information7                       VARCHAR2,
                   X_Org_Information8                       VARCHAR2,
                   X_Org_Information9                       VARCHAR2,
                   X_Attribute_Category                     VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Attribute16                            VARCHAR2,
                   X_Attribute17                            VARCHAR2,
                   X_Attribute18                            VARCHAR2,
                   X_Attribute19                            VARCHAR2,
                   X_Attribute20                            VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Org_Information_Id                  NUMBER,
                     X_Org_Information_Context             VARCHAR2,
                     X_Organization_Id                     NUMBER,
                     X_Org_Information1                    VARCHAR2,
                     X_Org_Information10                   VARCHAR2,
                     X_Org_Information11                   VARCHAR2,
                     X_Org_Information12                   VARCHAR2,
                     X_Org_Information13                   VARCHAR2,
                     X_Org_Information14                   VARCHAR2,
                     X_Org_Information15                   VARCHAR2,
                     X_Org_Information16                   VARCHAR2,
                     X_Org_Information17                   VARCHAR2,
                     X_Org_Information18                   VARCHAR2,
                     X_Org_Information19                   VARCHAR2,
                     X_Org_Information2                    VARCHAR2,
                     X_Org_Information20                   VARCHAR2,
                     X_Org_Information3                    VARCHAR2,
                     X_Org_Information4                    VARCHAR2,
                     X_Org_Information5                    VARCHAR2,
                     X_Org_Information6                    VARCHAR2,
                     X_Org_Information7                    VARCHAR2,
                     X_Org_Information8                    VARCHAR2,
                     X_Org_Information9                    VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);



PROCEDURE Validate_SIRET (X_SIRET IN VARCHAR2);

PROCEDURE Validate_SIREN (X_SIREN IN VARCHAR2);

PROCEDURE validate_business_group_name
  (p_organization_id             IN     NUMBER
  ,p_org_information_context     IN     VARCHAR2
  ,p_org_information1            IN     VARCHAR2
  ,p_org_information2            IN     VARCHAR2
  );

PROCEDURE check_duplicate_tax_rules
  (p_organization_id             IN     NUMBER
  ,p_org_information_context     IN     VARCHAR2
  ,p_org_information1            IN     VARCHAR2
  );

END HR_ORG_INFORMATION_PKG;

/
