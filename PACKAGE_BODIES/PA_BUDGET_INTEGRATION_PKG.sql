--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_INTEGRATION_PKG" AS
       /* $Header: PABDINTB.pls 120.3 2006/02/16 11:27:56 bkattupa noship $ */

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
--  Parameters          : Ref: P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
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
  p_Bdgt_Cntrl_Flag	      IN    VARCHAR2,
  P_FC_Level_Project          IN    VARCHAR2,
  P_FC_Level_Task             IN    VARCHAR2,
  P_FC_Level_RsrcGrp          IN    VARCHAR2,
  P_FC_Level_Rsrs             IN    VARCHAR2,
  P_Amount_Type               IN    VARCHAR2,
  P_Boundary_Code             IN    VARCHAR2,
  p_Project_Type_Org_ID       IN    NUMBER,
  p_Last_Update_Date          IN    DATE,
  p_Last_Updated_By           IN    NUMBER,
  p_Creation_Date             IN    DATE,
  p_Created_By                IN    NUMBER,
  p_Last_Update_Login         IN    NUMBER
)
AS
BEGIN

  BEGIN
    INSERT INTO PA_BUDGETARY_CONTROL_OPTIONS (
                Project_Type,
                Project_ID,
                Balance_Type,
                Budget_Type_Code,
                External_Budget_Code,
                GL_Budget_Version_ID,
                Encumbrance_Type_ID,
                Bdgt_Cntrl_Flag,
                Fund_Control_Level_Project,
                Fund_Control_Level_Task,
                Fund_Control_Level_Res_Grp,
                Fund_Control_Level_Res,
                Amount_Type,
                Boundary_Code,
		Project_Type_Org_ID,
                Last_Update_Date,
                Last_Updated_By,
                Creation_Date,
                Created_By,
                Last_Update_Login
              )
              VALUES (
                P_Project_Type,
                P_Project_ID,
                P_Balance_Type,
                P_Budget_Type_Code,
                P_External_Budget_Code,
                P_GL_Budget_Version_ID,
                P_Encumbrance_Type_ID,
                P_Bdgt_Cntrl_Flag,
                P_FC_Level_Project,
                P_FC_Level_Task,
                P_FC_Level_RsrcGrp,
                P_FC_Level_Rsrs,
                P_Amount_Type,
                P_Boundary_Code,
		P_Project_Type_Org_ID,
                P_Last_Update_Date,
                P_Last_Updated_By,
                P_Creation_Date,
                P_Created_By,
                P_Last_Update_Login
              );
  END;

  -- Fetch the rowid that is inserted into a table which will be used for
  -- updating/deleting the same record if performed in the same
  -- session (in SQL*Forms) ==> For details refer to the appln. Dev. Stds.
  BEGIN
    SELECT 	RowID
    INTO   	X_RowID
    FROM   	PA_BUDGETARY_CONTROL_OPTIONS
    WHERE  	Budget_Type_Code = P_Budget_Type_Code
    AND    	( Project_ID 	 = P_Project_ID OR Project_Type = P_Project_Type)
    AND         nvl(Project_Type_Org_ID,-99) = nvl(P_Project_Type_Org_ID,-99) ;  -- Added for bug #4772022
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_ERROR');
      APP_EXCEPTION.Raise_Exception;
    WHEN TOO_MANY_ROWS THEN
      FND_MESSAGE.Set_Name('FND', 'PA_BC_DUPLCT_BDGT_TYP');
      APP_EXCEPTION.Raise_Exception;
  END;

END Insert_Row;

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
  p_Bdgt_Cntrl_Flag	      IN    VARCHAR2,
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
)
AS
BEGIN

    UPDATE PA_BUDGETARY_CONTROL_OPTIONS
    SET
      Project_Type         	 = p_Project_Type,
      Project_ID               	 = p_Project_ID,
      Balance_Type               = p_Balance_Type,
      Budget_Type_Code     	 = p_Budget_Type_Code,
      External_Budget_Code 	 = p_External_Budget_Code,
      GL_Budget_Version_ID 	 = p_GL_Budget_Version_ID,
      Encumbrance_Type_ID  	 = p_Encumbrance_Type_ID,
      Bdgt_Cntrl_Flag        	 = p_Bdgt_Cntrl_Flag,
      Fund_Control_Level_Project = P_FC_Level_Project,
      Fund_Control_Level_Task    = P_FC_Level_Task,
      Fund_Control_Level_Res_Grp = P_FC_Level_RsrcGrp,
      Fund_Control_Level_Res     = P_FC_Level_Rsrs,
      Amount_Type                = p_Amount_Type,
      Boundary_Code              = p_Boundary_Code,
      Last_Update_Date     	 = p_Last_Update_Date,
      Last_Updated_By      	 = p_Last_Updated_By,
      Creation_Date        	 = p_Creation_Date,
      Created_By           	 = p_Created_By,
      Last_Update_Login    	 = p_Last_Update_Login
    WHERE
      rowid = p_Rowid;

    IF (SQL%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_ERROR');
      APP_EXCEPTION.Raise_Exception;
    END IF;

END Update_Row;

----------------------------------------------------------------------------------------
--  Procedure           : Delete_Row
--  Purpose             : To Delete a record from PA_BUDGETARY_CONTROL_OPTIONS table
--  Parameters          : ? Ref: P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------
PROCEDURE Delete_Row  (
  p_Rowid                   	IN    ROWID
)
AS
BEGIN

    DELETE FROM PA_BUDGETARY_CONTROL_OPTIONS
    WHERE 	RowID  = p_Rowid;

    IF (SQL%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_ERROR');
      APP_EXCEPTION.Raise_Exception;
    END IF;

END Delete_Row;


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
  p_Bdgt_Cntrl_Flag	      IN    VARCHAR2,
  P_FC_Level_Project          IN    VARCHAR2,
  P_FC_Level_Task             IN    VARCHAR2,
  P_FC_Level_RsrcGrp          IN    VARCHAR2,
  P_FC_Level_Rsrs             IN    VARCHAR2,
  P_Amount_Type               IN    VARCHAR2,
  P_Boundary_Code             IN    VARCHAR2
)
IS

Cursor C is
  SELECT
    Project_Type,
    Project_ID,
    Balance_Type,
    Budget_Type_Code,
    External_Budget_Code,
    GL_Budget_Version_ID,
    Encumbrance_Type_ID,
    Bdgt_Cntrl_Flag,
    Amount_Type,
    Boundary_Code
  FROM
    PA_BUDGETARY_CONTROL_OPTIONS
  WHERE
    RowID = p_RowID
    FOR UPDATE OF Budget_Type_Code NOWAIT;

RecInfo C%RowType;

BEGIN

  OPEN C;
  FETCH C INTO RecInfo;

  -- Check whether the record is present in the same session
  -- If not present, then it is deleted, so display the error message
  IF (C%NOTFOUND)
  THEN
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_LOCKED');
    APP_EXCEPTION.Raise_Exception;
  END IF;

  -- Check whether the record is existing in the same session
  -- If present, then return without displaying the error message
  IF (  (Recinfo.Budget_Type_Code =  p_Budget_Type_Code)
      AND
         ( (Recinfo.Project_Type =  p_Project_Type) OR
           ( (Recinfo.Project_Type IS NULL) AND (p_Project_Type IS NULL))
         )
      AND
         ( (Recinfo.Project_ID =  p_Project_ID) OR
           ( (Recinfo.Project_ID IS NULL) AND (p_Project_ID IS NULL))
         )
      AND
         ( (Recinfo.Balance_Type =  p_Balance_Type) OR
           ( (Recinfo.Balance_Type IS NULL) AND (p_Balance_Type IS NULL))
         )
      AND
         ( (Recinfo.External_Budget_Code =  p_External_Budget_Code) OR
           ( (Recinfo.External_Budget_Code IS NULL) AND (p_External_Budget_Code IS NULL))
         )
      AND
         ( (Recinfo.GL_Budget_Version_ID =  p_GL_Budget_Version_ID) OR
           ( (Recinfo.GL_Budget_Version_ID IS NULL) AND (p_GL_Budget_Version_ID IS NULL))
         )
      AND
         ( (Recinfo.Encumbrance_Type_ID =  p_Encumbrance_Type_ID) OR
           ( (Recinfo.Encumbrance_Type_ID IS NULL) AND (p_Encumbrance_Type_ID IS NULL))
         )
      AND
         ( (Recinfo.Bdgt_Cntrl_Flag =  p_Bdgt_Cntrl_Flag) OR
           ( (Recinfo.Bdgt_Cntrl_Flag IS NULL) AND (p_Bdgt_Cntrl_Flag IS NULL))
         )
      AND
         ( (Recinfo.Amount_Type =  p_Amount_Type) OR
           ( (Recinfo.Amount_Type IS NULL) AND (p_Amount_Type IS NULL))
         )
      AND
         ( (Recinfo.Boundary_Code =  p_Boundary_Code) OR
           ( (Recinfo.Boundary_Code IS NULL) AND (p_Boundary_Code IS NULL))
         )
     )
  THEN
    RETURN;
  ELSE
    -- After scanning all the data elements, if any of the element is not matching
    -- with the current record, then the record is changed, so display the error message
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
END Lock_Row;

END PA_BUDGET_INTEGRATION_PKG ; /* End Package Specifications PA_BUDGET_INTEGRATION_PKG */

/
