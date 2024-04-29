--------------------------------------------------------
--  DDL for Package PER_POS_STRUCT_ELEMENTS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_STRUCT_ELEMENTS_PKG2" AUTHID CURRENT_USER as
/* $Header: pepse02t.pkh 115.1 2002/12/04 16:15:35 eumenyio ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Pos_Structure_Element_Id             IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Pos_Structure_Version_Id             NUMBER,
                     X_Subordinate_Position_Id              NUMBER,
                     X_Parent_Position_Id                   NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Security_Profile_Id                  NUMBER,
                     X_View_All_Positions                   VARCHAR2,
                     X_End_of_time                          DATE,
                     X_Session_Date                         DATE,
                     X_hr_ins                               VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Pos_Structure_Element_Id               NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Pos_Structure_Version_Id               NUMBER,
                   X_Subordinate_Position_Id                NUMBER,
                   X_Parent_Position_Id                     NUMBER
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Pos_Structure_Element_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Subordinate_Position_Id             NUMBER,
                     X_Parent_Position_Id                  NUMBER,
                     X_Position_Id                         NUMBER
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_Business_Group_Id NUMBER,
                     X_Pos_Structure_Version_Id NUMBER,
                     X_Parent_Position_Id NUMBER,
                     X_Subordinate_Position_Id NUMBER,
                     X_hr_ins VARCHAR2,
                     X_Position_Id Number);

END PER_POS_STRUCT_ELEMENTS_PKG2;

 

/
