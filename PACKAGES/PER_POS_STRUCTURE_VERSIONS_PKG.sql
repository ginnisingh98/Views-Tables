--------------------------------------------------------
--  DDL for Package PER_POS_STRUCTURE_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_STRUCTURE_VERSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pepsv01t.pkh 115.1 2003/02/11 11:54:54 eumenyio ship $ */

------------------------------------------------------------------------------
FUNCTION get_next_free_no(X_Position_Structure_Id NUMBER) return NUMBER;
------------------------------------------------------------------------------
PROCEDURE check_version_number(X_Position_Structure_Id NUMBER
                              ,X_Version_Number NUMBER
                              ,X_Rowid VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE check_date_gap(X_Date_From                        DATE,
                         X_Date_To                          DATE ,
                         X_Position_Structure_Id            NUMBER,
                         X_gap_warning                      IN OUT NOCOPY VARCHAR2,
                         X_Rowid                            VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE check_overlap(X_Position_Structure_Id NUMBER
                       ,X_Rowid VARCHAR2
                       ,X_Date_From DATE
                       ,X_Date_To DATE
                       ,X_End_Of_Time DATE
                       ,X_End_Date_Closedown IN OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE copy_elements(X_Pos_Structure_Version_Id NUMBER
                        ,X_Copy_Structure_Version_Id NUMBER);
------------------------------------------------------------------------------
PROCEDURE pre_delete_checks(X_Pos_Structure_Version_Id      NUMBER,
                            X_Business_Group_Id             NUMBER,
									 X_Position_Structure_Id         NUMBER,
                            X_Hr_Installed                  VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Pos_Structure_Version_Id             IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Position_Structure_Id                NUMBER,
                     X_Date_From                            DATE,
                     X_Version_Number                       NUMBER,
                     X_Copy_Structure_Version_Id            NUMBER ,
                     X_Date_To                              DATE ,
                     X_end_of_time                         DATE,
                     X_Next_no_free                 IN OUT NOCOPY NUMBER,
                     X_closedown_warning            IN OUT NOCOPY VARCHAR2,
                     X_gap_warning                  IN OUT NOCOPY VARCHAR2
                     );
------------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Pos_Structure_Version_Id               NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Position_Structure_Id                  NUMBER,
                   X_Date_From                              DATE,
                   X_Version_Number                         NUMBER,
                   X_Copy_Structure_Version_Id              NUMBER ,
                   X_Date_To                                DATE
                   );
------------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Position_Structure_Id               NUMBER,
                     X_Date_From                           DATE,
                     X_Version_Number                      NUMBER,
                     X_Copy_Structure_Version_Id           NUMBER ,
                     X_Date_To                             DATE ,
                     X_end_of_time                         DATE,
                     X_Next_no_free                 IN OUT NOCOPY NUMBER,
                     X_closedown_warning            IN OUT NOCOPY VARCHAR2,
                     X_gap_warning                  IN OUT NOCOPY VARCHAR2
                     );
------------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
							X_Position_Structure_Id NUMBER,
                     X_Hr_Installed                        VARCHAR2,
                     X_Next_no_free                 IN OUT NOCOPY NUMBER,
                     X_closedown_warning            IN OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------------
END PER_POS_STRUCTURE_VERSIONS_PKG;

 

/
