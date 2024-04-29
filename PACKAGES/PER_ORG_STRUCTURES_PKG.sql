--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURES_PKG" AUTHID CURRENT_USER as
/* $Header: peors01t.pkh 115.4 2002/12/06 15:37:42 pkakar ship $ */
------------------------------------------------------------------------------
PROCEDURE form_startup(p_business_group_id NUMBER
                      ,p_security_profile_id IN OUT NOCOPY NUMBER
                      ,p_view_all_orgs IN OUT NOCOPY VARCHAR2
                      ,p_hr_installed IN OUT NOCOPY VARCHAR2
                      ,p_pa_installed IN OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE check_name_unique(p_name VARCHAR2
                     ,p_business_group_id NUMBER
                     ,p_rowid VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE check_primary_flag(p_primary_flag VARCHAR2
                      ,p_business_group_id NUMBER
                      ,p_rowid VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE check_position_control_flag(
          p_organization_structure_id NUMBER
         ,p_pos_control_structure_flag VARCHAR2
         ,p_business_group_id NUMBER);
------------------------------------------------------------------------------
PROCEDURE delete_check(p_organization_structure_id NUMBER
                ,p_business_group_id NUMBER
                ,p_pa_installed VARCHAR2
                );
------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
               X_Organization_Structure_Id            IN OUT NOCOPY NUMBER,
               X_Business_Group_Id                    NUMBER,
               X_Name                                 VARCHAR2,
               X_Comments                             VARCHAR2,
               X_Primary_Structure_Flag               VARCHAR2,
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
               X_Attribute20                          VARCHAR2,
               X_Pos_Control_Structure_Flag           VARCHAR2
               );
------------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
             X_Organization_Structure_Id              NUMBER,
             X_Business_Group_Id                      NUMBER,
             X_Name                                   VARCHAR2,
             X_Comments                               VARCHAR2,
             X_Primary_Structure_Flag                 VARCHAR2,
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
             X_Attribute20                            VARCHAR2,
             X_Pos_Control_Structure_Flag             VARCHAR2
             );
------------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
               X_Organization_Structure_Id           NUMBER,
               X_Business_Group_Id                   NUMBER,
               X_Name                                VARCHAR2,
               X_Comments                            VARCHAR2,
               X_Primary_Structure_Flag              VARCHAR2,
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
               X_Attribute20                         VARCHAR2,
               X_Pos_Control_Structure_Flag          VARCHAR2
               );
------------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2
                     ,p_organization_structure_id NUMBER
                     ,p_business_group_id NUMBER
                     ,p_pa_installed VARCHAR2
                     );
------------------------------------------------------------------------------
function postform(p_business_group_id NUMBER
                 ,p_org_structure_version_id IN NUMBER) RETURN BOOLEAN;
-----------------------------------------------------------------------------
END PER_ORG_STRUCTURES_PKG;

 

/
