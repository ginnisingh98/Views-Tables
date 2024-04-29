--------------------------------------------------------
--  DDL for Package Body AS_OPP_INITIAL_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_INITIAL_LOG_PKG" as
 /* $Header: asxoplgb.pls 120.2 2005/08/12 06:00:27 appldev ship $ */


PROCEDURE write_log(p_module VARCHAR2, p_debug_source NUMBER, p_fpt number, p_mssg  varchar2) IS
	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
BEGIN
     --IF G_Debug AND p_debug_source = G_DEBUG_TRIGGER THEN
        -- Write debug message to message stack
       IF l_debug THEN
       AS_UTILITY_PVT.Debug_Message(p_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, p_mssg);
       END IF;
     --END IF;
     IF p_debug_source = G_DEBUG_CONCURRENT THEN
            -- p_fpt (1,2)?(log : output)
            FND_FILE.put(p_fpt, p_mssg);
            FND_FILE.NEW_LINE(p_fpt, 1);
            -- If p_fpt == 2 and debug flag then also write to log file
            IF p_fpt = 2 And G_Debug THEN
               FND_FILE.put(1, p_mssg);
               FND_FILE.NEW_LINE(1, 1);
            END IF;
     END IF;
    EXCEPTION
        WHEN OTHERS THEN
         NULL;
END Write_Log;
-- Why doesn't use dbms_session.set_sql_trace(TRUE) ?
PROCEDURE trace (p_mode in boolean) is
ddl_curs integer;
v_Dummy  integer;
BEGIN
   null;
EXCEPTION WHEN OTHERS THEN
 NULL;
END trace;
 PROCEDURE Initial_logs(  ERRBUF                OUT NOCOPY VARCHAR2,
    			  RETCODE               OUT NOCOPY VARCHAR2,
			  p_debug_mode          IN  VARCHAR2,
    			  p_trace_mode          IN  VARCHAR2)
 IS
 l_status Boolean;
 l_module CONSTANT VARCHAR2(255) := 'as.plsql.opinlog.Initial_logs';
    BEGIN
    	IF p_debug_mode = 'Y' THEN G_Debug := TRUE; ELSE G_Debug := FALSE; END IF;
    	 IF p_trace_mode = 'Y' THEN trace(TRUE); ELSE trace(FALSE); END IF;
 	IF( UPPER(nvl(FND_PROFILE.VALUE('AS_OPP_ENABLE_LOG'), 'N')) = 'Y' ) THEN
 	BEGIN


 	     Insert into as_leads_log(
 	     LOG_ID , LEAD_ID ,CREATED_BY ,CREATION_DATE  ,
	     LAST_UPDATED_BY , LAST_UPDATE_DATE , LAST_UPDATE_LOGIN ,  STATUS_CODE ,
	     SALES_STAGE_ID  , WIN_PROBABILITY  , DECISION_DATE     ,  SECURITY_GROUP_ID ,
	     ADDRESS_ID , CHANNEL_CODE , CURRENCY_CODE , TOTAL_AMOUNT ,
	     LOG_MODE  , CUSTOMER_ID   , DESCRIPTION   ,SOURCE_PROMOTION_ID  ,
	     OFFER_ID  , CLOSE_COMPETITOR_ID , VEHICLE_RESPONSE_CODE  , SALES_METHODOLOGY_ID ,
	     OWNER_SALESFORCE_ID  ,OWNER_SALES_GROUP_ID , ORG_ID,
	     LOG_START_DATE, LOG_END_DATE, LOG_ACTIVE_DAYS, ENDDAY_LOG_FLAG, CURRENT_LOG )

	     SELECT  AS_LEAD_LOG_S.nextval   , a.LEAD_ID ,a.CREATED_BY ,a.CREATION_DATE  ,
	     a.LAST_UPDATED_BY , a.LAST_UPDATE_DATE , a.LAST_UPDATE_LOGIN ,  a.STATUS ,
	     a.SALES_STAGE_ID  , a.WIN_PROBABILITY  , a.DECISION_DATE     ,  a.SECURITY_GROUP_ID ,
	     a.ADDRESS_ID , a.CHANNEL_CODE , a.CURRENCY_CODE , a.TOTAL_AMOUNT ,
	     'I', a.CUSTOMER_ID   , a.DESCRIPTION   ,a.SOURCE_PROMOTION_ID ,
	     a.OFFER_ID  , a.CLOSE_COMPETITOR_ID , a.VEHICLE_RESPONSE_CODE  , a.SALES_METHODOLOGY_ID ,
	     a.OWNER_SALESFORCE_ID  ,a.OWNER_SALES_GROUP_ID , a.ORG_ID,
	     LAST_UPDATE_DATE, LAST_UPDATE_DATE, 0, 'Y', 1
	     FROM AS_LEADS_ALL a
		  where a.lead_id not in ( select log.lead_id from AS_LEADS_LOG log);

   	    write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Refresh of as_leads_log Process Completed @: '||to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));
 	    COMMIT;
 	  EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 		ERRBUF := ERRBUF||'Error in logging updation of AS_LEADS_LOG:'||to_char(sqlcode)||sqlerrm;
 		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
 		write_log(l_module, G_DEBUG_CONCURRENT, 1,'Error in logging updation of AS_LEADS_LOG');
      		write_log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
 		ROLLBACK;
 		l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
 		IF l_status = TRUE THEN
 			write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
 		END IF;
 		WHEN OTHERS THEN
 		ERRBUF := ERRBUF||'Error :'||to_char(sqlcode)||sqlerrm;
 		RETCODE := '2';
 		write_log(l_module, G_DEBUG_CONCURRENT, 1,'Error in SC Denorm Main');
      		write_log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
 		ROLLBACK;
 		l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
 		IF l_status = TRUE THEN
 			write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
		END IF;
 	END;
 	END IF;
 	IF( UPPER(nvl(FND_PROFILE.VALUE('AS_OPP_LINE_ENABLE_LOG'), 'N')) = 'Y' ) THEN
 	BEGIN
		Insert into AS_LEAD_LINES_LOG (
		   log_id,  lead_id,   lead_line_id,
		   last_update_date,   last_updated_by,   last_update_login,   creation_date,
		   created_by,   log_mode,   interest_type_id,   primary_interest_code_id,   secondary_interest_code_id,
           product_category_id, product_cat_set_id,
		   inventory_item_id,   organization_id,   source_promotion_id,   offer_id,   org_id,
		   forecast_date,   rolling_forecast_flag, endday_log_flag)
		 SELECT AS_LEAD_LINES_LOG_S.NEXTVAL , a.lead_id,   a.lead_line_id,
		   a.last_update_date,   a.last_updated_by,   a.last_update_login,   a.creation_date,
		   a.created_by,   'I',   a.interest_type_id,   a.primary_interest_code_id,   a.secondary_interest_code_id,
           a.product_category_id, a.product_cat_set_id,
		   a.inventory_item_id,   a.organization_id,   a.source_promotion_id,   a.offer_id,   a.org_id,
		   a.forecast_date ,   a.rolling_forecast_flag, 'Y'
		  FROM AS_LEAD_LINES_ALL a
		  where a.lead_line_id not in ( select log.lead_line_id from AS_LEAD_LINES_LOG log);
		  write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Refresh of as_lead_lines_log Process Completed @: '||to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));
		  COMMIT;
	EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 		ERRBUF := ERRBUF||'Error in loging of AS_LEAD_LINES_LOG:'||to_char(sqlcode)||sqlerrm;
 		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
 		write_log(l_module, G_DEBUG_CONCURRENT, 1,'Error in loging of AS_LEAD_LINES_LOG');
      		write_log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
 		ROLLBACK;
 		l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
 		IF l_status = TRUE THEN
 			write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
 		END IF;
 	WHEN OTHERS THEN
 		ERRBUF := ERRBUF||'Error in loging of AS_LEAD_LINES_LOG:'||to_char(sqlcode)||sqlerrm;
 		RETCODE := '2';
 		write_log(l_module, G_DEBUG_CONCURRENT, 1,'Error in loging of AS_LEAD_LINES_LOG');
      		write_log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
 		ROLLBACK;
 		l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
 		IF l_status = TRUE THEN
 			write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
		END IF;
	END;
	END IF;
 	IF( UPPER(nvl(FND_PROFILE.VALUE('AS_OPP_SC_ENABLE_LOG'), 'N')) = 'Y' ) THEN
 	BEGIN
 		  Insert into AS_SALES_CREDITS_LOG (   log_id,
		   lead_id,   lead_line_id,   sales_credit_id,   last_update_date,
		   last_updated_by,   last_update_login,   creation_date,   created_by,
		   log_mode,   salesforce_id,   salesgroup_id,	credit_type_id,
		   credit_percent, credit_amount, endday_log_flag)
		   SELECT AS_SALES_CREDIT_LOG_S.NEXTVAL ,
		   lead_id,   lead_line_id,   sales_credit_id,   last_update_date,
		   last_updated_by,   last_update_login,   creation_date,   created_by,
		   'I',   salesforce_id,   salesgroup_id,   credit_type_id,
		   credit_percent, credit_amount, 'Y'
		   FROM  AS_SALES_CREDITS
		   where AS_SALES_CREDITS.sales_credit_id not in (select AS_SALES_CREDITS_LOG.sales_credit_id
							  FROM AS_SALES_CREDITS_LOG);
		  write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Refresh of as_sales_credits_log Process Completed @: '||to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));
		  COMMIT;
	EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 		ERRBUF := ERRBUF||'Error in login of AS_SALES_CREDITS_LOG:'||to_char(sqlcode)||sqlerrm;
 		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
 		write_log(l_module, G_DEBUG_CONCURRENT, 1,'Error in login of AS_SALES_CREDITS_LOG');
      		write_log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
 		ROLLBACK;
 		l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
 		IF l_status = TRUE THEN
 			write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
 		END IF;
 		WHEN OTHERS THEN
 		ERRBUF := ERRBUF||'Error in login of AS_SALES_CREDITS_LOG:'||to_char(sqlcode)||sqlerrm;
 		RETCODE := '2';
 		write_log(l_module, G_DEBUG_CONCURRENT, 1,'Error in login of AS_SALES_CREDITS_LOG');
      		write_log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
 		ROLLBACK;
 		l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
 		IF l_status = TRUE THEN
 			write_log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
		END IF;
	END;
 	END IF;
 END Initial_logs;
END AS_OPP_INITIAL_LOG_PKG;

/
