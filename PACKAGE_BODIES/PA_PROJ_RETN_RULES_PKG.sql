--------------------------------------------------------
--  DDL for Package Body PA_PROJ_RETN_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_RETN_RULES_PKG" as
/* $Header: PAPJRETB.pls 120.2 2005/08/19 16:41:17 mwasowic noship $ */


  -----------------------------------------------------------------
  -- Insert the retention record
  -----------------------------------------------------------------

  PROCEDURE Insert_Row(
	X_Rowid                  IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	P_Project_ID			NUMBER,
        P_Task_Number	 		VARCHAR2,
        P_Task_Name			VARCHAR2,
	P_Customer_ID			NUMBER,
	P_Retention_Level_Code	 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Expenditure_Category   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Expenditure_Type       IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Non_Labor_Resource     IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Revenue_Category       IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Event_Type             IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Retention_Percentage          NUMBER,
	P_Retention_Amount              NUMBER,
	P_Threshold_Amount              NUMBER,
	P_Effective_Start_Date          DATE,
	P_Effective_End_Date            DATE,
	P_Task_Flag			VARCHAR2,
	X_Return_Status_code	IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Error_Message_Code	IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

l_Revenue_Category_Code VARCHAR2(100);
l_Task_ID               NUMBER;
l_Retention_Rule_ID	NUMBER;
l_retention_percentage number;


l_row_id VARCHAR2(30) := X_Rowid;
l_retention_level_code VARCHAR2(30) := P_Retention_Level_Code;
l_expenditure_category VARCHAR2(30) := P_Expenditure_Category ;
l_expenditure_type VARCHAR2(30) := P_Expenditure_Type ;
l_non_labor_resource VARCHAR2(30) := P_Non_Labor_Resource ;
l_revenue_category VARCHAR2(30) := P_Revenue_Category ;
l_event_type VARCHAR2(30) := P_Event_Type ;

BEGIN

   --- Performing Validations
/* As null cannot be passed in this parameter, 2004 is explicitly assigned in the RetentionEditCO .java
  This is unset here */

   if p_retention_percentage = 2004 then
      l_retention_percentage := null;
   else
      l_retention_percentage := p_retention_percentage;
   end if;

   PA_Retention_Util.Validate_Retention_Data (
	P_RowID                 => NULL,
        P_Project_ID		=> P_Project_ID,
        P_Task_Number		=> P_Task_Number,
        P_Task_Name		=> P_Task_Name,
        P_Customer_ID	 	=> P_Customer_ID,
	P_Retention_Level_Code  => P_Retention_Level_Code,
        P_Expenditure_Category  => P_Expenditure_Category,
	P_Expenditure_Type 	=> P_Expenditure_Type,
	P_Non_Labor_Resource    => P_Non_Labor_Resource,
	X_Revenue_Category_Code => l_Revenue_Category_Code,
	P_Revenue_Category      => P_Revenue_Category,
	P_Event_Type            => P_Event_Type,
        P_Retention_Percentage  => l_Retention_Percentage,
	P_Retention_Amount      => P_Retention_Amount,
	P_Threshold_Amount      => P_Threshold_Amount,
        P_Effective_Start_Date 	=> P_Effective_Start_Date,
        P_Effective_End_Date	=> P_Effective_End_Date,
	P_Task_Flag		=> P_Task_Flag,
	X_Task_ID               => l_Task_ID,
        X_Return_Status_Code	=> X_Return_Status_Code,
        X_Error_Message_Code	=> X_Error_Message_Code
   );

   IF X_Return_Status_Code = FND_API.G_RET_STS_ERROR
   THEN
     RETURN;
   ELSE
     -- Fix for Bug 2671135
     BEGIN
       SELECT PA_PROJ_RETN_RULES_S.NextVal
       INTO   l_Retention_Rule_ID
       FROM   dual ;
     END;
   END IF;

    INSERT INTO PA_PROJ_RETN_RULES (
      Project_ID,
      Task_ID,
      Customer_ID,
      Retention_Rule_ID,
      Retention_Level_Code,
      Effective_Start_Date,
      Effective_End_Date,
      Retention_Percentage,
      Retention_Amount,
      Threshold_Amount,
      Expenditure_Category,
      Expenditure_Type,
      Non_Labor_Resource,
      Revenue_Category_Code,
      Event_Type,
      Creation_Date,
      Created_By,
      Last_Update_Date,
      Last_Updated_By
    )
    VALUES (
      P_Project_ID,
      l_Task_ID,
      P_Customer_ID,
      l_Retention_Rule_ID, -- PA_PROJ_RETN_RULES_S.NextVal, -- Fix for Bug 2671135
      P_Retention_Level_Code,
      P_Effective_Start_Date,
      P_Effective_End_Date,
      l_Retention_Percentage,
      P_Retention_Amount,
      P_Threshold_Amount,
      P_Expenditure_Category,
      P_Expenditure_Type,
      P_Non_Labor_Resource,
      l_Revenue_Category_Code,
      P_Event_Type,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id
    );

    BEGIN
      UPDATE PA_Project_Customers
      SET    Retention_Level_Code = DECODE(l_Task_ID, NULL, 'PROJECT', 'TOP_TASK')
      WHERE  Project_ID  = P_Project_ID
      AND    Customer_ID = P_Customer_ID;
    END;

    BEGIN
      SELECT
	RowIDtoChar(ROWID)
      INTO
	X_RowID
      FROM
	PA_PROJ_RETN_RULES
      WHERE
	  Project_ID                    = P_Project_ID
      AND Customer_ID			= P_Customer_ID
      AND Effective_Start_Date 		= P_Effective_Start_Date
      AND Retention_Rule_ID		= l_Retention_Rule_ID  -- Fix for Bug 2671135
      AND NVL(Task_ID, -1)		= NVL(l_Task_ID, -1)
      AND decode(Effective_End_Date, NULL, sysdate, Effective_End_Date ) =
	    decode(p_Effective_End_Date, NULL, sysdate, p_Effective_End_Date )
      AND NVL(Retention_Percentage, -1) = NVL(l_Retention_Percentage, -1)
      AND NVL(Retention_Amount, -1)     = NVL(P_Retention_Amount, -1)
      AND NVL(Threshold_Amount, -1)     = NVL(P_Threshold_Amount, -1)
      AND Retention_Level_Code          = P_Retention_Level_Code
      AND NVL(Expenditure_Category, 'z')= NVL(Expenditure_Category, 'z')
      AND NVL(Expenditure_Type, 'z')    = NVL(Expenditure_Type, 'z')
      AND NVL(Non_Labor_Resource, 'z')  = NVL(Non_Labor_Resource, 'z')
      AND NVL(Revenue_Category_Code, 'z')= NVL(Revenue_Category_Code, 'z')
      AND NVL(Event_Type, 'z')          = NVL(Event_Type, 'z');
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
          X_Return_Status_Code := FND_API.G_RET_STS_ERROR ;
          X_Error_Message_Code := 'PA_DATA_ERROR';
    END;

    IF X_Return_Status_Code = FND_API.G_RET_STS_ERROR
    THEN
      RETURN;
    ELSE
      X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
        X_Rowid := l_row_id ;  --NOCOPY
        P_Retention_Level_Code := l_retention_level_code ; -- NOCOPY
        P_Expenditure_Category := l_expenditure_category ; -- NOCOPY
        P_Expenditure_Type := l_expenditure_type;  -- NOCOPY
        P_Non_Labor_Resource := l_non_labor_resource ; -- NOCOPY
        P_Revenue_Category := l_revenue_category ; -- NOCOPY
        P_Event_Type := l_event_type ; -- NOCOPY
  END Insert_Row; -- Insert_Row;

  -----------------------------------------------------------------
  -- Update the retention record
  -----------------------------------------------------------------

  PROCEDURE Update_Row (
	P_RowID                         VARCHAR2,
	P_Project_ID			NUMBER,
	P_Customer_ID			NUMBER,
        P_Expenditure_Category  IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Expenditure_Type      IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Non_Labor_Resource    IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Revenue_Category      IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_Event_Type            IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	P_Retention_Percentage          NUMBER,
	P_Retention_Amount              NUMBER,
	P_Threshold_Amount              NUMBER,
	P_Effective_Start_Date          DATE,
	P_Effective_End_Date            DATE,
	X_Return_Status_code	IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Error_Message_Code	IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

l_Retention_Level_Code		VARCHAR2(30);
l_Revenue_Category_Code 	VARCHAR2(100);
l_Task_ID 		 	NUMBER;
l_Retained_Amount		NUMBER;

l_retention_percentage number;

l_expenditure_category VARCHAR2(30) := P_Expenditure_Category ;
l_expenditure_type VARCHAR2(30) := P_Expenditure_Type ;
l_non_labor_resource VARCHAR2(30) := P_Non_Labor_Resource ;
l_revenue_category VARCHAR2(30) := P_Revenue_Category ;
l_event_type VARCHAR2(30) := P_Event_Type ;
BEGIN
  BEGIN
    SELECT
      Retention_Level_Code,
      Task_ID,
      NVL(Total_Retained, 0)
    INTO
      l_Retention_Level_Code,
      l_Task_ID,
      l_Retained_Amount
    FROM
      PA_PROJ_RETN_RULES
    WHERE
      RowIDToChar(RowID) = P_RowID;
  END;

  IF P_Threshold_Amount < l_Retained_Amount
  THEN
    X_Return_Status_Code := FND_API.G_RET_STS_ERROR ;
    X_Error_Message_Code := 'PA_RETN_THRSHLD_XD_RETAINED';
    RETURN;
  END IF;

/* As null cannot be passed in this parameter, 2004 is explicitly assigned in the RetentionEditCO .java
  This is unset here */
   if p_retention_percentage = 2004 then
      l_retention_percentage := null;
   else
      l_retention_percentage := p_retention_percentage;
   end if;
   --- Performing Validations
   PA_Retention_Util.Validate_Retention_Data (
	P_RowID                 => P_RowID,
        P_PROJECT_ID		=> P_Project_ID,
        P_Task_Number		=> NULL,
        P_Task_Name		=> NULL,
        P_CUSTOMER_ID	 	=> P_Customer_ID,
	P_Retention_Level_Code  => l_Retention_Level_Code,
        P_Expenditure_Category  => P_Expenditure_Category,
	P_Expenditure_Type 	=> P_Expenditure_Type,
	P_Non_Labor_Resource    => P_Non_Labor_Resource,
	X_Revenue_Category_Code => l_Revenue_Category_Code,
	P_Revenue_Category      => P_Revenue_Category,
	P_Event_Type            => P_Event_Type,
        P_Retention_Percentage  => l_Retention_Percentage,
	P_Retention_Amount      => P_Retention_Amount,
	P_Threshold_Amount      => P_Threshold_Amount,
        P_EFFECTIVE_START_DATE 	=> P_Effective_Start_Date,
        P_EFFECTIVE_END_DATE	=> P_Effective_End_Date,
        P_Task_Flag		=> 'N',
        X_Task_ID		=> l_Task_ID,
        X_RETURN_STATUS_CODE	=> X_RETURN_STATUS_CODE,
        X_ERROR_MESSAGE_CODE	=> X_ERROR_MESSAGE_CODE
   );

  IF X_Return_Status_Code = FND_API.G_RET_STS_ERROR
  THEN
    RETURN;
  END IF;

  --- End of validations

  UPDATE
      PA_PROJ_RETN_RULES
  SET
      Retention_Level_Code   = l_Retention_Level_Code,
      Expenditure_Category   = P_Expenditure_Category,
      Expenditure_Type	     = P_Expenditure_Type,
      Non_Labor_Resource     = P_Non_Labor_Resource,
      Revenue_Category_Code  = l_Revenue_Category_Code,
      Event_Type             = P_Event_Type,
      Retention_Percentage   = l_Retention_Percentage,
      Retention_Amount       = P_Retention_Amount,
      Threshold_Amount       = P_Threshold_Amount,
      Effective_Start_Date   = P_Effective_Start_Date,
      Effective_End_Date     = P_Effective_End_Date,
      Last_Update_Date       = SYSDATE,
      Last_Updated_By        = FND_GLOBAL.user_id
  WHERE
      RowIDToChar(RowID) = P_RowID;

  IF (SQL%NOTFOUND)
  THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_DATA_ERROR';
  ELSE
      X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS;
      X_Error_Message_Code := '';
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        P_Expenditure_Category := l_expenditure_category ; -- NOCOPY
        P_Expenditure_Type := l_expenditure_type;  -- NOCOPY
        P_Non_Labor_Resource := l_non_labor_resource ; -- NOCOPY
        P_Revenue_Category := l_revenue_category ; -- NOCOPY
        P_Event_Type := l_event_type ; -- NOCOPY
END Update_Row; -- Update_Row;


  -----------------------------------------------------------------
  -- Delete the retention record
  -----------------------------------------------------------------

  PROCEDURE Delete_Row (
	P_Rowid                         VARCHAR2,
	X_Return_Status_code	IN OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Error_Message_Code	IN OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

  BEGIN

    X_Return_Status_Code := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM PA_PROJ_RETN_RULES
    WHERE  ROWID = P_RowID;
    EXCEPTION
      WHEN OTHERS THEN
      X_Return_Status_Code := FND_API.G_RET_STS_ERROR;
      X_Error_Message_Code := 'PA_DATA_ERROR';

  END Delete_Row; -- Delete Row

END PA_PROJ_RETN_RULES_PKG;

/
