--------------------------------------------------------
--  DDL for Package PER_POS_STRUCTURE_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_STRUCTURE_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: pepse01t.pkh 115.5 2003/07/11 10:46:49 dcasemor ship $ */
-------------------------------------------------------------------------------
FUNCTION get_subordinates(X_View_All_Positions VARCHAR2
,X_Parent_Position_Id NUMBER
,X_Pos_Structure_Version_id NUMBER
,X_Security_Profile_Id NUMBER) RETURN NUMBER;
-------------------------------------------------------------------------------
PROCEDURE get_holders(X_Business_Group_Id NUMBER
,X_Position_Id NUMBER
,X_Organization_id NUMBER
,X_Holder IN OUT NOCOPY VARCHAR2
,X_No_Holders IN OUT NOCOPY NUMBER
,X_Session_date DATE
,X_Employee_Number IN OUT NOCOPY VARCHAR2
,X_User_Person_Type IN OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------
PROCEDURE block_post_query(X_Business_Group_Id NUMBER
,X_Position_Id NUMBER
,X_Organization_id IN OUT NOCOPY NUMBER
,X_Holder IN OUT NOCOPY VARCHAR2
,X_No_Holders IN OUT NOCOPY NUMBER
,X_Employee_Number IN OUT NOCOPY VARCHAR2
,X_Subordinate_position_id NUMBER
,X_View_All_Positions VARCHAR2
,X_Parent_Position_Id NUMBER
,X_Pos_Structure_Version_id NUMBER
,X_Security_Profile_Id NUMBER
,X_Session_date DATE
,X_exists_in_hierarchy IN OUT NOCOPY VARCHAR2
,X_Number_of_Subordinates IN OUT NOCOPY NUMBER
,X_User_Person_Type IN OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------
PROCEDURE maintain_pos_list(X_Business_Group_Id NUMBER
,X_Security_Profile_Id NUMBER
,X_View_All_Positions VARCHAR2
,X_Sec_Pos_Structure_Version_id NUMBER
,X_Position_Id NUMBER);
-------------------------------------------------------------------------------
PROCEDURE check_unique(X_Parent_position_id NUMBER
                      ,X_Pos_Structure_Version_Id NUMBER
                      ,X_Subordinate_Position_Id NUMBER);
-------------------------------------------------------------------------------
PROCEDURE pre_delete_checks(X_Subordinate_position_Id NUMBER
                           ,X_Position_Structure_Id NUMBER
                           ,X_Business_Group_Id NUMBER
                           ,X_Hr_Installed VARCHAR2
                           ,X_Pos_Structure_version_Id NUMBER);
-------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Pos_Structure_Element_Id             IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Pos_Structure_Version_Id             NUMBER,
                     X_Subordinate_Position_Id              NUMBER,
                     X_Parent_Position_Id                   NUMBER
                     );
-------------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Pos_Structure_Element_Id               NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Pos_Structure_Version_Id               NUMBER,
                   X_Subordinate_Position_Id                NUMBER,
                   X_Parent_Position_Id                     NUMBER
                   );
-------------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Pos_Structure_Element_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Pos_Structure_Version_Id            NUMBER,
                     X_Subordinate_Position_Id             NUMBER,
                     X_Parent_Position_Id                  NUMBER
                     );
-------------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2
                    ,X_Subordinate_position_Id NUMBER
                    ,X_Position_Structure_Id NUMBER
                    ,X_Business_Group_Id NUMBER
                    ,X_Hr_Installed VARCHAR2
                    ,X_Pos_Structure_version_Id NUMBER);

END PER_POS_STRUCTURE_ELEMENTS_PKG;

 

/
