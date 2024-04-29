--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_UNITS_PKG" AUTHID CURRENT_USER as
/* $Header: peoru01t.pkh 115.8 2002/12/06 15:52:51 pkakar ship $ */
--
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_ORGANIZATION_UNITS_PKG.';
--
PROCEDURE chk_repbody_seat_numbers
  (p_organization_id         IN hr_organization_units.organization_id%TYPE
  ,p_org_information_context IN hr_organization_information.org_information_context%TYPE
  ,p_org_information6        IN hr_organization_information.org_information6%TYPE
  ,p_org_information2        IN hr_organization_information.org_information2%TYPE
  ,p_rowid                   IN VARCHAR2);
--
FUNCTION Is_Org_A_Node
  (p_search_org_id             IN hr_organization_units.organization_id%TYPE
  ,p_organization_structure_id IN per_org_structure_versions_v.organization_structure_id%TYPE)
  RETURN CHAR;
--
function exists_in_hierarchy(p_org_structure_version_id NUMBER
                             ,p_organization_id NUMBER) return varchar2;
function get_parent(p_organization_id NUMBER
                   ,p_org_structure_version_id NUMBER) return NUMBER;
procedure form_post_query(p_exists_in_hierarchy in out nocopy VARCHAR2
                         ,p_view_all_orgs VARCHAR2
                         ,p_organization_id NUMBER
                         ,p_org_structure_version_id NUMBER
                         ,p_security_profile_id NUMBER
                         ,p_number_of_subordinates in out nocopy NUMBER);
--
procedure check_gre(p_org_id NUMBER);
--
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,

                     X_Organization_Id                      IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Cost_Allocation_Keyflex_Id           NUMBER,
                     X_Location_Id                          NUMBER,
                     X_Soft_Coding_Keyflex_Id               NUMBER,
                     X_Date_From                            DATE,
                     X_Name                                 VARCHAR2,
                     X_Comments                             VARCHAR2,
                     X_Date_To                              DATE,
                     X_Internal_External_Flag               VARCHAR2,
                     X_Internal_Address_Line                VARCHAR2,
                     X_Type                                 VARCHAR2,
             X_Security_Profile_Id                  NUMBER,
             X_View_All_Orgs                        VARCHAR2,
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
                   X_Organization_Id                        NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Cost_Allocation_Keyflex_Id             NUMBER,
                   X_Location_Id                            NUMBER,
                   X_Soft_Coding_Keyflex_Id                 NUMBER,
                   X_Date_From                              DATE,
                   X_Name                                   VARCHAR2,
                   X_Comments                               VARCHAR2,
                   X_Date_To                                DATE,
                   X_Internal_External_Flag                 VARCHAR2,
                   X_Internal_Address_Line                  VARCHAR2,
                   X_Type                                   VARCHAR2,
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
                     X_Organization_Id                     NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Cost_Allocation_Keyflex_Id          NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Soft_Coding_Keyflex_Id              NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Internal_External_Flag              VARCHAR2,
                     X_Internal_Address_Line               VARCHAR2,
                     X_Type                                VARCHAR2,
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

PROCEDURE Delete_Row(X_Rowid           VARCHAR2,
                     X_Business_Group_Id NUMBER,
                     X_Organization_Id NUMBER,
             X_View_All_Orgs   VARCHAR2);
--
PROCEDURE zoom_forms(X_destination IN VARCHAR2
                    ,X_ORGANIZATION_ID IN NUMBER
                          ,X_SOB_ID IN OUT NOCOPY NUMBER
                          ,X_ORG_CODE IN OUT NOCOPY VARCHAR2
                          ,X_CHART_OF_ACCOUNTS IN OUT NOCOPY NUMBER);
--
PROCEDURE ADD_LANGUAGE;
--
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                  p_legislation_code IN VARCHAR2);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure validate_TRANSLATION (organization_id IN    number,
                language IN             varchar2,
                                name IN  varchar2,
                p_business_group_id IN NUMBER DEFAULT NULL);
--------------------------------------------------------------------------------
function get_org_class (X_Organization_Id NUMBER, X_Organization_Class VARCHAR2)
return boolean;
--
END HR_ORGANIZATION_UNITS_PKG;

 

/
