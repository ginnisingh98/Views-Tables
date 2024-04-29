--------------------------------------------------------
--  DDL for Package Body XDP_ADAPTER_CORE_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ADAPTER_CORE_XML" AS
/* $Header: XDPACOXB.pls 115.5 2002/05/14 13:22:05 pkm ship      $ */

-- Private PL/SQL routines

Function BuildAttrXML(p_FeAttributes XDP_TYPES.ORDER_PARAMETER_LIST)
	return varchar2;

Function ConstructXMLPair(p_Tag in varchar2,
			  p_Value in varchar2,
			  p_Level in number default 0) return varchar2;

-- End of Private Routines


-- Start of Public Routines

Function ConstructSendXML(p_Command in varchar2,
			  p_Response in varchar2) return varchar2
is
 SendXML varchar2(32767);
begin
	xnp_xml_utils.initialize_doc ;
	xnp_xml_utils.xml_decl ;
	xnp_xml_utils.begin_segment ( pv_elemCommand) ;

	xnp_xml_utils.write_element( pv_elemOperation, 'SEND');

	--xnp_xml_utils.write_element ( pv_elemSendCmd, xnp_xml_utils.convert(p_Command)) ;
	--xnp_xml_utils.write_element ( pv_elemSendResp, xnp_xml_utils.convert(p_Response)) ;
	xnp_xml_utils.write_element ( pv_elemSendCmd, p_Command);
	xnp_xml_utils.write_element ( pv_elemSendResp, p_Response);

	xnp_xml_utils.end_segment ( pv_elemCommand) ;

        xnp_xml_utils.get_document(SendXML) ;

	return (SendXML);
end ConstructSendXML;


Function ConstructControlXML(p_Operation in varchar2,
			     p_OpData in varchar2 default null) return varchar2
is
 ControlXML varchar2(32767);
begin
	xnp_xml_utils.initialize_doc ;
	xnp_xml_utils.xml_decl ;
	xnp_xml_utils.begin_segment ( pv_elemCommand) ;


	xnp_xml_utils.write_element( pv_elemOperation, xnp_xml_utils.convert(p_Operation));
	if p_OpData is not null then
--		xnp_xml_utils.write_element( pv_elemData, xnp_xml_utils.convert(p_OpData));
		xnp_xml_utils.write_element( pv_elemData,p_OpData);
	end if;

	xnp_xml_utils.end_segment ( pv_elemCommand) ;
        xnp_xml_utils.get_document(ControlXML) ;

	return (ControlXML);

end ConstructControlXML;


Function ConstructRespXML(p_Status in varchar2,
			  p_RespData in varchar2 default null,
			  p_MoreFlag in varchar2 default 'N',
			  p_Timeout in number default null) return varchar2
is

 RespXML varchar2(32767);
begin

	xnp_xml_utils.initialize_doc ;
	xnp_xml_utils.xml_decl ;
	xnp_xml_utils.begin_segment (pv_elemResp) ;

	xnp_xml_utils.write_element( pv_elemStatus, p_Status);
	xnp_xml_utils.write_element( pv_elemMoreFlag,p_MoreFlag);

	if p_RespData is not null then
		xnp_xml_utils.write_element( pv_elemData, xnp_xml_utils.convert(p_RespData));
	end if;

	if p_Timeout is not null then
		xnp_xml_utils.write_element( pv_elemTimeout, to_char(p_Timeout));
	end if;

	xnp_xml_utils.end_segment ( pv_elemResp) ;
        xnp_xml_utils.get_document(RespXML) ;

	return (RespXML);

end ConstructRespXML;


Function DecodeMessage (p_WhattoDecode in varchar2,
		        p_XMLMessage in varchar2) return varchar2
is
 AttrValue varchar2(32767);
begin
	xnp_xml_utils.decode(p_msg_text => p_XMLMessage,
			     p_tag => p_WhattoDecode,
			     x_value => AttrValue);

	return AttrValue;

end DecodeMessage;

Function BuildAttrXML(p_FeAttributes XDP_TYPES.ORDER_PARAMETER_LIST)
	return varchar2
is
 FeAttrXML varchar2(32767);
begin
 FeAttrXML := g_tab || '<ATTRIBUTES>';

	for i in 1..p_FeAttributes.COUNT loop
		FeAttrXML := FeAttrXML || g_new_line ||
				g_tab || g_tab || '<ATTR>' || g_new_line ||
			ConstructXMLPair(p_Tag => 'NAME',
					 p_Value => p_FeAttributes(i).parameter_name,
					 p_Level => 3);

		FeAttrXML := FeAttrXML || g_new_line ||
			ConstructXMLPair(p_Tag => 'VALUE',
					 p_Value => p_FeAttributes(i).parameter_value,
					 p_Level => 3);

		FeAttrXML := FeAttrXML || g_new_line || g_tab || g_tab || '</ATTR>';

	end loop;

	FeAttrXML := FeAttrXML || g_new_line || g_tab || '</ATTRIBUTES>';

	return (FeAttrXML);

end BuildAttrXML;

Function ConstructXMLPair(p_Tag in varchar2,
			  p_Value in varchar2,
			  p_Level in number default 0) return varchar2
is
 XMLString varchar2(32767);
 TabTagString varchar2(4000);
 TabValueString varchar2(4000) := g_tab;
begin

 for i in 1..p_Level loop
	TabTagString := TabTagString || g_tab;
	TabValueString := TabValueString || g_tab;
 end loop;

 XMLString :=
	TabTagString   || '<' || ConstructXMLPair.p_Tag || '>' || g_new_line ||
	TabValueString || ConstructXMLPair.p_Value || g_new_line ||
	TabTagString   || '</' || ConstructXMLPair.p_Tag || '>';

 return (XMLString);

end ConstructXMLPair;

end XDP_ADAPTER_CORE_XML;

/
