--------------------------------------------------------
--  DDL for Package Body PAY_IN_XML_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_XML_UTILS" AS
/* $Header: pyinxutl.pkb 120.2 2006/05/27 18:33:39 statkar noship $ */
g_package          CONSTANT VARCHAR2(100) := 'pay_in_xml_utils.';
g_debug            BOOLEAN ;
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
  -- 115.0 01-Jan-2005    aaagawra   Initial Version                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE multiColumnar(p_type  IN VARCHAR2
                         ,p_data  IN tXMLTable
                         ,p_count IN NUMBER
		         ,p_xml_data IN OUT NOCOPY CLOB)
  IS
    l_tag         VARCHAR2(2000);
    l_procedure   VARCHAR2(250);
    l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'multiColumnar';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_type :',p_type);
        pay_in_utils.trace('p_count :',p_count);
        pay_in_utils.trace('**************************************************','********************');
   END IF;

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
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
  --
  END multiColumnar;

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
  -- 115.0 01-Jan-2005    aaagawra   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE twoColumnar(p_type  IN VARCHAR2
                       ,p_data  IN tXMLTable
                       ,p_count IN NUMBER
		       ,p_xml_data IN OUT NOCOPY CLOB)
  IS
     l_tag VARCHAR2(2000);
     l_procedure   VARCHAR2(250);
     l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'twoColumnar';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_type :',p_type);
        pay_in_utils.trace('p_count :',p_count);
        pay_in_utils.trace('**************************************************','********************');
   END IF;

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
          l_tag := getTag('c_description', p_data(i).Name);
          dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
	--
        -- Put amount tag
          l_tag := getTag('c_amount', p_data(i).Value);
          dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
	--
        -- End Main tag
          l_tag := '</'||p_type||'>';
          dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
        --
        END IF;
     --
     END LOOP;
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
  --
  END twoColumnar;
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
  -- 115.0 01-Jan-2005    aaagawra   Initial Version                      --
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
    l_procedure   VARCHAR2(250);
    l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'encode_html_string';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_value :',p_value);
        pay_in_utils.trace('**************************************************','********************');
   END IF;

   IF p_value IS NULL then
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
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
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);

  RETURN l_value;
  END encode_html_string;
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
  -- 115.0 01-Jan-2005    aaagawra   Initial Version                      --
  --------------------------------------------------------------------------
  --
  FUNCTION getTag(p_tag_name  IN VARCHAR2
                 ,p_tag_value IN VARCHAR2)
  RETURN VARCHAR2
  IS
   l_tag_value VARCHAR2(2000);
   l_procedure   VARCHAR2(250);
   l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'getTag';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_tag_name :',p_tag_name);
        pay_in_utils.trace('p_tag_value :',p_tag_value);
        pay_in_utils.trace('**************************************************','********************');
   END IF;
  --
     l_tag_value:=nvl(encode_html_string(p_tag_value),' ');
  --Return Tag
  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
  return '<'||p_tag_name||'>'||l_tag_value||'</'||p_tag_name||'>';
--
END getTag;

END pay_in_xml_utils;

/
