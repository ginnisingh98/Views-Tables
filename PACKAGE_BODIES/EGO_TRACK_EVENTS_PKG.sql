--------------------------------------------------------
--  DDL for Package Body EGO_TRACK_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_TRACK_EVENTS_PKG" AS
/* $Header: EGOTEVTB.pls 120.5 2007/08/30 07:42:43 dedatta noship $ */


FUNCTION EGO_LOG_EVENT(p_subscription_guid IN RAW,
                                 p_event IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2 IS PRAGMA AUTONOMOUS_TRANSACTION;
    l_param_name     VARCHAR2(240);
    l_param_value    VARCHAR2(2000);
    l_event_name     VARCHAR2(2000);
    l_event_key      VARCHAR2(2000);
    l_err_text       VARCHAR2(3000);
    l_param_list     WF_PARAMETER_LIST_T ;

    l_org_id         NUMBER;
    l_item_id        NUMBER;
    l_catalog_id     NUMBER;
    l_category_id    NUMBER;

    l_debug_file_dir    VARCHAR2(512);
    l_log_file          VARCHAR2(240);
    l_log_return_status VARCHAR2(1);
    l_errbuff           VARCHAR2(3000);
    l_error             VARCHAR2(30);
    No_Event_Exception  EXCEPTION;

BEGIN

     IF (p_event IS NULL) THEN

     RAISE No_Event_Exception;

     END IF;

     l_event_name := p_event.getEventName();
     l_param_list := p_event.getparameterlist;



   -- Insert the Parameter Values into EGO_BUSINESS_EVENTS_TRACKING Table -----

   IF l_param_list IS NOT NULL THEN

        IF (l_event_name in ('oracle.apps.bom.structure.created', 'oracle.apps.bom.structure.modified',
            'oracle.apps.bom.structure.deleteSuccess','oracle.apps.bom.component.deleteSuccess')) THEN

            FOR i IN l_param_list.FIRST..l_param_list.LAST LOOP

                l_param_name  :=  l_param_list(i).getname;
                l_param_value :=  l_param_list(i).getvalue;

                IF    (l_param_name = 'PK1_VALUE') THEN
                     l_item_id := l_param_value;
                ELSIF (l_param_name = 'PK2_VALUE') THEN
                     l_org_id := l_param_value;
                END IF;

            END LOOP;

        ELSE

            FOR i IN l_param_list.FIRST..l_param_list.LAST LOOP

                l_param_name  :=  l_param_list(i).getname;
                l_param_value :=  l_param_list(i).getvalue;

                IF ((l_param_name = 'INVENTORY_ITEM_ID') OR (l_param_name = 'InventoryItemId') ) THEN
                   l_item_id := l_param_value;
                ELSIF ((l_param_name = 'ORGANIZATION_ID') OR (l_param_name = 'OrganizationId') ) THEN
                   l_org_id := l_param_value;
                ELSIF ((l_param_name = 'CATEGORY_SET_ID') OR (l_param_name = 'CATALOG_ID')) THEN
                   l_catalog_id := l_param_value;
                ELSIF (l_param_name = 'CATEGORY_ID') THEN
                   l_category_id := l_param_value;
                END IF;
           END LOOP;

        END IF;
   END IF;

      INSERT INTO EGO_BUSINESS_EVENTS_TRACKING (sequence_id, invoke_date, business_event_name, event_payload, inventory_item_id, organization_id, catalog_id, category_id)
      VALUES (EGO_EVENT_SEQ.nextval,sysdate,l_event_name,p_event,l_item_id,l_org_id,l_catalog_id,l_category_id);

      COMMIT;

      RETURN 'SUCCESS';

   EXCEPTION

   WHEN No_Event_Exception THEN

   RETURN 'ERROR: WF_EVENT_MSG IS NULL';

   WHEN OTHERS THEN
     l_error := SQLERRM;
     l_err_text := 'Error : '||TO_CHAR(SQLCODE)||'---'||l_error;
    -- Error_Handler.Add_Error_Message( p_message_text => l_err_text, p_message_type => 'E');
   --  Error_Handler.Close_Debug_Session;
    RETURN l_error;

END EGO_LOG_EVENT;

END EGO_TRACK_EVENTS_PKG;

/
