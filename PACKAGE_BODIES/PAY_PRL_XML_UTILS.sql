--------------------------------------------------------
--  DDL for Package Body PAY_PRL_XML_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRL_XML_UTILS" AS
/* $Header: pyprxutl.pkb 120.0 2005/05/29 07:53 appldev noship $ */

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : TWOCOLUMNAR	                                  --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the XML tag and its data     --
  -- Parameters     :                                                     --
  --             IN : p_type			VARCHAR2                  --
  --                  p_data			tXMLTable                 --
  --                  p_count			NUMBER                    --
  --                  p_xml_data	        CLOB	                  --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 07-Apr-2005    pgongada   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE twoColumnar(p_type  IN VARCHAR2
                       ,p_data  IN tXMLTable
                       ,p_count IN NUMBER
		       ,p_xml_data IN OUT NOCOPY CLOB)
  IS
     l_tag VARCHAR2(2000);
  BEGIN
  --
     FOR i in 1..p_count
     LOOP
     --
        IF p_data.exists(i) THEN
        --
          -- Start Main tag
          l_tag := '<'||p_type||'>';
          dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
	  --
        -- Put Description tag
          l_tag := getTag('SEGMENT', p_data(i).Name);
          dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
	--
        -- Put amount tag
          l_tag := getTag('VALUE', p_data(i).Value);
          dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
	--
        -- End Main tag
          l_tag := '</'||p_type||'>';
          dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
        --
        END IF;
     --
     END LOOP;
  --
  END twoColumnar;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : MULTICOLUMNAR	                                  --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the XML tag and its data     --
  --									  --
  -- Parameters     :                                                     --
  --             IN : p_type			VARCHAR2                  --
  --                  p_data			tXMLTable                 --
  --                  p_count			NUMBER                    --
  --                  p_xml_data	        CLOB	                  --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Apr-2005    pgongada   Initial Version                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE multiColumnar(p_type  IN VARCHAR2
                         ,p_data  IN tXMLTable
                         ,p_count IN NUMBER
		         ,p_xml_data IN OUT NOCOPY CLOB)
  IS
    l_tag VARCHAR2(2000);
  BEGIN
  --
     l_tag := '<'||p_type||'>';
     dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);

     FOR i in 1..p_count
     LOOP
     --
        IF p_data.exists(i) THEN
        --
          l_tag := getTag(p_data(i).Name, p_data(i).Value);
          dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
        --
        END IF;
     --
     END LOOP;
     --
     l_tag := '</'||p_type||'>';
     dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
  --
  END multiColumnar;
  --
  --
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ENCODE_HTML_STRING                                  --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function encodes the XML tag and its data      --
  -- Parameters     :                                                     --
  --             IN : p_value		VARCHAR2	                  --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 08-Apr-2005    pgongada   Initial Version                      --
  --------------------------------------------------------------------------

  FUNCTION encode_html_string(p_value IN VARCHAR2)
  RETURN VARCHAR2
  IS
    TYPE html_rec IS RECORD
           (html_char VARCHAR2(2)
	   ,encoded   VARCHAR2(10)
	   );

    TYPE html_char_tab IS TABLE OF  html_rec INDEX BY binary_integer;

    char_list html_char_tab;
    i  NUMBER;
    l_value VARCHAR2(1000);
  begin
   IF p_value IS NULL then
      RETURN null;
   END IF;

   char_list(0).html_char:='&';
   char_list(0).encoded:='&amp;';

   char_list(1).html_char:='>';
   char_list(1).encoded:='&gt;';

   char_list(2).html_char:='<';
   char_list(2).encoded:='&lt;';

   i:=0;
   l_value := p_value;
   while(i<char_list.count())
   LOOP
       l_value:=replace(l_value,char_list(i).html_char,char_list(i).encoded);
       i:=i+1;
   END LOOP;

  RETURN l_value;

  END encode_html_string;

  --
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GETTAG		                                  --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function creates the XML tag and its data      --
  -- Parameters     :                                                     --
  --             IN : p_tag_name	VARCHAR2	                  --
  --                  p_tag_value	VARCHAR2		          --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Apr-2005    pgongada   Initial Version                      --
  --------------------------------------------------------------------------
  --
  FUNCTION getTag(p_tag_name  IN VARCHAR2
                 ,p_tag_value IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_tag_value VARCHAR2(2000);
  BEGIN

  IF p_tag_value IS NULL THEN
         RETURN '<' || p_tag_name || ' />';
  ELSE
         l_tag_value := encode_html_string(p_tag_value);
	 RETURN '<'||p_tag_name||'>'||l_tag_value||'</'||p_tag_name||'>';
  END IF;
--
END getTag;

END pay_prl_xml_utils;

/
