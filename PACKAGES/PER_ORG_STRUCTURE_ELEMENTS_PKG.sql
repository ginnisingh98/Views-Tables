--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURE_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURE_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: peose01t.pkh 120.1.12010000.2 2009/02/25 08:30:37 sidsaxen ship $ */
------------------------------------------------------------------------------
FUNCTION get_subordinates(p_view_all_orgs VARCHAR2
                         ,p_org_id_parent NUMBER
                         ,p_org_structure_version_id NUMBER
                         ,p_security_profile_id NUMBER) return NUMBER;
------------------------------------------------------------------------------
PROCEDURE maintain_org_lists(p_business_group_id  NUMBER
                            ,p_security_profile_id  NUMBER
                            ,p_organization_id  NUMBER);
------------------------------------------------------------------------------
PROCEDURE delete_validation(p_org_structure_version_id NUMBER
                           ,p_org_structure_element_id NUMBER
                           ,p_org_id_child NUMBER
                           ,p_org_id_parent NUMBER
                           ,p_hr_installed VARCHAR2
                           ,p_pa_installed VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE perwsdor_delete_check(p_org_structure_version_id NUMBER
                               ,p_org_structure_element_id NUMBER
                               ,p_org_id_child NUMBER
                               ,p_org_id_parent NUMBER
                               ,p_business_group_id NUMBER
                               ,p_hr_installed VARCHAR2
                               ,p_pa_installed VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE check_duplicate_entry (p_org_structure_version_id NUMBER
                   ,p_org_structure_element_id NUMBER);
------------------------------------------------------------------------------
PROCEDURE check_org_active(p_Org_Id_Parent NUMBER
                   ,p_date_from DATE
                   ,p_end_of_time DATE
                   ,p_warning_raised IN OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------
PROCEDURE check_position_flag (
                    p_org_structure_version_id NUMBER
                   ,p_pos_control_enabled_flag VARCHAR2);
------------------------------------------------------------------------------
FUNCTION post_delete_check(p_org_structure_version_id NUMBER
                           ,p_organization_id NUMBER) return BOOLEAN;
------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                         IN OUT NOCOPY VARCHAR2,
                     p_Org_Structure_Element_Id             IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                    NUMBER,
                     p_Organization_Id_Parent               NUMBER,
                     p_Org_Structure_Version_Id             NUMBER,
                     p_Organization_Id_Child                NUMBER,
                     p_date_from                            DATE,
                     p_security_profile_id                  NUMBER,
                     p_view_all_orgs                        VARCHAR2,
                     p_end_of_time                          DATE,
                     p_pos_control_enabled_flag             VARCHAR2
                     );
------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                         IN OUT NOCOPY VARCHAR2,
                     p_Org_Structure_Element_Id             IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                    NUMBER,
                     p_Organization_Id_Parent               NUMBER,
                     p_Org_Structure_Version_Id             NUMBER,
                     p_Organization_Id_Child                NUMBER,
                     p_date_from                            DATE,
                     p_security_profile_id                  NUMBER,
                     p_view_all_orgs                        VARCHAR2,
                     p_end_of_time                          DATE,
                     p_pos_control_enabled_flag             VARCHAR2,
                     p_warning_raised                IN OUT NOCOPY VARCHAR2
                     );
------------------------------------------------------------------------------
-- added for bug 8200692
PROCEDURE Insert_Row(p_Rowid                         IN OUT NOCOPY VARCHAR2,
                     p_Org_Structure_Element_Id             IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                    NUMBER,
                     p_Organization_Id_Parent               NUMBER,
                     p_Org_Structure_Version_Id             NUMBER,
                     p_Organization_Id_Child                NUMBER,
                     p_date_from                            DATE,
                     p_security_profile_id                  NUMBER,
                     p_view_all_orgs                        VARCHAR2,
                     p_end_of_time                          DATE,
                     p_pos_control_enabled_flag             VARCHAR2,
                     p_warning_raised                IN OUT NOCOPY VARCHAR2,
                     p_pa_installed                         VARCHAR2
                     );
------------------------------------------------------------------------------
PROCEDURE Lock_Row(p_Rowid                                  VARCHAR2,
                   p_Org_Structure_Element_Id               NUMBER,
                   p_Business_Group_Id                      NUMBER,
                   p_Organization_Id_Parent                 NUMBER,
                   p_Org_Structure_Version_Id               NUMBER,
                   p_Organization_Id_Child                  NUMBER,
                   p_pos_control_enabled_flag               VARCHAR2
                   );
------------------------------------------------------------------------------
PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Org_Structure_Element_Id            NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Organization_Id_Parent              NUMBER,
                     p_Org_Structure_Version_Id            NUMBER,
                     p_Organization_Id_Child               NUMBER,
                     p_pos_control_enabled_flag            VARCHAR2
                     );
------------------------------------------------------------------------------
--bug no 5912009 starts here
PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Org_Structure_Element_Id            NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Organization_Id_Parent              NUMBER,
                     p_Org_Structure_Version_Id            NUMBER,
                     p_Organization_Id_Child               NUMBER,
                     p_pos_control_enabled_flag            VARCHAR2
                     ,p_pa_installed                        VARCHAR2
                     );
--bug no 5912009 ends here
------------------------------------------------------------------------------
PROCEDURE Delete_Row(p_Rowid VARCHAR2
                     ,p_org_structure_version_id NUMBER
                     ,p_org_structure_element_id NUMBER
                     ,p_Organization_Id_Child NUMBER
                     ,p_Organization_Id_Parent NUMBER
                     ,p_hr_installed VARCHAR2
                     ,p_exists_in_hierarchy IN OUT NOCOPY VARCHAR2
                     ,p_pa_installed VARCHAR2);
------------------------------------------------------------------------------
END PER_ORG_STRUCTURE_ELEMENTS_PKG;

/
