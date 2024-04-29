--------------------------------------------------------
--  DDL for Package Body WF_EVENT_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_XML" as
/* $Header: wfevxmlb.pls 120.1 2005/07/02 03:48:18 appldev ship $ */
-----------------------------------------------------------------------------
function findTable(x_message in varchar2, p_tablename in varchar2)
                return xmldom.DOMNodeList is
  l_parser         xmlparser.parser;
  l_doc            xmldom.DOMDocument;
  l_node_name      varchar2(255);
  l_node_list        xmldom.DOMNodeList;
  l_doc_node         xmldom.DOMNode;
  l_length           integer;
begin

  l_parser := xmlparser.newParser;

  -- CTILLEY bug 2708622
  xmlparser.setPreserveWhitespace(l_parser, false);

  -- Parse the message and the document
  xmlparser.ParseBuffer(l_parser, x_message);
  l_doc := xmlparser.getDocument(l_parser);

  /*
  ** Find The master node
  */
  l_node_list := xmldom.getElementsByTagName(l_doc,
                           wf_event_xml.masterTagName);
  l_length := xmldom.getLength(l_node_list);
  if l_length = 0 then
    Wf_Core.Token('REASON', 'Could not find XML base node ' ||
	wf_event_xml.masterTagName);
    Wf_Core.Raise('WFSQL_INTERNAL');
  end if;

  -- There should never be more than one on the list, so we want the first.
  l_doc_node := xmldom.item(l_node_list, 0);
  l_node_name := xmldom.getNodeName(l_doc_node);
  if l_node_name <> wf_event_xml.masterTagName then
    Wf_Core.Token('REASON', 'Could not find XML base node in list' ||
	wf_event_xml.masterTagName);
    Wf_Core.Raise('WFSQL_INTERNAL');
  end if;

  /*
  ** Find the table node
  */
  l_node_list := xmldom.getElementsByTagName(xmldom.makeElement(l_doc_node),
                 p_tablename);
  l_length := xmldom.getLength(l_node_list);
  if l_length = 0 then
    Wf_Core.Token('REASON', 'Could not find XML table node ' ||
	p_tablename);
    Wf_Core.Raise('WFSQL_INTERNAL');
  end if;

  -- There should never be more than one on the list, so we want the first.
  l_doc_node := xmldom.item(l_node_list, 0);
  l_node_name := xmldom.getNodeName(l_doc_node);
  if l_node_name <> p_tablename then
    Wf_Core.Token('REASON', 'Could not find XML table node in list' ||
       p_tablename);
    Wf_Core.Raise('WFSQL_INTERNAL');
  end if;

  l_node_list := xmldom.getChildNodes(l_doc_node);

  return l_node_list;
exception
  when others then
    wf_core.context('Wf_Event_XML', 'findTable', x_message);
    raise;

end findTable;

function newTag (p_doc in xmldom.DOMDocument,
                    p_node in xmldom.DOMNode,
                    p_tag in varchar2,
                    p_data in varchar2 default NULL) return xmldom.DOMNode is
      l_element xmldom.DOMElement;
      l_node xmldom.DOMNode;
      l_text xmldom.DOMText;
      l_text_node xmldom.DOMNode;

begin

      -- Create an instance of the node
      l_element := xmldom.createElement(p_doc, p_tag);
      l_node := xmldom.makeNode(l_element);

      if p_data is not null then
         -- Append the data to the node
         l_text := xmldom.createTextNode(p_doc, p_data);
         l_text_node := xmldom.makeNode(l_text);
         l_text_node := xmldom.appendChild(l_node, l_text_node);
      end if;

      -- Append the new TAG node to the parent.
      l_node := xmldom.appendChild(p_node, l_node);

      return l_node;

exception
      when xmldom.INDEX_SIZE_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.DOMSTRING_SIZE_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.HIERARCHY_REQUEST_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.WRONG_DOCUMENT_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.INVALID_CHARACTER_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.NO_DATA_ALLOWED_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.NO_MODIFICATION_ALLOWED_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.NOT_FOUND_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.NOT_SUPPORTED_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

      when xmldom.INUSE_ATTRIBUTE_ERR then
         wf_core.context('WF_EVENT_XML', 'NewTag', p_tag);
         raise;

end newTag;

-- For debugging only.
procedure printElements(doc xmldom.DOMDocument) is
   nl xmldom.DOMNodeList;
   len number;
   n xmldom.DOMNode;
begin
   -- get all elements
   nl := xmldom.getElementsByTagName(doc, '*');
   len := xmldom.getLength(nl);

   -- loop through elements
   -- ### uncomment this for debug purpose
   --    dbms_output.put('[');
   --    for i in 0..len-1 loop
   --       n := xmldom.item(nl, i);
   --       dbms_output.put(xmldom.getNodeName(n) || ', ');
   --    end loop;
   --    dbms_output.put_line(']');
end printElements;

/*get XML Parser version*/

Function XMLVersion
return varchar2
is language java name 'oracle.xml.parser.v2.XMLParser.getReleaseVersion() returns java.lang.String';


end WF_EVENT_XML;

/
