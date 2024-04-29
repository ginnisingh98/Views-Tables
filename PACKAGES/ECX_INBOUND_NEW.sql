--------------------------------------------------------
--  DDL for Package ECX_INBOUND_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_INBOUND_NEW" AUTHID CURRENT_USER as
-- $Header: ECXINNS.pls 120.1.12000000.1 2007/01/16 06:11:15 appldev ship $

   PROCESS_LEVEL_EXCEPTION   pls_integer := 1;
   SQL_EXCEPTION             pls_integer := 2;
   SAX_EXCEPTION             pls_integer := 3;
   XML_PARSE_EXCEPTION       pls_integer := 4;
   IO_EXCEPTION              pls_integer := 5;
   OTHER_EXCEPTION           pls_integer := 6;

   TYPE node_info_record is RECORD
   (
   parent_node_id        pls_integer,
   parent_node_pos       pls_integer,
   parent_xml_node_indx  number,
   occur                 pls_integer,
   pre_child_name        Varchar2(80));

   TYPE node_info_table is table of node_info_record index by BINARY_INTEGER;


   function LoadXML (
      p_debugLevel       IN         number,
      p_payload          IN         clob,
      p_map_code         IN         varchar2,
      x_err_code         OUT NOCOPY number
   ) return varchar2;

   procedure startDocument;


   procedure endDocument(
      x_xmlclob   OUT NOCOPY clob,
      x_parseXML  OUT NOCOPY boolean);


   procedure processLevel(
      p_nodeList       IN         ECX_NODE_TBL_TYPE,
      p_level          IN         pls_integer,
      p_next           IN         pls_integer,
      p_count          IN         pls_integer,
      x_err_msg        OUT NOCOPY varchar2
   );


   procedure process_xml_doc (
      p_payload          IN         clob,
      p_map_id           IN         pls_integer,
      x_xmlclob          OUT NOCOPY clob,
      x_parseXML         OUT NOCOPY boolean
   );

END ecx_inbound_new;

 

/
