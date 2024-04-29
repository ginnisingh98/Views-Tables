--------------------------------------------------------
--  DDL for Package Body IEX_WF_DEL_CUR_STATUS_NOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WF_DEL_CUR_STATUS_NOTE_PUB" AS
/* $Header: iexwfcnb.pls 120.1 2006/05/30 21:18:49 scherkas noship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which will launch workflow.
 * This procedure is called to workflow to notify owner and manager
 * if the delinquency is closed(Current)
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_WF_DEL_CUR_STATUS_NOTE_PUB';


    -- WorkFlow Defaults
    v_itemtype              VARCHAR2(10) ;
    v_itemkey       	   	VARCHAR2(30);
    workflowprocess      	VARCHAR2(30);


    l_type_id    NUMBER;
    l_owner_id   NUMBER;
    l_owner_name VARCHAR2(360);
    l_mgr_id     NUMBER;
    l_mgr_name   VARCHAR2(360);

    -- Forward Declaration
    PROCEDURE clear_table_values ;


--    PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE start_workflow
    (
            p_api_version     IN NUMBER := 1.0,
            p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
            p_commit          IN VARCHAR2 := FND_API.G_FALSE,
            p_delinquency_ids IN IEX_UTILITIES.t_del_id,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2
    )
    IS
	    p_delinquency_id	Number ;
        l_result             	VARCHAR2(10);

        l_error_msg     	VARCHAR2(2000);
        l_return_status     	VARCHAR2(20);
        l_msg_count     	NUMBER;
        l_msg_data           	VARCHAR2(2000);
        l_api_name           	VARCHAR2(100) := 'START_WORKFLOW';
        l_api_version_number 	CONSTANT NUMBER   := 1.0;

	    v_del_notification_cur	DEL_NOTIFICATION_CUR ;

        v_lit_sql    varchar2(2000) ;
	    v_wof_sql    varchar2(2000) ;
	    v_rep_sql    varchar2(2000) ;
	    v_ban_sql    varchar2(2000) ;
	    v_end_sql	   varchar2(2000) ;

    BEGIN
      -- Standard Start of API savepoint
      -- SAVEPOINT START_WORKFLOW;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      v_itemtype := 'IEXDELCN';
      workflowprocess := 'DEL_STATUS_NOTICE';

	  -- Common SQL Attachment
      v_end_sql :=  v_end_sql || ', iex_delinquencies_all d, JTF_RS_RESOURCE_EXTNS r ' ;
	  v_end_sql :=  v_end_sql || 'where d.delinquency_id = :p_delinquency_id  ' ;
	  v_end_sql :=  v_end_sql || 'and d.delinquency_id = l.delinquency_id ' ;
      v_end_sql :=  v_end_sql || 'and l.created_by = r.user_id ' ;


      -- Litigation SQL Query
	  v_lit_sql :=   ' select l.created_by, l.litigation_id, r.SOURCE_NAME, ' ;
	  v_lit_sql :=  v_lit_sql || 'NVL(r.SOURCE_MGR_ID, l.created_by), NVL(r.SOURCE_MGR_NAME, r.SOURCE_NAME)' ;
	  v_lit_sql :=  v_lit_sql || ' from IEX_LITIGATIONS l  ';

        -- WriteOff SQL Query
	  v_wof_sql :=   ' select l.created_by, l.writeoff_id, r.SOURCE_NAME, ' ;
	  v_wof_sql :=  v_wof_sql || 'NVL(r.SOURCE_MGR_ID, l.created_by), NVL(r.SOURCE_MGR_NAME, r.SOURCE_NAME)' ;
	  v_wof_sql :=  v_wof_sql || ' from IEX_WRITEOFFS l  ';

      -- Bankruptcy SQL Query
	  v_ban_sql :=   ' select l.created_by, l.bankruptcy_id, r.SOURCE_NAME, ' ;
	  v_ban_sql :=  v_ban_sql || 'NVL(r.SOURCE_MGR_ID, l.created_by), NVL(r.SOURCE_MGR_NAME, r.SOURCE_NAME)' ;
	  v_ban_sql :=  v_ban_sql || ' from IEX_BANKRUPTCIES l  ';

      -- Repossession SQL Query
	  v_rep_sql :=   ' select l.created_by, l.repossession_id, r.SOURCE_NAME, ' ;
	  v_rep_sql :=  v_rep_sql || 'NVL(r.SOURCE_MGR_ID, l.created_by), NVL(r.SOURCE_MGR_NAME, r.SOURCE_NAME)' ;
	  v_rep_sql :=  v_rep_sql || ' from IEX_REPOSSESSIONS l ';

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Litigation SQL');
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '--------------');
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || v_lit_sql || v_end_sql);
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '--------------');
      END IF;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Repo SQL');
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '--------------');
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || v_rep_sql || v_end_sql);
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '--------------');
      END IF;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Bank SQL');
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '--------------');
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || v_ban_sql || v_end_sql);
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '--------------');
      END IF;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Woff SQL');
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '--------------');
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || v_wof_sql || v_end_sql);
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '--------------');
      END IF;

        -- INITIALIZING PL/SQL TABLES
	  p_wf_item_number_name(1) := 'DELINQUENCY_ID' ;
	  p_wf_item_number_name(p_wf_item_number_name.LAST + 1) := 'TYPE_ID' ;
	  p_wf_item_number_name(p_wf_item_number_name.LAST + 1) := 'OWNER_ID' ;
	  p_wf_item_number_name(p_wf_item_number_name.LAST + 1) := 'MANAGER_ID' ;


	  p_wf_item_text_name(1) := 'SUB_DEL_TYPE' ;
	  p_wf_item_text_name(p_wf_item_text_name.LAST + 1) := 'OWNER_NAME' ;
      p_wf_item_text_name(p_wf_item_text_name.LAST + 1) := 'MANAGER_NAME' ;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Delinquency Table Size ' || to_char(p_delinquency_ids.COUNT));
      END IF;

      -- Starting the WorkFlow

      FOR cnt in p_delinquency_ids.FIRST..p_delinquency_ids.LAST
      LOOP
	    p_wf_item_number_value(1) := p_delinquency_ids(cnt) ;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' ---------------------------------------------------');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' Delinquency Id >> ' || to_char(p_delinquency_ids(cnt)));
        END IF;

        /* ___________________ LITIGATIONS WORKFLOW  _____________________*/
        BEGIN
	       OPEN v_del_notification_cur FOR v_lit_sql || v_end_sql
            USING  p_delinquency_ids(cnt) ;

	       FETCH v_del_notification_cur
	       INTO 	l_owner_id,
           	    	l_type_id,
           		    l_owner_name,
           		    l_mgr_id,
    			    l_mgr_name	;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' Lit Data>> ' || to_char(l_owner_id) || ' >> ' || to_char(l_type_id) || ' >> '|| l_owner_name || ' >> ' || to_char(l_mgr_id) || ' >> ' || l_mgr_name );
           END IF;

        EXCEPTION
            WHEN OTHERS THEN
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' Liti >> ' || SQLCODE || ' >> ' || SQLERRM);
                END IF;
        END MAIN ;

        IF v_del_notification_cur%FOUND THEN
--   	        IF PG_DEBUG < 10  THEN
   	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'START LIT PROCESS Owner id '||l_owner_id);
   	        END IF;
--   	        IF PG_DEBUG < 10  THEN
   	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'START LIT PROCESS Type id '||l_type_id);
   	        END IF;

            select 'LIT_' || to_char(IEX_DEL_WF_S.Nextval)
            INTO v_itemkey
            from dual ;

	        -- Setting all Numeric Attributes.
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_type_id ;
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_owner_id ;
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_mgr_id ;


		    -- Setting all Text Attributes.
	        p_wf_item_text_value(1) := 'LITIGATION'  ;
	        p_wf_item_text_value(p_wf_item_text_value.LAST + 1) := l_owner_name  ;
	        p_wf_item_text_value(p_wf_item_text_value.LAST + 1) := l_mgr_name  ;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '************ LITIGATION ***************');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Num Name count >> ' || to_char(p_wf_item_number_name.count) || 'Num Value count >> ' || to_char(p_wf_item_number_value.count));
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Text Name count >> ' || to_char(p_wf_item_text_name.count) || 'Text Value count >> ' || to_char(p_wf_item_text_value.count));
            END IF;



	        SEND_NOTIFICATION(
                    v_itemtype			,
					v_itemkey			,
					p_wf_item_NUMBER_NAME 	,
					p_wf_item_NUMBER_VALUE	,
					p_wf_item_TEXT_NAME	,
					p_wf_item_TEXT_VALUE	,
					l_return_status		,
					l_result			) ;

--      	    IF PG_DEBUG < 10  THEN
      	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      	       IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Lit Return Status '||v_ItemKey||' '||l_return_status);
      	    END IF;


            Clear_Table_Values ;

        END IF ;
	    CLOSE v_del_notification_cur ;

        /* ___________________ BANKRUPTCY WORKFLOW  _____________________*/
        BEGIN
	       OPEN v_del_notification_cur FOR v_ban_sql || v_end_sql
            USING  p_delinquency_ids(cnt) ;

	       FETCH v_del_notification_cur
	       INTO 	l_owner_id,
           	    	l_type_id,
           		l_owner_name,
           		l_mgr_id,
    			l_mgr_name	;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' BAN Data>> ' || to_char(l_owner_id) || ' >> ' || to_char(l_type_id) || ' >> '|| l_owner_name || ' >> ' || to_char(l_mgr_id) || ' >> ' || l_mgr_name );
           END IF;

        EXCEPTION
            WHEN OTHERS THEN
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' Bank >> ' || SQLCODE || ' >> ' || SQLERRM);
                END IF;
        END MAIN ;

        IF v_del_notification_cur%FOUND THEN

--   	        IF PG_DEBUG < 10  THEN
   	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'START BANK PROCESS Owner id '||l_owner_id);
   	        END IF;
--   	        IF PG_DEBUG < 10  THEN
   	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'START BANK PROCESS Type id '||l_type_id);
   	        END IF;

            select 'BAN_' || to_char(IEX_DEL_WF_S.Nextval)
            INTO v_itemkey
            from dual ;

	        -- Setting all Numeric Attributes.
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_type_id ;
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_owner_id ;
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_mgr_id ;

		    -- Setting all Text Attributes.
	        p_wf_item_text_value(1) := 'BANKRUPTCY'  ;
	        p_wf_item_text_value(p_wf_item_text_value.LAST + 1) := l_owner_name  ;
	        p_wf_item_text_value(p_wf_item_text_value.LAST + 1) := l_mgr_name  ;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '************ BANKRUPTCY ***************');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Num Name count >> ' || to_char(p_wf_item_number_name.count) || 'Num Value count >> ' || to_char(p_wf_item_number_value.count));
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Text Name count >> ' || to_char(p_wf_item_text_name.count) || 'Text Value count >> ' || to_char(p_wf_item_text_value.count));
            END IF;

	        SEND_NOTIFICATION(
                    v_itemtype			,
					v_itemkey			,
					p_wf_item_NUMBER_NAME 	,
					p_wf_item_NUMBER_VALUE	,
					p_wf_item_TEXT_NAME	,
					p_wf_item_TEXT_VALUE	,
					l_return_status		,
					l_result			) ;

      	    --IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      	    --IEX_DEBUG_PUB.LOGMESSAGE('Bank Ret Status '||ItemKey||' '||l_return_status);
      	    --END IF;

            Clear_Table_Values ;
        END IF ;
	    CLOSE v_del_notification_cur ;


        /* ___________________ WRITE OFF WORKFLOW  _____________________*/
        BEGIN
	       OPEN v_del_notification_cur FOR v_wof_sql || v_end_sql
            USING  p_delinquency_ids(cnt) ;

	       FETCH v_del_notification_cur
	       INTO l_owner_id,
           	    l_type_id,
           		l_owner_name,
           		l_mgr_id,
    			l_mgr_name	;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '  Data>> ' || to_char(l_owner_id) || ' >> ' || to_char(l_type_id) || ' >> '|| l_owner_name || ' >> ' || to_char(l_mgr_id) || ' >> ' || l_mgr_name );
           END IF;

        EXCEPTION
            WHEN OTHERS THEN
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' Write Off >>' || SQLCODE || ' >> ' || SQLERRM);
                END IF;
        END MAIN ;

        IF v_del_notification_cur%FOUND THEN

--   	        IF PG_DEBUG < 10  THEN
   	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'START wof PROCESS Owner id '||l_owner_id);
   	        END IF;
--   	        IF PG_DEBUG < 10  THEN
   	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'START WOF PROCESS Type id '||l_type_id);
   	        END IF;

            select 'WRI_' || to_char(IEX_DEL_WF_S.Nextval)
            INTO v_itemkey
            from dual ;

	        -- Setting all Numeric Attributes.
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_type_id ;
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_owner_id ;
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_mgr_id ;

		    -- Setting all Text Attributes.
	        p_wf_item_text_value(1) := 'WRITEOFF'  ;
	        p_wf_item_text_value(p_wf_item_text_value.LAST + 1) := l_owner_name  ;
	        p_wf_item_text_value(p_wf_item_text_value.LAST + 1) := l_mgr_name  ;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '************ WRITE OFF ***************');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Num Name count >> ' || to_char(p_wf_item_number_name.count) || 'Num Value count >> ' || to_char(p_wf_item_number_value.count));
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Text Name count >> ' || to_char(p_wf_item_text_name.count) || 'Text Value count >> ' || to_char(p_wf_item_text_value.count));
            END IF;

	        SEND_NOTIFICATION(
                    v_itemtype			,
					v_itemkey			,
					p_wf_item_NUMBER_NAME 	,
					p_wf_item_NUMBER_VALUE	,
					p_wf_item_TEXT_NAME	,
					p_wf_item_TEXT_VALUE	,
					l_return_status		,
					l_result			) ;

      	    --IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      	    --IEX_DEBUG_PUB.LOGMESSAGE('WRI Return Status '||ItemKey||' '||l_return_status);
      	    --END IF;

            Clear_Table_Values ;
        END IF ;
	    CLOSE v_del_notification_cur ;

        /* ___________________ REPOSSESSION WORKFLOW  _____________________*/
        BEGIN
	       OPEN v_del_notification_cur FOR v_rep_sql || v_end_sql
            USING  p_delinquency_ids(cnt) ;

	       FETCH v_del_notification_cur
	       INTO 	l_owner_id,
           	    	l_type_id,
           		l_owner_name,
           		l_mgr_id,
    			l_mgr_name	;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' Repo Data>> ' || to_char(l_owner_id) || ' >> ' || to_char(l_type_id) || ' >> '|| l_owner_name || ' >> ' || to_char(l_mgr_id) || ' >> ' || l_mgr_name );
           END IF;

        EXCEPTION
            WHEN OTHERS THEN
--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || ' Repo >>' || SQLCODE || ' >> ' || SQLERRM);
                END IF;
        END MAIN ;

        IF v_del_notification_cur%FOUND THEN

--   	        IF PG_DEBUG < 10  THEN
   	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'START Repo PROCESS Owner id '||l_owner_id);
   	        END IF;
--   	        IF PG_DEBUG < 10  THEN
   	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   	           IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'START REPO PROCESS Type id '||l_type_id);
   	        END IF;

            select 'REP_' || to_char(IEX_DEL_WF_S.Nextval)
            INTO v_itemkey
            from dual ;

	        -- Setting all Numeric Attributes.
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_type_id ;
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_owner_id ;
	        p_wf_item_number_value(p_wf_item_number_value.LAST + 1) := l_mgr_id ;

		    -- Setting all Text Attributes.
	        p_wf_item_text_value(1) := 'WRITEOFF'  ;
	        p_wf_item_text_value(p_wf_item_text_value.LAST + 1) := l_owner_name  ;
	        p_wf_item_text_value(p_wf_item_text_value.LAST + 1) := l_mgr_name  ;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || '************ REPOSSESSION ***************');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Num Name count >> ' || to_char(p_wf_item_number_name.count) || 'Num Value count >> ' || to_char(p_wf_item_number_value.count));
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LOGMESSAGE('start_workflow: ' || 'Text Name count >> ' || to_char(p_wf_item_text_name.count) || 'Text Value count >> ' || to_char(p_wf_item_text_value.count));
            END IF;

	        SEND_NOTIFICATION(
                    v_itemtype			,
					v_itemkey			,
					p_wf_item_NUMBER_NAME 	,
					p_wf_item_NUMBER_VALUE	,
					p_wf_item_TEXT_NAME	,
					p_wf_item_TEXT_VALUE	,
					l_return_status		,
					l_result			) ;

            Clear_Table_Values ;
        END IF ;
	    CLOSE v_del_notification_cur ;
      END LOOP ;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );

    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
    ----------------------------------
    END start_workflow;

    /* ________________________________________________________________________

                            PROCEDURE SELECT_NOTICE
    __________________________________________________________________________*/

    ----------- procedure update_approval_status  -----------------------------
    PROCEDURE select_notice(itemtype  	IN   varchar2,
                        itemkey     IN   varchar2,
                        actid       IN   number,
                        funcmode    IN   varchar2,
                        result      OUT NOCOPY  varchar2) is

        l_responder           VARCHAR2(100);
        l_text_value          VARCHAR2(2000);
        l_status              VARCHAR2(1);
        l_resource_id         NUMBER;
        l_delinquency_id      NUMBER;
        l_api_name     				VARCHAR2(100) := 'select_notice';
        l_errmsg_name					VARCHAR2(30);
        L_API_ERROR						EXCEPTION;
    BEGIN

        if funcmode <> 'RUN' then
            result := wf_engine.eng_null;
            return;
        end if;

        l_resource_id := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'RESOURCE_ID');


        l_delinquency_id := wf_engine.GetItemAttrText(
                                       itemtype  => itemtype,
                                       itemkey   => itemkey,
                                       aname     => 'DELINQUENCY_ID');

        IF l_status = 'Y' THEN
            result := 'COMPLETE:'||'Y';
        ELSE
            result := 'COMPLETE:'||'N';
        END IF;

    EXCEPTION
  	     WHEN L_API_ERROR then
      		WF_CORE.Raise(l_errmsg_name);
         WHEN OTHERS THEN
              WF_CORE.Context('IEX_WF_DEL_CUR_STATUS_NOTE_PUB', 'Select Notice',
		      itemtype, itemkey, actid, funcmode);
            RAISE;
    END select_notice;

    PROCEDURE select_resource_info(
          p_delinquency_id      IN NUMBER) IS
    BEGIN
         null;
    EXCEPTION
        WHEN OTHERS THEN
            WF_CORE.Context('IEX_WF_DEL_CUR_STATUS_NOTE_PUB', 'Select Notice' );
            RAISE;
    END select_resource_info;

    /* ________________________________________________________________________

                            PROCEDURE SEND_NOTIFICATION
    __________________________________________________________________________*/

    PROCEDURE SEND_NOTIFICATION( 	p_itemtype			varchar2			,
					p_itemkey			varchar2			,
					p_wf_item_NUMBER_NAME 	wf_engine.NameTabTyp	,
					p_wf_item_NUMBER_VALUE	wf_engine.NumTabTyp	,
					p_wf_item_TEXT_NAME	wf_engine.NameTabTyp	,
					p_wf_item_TEXT_VALUE	wf_engine.TextTabTyp	,
					l_return_status		OUT NOCOPY 	varchar2		,
					l_result			OUT NOCOPY 	varchar2 		)
    IS
    BEGIN

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LOGMESSAGE('Item Type >> ' || p_itemtype || ' Item Key >> ' || p_itemkey || ' Process >> ' || workflowprocess) ;
        END IF;

        wf_engine.createprocess  (
			itemtype => p_itemtype,
              	itemkey  => p_itemkey,
              	process  => workflowprocess);


	    WF_ENGINE.SetItemAttrNumberArray(
			itemtype =>   p_itemtype,
                	itemkey  =>   p_itemkey,
                	aname    =>   p_wf_item_number_name,
                	avalue   =>   p_wf_item_number_value);

	    WF_ENGINE.SetItemAttrTextArray(
			    itemtype =>   p_itemtype,
               	itemkey  =>   p_itemkey,
                aname    =>   p_wf_item_text_name,
                avalue   =>   p_wf_item_text_value);

        wf_engine.startprocess( itemtype =>   p_itemtype,
                               itemkey  =>   p_itemkey);
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LOGMESSAGE('Send Notification  Before Item Status');
        END IF;

        wf_engine.ItemStatus(  itemtype =>   p_ItemType,
                              itemkey  =>   p_ItemKey,
                              status   =>   l_return_status,
                              result   =>   l_result);
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LOGMESSAGE('Send Notification  Status >> ' || l_return_status);
        IEX_DEBUG_PUB.LOGMESSAGE('Result  Status >> ' || l_result);
        END IF;

    EXCEPTION
	    WHEN OTHERS then
	        -- Raise the Error and Return Error Status Back.
	        -- Null for now
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LOGMESSAGE(SQLCODE || ' >> ' || SQLERRM) ;
            END IF;
    END ;

    /* ________________________________________________________________________

                            PROCEDURE CLEAR_TABLE_VALUES
    __________________________________________________________________________*/
    -- Helper Procedure to Clear the Workflow PL/SQL Tables.
    PROCEDURE clear_table_values
    IS
    BEGIN
        p_wf_item_NUMBER_VALUE.DELETE(2, p_wf_item_NUMBER_NAME.LAST) ;
        p_wf_item_TEXT_VALUE.DELETE(p_wf_item_NUMBER_NAME.FIRST, p_wf_item_NUMBER_NAME.LAST) ;

        l_owner_id      := NULL ;
        l_type_id       := NULL ;
        l_owner_name    := NULL ;
        l_mgr_id        := NULL ;
        l_mgr_name      := NULL ;
    END ;


    /* ________________________________________________________________________

                            PROCEDURE MAIN

    PROCEDURE MAIN
    IS
        ld_del_tbl	IEX_UTILITIES.t_del_id ;
        ld_api_version	Number 		:= 1.0 ;
        ld_init_mesg_list	Varchar2(1) := 'T' ;
        ld_commit		Varchar2(1)	:= 'F' ;
        ld_validation_level	Number	:= 100 ;

        ld_return_status     VARCHAR2(10) := 'S';
        ld_msg_count         NUMBER  := 0	;
        ld_msg_data          VARCHAR2(4000) default NULL;

    Begin
        -- Populate with new Values
        SELECT DISTINCT DELINQUENCY_ID
        BULK COLLECT INTO ld_del_tbl
        From IEX_DEL_CHILDREN ;
        start_workflow
        (   ld_api_version,
            ld_init_mesg_list,
            ld_commit         	,
            ld_del_tbl   ,
            ld_return_status     ,
            ld_msg_count      	,
            ld_msg_data      	) ;

    EXCEPTION
        WHEN OTHERS THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LOGMESSAGE(SQLCODE || ' >> ' || SQLERRM) ;
            END IF;
    END MAIN ;
    __________________________________________________________________________*/

END IEX_WF_DEL_CUR_STATUS_NOTE_PUB;

/
