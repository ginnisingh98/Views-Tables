--------------------------------------------------------
--  DDL for Package Body WF_OAM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_OAM_UTIL" as
/* $Header: WFOAMUTB.pls 120.3 2005/07/02 03:16:33 appldev noship $ */

--
-- getWfEventTParameters
--   To convert the the parameter list in WF_EVENT_T to
--   string

FUNCTION getWfEventTParameters(l_paramlist in wf_parameter_list_t)
RETURN VARCHAR2
IS
 l_parmlist_t            wf_parameter_list_t;
 l_parameters            varchar2(4000);
 i                       binary_integer;
begin
 l_parmlist_t := l_paramlist;
 if (l_parmlist_t is not null) then
        i := l_parmlist_t.FIRST;
        while (i <= l_parmlist_t.LAST) loop
          l_parameters := l_parameters||l_parmlist_t(i).getName()||'='||
                        l_parmlist_t(i).getValue()||' ';
          i := l_parmlist_t.NEXT(i);
        end loop;
      end if;
  return l_parameters;
end getWfEventTParameters;

--
-- getWfEventT
--   Function wrapper around wf_event_ojmstext_qh.deserialize
--

FUNCTION getWfEventT(l_aq_jms_text in sys.aq$_jms_text_message)
RETURN WF_EVENT_T
IS
l_wf_event_t     wf_event_t;
l_jms            sys.aq$_jms_text_message;
begin
 l_jms := l_aq_jms_text;
 wf_event_ojmstext_qh.deserialize(l_jms,l_wf_event_t);
 return l_wf_event_t;
end getWfEventT;

--
-- getViewXMLURL
--    To get the URL for viewing XML given item type, item key and
--    event attribute
FUNCTION  getViewXMLURL(p_eventattribute  in      varchar2,
                        p_itemtype        in      varchar2,
                        p_itemkey        in      varchar2,
			p_mimetype       in      varchar2 default 'text/xml')
RETURN VARCHAR2
IS
  l_url varchar2(4000);
  l_fnctname varchar2(500);
  l_params varchar2(1000);
begin

  l_fnctname := 'OAM_WF_VIEW_XML';

  l_params := 'eventattr='||p_eventattribute||
              '&'||'itemtype='||p_itemtype||
	      '&'||'itemkey='||p_itemkey||
	      '&'||'mime='||p_mimetype||
	      '&'||'source='||'ITEMDATA';

  l_url := fnd_run_function.get_run_function_url( p_function_name => l_fnctname,
                                p_resp_appl => null,
                                p_resp_key => null,
                                p_security_group_key => null,
                                p_parameters => l_params);

 return l_url;
end getViewXMLURL;

--
-- getViewXMLURL
--    To get the URL for viewing XML given message id and queue table
FUNCTION  getViewXMLURL(p_message_id   in  varchar2,
                        p_queue_table  in  varchar2,
			p_mimetype       in      varchar2 default 'text/xml')
RETURN VARCHAR2
IS
  l_url varchar2(4000);
  l_fnctname varchar2(500);
  l_qtable varchar2(30);
  l_msgid varchar2(500);
  l_type  varchar2(30);
  l_params varchar2(1000);
  l_owner varchar2(30);
  l_queue_table varchar2(30);
  l_dummy number;

begin
  l_fnctname := 'OAM_WF_VIEW_XML';

  -- Validate the Queue Table
  if (instr(p_queue_table, '.', 1) > 0) then
     l_owner := substr(p_queue_table, 1, instr(p_queue_table, '.', 1)-1);
     l_queue_table := substr(p_queue_table, instr(p_queue_table, '.', 1)+1);
  else
     l_owner := Wf_Core.Translate('WF_SCHEMA');
     l_queue_table := p_queue_table;
  end if;

  begin
     SELECT 1
     INTO   l_dummy
     FROM   all_queue_tables
     WHERE  owner = l_owner
     AND    queue_table = l_queue_table
     AND    rownum = 1;
  exception
     when no_data_found then
        -- mostly no_data_found error
        Wf_Core.Token('OWNER', l_owner);
        Wf_Core.Token('QUEUE', l_queue_table);
        Wf_Core.Raise('WFE_QUEUE_NOTEXIST');
  end;

  l_params := 'id='||p_message_id||
              '&'||'qtable='||p_queue_table||
	      '&'||'mime='||p_mimetype||
	      '&'||'source='||'MSGDATA';

  l_url := fnd_run_function.get_run_function_url( p_function_name => l_fnctname,
                                p_resp_appl => null,
                                p_resp_key => null,
                                p_security_group_key => null,
                                p_parameters => l_params);

 return l_url;
end getViewXMLURL;

--
--getEventData
--    To get the CLOB Eventdata  given item type, item key and
--    event attribute
FUNCTION getEventData(p_eventattribute  in    varchar2,
                      p_itemtype        in    varchar2,
                      p_itemkey        in     varchar2)
RETURN clob
IS
  l_event_t               wf_event_t;
  l_eventdata             clob;
begin

  l_event_t := wf_engine.GetItemAttrEvent(
                                itemtype        => P_ItemType,
                                itemkey         => P_ItemKey,
                                name            => P_EventAttribute);
  l_eventdata := l_event_t.GetEventData();

  return l_eventdata;
end getEventData;

--
--getEventData
--    To get the CLOB Eventdata  given message id and queue table
FUNCTION getEventData(p_message_id   in  varchar2,
                      p_queue_table  in  varchar2)
RETURN clob
IS
  TYPE queue_contents_t IS REF CURSOR;
  l_qcontents             queue_contents_t;
  l_sqlstmt               varchar2(32000);
  l_message               wf_event_t;
  l_eventdata             clob;
begin

  -- Get the Clob
  l_sqlstmt := 'SELECT user_data FROM '||p_queue_table
                ||' WHERE MSGID = :b';

  OPEN l_qcontents FOR l_sqlstmt USING p_message_id;
  LOOP
  FETCH l_qcontents INTO l_message;
    l_eventdata  := l_message.GetEventData();
  EXIT WHEN l_qcontents%NOTFOUND;

  END LOOP;

  return l_eventdata;
end getEventData;

END WF_OAM_UTIL;

/
