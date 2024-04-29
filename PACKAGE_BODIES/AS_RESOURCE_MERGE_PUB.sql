--------------------------------------------------------
--  DDL for Package Body AS_RESOURCE_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_RESOURCE_MERGE_PUB" as
/* $Header: asxrsmrb.pls 120.2 2005/12/22 22:53:57 subabu noship $ */

-- Start of Comments
-- Package name     : AS_RESOURCE_MERGE_PUB
--
-- Purpose      : This package should be called in event subscription of
--                event oracle.apps.jtf.jres.resource.update.effectdate.
--                It will update the salesforce_id(resource_id) column in AS
--                tables due to resource merge.
--
-- NOTES
--
-- HISTORY
--   12/31/03  FFANG    Created.
--
--

FUNCTION update_resource_enddate (
    p_subscription_guid  in raw,
    p_event              in out NOCOPY wf_event_t )
RETURN VARCHAR2
IS
    l_event_key                varchar2(240) := p_event.GetEventKey();
    l_event_name               varchar2(240) := p_event.GetEventName();
    l_event_details            varchar2(2000);
    l_resource_id              number;
    l_resource_name            varchar2(240);
    l_category                 varchar2(30);
    l_new_start_date    date;
    l_new_end_date      date;
    l_old_start_date    date;
    l_old_end_date      date;

    l_logdir       VARCHAR2(500);
    l_logfile      VARCHAR2(200) := 'asxrsmrb.log';
    l_file_ptr     UTL_FILE.FILE_TYPE;
    l_filepath     VARCHAR2(500);
    l_begin_pos    NUMBER;
    l_length       NUMBER;
    l_sysdate      VARCHAR2(100) := TO_CHAR(SYSDATE,'DD-MON-YYYY-HH:MI:SS');

    cursor c_get_from_resource (c_resource_id NUMBER) is
        select resource_id from jtf_rs_resource_extns
        where category in ('PARTNER', 'PARTY')
          and source_id =
               (select party_id from hz_relationships
                where relationship_id=
                       (select merge_to_entity_id from hz_merge_party_details
                        where merge_from_entity_id =
                               (select relationship_id
                                from hz_relationships
                                where party_id=
                                       (select source_id
                                        from jtf_rs_resource_extns
                                        where resource_id=c_resource_id) ) ) );

    l_to_resource_id    NUMBER;

BEGIN

    -- Fetch the directories to which UTL_FILE has access to write
    -- they will be seperated by comma ","
    SELECT value
    INTO   l_logdir
    FROM   v$parameter
    WHERE  UPPER(name) = 'UTL_FILE_DIR';

    -- Parse the logdir for the first comma and get the first directory
    l_begin_pos   := instr(l_logdir,',');
    IF l_begin_pos > 0 THEN
       l_length   := l_begin_pos-1;
       l_filepath := ltrim(substr(l_logdir,1,l_length));
    ELSE
       l_filepath := ltrim(l_logdir);
    END IF;

    l_file_ptr    := UTL_FILE.FOPEN(l_filepath,l_logfile,'a');
    UTL_FILE.Put_Line(l_file_ptr,'===========================================');
    UTL_FILE.Put_Line(l_file_ptr,'Event subscription Start '||l_sysdate);

    -- Get event parameters
    l_resource_id    := p_event.GetValueForParameter('RESOURCE_ID');
    l_category       := p_event.GetValueForParameter('CATEGORY');
    l_resource_name  := p_event.GetValueForParameter('RESOURCE_NAME');
    l_new_start_date := p_event.GetValueForParameter('NEW_START_DATE_ACTIVE');
    l_old_start_date := p_event.GetValueForParameter('OLD_START_DATE_ACTIVE');
    l_new_end_date   := p_event.GetValueForParameter('NEW_END_DATE_ACTIVE');
    l_old_end_date   := p_event.GetValueForParameter('OLD_END_DATE_ACTIVE');
    l_event_details  := 'Active Date of '||l_category || ' resource: '''
                        || l_resource_id || ' - '
                        || l_resource_name
                        || ' is changed.';

    if (nvl(l_new_start_date, sysdate+100000) <>
        nvl(l_old_start_date, sysdate+100000))
    then
        UTL_FILE.Put_Line(l_file_ptr,l_event_details);
        UTL_FILE.Put_Line(l_file_ptr,'New Start Date: '|| l_new_start_date);
        UTL_FILE.Put_Line(l_file_ptr,'Old Start Date: '|| l_old_start_date);
    end if;

    if (nvl(l_new_end_date, sysdate+100000) <>
        nvl(l_old_end_date, sysdate+100000))
    then
        UTL_FILE.Put_Line(l_file_ptr,l_event_details);
        UTL_FILE.Put_Line(l_file_ptr,'New End Date: '|| l_new_end_date);
        UTL_FILE.Put_Line(l_file_ptr,'Old End Date: '|| l_old_end_date);

        -- resource got end-dated, check if it is because of resource merge;
        -- if yes, update the resources in AS tables
        open c_get_from_resource (l_resource_id);
        fetch c_get_from_resource into l_to_resource_id;

        UTL_FILE.Put_Line(l_file_ptr,'To Resource Id: '||l_to_resource_id);

        -- Bug 3555514
        -- Don't update salesforce_id if to_resource_id is null while end-dating resource
        if (l_to_resource_id is not null)
        then
            UTL_FILE.Put_Line(l_file_ptr,'Salesforce Update Start');

            -- AS_ACCESSES_ALL
            begin
                UTL_FILE.Put_Line(l_file_ptr, 'Updating AS_ACCESSES_ALL');
                update AS_ACCESSES_ALL
                set salesforce_id = l_to_resource_id
                where salesforce_id = l_resource_id;
            exception
              when others then
                UTL_FILE.Put_Line(l_file_ptr,
                                  'Errors when updating AS_ACCESSES_ALL');
                RAISE;
            end;

            -- AS_SALES_CREDITS
            begin
                UTL_FILE.Put_Line(l_file_ptr, 'Updating AS_SALES_CREDITS');
                update AS_SALES_CREDITS
                set salesforce_id = l_to_resource_id
                where salesforce_id = l_resource_id;
            exception
              when others then
                UTL_FILE.Put_Line(l_file_ptr,
                                  'Errors when updating AS_SALES_CREDITS');
                RAISE;
            end;

            -- AS_SALES_CREDITS_DENORM
            begin
                UTL_FILE.Put_Line(l_file_ptr, 'Updating AS_SALES_CREDITS_DENORM');
                update AS_SALES_CREDITS_DENORM
                set salesforce_id = l_to_resource_id
                where salesforce_id = l_resource_id;
            exception
              when others then
                UTL_FILE.Put_Line(l_file_ptr,
                                  'Errors when updating AS_SALES_CREDITS_DENORM');
                RAISE;
            end;

            -- AS_INTERNAL_FORECASTS
            begin
                UTL_FILE.Put_Line(l_file_ptr, 'Updating AS_INTERNAL_FORECASTS');
                update AS_INTERNAL_FORECASTS
                set salesforce_id = l_to_resource_id
                where salesforce_id = l_resource_id;
            exception
              when others then
                UTL_FILE.Put_Line(l_file_ptr,
                                  'Errors when updating AS_INTERNAL_FORECASTS');
                RAISE;
            end;

            -- AS_FORECAST_WORKSHEETS
            begin
                UTL_FILE.Put_Line(l_file_ptr, 'Updating AS_FORECAST_WORKSHEETS');
                update AS_FORECAST_WORKSHEETS
                set salesforce_id = l_to_resource_id
                where salesforce_id = l_resource_id;
            exception
              when others then
                UTL_FILE.Put_Line(l_file_ptr,
                                  'Errors when updating AS_FORECAST_WORKSHEETS');
                RAISE;
            end;

            -- AS_PROD_WORKSHEET_LINES
            begin
                UTL_FILE.Put_Line(l_file_ptr, 'Updating AS_PROD_WORKSHEET_LINES');
                update AS_PROD_WORKSHEET_LINES
                set salesforce_id = l_to_resource_id
                where salesforce_id = l_resource_id;
            exception
              when others then
                UTL_FILE.Put_Line(l_file_ptr,
                                  'Errors when updating AS_PROD_WORKSHEET_LINES');
                RAISE;
            end;
            UTL_FILE.Put_Line(l_file_ptr,'Salesforce Update End');
        end if;
    end if;

    UTL_FILE.FFLUSH(l_file_ptr);
    UTL_FILE.FClose(l_file_ptr);

    return 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('AS_RESOURCE_MERGE_PUB', 'update_resource_enddate',
                    p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    UTL_FILE.PUT_LINE(l_file_ptr, 'Error number ' || to_char(SQLCODE));
    UTL_FILE.PUT_LINE(l_file_ptr, 'Error message ' || SQLERRM);
    UTL_FILE.FFLUSH(l_file_ptr);
    UTL_FILE.FCLOSE(l_file_ptr);

    RETURN 'ERROR';
END update_resource_enddate;

END AS_RESOURCE_MERGE_PUB;

/
