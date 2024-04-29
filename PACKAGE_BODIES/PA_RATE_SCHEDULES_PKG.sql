--------------------------------------------------------
--  DDL for Package Body PA_RATE_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RATE_SCHEDULES_PKG" AS
-- $Header: PARTSCHB.pls 120.1 2005/08/19 17:01:28 mwasowic noship $

PROCEDURE Copy_Rate_Schedules (
	    P_Source_Organization_ID	IN  NUMBER,
	    P_Source_Rate_Schedule	IN  VARCHAR2,
	    P_Organization_ID		IN  NUMBER,
	    P_Rate_Schedule		IN  VARCHAR2,
	    P_Rate_Schedule_Desc	IN  VARCHAR2,
	    P_Rate_Sch_Currency_Code	IN  VARCHAR2,
	    P_Share_Across_OU_Flag	IN  VARCHAR2,
    	    P_Escalated_Rate_Perc	IN  NUMBER  DEFAULT 0,
    	    P_Escalated_Markup_Perc	IN  NUMBER  DEFAULT 0,
	    X_Return_Status 		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	    X_Msg_Data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         )
IS
  l_Bill_Rate_Sch_ID 	NUMBER;
  l_Org_ID		NUMBER;
  l_Exists_Flag		NUMBER;
  l_Duplicate_Flag	NUMBER;

BEGIN

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- Bill_Rate_Sch_ID should be from the sequence PA_STD_BILL_SCH_S next value
  SELECT PA_STD_BILL_SCH_S.NextVal
  INTO   l_Bill_Rate_Sch_ID
  FROM   DUAL;

  -- Derive the Org_ID value from PA_Implemenatations table
  SELECT Org_ID
  INTO   l_Org_ID
  FROM   PA_Implementations;

  -- Check for existence of source rate schedule
  BEGIN
   SELECT 1 INTO l_Exists_Flag
   FROM
   PA_STD_BILL_RATE_SCHEDULES_ALL
   WHERE
      ORG_ID = l_Org_ID
   AND STD_BILL_RATE_SCHEDULE = P_Source_Rate_Schedule
   AND Organization_ID	      = P_Source_Organization_ID;
   EXCEPTION
   WHEN others THEN
      Raise;
      X_Return_Status := FND_API.G_RET_STS_ERROR;
      X_Msg_Data      := 'PA_UNEXPECTED_ERROR';
      RETURN;
   END;

IF l_Exists_Flag = 1 THEN

  INSERT INTO
  PA_STD_BILL_RATE_SCHEDULES_ALL (
    ORGANIZATION_ID,
    STD_BILL_RATE_SCHEDULE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SCHEDULE_TYPE,
    DESCRIPTION,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ORG_ID,
    BILL_RATE_SCH_ID,
    JOB_GROUP_ID,
    RATE_SCH_CURRENCY_CODE,
    SHARE_ACROSS_OU_FLAG )
  SELECT
    P_ORGANIZATION_ID,
    P_RATE_SCHEDULE,
    sysdate, 		 	-- LAST_UPDATE_DATE,
    FND_GLOBAL.User_ID,		-- LAST_UPDATED_BY,
    sysdate, 			-- CREATION_DATE,
    FND_GLOBAL.User_ID, 	-- CREATED_BY,
    FND_GLOBAL.User_ID,		-- LAST_UPDATE_LOGIN,
    SCHEDULE_TYPE,
    P_Rate_Schedule_Desc,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ORG_ID,
    l_Bill_Rate_Sch_ID,
    JOB_GROUP_ID,
    P_Rate_Sch_Currency_Code,
    P_Share_Across_OU_Flag
  FROM
    PA_STD_BILL_RATE_SCHEDULES_ALL
  WHERE
      ORG_ID = l_Org_ID
  AND STD_BILL_RATE_SCHEDULE = P_Source_Rate_Schedule
  AND Organization_ID	     = P_Source_Organization_ID;
END IF;
  --
  -- Insert the records into detail table PA_BILL_RATES_ALL
  --
  INSERT INTO
  PA_BILL_RATES_ALL (
    BILL_RATE_ORGANIZATION_ID,
    STD_BILL_RATE_SCHEDULE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    START_DATE_ACTIVE,
    PERSON_ID,
    JOB_ID,
    EXPENDITURE_TYPE,
    NON_LABOR_RESOURCE,
    RATE,
    BILL_RATE_UNIT,
    MARKUP_PERCENTAGE,
    END_DATE_ACTIVE,
    ORG_ID,
    BILL_RATE_SCH_ID,
    JOB_GROUP_ID,
    RATE_CURRENCY_CODE,
    Resource_Class_Code,
    Res_Class_Organization_Id
  )
  SELECT
    P_Organization_ID,
    P_Rate_Schedule,
    sysdate,			-- LAST_UPDATE_DATE,
    FND_GLOBAL.User_ID,		-- LAST_UPDATED_BY,
    Sysdate,			-- CREATION_DATE,
    FND_GLOBAL.User_ID,		-- CREATED_BY,
    FND_GLOBAL.User_ID,		-- LAST_UPDATE_LOGIN,
    START_DATE_ACTIVE,
    PERSON_ID,
    JOB_ID,
    EXPENDITURE_TYPE,
    NON_LABOR_RESOURCE,
    RATE*(1 + NVL(P_Escalated_Rate_Perc,0)/100),
    BILL_RATE_UNIT,
    MARKUP_PERCENTAGE*(1 + NVL(P_Escalated_Markup_Perc,0)/100),
    END_DATE_ACTIVE,
    ORG_ID,
    l_Bill_Rate_Sch_ID,
    JOB_GROUP_ID,
    P_Rate_Sch_Currency_Code,
    Resource_Class_Code,
    Res_Class_Organization_Id
  FROM
    PA_BILL_RATES_ALL
  WHERE
      ORG_ID = l_Org_ID
  AND STD_BILL_RATE_SCHEDULE    = P_Source_Rate_Schedule
  AND Bill_Rate_Organization_ID	= P_Source_Organization_ID;
  --
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    -- X_Msg_Data      := 'PA_UNEXPECTED_ERROR';

END Copy_Rate_Schedules;


END PA_Rate_Schedules_PKG;


/
