--------------------------------------------------------
--  DDL for Package PQH_DE_OPR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPR_GRP" AUTHID CURRENT_USER As
/* $Header: pqtskpln.pkh 115.2 2002/12/09 22:40:37 rpasapul noship $ */

/*REM  TYPE     => Pass 'P' for operation Plan, 'G' => for Operation group 'O' => Operation  'J' => Jobs
REM  TRNTYP   => 'I' => Insert  'S' => Select   'U' => Update */

Function Node_Sequence(P_Hierarchy_version_id  IN Number,
                       P_Parent_Hierarchy_Id   IN Number)
                       Return Number;
Procedure copy_Hierarchy
(P_Hierarchy_version_id             IN Number,
 P_Parent_Hierarchy_id              IN Number,
 P_Hierarchy_Id                     IN Number,
 p_Business_group_Id                IN Number,
 p_Effective_Date                   IN Date);

Procedure Main
(P_Type                             IN Varchar2,
 P_Trntype                          IN Varchar2,
 P_Code                             IN Varchar2  Default NULL,
 P_Description                      IN Varchar2  Default NULL,
 p_Code_Id                          IN Number    Default NULL,
 P_Hierarchy_version_id             IN Number    Default NULL,
 P_Parent_Hierarchy_id              IN Number    Default NULL,
 P_Hierarchy_Id                     IN Number    Default NULL,
 p_Object_Version_Number            IN Number    Default NULL,
 p_Business_group_Id                IN Number  ,
 p_Effective_Date                   IN Date);

Procedure Copy_Hierarchy_version
(P_Type                             IN Varchar2,
 P_Name                             IN Varchar2 Default NULL,
 P_Date_From                        IN Date     Default NULL,
 P_Date_To                          IN Date     Default NULL,
 P_Hierarchy_Id                     IN Number   Default NULL,
 P_Hierarchy_Version_Id             IN Number   Default NULL,
 P_Version_Number                   IN Number   Default NULL,
 P_Business_Group_id                IN Number  ,
 P_Effective_Date                   IN Date    ,
 P_New_hierarchy_Id                OUT NOCOPY Number  ,
 P_New_Hierarchy_Version_Id        OUT NOCOPY Number);

End;

 

/
