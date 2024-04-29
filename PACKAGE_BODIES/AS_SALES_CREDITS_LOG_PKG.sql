--------------------------------------------------------
--  DDL for Package Body AS_SALES_CREDITS_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_CREDITS_LOG_PKG" as
/* $Header: asxtsclb.pls 120.2 2005/09/02 04:05:34 appldev ship $ */
 PROCEDURE Insert_Row(p_new_lead_id    	NUMBER,
  						p_new_lead_line_id 	NUMBER,
						p_new_sales_credit_id	NUMBER,
						p_new_last_update_date  DATE,
						p_new_last_updated_by   NUMBER,
						p_new_last_update_login NUMBER,
						p_new_creation_date     DATE,
  						p_new_created_by        NUMBER,
						p_new_salesforce_id	NUMBER,
						p_new_salesgroup_id	NUMBER,
						p_new_credit_type_id	NUMBER,
						p_new_credit_percent	NUMBER,
						p_new_credit_amount	NUMBER,
						p_new_opp_worst_frcst_amount NUMBER,
						p_new_opp_frcst_amount NUMBER,
						p_new_opp_best_frcst_amount NUMBER,
						p_endday_log_flag VARCHAR2,
						p_TRIGGER_MODE 	   	VARCHAR2)
 IS
 l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

 BEGIN
	-- dbms_output.put_line('In AS_SALES_CREDITS_LOG_PKG Before Insert Statement');

	  IF l_debug THEN
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtsclb: In AS_SALES_CREDITS_LOG_PKG Before Insert Statement');
	  END IF;
  Insert into AS_SALES_CREDITS_LOG (
   log_id,
   lead_id,
   lead_line_id,
   sales_credit_id,
   last_update_date,
   last_updated_by,
   last_update_login,
   creation_date,
   created_by,
   log_mode,
   salesforce_id,
   salesgroup_id,
   credit_type_id,
   credit_percent,
   credit_amount,
   opp_worst_forecast_amount,
   opp_forecast_amount,
   opp_best_forecast_amount,
   endday_log_flag) VALUES (
            AS_SALES_CREDIT_LOG_S.nextval,
  decode( p_new_lead_id, FND_API.G_MISS_NUM, NULL, p_new_lead_id),
  decode( p_new_lead_line_id,FND_API.G_MISS_NUM, NULL, p_new_lead_line_id),
  decode( p_new_sales_credit_id,FND_API.G_MISS_NUM, NULL, p_new_sales_credit_id),
  decode( p_new_last_update_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_new_last_update_date),
  decode( p_new_last_updated_by,FND_API.G_MISS_NUM, NULL, p_new_last_updated_by),
  decode( p_new_last_update_login,FND_API.G_MISS_NUM, NULL, p_new_last_update_login),
  decode( p_new_creation_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_new_creation_date),
  decode( p_new_created_by,FND_API.G_MISS_NUM, NULL, p_new_created_by),
  p_TRIGGER_MODE,
  decode( p_new_salesforce_id,FND_API.G_MISS_NUM, NULL, p_new_salesforce_id),
  decode( p_new_salesgroup_id,FND_API.G_MISS_NUM, NULL, p_new_salesgroup_id),
  decode( p_new_credit_type_id,FND_API.G_MISS_NUM, NULL, p_new_credit_type_id),
  decode( p_new_credit_percent,FND_API.G_MISS_NUM, NULL, p_new_credit_percent),
  decode( p_new_credit_amount,FND_API.G_MISS_NUM, NULL, p_new_credit_amount),
  decode( p_new_opp_worst_frcst_amount,FND_API.G_MISS_NUM, NULL, p_new_opp_worst_frcst_amount),
  decode( p_new_opp_frcst_amount,FND_API.G_MISS_NUM, NULL, p_new_opp_frcst_amount),
  decode( p_new_opp_best_frcst_amount,FND_API.G_MISS_NUM, NULL, p_new_opp_best_frcst_amount),
  decode( p_endday_log_flag,FND_API.G_MISS_CHAR, NULL, p_endday_log_flag));
EXCEPTION
WHEN OTHERS THEN
	  -- dbms_output.put_line('In AS_SALES_CREDITS_LOG_PKG After Insert Statement Seems some error');
	  -- dbms_output.put_line('Error Number:'||SQLCODE);
	  -- dbms_output.put_line('Error Message:'|| SUBSTR(SQLERRM, 1, 200));
	  IF l_debug THEN
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtsclb: In AS_SALES_CREDITS_LOG_PKG After Insert Statement Seems some error');
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtsclb: Error Number: '||SQLCODE||' and Error Message: ' || SUBSTR(SQLERRM, 1, 200));
	  END IF;
 END Insert_Row;

 PROCEDURE Update_Row(p_new_lead_id         NUMBER,
	p_new_lead_line_id              NUMBER,
	p_old_sales_credit_id		NUMBER,
	p_old_last_update_date          DATE,
	p_new_last_update_date		DATE,
	p_new_last_updated_by           NUMBER,
    	p_new_last_update_login         NUMBER,
    	p_new_creation_date             DATE,
    	p_new_created_by                NUMBER,
	p_new_salesforce_id		NUMBER,
	p_new_salesgroup_id		NUMBER,
	p_new_credit_type_id		NUMBER,
	p_new_credit_percent		NUMBER,
	p_new_credit_amount		NUMBER,
	p_new_opp_worst_frcst_amount NUMBER,
	p_new_opp_frcst_amount NUMBER,
	p_new_opp_best_frcst_amount NUMBER,
	p_endday_log_flag VARCHAR2,
	p_TRIGGER_MODE 	   		VARCHAR2)
 IS
 	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

 BEGIN
    -- dbms_output.put_line('In AS_SALES_CREDITS_LOG_PKG before Update_Row');
    IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtsclb: In AS_SALES_CREDITS_LOG_PKG before Update_Row');
    END IF;

    Update AS_SALES_CREDITS_LOG
    SET object_version_number =  nvl(object_version_number,0) + 1, lead_id = decode( p_new_lead_id, FND_API.G_MISS_NUM, NULL, p_new_lead_id),
    lead_line_id = decode( p_new_lead_line_id,FND_API.G_MISS_NUM, NULL, p_new_lead_line_id),
    last_update_date = decode( p_new_last_update_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_new_last_update_date),
    last_updated_by = decode( p_new_last_updated_by,FND_API.G_MISS_NUM, NULL, p_new_last_updated_by),
    last_update_login = decode( p_new_last_update_login,FND_API.G_MISS_NUM, NULL, p_new_last_update_login),
    LOG_MODE = p_TRIGGER_MODE,
    salesforce_id = decode( p_new_salesforce_id,FND_API.G_MISS_NUM, NULL, p_new_salesforce_id),
    salesgroup_id = decode( p_new_salesgroup_id,FND_API.G_MISS_NUM, NULL, p_new_salesgroup_id),
    credit_type_id = decode( p_new_credit_type_id,FND_API.G_MISS_NUM, NULL, p_new_credit_type_id),
    credit_percent = decode( p_new_credit_percent,FND_API.G_MISS_NUM, NULL, p_new_credit_percent),
    credit_amount = decode( p_new_credit_amount,FND_API.G_MISS_NUM, NULL, p_new_credit_amount),
    opp_worst_forecast_amount = decode( p_new_opp_worst_frcst_amount,FND_API.G_MISS_NUM, NULL, p_new_opp_worst_frcst_amount),
    opp_forecast_amount = decode( p_new_opp_frcst_amount,FND_API.G_MISS_NUM, NULL, p_new_opp_frcst_amount),
    opp_best_forecast_amount = decode( p_new_opp_best_frcst_amount,FND_API.G_MISS_NUM, NULL, p_new_opp_best_frcst_amount),
    endday_log_flag =   decode( p_endday_log_flag,FND_API.G_MISS_CHAR, endday_log_flag, p_endday_log_flag)
    WHERE log_id = (select max(log_id)
          		  from AS_SALES_CREDITS_LOG
          		  where SALES_CREDIT_ID = p_old_sales_credit_id);

    If (SQL%NOTFOUND) then
	 -- dbms_output.put_line('In AS_SALES_CREDITS_LOG_PKG after Update statement : Data No found seems');
	 -- dbms_output.put_line('Error Number:'||SQLCODE);
	 -- dbms_output.put_line('Error Message:'|| SUBSTR(SQLERRM, 1, 200));

	 IF l_debug THEN
	 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	 	                      'asxtsclb: In AS_SALES_CREDITS_LOG_PKG after Update statement : Data No found seems');
	 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      	'asxtsclb: Error Number: '||SQLCODE||' and Error Message: ' || SUBSTR(SQLERRM, 1, 200));
	 END IF;
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

 Procedure Delete_Row(p_old_lead_id   NUMBER,
  	p_old_lead_line_id 	NUMBER,
	p_old_sales_credit_id	NUMBER,
	p_old_last_update_date  DATE,
	p_old_last_updated_by   NUMBER,
	p_old_last_update_login NUMBER,
	p_old_creation_date     DATE,
  	p_old_created_by        NUMBER,
	p_endday_log_flag VARCHAR2)
 IS
 	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

 BEGIN
    /*
    Update AS_SALES_CREDITS_LOG
    set object_version_number =  nvl(object_version_number,0) + 1, log_mode = 'D'
    where sales_credit_id = p_old_sales_credit_id and last_update_date = p_old_last_update_date;
    */
    Insert into AS_SALES_CREDITS_LOG (
   log_id,
   lead_id,
   lead_line_id,
   sales_credit_id,
   last_update_date,
   last_updated_by,
   last_update_login,
   creation_date,
   created_by,
   log_mode,
   endday_log_flag) VALUES (
            AS_SALES_CREDIT_LOG_S.nextval,
  decode( p_old_lead_id, FND_API.G_MISS_NUM, NULL, p_old_lead_id),
  decode( p_old_lead_line_id,FND_API.G_MISS_NUM, NULL, p_old_lead_line_id),
  decode( p_old_sales_credit_id,FND_API.G_MISS_NUM, NULL, p_old_sales_credit_id),
  sysdate,
  decode( p_old_last_updated_by,FND_API.G_MISS_NUM, NULL, p_old_last_updated_by),
  decode( p_old_last_update_login,FND_API.G_MISS_NUM, NULL, p_old_last_update_login),
  decode( p_old_creation_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_old_creation_date),
  decode( p_old_created_by,FND_API.G_MISS_NUM, NULL, p_old_created_by),
  'D',
  decode( p_endday_log_flag,FND_API.G_MISS_CHAR, NULL, p_endday_log_flag));

EXCEPTION
 WHEN OTHERS THEN
	  -- dbms_output.put_line('In AS_SALES_CREDITS_LOG_PKG After Delete Statement Seems some error');
	  -- dbms_output.put_line('Error Number:'||SQLCODE);
	  -- dbms_output.put_line('Error Message:'|| SUBSTR(SQLERRM, 1, 200));
	  IF l_debug THEN
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  	 	                      'asxtsclb: In AS_SALES_CREDITS_LOG_PKG After Delete Statement Seems some error');
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      	'asxtsclb: Error Number: '||SQLCODE||' and Error Message: ' || SUBSTR(SQLERRM, 1, 200));
	  END IF;

 END Delete_Row;
 END AS_SALES_CREDITS_LOG_PKG;

/
