--------------------------------------------------------
--  DDL for Package WF_EVENT_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT_XML" AUTHID CURRENT_USER as
/* $Header: wfevxmls.pls 120.1 2005/07/02 03:48:22 appldev ship $ */
-----------------------------------------------------------------------------
masterTagName varchar2(256) := 'WF_TABLE_DATA';
versionTagName varchar2(256) := 'VERSION';

function findTable(x_message in varchar2, p_tablename in varchar2)
                return xmldom.DOMNodeList;

function newTag (p_doc in xmldom.DOMDocument,
                    p_node in xmldom.DOMNode,
                    p_tag in varchar2,
                    p_data in varchar2 default NULL) return xmldom.DOMNode;

procedure printElements(doc xmldom.DOMDocument);

Function XMLversion return varchar2;


end WF_EVENT_XML;

 

/
