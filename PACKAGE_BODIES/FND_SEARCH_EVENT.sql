--------------------------------------------------------
--  DDL for Package Body FND_SEARCH_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SEARCH_EVENT" as
-- $Header: FNDCLGEHB.pls 120.1.12010000.1 2008/07/25 14:24:28 appldev ship $

    FUNCTION Start_Crawl(obj_name in varchar2) return VARCHAR2
    IS
    BEGIN
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.START_CRAWL',
                     'Begin Start_Crawl to initialize crawl status in change log');
      end if;
    UPDATE FND_SEARCHABLE_CHANGE_LOG
    set CRAWL_STATUS='Y'
    where object_name=obj_name;

    if (sql%rowcount=0) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.START_CRAWL',
                     'Change Log is empty for this object');
      end if;
      return 'ERROR';
    else
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.START_CRAWL',
                     'End Start_Crawl');
      end if;
      return 'SUCCESS';
    end if;
    END Start_Crawl;

    FUNCTION End_Crawl(obj_name in varchar2,change_type in varchar2) return VARCHAR2
    IS
    BEGIN
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.END_CRAWL',
                     'Begin End_Crawl to remove crawled entries from the  change log');
      end if;
      if (change_type='EVENT') then
         DELETE FROM FND_SEARCHABLE_CHANGE_LOG
         WHERE  OBJECT_NAME=obj_name
         AND CHANGE_TYPE IN ('INSERT','UPDATE')
         AND CRAWL_STATUS='Y';
      elsif (change_Type ='DELETE') then
         DELETE FROM FND_SEARCHABLE_CHANGE_LOG
         WHERE  OBJECT_NAME=obj_name
         AND CHANGE_TYPE ='DELETE'
         AND CRAWL_STATUS='Y';
      elsif (change_Type='ERROR') then
         DELETE FROM FND_SEARCHABLE_CHANGE_LOG
         WHERE  OBJECT_NAME=obj_name
         AND CHANGE_TYPE ='ERROR'
         AND CRAWL_STATUS='Y';
      end if;

      if (sql%rowcount=0) then
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.END_CRAWL',
                     'Change log is empty for this object');
           end if;
           return 'ERROR';
      else
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.END_CRAWL',
                     'End End_Crawl ');
           end if;

           return 'SUCCESS';
      end if;

    END End_Crawl;

   FUNCTION Reset_Crawl(obj_name in varchar2,change_type in varchar2) return VARCHAR2
    IS
    BEGIN
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.END_CRAWL',
                     'Begin Reset_Crawl to reset entries that errored out during crawl');
      end if;
      if (change_type='EVENT') then
         UPDATE FND_SEARCHABLE_CHANGE_LOG
         SET CRAWL_STATUS=NULL
         WHERE  OBJECT_NAME=obj_name
         AND CHANGE_TYPE IN ('INSERT','UPDATE')
         AND CRAWL_STATUS='Y';
      elsif (change_Type ='DELETE') then
         UPDATE FND_SEARCHABLE_CHANGE_LOG
         SET CRAWL_STATUS=NULL
         WHERE  OBJECT_NAME=obj_name
         AND CHANGE_TYPE ='DELETE'
         AND CRAWL_STATUS='Y';
      elsif (change_Type='ERROR') then
         UPDATE FND_SEARCHABLE_CHANGE_LOG
         SET CRAWL_STATUS=NULL
         WHERE  OBJECT_NAME=obj_name
         AND CHANGE_TYPE ='ERROR'
         AND CRAWL_STATUS='Y';
      end if;

      if (sql%rowcount=0) then
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
                fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.RESET_CRAWL',
                     'Change log is empty for this object');
           end if;
           return 'ERROR';
      else
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
             fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.RESET_CRAWL',
                     'End Reset_Crawl ');
           end if;

           return 'SUCCESS';
      end if;

    END Reset_Crawl;


    FUNCTION On_Object_Change(p_subscription_guid in raw,
            p_event in out NOCOPY WF_EVENT_T) return VARCHAR2
    IS
        object_name varchar2(256);
        change_type varchar2(64);
        id_type varchar2(64);
        row_id_from varchar2(2000);
        row_id_to  varchar2(2000);
        pk_name_1 varchar2(64);
        pk_value_1 varchar2(64);
        pk_name_2 varchar2(64);
        pk_value_2 varchar2(64);
        pk_name_3 varchar2(64);
        pk_value_3 varchar2(64);
        pk_name_4 varchar2(64);
        pk_value_4 varchar2(64);
        pk_name_5 varchar2(64);
        pk_value_5 varchar2(64);
        status     varchar2(1);
        feed_url   varchar2(4000);

    BEGIN
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.ON_OBJECT_CHANGE',
                     'Begin On_Object_Change');
      end if;
        object_name := p_event.GetValueForParameter('OBJECT_NAME');
        change_type := p_event.GetValueForParameter('CHANGE_TYPE');
        id_type := p_event.GetValueForParameter('ID_TYPE');
        row_id_from := p_event.GetValueForParameter('ROW_ID_FROM');
        row_id_to := p_event.GetValueForParameter('ROW_ID_TO');
        pk_name_1 := p_event.GetValueForParameter('PK_NAME_1');
        pk_value_1 := p_event.GetValueForParameter('PK_VALUE_1');
        pk_name_2 := p_event.GetValueForParameter('PK_NAME_2');
        pk_value_2 := p_event.GetValueForParameter('PK_VALUE_2');
        pk_name_3 := p_event.GetValueForParameter('PK_NAME_3');
        pk_value_3 :=p_event.GetValueForParameter('PK_VALUE_3');
        pk_name_4 := p_event.GetValueForParameter('PK_NAME_4');
        pk_value_4 := p_event.GetValueForParameter('PK_VALUE_4');
        pk_name_5 := p_event.GetValueForParameter('PK_NAME_5');
        pk_value_5 := p_event.GetValueForParameter('PK_VALUE_5');
        status     := p_event.GetValueForParameter('CRAWL_STATUS');
        feed_url   := p_event.GetValueForParameter('DATA_FEED_URL');

        insert into fnd_searchable_change_log
        (
            EVENT_INSTANCE_ID,
            OBJECT_NAME,
            CHANGE_TYPE,
            ID_TYPE,
            ROW_FROM,
            ROW_TO,
            PK_NAME_1,
            PK_VALUE_1,
            PK_NAME_2,
            PK_VALUE_2,
            PK_NAME_3,
            PK_VALUE_3,
            PK_NAME_4,
            PK_VALUE_4,
            PK_NAME_5,
            PK_VALUE_5,
            CHANGE_DATE,
            CRAWL_STATUS,
            DATA_FEED_URL
            )values
        (
            FND_SEARCH_EVENTS_SEQ.nextVal,
            object_name,
            change_type ,
            id_type,
            row_id_from,
            row_id_to ,
            pk_name_1 ,
            pk_value_1,
            pk_name_2 ,
            pk_value_2 ,
            pk_name_3,
            pk_value_3,
            pk_name_4 ,
            pk_value_4 ,
            pk_name_5 ,
            pk_value_5 ,
            Sysdate,
            status,
            feed_url
        );
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT, 'FND_SEARCH_EVENT.ON_OBJECT_CHANGE',
                     'End On_Object_Change');
      end if;
    return 'SUCCESS';
    exception
         when others then
            WF_CORE.CONTEXT('FND_SEARCH_EVENTS', 'On_Object_Change',
                            p_event.getEventName( ), p_subscription_guid);
            WF_EVENT.setErrorInfo(p_event, 'ERROR');
            return 'ERROR';
    END On_Object_Change;


end FND_SEARCH_EVENT;

/
