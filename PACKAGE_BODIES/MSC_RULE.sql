--------------------------------------------------------
--  DDL for Package Body MSC_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_RULE" as
-- $Header: MSCRULEB.pls 120.1 2005/06/21 01:54:36 appldev ship $
--
-- Inbound_Rule (PUBLIC)
--   Standard XML Gateway Subscription rule function
-- IN:
--   p_subscription_guid - GUID of Subscription to be processed
--   p_event             - Event to be processes
-- NOTE: Determines the Inbound Transaction Queue
--
-- Standard INBOUND_RULE function

FUNCTION INBOUND_RULE( p_subscription_guid  in      raw,
	               p_event	            in out nocopy wf_event_t ) return varchar2
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  attribute4            varchar2(1000);
  i_queue_name		varchar2(2000);
  v_ect_inengobj        system.ecx_inengobj;
  v_enqueueoptions      dbms_aq.enqueue_options_t;
  v_messageproperties   dbms_aq.message_properties_t;
  v_msgid               raw(16);
  v_msgid_out           raw(16);
  i_trigger_id          number;
  debug_level           pls_integer;
  i_payload             clob;

  retcode                 pls_integer;
  errmsg                  varchar2(2000);
  logfile                 varchar2(200);
  i_outpayload            CLOB;

  EX_NOT_MSC            EXCEPTION;

BEGIN

  v_msgid := p_event.getValueForParameter('ECX_MSGID');
  i_trigger_id := p_event.getValueForParameter('ECX_TRIGGER_ID');

  wf_log_pkg.string(6,'inbound_rule','MsgId '|| v_msgid);
  wf_log_pkg.string(6,'inbound_rule','TriggerId '|| i_trigger_id);

  ecx_errorlog.inbound_trigger( i_trigger_id,
                                 v_msgid,
                                 null,
                                 '10',
                                 'Processing rule...');

  -- Get the data from the Event

  attribute4 := p_event.getValueForParameter('ECX_ATTRIBUTE4');

  -- get out if this is not a MSC message
  IF substr(upper(nvl(attribute4,'XYZ')),1,3) <> 'MSC' THEN RAISE EX_NOT_MSC; END IF;

  debug_level := p_event.getValueForParameter('ECX_DEBUG_LEVEL');
  i_payload := p_event.event_data;

  wf_log_pkg.string(6,'inbound_rule','Attribute4 ' || attribute4);
  wf_log_pkg.string(6,'inbound_rule','Debug Mode ' || debug_level);

  ecx_inbound_trig.ProcessXML
                ( attribute4,
                i_payload,
                debug_level,
                retcode,
                errmsg,
                logfile,
                i_outpayload);
  COMMIT;

  IF retcode = 0 THEN
        return  'SUCCESS';
  ELSIF retcode = 1 THEN
        wf_core.token('ECX_ERRMSG',errmsg);
        wf_core.token('ECX_LOGFILE',logfile);
        wf_core.raise('ECX_PROCESS_XMLERROR');
  ELSE
        wf_core.token('ECX_ERRMSG',errmsg);
        wf_core.token('ECX_LOGFILE',logfile);
        wf_core.raise('ECX_PROGRAM_EXIT');
  END IF;

  ecx_errorlog.inbound_trigger( i_trigger_id,
                                v_msgid,
                                v_msgid_out,
                                '10',
                                'Processing message...');

  wf_log_pkg.string(6,'inbound_rule','Processed successfully.');

  RETURN 'SUCCESS';

EXCEPTION
  WHEN EX_NOT_MSC THEN
        RETURN 'SUCCESS';
  WHEN OTHERS THEN
	RETURN 'ERROR';
END INBOUND_RULE;

END MSC_RULE;

/
