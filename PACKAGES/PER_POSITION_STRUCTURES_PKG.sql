--------------------------------------------------------
--  DDL for Package PER_POSITION_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POSITION_STRUCTURES_PKG" AUTHID CURRENT_USER as
/* $Header: pepst01t.pkh 115.2 2003/02/11 09:59:46 eumenyio ship $ */

procedure form_startup(p_business_group_id NUMBER,
                       p_security_profile_id IN OUT NOCOPY NUMBER,
                       p_view_all_poss IN OUT NOCOPY VARCHAR2,
                       p_hr_installed IN OUT NOCOPY VARCHAR2,
                       p_pa_installed IN OUT NOCOPY VARCHAR2);

PROCEDURE check_name_unique(X_Rowid VARCHAR2,
                            X_Name  VARCHAR2,
                            X_Business_group_id NUMBER);

PROCEDURE check_primary_flag(X_Rowid VARCHAR2,
                             X_Primary_flag VARCHAR2,
                            X_Business_group_id NUMBER);

PROCEDURE pre_delete_checks(X_Position_Structure_Id          NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Po_Installed                         VARCHAR2,
                     X_Hr_Installed                         VARCHAR2);

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Position_Structure_Id                IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Comments                             VARCHAR2 ,
                     X_Primary_Position_Flag                VARCHAR2 ,
                     X_Attribute_Category                   VARCHAR2 ,
                     X_Attribute1                           VARCHAR2 ,
                     X_Attribute2                           VARCHAR2 ,
                     X_Attribute3                           VARCHAR2 ,
                     X_Attribute4                           VARCHAR2 ,
                     X_Attribute5                           VARCHAR2 ,
                     X_Attribute6                           VARCHAR2 ,
                     X_Attribute7                           VARCHAR2 ,
                     X_Attribute8                           VARCHAR2 ,
                     X_Attribute9                           VARCHAR2 ,
                     X_Attribute10                          VARCHAR2 ,
                     X_Attribute11                          VARCHAR2 ,
                     X_Attribute12                          VARCHAR2 ,
                     X_Attribute13                          VARCHAR2 ,
                     X_Attribute14                          VARCHAR2 ,
                     X_Attribute15                          VARCHAR2 ,
                     X_Attribute16                          VARCHAR2 ,
                     X_Attribute17                          VARCHAR2 ,
                     X_Attribute18                          VARCHAR2 ,
                     X_Attribute19                          VARCHAR2 ,
                     X_Attribute20                          VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Position_Structure_Id                  NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Name                                   VARCHAR2,
                   X_Comments                               VARCHAR2 ,
                   X_Primary_Position_Flag                  VARCHAR2 ,
                   X_Attribute_Category                     VARCHAR2 ,
                   X_Attribute1                             VARCHAR2 ,
                   X_Attribute2                             VARCHAR2 ,
                   X_Attribute3                             VARCHAR2 ,
                   X_Attribute4                             VARCHAR2 ,
                   X_Attribute5                             VARCHAR2 ,
                   X_Attribute6                             VARCHAR2 ,
                   X_Attribute7                             VARCHAR2 ,
                   X_Attribute8                             VARCHAR2 ,
                   X_Attribute9                             VARCHAR2 ,
                   X_Attribute10                            VARCHAR2 ,
                   X_Attribute11                            VARCHAR2 ,
                   X_Attribute12                            VARCHAR2 ,
                   X_Attribute13                            VARCHAR2 ,
                   X_Attribute14                            VARCHAR2 ,
                   X_Attribute15                            VARCHAR2 ,
                   X_Attribute16                            VARCHAR2 ,
                   X_Attribute17                            VARCHAR2 ,
                   X_Attribute18                            VARCHAR2 ,
                   X_Attribute19                            VARCHAR2 ,
                   X_Attribute20                            VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Position_Structure_Id               NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2 ,
                     X_Primary_Position_Flag               VARCHAR2 ,
                     X_Attribute_Category                  VARCHAR2 ,
                     X_Attribute1                          VARCHAR2 ,
                     X_Attribute2                          VARCHAR2 ,
                     X_Attribute3                          VARCHAR2 ,
                     X_Attribute4                          VARCHAR2 ,
                     X_Attribute5                          VARCHAR2 ,
                     X_Attribute6                          VARCHAR2 ,
                     X_Attribute7                          VARCHAR2 ,
                     X_Attribute8                          VARCHAR2 ,
                     X_Attribute9                          VARCHAR2 ,
                     X_Attribute10                         VARCHAR2 ,
                     X_Attribute11                         VARCHAR2 ,
                     X_Attribute12                         VARCHAR2 ,
                     X_Attribute13                         VARCHAR2 ,
                     X_Attribute14                         VARCHAR2 ,
                     X_Attribute15                         VARCHAR2 ,
                     X_Attribute16                         VARCHAR2 ,
                     X_Attribute17                         VARCHAR2 ,
                     X_Attribute18                         VARCHAR2 ,
                     X_Attribute19                         VARCHAR2 ,
                     X_Attribute20                         VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_Position_Structure_Id          NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Po_Installed                         VARCHAR2,
                     X_Hr_Installed                         VARCHAR2);

function postform(p_business_group_id NUMBER) return boolean;

END PER_POSITION_STRUCTURES_PKG;

 

/
