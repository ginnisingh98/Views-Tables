--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEADS_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEADS_LOG_PKG" as
/* $Header: asxtslab.pls 115.9 2002/12/18 22:29:40 solin ship $ */

-- Start of Comments
-- Package name     : AS_SALES_LEADS_LOG_PVT
-- Purpose          : Sales activity log management
-- NOTE             :
-- History          : 07/07/2000 CDESANTI  Created.
--                    12/17/2002 SOLIN     Add manual_rank_flag
--

-- NAME
--   Insert_Row
--
-- HISTORY
--
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Insert_Row( px_log_id                  IN OUT NOCOPY NUMBER,
                      p_sales_lead_id                   NUMBER,
                      p_created_by                      NUMBER,
                      p_creation_date                   DATE,
                      p_last_updated_by                 NUMBER,
                      p_last_update_date                DATE,
                      p_last_update_login               NUMBER,
                      p_request_id                      NUMBER,
                      p_program_application_id          NUMBER,
                      p_program_id                      NUMBER,
                      p_program_update_date             DATE,
                      p_status_code                     VARCHAR2,
                      p_assign_to_person_id             NUMBER,
                      p_assign_to_salesforce_id         NUMBER,
                      p_reject_reason_code              VARCHAR2,
                      p_assign_sales_group_id           NUMBER,
                      p_lead_rank_id                    NUMBER,
                      p_qualified_flag                  VARCHAR2,
                      -- new column for CAPRI lead referral
                      p_category			VARCHAR2,
                      -- SOLIN added
                      p_manual_rank_flag                VARCHAR2
) IS
   CURSOR C2 IS SELECT as_sales_leads_log_s.nextval FROM sys.dual;

   p_User_Id    	NUMBER;
   p_Login_Id   	NUMBER;
   p_Date       	DATE;
   p_Conc_Request_Id 	NUMBER;
   p_Prg_Id		NUMBER;
   p_Prg_Update_Date    DATE;
   p_Prg_Appl_Id        NUMBER;

BEGIN
  if (px_log_id IS NULL) OR (px_log_id = FND_API.G_MISS_NUM) then
      OPEN C2;
      FETCH C2 INTO px_log_id;
      CLOSE C2;
  end if;

  INSERT INTO AS_SALES_LEADS_LOG (
              LOG_ID,
              SALES_LEAD_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN,
              REQUEST_ID,
              PROGRAM_APPLICATION_ID,
              PROGRAM_ID,
              PROGRAM_UPDATE_DATE,
              STATUS_CODE,
              ASSIGN_TO_PERSON_ID,
              ASSIGN_TO_SALESFORCE_ID,
              REJECT_REASON_CODE,
              ASSIGN_SALES_GROUP_ID,
              LEAD_RANK_ID,
              QUALIFIED_FLAG,
	      -- new column for CAPRI lead referral
              CATEGORY,
              MANUAL_RANK_FLAG
         )
         VALUES (     px_log_id,
            decode (p_sales_lead_id, fnd_api.g_miss_num, null, p_sales_lead_id),
            decode (p_created_by , fnd_api.g_miss_num, null, p_created_by),
            decode (p_creation_date,fnd_api.g_miss_date, to_date(null), p_creation_date),
            decode (p_last_updated_by, fnd_api.g_miss_num, null, p_last_updated_by),
            decode (p_last_update_date , fnd_api.g_miss_date, to_date(null), p_last_update_date),
            decode (p_last_update_login , fnd_api.g_miss_num, null, p_last_update_login),
            decode (p_request_id , fnd_api.g_miss_num, null, p_request_id),
            decode (p_program_application_id , fnd_api.g_miss_num, null,p_program_application_id),
            decode (p_program_id , fnd_api.g_miss_num, null,p_program_id),
            decode (p_program_update_date , fnd_api.g_miss_date, to_date(null),p_program_update_date),
            decode (p_status_code , fnd_api.g_miss_char, null, p_status_code),
            decode (p_assign_to_person_id , fnd_api.g_miss_num, null,p_assign_to_person_id),
            decode (p_assign_to_salesforce_id , fnd_api.g_miss_num, null,p_assign_to_salesforce_id),
            decode (p_reject_reason_code, fnd_api.g_miss_char, null,p_reject_reason_code),
            decode (p_assign_sales_group_id, fnd_api.g_miss_num, null,p_assign_sales_group_id),
            decode (p_lead_rank_id , fnd_api.g_miss_num, null,p_lead_rank_id),
            decode (p_qualified_flag, fnd_api.g_miss_char, null,p_qualified_flag),
            decode (p_category, fnd_api.g_miss_char, null,p_category),
            decode (p_manual_rank_flag, fnd_api.g_miss_char, null,p_manual_rank_flag)

	        );


  END Insert_Row;

PROCEDURE Lock_Row(   p_log_id                          NUMBER,
                      p_sales_lead_id                   NUMBER,
                      p_created_by                      NUMBER,
                      p_creation_date                   DATE,
                      p_last_updated_by                 NUMBER,
                      p_last_update_date                DATE,
                      p_last_update_login               NUMBER,
                      p_request_id                      NUMBER,
                      p_program_application_id          NUMBER,
                      p_program_id                      NUMBER,
                      p_program_update_date             DATE,
                      p_status_code                     VARCHAR2,
                      p_assign_to_person_id             NUMBER,
                      p_assign_to_salesforce_id         NUMBER,
                      p_reject_reason_code              VARCHAR2,
                      p_assign_sales_group_id           NUMBER,
                      p_lead_rank_id                    NUMBER,
                      p_qualified_flag                  VARCHAR2,
	      -- new column for CAPRI lead referral

                      p_category			VARCHAR2,
                      p_manual_rank_flag                VARCHAR2
) IS

     CURSOR C IS
      SELECT *
      FROM   AS_SALES_LEADS_LOG
      WHERE log_id = p_log_id
      FOR UPDATE of log_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  end if;
  CLOSE C;
  if (    (   (Recinfo.log_id = p_log_Id)
           OR (    (Recinfo.log_id IS NULL)
               AND (p_Log_Id IS NULL)))
      AND (   (Recinfo.sales_lead_id = p_sales_lead_id)
           OR (    (Recinfo.sales_lead_id IS NULL)
               AND (p_sales_lead_id IS NULL)))

      AND (   (Recinfo.request_id = p_request_id)
           OR (    (Recinfo.request_id IS NULL)
               AND (p_request_id IS NULL)))
      AND (   (Recinfo.program_application_id = p_program_application_id)
           OR (    (Recinfo.program_application_id IS NULL)
               AND (p_program_application_id IS NULL)))
      AND (   (Recinfo.program_id = p_program_id)
           OR (    (Recinfo.program_id IS NULL)
               AND (p_program_id IS NULL)))
      AND (   (Recinfo.program_update_date = p_program_update_date)
           OR (    (Recinfo.program_update_date IS NULL)
               AND (p_program_update_date IS NULL)))
      AND (   (Recinfo.status_code = p_status_code)
           OR (    (Recinfo.status_code IS NULL)
               AND (p_status_code IS NULL)))
      AND (   (Recinfo.assign_to_person_id = p_assign_to_person_id)
           OR (    (Recinfo.assign_to_person_id IS NULL)
               AND (p_assign_to_person_id IS NULL)))
      AND (   (Recinfo.assign_to_salesforce_id = p_assign_to_salesforce_id)
           OR (    (Recinfo.assign_to_salesforce_id IS NULL)
               AND (p_assign_to_salesforce_id IS NULL)))
      AND (   (Recinfo.reject_reason_code = p_reject_reason_code)
           OR (    (Recinfo.reject_reason_code IS NULL)
               AND (p_reject_reason_code IS NULL)))
      AND (   (Recinfo.assign_sales_group_id = p_assign_sales_group_id)
           OR (    (Recinfo.assign_sales_group_id IS NULL)
               AND (p_assign_sales_group_id IS NULL)))
      AND (   (Recinfo.lead_rank_id = p_lead_rank_id)
           OR (    (Recinfo.lead_rank_id IS NULL)
               AND (p_lead_rank_id IS NULL)))
      AND (   (Recinfo.qualified_flag = p_qualified_flag)
           OR (    (Recinfo.qualified_flag IS NULL)
               AND (p_qualified_flag IS NULL)))
      AND (   (Recinfo.category = p_category)
           OR (    (Recinfo.category IS NULL)
               AND (p_category IS NULL)))
      AND (   (Recinfo.manual_rank_flag = p_manual_rank_flag)
           OR (    (Recinfo.manual_rank_flag IS NULL)
               AND (p_manual_rank_flag IS NULL)))

      ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  end if;
END Lock_Row;

PROCEDURE Update_Row(p_log_id                          NUMBER,
                     p_sales_lead_id                   NUMBER,
                     p_created_by                      NUMBER,
                     p_creation_date                   DATE,
                     p_last_updated_by                 NUMBER,
                     p_last_update_date                DATE,
                     p_last_update_login               NUMBER,
                     p_request_id                      NUMBER,
                     p_program_application_id          NUMBER,
                     p_program_id                      NUMBER,
                     p_program_update_date             DATE,
                     p_status_code                     VARCHAR2,
                     p_assign_to_person_id             NUMBER,
                     p_assign_to_salesforce_id         NUMBER,
                     p_reject_reason_code              VARCHAR2,
                     p_assign_sales_group_id           NUMBER,
                     p_lead_rank_id                    NUMBER,
                     p_qualified_flag                  VARCHAR2,
	      -- new column for CAPRI lead referral
                     p_category			       VARCHAR2,
                     p_manual_rank_flag                VARCHAR2
) IS
BEGIN
  UPDATE AS_SALES_LEADS_LOG
  SET
   sales_lead_id         =    decode(p_sales_lead_id, FND_API.G_MISS_NUM, sales_lead_id, p_sales_lead_id),
   last_update_date      =    decode(p_last_Update_Date, FND_API.G_MISS_DATE, last_update_date , p_last_update_date),
   last_updated_by       =    decode(last_Updated_By, FND_API.G_MISS_NUM, last_updated_by, p_last_updated_by),
   last_update_login     =    decode(last_Update_Login, FND_API.G_MISS_NUM, last_update_login, p_last_update_login),
   request_id            =    decode(request_id , FND_API.G_MISS_NUM, request_id, p_request_id),
   program_application_id =   decode(program_application_id , FND_API.G_MISS_NUM, program_application_id, p_program_application_id),
   program_id             =   decode(program_id , FND_API.G_MISS_NUM, program_id, p_program_id),
   program_update_date    =   decode(program_update_date , FND_API.G_MISS_DATE, program_update_date, p_program_update_date),
   status_code            =   decode(status_code , FND_API.G_MISS_CHAR, status_code, p_status_code),
   assign_to_person_id    =   decode(assign_to_person_id , FND_API.G_MISS_NUM, assign_to_person_id, p_assign_to_person_id),
   assign_to_salesforce_id    =   decode(assign_to_salesforce_id , FND_API.G_MISS_NUM, assign_to_salesforce_id, p_assign_to_salesforce_id),
   reject_reason_code     =   decode(reject_reason_code, FND_API.G_MISS_CHAR, reject_reason_code, p_reject_reason_code),
   assign_sales_group_id  =   decode(assign_sales_group_id, FND_API.G_MISS_NUM, assign_sales_group_id, p_assign_sales_group_id),
   lead_rank_id           =   decode(lead_rank_id , FND_API.G_MISS_NUM, lead_rank_id, p_lead_rank_id),
   qualified_flag         =   decode(qualified_flag, FND_API.G_MISS_CHAR, qualified_flag, p_qualified_flag),
   category         	  =   decode(category, FND_API.G_MISS_CHAR, category, p_category),
   manual_rank_flag       =   decode(manual_rank_flag, FND_API.G_MISS_CHAR, manual_rank_flag, p_manual_rank_flag)

  WHERE log_id = p_log_id;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(p_log_id NUMBER) is
BEGIN

  DELETE FROM AS_SALES_LEADS_LOG
  WHERE log_id = p_log_id;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Delete_Row;


END AS_SALES_LEADS_LOG_PKG;


/
