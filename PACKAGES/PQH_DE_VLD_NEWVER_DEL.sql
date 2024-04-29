--------------------------------------------------------
--  DDL for Package PQH_DE_VLD_NEWVER_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLD_NEWVER_DEL" AUTHID CURRENT_USER As
/* $Header: pqhverdl.pkh 115.2 2002/12/03 00:07:38 rpasapul noship $ */
 Procedure PQH_DE_CREATE_VERSION
 (p_WRKPLC_VLDTN_VER_ID In Number,
  P_Business_Group_Id   In Number);

 Procedure PQH_DE_DELETE_VERSION
 (p_WRKPLC_VLDTN_VER_ID In Number,
  P_Business_Group_Id   In Number);

 Procedure PQH_DE_DELETE_OPERATION
 (p_WRKPLC_VLDTN_OP_ID In Number,
  P_Business_Group_Id   In Number);

 Procedure PQH_DE_DELETE_JOB
 (p_WRKPLC_VLDTN_JOB_ID In Number,
  P_Business_Group_Id   In Number);
Procedure PQH_DE_IN_UP_CALL
 (
   P_EFFECTIVE_DATE            IN        	DATE
  ,P_BUSINESS_GROUP_ID         IN   		NUMBER
  ,P_WRKPLC_VLDTN_VER_ID       IN  		NUMBER
  ,P_LEVEL_NUMBER_ID           IN    		NUMBER
  ,P_LEVEL_CODE_ID             IN   		NUMBER
  ,P_WRKPLC_VLDTN_LVLNUM_ID    IN OUT NOCOPY   	NUMBER
  ,P_OBJECT_VERSION_NUMBER     IN OUT NOCOPY   	NUMBER
  ,P_RETURN_STATUS             OUT NOCOPY   	VARCHAR2
);
End;

 

/
