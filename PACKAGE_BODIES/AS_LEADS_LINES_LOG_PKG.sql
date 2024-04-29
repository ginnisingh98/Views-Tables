--------------------------------------------------------
--  DDL for Package Body AS_LEADS_LINES_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LEADS_LINES_LOG_PKG" as
 /* $Header: asxtlnlb.pls 120.2 2005/09/02 04:05:26 appldev ship $ */
 PROCEDURE Insert_Row( p_lead_id    NUMBER,
  p_lead_line_id                    NUMBER,
  p_last_update_date                        DATE,
  p_last_updated_by                         NUMBER,
  p_last_update_login                       NUMBER,
  p_creation_date                   DATE,
  p_created_by                              NUMBER,
  p_interest_type_id                        NUMBER,
  p_primary_interest_code_id                NUMBER,
  p_secondary_interest_code_id              NUMBER,
  p_product_category_id                     NUMBER,
  p_product_cat_set_id                      NUMBER,
  p_inventory_item_id                       NUMBER,
  p_organization                    NUMBER,
  p_source_promotion_id                     NUMBER,
  p_offer_id                                NUMBER,
  p_org_id                          NUMBER,
  p_forecast_date                   DATE,
  p_rolling_forecast_flag           VARCHAR2,
  p_endday_log_flag         VARCHAR2,
  p_TRIGGER_MODE 	   	    VARCHAR2)
 IS
 l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

 BEGIN

  IF l_debug THEN
  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtlnlb: In AS_LEADS_LINES_LOG_PKG Before Insert Statement');
  END IF;
  Insert into AS_LEAD_LINES_LOG (
   log_id,
   lead_id,
   lead_line_id,
   last_update_date,
   last_updated_by,
   last_update_login,
   creation_date,
   created_by,
   log_mode,
   interest_type_id,
   primary_interest_code_id,
   secondary_interest_code_id,
   product_category_id,
   product_cat_set_id,
   inventory_item_id,
   organization_id,
   source_promotion_id,
   offer_id,
   org_id,
   forecast_date,
   rolling_forecast_flag,
   endday_log_flag) VALUES (
         AS_LEAD_LINES_LOG_S.nextval,
  decode( p_lead_id, FND_API.G_MISS_NUM, NULL, p_lead_id),
  decode( p_lead_line_id,FND_API.G_MISS_NUM, NULL, p_lead_line_id),
  decode( p_last_update_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_last_update_date),
  decode( p_last_updated_by,FND_API.G_MISS_NUM, NULL, p_last_updated_by),
  decode( p_last_update_login,FND_API.G_MISS_NUM, NULL, p_last_update_login),
  decode( p_creation_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_creation_date),
  decode( p_created_by,FND_API.G_MISS_NUM, NULL, p_created_by),
  p_TRIGGER_MODE,
  decode( p_interest_type_id,FND_API.G_MISS_NUM, NULL, p_interest_type_id),
  decode( p_primary_interest_code_id,FND_API.G_MISS_NUM, NULL, p_primary_interest_code_id),
  decode( p_secondary_interest_code_id,FND_API.G_MISS_NUM, NULL, p_secondary_interest_code_id),
  decode( p_product_category_id,FND_API.G_MISS_NUM, NULL, p_product_category_id),
  decode( p_product_cat_set_id,FND_API.G_MISS_NUM, NULL, p_product_cat_set_id),
  decode( p_inventory_item_id,FND_API.G_MISS_NUM, NULL, p_inventory_item_id),
  decode( p_organization,FND_API.G_MISS_NUM, NULL, p_organization),
  decode( p_source_promotion_id,FND_API.G_MISS_NUM, NULL, p_source_promotion_id),
  decode( p_offer_id,FND_API.G_MISS_NUM, NULL, p_offer_id),
  decode( p_org_id,FND_API.G_MISS_NUM, NULL, p_org_id),
  decode( p_forecast_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_forecast_date),
  decode( p_rolling_forecast_flag,FND_API.G_MISS_CHAR, NULL, p_rolling_forecast_flag),
  decode( p_endday_log_flag,FND_API.G_MISS_CHAR, NULL, p_endday_log_flag));

EXCEPTION
WHEN OTHERS THEN
	  -- dbms_output.put_line('In AS_LEADS_LINES_LOG_PKG After Insert Statement Seems some error');
	   -- dbms_output.put_line('Error Number:'||SQLCODE);
	  -- dbms_output.put_line('Error Message:'|| SUBSTR(SQLERRM, 1, 200));

	  IF l_debug THEN
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtlnlb: In AS_LEADS_LINES_LOG_PKG After Insert Statement Seems some error');
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtlnlb: Error Number: '||SQLCODE||' and Error Message: ' || SUBSTR(SQLERRM, 1, 200));
	  END IF;
 END Insert_Row;
 PROCEDURE Update_Row(
    p_lead_id                       NUMBER,
    old_lead_line_id                NUMBER,
    old_last_update_date            DATE,
    new_last_update_date		    DATE,
    p_last_updated_by               NUMBER,
    p_last_update_login             NUMBER,
    p_creation_date                 DATE,
    p_created_by                    NUMBER,
    p_interest_type_id              NUMBER,
    p_primary_interest_code_id      NUMBER,
    p_secondary_interest_code_id    NUMBER,
    p_product_category_id           NUMBER,
    p_product_cat_set_id            NUMBER,
    p_inventory_item_id             NUMBER,
    p_organization_id               NUMBER,
    p_source_promotion_id           NUMBER,
    p_offer_id                      NUMBER,
    p_org_id                        NUMBER,
    p_forecast_date                 DATE,
    p_rolling_forecast_flag         VARCHAR2,
    p_endday_log_flag       VARCHAR2,
    p_TRIGGER_MODE 	   	    VARCHAR2)
 IS

 l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
 BEGIN
    -- dbms_output.put_line('In AS_LEADS_LINES_LOG_PKG before Update_Row');
    	  IF l_debug THEN
    	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtlnlb: In AS_LEADS_LINES_LOG_PKG before Update_Row');
	  END IF;
    Update AS_LEAD_LINES_LOG
    SET object_version_number =  nvl(object_version_number,0) + 1, lead_id = decode( p_lead_id, FND_API.G_MISS_NUM, NULL, p_lead_id),
    last_update_date = decode( new_last_update_date,FND_API.G_MISS_DATE, TO_DATE(NULL), new_last_update_date),
    last_updated_by = decode( p_last_updated_by,FND_API.G_MISS_NUM, NULL, p_last_updated_by),
    last_update_login = decode( p_last_update_login,FND_API.G_MISS_NUM, NULL, p_last_update_login),
    LOG_MODE = p_TRIGGER_MODE,
    interest_type_id = decode( p_interest_type_id,FND_API.G_MISS_NUM, NULL, p_interest_type_id),
    primary_interest_code_id = decode( p_primary_interest_code_id,FND_API.G_MISS_NUM, NULL, p_primary_interest_code_id),
    secondary_interest_code_id = decode( p_secondary_interest_code_id,FND_API.G_MISS_NUM, NULL, p_secondary_interest_code_id),
    product_category_id = decode( p_product_category_id,FND_API.G_MISS_NUM, NULL, p_product_category_id),
    product_cat_set_id = decode( p_product_cat_set_id,FND_API.G_MISS_NUM, NULL, p_product_cat_set_id),
    inventory_item_id = decode( p_inventory_item_id,FND_API.G_MISS_NUM, NULL, p_inventory_item_id),
    organization_id =  decode( p_organization_id,FND_API.G_MISS_NUM, NULL, p_organization_id),
    source_promotion_id = decode( p_source_promotion_id,FND_API.G_MISS_NUM, NULL, p_source_promotion_id),
    offer_id = decode( p_offer_id,FND_API.G_MISS_NUM, NULL, p_offer_id),
    org_id = decode( p_org_id,FND_API.G_MISS_NUM, NULL, p_org_id),
    forecast_date = decode( p_forecast_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_forecast_date),
    rolling_forecast_flag =   decode( p_rolling_forecast_flag,FND_API.G_MISS_CHAR, NULL, p_rolling_forecast_flag),
    endday_log_flag =   decode( p_endday_log_flag,FND_API.G_MISS_CHAR, endday_log_flag, p_endday_log_flag)
    WHERE LOG_ID = (SELECT max(log_id)
                    	  from AS_LEAD_LINES_LOG
            		  where lead_line_id = old_lead_line_id);

    If (SQL%NOTFOUND) then
	  -- dbms_output.put_line('In AS_LEADS_LINES_LOG_PKG after Update statement : Data No found seems');
	  -- dbms_output.put_line('Error Number:'||SQLCODE);
	  -- dbms_output.put_line('Error Message:'|| SUBSTR(SQLERRM, 1, 200));
	 IF l_debug THEN
	 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	 	                      'asxtlnlb: In AS_LEADS_LINES_LOG_PKG after Update statement : Data No found seems');
	 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtlnlb: Error Number: '||SQLCODE||' and Error Message: ' || SUBSTR(SQLERRM, 1, 200));
	 END IF;
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

 Procedure Delete_Row(p_old_lead_id	NUMBER,
  		p_old_lead_line_id 	NUMBER,
		p_old_last_update_date      DATE,
		p_old_last_updated_by       NUMBER,
		p_old_last_update_login     NUMBER,
		p_old_creation_date         DATE,
  		p_old_created_by            NUMBER,
        p_endday_log_flag           VARCHAR2)
 IS
 l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

 BEGIN
    /*
    Update AS_LEAD_LINES_LOG
    set object_version_number =  nvl(object_version_number,0) + 1, log_mode = 'D'
    where lead_line_id = old_lead_line_id and last_update_date = old_last_update_date;
    */
   -- dbms_output.put_line('In AS_LEADS_LINES_LOG_PKG before Delete_Row');
   -- dbms_output.put_line('Lead Id:'|| p_old_lead_id);
   -- dbms_output.put_line('Lead line Id:'|| p_old_lead_line_id);
   -- dbms_output.put_line('p_old_last_update_date:'|| p_old_last_update_date);
   -- dbms_output.put_line('p_old_last_updated_by:'|| p_old_last_updated_by);
   -- dbms_output.put_line('p_old_last_update_login:'|| p_old_last_update_login);
   -- dbms_output.put_line('p_old_creation_date:'|| p_old_creation_date);
   -- dbms_output.put_line('p_old_created_by:'|| p_old_created_by);

   Insert into AS_LEAD_LINES_LOG (
   log_id,
   lead_id,
   lead_line_id,
   last_update_date,
   last_updated_by,
   last_update_login,
   creation_date,
   created_by,
   log_mode,
   endday_log_flag
  ) VALUES (
   AS_LEAD_LINES_LOG_S.nextval,
  decode( p_old_lead_id, FND_API.G_MISS_NUM, NULL, p_old_lead_id),
  decode( p_old_lead_line_id,FND_API.G_MISS_NUM, NULL, p_old_lead_line_id),
  sysdate,
  decode( p_old_last_updated_by,FND_API.G_MISS_NUM, NULL, p_old_last_updated_by),
  decode( p_old_last_update_login,FND_API.G_MISS_NUM, NULL, p_old_last_update_login),
  decode( p_old_creation_date,FND_API.G_MISS_DATE, TO_DATE(NULL), p_old_creation_date),
  decode( p_old_created_by,FND_API.G_MISS_NUM, NULL, p_old_created_by),
  'D',
  decode( p_endday_log_flag,FND_API.G_MISS_CHAR, NULL, p_endday_log_flag));

 EXCEPTION
 WHEN OTHERS THEN
	  -- dbms_output.put_line('In AS_LEADS_LINES_LOG_PKG After Delete Statement Seems some error');
	  -- dbms_output.put_line('Error Number:'||SQLCODE);
	  -- dbms_output.put_line('Error Message:'|| SUBSTR(SQLERRM, 1, 200));
	  IF l_debug THEN
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  	 	                      'asxtlnlb: In AS_LEADS_LINES_LOG_PKG After Delete Statement Seems some error');
	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                      'asxtlnlb: Error Number: '||SQLCODE||' and Error Message: ' || SUBSTR(SQLERRM, 1, 200));
	  END IF;

 END Delete_Row;

 END AS_LEADS_LINES_LOG_PKG;

/
