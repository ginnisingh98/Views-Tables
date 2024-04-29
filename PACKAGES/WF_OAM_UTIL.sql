--------------------------------------------------------
--  DDL for Package WF_OAM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_OAM_UTIL" AUTHID CURRENT_USER as
/* $Header: WFOAMUTS.pls 115.3 2004/05/19 13:20:19 grengara noship $ */

--
-- getWfEventTParameters
--   To convert the the parameter list in WF_EVENT_T to
--   string
FUNCTION getWfEventTParameters(l_paramlist in wf_parameter_list_t)
RETURN VARCHAR2;

--
-- getWfEventT
--   Function wrapper around wf_event_ojmstext_qh.deserialize
--
FUNCTION getWfEventT(l_aq_jms_text in sys.aq$_jms_text_message)
RETURN WF_EVENT_T;

--
-- getViewXMLURL
--    To get the URL for viewing XML given item type, item key and
--    event attribute
FUNCTION  getViewXMLURL(p_eventattribute  in      varchar2,
                        p_itemtype        in      varchar2,
                        p_itemkey        in      varchar2,
			p_mimetype       in      varchar2 default 'text/xml')
RETURN VARCHAR2;

--
-- getViewXMLURL
--    To get the URL for viewing XML given message id and queue table
FUNCTION  getViewXMLURL(p_message_id   in  varchar2,
                        p_queue_table  in  varchar2,
			p_mimetype     in  varchar2 default 'text/xml')
RETURN VARCHAR2;

--
--getEventData
--    To get the CLOB Eventdata  given item type, item key and
--    event attribute
FUNCTION getEventData(p_eventattribute  in      varchar2,
                      p_itemtype        in      varchar2,
                      p_itemkey        in      varchar2)
RETURN clob;

--
--getEventData
--    To get the CLOB Eventdata  given message id and queue table
FUNCTION getEventData(p_message_id   in  varchar2,
                      p_queue_table  in  varchar2)
RETURN clob;

END WF_OAM_UTIL;


 

/
