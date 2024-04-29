--------------------------------------------------------
--  DDL for Package Body OKC_XML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XML_PVT" AS
/* $Header: OKCRXMLB.pls 120.0 2005/05/26 09:50:40 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- TYPES
  ---------------------------------------------------------------------------
  -- CONSTANTS
  ---------------------------------------------------------------------------
  -- PUBLIC VARIABLES
  ---------------------------------------------------------------------------
  -- EXCEPTIONS
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE build_xml_clob (
    p_corrid_rec IN okc_aq_pvt.corrid_rec_typ,
    p_element_tbl   IN  okc_aq_pvt.msg_tab_typ,
    x_xml_clob      OUT NOCOPY  system.okc_aq_msg_typ
    )
IS
  l_element_name  varchar2(240);
  l_element_value varchar2(240);
  l_index         number := 1;
  l_xml_clob      system.okc_aq_msg_typ;
  l_constant      varchar2(32767) := '<?xml version="1.0" ?>';
  l_char_msg      varchar2(32767);
  l_dest_clob     system.okc_aq_msg_typ;
  l_amount        integer := 32767;
BEGIN
  -- create a temporary lob
  l_xml_clob := system.okc_aq_msg_typ(empty_clob());
  x_xml_clob := system.okc_aq_msg_typ(empty_clob());
  dbms_lob.createtemporary(l_xml_clob.body,TRUE,dbms_lob.session);
  dbms_lob.writeappend(l_xml_clob.body,length(l_constant),l_constant);

  -- load message body with message
  l_constant := '<!DOCTYPE ' ||
		p_corrid_rec.corrid ||
		' [<!ELEMENT ' ||
		p_corrid_rec.corrid ||
		'(';
  dbms_lob.writeappend ( l_xml_clob.body
                       , length(l_constant)
		       , l_constant);

  -- loop thro the records and build xml clob
  FOR counter IN 1..p_element_tbl.count LOOP
    l_element_name := p_element_tbl(l_index).element_name;
    l_constant := l_element_name||',';
    dbms_lob.writeappend(l_xml_clob.body,length(l_constant),l_constant);
    l_index := l_index + 1;
  END LOOP;
  l_index := 1;

  -- trim the trailing ',' from the clob
  dbms_lob.trim ( l_xml_clob.body
                , dbms_lob.getlength(l_xml_clob.body) - 1);
  l_constant := ')>';
  dbms_lob.writeappend(l_xml_clob.body,length(l_constant),l_constant);

  -- loop thro the records to add DTD
  FOR counter IN 1..p_element_tbl.count LOOP
    l_element_name := p_element_tbl(l_index).element_name;
    l_index := l_index + 1;
    l_constant := '<!ELEMENT '||l_element_name||'(#PCDATA)>';
    dbms_lob.writeappend(l_xml_clob.body,length(l_constant),l_constant);
  END LOOP;
    l_index := 1;
    l_constant := ']><'||p_corrid_rec.corrid||'>';
    dbms_lob.writeappend(l_xml_clob.body,length(l_constant),l_constant);

  -- loop thro the records to add the xml string
  FOR counter IN 1..p_element_tbl.count LOOP
    l_element_name := p_element_tbl(l_index).element_name;
    l_element_value := p_element_tbl(l_index).element_value;
    l_index := l_index + 1;
    l_constant := '<'||l_element_name||'>'||
		  l_element_value||'</'||l_element_name||'>';
    dbms_lob.writeappend(l_xml_clob.body,length(l_constant),l_constant);
  END LOOP;
  l_index := 1;
  l_constant := '</'||p_corrid_rec.corrid||'>';
  dbms_lob.writeappend ( l_xml_clob.body
		       , length(l_constant)
		       , l_constant);

  -- l_xml_clob.body := dbms_lob.substr(l_xml_clob.body,32767,1);

  x_xml_clob.body := l_xml_clob.body;
  dbms_lob.freetemporary(l_xml_clob.body);

END;


PROCEDURE get_element_vals (
  p_msg IN system.okc_aq_msg_typ,
  x_msg_tab OUT NOCOPY okc_aq_pvt.msg_tab_typ,
  x_corrid  OUT NOCOPY okc_aq_pvt.corrid_rec_typ)
IS
  search_start        number(10)  := 1;
  start_bracket       varchar2(1) := '<';
  end_bracket         varchar2(1) := '>';
  end_tag             varchar2(2) := '</';
  l_tag		      varchar2(3) := '>]>';
  l_msg               system.okc_aq_msg_typ;
  l_temp_clob         system.okc_aq_msg_typ;
  l_temp1_clob         system.okc_aq_msg_typ;
  l_char_element_name      varchar2(32767);
  l_char_element_value     varchar2(32767);
  l_char_corrid            varchar2(32767);
  l_start_bracket_pos number(5);
  l_start_pos         integer  ;
  l_end_pos           integer;
  l_length            integer;
  l_msg_tab           okc_aq_pvt.msg_tab_typ:=okc_aq_pvt.msg_tab_typ();
  l_index             integer := 1;
  l_amount            integer;

BEGIN

    l_msg := system.okc_aq_msg_typ(empty_clob());
    dbms_lob.createtemporary(l_msg.body,TRUE,dbms_lob.session);
    l_temp_clob := system.okc_aq_msg_typ(empty_clob());
    dbms_lob.createtemporary(l_temp_clob.body,TRUE,dbms_lob.session);
    l_temp1_clob := system.okc_aq_msg_typ(empty_clob());
    dbms_lob.createtemporary(l_temp1_clob.body,TRUE,dbms_lob.session);
    l_msg := p_msg;

    -- fix the position to remove DTD of xml string
    l_end_pos :=  dbms_lob.instr(l_msg.body,l_tag,1,1) + 3 ;
    -- cut the DTD from xml string
    l_amount := dbms_lob.getlength(l_msg.body)- l_end_pos;
    dbms_lob.copy(l_temp_clob.body,l_msg.body,l_amount,1,
				   (l_end_pos+1));

    l_length := dbms_lob.getlength(l_temp_clob.body);

    -- fix position to get corrid
    l_tag := '>';
    l_amount := (dbms_lob.instr(l_temp_clob.body,l_tag,1,1)-1);

    l_char_corrid := dbms_lob.substr(l_temp_clob.body,l_amount,1);

    -- assign corrid to corrid_rec_typ
       x_corrid.corrid := l_char_corrid;
    l_length := length(l_char_corrid)+1;
    l_amount := (dbms_lob.getlength(l_temp_clob.body) -
		l_length);
    dbms_lob.copy(l_temp1_clob.body,l_temp_clob.body,
		 l_amount,1,(l_length+1));
    -- fix position to remove end corrid tag REMINDER!
    l_length := dbms_lob.getlength(l_temp1_clob.body)-(length(l_char_corrid)+3);
    dbms_lob.trim(l_temp1_clob.body,l_length);

    -- Remove
    l_length := dbms_lob.getlength(l_temp1_clob.body);
    l_char_element_name := dbms_lob.substr(l_temp1_clob.body,l_length,1);
    -- Remove

    LOOP

      --  capture element name
      l_start_bracket_pos
           := dbms_lob.INSTR(l_temp1_clob.body,start_bracket,search_start,1);

           -- see if it is time to get out
           IF NVL(l_start_bracket_pos,0)  = 0
           THEN
             EXIT;
           ELSE
             l_start_pos := l_start_bracket_pos + 1;
           END IF;
        l_end_pos       := (dbms_lob.INSTR(l_temp1_clob.body,
					   end_bracket,
					   l_start_pos,
					   1) - 1);
        l_length        := (l_end_pos-l_start_pos) + 1;
        l_char_element_name  := dbms_lob.SUBSTR(l_temp1_clob.body,
						l_length,
						l_start_pos);


    -- assign element_name to msg_tab_typ rows
       l_msg_tab.extend;
       l_msg_tab(l_index).element_name := l_char_element_name;

    -- capture element value
       l_start_pos     := l_end_pos + 2;
       l_end_pos       := (dbms_lob.INSTR(l_temp1_clob.body,
					  end_tag,
					  l_start_pos,1) -1);
       l_length        := (l_end_pos-l_start_pos)+1;
       l_char_element_value := dbms_lob.SUBSTR(l_temp1_clob.body,
					       l_length,l_start_pos);


        -- assign element_value to msg_tab_typ rows
        l_msg_tab(l_index).element_value := l_char_element_value;
        search_start := l_end_pos + 2 ;
        l_index := l_index + 1 ;
    END LOOP;
       x_msg_tab := l_msg_tab;

       dbms_lob.freetemporary(l_temp_clob.body);
       dbms_lob.freetemporary(l_temp1_clob.body);
       -- dbms_lob.freetemporary(l_msg.body);
END;

END;

/
