--------------------------------------------------------
--  DDL for Package PA_BUDGET_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_INTEGRATION_PKG" AUTHID CURRENT_USER AS
       /* $Header: PABDINTS.pls 120.1 2005/08/08 14:49:27 pbandla noship $ */

----------------------------------------------------------------------------------------
--  Package             : PA_BUDGET_INTEGRATION_PKG
--  Purpose             : Table Handlers APIs to Insert/Update/Delete/Lock a record
--                        thru SQL Form
--  Parameters          :
--     P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
--  Procedure           : Insert_Row
--  Purpose             : To insert a record into PA_BUDGETARY_CONTROL_OPTIONS table
--  Parameters          : ? Ref: P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------
PROCEDURE Insert_Row  (
  X_Rowid                     OUT   NOCOPY ROWID,
  p_Project_Type              IN    VARCHAR2,
  p_Project_ID                IN    NUMBER,
  p_Balance_Type              IN    VARCHAR2,
  p_Budget_Type_Code          IN    VARCHAR2,
  p_External_Budget_Code      IN    VARCHAR2,
  p_GL_Budget_Version_ID      IN    NUMBER,
  p_Encumbrance_Type_ID       IN    NUMBER,
  p_Bdgt_Cntrl_Flag           IN    VARCHAR2,
  P_FC_Level_Project          IN    VARCHAR2,
  P_FC_Level_Task             IN    VARCHAR2,
  P_FC_Level_RsrcGrp          IN    VARCHAR2,
  P_FC_Level_Rsrs             IN    VARCHAR2,
  P_Amount_Type               IN    VARCHAR2,
  P_Boundary_Code             IN    VARCHAR2,
  P_Project_Type_Org_ID       IN    NUMBER,
  p_Last_Update_Date          IN    DATE,
  p_Last_Updated_By           IN    NUMBER,
  p_Creation_Date             IN    DATE,
  p_Created_By                IN    NUMBER,
  p_Last_Update_Login         IN    NUMBER
);

----------------------------------------------------------------------------------------
--  Procedure           : Update_Row
--  Purpose             : To Update a record in PA_BUDGETARY_CONTROL_OPTIONS table
--  Parameters          : ? Ref: P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------
PROCEDURE Update_Row  (
  p_Rowid                     IN    ROWID,
  p_Project_Type              IN    VARCHAR2,
  p_Project_ID                IN    NUMBER,
  p_Balance_Type              IN    VARCHAR2,
  p_Budget_Type_Code          IN    VARCHAR2,
  p_External_Budget_Code      IN    VARCHAR2,
  p_GL_Budget_Version_ID      IN    NUMBER,
  p_Encumbrance_Type_ID       IN    NUMBER,
  p_Bdgt_Cntrl_Flag           IN    VARCHAR2,
  P_FC_Level_Project          IN    VARCHAR2,
  P_FC_Level_Task             IN    VARCHAR2,
  P_FC_Level_RsrcGrp          IN    VARCHAR2,
  P_FC_Level_Rsrs             IN    VARCHAR2,
  P_Amount_Type               IN    VARCHAR2,
  P_Boundary_Code             IN    VARCHAR2,
  p_Last_Update_Date          IN    DATE,
  p_Last_Updated_By           IN    NUMBER,
  p_Creation_Date             IN    DATE,
  p_Created_By                IN    NUMBER,
  p_Last_Update_Login         IN    NUMBER
);

----------------------------------------------------------------------------------------
--  Procedure           : Delete_Row
--  Purpose             : To Delete a record from PA_BUDGETARY_CONTROL_OPTIONS table
--  Parameters          : ? Ref: P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------
PROCEDURE Delete_Row  (
  p_Rowid                     IN    ROWID
);

----------------------------------------------------------------------------------------
--  Procedure           : Lock_Row
--  Purpose             : To Lock a record in PA_BUDGETARY_CONTROL_OPTIONS table
--  Parameters          : ? Ref: P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------
PROCEDURE Lock_Row  (
  p_Rowid                     IN    ROWID,
  p_Project_Type              IN    VARCHAR2,
  p_Project_ID                IN    NUMBER,
  p_Balance_Type              IN    VARCHAR2,
  p_Budget_Type_Code          IN    VARCHAR2,
  p_External_Budget_Code      IN    VARCHAR2,
  p_GL_Budget_Version_ID      IN    NUMBER,
  p_Encumbrance_Type_ID       IN    NUMBER,
  p_Bdgt_Cntrl_Flag           IN    VARCHAR2,
  P_FC_Level_Project          IN    VARCHAR2,
  P_FC_Level_Task             IN    VARCHAR2,
  P_FC_Level_RsrcGrp          IN    VARCHAR2,
  P_FC_Level_Rsrs             IN    VARCHAR2,
  P_Amount_Type               IN    VARCHAR2,
  P_Boundary_Code             IN    VARCHAR2
);

END PA_BUDGET_INTEGRATION_PKG ; /* End Package Specifications PA_BUDGET_INTEGRATION_PKG */

 

/
