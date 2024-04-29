--------------------------------------------------------
--  DDL for Package Body GCS_CONS_ENG_RUN_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CONS_ENG_RUN_DTLS_PKG" AS
/* $Header: gcs_eng_run_dtlb.pls 120.2 2005/12/07 02:23:58 skamdar noship $ */

   g_api	VARCHAR2(80)	:=	'gcs.plsql.GCS_CONS_ENG_RUN_DTLS_PKG';

  PROCEDURE	insert_row	(	p_run_detail_id			OUT NOCOPY NUMBER,
  					p_run_name			IN VARCHAR2,
  					p_consolidation_entity_id	IN NUMBER,
  					p_category_code			IN VARCHAR2,
  					p_child_entity_id		IN NUMBER,
  					p_contra_child_entity_id	IN NUMBER,
  					p_rule_id			IN NUMBER,
  					p_entry_id			IN NUMBER,
  					p_stat_entry_id			IN NUMBER,
  					p_request_error_code		IN VARCHAR2,
  					p_bp_request_error_code		IN VARCHAR2,
  					p_pre_prop_entry_id		IN NUMBER,
  					p_pre_prop_stat_entry_id	IN NUMBER,
  					p_cons_relationship_id		IN NUMBER)

  IS PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.INSERT_ROW', '<<Enter>>');
    END IF;


    INSERT INTO gcs_cons_eng_run_dtls
    (
    	RUN_DETAIL_ID,
    	RUN_NAME,
    	CONSOLIDATION_ENTITY_ID,
    	CATEGORY_CODE,
    	CHILD_ENTITY_ID,
    	CONTRA_CHILD_ENTITY_ID,
    	RULE_ID,
    	ENTRY_ID,
    	STAT_ENTRY_ID,
    	REQUEST_ERROR_CODE,
    	BP_REQUEST_ERROR_CODE,
    	PRE_PROP_ENTRY_ID,
    	PRE_PROP_STAT_ENTRY_ID,
    	CONS_RELATIONSHIP_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN
    )
    VALUES
    (
    	gcs_cons_eng_run_dtls_s.nextval,
    	p_run_name,
    	p_consolidation_entity_id,
    	p_category_code,
    	p_child_entity_id,
    	p_contra_child_entity_id,
    	p_rule_id,
    	p_entry_id,
    	p_stat_entry_id,
    	p_request_error_code,
    	p_bp_request_error_code,
    	p_pre_prop_entry_id,
    	p_pre_prop_stat_entry_id,
    	p_cons_relationship_id,
	sysdate,
  	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.USER_ID,
	FND_GLOBAL.LOGIN_ID
    )
    RETURNING run_detail_id INTO p_run_detail_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.INSERT_ROW', '<<Exit>>');
    END IF;


  COMMIT;

  END;

  PROCEDURE	update_entry_headers(	p_run_detail_id			IN NUMBER,
  					p_entry_id			IN NUMBER,
  					p_stat_entry_id			IN NUMBER 	DEFAULT NULL,
  					p_pre_prop_entry_id		IN NUMBER	DEFAULT NULL,
  					p_pre_prop_stat_entry_id	IN NUMBER	DEFAULT NULL,
  					p_request_error_code		IN VARCHAR2	DEFAULT NULL,
  					p_bp_request_error_code		IN VARCHAR2	DEFAULT NULL
  					)
  IS

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_ENTRY_HEADERS', '<<Enter>>');
    END IF;

    UPDATE gcs_cons_eng_run_dtls
    SET    entry_id			=	NVL(p_entry_id, entry_id),
    	   stat_entry_id		=	NVL(p_stat_entry_id, stat_entry_id),
    	   pre_prop_entry_id		=	NVL(p_pre_prop_entry_id, pre_prop_entry_id),
    	   pre_prop_stat_entry_id	=	NVL(p_pre_prop_stat_entry_id, pre_prop_stat_entry_id),
    	   request_error_code		=	NVL(p_request_error_code, request_error_code),
    	   bp_request_error_code	=	NVL(p_bp_request_error_code, bp_request_error_code),
	   last_update_date		=	sysdate,
	   last_updated_by		=	FND_GLOBAL.user_id
    WHERE  run_detail_id		=	p_run_detail_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_ENTRY_HEADERS', '<<Exit>>');
    END IF;


  END;

  PROCEDURE	update_entry_headers_async(	p_run_detail_id			IN NUMBER,
  						p_entry_id			IN NUMBER	DEFAULT NULL,
  						p_stat_entry_id			IN NUMBER 	DEFAULT NULL,
  						p_pre_prop_entry_id		IN NUMBER	DEFAULT NULL,
  						p_pre_prop_stat_entry_id	IN NUMBER	DEFAULT NULL,
  						p_request_error_code		IN VARCHAR2	DEFAULT NULL,
  						p_bp_request_error_code		IN VARCHAR2	DEFAULT NULL
  					)
  IS PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_ENTRY_HEADERS_ASYNC', '<<Enter>>');
    END IF;

    UPDATE gcs_cons_eng_run_dtls
    SET    entry_id			=	NVL(p_entry_id, entry_id),
    	   stat_entry_id		=	NVL(p_stat_entry_id, stat_entry_id),
    	   pre_prop_entry_id		=	NVL(p_pre_prop_entry_id, pre_prop_entry_id),
    	   pre_prop_stat_entry_id	=	NVL(p_pre_prop_stat_entry_id, pre_prop_stat_entry_id),
    	   request_error_code		=	NVL(p_request_error_code, request_error_code),
    	   bp_request_error_code	=	NVL(p_bp_request_error_code, bp_request_error_code),
	   last_update_date		=	sysdate,
	   last_updated_by		=	FND_GLOBAL.USER_ID
    WHERE  run_detail_id		=	p_run_detail_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_ENTRY_HEADERS_ASYNC', '<<Exit>>');
    END IF;


   COMMIT;
  END;

  FUNCTION 	retrieve_status_code  ( p_consolidation_entity_id	IN NUMBER,
					p_category_code			IN VARCHAR2,
					p_run_name			IN VARCHAR2) RETURN VARCHAR2

  IS
    l_row_count			NUMBER(15);
    l_warning_row_count		NUMBER(15);
    l_status_code		VARCHAR2(30);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RETRIEVE_STATUS_CODE.begin', '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RETRIEVE_STATUS_CODE', 'Consolidation Entity Id : ' || p_consolidation_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RETRIEVE_STATUS_CODE', 'Run Name		 : ' || p_run_name);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RETRIEVE_STATUS_CODE', 'Category Code		 : ' || p_category_code);
    END IF;

    SELECT count(request_error_code)
    INTO   l_row_count
    FROM   gcs_cons_eng_run_dtls
    WHERE  run_name                 =       p_run_name
    AND    consolidation_entity_id  =       p_consolidation_entity_id
    AND    child_entity_id          IS NOT NULL
    AND    category_code            =       p_category_code;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_CATEGORY_STATUS', 'Number of rows : ' || l_row_count);
    END IF;

    IF (l_row_count = 0) THEN
      l_status_code                         :=      'NOT_APPLICABLE';
    ELSE
      SELECT count(request_error_code)
      INTO   l_warning_row_count
      FROM   gcs_cons_eng_run_dtls
      WHERE  run_name                       	=       p_run_name
      AND    consolidation_entity_id        	=       p_consolidation_entity_id
      AND    child_entity_id                	IS NOT NULL
      AND    category_code          		=       p_category_code
      AND    NVL(request_error_code,'X')    	NOT IN  ('COMPLETED','NOT_APPLICABLE');

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_CATEGORY_STATUS', 'Warning Row Count	:       '  || l_warning_row_count);
    END IF;

      IF (l_warning_row_count <> 0) THEN
        l_status_code              :=      'WARNING';
      ELSE
        l_status_code              :=      'COMPLETED';
      END IF;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL		<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_CATEGORY_STATUS', 'Status Code		:	'  || l_status_code);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.RETRIEVE_STATUS_CODE.end', '<<Exit>>');
    END IF;
    return(l_status_code);

  END;

  PROCEDURE	update_category_status(	p_run_name			IN VARCHAR2,
  					p_consolidation_entity_id	IN NUMBER,
  					p_category_code			IN VARCHAR2,
  					p_status			IN VARCHAR2)
  IS PRAGMA AUTONOMOUS_TRANSACTION;

    l_request_error_code	VARCHAR2(30);
    l_row_count			NUMBER(15);
    l_warning_row_count		NUMBER(15);
    l_status_code		VARCHAR2(30);
    l_category_count		NUMBER(15);
    l_category_code	 	VARCHAR2(30);

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_CATEGORY_STATUS', '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_CATEGORY_STATUS', 'Run Name		:	'  || p_run_name);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_CATEGORY_STATUS', 'Consolidation Entity	:	'  || p_consolidation_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_CATEGORY_STATUS', 'Category Code	:	'  || p_category_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.UPDATE_CATEGORY_STATUS', 'Status		:	'  || p_status);
    END IF;

   IF (p_category_code = 'DATAPREPARATION') THEN
     FOR l_category_count IN -1..gcs_categories_pkg.g_oper_category_info.COUNT LOOP
       IF (l_category_count = -1) THEN
	 l_category_code := 'DATAPREPARATION';
       ELSIF (l_category_count = 0) THEN
         l_category_code := 'TRANSLATION';
       ELSE
         l_category_code := gcs_categories_pkg.g_oper_category_info(l_category_count).category_code;
       END IF;

       l_status_code    :=      retrieve_status_code  ( p_consolidation_entity_id       =>      p_consolidation_entity_id,
                                                        p_category_code                 =>      l_category_code,
                                                        p_run_name                      =>      p_run_name);

       UPDATE gcs_cons_eng_run_dtls
       SET    request_error_code  =       l_status_code,
              last_update_date    =       sysdate,
              last_updated_by     =       FND_GLOBAL.LOGIN_ID
       WHERE  run_name                    =       p_run_name
       AND    category_code               =       l_category_code
       AND    consolidation_entity_id     =       p_consolidation_entity_id
       AND    child_entity_id             IS NULL;
     END LOOP;
   ELSE
     IF (p_status = 'COMPLETED' AND p_category_code <> 'AGGREGATION') THEN
       l_status_code	:=	retrieve_status_code  ( p_consolidation_entity_id       =>	p_consolidation_entity_id,
                                			p_category_code                 =>	p_category_code,
                                			p_run_name                      =>	p_run_name);
     ELSE
       l_status_code	:=	p_status;
     END IF;

     UPDATE gcs_cons_eng_run_dtls
     SET    request_error_code	= 	l_status_code,
  	    last_update_date	=	sysdate,
	    last_updated_by	=	FND_GLOBAL.LOGIN_ID
     WHERE  run_name			=	p_run_name
     AND    category_code		=	p_category_code
     AND    consolidation_entity_id	=	p_consolidation_entity_id
     AND    child_entity_id		IS NULL;
   END IF;
   COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_CATEGORY_STATUS', '<<Exit>>');
    END IF;

  END;

  PROCEDURE	update_detail_requests(	p_run_detail_id			IN NUMBER,
  					p_run_process_code		IN VARCHAR2
  					)

  IS

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_DETAIL_REQUESTS', '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.UPDATE_DETAIL_REQUESTS', '<<Exit>>');
    END IF;

  END;

  PROCEDURE 	copy_prior_run_dtls(	p_prior_run_name		IN VARCHAR2,
					p_current_run_name		IN VARCHAR2,
					p_itemtype			IN VARCHAR2,
					p_entity_id			IN NUMBER)

  IS PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    IF (p_itemtype 	=	'GCSOPRWF') THEN
      INSERT INTO gcs_cons_eng_run_dtls
      (
	run_detail_id,
	run_name,
	consolidation_entity_id,
	category_code,
	child_entity_id,
	contra_child_entity_id,
	rule_id,
	entry_id,
	stat_entry_id,
	request_error_code,
	bp_request_error_code,
	cons_relationship_id,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login
      )
      SELECT  gcs_cons_eng_run_dtls_s.nextval,
	      p_current_run_name,
	      consolidation_entity_id,
	      category_code,
	      child_entity_id,
	      contra_child_entity_id,
	      rule_id,
	      entry_id,
	      stat_entry_id,
	      request_error_code,
	      bp_request_error_code,
	      cons_relationship_id,
	      sysdate,
	      FND_GLOBAL.USER_ID,
              sysdate,
	      FND_GLOBAL.USER_ID,
	      FND_GLOBAL.LOGIN_ID
      FROM    gcs_cons_eng_run_dtls
      WHERE   run_name  		=	p_prior_run_name
      AND     child_entity_id		=	p_entity_id
      AND     category_code		IN	(select category_code
						 from 	gcs_categories_b
						 where 	target_entity_code	=	'CHILD'
						 and	category_type_code	<>	'PROCESS');
    ELSE

      DELETE FROM gcs_cons_eng_run_dtls
      WHERE  run_name			=	p_current_run_name
      AND    consolidation_entity_id	=	p_entity_id
      AND    category_code		IN	(select category_code
						 from   gcs_categories_b
						 where  target_entity_code	IN ('ELIMINATION', 'PARENT'))
      AND    child_entity_id		IS	NULL;

      INSERT INTO gcs_cons_eng_run_dtls
      (
	run_detail_id,
	run_name,
	consolidation_entity_id,
	category_code,
	child_entity_id,
	contra_child_entity_id,
	rule_id,
	entry_id,
	stat_entry_id,
	request_error_code,
	bp_request_error_code,
	pre_prop_entry_id,
	pre_prop_stat_entry_id,
	cons_relationship_id,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login
      )
      SELECT gcs_cons_eng_run_dtls_s.nextval,
             p_current_run_name,
	     consolidation_entity_id,
	     category_code,
	     child_entity_id,
	     contra_child_entity_id,
	     rule_id,
	     entry_id,
	     stat_entry_id,
	     request_error_code,
	     bp_request_error_code,
	     pre_prop_entry_id,
	     pre_prop_stat_entry_id,
	     cons_relationship_id,
	     sysdate,
	     FND_GLOBAL.USER_ID,
	     sysdate,
	     FND_GLOBAL.USER_ID,
	     FND_GLOBAL.LOGIN_ID
      FROM   gcs_cons_eng_run_dtls
      WHERE  run_name			=       p_prior_run_name
      AND    consolidation_entity_id	=	p_entity_id
      AND    category_code		IN	(select category_code
						 from   gcs_categories_b
						 where  target_entity_code	IN	('ELIMINATION', 'PARENT'));
   END IF;

   COMMIT;

  END;
END GCS_CONS_ENG_RUN_DTLS_PKG;

/
