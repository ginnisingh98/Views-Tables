--------------------------------------------------------
--  DDL for Package Body WF_WS_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_WS_RULE" as
-- $Header: wfwsruleb.pls 120.1 2006/09/08 11:10:49 kjayapra noship $

--
-- log_outbound (PUBLIC)
--   Rule function for logging.  Used with the following events:
--       oracle.apps.fnd.wf.ws.outbound.log
-- IN:
--   p_subscription_guid - subscription guid
-- IN/OUT:
--   p_event             - incoming log event

function log_outbound
    (p_subscription_guid  in      raw,
     p_event              in out  NOCOPY WF_EVENT_T) return varchar2
is

  msgid			raw(200);
  receipt_msgid         raw(200);
  status 		binary_integer;
  log_msg               varchar2(4000);
  err_msg		varchar2(2000);
  err_params            varchar2(2000);
  timestampstring       varchar2(50);
  timestamp             date;
  ret_code		pls_integer;
  ret_message		varchar2(4000);

begin
  msgid := p_event.GetValueForParameter('SENDER_MSGID');
  receipt_msgid := p_event.GetValueForParameter('RECEIPT_MSGID');
  err_msg := p_event.GetValueForParameter('ERROR_MESSAGE');
  err_params := '';
  if(receipt_msgid is not null) then
    err_params := err_params || 'msgid=' || receipt_msgid || '#WF#';
  end if;
  if(err_msg is not null) then
    err_params := err_params || 'ErrMsg=' || err_msg || '#WF#';
  end if;
  status := 2;
  if (p_event.GetValueForParameter('STATUS') = 'SUCCESS') then
    status := 0;
  end if;

  log_msg := p_event.GetValueForParameter('LOG_MESSAGE');

  timestampstring := p_event.GetValueForParameter('TIMESTAMP');

  begin
    timestamp := to_date(timestampstring, 'YYYY/MM/DD HH24:MI:SS');
  exception when others then
    timestamp := sysdate;
  end;

  ecx_errorlog.external_system(msgid, status, log_msg, timestamp, ret_code, ret_message, err_params);

  return 'SUCCESS';
exception
         when others then
            WF_CORE.CONTEXT('WS_RULE', 'LOG',
                            p_event.getEventName( ), p_subscription_guid);
            WF_EVENT.setErrorInfo(p_event, 'ERROR');
            return 'ERROR';
end log_outbound;



--
-- log_inbound (PUBLIC)
--   Rule function for logging.  Used with the following events:
--       oracle.apps.fnd.wf.ws.inbound.log
-- IN:
--   p_subscription_guid - subscription guid
-- IN/OUT:
--   p_event             - incoming log event

function log_inbound
    (p_subscription_guid  in      raw,
     p_event              in out  NOCOPY WF_EVENT_T) return varchar2
is

  status 		varchar2(50);
  err_msg		varchar2(4000);
  err_params            varchar2(255);
  trigger_id            number;
  receipt_msgid         raw(200);

  message_type          varchar2(2000) := null;
  message_standard      varchar2(2000) := null;
  transaction_type      varchar2(2000) := null;
  transaction_subtype   varchar2(2000) := null;
  document_number       varchar2(2000) := null;
  partyid               varchar2(2000) := null;
  party_site_id         varchar2(2000) := null;
  party_type            varchar2(2000) := null;
  protocol_type         varchar2(2000) := null;
  protocol_address      varchar2(2000) := null;
  username              varchar2(2000) := null;
  encrypt_password      varchar2(2000) := null;
  attribute1            varchar2(2000) := null;
  attribute2            varchar2(2000) := null;
  attribute3            varchar2(2000) := null;
  attribute4            varchar2(2000) := null;
  attribute5            varchar2(2000) := null;
  payload               clob := null;
  l_retcode             pls_integer := 0;
  l_retmsg              varchar2(2000) := null;
  returnval	        varchar2(2000);
begin

  if (WF_EVENT_FUNCTIONS_PKG.SubParamInEvent(p_subscription_guid, p_event))
  then
   status := p_event.GetValueForParameter('STATUS');
   err_msg := p_event.GetValueForParameter('LOG_MESSAGE');
   err_params := 'msgid=' || p_event.GetValueForParameter('RECEIPT_MSGID') || '#WF#';
   trigger_id := p_event.GetValueForParameter('ECX_TRIGGER_ID');
   receipt_msgid := p_event.GetValueForParameter('RECEIPT_MSGID');
   message_type := p_event.GetValueForParameter('ECX_MESSAGE_TYPE');
   message_standard := p_event.GetValueForParameter('ECX_MESSAGE_STANDARD');
   transaction_type := p_event.GetValueForParameter('ECX_TRANSACTION_TYPE');
   transaction_subtype := p_event.GetValueForParameter('ECX_TRANSACTION_SUBTYPE');
   document_number := p_event.GetValueForParameter('ECX_DOCUMENT_NUMBER');
   partyid := p_event.GetValueForParameter('ECX_PARTY_ID');
   party_site_id := p_event.GetValueForParameter('ECX_PARTY_SITE_ID');
   party_type := p_event.GetValueForParameter('ECX_PARTY_TYPE');
   protocol_type := p_event.GetValueForParameter('ECX_PROTOCOL_TYPE');
   protocol_address := p_event.GetValueForParameter('ECX_PROTOCOL_ADDRESS');
   username := p_event.GetValueForParameter('ECX_USERNAME');
   encrypt_password := p_event.GetValueForParameter('ECX_PASSWORD');
   attribute1 := p_event.GetValueForParameter('ECX_ATTRIBUTE1');
   attribute2 := p_event.GetValueForParameter('ECX_ATTRIBUTE2');
   attribute3 := p_event.GetValueForParameter('ECX_ATTRIBUTE3');
   attribute4 := p_event.GetValueForParameter('ECX_ATTRIBUTE4');
   attribute5 := p_event.GetValueForParameter('ECX_ATTRIBUTE5');
   payload := p_event.GetEventData();

   ECX_ERRORLOG.log_receivemessage (
                        'WEBSERVICE',
		        status,
                        err_msg,
                        receipt_msgid,
                        trigger_id,
                        message_type,
                        message_standard,
			transaction_type,
			transaction_subtype,
			document_number,
			partyid,
			party_site_id,
			party_type,
			protocol_type,
			protocol_address,
			username,
			encrypt_password,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			payload,
			returnval);
  if (returnval <> 'SUCCESS') then
    WF_CORE.CONTEXT('WS_RULE', 'LOG',
                    p_event.getEventName( ), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    return 'ERROR';
  end if;
  end if;
  return 'SUCCESS';


exception
         when others then
            WF_CORE.CONTEXT('WS_RULE', 'LOG',
                            p_event.getEventName( ), p_subscription_guid);
            WF_EVENT.setErrorInfo(p_event, 'ERROR');
            return 'ERROR';
end log_inbound;


end WF_WS_RULE;

/
