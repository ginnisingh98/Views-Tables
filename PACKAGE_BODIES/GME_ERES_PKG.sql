--------------------------------------------------------
--  DDL for Package Body GME_ERES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_ERES_PKG" AS
/* $Header: GMEVERSB.pls 120.3.12000000.2 2007/03/06 21:31:31 adeshmuk ship $ */

   /****************************************************************************************
    *** Following procedure is used to insert ERES event in GME_ERES_GTMP table for ERES
    *** processing from form
    ****************************************************************************************/

   PROCEDURE INSERT_EVENT(P_EVENT_NAME VARCHAR2,
                          P_EVENT_KEY VARCHAR2,
                          P_USER_KEY_LABEL VARCHAR2,
                          P_USER_KEY_VALUE VARCHAR2,
                          P_POST_OP_API VARCHAR2,
                          P_PARENT_EVENT VARCHAR2,
                          P_PARENT_EVENT_KEY VARCHAR2,
                          P_PARENT_ERECORD_ID NUMBER,
                          X_STATUS OUT NOCOPY VARCHAR2) IS
    CURSOR check_event_already_exisits IS
      select count(*)
      from GME_ERES_GTMP
      where event_name = p_event_name
        and event_key  = p_event_key;
    l_count number:=0;
    l_ins_flag VARCHAR2(5);
    l_XML_GEN_API VARCHAR2(400);
   BEGIN

       OPEN check_event_already_exisits;
       FETCH check_event_already_exisits into l_count;
       CLOSE check_event_already_exisits;
       IF l_count = 0 THEN
          l_ins_flag  := 'Y';
          -- Meaning event data is not present in ERES Processing Table
          IF p_event_name in ( gme_common_pvt.G_RESOURCE_ADDED
                              ,gme_common_pvt.G_RESOURCE_REMOVED
                              ,gme_common_pvt.G_RESOURCE_UPDATE)
          THEN
            select count(*) into l_count
            from GME_ERES_GTMP
            where (event_name = gme_common_pvt.G_BATCHSTEP_ADDED
                   and event_key = substrb(P_EVENT_KEY,1,instrb(P_EVENT_KEY,'-',1,2)-1)) OR
                   (event_name = gme_common_pvt.G_ACTIVITY_ADDED
                      and event_key = substrb(P_EVENT_KEY,1,instrb(P_EVENT_KEY,'-',1,3)-1));
            IF l_count = 0 then
              select count(*) into l_count
              from GME_ERES_GTMP
              where event_name in (gme_common_pvt.G_RESOURCE_ADDED )
                and event_key =   p_event_key;
              IF (l_count > 0)
              THEN
                IF p_event_name = gme_common_pvt.G_RESOURCE_REMOVED THEN
                  delete GME_ERES_GTMP
                  where  event_name in (gme_common_pvt.G_RESOURCE_ADDED )
                  and event_key =   p_event_key;
                end if;
                l_ins_flag  := 'N';
              ELSE
                if p_event_name = gme_common_pvt.G_RESOURCE_REMOVED
                then
                  delete GME_ERES_GTMP
                  where  event_name in (gme_common_pvt.G_RESOURCE_UPDATE)
                  and event_key =   p_event_key;
                end if;
                l_ins_flag := 'Y';
              END IF;
            ELSE
              l_ins_flag  := 'N';
            END IF;
          ELSIF p_event_name in (gme_common_pvt.G_ACTIVITY_ADDED
                            ,gme_common_pvt.G_ACTIVITY_REMOVED
                            ,gme_common_pvt.G_ACTIVITY_UPDATED)
          THEN
            select count(*) into l_count
            from GME_ERES_GTMP
            where (event_name = gme_common_pvt.G_BATCHSTEP_ADDED
                   and event_key = substrb(P_EVENT_KEY,1,instrb(P_EVENT_KEY,'-',1,2)-1));
            IF l_count = 0 then
              select count(*) into l_count
              from GME_ERES_GTMP
              where event_name in (gme_common_pvt.G_ACTIVITY_ADDED )
                and event_key =   p_event_key;
              IF (l_count > 0)
              THEN
                IF p_event_name = gme_common_pvt.G_ACTIVITY_REMOVED THEN
                  delete GME_ERES_GTMP
                  where  event_name in (gme_common_pvt.G_ACTIVITY_ADDED )
                  and event_key =   p_event_key;
                end if;
                l_ins_flag  := 'N';
              ELSE
                if p_event_name = gme_common_pvt.G_ACTIVITY_REMOVED
                then
                  delete GME_ERES_GTMP
                  where  (event_name in (gme_common_pvt.G_ACTIVITY_UPDATED)
                  and event_key =   p_event_key) OR
                       (event_name in (gme_common_pvt.G_RESOURCE_ADDED
                            ,gme_common_pvt.G_RESOURCE_REMOVED
                            ,gme_common_pvt.G_RESOURCE_UPDATE)
                          and substrb(EVENT_KEY,1,instrb(EVENT_KEY,'-',1,3)-1) = p_event_key);
                end if;
                l_ins_flag := 'Y';
              END IF;
            ELSE
              l_ins_flag  := 'N';
            END IF;
          ELSIF p_event_name in (gme_common_pvt.G_BATCHSTEP_ADDED ,
                                 gme_common_pvt.G_BATCHSTEP_REMOVED ,
                                 gme_common_pvt.G_BATCHSTEP_UPDATE)
          THEN
            select count(*) into l_count
            from GME_ERES_GTMP
            where event_name = gme_common_pvt.G_BATCHSTEP_ADDED
              and event_key =   p_event_key;
            IF (l_count > 0)
            THEN
                IF p_event_name = gme_common_pvt.G_BATCHSTEP_REMOVED  THEN
                  delete GME_ERES_GTMP
                  where  event_name in (gme_common_pvt.G_BATCHSTEP_ADDED )
                  and event_key =   p_event_key;
                end if;
                l_ins_flag  := 'N';
             ELSE
                if p_event_name = gme_common_pvt.G_BATCHSTEP_REMOVED
                then
                  delete GME_ERES_GTMP
                  where  (event_name in (gme_common_pvt.G_BATCHSTEP_UPDATE)
                  and event_key =   p_event_key) OR
                       (event_name in (gme_common_pvt.G_RESOURCE_ADDED
                            ,gme_common_pvt.G_RESOURCE_REMOVED
                            ,gme_common_pvt.G_RESOURCE_UPDATE
                            ,gme_common_pvt.G_ACTIVITY_ADDED
                            ,gme_common_pvt.G_ACTIVITY_REMOVED
                            ,gme_common_pvt.G_ACTIVITY_UPDATED)
                          and substrb(EVENT_KEY,1,instrb(EVENT_KEY,'-',1,2)-1) = p_event_key);
                end if;
                l_ins_flag := 'Y';
            END IF;
          END IF;
          IF  p_event_name in ( gme_common_pvt.G_BATCHMTL_ADDED
                                 ,gme_common_pvt.G_BATCHMTL_REMOVED
                                 ,gme_common_pvt.G_BATCHMTL_UPDATED)
          THEN

            select count(*) into l_count
            from GME_ERES_GTMP
            where event_name = gme_common_pvt.G_BATCHMTL_ADDED
              and event_key =   p_event_key;
            IF (l_count > 0)
            THEN
                IF p_event_name =  gme_common_pvt.G_BATCHMTL_REMOVED THEN
                  delete GME_ERES_GTMP
                  where  event_name in (gme_common_pvt.G_BATCHMTL_ADDED)
                  and event_key =   p_event_key;
                end if;
                l_ins_flag  := 'N';
            ELSE
                if p_event_name = gme_common_pvt.G_BATCHMTL_REMOVED
                then
                  delete GME_ERES_GTMP
                  where  (event_name in (gme_common_pvt.G_BATCHMTL_UPDATED)
                  and event_key =   p_event_key);
                end if;
                l_ins_flag := 'Y';
            END IF;
          END IF;
       ELSE
         l_ins_flag  := 'N';
       END IF;
       IF l_ins_flag = 'Y' THEN
         IF p_event_name in ( gme_common_pvt.G_RESOURCE_REMOVED
                             ,gme_common_pvt.G_BATCHMTL_REMOVED
                             ,gme_common_pvt.G_ACTIVITY_REMOVED
                             ,gme_common_pvt.G_BATCHSTEP_REMOVED )
         THEN
           l_XML_GEN_API := ' GME_ERES_PKG.GET_EVENT_XML('||''''||p_event_name||''','''||P_EVENT_KEY||''''||')';
         ELSE
           l_XML_GEN_API := null;
         END IF;
         INSERT INTO GME_ERES_GTMP ( Event_name
                                    ,Event_key
                                    ,Task
                                    ,Action_code
                                    ,User_KEY_LABEL
                                    ,USER_KEY_VALUE
                                    ,POST_OP_API
                                    ,PARENT_EVENT
                                    ,PARENT_EVENT_KEY
                                    ,PARENT_ERECORD_ID
                                    ,XML_GENERATION_API )
                  VALUES  (P_EVENT_NAME,
                           P_EVENT_KEY,
                           null,
                           null,
                           P_USER_KEY_LABEL,
                           P_USER_KEY_VALUE,
                           P_POST_OP_API,
                           P_PARENT_EVENT,
                           P_PARENT_EVENT_KEY,
                           P_PARENT_ERECORD_ID,
                           l_XML_GEN_API);
       END IF;

   END INSERT_EVENT;
   /****************************************************************************************
    *** Following procedure is used to retrieve Item concatenated segments
    *** using org_id and item_id
    ****************************************************************************************/
   FUNCTION GET_ITEM_NUMBER(P_ORGANIZATION_ID NUMBER,
                            P_INVENTORY_ITEM_ID NUMBER) RETURN VARCHAR2 IS
     L_ITEM_NUMBER varchar2(240);
     CURSOR GET_ITEM_NUM IS
     SELECT CONCATENATED_SEGMENTS
     FROM MTL_SYSTEM_ITEMS_B_KFV
     WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
       AND INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;
   BEGIN
     OPEN GET_ITEM_NUM;
     FETCH GET_ITEM_NUM INTO L_ITEM_NUMBER;
     CLOSE GET_ITEM_NUM;
     RETURN L_ITEM_NUMBER;
   END GET_ITEM_NUMBER;

   /****************************************************************************************
    *** Following procedure is used to retrieve operation number
    ***
    ****************************************************************************************/

   FUNCTION GET_OPRN_NO(P_OPRN_ID NUMBER)  RETURN VARCHAR2 is
     L_OPRN_NO varchar2(80);
     CURSOR GET_OPERATION_NO IS
     SELECT OPRN_NO
     FROM GMD_OPERATIONS_B
     WHERE OPRN_ID = P_OPRN_ID;
   BEGIN
     OPEN GET_OPERATION_NO;
     FETCH GET_OPERATION_NO INTO L_OPRN_NO;
     CLOSE GET_OPERATION_NO;
     RETURN L_OPRN_NO;
   END GET_OPRN_NO;

   FUNCTION GET_EVENT_XML (P_EVENT_NAME VARCHAR2,P_EVENT_KEY VARCHAR2) RETURN CLOB IS
   PRAGMA AUTONOMOUS_TRANSACTION;
    l_xml CLOB;
    l_error_code NUMBER;
    l_error_msg VARCHAR2(4000);
    l_log_file VARCHAR2(4000);
    l_map_code VARCHAR2(50);
    l_CNT      NUMBER;
    CURSOR GET_MAP_CODE IS
       SELECT DISTINCT b.STATUS,
              EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_XML_MAP_CODE',b.GUID) map_code
       FROM wf_events_vl a,
            wf_event_subscriptions b
       WHERE a.guid=b.EVENT_FILTER_GUID
         -- Namit S. Bug#4917171 Added the following 2 clauses.
         -- Table wf_event_subscriptions has index on EVENT_FILTER_GUID, source_type, system_guid.
         -- Adding the 2 clauses removes Full Table Scan of wf_event_subscriptions.
         AND b.source_type = 'LOCAL'
         AND b.system_guid = HEXTORAW(wf_core.TRANSLATE('WF_SYSTEM_GUID'))
         AND b.RULE_FUNCTION ='EDR_PSIG_RULE.PSIG_RULE'
         AND a.name = p_event_name
         AND b.status = 'ENABLED'
       ORDER BY b.STATUS DESC;
  BEGIN
    SELECT COUNT(*) INTO l_cnt
    FROM   wf_events_vl a,
           wf_event_subscriptions b
    WHERE a.guid=b.EVENT_FILTER_GUID
      -- Namit S. Bug#4917171 Added the following 2 clauses.
      AND b.source_type = 'LOCAL'
      AND b.system_guid = HEXTORAW(wf_core.TRANSLATE('WF_SYSTEM_GUID'))
      AND b.RULE_FUNCTION ='EDR_PSIG_RULE.PSIG_RULE'
      AND b.status = 'ENABLED'
      AND a.name = p_event_name;
    IF l_cnt > 1 THEN
      ROLLBACK;
      return null;
    ELSE
      l_cnt := 0;
      FOR GET_MAP_CODE_REC in  GET_MAP_CODE
      LOOP
        l_map_code := GET_MAP_CODE_REC.map_code;
        l_cnt := l_cnt + 1;
      END LOOP;
      IF L_CNT = 1
      THEN
         edr_utilities.generate_xml(P_MAP_CODE     => nvl(l_map_code,P_EVENT_NAME)
                                   ,P_DOCUMENT_ID  => P_EVENT_KEY
                                   ,p_xml          => l_xml
                                   ,p_error_code   => l_error_code
                                   ,p_error_msg    => l_error_msg
                                   ,p_log_file     => l_log_file);

         ROLLBACK;
         RETURN l_xml;
       ELSE
         ROLLBACK;
         RETURN NULL;
       END IF;
     END IF;
     ROLLBACK;
     RETURN l_xml;
  END;

END;

/
