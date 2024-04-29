--------------------------------------------------------
--  DDL for Package Body AP_WEB_PROJECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_PROJECT_PKG" AS
/* $Header: apwprojb.pls 120.10.12000000.2 2007/09/28 13:57:28 rveliche ship $ */

PROCEDURE IsSessionProjectEnabled(
                          P_EmployeeID IN    FND_USER.employee_id%TYPE,
                          P_FNDUserID  IN    FND_USER.user_id%TYPE,
                          P_Result     OUT NOCOPY   VARCHAR2)

  -- Determines whether the session is project enabled.  Checks (1) PA is
  -- installed, (2) project accounting profile option is enabled, and
  -- (3) the web user can enter projects information.  If all of the above
  -- is true, then returns 'Y', otherwise 'N'.
  -- For contingent workers, an additional check is made whether
  -- projects in cwk enabled.

IS

  l_Status              VARCHAR2(10);
  l_Industry            VARCHAR2(10);
  l_PAEnable            VARCHAR2(30);
  l_PAEnableProfile     VARCHAR2(30) := NULL;
  l_PAEnablePreviousVal VARCHAR2(30);
  l_Mesg                VARCHAR2(100);
  l_FNDUserID           AP_WEB_DB_HR_INT_PKG.fndUser_userID;
  l_FNDUsersEmployeeID  AP_WEB_DB_HR_INT_PKG.fndUser_employeeID;
  l_userIdCursor	AP_WEB_DB_HR_INT_PKG.UserIdRefCursor;

BEGIN

  -- Assume that the session is not project enabled
  P_Result := 'N';

  -- Check projects installed
  if (FND_INSTALLATION.GET(275, 275, l_Status, l_Industry)) then
    if (l_Status <> 'I') then
      return;
    end if;
  end if;

  -- Be sure that both employee ID and FND User ID is not null.  Otherwise
  -- return not projects enabled
  IF (P_FNDUserID IS NULL) OR (P_EmployeeID IS NULL) THEN
    RETURN;
  END IF;

  -- For Contingent workers, call PA API to determine whether
  -- PA.FP.M is installed.
  IF (AP_WEB_DB_HR_INT_PKG.IsPersonCwk(P_EmployeeID) = 'Y' AND
      PA_PO_INTEGRATION.is_pjc_po_cwk_intg_enab <> 'Y')  THEN
    RETURN;
  END IF;

  -- Check whether third party is being used since different logic is used
  -- to handle the case where an employee may correspond to multiple
  -- FND users.
  IF ( NOT AP_WEB_DB_HR_INT_PKG.GetEmpIdForUser(
				P_FNDUserID,
				 l_FNDUsersEmployeeID) ) THEN
	l_FNDUsersEmployeeID := NULL;
  END IF;

  if (l_FNDUsersEmployeeID = P_EmployeeID) then

    -- Third party not being used.

    -- Check profile option
    l_PAEnableProfile := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
				p_name    => 'AP_WEB_ENABLE_PROJECT_ACCOUNTING',
				p_user_id => P_FNDUserID,
				p_resp_id => null,
				p_apps_id => null);
    if (l_PAEnableProfile = 'N') then
      return;
    end if;

    -- Call PA API to determine whether user is projects enabled.
    PA_CLIENT_EXTN_PTE.check_time_exp_proj_user(l_FNDUsersEmployeeID,
                                                P_FNDUserID,
                                                l_PAEnable, l_Mesg);
    if (l_PAEnable = 'Y') then
      P_Result := 'Y';
    end if;

  else

    -- Third party being used.
    -- For each FNDUSER corresponding to the employee, verify that the
    -- Project enabled profile option is the same for all fnd users
    -- If value is the same for all FND user then return the value, otherwise
    -- return not projects enabled.
    l_PAEnablePreviousVal := NULL;

    IF ( AP_WEB_DB_HR_INT_PKG.GetUserIdForEmpCursor(
				p_EmployeeID,
				l_userIdCursor) = TRUE ) THEN
    	LOOP
		EXIT WHEN l_userIdCursor%NOTFOUND OR
                        l_PAEnableProfile = 'N' OR
                	((l_PAEnablePreviousVal <> l_PAEnable) AND
                 	(l_PAEnablePreviousVal IS NOT NULL));

      		FETCH l_userIdCursor INTO l_FNDUserID;

                -- Check profile option
                l_PAEnableProfile := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
					p_name    => 'AP_WEB_ENABLE_PROJECT_ACCOUNTING',
					p_user_id => l_FNDUserID,
					p_resp_id => null,
					p_apps_id => null);

      		PA_CLIENT_EXTN_PTE.check_time_exp_proj_user(P_EmployeeID,
                                            l_FNDUserID,
                                            l_PAEnable,
					    l_Mesg);
      		l_PAEnablePreviousVal := l_PAEnable;
  	END LOOP;
    	CLOSE l_userIdCursor;
    END IF;

    if (l_PAEnableProfile <> 'N') AND
       (l_PAEnable = 'Y') AND
       (l_PAEnablePreviousVal = l_PAEnable) THEN
      P_Result := 'Y';
    end if;
  end if;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'IsSessionProjectEnabled');
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;


END;

PROCEDURE GetExpenditureTypeMapping(
  P_ExpenseType       IN        AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE,
  P_PAExpenditureType OUT NOCOPY       AP_EXPENSE_REPORT_PARAMS.pa_expenditure_type%TYPE
  )
  -- Returns the expenditure type mapped to the expense type
  -- Exception generated if cannot find P_ExpenseType

IS
	l_expTypeInfoRec	AP_WEB_DB_EXPTEMPLATE_PKG.ExpTypeInfoRec;
BEGIN

	IF ( AP_WEB_DB_EXPTEMPLATE_PKG.GetExpTypeInfo(
					P_ExpenseType,
					l_expTypeInfoRec) ) THEN
		P_PAExpenditureType := l_expTypeInfoRec.pa_exp_type;
	END IF;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'GetExpenditureTypeMapping');
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;

END GetExpenditureTypeMapping;

PROCEDURE DerivePAInfoFromDatabase(
  P_IsProjectEnabled   IN 	VARCHAR2,
  P_PAProjectNumber    IN OUT NOCOPY 	PA_PROJECTS_EXPEND_V.project_number%TYPE,
  P_PAProjectID        IN OUT NOCOPY 	PA_PROJECTS_EXPEND_V.project_id%TYPE,
  P_PATaskNumber       IN OUT NOCOPY 	PA_TASKS_EXPEND_V.task_number%TYPE,
  P_PATaskID           IN OUT NOCOPY 	PA_TASKS_EXPEND_V.task_id%TYPE,
  P_PAExpenditureType  IN OUT NOCOPY 	AP_EXPENSE_REPORT_PARAMS.pa_expenditure_type%TYPE )

  -- Populates the ProjectNumber, TaskNumber
  -- Assumes that Project and Task Number are filled in already
  -- Reports errors that would not be caught by core validation
  -- Will clear out project info, if invalid

IS
  l_Field1 INTEGER; -- Temporary
  l_Field2 INTEGER; -- Temporary
BEGIN

  if P_IsProjectEnabled = 'Y' then

    if (P_PAExpenditureType is not NULL) then

      -- Get ProjectNumber from ProjectID
      if P_PAProjectID is not NULL then
        begin
		IF ( NOT AP_WEB_DB_PA_INT_PKG.GetProjectNumber(
						P_PAProjectID,
						P_PAProjectNumber) ) THEN
			P_PAProjectNumber := NULL;
		END IF;
        exception
          when OTHERS then
            NULL; -- do not report errors here, will be caught in validation
        end;
      end if;

      -- GetTaskID from TaskNumber
      if P_PATaskID is not NULL then
        if P_PAProjectID is not NULL then
 		IF ( NOT AP_WEB_DB_PA_INT_PKG.GetTaskIDByProjID(
					P_PAProjectID,
					P_PATaskID) ) THEN
			P_PATaskID := NULL;
		END IF;
        end if;
      end if;

      -- Clear out expenditure type if not project-enabled receipt
      if (P_PAProjectNumber = NULL) and (P_PATaskNumber = NULL) then
        P_PAExpenditureType := NULL;
        P_PAProjectID := NULL;
        P_PATaskID := NULL;
      end if;

      return; -- No more additional errors to catch

    end if;  -- (P_PAExpenditureType is not NULL)
  end if; -- P_IsProjectEnabled = 'Y'
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DerivePAInfoFromDatabase');
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;

END DerivePAInfoFromDatabase;

PROCEDURE DerivePAInfoFromUserInput(
  P_IsProjectEnabled   IN     VARCHAR2,
  P_PAProjectNumber    IN OUT NOCOPY PA_PROJECTS_EXPEND_V.project_number%TYPE,
  P_PAProjectID        OUT NOCOPY    PA_PROJECTS_EXPEND_V.project_id%TYPE,
  P_PAProjectName      OUT NOCOPY    PA_PROJECTS_EXPEND_V.project_name%TYPE,
  P_PATaskNumber       IN OUT NOCOPY PA_TASKS_EXPEND_V.task_number%TYPE,
  P_PATaskID           OUT NOCOPY    PA_TASKS_EXPEND_V.task_id%TYPE,
  P_PATaskName	       OUT NOCOPY    PA_TASKS_EXPEND_V.task_name%TYPE,
  P_PAExpenditureType  OUT NOCOPY    AP_EXPENSE_REPORT_PARAMS.pa_expenditure_type%TYPE,
  P_ExpenseType        IN     AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE
)

  -- Populates the ProjectID, TaskID, and Expenditure Type
  -- Assumes that Project and Task Number are filled in already
  -- Reports errors that would not be caught by core validation

IS
  P_PAExpenditureTypeTemp	AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_paExpendituretype;
BEGIN

  -- Initialize out variables
  P_PAProjectID := NULL;
  P_PATaskID := NULL;
  P_PAExpenditureType := NULL;

  if P_IsProjectEnabled = 'Y' then

    -- Determine whether expense type project enabled
    GetExpenditureTypeMapping(P_ExpenseType, P_PAExpenditureTypeTemp);
    P_PAExpenditureType := P_PAExpenditureTypeTemp;

    if (P_PAExpenditureTypeTemp IS NOT NULL) then

      -- Get ProjectID from ProjectNumber
      if (NOT P_PAProjectNumber IS NULL) then
	IF ( NOT AP_WEB_DB_PA_INT_PKG.GetProjectInfo(
				P_PAProjectNumber,
				p_PAProjectID,
				P_PAProjectName) ) THEN
		P_PAProjectID := NULL;
	END IF;

      end if;

      -- GetTaskID from TaskNumber
      if (NOT P_PATaskNumber IS NULL) then
        if (NOT P_PAProjectID IS NULL) then
		IF ( NOT AP_WEB_DB_PA_INT_PKG.GetTaskInfo(
					P_PATaskNumber,
					P_PAProjectID,
					P_PATaskID,
					P_PATaskName) ) THEN
			P_PATaskID := NULL;
		END IF;
        end if;
      end if;

      if (P_PAProjectNumber IS NULL) and (P_PATaskNumber IS NULL) then
        P_PAExpenditureType := NULL;
      end if;

    end if;  -- (P_PAExpenditureType is not NULL)

  end if;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DerivePAInfoFromUserInput');
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;
END DerivePAInfoFromUserInput;

PROCEDURE ValidatePATransaction(
            P_project_id             IN NUMBER,
            P_task_id                IN NUMBER,
            P_ei_date                IN DATE,
            P_expenditure_type       IN VARCHAR2,
            P_non_labor_resource     IN VARCHAR2,
            P_person_id              IN NUMBER,
            P_quantity               IN NUMBER DEFAULT NULL,
            P_denom_currency_code    IN VARCHAR2 DEFAULT NULL,
            P_acct_currency_code     IN VARCHAR2 DEFAULT NULL,
            P_denom_raw_cost         IN NUMBER DEFAULT NULL,
            P_acct_raw_cost          IN NUMBER DEFAULT NULL,
            P_acct_rate_type         IN VARCHAR2 DEFAULT NULL,
            P_acct_rate_date         IN DATE DEFAULT NULL,
            P_acct_exchange_rate     IN NUMBER DEFAULT NULL ,
            P_transfer_ei            IN NUMBER DEFAULT NULL,
            P_incurred_by_org_id     IN NUMBER DEFAULT NULL,
            P_nl_resource_org_id     IN NUMBER DEFAULT NULL,
            P_transaction_source     IN VARCHAR2 DEFAULT NULL ,
            P_calling_module         IN VARCHAR2 DEFAULT NULL,
            P_vendor_id              IN NUMBER DEFAULT NULL,
            P_entered_by_user_id     IN NUMBER DEFAULT NULL,
            P_attribute_category     IN VARCHAR2 DEFAULT NULL,
            P_attribute1             IN VARCHAR2 DEFAULT NULL,
            P_attribute2             IN VARCHAR2 DEFAULT NULL,
            P_attribute3             IN VARCHAR2 DEFAULT NULL,
            P_attribute4             IN VARCHAR2 DEFAULT NULL,
            P_attribute5             IN VARCHAR2 DEFAULT NULL,
            P_attribute6             IN VARCHAR2 DEFAULT NULL,
            P_attribute7             IN VARCHAR2 DEFAULT NULL,
            P_attribute8             IN VARCHAR2 DEFAULT NULL,
            P_attribute9             IN VARCHAR2 DEFAULT NULL,
            P_attribute10            IN VARCHAR2 DEFAULT NULL,
            P_attribute11            IN VARCHAR2 DEFAULT NULL,
            P_attribute12            IN VARCHAR2 DEFAULT NULL,
            P_attribute13            IN VARCHAR2 DEFAULT NULL,
            P_attribute14            IN VARCHAR2 DEFAULT NULL,
            P_attribute15            IN VARCHAR2 DEFAULT NULL,
            P_msg_type               OUT NOCOPY VARCHAR2,
            P_msg_data               OUT NOCOPY VARCHAR2,
            P_billable_flag          OUT NOCOPY VARCHAR2)
IS

--
-- This is a wrapper function to PATC.GET_STATUS.  Since the
-- PA group is modifying the API for 11.5, but not in 11.0,
-- we would like to isolate the rest of the source code from
-- these changes.
--
  l_MsgApplication VARCHAR2(10);
  l_MsgType        VARCHAR2(10);
  l_MsgName        VARCHAR2(100);
  l_MsgToken1      VARCHAR2(1000);
  l_MsgToken2      VARCHAR2(1000);
  l_MsgToken3      VARCHAR2(1000);
  l_MsgCount       NUMBER;

BEGIN

  AP_WEB_WRAPPER_PKG.ValidatePATransaction(
  P_project_id,
  P_task_id,
  P_ei_date,
  P_expenditure_type,
  P_non_labor_resource,
  P_person_id,
  P_quantity,
  P_denom_currency_code,
  P_acct_currency_code,
  P_denom_raw_cost,
  P_acct_raw_cost,
  P_acct_rate_type,
  P_acct_rate_date,
  P_acct_exchange_rate,
  P_transfer_ei,
  P_incurred_by_org_id,
  P_nl_resource_org_id,
  P_transaction_source,
  P_calling_module,
  P_vendor_id,
  P_entered_by_user_id,
  P_attribute_category,
  P_attribute1,
  P_attribute2,
  P_attribute3,
  P_attribute4,
  P_attribute5,
  P_attribute6,
  P_attribute7,
  P_attribute8,
  P_attribute9,
  P_attribute10,
  P_attribute11,
  P_attribute12,
  P_attribute13,
  P_attribute14,
  P_attribute15,
  l_MsgApplication,
  l_MsgType,
  l_MsgToken1,
  l_MsgToken2,
  l_MsgToken3,
  l_MsgCount,
  l_MsgName, -- P_msg_data will contain the error msg
  P_Msg_Data,
  P_billable_flag);

  -- If errors occurred, then get the message text and return in P_msg_data
  P_Msg_Data := NULL;
  IF (l_MsgName IS NOT NULL) THEN
    FND_MESSAGE.SET_NAME( l_MsgApplication, l_MsgName);

    -- Bug: 6347674, donot set the tokens when there are none comming from the PA client extension
    IF (l_MsgToken1 IS NOT NULL) THEN
      FND_MESSAGE.SET_TOKEN('PATC_MSG_TOKEN1', l_MsgToken1);
    END IF;

    IF (l_MsgToken2 IS NOT NULL) THEN
      FND_MESSAGE.SET_TOKEN('PATC_MSG_TOKEN2', l_MsgToken2);
    END IF;

    IF (l_MsgToken3 IS NOT NULL) THEN
      FND_MESSAGE.SET_TOKEN('PATC_MSG_TOKEN3', l_MsgToken3);
    END IF;

    P_Msg_Data := FND_MESSAGE.GET;
  END IF;

  -- Set the message type to one we use in Web Expenses
  P_Msg_Type := NULL;
  IF (l_MsgType = 'E') THEN
    P_Msg_Type := AP_WEB_DFLEX_PKG.C_CustValidResMsgTypeError;
  ELSIF (l_MsgType = 'W') THEN
    P_Msg_Type := AP_WEB_DFLEX_PKG.C_CustValidResMsgTypeWarning;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'PROJECT.ValidatePATransaction');
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;
END ValidatePATransaction;

----------------------------------------------------------------------

FUNCTION IsGrantsEnabled RETURN VARCHAR2
IS
 l_is_grants_enabled VARCHAR2(1);
BEGIN
  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_OA_MAINFLOW_PKG',
                                   'start IsGrantsEnabled');

  IF (GMS_OIE_INT_PKG.IsGrantsEnabled()) THEN
    l_is_grants_enabled := 'Y';
  ELSE
     l_is_grants_enabled := 'N';
  END IF;

  AP_WEB_UTILITIES_PKG.LogProcedure('AP_WEB_OA_MAINFLOW_PKG',
                                   'end IsGrantsEnabled');
  RETURN l_is_grants_enabled;
END IsGrantsEnabled;
----------------------------------------------------------------------

END AP_WEB_PROJECT_PKG;

/
