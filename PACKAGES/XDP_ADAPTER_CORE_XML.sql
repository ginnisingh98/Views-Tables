--------------------------------------------------------
--  DDL for Package XDP_ADAPTER_CORE_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ADAPTER_CORE_XML" AUTHID CURRENT_USER AS
/* $Header: XDPACOXS.pls 120.2 2006/04/10 23:20:19 dputhiye noship $ */

g_new_line CONSTANT VARCHAR2(10) := convert(FND_GLOBAL.LOCAL_CHR(10),
        substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
        'WE8ISO8859P1')  ;

g_tab CONSTANT VARCHAR2(10) := convert(FND_GLOBAL.LOCAL_CHR(9),
        substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
        'WE8ISO8859P1')  ;

 pv_elemOperation varchar2(40) := 'OPERATION';
 pv_elemCommand varchar2(40) := 'COMMAND';
 pv_elemResp varchar2(40) := 'RESPONSE';

 pv_elemSendCmd varchar2(40) := 'CMD';
 pv_elemSendResp varchar2(40) := 'RESP';

 pv_elemAck varchar2(40) := 'ACK';
 pv_elemMoreFlag varchar2(40) := 'MORE_FLAG';
 pv_elemData varchar2(40) := 'DATA';
 pv_elemTimeout varchar2(40) := 'TIMEOUT';

 pv_elemStatus varchar2(40) := 'STATUS';
 pv_elemStatusSuccess varchar2(40) := 'SUCCESS';
 pv_elemStatusError varchar2(40) := 'ERROR';


-- Construct any Control XML
Function ConstructControlXML(p_Operation in varchar2,
			     p_OpData in varchar2 default null) return varchar2;

-- Construct the XML for a SEND Application Message
Function ConstructSendXML(p_Command in varchar2,
			  p_Response in varchar2) return varchar2;

-- Construct the Response XML string
Function ConstructRespXML(p_Status in varchar2,
			  p_RespData in varchar2 default null,
			  p_MoreFlag in varchar2 default 'N',
			  p_Timeout in number default null) return varchar2;

-- Return a particular tag value given a tag name from the XML
Function DecodeMessage (p_WhattoDecode in varchar2,
		        p_XMLMessage in varchar2) return varchar2;

END XDP_ADAPTER_CORE_XML;

 

/
