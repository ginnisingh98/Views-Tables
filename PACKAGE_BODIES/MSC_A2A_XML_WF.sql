--------------------------------------------------------
--  DDL for Package Body MSC_A2A_XML_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_A2A_XML_WF" as
/* $Header: MSCXMLWB.pls 120.0.12010000.3 2009/07/01 09:36:55 nyellank ship $*/

v_parameter_list wf_parameter_list_t;


  -- =========== Private Functions =============

   PROCEDURE LOG_MESSAGE( pBUFF  IN  VARCHAR2)
   IS
   BEGIN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         null;
         --DBMS_OUTPUT.PUT_LINE( pBUFF);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
   END LOG_MESSAGE;

   PROCEDURE SEND_XML (p_map_code    IN VARCHAR2,
                       p_instance_id IN NUMBER,
                       p_document_id IN VARCHAR2 DEFAULT NULL,
                       p_parameter1  IN VARCHAR2 DEFAULT NULL,
                       p_parameter2  IN VARCHAR2 DEFAULT NULL,
                       p_parameter3  IN VARCHAR2 DEFAULT NULL,
                       p_parameter4  IN VARCHAR2 DEFAULT NULL,
                       p_parameter5  IN VARCHAR2 DEFAULT NULL) IS
   TYPE CurTyp IS REF CURSOR;
   c_instance          CurTyp;
   c_info              CurTyp;

   lv_msgid            RAW(100);
   lv_instance_code    VARCHAR2(10):='';
   lv_debug_mode       PLS_INTEGER := 0;
   lv_username         VARCHAR2(512);
   lv_password         VARCHAR2(500);
   lv_protocol_type    VARCHAR2(30);
   lv_protocol_address VARCHAR2(512);
   l_parameter_list             wf_parameter_list_t; -- for raising event

   BEGIN

      -- get the instance code
       OPEN c_instance FOR
                ' select instance_code from msc_apps_instances mai '
              ||' where mai.instance_id = :instance_id' USING p_instance_id;

       LOOP

          FETCH c_instance into lv_instance_code;

          EXIT WHEN c_instance%NOTFOUND;

      -- get the username, password, protocol type and address
           OPEN c_info FOR
                 ' select usr.username, usr.password,'
               ||' hub.protocol_type, hub.protocol_address  '
               ||' FROM ecx_hubs hub, ecx_hub_users usr '
               ||' where hub.hub_id = usr.hub_id '
               ||' and usr.hub_entity_code = :instance_code ' USING lv_instance_code;
           FETCH c_info into lv_username, lv_password, lv_protocol_type, lv_protocol_address;
           CLOSE c_info;


      --  if no record found default protocol address to Instance Code and type to 'NONE'
            IF lv_protocol_type IS NULL THEN
               lv_protocol_type:= 'NONE';
            END IF;
            IF lv_protocol_address IS NULL THEN
               lv_protocol_address := lv_instance_code;
            END IF;

      --  get the debug level. If MRP: Debug Mode is yes, set it to 3
             IF FND_PROFILE.VALUE('MRP_DEBUG') = 'Y' THEN
                 lv_debug_mode := 3;
             ELSE
                 lv_debug_mode := 0;
             END IF;
      -- Initialize the ecx_utils.i_ret_code and i_errbuf variables;
             ecx_utils.i_ret_code :=0;
             ecx_utils.i_errbuf := null;

      --  send the message to the queue
                        ECX_OUTBOUND.putmsg (
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                p_document_id,
                                p_parameter1,
                                p_parameter2,
                                p_parameter3,
                                p_parameter4,
                                p_parameter5,
                                p_map_code,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                lv_protocol_type,
                                lv_protocol_address,
                                lv_username,
                                lv_password,
                                NULL,
                                NULL,
                                NULL,
                                p_map_code,
                                NULL,
                                lv_debug_mode,
                                NULL,
                                lv_msgid
                                );

          CLOSE c_instance;

      END LOOP;

-- Raise Event to which system integrators can subscribe to annd launch their workflows
-- after the message has been queued in the outbound queue

         wf_event.AddParameterToList(p_name=>'p_map_code',
                                     p_value=> 'MSC_PLANSCHDO_OAG71_OUT',
                                     p_parameterlist=>l_parameter_list);

         wf_event.raise( p_event_name => 'oracle.apps.msc.ascp.out',
                         p_event_key => to_char(sysdate,'YYYYMMDD HH24MISS'),
                         p_parameters => l_parameter_list);

         l_parameter_list.DELETE;

         -- dbms_output.put_line('SEND_XML complete ');
   EXCEPTION
   when others then
     log_message ('Error in SEND_XML: '||substr(SQLERRM,1,240));
   END SEND_XML;


-- public procedures -----------------
PROCEDURE PURGE_INTERFACE(p_map_code IN VARCHAR2, p_unique_id IN NUMBER) IS
BEGIN

IF p_map_code = 'MSC_POO_OAG71_OUT' THEN
        DELETE MSC_PO_RESCHEDULE_INTERFACE
        WHERE  purchase_order_id = p_unique_id;

ELSIF p_map_code = 'MSC_REQUISITNO_OAG71_OUT' THEN
        DELETE MSC_PO_REQUISITIONS_INTERFACE
        WHERE  source_line_id = p_unique_id;

ELSIF p_map_code = 'MSC_PRODORDERO_OAG71_OUT' THEN
        DELETE MSC_WIP_JOB_SCHEDULE_INTERFACE
        WHERE  source_line_id = p_unique_id;

        DELETE MSC_WIP_JOB_DTLS_INTERFACE
        WHERE  parent_header_id = p_unique_id;

ELSIF p_map_code = 'MSC_PRODORDERC_OAG71_OUT' THEN
        DELETE MSC_WIP_JOB_SCHEDULE_INTERFACE
        WHERE  source_line_id = p_unique_id;

        DELETE MSC_WIP_JOB_DTLS_INTERFACE
        WHERE  parent_header_id = p_unique_id;

END IF;

END;

PROCEDURE RESCHEDULE_PO(p_map_code IN VARCHAR2 DEFAULT 'MSC_POO_OAG71_OUT', p_instance_id IN NUMBER, p_purchase_order_id IN NUMBER) IS

BEGIN

  SEND_XML (p_map_code , p_instance_id, NULL, p_instance_id, p_purchase_order_id);
  IF  ecx_utils.i_ret_code = 0 THEN
  null;
        IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
          PURGE_INTERFACE(p_map_code , p_purchase_order_id);
        END IF;
  END IF;

end RESCHEDULE_PO;


PROCEDURE CREATE_REQ(p_map_code IN VARCHAR2 DEFAULT 'MSC_REQUISITNO_OAG71_OUT', p_source_line_id IN NUMBER,  p_instance_id IN NUMBER) IS

BEGIN

  SEND_XML (p_map_code , p_instance_id, p_source_line_id, p_instance_id );
  IF  ecx_utils.i_ret_code = 0 THEN
  null;

        IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
          PURGE_INTERFACE(p_map_code , p_source_line_id );
        END IF;
  END IF;


end CREATE_REQ;


PROCEDURE SYNC_WORK_ORDER(p_map_code IN VARCHAR2 DEFAULT 'MSC_PRODORDERO_OAG71_OUT', p_source_line_id IN NUMBER, p_instance_id IN NUMBER) IS

BEGIN

  SEND_XML (p_map_code , p_instance_id, p_source_line_id, p_instance_id );
  IF  ecx_utils.i_ret_code = 0 THEN
  null;
         IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
          PURGE_INTERFACE(p_map_code , p_source_line_id );
       END IF;
  END IF;


end SYNC_WORK_ORDER;

PROCEDURE CREATE_WORK_ORDER(p_map_code IN VARCHAR2 DEFAULT 'MSC_PRODORDERC_OAG71_OUT', p_source_line_id IN NUMBER, p_instance_id IN NUMBER) IS

BEGIN

  SEND_XML (p_map_code , p_instance_id, p_source_line_id, p_instance_id );
  IF  ecx_utils.i_ret_code = 0 THEN
  null;
           IF fnd_profile.value('MSC_RETAIN_RELEASED_DATA') ='N' THEN
             PURGE_INTERFACE(p_map_code , p_source_line_id );
         END IF;
  END IF;


end CREATE_WORK_ORDER;


PROCEDURE PUSH_PLAN_OUTPUT (p_map_code IN VARCHAR2 DEFAULT 'MSC_PLANSCHDO_OAG71_OUT', p_compile_designator IN VARCHAR2, p_instance_id IN NUMBER, p_buy_items_only IN NUMBER) IS

BEGIN

  SEND_XML (p_map_code , p_instance_id, p_compile_designator, p_instance_id ,p_buy_items_only);

end PUSH_PLAN_OUTPUT;

PROCEDURE LEGACY_RELEASE ( p_instance_id IN NUMBER) IS
        TYPE cur IS REF CURSOR;
        c_cur   cur;
        lv_unique_id     number;

BEGIN

-- reschedule POs

     OPEN c_cur FOR
           'select distinct purchase_order_id from msc_po_reschedule_interface '
         ||' where sr_instance_id = :instance_id' USING p_instance_id;

     LOOP

        FETCH c_cur INTO lv_unique_id;

        EXIT WHEN c_cur%NOTFOUND;

        RESCHEDULE_PO(p_map_code =>'MSC_POO_OAG71_OUT',
                      p_instance_id => p_instance_id,
                      p_purchase_order_id =>lv_unique_id );

     END LOOP;

     CLOSE c_cur;

-- Create Reqs

     OPEN c_cur FOR
           'select distinct source_line_id from msc_po_requisitions_interface '
         ||' where sr_instance_id = :instance_id' USING p_instance_id;

     LOOP

        FETCH c_cur INTO lv_unique_id;

        EXIT WHEN c_cur%NOTFOUND;

        CREATE_REQ(p_map_code =>'MSC_REQUISITNO_OAG71_OUT',
                      p_source_line_id =>lv_unique_id,
                      p_instance_id => p_instance_id);

     END LOOP;

     CLOSE c_cur;

-- Sync Work Orders

     OPEN c_cur FOR
           'select distinct source_line_id from msc_wip_job_schedule_interface '
         ||' where sr_instance_id = :instance_id'
         ||' and load_type in (3,6)' USING p_instance_id;

     LOOP

        FETCH c_cur INTO lv_unique_id;

        EXIT WHEN c_cur%NOTFOUND;

        SYNC_WORK_ORDER(p_map_code =>'MSC_PRODORDERO_OAG71_OUT',
                      p_source_line_id =>lv_unique_id,
                      p_instance_id => p_instance_id);

     END LOOP;

     CLOSE c_cur;

-- Create Work Orders

     OPEN c_cur FOR
           'select distinct source_line_id from msc_wip_job_schedule_interface '
         ||' where sr_instance_id = :instance_id '
         ||' and load_type not in (3,6)' USING p_instance_id;

     LOOP

        FETCH c_cur INTO lv_unique_id;

        EXIT WHEN c_cur%NOTFOUND;

        CREATE_WORK_ORDER(p_map_code =>'MSC_PRODORDERC_OAG71_OUT',
                      p_source_line_id =>lv_unique_id,
                      p_instance_id => p_instance_id);

     END LOOP;

     CLOSE c_cur;

end LEGACY_RELEASE;

end MSC_A2A_XML_WF;

/
