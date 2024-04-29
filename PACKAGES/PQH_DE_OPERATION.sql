--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATION" AUTHID CURRENT_USER As
/* $Header: pqoprpln.pkh 115.4 2002/12/12 05:22:31 vevenkat noship $ */
Procedure Insert_Rec
(p_BUSINESS_GROUP_ID              IN  NUMBER
,p_effective_Date                 IN  Date
,p_ENTITY_ID                      IN  Varchar2
,P_Parent_Entity_Id               IN  Number  Default NULL
,p_Operation_Group                IN  NUMBER
,p_TRN_TYPE                       IN  Varchar2
,p_HIERARCHY_NODE_ID              Out NOCOPY NUMBER
,p_Status                         Out NOCOPY Varchar2
,p_Object_Version_Number          Out NOCOPY Number);

Procedure Populate_Operations
(p_Business_group_Id             IN Number
,p_Vldtn_Ver_Op_Id               IN Number
,p_Hierarchy_Node_Id  		 IN Number
,p_Trn_Type                      IN Varchar2
,p_Operation_Job_Number          IN Varchar2
,p_Operation_Job_Id              IN Number);

Procedure Populate_Operation_PLan
(p_WRKPLC_VLDTN_VER_ID           IN Number
,p_Business_group_Id             IN Number
,p_Effective_Date                IN Date);
End;

 

/
