--------------------------------------------------------
--  DDL for Package Body GCS_CONS_ENG_RUNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CONS_ENG_RUNS_PKG" AS
/* $Header: gcs_eng_runb.pls 120.1 2005/10/30 05:18:01 appldev noship $ */

  -- Declaration of Global Variables
  	g_api	VARCHAR2(200) := 'gcs.plsql.GCS_CONS_ENG_RUNS_PKG';
  -- End of Global Variables

  PROCEDURE	insert_row	(	p_run_name		IN VARCHAR2,
  					p_hierarchy_id		IN NUMBER,
  					p_process_method_code	IN VARCHAR2,
  					p_run_entity_id		IN NUMBER,
  					p_cal_period_id		IN NUMBER,
  					p_balance_type_code	IN VARCHAR2,
  					p_parent_entity_id	IN NUMBER,
  					p_item_key		IN VARCHAR2,
					p_request_id		IN NUMBER)

  IS PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.INSERT_ROW', '<<Enter>>');
    END IF;

    INSERT INTO gcs_cons_eng_runs
    (
    	RUN_NAME,
    	HIERARCHY_ID,
    	PROCESS_METHOD,
    	RUN_ENTITY_ID,
    	CAL_PERIOD_ID,
    	BALANCE_TYPE_CODE,
    	STATUS_CODE,
    	OBJECT_VERSION_NUMBER,
    	CREATION_DATE,
    	CREATED_BY,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN,
    	PARENT_ENTITY_ID,
    	ITEM_KEY,
	LOCKED_FLAG,
	IMPACTED_FLAG,
        MOST_RECENT_FLAG,
    -- Bugfix 3692336 : Add the START_TIME for the Consolidation Process
        START_TIME,
    -- Bugfix 4269147 : Added request_id
        REQUEST_ID

    )
    VALUES
    (
    	p_run_name,
    	p_hierarchy_id,
    	p_process_method_code,
    	p_run_entity_id,
    	p_cal_period_id,
    	p_balance_type_code,
    	'IN_PROGRESS',
    	1,
    	sysdate,
    	fnd_global.user_id,
    	fnd_global.user_id,
    	sysdate,
    	fnd_global.login_id,
    	p_parent_entity_id,
    	p_item_key,
	'N',
	'N',
	'N',
	sysdate,
        p_request_id
    );

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.INSERT_ROW', '<<Exit>>');
    END IF;

    COMMIT;

  END;

  PROCEDURE	update_status	(	p_run_name		IN VARCHAR2,
  					p_most_recent_flag	IN VARCHAR2,
  					p_status_code		IN VARCHAR2,
  					p_run_entity_id		IN NUMBER,
					p_end_time		IN DATE)

  IS PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_STATUS', '<<Enter>>');
    END IF;

    UPDATE gcs_cons_eng_runs
    SET    most_recent_flag	=	p_most_recent_flag,
    	   status_code		=	NVL(p_status_code,status_code),
	   end_time		=	NVL(p_end_time,end_time),
	   last_update_date	=	sysdate,
	   last_updated_by	=	FND_GLOBAL.USER_ID
    WHERE  run_name		=	p_run_name
    AND	   run_entity_id	=	p_run_entity_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_STATUS', '<<Exit>>');
    END IF;


    COMMIT;

  END;

END GCS_CONS_ENG_RUNS_PKG;


/
