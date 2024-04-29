--------------------------------------------------------
--  DDL for Package Body WS_SAMPLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WS_SAMPLES" as
-- $Header: wssmplb.pls 115.0 2003/10/16 21:53:37 jjxie noship $

--
-- generate (PUBLIC)
--   Sample Web Services generate function to procedure outbound
--   XML document
-- IN:
--   p_event_name     - Event to be processes
--   p_event_key      - Event key
--   p_parameter_list - parameter list
-- OUT
--   CLOB	    - Event data
--

function generate
		(
		p_event_name	    	in	varchar2,
		p_event_key	    	in 	varchar2,
        	p_parameter_list 	in 	wf_parameter_list_t
		) return CLOB
is

  p_xmldoc		clob;
  i_xmldoc              varchar2(4000);

begin

  dbms_lob.createtemporary(p_xmldoc,true,dbms_lob.session);
  i_xmldoc := '<s0:AnnouncementDate>11/11/2003</s0:AnnouncementDate>';
  dbms_lob.write(p_xmldoc, 53, 1, i_xmldoc);
  --dbms_lob.freetemporary(p_xmldoc);

  return p_xmldoc;

exception

  when others then
    wf_core.context('WS_SAMPLES', 'Generate', p_event_name, p_event_key);
    raise;

end generate;


end WS_SAMPLES;

/
