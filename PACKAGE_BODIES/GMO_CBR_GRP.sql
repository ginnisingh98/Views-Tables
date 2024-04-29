--------------------------------------------------------
--  DDL for Package Body GMO_CBR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_CBR_GRP" AS
/* $Header: GMOGCBRB.pls 120.21 2006/09/22 12:29:56 rvsingh noship $ */

    PROCEDURE ENABLE_CBR (ERRBUF OUT NOCOPY VARCHAR2,RETCODE OUT NOCOPY VARCHAR2) IS
    -- Local Variables
    l_event_name VARCHAR2(80);
    l_err BOOLEAN;
    datetime_format CONSTANT VARCHAR2(32) := 'DD-MM-YYYY HH24:MI:SS';
     --
     -- ERES events where GMO CBR subscription exists
     --

    CURSOR CBR_EVENTS IS
        SELECT a.GUID
              ,a.NAME
              ,a.TYPE
              ,a.STATUS
              ,a.GENERATE_FUNCTION
              ,a.JAVA_GENERATE_FUNC
              ,a.OWNER_NAME
              ,a.OWNER_TAG
              ,a.CUSTOMIZATION_LEVEL
              ,a.DISPLAY_NAME
              ,a.DESCRIPTION
         FROM
           wf_events_vl  a,
           wf_event_subscriptions b
         WHERE a.GUID = b.EVENT_FILTER_GUID
           and b.RULE_FUNCTION in ('GMO_CBR_GRP.PROCESS_EVENT','GMO_CBR_GRP.PROCESS_INSTANCE_INSTR_SET');

     --
     -- ERES event subscriptions owned by product teams where GMO subscription exists
     --

     CURSOR CBR_EVENT_SUBCRIPTIONS IS
        SELECT b.GUID
              ,b.SYSTEM_GUID
              ,b.SOURCE_TYPE
              ,b.SOURCE_AGENT_GUID
              ,b.EVENT_FILTER_GUID
              ,b.PHASE
              ,b.STATUS
              ,b.RULE_DATA
              ,b.OUT_AGENT_GUID
              ,b.TO_AGENT_GUID
              ,b.PRIORITY
              ,b.RULE_FUNCTION
              ,b.WF_PROCESS_TYPE
              ,b.WF_PROCESS_NAME
              ,b.PARAMETERS
              ,b.OWNER_NAME
              ,b.OWNER_TAG
              ,b.DESCRIPTION
              ,b.EXPRESSION
              ,b.SECURITY_GROUP_ID
              ,b.CUSTOMIZATION_LEVEL
              ,b.LICENSED_FLAG
              ,b.INVOCATION_ID
              ,b.MAP_CODE
              ,b.STANDARD_TYPE
              ,b.STANDARD_CODE
              ,b.JAVA_RULE_FUNC
              ,b.ON_ERROR_CODE
              ,b.ACTION_CODE
         FROM
            wf_events_vl  a,
            wf_event_subscriptions b
         WHERE a.GUID = b.EVENT_FILTER_GUID
           AND b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
           AND a.name = l_event_name
           and b.owner_tag <> 'GMO'
           and b.status = 'ENABLED';

     --
     -- ERES event subscriptions owned by GMO and they are in disabled state
     --

     CURSOR CBR_GMO_SUBCRIPTIONS IS
        SELECT b.GUID
              ,b.SYSTEM_GUID
              ,b.SOURCE_TYPE
              ,b.SOURCE_AGENT_GUID
              ,b.EVENT_FILTER_GUID
              ,b.PHASE
              ,b.STATUS
              ,b.RULE_DATA
              ,b.OUT_AGENT_GUID
              ,b.TO_AGENT_GUID
              ,b.PRIORITY
              ,b.RULE_FUNCTION
              ,b.WF_PROCESS_TYPE
              ,b.WF_PROCESS_NAME
              ,b.PARAMETERS
              ,b.OWNER_NAME
              ,b.OWNER_TAG
              ,b.DESCRIPTION
              ,b.EXPRESSION
              ,b.SECURITY_GROUP_ID
              ,b.CUSTOMIZATION_LEVEL
              ,b.LICENSED_FLAG
              ,b.INVOCATION_ID
              ,b.MAP_CODE
              ,b.STANDARD_TYPE
              ,b.STANDARD_CODE
              ,b.JAVA_RULE_FUNC
              ,b.ON_ERROR_CODE
              ,b.ACTION_CODE
         FROM
            wf_events_vl  a,
            wf_event_subscriptions b
         WHERE a.GUID = b.EVENT_FILTER_GUID
           AND a.name = l_event_name
           AND b.owner_tag = 'GMO'
           AND b.status = 'DISABLED'   ;

     -- Cursor ROW TYPE Varaibles
        l_EVENT_REC CBR_EVENTS%ROWTYPE;
        l_CBR_GMO_SUBCRIPTIONS_REC CBR_GMO_SUBCRIPTIONS%ROWTYPE;
        l_CBR_EVENT_SUBCRIPTIONS_REC CBR_EVENT_SUBCRIPTIONS%ROWTYPE;
     BEGIN

     if (fnd_profile.defined('GMO_ENABLED_FLAG')) THEN
        if GMO_SETUP_GRP.IS_GMO_ENABLED = GMO_CONSTANTS_GRP.YES THEN
           fnd_file.put_line(fnd_file.output, fnd_message.get_string('GMO', 'GMO_IS_ENABLED_START_PROCESS') );
           fnd_file.new_line(fnd_file.output, 1);

           OPEN CBR_EVENTS;
           LOOP
             FETCH CBR_EVENTS INTO l_EVENT_REC;
             EXIT WHEN CBR_EVENTS%NOTFOUND;
             l_event_name := l_EVENT_REC.name;
             IF l_EVENT_REC.STATUS = 'DISABLED' THEN
                  fnd_message.set_name('GMO', 'GMO_CBR_EVENT_PROCESSING');
                  fnd_message.set_token('EVENT', l_EVENT_REC.DISPLAY_NAME);
                  fnd_file.put_line(fnd_file.output, fnd_message.get);
                  fnd_file.new_line(fnd_file.output, 2);

                  --
                  -- Enable ERES Event for Control Batch Recording
                  --
                  WF_EVENTS_PKG.UPDATE_ROW(X_GUID                => l_EVENT_REC.GUID
	  	  	  	      ,X_NAME                => l_EVENT_REC.NAME
	  	  	  	      ,X_TYPE                => l_EVENT_REC.TYPE
	  	  	  	      ,X_STATUS              => 'ENABLED'
	  	  	  	      ,X_GENERATE_FUNCTION   => l_EVENT_REC.GENERATE_FUNCTION
	  	  	  	      ,X_OWNER_NAME          => l_EVENT_REC.OWNER_NAME
	  	  	  	      ,X_OWNER_TAG           => l_EVENT_REC.OWNER_TAG
	  	  	  	      ,X_DISPLAY_NAME        => l_EVENT_REC.DISPLAY_NAME
	  	  	  	      ,X_DESCRIPTION         => l_EVENT_REC.DESCRIPTION
	  	  	  	      ,X_CUSTOMIZATION_LEVEL => l_EVENT_REC.CUSTOMIZATION_LEVEL
	  	  	  	      ,X_LICENSED_FLAG       => l_EVENT_REC.CUSTOMIZATION_LEVEL
	  	  	  	      ,X_JAVA_GENERATE_FUNC  => l_EVENT_REC.JAVA_GENERATE_FUNC);
             END IF;
             OPEN CBR_EVENT_SUBCRIPTIONS;
             LOOP
               FETCH CBR_EVENT_SUBCRIPTIONS INTO l_CBR_EVENT_SUBCRIPTIONS_REC;
               EXIT WHEN CBR_EVENT_SUBCRIPTIONS%NOTFOUND;
                  --
                  -- disable ERES Event subscriptions owned by product teams
                  --
                  fnd_message.set_name('GMO', 'GMO_CBR_EVT_PROD_SUB_PROCESS');
                  fnd_message.set_token('EVENT', l_EVENT_REC.DISPLAY_NAME);
                  fnd_file.put_line(fnd_file.output, fnd_message.get);
                  fnd_file.new_line(fnd_file.output, 2);

               WF_EVENT_SUBSCRIPTIONS_PKG.UPDATE_ROW(X_GUID                => l_CBR_EVENT_SUBCRIPTIONS_REC.GUID
                                                ,X_SYSTEM_GUID         => l_CBR_EVENT_SUBCRIPTIONS_REC.SYSTEM_GUID
                                                ,X_SOURCE_TYPE         => l_CBR_EVENT_SUBCRIPTIONS_REC.SOURCE_TYPE
                                                ,X_SOURCE_AGENT_GUID   => l_CBR_EVENT_SUBCRIPTIONS_REC.SOURCE_AGENT_GUID
                                                ,X_EVENT_FILTER_GUID   => l_CBR_EVENT_SUBCRIPTIONS_REC.EVENT_FILTER_GUID
                                                ,X_PHASE               => l_CBR_EVENT_SUBCRIPTIONS_REC.PHASE
                                                ,X_STATUS              => 'DISABLED'
                                                ,X_RULE_DATA           => l_CBR_EVENT_SUBCRIPTIONS_REC.RULE_DATA
                                                ,X_OUT_AGENT_GUID      => l_CBR_EVENT_SUBCRIPTIONS_REC.OUT_AGENT_GUID
                                                ,X_TO_AGENT_GUID       => l_CBR_EVENT_SUBCRIPTIONS_REC.TO_AGENT_GUID
                                                ,X_PRIORITY            => l_CBR_EVENT_SUBCRIPTIONS_REC.PRIORITY
                                                ,X_RULE_FUNCTION       => l_CBR_EVENT_SUBCRIPTIONS_REC.RULE_FUNCTION
                                                ,X_WF_PROCESS_TYPE     => l_CBR_EVENT_SUBCRIPTIONS_REC.WF_PROCESS_TYPE
                                                ,X_WF_PROCESS_NAME     => l_CBR_EVENT_SUBCRIPTIONS_REC.WF_PROCESS_NAME
                                                ,X_PARAMETERS          => l_CBR_EVENT_SUBCRIPTIONS_REC.PARAMETERS
                                                ,X_OWNER_NAME          => l_CBR_EVENT_SUBCRIPTIONS_REC.OWNER_NAME
                                                ,X_OWNER_TAG           => l_CBR_EVENT_SUBCRIPTIONS_REC.OWNER_TAG
                                                ,X_CUSTOMIZATION_LEVEL => l_CBR_EVENT_SUBCRIPTIONS_REC.CUSTOMIZATION_LEVEL
                                                ,X_LICENSED_FLAG       => l_CBR_EVENT_SUBCRIPTIONS_REC.LICENSED_FLAG
                                                ,X_DESCRIPTION         => l_CBR_EVENT_SUBCRIPTIONS_REC.DESCRIPTION
                                                ,X_EXPRESSION          => l_CBR_EVENT_SUBCRIPTIONS_REC.EXPRESSION
                                                ,X_ACTION_CODE         => l_CBR_EVENT_SUBCRIPTIONS_REC.ACTION_CODE
                                                ,X_ON_ERROR_CODE       => l_CBR_EVENT_SUBCRIPTIONS_REC.ON_ERROR_CODE
                                                ,X_JAVA_RULE_FUNC      => l_CBR_EVENT_SUBCRIPTIONS_REC.JAVA_RULE_FUNC
                                                ,X_MAP_CODE            => l_CBR_EVENT_SUBCRIPTIONS_REC.MAP_CODE
                                                ,X_STANDARD_CODE       => l_CBR_EVENT_SUBCRIPTIONS_REC.STANDARD_CODE
                                                ,X_STANDARD_TYPE       => l_CBR_EVENT_SUBCRIPTIONS_REC.STANDARD_TYPE);
             END LOOP;
             CLOSE CBR_EVENT_SUBCRIPTIONS;
             OPEN CBR_GMO_SUBCRIPTIONS;
             LOOP
               FETCH CBR_GMO_SUBCRIPTIONS INTO l_CBR_GMO_SUBCRIPTIONS_REC;
               EXIT WHEN CBR_GMO_SUBCRIPTIONS%NOTFOUND;
                  fnd_message.set_name('GMO', 'GMO_CBR_EVT_GMO_SUB_PROCESS');
                  fnd_message.set_token('EVENT', l_EVENT_REC.DISPLAY_NAME);
                  fnd_file.put_line(fnd_file.output, fnd_message.get);
                  fnd_file.new_line(fnd_file.output, 2);

                --
                -- enable ERES Event subscriptions owned by GMO
                --
               WF_EVENT_SUBSCRIPTIONS_PKG.UPDATE_ROW(X_GUID                => l_CBR_GMO_SUBCRIPTIONS_REC.GUID
                                                ,X_SYSTEM_GUID         => l_CBR_GMO_SUBCRIPTIONS_REC.SYSTEM_GUID
                                                ,X_SOURCE_TYPE         => l_CBR_GMO_SUBCRIPTIONS_REC.SOURCE_TYPE
                                                ,X_SOURCE_AGENT_GUID   => l_CBR_GMO_SUBCRIPTIONS_REC.SOURCE_AGENT_GUID
                                                ,X_EVENT_FILTER_GUID   => l_CBR_GMO_SUBCRIPTIONS_REC.EVENT_FILTER_GUID
                                                ,X_PHASE               => l_CBR_GMO_SUBCRIPTIONS_REC.PHASE
                                                ,X_STATUS              => 'ENABLED'
                                                ,X_RULE_DATA           => l_CBR_GMO_SUBCRIPTIONS_REC.RULE_DATA
                                                ,X_OUT_AGENT_GUID      => l_CBR_GMO_SUBCRIPTIONS_REC.OUT_AGENT_GUID
                                                ,X_TO_AGENT_GUID       => l_CBR_GMO_SUBCRIPTIONS_REC.TO_AGENT_GUID
                                                ,X_PRIORITY            => l_CBR_GMO_SUBCRIPTIONS_REC.PRIORITY
                                                ,X_RULE_FUNCTION       => l_CBR_GMO_SUBCRIPTIONS_REC.RULE_FUNCTION
                                                ,X_WF_PROCESS_TYPE     => l_CBR_GMO_SUBCRIPTIONS_REC.WF_PROCESS_TYPE
                                                ,X_WF_PROCESS_NAME     => l_CBR_GMO_SUBCRIPTIONS_REC.WF_PROCESS_NAME
                                                ,X_PARAMETERS          => l_CBR_GMO_SUBCRIPTIONS_REC.PARAMETERS
                                                ,X_OWNER_NAME          => l_CBR_GMO_SUBCRIPTIONS_REC.OWNER_NAME
                                                ,X_OWNER_TAG           => l_CBR_GMO_SUBCRIPTIONS_REC.OWNER_TAG
                                                ,X_CUSTOMIZATION_LEVEL => l_CBR_GMO_SUBCRIPTIONS_REC.CUSTOMIZATION_LEVEL
                                                ,X_LICENSED_FLAG       => l_CBR_GMO_SUBCRIPTIONS_REC.LICENSED_FLAG
                                                ,X_DESCRIPTION         => l_CBR_GMO_SUBCRIPTIONS_REC.DESCRIPTION
                                                ,X_EXPRESSION          => l_CBR_GMO_SUBCRIPTIONS_REC.EXPRESSION
                                                ,X_ACTION_CODE         => l_CBR_GMO_SUBCRIPTIONS_REC.ACTION_CODE
                                                ,X_ON_ERROR_CODE       => l_CBR_GMO_SUBCRIPTIONS_REC.ON_ERROR_CODE
                                                ,X_JAVA_RULE_FUNC      => l_CBR_GMO_SUBCRIPTIONS_REC.JAVA_RULE_FUNC
                                                ,X_MAP_CODE            => l_CBR_GMO_SUBCRIPTIONS_REC.MAP_CODE
                                                ,X_STANDARD_CODE       => l_CBR_GMO_SUBCRIPTIONS_REC.STANDARD_CODE
                                                ,X_STANDARD_TYPE       => l_CBR_GMO_SUBCRIPTIONS_REC.STANDARD_TYPE);
             END LOOP;
             CLOSE CBR_GMO_SUBCRIPTIONS;
           END LOOP;
           CLOSE CBR_EVENTS;
           IF TO_DATE(fnd_profile.value('GMO_CBR_ENABLED_DATE'), datetime_format) is null
           THEN
             l_err := fnd_profile.save('GMO_CBR_ENABLED_DATE',TO_CHAR(sysdate, datetime_format), 'SITE');
             fnd_message.set_name('GMO', 'GMO_EBR_ENABLED_DATE');
             fnd_message.set_token('ENABLE_DATE',TO_DATE(fnd_profile.value('GMO_CBR_ENABLED_DATE'), datetime_format)  );
             fnd_file.put_line(fnd_file.output, fnd_message.get);
             fnd_file.new_line(fnd_file.output, 2);
           END IF;
           COMMIT;
         else
           fnd_file.put_line(fnd_file.output, fnd_message.get_string('GMO', 'GMO_IS_NOT_ENABLED') );
           fnd_file.new_line(fnd_file.output, 1);
         end if;
      else
           fnd_file.put_line(fnd_file.output, fnd_message.get_string('GMO', 'GMO_PROFILE_NOTFOUND') );
           fnd_file.new_line(fnd_file.output, 1);
           APP_EXCEPTION.Raise_exception;
      end if;
     EXCEPTION WHEN OTHERS THEN
       ERRBUF  := SQLERRM;
       RETCODE := 2;
     END;


    PROCEDURE UPDATE_EVENT (P_ERECORD_ID NUMBER, P_BATCH_PROGRESSION_ID NUMBER, P_EVENT_DATE DATE, P_STATUS VARCHAR2) IS
    BEGIN
     --
     -- Update event details based on parameters
     --
       IF P_ERECORD_ID IS NOT NULL
       THEN
         UPDATE gmo_batch_progression
         SET STATUS = P_STATUS,
             EVENT_DATE = p_EVENT_DATE
         WHERE ERECORD_ID = p_ERECORD_ID;
       END IF;
       IF P_BATCH_PROGRESSION_ID IS NOT NULL
       THEN
         UPDATE gmo_batch_progression
         SET STATUS     = P_STATUS,
             EVENT_DATE = p_EVENT_DATE
         WHERE PROGRESSION_ID = P_BATCH_PROGRESSION_ID;
       END IF;
    END UPDATE_EVENT ;

    PROCEDURE INSERT_EVENT(P_BATCH_PROG_REC GMO_BATCH_PROGRESSION%ROWTYPE,P_BATCH_PROGRESSION_ID OUT NOCOPY NUMBER) IS
       CURSOR get_progression_ID is
        SELECT  GMO_BATCH_PROGRESSION_S.nextval
        FROM DUAL;
    BEGIN
      OPEN get_progression_ID;
      FETCH get_progression_ID INTO P_BATCH_PROGRESSION_ID;
      CLOSE get_progression_ID;

      --
      -- insert into Batch Progression Table
      --
      INSERT INTO GMO_BATCH_PROGRESSION (
                   PROGRESSION_ID
                  ,BATCH_ID
                  ,BATCHSTEP_ID
                  ,MATERIAL_LINE_ID
                  ,BATCHACTIVITY_ID
                  ,BATCHRSRC_ID
                  ,DISPENSE_ID
                  ,SAMPLE_ID
                  ,DEVIATION_ID
                  ,TRANSACTION_ID
                  ,PARENT_NODE
                  ,PARENT_KEY_NODE
                  ,PARENT_KEY_VAL
                  ,CURR_NODE_KEY
                  ,CURR_KEY_VAL
                  ,USER_KEY_LABEL_PROD
                  ,USER_KEY_LABEL_TOKEN
                  ,USER_KEY_LABEL
                  ,USER_KEY_VALUE
                  ,EXTERNAL_EVENT
                  ,INCLUDE_IN_CBR
                  ,EVENT
                  ,EVENT_KEY
                  ,EVENT_DATE
                  ,PLANED_START_DATE
                  ,ERECORD_ID
                  ,XML_EREC
                  ,STATUS
                  ,INCLUDED_IN_CBR
                  ,XML_MAP_CODE
                  ,compare_xml)
           VALUES
                 (P_BATCH_PROGRESSION_ID
                  ,P_BATCH_PROG_REC.BATCH_ID
                  ,P_BATCH_PROG_REC.BATCHSTEP_ID
                  ,P_BATCH_PROG_REC.MATERIAL_LINE_ID
                  ,P_BATCH_PROG_REC.BATCHACTIVITY_ID
                  ,P_BATCH_PROG_REC.BATCHRSRC_ID
                  ,P_BATCH_PROG_REC.DISPENSE_ID
                  ,P_BATCH_PROG_REC.SAMPLE_ID
                  ,P_BATCH_PROG_REC.DEVIATION_ID
                  ,P_BATCH_PROG_REC.TRANSACTION_ID
                  ,P_BATCH_PROG_REC.PARENT_NODE
                  ,P_BATCH_PROG_REC.PARENT_KEY_NODE
                  ,P_BATCH_PROG_REC.PARENT_KEY_VAL
                  ,P_BATCH_PROG_REC.CURR_NODE_KEY
                  ,P_BATCH_PROG_REC.CURR_KEY_VAL
                  ,P_BATCH_PROG_REC.USER_KEY_LABEL_PROD
                  ,P_BATCH_PROG_REC.USER_KEY_LABEL_TOKEN
                  ,P_BATCH_PROG_REC.USER_KEY_LABEL
                  ,P_BATCH_PROG_REC.USER_KEY_VALUE
                  ,P_BATCH_PROG_REC.EXTERNAL_EVENT
                  ,P_BATCH_PROG_REC.INCLUDE_IN_CBR
                  ,P_BATCH_PROG_REC.EVENT
                  ,P_BATCH_PROG_REC.EVENT_KEY
                  ,P_BATCH_PROG_REC.EVENT_DATE
                  ,P_BATCH_PROG_REC.PLANED_START_DATE
                  ,P_BATCH_PROG_REC.ERECORD_ID
                  ,P_BATCH_PROG_REC.XML_EREC
                  ,P_BATCH_PROG_REC.STATUS
                  ,P_BATCH_PROG_REC.INCLUDED_IN_CBR
                  ,P_BATCH_PROG_REC.XML_MAP_CODE
                  ,P_BATCH_PROG_REC.compare_xml );


    END;

    PROCEDURE CBR_PREPROCESS (P_BATCH_ID IN NUMBER) IS
      -- local variables
      l_document             EDR_PSIG.DOCUMENT;
      l_docparams            EDR_PSIG.PARAMS_TABLE;
      l_signatures           EDR_PSIG.SIGNATURETABLE;
      l_error                NUMBER;
      l_error_msg            VARCHAR2(4000);
      l_event_name           varchar2(80) := NULL;
      l_event_key            varchar2(80) := NULL;
      l_batch_id             number := null;
      l_batchstep_id         number := null;
      l_material_detail_id   number := null;
      l_dispense_id          NUMBER := NULL;
      l_parent_node          VARCHAR2(80) := NULL;
      l_parent_key_node      VARCHAR2(80) := NULL;
      l_parent_key_val       VARCHAR2(80) := NULL;
      l_curr_node_key        VARCHAR2(80) := NULL;
      l_curr_key_val         VARCHAR2(80) := NULL;
      l_entity_name          VARCHAR2(40) := NULL;
      l_progression_id       NUMBER;
      l_PSIG_EREC            CLOB;
      l_PROG_EREC 	     CLOB;
      l_QA_XML               VARCHAR2(4000);
   -- cursor declarations
      -- This cursor is used to modify Progression row status for a given batch
      -- from inprogress to complete status based on e-record status

      CURSOR GMO_BATCH_PROGRESSION_CUR IS
       SELECT PROGRESSION_ID,ERECORD_ID,BATCH_ID ,BATCHSTEP_ID,
              MATERIAL_LINE_ID,BATCHACTIVITY_ID,BATCHRSRC_ID
       FROM GMO_BATCH_PROGRESSION
       WHERE BATCH_ID = P_BATCH_ID
         AND STATUS   = 'INPROGRESS'
         AND ERECORD_ID IS NOT NULL;

      --  This cursor is used to populate missing information for batch progression table
      --  this can occur for SSWA based events.

      CURSOR GMO_BATCH_PROGRESSION_CUR2 IS
       SELECT PROGRESSION_ID,EVENT,EVENT_KEY,dispense_id
       FROM GMO_BATCH_PROGRESSION
       WHERE BATCH_ID IS NULL
         AND STATUS   = 'INPROGRESS'
         AND ERECORD_ID IS NOT NULL
         AND event in ('oracle.apps.gmo.mtl.dispense',
                       'oracle.apps.gmo.mtl.revdisp',
                       'oracle.apps.gmo.labelprint');

     CURSOR get_dispense_Details IS
       SELECT batch_id, batch_step_id ,material_detail_id
       FROM gmo_material_dispenses
       WHERE dispense_id = l_dispense_id;
     CURSOR get_rev_dispense_Details IS
       SELECT batch_id, batch_step_id ,material_detail_id,dispense_id
       FROM gmo_material_undispenses
       WHERE undispense_id = l_event_key;
     CURSOR GET_LABEL_DETAILS IS
       SELECT entity_name, entity_key
       from gmo_label_history
       where label_id = l_event_key;
    BEGIN
      -- Following code is to populate missing data values in batch progression for SSWA events

      OPEN GMO_BATCH_PROGRESSION_CUR2;
      LOOP
        FETCH GMO_BATCH_PROGRESSION_CUR2 INTO l_progression_id,l_event_name,l_event_key,l_dispense_id;
        EXIT WHEN GMO_BATCH_PROGRESSION_CUR2%NOTFOUND;
          IF l_event_name in ('oracle.apps.gmo.mtl.dispense','oracle.apps.gmo.labelprint') THEN
            IF l_event_name in ('oracle.apps.gmo.mtl.dispense') THEN
              l_dispense_id := l_event_key ;
            END IF;
            OPEN get_dispense_Details;
            FETCH get_dispense_Details into l_batch_id, l_batchstep_id ,l_material_detail_id;
            CLOSE get_dispense_Details;
            UPDATE GMO_BATCH_PROGRESSION
            SET batch_id         = l_batch_id,
                batchstep_id     = l_batchstep_id,
                material_line_id = l_material_detail_id
            WHERE PROGRESSION_ID = l_progression_id;
          ELSIF  l_event_name in ('oracle.apps.gmo.mtl.revdisp') THEN
            OPEN get_rev_dispense_Details;
            FETCH get_rev_dispense_Details into l_batch_id, l_batchstep_id ,l_material_detail_id,l_dispense_id;
            CLOSE get_rev_dispense_Details;
            UPDATE GMO_BATCH_PROGRESSION
            SET batch_id         = l_batch_id,
                batchstep_id     = l_batchstep_id,
                material_line_id = l_material_detail_id,
                dispense_id      = l_dispense_id
            WHERE PROGRESSION_ID = l_progression_id;
        END IF;
      END LOOP;

      --
      -- Based on batch ID process inprogress batch progression table rows
      -- to mark as completed. This is required as when event is raised
      -- rows will be in 'INPROGRESS' state and we do not have any hook from where
      -- we can mark row as completed once ERES is success.
      --
      FOR GMO_BATCH_PROGRESSION_REC IN GMO_BATCH_PROGRESSION_CUR
      LOOP
        edr_psig.getdocumentdetails(GMO_BATCH_PROGRESSION_REC.ERECORD_ID,l_document,l_docparams,l_signatures,l_error,l_error_msg);
        IF l_document.PSIG_STATUS = 'ERROR' THEN
          DELETE FROM GMO_BATCH_PROGRESSION WHERE PROGRESSION_ID = GMO_BATCH_PROGRESSION_REC.PROGRESSION_ID;
        ELSIF l_document.PSIG_STATUS in ('COMPLETE','REJECTED','TIMEDOUT') then
          UPDATE GMO_BATCH_PROGRESSION
          SET STATUS = 'COMPLETE'
          WHERE PROGRESSION_ID = GMO_BATCH_PROGRESSION_REC.PROGRESSION_ID;
          IF l_document.EVENT_NAME in ('oracle.apps.qa.disp.create'
                          ,'oracle.apps.qa.disp.detail.approve'
                          ,'oracle.apps.qa.disp.header.approve'
                          ,'oracle.apps.qa.disp.update'
                          ,'oracle.apps.qa.ncm.create'
                          ,'oracle.apps.qa.ncm.detail.approve'
                          ,'oracle.apps.qa.ncm.master.approve'
                          ,'oracle.apps.qa.ncm.update')
          THEN
            DBMS_LOB.CREATETEMPORARY(l_PROG_EREC,TRUE,DBMS_LOB.SESSION);
            l_QA_XML :='<QA_NCM_EREC>
                            <ERECORD_ID>'||GMO_BATCH_PROGRESSION_REC.ERECORD_ID ||'
                            </ERECORD_ID>
                            <ERECORD>';
            DBMS_LOB.append(l_PROG_EREC,l_QA_XML);
            DBMS_LOB.append(l_PROG_EREC,l_document.PSIG_DOCUMENT);
            DBMS_LOB.append(l_PROG_EREC,'
                           </ERECORD>
                        </QA_NCM_EREC>');

           -- add code for constructing XML for E-Record Object.
--            IF l_document.EVENT_NAME  = 'oracle.apps.qa.ncm.create' THEN
              IF GMO_BATCH_PROGRESSION_REC.BATCHRSRC_ID  is not null
              THEN
                l_parent_node      := 'RESOURCE_REQUIREMENTS';
                l_parent_key_node  := 'STEP_RESOURCE_ID';
                l_parent_key_val   := GMO_BATCH_PROGRESSION_REC.BATCHRSRC_ID;
                l_curr_node_key    := 'ERECORD_ID';
                l_curr_key_val     := GMO_BATCH_PROGRESSION_REC.ERECORD_ID;
              ELSIF GMO_BATCH_PROGRESSION_REC.BATCHACTIVITY_ID  is not null
              THEN
                l_parent_node      := 'ACTIVITIES';
                l_parent_key_node  := 'STEP_ACTIVITY_ID';
                l_parent_key_val   := GMO_BATCH_PROGRESSION_REC.BATCHACTIVITY_ID;
                l_curr_node_key    := 'ERECORD_ID';
                l_curr_key_val     := GMO_BATCH_PROGRESSION_REC.ERECORD_ID;
              ELSIF GMO_BATCH_PROGRESSION_REC.MATERIAL_LINE_ID  is not null
              THEN
                l_parent_node      := 'MATERIAL_REQUIREMENTS';
                l_parent_key_node  := 'MATERIAL_DETAIL_ID';
                l_parent_key_val   := GMO_BATCH_PROGRESSION_REC.MATERIAL_LINE_ID;
                l_curr_node_key    := 'ERECORD_ID';
                l_curr_key_val     := GMO_BATCH_PROGRESSION_REC.ERECORD_ID;

              ELSIF GMO_BATCH_PROGRESSION_REC.BATCHSTEP_ID  is not null
              THEN
                l_parent_node      := 'ROUTING_STEPS';
                l_parent_key_node  := 'STEP_ID';
                l_parent_key_val   := GMO_BATCH_PROGRESSION_REC.BATCHSTEP_ID;
                l_curr_node_key    := 'ERECORD_ID';
                l_curr_key_val     := GMO_BATCH_PROGRESSION_REC.ERECORD_ID;

              ELSIF GMO_BATCH_PROGRESSION_REC.BATCH_ID   is not null
              THEN
                l_parent_node      := 'HEADER_INFORMATION';
                l_parent_key_node  := 'BATCH_ID';
                l_parent_key_val   := GMO_BATCH_PROGRESSION_REC.BATCH_ID;
                l_curr_node_key    := 'ERECORD_ID';
                l_curr_key_val     := GMO_BATCH_PROGRESSION_REC.ERECORD_ID;
              END IF;
--            END IF;
              UPDATE GMO_BATCH_PROGRESSION
              SET XML_EREC         = l_PROG_EREC,
                  PARENT_NODE      = l_parent_node,
                  PARENT_KEY_NODE  = l_parent_key_node,
                  PARENT_KEY_VAL   = l_parent_key_val,
                  CURR_NODE_KEY    = l_curr_node_key,
                  CURR_KEY_VAL     = l_curr_key_val
              WHERE PROGRESSION_ID = GMO_BATCH_PROGRESSION_REC.PROGRESSION_ID;
                l_parent_node      := null;
                l_parent_key_node  := null;
                l_parent_key_val   := null;
                l_curr_node_key    := null;
                l_curr_key_val     := null;

          END IF;

        END IF;
      END LOOP;
      COMMIT;
    END CBR_PREPROCESS;

      /* Bug : 5040377
       *  update the progression status based on Batch status
       */

  PROCEDURE UPDATE_PROGRESSION_STATUS(P_BATCH_ID IN NUMBER ,P_BATCHSTEP_ID IN NUMBER,P_EVENT_NAME IN VARCHAR2) IS
  BEGIN
 	IF P_EVENT_NAME='oracle.apps.gme.batch.complete' THEN
      	UPDATE GMO_BATCH_PROGRESSION
            	  SET STATUS='BYPASSED'
	              WHERE BATCH_ID = P_BATCH_ID
                  AND STATUS='PENDING'
           	      AND EVENT IN ('oracle.apps.gme.batch.release'
                               ,'oracle.apps.gme.batchstep.release'
                               ,'oracle.apps.gme.batchstep.complete');
	ELSIF P_EVENT_NAME='oracle.apps.gme.batch.cancel' THEN
           -- Bug 5499897 : rvsingh : start
      	UPDATE GMO_BATCH_PROGRESSION
              	SET STATUS='CANCEL'
	              WHERE BATCH_ID = P_BATCH_ID
      	          AND STATUS IN ('PENDING','INPROGRESS');
           -- Bug 5499897 : rvsingh : End
	ELSIF P_EVENT_NAME='oracle.apps.gme.batch.reroute' THEN
      	UPDATE GMO_BATCH_PROGRESSION
            	  SET STATUS='CANCEL'
	              WHERE BATCH_ID = P_BATCH_ID
      	          AND STATUS='PENDING'
            	  AND EVENT IN ('oracle.apps.gme.batchstep.complete'
                  		       ,'oracle.apps.gme.batchstep.release'
		                         ,'oracle.apps.gme.batchstep.close');
           -- Bug 5499897 : rvsingh : start
      	UPDATE GMO_BATCH_PROGRESSION
            	  SET STATUS='CANCEL'
	              WHERE BATCH_ID = P_BATCH_ID
      	          AND STATUS='INPROGRESS'
            	  AND EVENT = 'oracle.apps.gmo.instrset.update';
           -- Bug 5499897 : rvsingh : End
	ELSIF P_EVENT_NAME='oracle.apps.gme.batch.terminate' THEN
           -- Bug 5499897 : rvsingh : start
      	UPDATE GMO_BATCH_PROGRESSION
            	  SET STATUS='TERMINATE'
	              WHERE BATCH_ID = P_BATCH_ID
	              AND STATUS IN ('PENDING','INPROGRESS');
           -- Bug 5499897 : rvsingh : End
	ELSIF P_EVENT_NAME='oracle.apps.gme.batch.close' THEN
	      UPDATE GMO_BATCH_PROGRESSION
      	        SET STATUS='BYPASSED'
             	  WHERE BATCH_ID = P_BATCH_ID
	              AND STATUS='PENDING'
      	           AND EVENT ='oracle.apps.gme.batchstep.close';
           -- Bug 5499897 : rvsingh : start
      	UPDATE GMO_BATCH_PROGRESSION
            	  SET STATUS='OPTIONAL_ACK'
	              WHERE BATCH_ID = P_BATCH_ID
      	           AND STATUS='INPROGRESS'
            	   AND EVENT = 'oracle.apps.gmo.instrset.update';
           -- Bug 5499897 : rvsingh : End
	ELSIF P_EVENT_NAME='oracle.apps.gme.batchstep.complete' THEN
      	UPDATE GMO_BATCH_PROGRESSION
              SET STATUS='BYPASSED'
              WHERE BATCH_ID = P_BATCH_ID
                 AND BATCHSTEP_ID = P_BATCHSTEP_ID
                 AND STATUS='PENDING'
                 AND EVENT ='oracle.apps.gme.batchstep.release';
	ELSIF P_EVENT_NAME='oracle.apps.gme.batchstep.close' THEN
           -- Bug 5499897 : rvsingh : start
      	UPDATE GMO_BATCH_PROGRESSION
            	  SET STATUS='OPTIONAL_ACK'
	              WHERE BATCH_ID = P_BATCH_ID
                  AND BATCHSTEP_ID = P_BATCHSTEP_ID
      	          AND STATUS='INPROGRESS'
            	  AND EVENT = 'oracle.apps.gmo.instrset.update';
           -- Bug 5499897 : rvsingh : End
	END IF;
  END UPDATE_PROGRESSION_STATUS;




    FUNCTION PROCESS_EVENT (P_SUBSCRIPTION_GUID IN RAW, P_EVENT IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2 IS
        l_batch_prog_rec       GMO_BATCH_PROGRESSION%ROWTYPE;
        l_batch_progression_id NUMBER := NULL;
        l_event_name           varchar2(80) := NULL;
        l_event_key            varchar2(80) := NULL;
        l_user_key_label       varchar2(80) := NULL;
        l_user_key_value       varchar2(80) := NULL;
        l_erecord_id           number := NULL;
        l_batch_id             number := null;
        l_operation_id         number := null;
        l_batchstep_id         number := null;
        l_material_detail_id   number := null;
        l_batch_activity_id    number := null;
        l_batch_rsrc_id        number := null;
        l_parameter_id         number := NULL;
        l_plan_start_date      date := null;
        l_return_status        varchar2(80) := NULL;
        l_map_code             varchar2(80) := NULL;
        l_event_cnt            number := -1;
        l_message_prod         VARCHAR2(10) := NULL;
        l_message_token        VARCHAR2(50) := NULL;
        l_collection_id        number := NULL;
        l_plan_id              number := NULL;
        l_occurrence           number := NULL;
        l_dispense_id          NUMBER := NULL;
        l_sample_id            NUMBER := NULL;
        l_deviation_id         NUMBER := NULL;
        l_transaction_id       NUMBER := NULL;
        l_parent_node          VARCHAR2(80) := NULL;
        l_parent_key_node      VARCHAR2(80) := NULL;
        l_parent_key_val       VARCHAR2(80) := NULL;
        l_curr_node_key        VARCHAR2(80) := NULL;
        l_curr_key_val         VARCHAR2(80) := NULL;
        l_xml_erec             CLOB         := NULL;
        l_entity_name          VARCHAR2(40) := NULL;
        l_line_id              NUMBER := NULL;
        l_smpl_source          VARCHAR2(1) :=NULL;
        l_include_in_CBR       VARCHAR2(10) := 'XML';
        l_external_event       VARCHAR2(1) :='N';
        l_compare_XML          VARCHAR2(1) :='Y';
        cursor cur_qa_results IS
        SELECT PROCESS_BATCH_ID
              ,PROCESS_BATCHSTEP_ID
              ,PROCESS_OPERATION_ID
              ,PROCESS_ACTIVITY_ID
              ,PROCESS_RESOURCE_ID
              ,PROCESS_PARAMETER_ID
        FROM QA_RESULTS
        WHERE
              plan_id       = l_plan_id
          AND collection_id = l_collection_id
          AND occurrence    = l_occurrence ;
        CURSOR get_collection_id IS
          SELECT substrb(l_event_key,instrb(l_event_key,'-',1,1)+1,
                                     decode(instrb(l_event_key,'-',1,2),0,
                                            length(substrb(l_event_key,instrb(l_event_key,'-',1,1)+1)),
                                            instrb(l_event_key,'-',1,2)-(instrb(l_event_key,'-',1,1)+1)))
          FROM DUAL;
        CURSOR GET_SAMPLE_DETAILS IS
         SELECT SMPL.BATCH_ID,SMPL.STEP_ID,SMPL.FORMULALINE_ID
               ,SMPL.MATERIAL_DETAIL_ID
         FROM GMD_SAMPLES SMPL
         WHERE SMPL.SAMPLE_ID = l_sample_id;

    BEGIN
        l_return_status:=wf_rule.setParametersIntoParameterList(p_subscription_guid,p_event);
        --
        -- Get parameters from ef_event structure for processing
        --
        l_event_name      := p_event.getEventName();
        l_event_key       := p_event.getEventKey();
        l_user_key_label  := wf_event.getValueForParameter('PSIG_USER_KEY_LABEL',p_event.Parameter_List);
        l_user_key_value  := wf_event.getValueForParameter('PSIG_USER_KEY_VALUE',p_event.Parameter_List);
        l_erecord_id      := wf_event.getValueForParameter('#ERECORD_ID',p_event.Parameter_List);
        l_map_code        := wf_event.getValueForParameter('CBR_XML_MAP_CODE',p_event.Parameter_List);
        l_compare_XML     := nvl(wf_event.getValueForParameter('COMPARE_XML',p_event.Parameter_List),'Y');

       --
       -- process Oracle Quality Events
       --
       IF l_event_name in ('oracle.apps.qa.disp.create'
                          ,'oracle.apps.qa.disp.detail.approve'
                          ,'oracle.apps.qa.disp.header.approve'
                          ,'oracle.apps.qa.disp.update'
                          ,'oracle.apps.qa.ncm.create'
                          ,'oracle.apps.qa.ncm.detail.approve'
                          ,'oracle.apps.qa.ncm.master.approve'
                          ,'oracle.apps.qa.ncm.update')
       THEN
         l_plan_id       := substrb(l_event_key,1,instrb(l_event_key,'-',1,1)-1);
         --
         -- get collection id from event key. We need to use SQL as decode is not allowed
         -- other than SQL
         --
         OPEN get_collection_id;
         FETCH get_collection_id INTO l_collection_id;
         CLOSE get_collection_id;
         l_occurrence    := substrb(l_event_key,instrb(l_event_key,'-',1,2)+1);
         --
         -- check current NCM is related to production batch
         -- if current is not belogns to production batch then
         -- we do not require to process
         --
         OPEN cur_qa_results;
         FETCH cur_qa_results INTO l_batch_id,l_batchstep_id,l_operation_id,l_batch_activity_id,l_batch_rsrc_id,l_parameter_id;
         CLOSE cur_qa_results;
         IF l_batch_id is null THEN
            RETURN 'SUCCESS';
         END IF;
         l_message_prod := 'GMO';
         l_message_token:= 'GMO_QA_ERES_KEY_LABEL';
         l_include_in_CBR := 'XTEXT';

       ELSIf l_event_name in ('oracle.apps.gme.batch.erecords'
                          ,'oracle.apps.gme.batch.complete'
                          ,'oracle.apps.gme.batch.uncertify'
                          ,'oracle.apps.gme.batch.unrelease'
                          ,'oracle.apps.gme.batch.close'
                          ,'oracle.apps.gme.batch.reopen'
                          ,'oracle.apps.gme.batch.release'
                          ,'oracle.apps.gme.batch.terminate'
                          ,'oracle.apps.gme.batch.transact'
                          ,'oracle.apps.gme.batch.scale'
                          ,'oracle.apps.gme.batch.rsrc.trx'
                          ,'oracle.apps.gme.batch.cancel'
                          ,'oracle.apps.gme.batch.reroute'
                          ,'oracle.apps.gme.batch.rescheduled'
                          ,'oracle.apps.gme.batch.update')
       THEN
       --
       -- process batch level Events
       --
           l_batch_id := l_event_key;
           l_message_prod := 'GME';
           l_message_token:= 'GME_PSIG_BATCH_LABEL';
           SELECT PLAN_START_DATE into l_plan_start_date
           FROM GME_BATCH_HEADER
           WHERE batch_id = l_batch_id;
           --
           -- If event is batch creation event then store
           -- e-record XML into CBR XML
           --
           IF l_event_name = 'oracle.apps.gme.batch.erecords' THEN
              insert into GMO_CBR_XML (batch_id, CBR_XML)
                       VALUES (l_batch_id,p_event.geteventdata());
              INSERT_BATH_EVENTS(l_batch_id);
           END IF;
       ELSIF l_event_name in ('oracle.apps.gme.batchstep.complete'
                             ,'oracle.apps.gme.batchstep.release'
                             ,'oracle.apps.gme.batchstep.uncertify'
                             ,'oracle.apps.gme.batchstep.unrelease'
                             ,'oracle.apps.gme.batchstep.close'
                             ,'oracle.apps.gme.batchstep.reopen') THEN
         --
         -- process batch step events
         --
           l_batchstep_id := l_event_key;
           l_message_prod := 'GME';
           l_message_token:= 'GME_PSIG_BATCH_STEP_LABEL';
           SELECT batch_id,PLAN_START_DATE into l_batch_id,l_plan_start_date
           FROM GME_BATCH_STEPS
           WHERE batchstep_id = l_batchstep_id;
       ELSIF l_event_name in ('oracle.apps.gme.batchstep.added'
                             ,'oracle.apps.gme.batchstep.removed'
                             ,'oracle.apps.gme.batchstep.update') THEN
           --
           -- process batch step events
           --
           l_batch_id     := substrb(l_event_key,1,instrb(l_event_key,'-',1)-1);
           l_batchstep_id := substrb(l_event_key,instrb(l_event_key,'-',1)+1);
           l_message_prod := 'GME';
           l_message_token:= 'GME_PSIG_BATCH_STEP_LABEL';
           IF l_event_name in ('oracle.apps.gme.batchstep.added') THEN
             SELECT PLAN_START_DATE into l_plan_start_date
             FROM GME_BATCH_STEPS
             WHERE batch_id = l_batch_id
               AND batchstep_id = l_batchstep_id;
           END IF;
       ELSIF l_event_name in ('oracle.apps.gme.batchmtl.added'
                             ,'oracle.apps.gme.batchmtl.removed'
                             ,'oracle.apps.gme.batchmtl.updated') THEN
           --
           -- process batch material events
           --
           l_batch_id           := substrb(l_event_key,1,instrb(l_event_key,'-',1)-1);
           l_material_detail_id := substrb(l_event_key,instrb(l_event_key,'-',1)+1);
           l_message_prod := 'GME';
           l_message_token:= 'GME_PSIG_BATCH_MATL_LABEL';

       ELSIF l_event_name in ('oracle.apps.gme.resource.added'
                             ,'oracle.apps.gme.resource.removed'
                             ,'oracle.apps.gme.resource.update') THEN
           --
           -- process batch step resource events
           --
           l_batch_id          := substrb(l_event_key,1,instrb(l_event_key,'-',1)-1);
           l_batchstep_id      := substrb(l_event_key,instrb(l_event_key,'-',1)+1,instrb(l_event_key,'-',1,2)-(instrb(l_event_key,'-',1,1)+1));
           l_batch_activity_id := substrb(l_event_key,instrb(l_event_key,'-',1,2)+1,instrb(l_event_key,'-',1,3)-(instrb(l_event_key,'-',1,2)+1));
           l_batch_rsrc_id     := substrb(l_event_key,instrb(l_event_key,'-',1,3)+1);
           l_message_prod := 'GME';
           l_message_token:= 'GME_PSIG_BATCH_STEP_RSRC_LABEL';
           IF l_event_name = 'oracle.apps.gme.resource.added'
           THEN
             SELECT PLAN_START_DATE into l_plan_start_date
             FROM GME_BATCH_STEP_RESOURCES
             WHERE batch_id = l_batch_id
               AND BATCHSTEP_RESOURCE_ID = l_batch_rsrc_id;
           END IF;
       ELSIF l_event_name in ('oracle.apps.gme.activity.added'
                             ,'oracle.apps.gme.activity.removed'
                             ,'oracle.apps.gme.activity.update') THEN
           --
           -- process batch step activity events
           --
           l_batch_id     := substrb(l_event_key,1,instrb(l_event_key,'-',1)-1);
           l_batchstep_id := substrb(l_event_key,instrb(l_event_key,'-',1)+1,instrb(l_event_key,'-',1,2)-(instrb(l_event_key,'-',1,1)+1));
           l_batch_activity_id := substrb(l_event_key,instrb(l_event_key,'-',1,2)+1);
           l_message_prod := 'GME';
           l_message_token:= 'GME_PSIG_BATCH_STEP_ACT_LABEL';
           IF l_event_name = 'oracle.apps.gme.activity.added' THEN
             SELECT PLAN_START_DATE into l_plan_start_date
             FROM GME_BATCH_STEP_ACTIVITIES
             WHERE batch_id = l_batch_id
               AND BATCHSTEP_ACTIVITY_ID = l_batch_activity_id;
           END IF;
       ELSIF l_event_name in ('oracle.apps.gme.batch.pparam') THEN
            l_batch_id      := substrb(l_event_key,1,instrb(l_event_key,'-',1)-1);
            l_batch_rsrc_id := substrb(l_event_key,instrb(l_event_key,'-',1)+1,instrb(l_event_key,'-',1,2)-(instrb(l_event_key,'-',1,1)+1));
           l_message_prod := 'GME';
           l_message_token:= 'GME_PSIG_BATCH_RSRC_PARM_LABEL';
       ELSIF l_event_name in ('oracle.apps.gmo.labelprint') THEN
         SELECT entity_name, entity_key  INTO l_entity_name,l_dispense_id
         from gmo_label_history
         where label_id = l_event_key;
         IF l_entity_name = 'GMO_DISPENSING'
         THEN
           l_message_prod     := 'GMO';
           l_message_token    := 'GMO_PRNTLBL_KEY_LABEL';
           l_parent_node      := 'MATERIAL_DISPENSE';
           l_parent_key_node  := 'DISPENSE_ID';
           l_parent_key_val   := l_dispense_id;
           l_curr_node_key    := 'LABEL_ID';
           l_curr_key_val     := l_event_key;
         ELSE
           return 'SUCCESS';
         END IF;
       ELSIF  l_event_name in ('oracle.apps.gmo.mtl.dispense') THEN
           l_dispense_id := l_event_key;
           l_message_prod  := 'GMO';
           l_message_token := 'GMO_DISP_MTL_DISP_KEY_LABEL';
       ELSIF  l_event_name in ('oracle.apps.gmo.mtl.revdisp') THEN
           l_transaction_id  := l_event_key;
           l_message_prod    := 'GMO';
           l_message_token   := 'GMO_DISP_RVDISP_KEY_LABEL';
       ELSIF l_event_name in ('oracle.apps.gmd.qm.smpl.crea',
                              'oracle.apps.gmd.qm.rslt.entry' ) THEN
         if l_event_name = 'oracle.apps.gmd.qm.smpl.crea'
         then
           l_sample_id :=  l_event_key;
         else
           l_sample_id :=  substrb(l_event_key,1,instrb(l_event_key,'-',1,1) -1);
         end if;
         OPEN GET_SAMPLE_DETAILS;
         FETCH GET_SAMPLE_DETAILS INTO l_batch_id, l_batchstep_id ,l_line_id,l_material_detail_id;
         CLOSE  GET_SAMPLE_DETAILS;
         if l_batch_id is null
         then
           return 'SUCCESS';
         ELSE
           if l_event_name = 'oracle.apps.gmd.qm.smpl.crea'
           then
              l_message_prod  := 'GMD';
              l_message_token := 'GMD_ERES_SAMPLE_LBL';
              if l_material_detail_id is not null
              then
                l_parent_node      := 'MATERIAL_REQUIREMENTS';
                l_parent_key_node  := 'MATERIAL_DETAIL_ID';
                l_parent_key_val   := l_material_detail_id;
                l_curr_node_key    := 'SAMPLE_ID';
                l_curr_key_val     := l_sample_id;
              elsif l_batchstep_id  is not null
              then
                l_parent_node      := 'ROUTING_STEPS';
                l_parent_key_node  := 'STEP_ID';
                l_parent_key_val   := l_batchstep_id;
                l_curr_node_key    := 'SAMPLE_ID';
                l_curr_key_val     := l_sample_id;
              elsif l_batch_id  is not null
              then
                l_parent_node      := 'HEADER_INFORMATION';
                l_parent_key_node  := 'BATCH_ID';
                l_parent_key_val   := l_batch_id;
                l_curr_node_key    := 'SAMPLE_ID';
                l_curr_key_val     := l_sample_id;
              end if;
           else
              l_message_prod  := 'GMD';
              l_message_token := 'GMD_ERES_RESULT_LBL';
           end if;
         END IF;
       END IF;
      --
      -- Manage events created in batch progression at the time of batch creation
      --
       If l_event_name in ('oracle.apps.gme.batch.complete'
                          ,'oracle.apps.gme.batch.close'
                          ,'oracle.apps.gme.batch.release'
                          ,'oracle.apps.gme.batchstep.complete'
                          ,'oracle.apps.gme.batchstep.release'
                          ,'oracle.apps.gme.batchstep.close')
      THEN
        /* delete progression row created when batch is created */
        delete GMO_BATCH_PROGRESSION
        where event = l_event_name
          AND event_key = l_event_key
          AND STATUS = 'PENDING';
      END IF;

        /* update the progression status for other event */
        UPDATE_PROGRESSION_STATUS(l_batch_id,l_batchstep_id,l_event_name);

       /* populate Record object with the details */

       l_batch_prog_rec.PROGRESSION_ID := NULL;
       l_batch_prog_rec.BATCH_ID := l_batch_id;
       l_batch_prog_rec.BATCHSTEP_ID := l_batchstep_id ;
       l_batch_prog_rec.MATERIAL_LINE_ID := l_material_detail_id;
       l_batch_prog_rec.BATCHACTIVITY_ID := l_batch_activity_id;
       l_batch_prog_rec.BATCHRSRC_ID :=l_batch_rsrc_id ;
       l_batch_prog_rec.DISPENSE_ID := l_dispense_id;
       l_batch_prog_rec.SAMPLE_ID := l_sample_id;
       l_batch_prog_rec.DEVIATION_ID := l_deviation_id;
       l_batch_prog_rec.TRANSACTION_ID := l_transaction_id;
       l_batch_prog_rec.PARENT_NODE := l_parent_node;
       l_batch_prog_rec.PARENT_KEY_NODE := l_parent_key_node;
       l_batch_prog_rec.PARENT_KEY_VAL := l_parent_key_val;
       l_batch_prog_rec.CURR_NODE_KEY := l_curr_node_key;
       l_batch_prog_rec.CURR_KEY_VAL := l_curr_key_val;
       l_batch_prog_rec.USER_KEY_LABEL_PROD := l_message_prod;
       l_batch_prog_rec.USER_KEY_LABEL_TOKEN := l_message_token;
       l_batch_prog_rec.USER_KEY_LABEL := l_user_key_label;
       l_batch_prog_rec.USER_KEY_VALUE := l_user_key_value;
       l_batch_prog_rec.EXTERNAL_EVENT := l_external_event;
       l_batch_prog_rec.INCLUDE_IN_CBR := l_include_in_CBR;
       l_batch_prog_rec.EVENT := l_event_name;
       l_batch_prog_rec.EVENT_KEY := l_event_key;
       l_batch_prog_rec.EVENT_DATE := SYSDATE;
       l_batch_prog_rec.PLANED_START_DATE := l_plan_start_date;
       l_batch_prog_rec.ERECORD_ID := l_erecord_id;
       l_batch_prog_rec.XML_EREC := l_xml_erec;
       IF l_event_name = 'oracle.apps.gme.batch.erecords' THEN
         l_batch_prog_rec.STATUS := 'COMPLETE';
         l_batch_prog_rec.INCLUDED_IN_CBR := 'Y';
       ELSE
         l_batch_prog_rec.STATUS := 'INPROGRESS';
         l_batch_prog_rec.INCLUDED_IN_CBR := 'N';
       END IF;
       l_batch_prog_rec.XML_MAP_CODE :=  l_map_code;
       l_batch_prog_rec.compare_xml:=l_compare_XML;
       gmo_cbr_grp.insert_event(l_batch_prog_rec,l_batch_progression_id);
       wf_event.AddParameterToList('BATCH_PROGRESSION_ID', l_batch_progression_id,p_event.Parameter_List);
       return 'SUCCESS';
    END;


    PROCEDURE INSERT_BATH_EVENTS(P_BATCH_ID IN NUMBER) IS
        l_batch_prog_rec GMO_BATCH_PROGRESSION%ROWTYPE;
        l_batch_progression_id NUMBER;
        l_step_label VARCHAR2(400);
        l_step_user_val VARCHAR2(400);
     CURSOR Get_BATCH_DETAILS IS
     SELECT BATCH_ID,BATCH_NO,PLANT_CODE,PLAN_START_DATE,PLAN_CMPLT_DATE
     FROM GME_BATCH_HEADER_VW
     WHERE batch_id = P_BATCH_ID;
     CURSOR GET_STEP_DETAILS IS
       SELECT BATCH_ID,BATCHSTEP_ID,BATCHSTEP_NO,OPERATION_NO,PLAN_START_DATE,PLAN_CMPLT_DATE
       FROM gme_batch_steps_v
       WHERE BATCH_ID = P_BATCH_ID;
     BATCH_DETAILS_REC Get_BATCH_DETAILS%ROWTYPE;
     STEP_DETAILS_REC  GET_STEP_DETAILS%ROWTYPE;
    BEGIN
       --
       -- Create Batch progression rows when batch is created.
       -- oracle.apps.gme.batch.complete
       -- oracle.apps.gme.batch.close
       -- oracle.apps.gme.batch.release
       -- create step level rows for each step.
       -- oracle.apps.gme.batchstep.complete
       -- oracle.apps.gme.batchstep.release
       -- oracle.apps.gme.batchstep.close
       --
       OPEN Get_BATCH_DETAILS;
       FETCH Get_BATCH_DETAILS INTO BATCH_DETAILS_REC;
       CLOSE Get_BATCH_DETAILS;
       l_batch_prog_rec.PROGRESSION_ID := NULL;
       l_batch_prog_rec.BATCH_ID := P_BATCH_ID;
       l_batch_prog_rec.BATCHSTEP_ID := NULL;
       l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
       l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
       l_batch_prog_rec.BATCHRSRC_ID := NULL;
       l_batch_prog_rec.DISPENSE_ID := NULL;
       l_batch_prog_rec.SAMPLE_ID := NULL;
       l_batch_prog_rec.DEVIATION_ID := NULL;
       l_batch_prog_rec.TRANSACTION_ID := NULL;
       l_batch_prog_rec.PARENT_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_VAL := NULL;
       l_batch_prog_rec.CURR_NODE_KEY := NULL;
       l_batch_prog_rec.CURR_KEY_VAL := NULL;
       l_batch_prog_rec.USER_KEY_LABEL_PROD := 'GME';
       l_batch_prog_rec.USER_KEY_LABEL_TOKEN := 'GME_PSIG_BATCH_LABEL';
       l_batch_prog_rec.USER_KEY_LABEL := FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_LABEL');
       l_batch_prog_rec.USER_KEY_VALUE := BATCH_DETAILS_REC.PLANT_CODE || '-'||BATCH_DETAILS_REC.BATCH_NO;
       l_batch_prog_rec.EXTERNAL_EVENT := NULL;
       l_batch_prog_rec.INCLUDE_IN_CBR := NULL;
       l_batch_prog_rec.EVENT := 'oracle.apps.gme.batch.release';
       l_batch_prog_rec.EVENT_KEY := P_BATCH_ID;
       l_batch_prog_rec.EVENT_DATE := NULL;
       l_batch_prog_rec.PLANED_START_DATE := BATCH_DETAILS_REC.PLAN_START_DATE;
       l_batch_prog_rec.ERECORD_ID := NULL;
       l_batch_prog_rec.XML_EREC := NULL;
       l_batch_prog_rec.STATUS := 'PENDING';
       l_batch_prog_rec.INCLUDED_IN_CBR := 'N';
       gmo_cbr_grp.insert_event(l_batch_prog_rec,l_batch_progression_id);
       OPEN GET_STEP_DETAILS ;
       LOOP
         FETCH GET_STEP_DETAILS INTO STEP_DETAILS_REC;
         EXIT WHEN    GET_STEP_DETAILS%NOTFOUND;
        l_step_label := FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_STEP_LABEL');
        l_step_user_val := BATCH_DETAILS_REC.PLANT_CODE || '-'||BATCH_DETAILS_REC.BATCH_NO||
                                          '-' ||STEP_DETAILS_REC.BATCHSTEP_NO||'-'||STEP_DETAILS_REC.OPERATION_NO;
       l_batch_prog_rec.PROGRESSION_ID := NULL;
       l_batch_prog_rec.BATCH_ID := P_BATCH_ID;
       l_batch_prog_rec.BATCHSTEP_ID := STEP_DETAILS_REC.BATCHSTEP_ID;
       l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
       l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
       l_batch_prog_rec.BATCHRSRC_ID := NULL;
       l_batch_prog_rec.DISPENSE_ID := NULL;
       l_batch_prog_rec.SAMPLE_ID := NULL;
       l_batch_prog_rec.DEVIATION_ID := NULL;
       l_batch_prog_rec.TRANSACTION_ID := NULL;
       l_batch_prog_rec.PARENT_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_VAL := NULL;
       l_batch_prog_rec.CURR_NODE_KEY := NULL;
       l_batch_prog_rec.CURR_KEY_VAL := NULL;
       l_batch_prog_rec.USER_KEY_LABEL_PROD := 'GME';
       l_batch_prog_rec.USER_KEY_LABEL_TOKEN := 'GME_PSIG_BATCH_STEP_LABEL';
       l_batch_prog_rec.USER_KEY_LABEL := l_step_label;
       l_batch_prog_rec.USER_KEY_VALUE := l_step_user_val;
       l_batch_prog_rec.EXTERNAL_EVENT := NULL;
       l_batch_prog_rec.INCLUDE_IN_CBR := NULL;
       l_batch_prog_rec.EVENT := 'oracle.apps.gme.batchstep.release';
       l_batch_prog_rec.EVENT_DATE := NULL;
       l_batch_prog_rec.EVENT_KEY := STEP_DETAILS_REC.BATCHSTEP_ID ;
       l_batch_prog_rec.PLANED_START_DATE := STEP_DETAILS_REC.PLAN_START_DATE;
       l_batch_prog_rec.ERECORD_ID := NULL;
       l_batch_prog_rec.XML_EREC := NULL;
       l_batch_prog_rec.STATUS := 'PENDING';
       l_batch_prog_rec.INCLUDED_IN_CBR := 'N';
       gmo_cbr_grp.insert_event(l_batch_prog_rec,l_batch_progression_id);
       l_batch_prog_rec.PROGRESSION_ID := NULL;
       l_batch_prog_rec.BATCH_ID := P_BATCH_ID;
       l_batch_prog_rec.BATCHSTEP_ID := STEP_DETAILS_REC.BATCHSTEP_ID;
       l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
       l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
       l_batch_prog_rec.BATCHRSRC_ID := NULL;
       l_batch_prog_rec.DISPENSE_ID := NULL;
       l_batch_prog_rec.SAMPLE_ID := NULL;
       l_batch_prog_rec.DEVIATION_ID := NULL;
       l_batch_prog_rec.TRANSACTION_ID := NULL;
       l_batch_prog_rec.PARENT_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_VAL := NULL;
       l_batch_prog_rec.CURR_NODE_KEY := NULL;
       l_batch_prog_rec.CURR_KEY_VAL := NULL;
       l_batch_prog_rec.USER_KEY_LABEL_PROD := 'GME';
       l_batch_prog_rec.USER_KEY_LABEL_TOKEN := 'GME_PSIG_BATCH_STEP_LABEL';
       l_batch_prog_rec.USER_KEY_LABEL := l_step_label;
       l_batch_prog_rec.USER_KEY_VALUE :=l_step_user_val;
       l_batch_prog_rec.EXTERNAL_EVENT := NULL;
       l_batch_prog_rec.INCLUDE_IN_CBR := NULL;
       l_batch_prog_rec.EVENT := 'oracle.apps.gme.batchstep.complete';
       l_batch_prog_rec.EVENT_KEY := STEP_DETAILS_REC.BATCHSTEP_ID ;
       l_batch_prog_rec.EVENT_DATE := NULL;
       l_batch_prog_rec.PLANED_START_DATE := STEP_DETAILS_REC.PLAN_CMPLT_DATE;
       l_batch_prog_rec.ERECORD_ID := NULL;
       l_batch_prog_rec.XML_EREC := NULL;
       l_batch_prog_rec.STATUS := 'PENDING';
       l_batch_prog_rec.INCLUDED_IN_CBR := 'N';
       gmo_cbr_grp.insert_event(l_batch_prog_rec,l_batch_progression_id);
       l_batch_prog_rec.PROGRESSION_ID := NULL;
       l_batch_prog_rec.BATCH_ID := P_BATCH_ID;
       l_batch_prog_rec.BATCHSTEP_ID := STEP_DETAILS_REC.BATCHSTEP_ID;
       l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
       l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
       l_batch_prog_rec.BATCHRSRC_ID := NULL;
       l_batch_prog_rec.DISPENSE_ID := NULL;
       l_batch_prog_rec.SAMPLE_ID := NULL;
       l_batch_prog_rec.DEVIATION_ID := NULL;
       l_batch_prog_rec.TRANSACTION_ID := NULL;
       l_batch_prog_rec.PARENT_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_VAL := NULL;
       l_batch_prog_rec.CURR_NODE_KEY := NULL;
       l_batch_prog_rec.CURR_KEY_VAL := NULL;
       l_batch_prog_rec.USER_KEY_LABEL_PROD := 'GME';
       l_batch_prog_rec.USER_KEY_LABEL_TOKEN := 'GME_PSIG_BATCH_STEP_LABEL';
       l_batch_prog_rec.USER_KEY_LABEL := l_step_label;
       l_batch_prog_rec.USER_KEY_VALUE :=l_step_user_val;
       l_batch_prog_rec.EXTERNAL_EVENT := NULL;
       l_batch_prog_rec.INCLUDE_IN_CBR := NULL;
       l_batch_prog_rec.EVENT := 'oracle.apps.gme.batchstep.close';
       l_batch_prog_rec.EVENT_KEY := STEP_DETAILS_REC.BATCHSTEP_ID ;
       l_batch_prog_rec.EVENT_DATE := NULL;
       l_batch_prog_rec.PLANED_START_DATE := null;
       l_batch_prog_rec.ERECORD_ID := NULL;
       l_batch_prog_rec.XML_EREC := NULL;
       l_batch_prog_rec.STATUS := 'PENDING';
       l_batch_prog_rec.INCLUDED_IN_CBR := 'N';
       gmo_cbr_grp.insert_event(l_batch_prog_rec,l_batch_progression_id);
       END LOOP;
       CLOSE GET_STEP_DETAILS;
       l_batch_prog_rec.PROGRESSION_ID := NULL;
       l_batch_prog_rec.BATCH_ID := P_BATCH_ID;
       l_batch_prog_rec.BATCHSTEP_ID := NULL;
       l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
       l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
       l_batch_prog_rec.BATCHRSRC_ID := NULL;
       l_batch_prog_rec.DISPENSE_ID := NULL;
       l_batch_prog_rec.SAMPLE_ID := NULL;
       l_batch_prog_rec.DEVIATION_ID := NULL;
       l_batch_prog_rec.TRANSACTION_ID := NULL;
       l_batch_prog_rec.PARENT_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_VAL := NULL;
       l_batch_prog_rec.CURR_NODE_KEY := NULL;
       l_batch_prog_rec.CURR_KEY_VAL := NULL;
       l_batch_prog_rec.USER_KEY_LABEL_PROD := 'GME';
       l_batch_prog_rec.USER_KEY_LABEL_TOKEN := 'GME_PSIG_BATCH_LABEL';
       l_batch_prog_rec.USER_KEY_LABEL := FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_LABEL');
       l_batch_prog_rec.USER_KEY_VALUE := BATCH_DETAILS_REC.PLANT_CODE || '-'||BATCH_DETAILS_REC.BATCH_NO;
       l_batch_prog_rec.EXTERNAL_EVENT := NULL;
       l_batch_prog_rec.INCLUDE_IN_CBR := NULL;
       l_batch_prog_rec.EVENT := 'oracle.apps.gme.batch.complete';
       l_batch_prog_rec.EVENT_KEY := P_BATCH_ID;
       l_batch_prog_rec.EVENT_DATE := NULL;
       l_batch_prog_rec.PLANED_START_DATE := BATCH_DETAILS_REC.PLAN_CMPLT_DATE;
       l_batch_prog_rec.ERECORD_ID := NULL;
       l_batch_prog_rec.XML_EREC := NULL;
       l_batch_prog_rec.STATUS := 'PENDING';
       l_batch_prog_rec.INCLUDED_IN_CBR := 'N';
       gmo_cbr_grp.insert_event(l_batch_prog_rec,l_batch_progression_id);
       l_batch_prog_rec.PROGRESSION_ID := NULL;
       l_batch_prog_rec.BATCH_ID := P_BATCH_ID;
       l_batch_prog_rec.BATCHSTEP_ID := NULL;
       l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
       l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
       l_batch_prog_rec.BATCHRSRC_ID := NULL;
       l_batch_prog_rec.DISPENSE_ID := NULL;
       l_batch_prog_rec.SAMPLE_ID := NULL;
       l_batch_prog_rec.DEVIATION_ID := NULL;
       l_batch_prog_rec.TRANSACTION_ID := NULL;
       l_batch_prog_rec.PARENT_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_NODE := NULL;
       l_batch_prog_rec.PARENT_KEY_VAL := NULL;
       l_batch_prog_rec.CURR_NODE_KEY := NULL;
       l_batch_prog_rec.CURR_KEY_VAL := NULL;
       l_batch_prog_rec.USER_KEY_LABEL_PROD := 'GME';
       l_batch_prog_rec.USER_KEY_LABEL_TOKEN := 'GME_PSIG_BATCH_LABEL';
       l_batch_prog_rec.USER_KEY_LABEL := FND_MESSAGE.GET_STRING('GME','GME_PSIG_BATCH_LABEL');
       l_batch_prog_rec.USER_KEY_VALUE := BATCH_DETAILS_REC.PLANT_CODE || '-'||BATCH_DETAILS_REC.BATCH_NO;
       l_batch_prog_rec.EXTERNAL_EVENT := NULL;
       l_batch_prog_rec.INCLUDE_IN_CBR := NULL;
       l_batch_prog_rec.EVENT := 'oracle.apps.gme.batch.close';
       l_batch_prog_rec.EVENT_KEY := P_BATCH_ID;
       l_batch_prog_rec.EVENT_DATE := NULL;
       l_batch_prog_rec.PLANED_START_DATE := null;
       l_batch_prog_rec.ERECORD_ID := NULL;
       l_batch_prog_rec.XML_EREC := NULL;
       l_batch_prog_rec.STATUS := 'PENDING';
       l_batch_prog_rec.INCLUDED_IN_CBR := 'N';
       l_batch_prog_rec.compare_xml:='N';
       gmo_cbr_grp.insert_event(l_batch_prog_rec,l_batch_progression_id);
EXCEPTION
WHEN OTHERS THEN
null;
END;

function getValue(P_XML XMLType,P_VARIABLE VARCHAR2) return VARCHAR2
IS
tmp varchar2(400);
BEGIN
 select extractValue(P_XML,P_VARIABLE) into tmp from dual;
 return tmp;
END getValue;


PROCEDURE GET_INSTR_XML (P_EVENT_KEY IN VARCHAR2,P_MAP_CODE IN VARCHAR2,X_FINAL_XML OUT NOCOPY XMLType) IS

l_xml CLOB;
l_final_xml CLOB;
l_result XMLType;
l_erecID NUMBER(22);
--This holds the query context.
qryCtx DBMS_XMLGEN.ctxHandle;
l_srcDoc  dbms_xmldom.DOMDocument;
l_srcDocEle  dbms_xmldom.DOMELEMENT;
l_parentRootNode DBMS_XMLDOM.DOMNODE;
l_sigHDRDoc DBMS_XMLDOM.DOMDOCUMENT;
l_childRootNode DBMS_XMLDOM.DOMNODE;
l_sigHDRDocEle  dbms_xmldom.DOMELEMENT;
l_childNodeList dbms_xmldom.DOMNodeList;
l_childNode dbms_xmldom.DOMNode;
l_nodeListDel dbms_xmldom.DOMNodeList;
l_tmpnode dbms_xmldom.DOMNode;
l_esigNode dbms_xmldom.DOMNode;
l_ehdrNode dbms_xmldom.DOMNode;
l_eleNodeList dbms_xmldom.DOMNodeList;
l_eleNode dbms_xmldom.DOMNode;
esigHdrFinalXML XMLType;
l_debug_level number(2):=6;
l_error_code pls_integer;
l_log_file varchar2(2000);
l_error_msg varchar2(2000);
DB_TO_XML_ERROR  EXCEPTION;
BEGIN

    ecx_outbound.getXML(i_map_code         => P_MAP_CODE,
                      i_document_id      => P_EVENT_KEY,
                      i_debug_level      => l_debug_level,
                      i_xmldoc           => l_xml,
                      i_ret_code         => l_error_code,
                      i_errbuf           => l_error_msg,
                      i_log_file         => l_log_file);

     --If the return code from ECX is a value other than 0 then
    --an error has occurred
    if(l_error_code <> 0) then
        raise DB_TO_XML_ERROR;
    end if;




 -- construct the XML Type object
   l_result := xmltype(l_xml);

   l_srcDoc := dbms_xmldom.newDOMDocument(l_result);
   l_srcDocEle := dbms_xmldom.getDocumentElement(l_srcDoc);
   l_parentRootNode := DBMS_XMLDOM.makeNode(l_srcDocEle);
   l_eleNodeList :=   dbms_xmldom.getElementsByTagName(l_srcDocEle,'InstrErecID');
   For i in 0..dbms_xmldom.getLength(l_eleNodeList)-1 LOOP
     l_eleNode := dbms_xmldom.item(l_eleNodeList, i);
      -- import Erec Header node and signature node
      l_erecID   := TO_NUMBER(DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.getFirstChild(l_eleNode)));
      EDR_PSIG.GET_EVENT_XML(P_EVENT_NAME =>null,
                        P_EVENT_KEY => null,
                        P_ERECORD_ID  => l_erecID,
                        P_GET_ERECORD_XML =>'F',
                        P_GET_PSIG_DETAILS =>'T',
                        P_GET_ACKN_DETAILS  =>'F',
                        P_GET_PRINT_DETAILS =>'F',
                        P_GET_RELATED_EREC_DETAILS =>'F',
                        X_FINAL_XML    =>   l_final_xml);
       esigHdrFinalXML :=  xmltype(l_final_xml);


    -- construct ESIG HDR Node
      l_sigHDRDoc := DBMS_XMLDOM.newDOMDocument(esigHdrFinalXML);
    -- make the Header Noe
      l_sigHDRDocEle := DBMS_XMLDOM.getDocumentElement(l_sigHDRDoc);
      l_childRootNode := DBMS_XMLDOM.makeNode(l_sigHDRDocEle);

      -- get the Heder Details node
      l_childNodeList := dbms_xmldom.getElementsByTagName(l_sigHDRDocEle,'ERECORD_HEADER_DETAILS');
      l_ehdrNode := dbms_xmldom.item(l_childNodeList, 0);
      -- get the Node to be deleted
      l_nodeListDel := dbms_xmldom.getElementsByTagName(l_sigHDRDocEle,'DOC_PARAM_DETAILS');
      For i in 0..dbms_xmldom.getLength(l_nodeListDel)-1 LOOP
       l_tmpnode := dbms_xmldom.item(l_nodeListDel, i);
       l_childNode :=  dbms_xmldom.removeChild(l_ehdrNode,l_tmpnode);
      END LOOP;

      -- get the Signature Details node
      l_childNodeList := dbms_xmldom.getElementsByTagName(l_sigHDRDocEle,'ERECORD_SIGNATURE_DETAILS');
      l_esigNode := dbms_xmldom.item(l_childNodeList, 0);
      -- get the Node to be deleted
      l_nodeListDel := dbms_xmldom.getElementsByTagName(l_sigHDRDocEle,'SIGNATURE_PARAMS');
      For i in 0..dbms_xmldom.getLength(l_nodeListDel)-1 LOOP
       l_tmpnode := dbms_xmldom.item(l_nodeListDel, i);
       l_childNode :=  dbms_xmldom.removeChild(l_esigNode,l_tmpnode);
      END LOOP;
      -- append Signature node into Header node
      if (dbms_xmldom.isNull(l_esigNode) = false) THEN
       l_tmpnode := dbms_xmldom.appendChild(l_ehdrNode,l_esigNode);
      END IF;

    -- import the Hdr node in Source Document
      l_childRootNode := dbms_xmldom.importNode(l_srcDoc,l_childRootNode,TRUE);
    -- append the HDR node in Source XML
      l_parentRootNode := dbms_xmldom.appendChild(dbms_xmldom.getParentNode(l_eleNode),l_childRootNode);
       if (dbms_xmldom.isNull(l_sigHDRDoc) = false) THEN
        dbms_xmldom.freeDocument(l_sigHDRDoc);
       End IF;
    END LOOP;

    X_FINAL_XML  := l_result.extract('//INSTRUCTION_SET');
    if (dbms_xmldom.isNull(l_srcDoc) = false) THEN
       dbms_xmldom.freeDocument(l_srcDoc);
    End IF;
EXCEPTION
  when DB_TO_XML_ERROR then
      FND_MESSAGE.SET_NAME('GMO','GMO_VALIDATE_XML_GEN_ERR');
      FND_MESSAGE.SET_TOKEN('OPERATION','DB to XML');
      FND_MESSAGE.SET_TOKEN('ERROR_DETAILS',l_error_msg);
      FND_MESSAGE.SET_TOKEN('LOG_DETAILS',l_log_file);
      APP_EXCEPTION.RAISE_EXCEPTION;
END GET_INSTR_XML;

 PROCEDURE PROCESS_INSTR_XML (p_entity_name VARCHAR2,p_entity_key VARCHAR2,p_event_key varchar2,p_instr_type VARCHAR2,
                      p_instr_status VARCHAR2,P_BATCHPROGRESSION_STATUS VARCHAR2,P_EVENT_NAME VARCHAR2,P_FINAL_XML  XMLType) IS
l_batch_id             number := null;
l_batchstep_id         number := null;
l_material_detail_id   number := null;
l_batchstep_activity_id number := null;
l_dispense_id          NUMBER := NULL;
l_parent_node          VARCHAR2(80) := NULL;
l_parent_key_node      VARCHAR2(80) := NULL;
l_parent_key_val       VARCHAR2(80) := NULL;
l_curr_node_key        VARCHAR2(80) := NULL;
l_curr_key_val         VARCHAR2(80) := NULL;
l_batch_prog_rec GMO_BATCH_PROGRESSION%ROWTYPE;
l_batch_progression_id NUMBER := NULL;
l_message_prod         VARCHAR2(10) := 'GMO';
l_message_token        VARCHAR2(50) := NULL;
l_user_key_label       VARCHAR2(80) := NULL;
l_user_key_value       VARCHAR2(80) := p_entity_key;

l_event_data CLOB;
l_MSG_COUNT NUMBER(22);
l_MSG_DATA  VARCHAR2(2000);
 CURSOR get_dispense_Details IS
       SELECT batch_id, batch_step_id ,material_detail_id
       FROM gmo_material_dispenses
       WHERE dispense_id = p_entity_key;
 CURSOR get_rev_dispense_Details IS
       SELECT batch_id, batch_step_id ,material_detail_id,dispense_id
       FROM gmo_material_undispenses
       WHERE undispense_id = p_entity_key;
CURSOR get_resource_details IS
   SELECT  BATCH_ID,BATCHSTEP_ID,BATCHSTEP_ACTIVITY_ID    FROM GME_BATCH_STEP_RESOURCES
    where BATCHSTEP_RESOURCE_ID = p_entity_key;
BEGIN
        delete GMO_BATCH_PROGRESSION
           where event = P_EVENT_NAME
           AND event_key = p_event_key
           AND STATUS = 'INPROGRESS';

      select  P_FINAL_XML.getCLobVal() into  l_event_data    from dual;

      IF(p_instr_type =  'DISPENSE' and p_entity_name ='DISPENSE_ITEM') THEN
            OPEN get_dispense_Details;
            FETCH get_dispense_Details into l_batch_id, l_batchstep_id ,l_material_detail_id;
            CLOSE get_dispense_Details;
            l_message_token := 'GMO_ENTITY_DISPENSE_ITEM';
		l_user_key_label := FND_MESSAGE.GET_STRING('GMO',l_message_token);
            l_batch_prog_rec.PROGRESSION_ID := NULL;
            l_batch_prog_rec.BATCH_ID := l_batch_id ;
            l_batch_prog_rec.BATCHSTEP_ID := l_batchstep_id;
            l_batch_prog_rec.MATERIAL_LINE_ID := l_material_detail_id;
            l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
            l_batch_prog_rec.BATCHRSRC_ID := NULL;
            l_batch_prog_rec.DISPENSE_ID := p_entity_key;
            l_batch_prog_rec.SAMPLE_ID := NULL;
            l_batch_prog_rec.DEVIATION_ID := NULL;
            l_batch_prog_rec.TRANSACTION_ID := NULL;
            l_batch_prog_rec.PARENT_NODE := 'MATERIAL_DISPENSE';
            l_batch_prog_rec.PARENT_KEY_NODE := 'DISPENSE_ID';
            l_batch_prog_rec.PARENT_KEY_VAL := p_entity_key;
            l_batch_prog_rec.CURR_NODE_KEY := 'INSTRUCTION_SET_ID';
            l_batch_prog_rec.CURR_KEY_VAL := p_event_key;
            -- Bug 5231778 : change the Instr Type for Reverse Dispense.
       ELSIF(p_instr_type =  'REVERSE_DISPENSE' and p_entity_name ='DISPENSE_ITEM') THEN
            OPEN get_rev_dispense_Details;
            FETCH get_rev_dispense_Details into l_batch_id, l_batchstep_id ,l_material_detail_id,l_dispense_id;
            CLOSE get_rev_dispense_Details;
            l_message_token := 'GMO_ENTITY_REV_DISP_ITEM';
		l_user_key_label := FND_MESSAGE.GET_STRING('GMO',l_message_token);
            l_batch_prog_rec.PROGRESSION_ID := NULL;
            l_batch_prog_rec.BATCH_ID := l_batch_id ;
            l_batch_prog_rec.BATCHSTEP_ID := l_batchstep_id;
            l_batch_prog_rec.MATERIAL_LINE_ID := l_material_detail_id;
            l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
            l_batch_prog_rec.BATCHRSRC_ID := NULL;
            l_batch_prog_rec.DISPENSE_ID := p_entity_key;
            l_batch_prog_rec.SAMPLE_ID := NULL;
            l_batch_prog_rec.DEVIATION_ID := NULL;
            l_batch_prog_rec.TRANSACTION_ID := NULL;
            l_batch_prog_rec.PARENT_NODE := 'MATERIAL_REVERSE_DISPENSE';
            l_batch_prog_rec.PARENT_KEY_NODE := 'UNDISPENSE_ID';
            l_batch_prog_rec.PARENT_KEY_VAL := p_entity_key;
            l_batch_prog_rec.CURR_NODE_KEY := 'INSTRUCTION_SET_ID';
            l_batch_prog_rec.CURR_KEY_VAL := p_event_key;
       ELSIF(p_instr_type =  'PROCESS' and p_entity_name ='ACTIVITY') THEN
            SELECT BATCH_ID,BATCHSTEP_ID into l_batch_id,l_batchstep_id   FROM GME_BATCH_STEP_ACTIVITIES
            WHERE batchstep_activity_id = p_entity_key;
		l_message_token := 'GMO_ENTITY_ACTIVITY';
		l_user_key_label := FND_MESSAGE.GET_STRING('GMO',l_message_token);
            l_batch_prog_rec.PROGRESSION_ID := NULL;
            l_batch_prog_rec.BATCH_ID := l_batch_id ;
            l_batch_prog_rec.BATCHSTEP_ID := l_batchstep_id;
            l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
            l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
            l_batch_prog_rec.BATCHRSRC_ID := NULL;
            l_batch_prog_rec.DISPENSE_ID := NULL;
            l_batch_prog_rec.SAMPLE_ID := NULL;
            l_batch_prog_rec.DEVIATION_ID := NULL;
            l_batch_prog_rec.TRANSACTION_ID := NULL;
            l_batch_prog_rec.PARENT_NODE := 'ACTIVITIES';
            l_batch_prog_rec.PARENT_KEY_NODE := 'STEP_ACTIVITY_ID';
            l_batch_prog_rec.PARENT_KEY_VAL := p_entity_key;
            l_batch_prog_rec.CURR_NODE_KEY := 'INSTRUCTION_SET_ID';
            l_batch_prog_rec.CURR_KEY_VAL := p_event_key;
        ELSIF(p_instr_type =  'PROCESS' and p_entity_name ='RESOURCE') THEN
             open get_resource_details;
             FETCH  get_resource_details  into l_batch_id,l_batchstep_id,l_batchstep_activity_id;
             CLOSE get_resource_details;
		l_message_token := 'GMO_ENTITY_RESOURCE';
		l_user_key_label := FND_MESSAGE.GET_STRING('GMO',l_message_token);
            l_batch_prog_rec.PROGRESSION_ID := NULL;
            l_batch_prog_rec.BATCH_ID := l_batch_id ;
            l_batch_prog_rec.BATCHSTEP_ID := l_batchstep_id;
            l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
            l_batch_prog_rec.BATCHACTIVITY_ID := l_batchstep_activity_id;
            l_batch_prog_rec.BATCHRSRC_ID := p_entity_key;
            l_batch_prog_rec.DISPENSE_ID := NULL;
            l_batch_prog_rec.SAMPLE_ID := NULL;
            l_batch_prog_rec.DEVIATION_ID := NULL;
            l_batch_prog_rec.TRANSACTION_ID := NULL;
            l_batch_prog_rec.PARENT_NODE := 'RESOURCE_REQUIREMENTS';
            l_batch_prog_rec.PARENT_KEY_NODE := 'STEP_RESOURCE_ID';
            l_batch_prog_rec.PARENT_KEY_VAL := p_entity_key;
            l_batch_prog_rec.CURR_NODE_KEY := 'INSTRUCTION_SET_ID';
            l_batch_prog_rec.CURR_KEY_VAL := p_event_key;
        ELSIF(p_instr_type =  'PROCESS' and p_entity_name ='MATERIAL') THEN
            select batch_id into  l_batch_id from gme_material_details
                  where material_detail_id=p_entity_key;
       	l_message_token := 'GMO_ENTITY_MATERIAL';
		l_user_key_label := FND_MESSAGE.GET_STRING('GMO',	l_message_token);
            l_batch_prog_rec.PROGRESSION_ID := NULL;
            l_batch_prog_rec.BATCH_ID := l_batch_id ;
            l_batch_prog_rec.BATCHSTEP_ID := NULL;
            l_batch_prog_rec.MATERIAL_LINE_ID := p_entity_key;
            l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
            l_batch_prog_rec.BATCHRSRC_ID := NULL;
            l_batch_prog_rec.DISPENSE_ID := NULL;
            l_batch_prog_rec.SAMPLE_ID := NULL;
            l_batch_prog_rec.DEVIATION_ID := NULL;
            l_batch_prog_rec.TRANSACTION_ID := NULL;
            l_batch_prog_rec.PARENT_NODE := 'MATERIAL_REQUIREMENTS';
            l_batch_prog_rec.PARENT_KEY_NODE := 'MATERIAL_DETAIL_ID';
            l_batch_prog_rec.PARENT_KEY_VAL := p_entity_key;
            l_batch_prog_rec.CURR_NODE_KEY := 'INSTRUCTION_SET_ID';
            l_batch_prog_rec.CURR_KEY_VAL := p_event_key;
        ELSIF(p_instr_type =  'PROCESS' and p_entity_name ='OPERATION') THEN
          SELECT batch_id into l_batch_id
               FROM GME_BATCH_STEPS
                 WHERE batchstep_id = p_entity_key;
       	l_message_token := 'GMO_ENTITY_OPERATION';
		l_user_key_label := FND_MESSAGE.GET_STRING('GMO',l_message_token);
            l_batch_prog_rec.PROGRESSION_ID := NULL;
            l_batch_prog_rec.BATCH_ID := l_batch_id ;
            l_batch_prog_rec.BATCHSTEP_ID := p_entity_key;
            l_batch_prog_rec.MATERIAL_LINE_ID := NULL;
            l_batch_prog_rec.BATCHACTIVITY_ID := NULL;
            l_batch_prog_rec.BATCHRSRC_ID := NULL;
            l_batch_prog_rec.DISPENSE_ID := NULL;
            l_batch_prog_rec.SAMPLE_ID := NULL;
            l_batch_prog_rec.DEVIATION_ID := NULL;
            l_batch_prog_rec.TRANSACTION_ID := NULL;
            l_batch_prog_rec.PARENT_NODE := 'ROUTING_STEPS';
            l_batch_prog_rec.PARENT_KEY_NODE := 'STEP_ID';
            l_batch_prog_rec.PARENT_KEY_VAL := p_entity_key;
            l_batch_prog_rec.CURR_NODE_KEY := 'INSTRUCTION_SET_ID';
            l_batch_prog_rec.CURR_KEY_VAL := p_event_key;
         END IF;
            l_batch_prog_rec.USER_KEY_LABEL_PROD := l_message_prod;
            l_batch_prog_rec.USER_KEY_LABEL_TOKEN := l_message_token;
            l_batch_prog_rec.USER_KEY_LABEL := l_user_key_label;
            l_batch_prog_rec.USER_KEY_VALUE := l_user_key_value;
            l_batch_prog_rec.EXTERNAL_EVENT := 'N';
            l_batch_prog_rec.INCLUDE_IN_CBR := 'XTEXT';
            l_batch_prog_rec.EVENT := P_EVENT_NAME;
            l_batch_prog_rec.EVENT_KEY := p_event_key;
            l_batch_prog_rec.EVENT_DATE := SYSDATE;
            l_batch_prog_rec.PLANED_START_DATE := null;
            l_batch_prog_rec.ERECORD_ID := NULL;
            l_batch_prog_rec.XML_EREC := l_event_data;
            l_batch_prog_rec.STATUS := P_BATCHPROGRESSION_STATUS;
            l_batch_prog_rec.INCLUDED_IN_CBR := 'N';
            l_batch_prog_rec.COMPARE_XML := 'N';
            gmo_cbr_grp.insert_event(l_batch_prog_rec,l_batch_progression_id);

            EXCEPTION
        	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('GMO','FND_AS_UNEXPECTED_ERROR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE', SQLCODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => l_msg_count, p_data => l_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.GMO_CBR_GRP.PROCESS_INSTR_XML', FALSE);
		end if;
  END PROCESS_INSTR_XML;

FUNCTION PROCESS_INSTANCE_INSTR_SET(P_SUBSCRIPTION_GUID IN RAW, P_EVENT IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2 IS
  l_xml_map_code varchar2(240);
  l_result XMLType;
  l_temp XMLType;
  l_entity_name VARCHAR2(200);
  l_entity_key VARCHAR2(500);
  l_instr_type VARCHAR2(40);
  l_instr_status VARCHAR2(40);
  l_instr_set_id NUMBER(22):=2641;
  l_erecID NUMBER(22);
  l_orig_source  varchar2(40);
  l_orig_sourceID number(22);
  l_batchprogression_status VARCHAR2(200) := NULL;
  l_batchprogression_curr_status VARCHAR2(200) := NULL;
  l_event_key       varchar2(240);
  l_event_name VARCHAR2(240);
  l_return_status varchar2(10);
  CURSOR get_pending_instr_curr (p_event_name VARCHAR2,p_event_key VARCHAR2) is
    select  STATUS
    from gmo_batch_progression
    where event =p_event_name
      and EVENT_KEY=p_event_key
      and STATUS = 'INPROGRESS' ;
 BEGIN

  l_return_status:=wf_rule.setParametersIntoParameterList(p_subscription_guid,p_event);
  l_event_name:=p_event.getEventName();
  l_event_key:=p_event.getEventKey();
  l_xml_map_code := NVL(wf_event.getValueForParameter('GMO_XML_MAP_CODE',p_event.Parameter_List),
                          P_EVENT.getEventName( ));
 --  Get the Instruction Set XML
   GET_INSTR_XML(l_event_key,l_xml_map_code,l_result);
   l_entity_name := getValue(l_result,'//ENTITY_NAME');
   l_entity_key  := getValue(l_result,'//ENTITY_KEY');
   l_instr_type  := getValue(l_result,'//INSTRUCTION_TYPE');
   l_orig_source := getValue(l_result,'//ORIG_SOURCE');
   l_orig_sourceID := getValue(l_result,'//ORIG_SOURCE_ID');
   l_instr_status := getValue(l_result,'//INSTR_SET_STATUS');

   IF(l_instr_status = GMO_CONSTANTS_GRP.G_INSTR_STATUS_COMPLETE OR l_instr_status = GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL) THEN
     l_batchprogression_status := 'COMPLETE';
   ELSE
     l_batchprogression_status := 'INPROGRESS';
   END IF;


   IF(l_orig_source = GMO_CONSTANTS_GRP.G_ORIG_SOURCE_DEFN) THEN
       PROCESS_INSTR_XML(l_entity_name,l_entity_key,l_event_key,l_instr_type,l_instr_status,l_batchprogression_status,l_event_name,l_result);
   ELSIF(l_orig_source = GMO_CONSTANTS_GRP.G_ORIG_SOURCE_INSTANCE) THEN
     -- process Instruction with new INSTR Set ID
      PROCESS_INSTR_XML(l_entity_name,l_entity_key,l_event_key,l_instr_type,l_instr_status,l_batchprogression_status,l_event_name,l_result);
     -- process Instruction with old INSTR Set ID
      l_event_key := l_orig_sourceID;
      open get_pending_instr_curr(l_event_name,l_event_key);
      loop
      fetch get_pending_instr_curr into  l_batchprogression_curr_status;
       exit when get_pending_instr_curr%NOTFOUND;
   --  Get the Instruction Set XML for Old Set ID
      GET_INSTR_XML(l_event_key,l_xml_map_code,l_result);
      l_batchprogression_status := 'COMPLETE';
      PROCESS_INSTR_XML(l_entity_name,l_entity_key,l_event_key,l_instr_type,l_instr_status,l_batchprogression_status,l_event_name,l_result);
      END LOOP;
   END IF;
   return 'SUCCESS';
 END PROCESS_INSTANCE_INSTR_SET;

 PROCEDURE DELETE_PROGRESSION_ROW (P_BATCH_PROGRESSION_ID   NUMBER DEFAULT Null,
                                   P_ERECORD_ID             NUMBER DEFAULT Null,
                                   P_EVENT                  VARCHAR2 DEFAULT Null,
                                   P_EVENT_KEY              VARCHAR2 DEFAULT Null,
                                   X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
                                   X_MSG_COUNT            OUT NOCOPY NUMBER,
                                   X_MSG_DATA             OUT NOCOPY VARCHAR2) IS
 BEGIN

   IF P_BATCH_PROGRESSION_ID IS NOT NULL
   THEN
     DELETE GMO_BATCH_PROGRESSION
     WHERE PROGRESSION_ID = P_BATCH_PROGRESSION_ID;
     X_RETURN_STATUS := 'S';
   ELSIF P_ERECORD_ID IS NOT NULL
   THEN
     DELETE GMO_BATCH_PROGRESSION
     WHERE ERECORD_ID = P_ERECORD_ID;
     X_RETURN_STATUS := 'S';
   ELSIF ((P_EVENT IS NOT NULL) and (P_EVENT_KEY IS NOT NULL))
   THEN
     DELETE GMO_BATCH_PROGRESSION
     WHERE EVENT     = P_EVENT
       AND EVENT_KEY = P_EVENT_KEY;
     X_RETURN_STATUS := 'S';
   ELSE
     FND_MESSAGE.SET_NAME('GMO','GMO_DEL_PROG_ROW_PARAMETER_ERR');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
     X_RETURN_STATUS := 'E';
     if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_CBR_GRP.DELETE_PROGRESSION_ROW',
                      FALSE
                       );
     end if;
   END IF;

 END DELETE_PROGRESSION_ROW;



END GMO_CBR_GRP;

/
