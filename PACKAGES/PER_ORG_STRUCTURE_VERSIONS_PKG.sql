--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURE_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURE_VERSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: peosv01t.pkh 115.2 2002/12/06 16:34:42 pkakar ship $ */
------------------------------------------------------------------------------
FUNCTION get_next_free_no(p_Org_Structure_Version_Id NUMBER) return NUMBER;
------------------------------------------------------------------------------
PROCEDURE check_date_gaps(p_org_structure_id NUMBER
                         ,p_date_to DATE
                         ,p_date_from DATE
                         ,p_rowid VARCHAR2
                         ,p_gap_warning in out nocopy VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE check_version_number(p_org_structure_id NUMBER
                              ,p_version_number NUMBER
                              ,p_rowid VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE check_overlap(p_org_structure_id NUMBER
                     ,p_rowid VARCHAR2
                     ,p_date_from DATE
                     ,p_date_to DATE
                     ,p_end_of_time DATE
                     ,p_end_date_closedown in out nocopy  VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE copy_elements(p_org_structure_Version_id NUMBER
							  ,p_copy_structure_version_id NUMBER);
------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                         IN OUT NOCOPY VARCHAR2,
                     p_Org_Structure_Version_Id             IN OUT NOCOPY NUMBER,
                     p_Business_Group_Id                    NUMBER,
                     p_Organization_Structure_Id            NUMBER,
                     p_Date_From                            DATE,
                     p_Version_Number                       NUMBER,
                     p_Copy_Structure_Version_Id            NUMBER,
                     p_Date_To                              DATE,
                     p_Pos_Ctrl_Enabled_Flag                VARCHAR2,
                     p_end_of_time                          DATE,
                     p_Next_no_free                 IN OUT NOCOPY NUMBER,
                     p_closedown_warning            IN OUT NOCOPY VARCHAR2,
                     p_gap_warning                  IN OUT NOCOPY VARCHAR2
                     );
------------------------------------------------------------------------------
--
PROCEDURE Lock_Row(p_Rowid                                  VARCHAR2,
                   p_Org_Structure_Version_Id               NUMBER,
                   p_Business_Group_Id                      NUMBER,
                   p_Organization_Structure_Id              NUMBER,
                   p_Date_From                              DATE,
                   p_Version_Number                         NUMBER,
                   p_Copy_Structure_Version_Id              NUMBER,
                   p_Date_To                                DATE,
                   p_Pos_Ctrl_Enabled_Flag                  VARCHAR2
                   );
------------------------------------------------------------------------------
--
PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Org_Structure_Version_Id            NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Organization_Structure_Id           NUMBER,
                     p_Date_From                           DATE,
                     p_Version_Number                      NUMBER,
                     p_Copy_Structure_Version_Id           NUMBER,
                     p_Date_To                             DATE,
                     p_Pos_Ctrl_Enabled_Flag               VARCHAR2,
                     p_end_of_time                         DATE,
                     p_Next_no_free                 IN OUT NOCOPY NUMBER,
                     p_closedown_warning            IN OUT NOCOPY VARCHAR2,
                     p_gap_warning                  IN OUT NOCOPY VARCHAR2
                     );
------------------------------------------------------------------------------
PROCEDURE pre_delete_checks(p_org_Structure_Version_Id NUMBER,
                     p_Pa_Installed VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE update_copied_versions(p_org_Structure_Version_Id NUMBER);
------------------------------------------------------------------------------
PROCEDURE Delete_Row(p_Rowid VARCHAR2,
                     p_Organization_Structure_Id NUMBER,
                     p_org_Structure_Version_Id NUMBER,
                     p_Pa_Installed VARCHAR2,
                     p_Date_From DATE,
                     p_Date_To DATE,
                     p_gap_warning IN OUT NOCOPY VARCHAR2,
                     p_Next_no_free IN OUT NOCOPY NUMBER);
------------------------------------------------------------------------------
END PER_ORG_STRUCTURE_VERSIONS_PKG;

 

/
