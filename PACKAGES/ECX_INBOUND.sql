--------------------------------------------------------
--  DDL for Package ECX_INBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_INBOUND" AUTHID CURRENT_USER as
-- $Header: ECXINBS.pls 115.9 2003/08/12 20:42:28 mtai ship $

   TYPE node_info_record is RECORD
   (
   siblings            pls_integer,
   parent_node_id      pls_integer,
   parent_node_pos     pls_integer,
   parent_node_map_id  pls_integer,
   occur               pls_integer,
   pre_child_name      Varchar2(80));

   TYPE node_info_tbl is table of node_info_record index by BINARY_INTEGER;

   procedure process_xml_doc (
      p_doc           IN         xmldom.DOMDocument,
      p_map_id        IN         pls_integer,
      p_snd_tp_id     IN         pls_integer,
      p_rec_tp_id     IN         pls_integer,
      x_xmlclob       OUT NOCOPY clob,
      x_parseXML      OUT NOCOPY boolean
      );

   procedure process_data (
      i               IN      pls_integer,
      i_stage         IN      pls_integer ,
      i_next          IN      pls_integer
      );

   procedure structurePrintingSetup (
      i_root_name     IN OUT  NOCOPY varchar2
      );

   procedure getXMLDoc;

END ecx_inbound;

 

/
