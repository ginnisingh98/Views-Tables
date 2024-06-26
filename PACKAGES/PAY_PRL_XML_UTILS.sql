--------------------------------------------------------
--  DDL for Package PAY_PRL_XML_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRL_XML_UTILS" AUTHID CURRENT_USER AS
/* $Header: pyprxutl.pkh 120.0 2005/05/29 07:54 appldev noship $ */
  TYPE XMLRec
  IS RECORD
  (
    Name VARCHAR2(240),
    Value VARCHAR2(2000)
  );

  TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
  gXMLTable tXMLTable;

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
  --
  procedure twoColumnar(p_type  IN VARCHAR2
                       ,p_data  IN tXMLTable
                       ,p_count IN NUMBER
	               ,p_xml_data IN OUT NOCOPY CLOB);

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
			 ,p_xml_data IN OUT NOCOPY CLOB);

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
  RETURN VARCHAR2;
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
  RETURN VARCHAR2;

  END pay_prl_xml_utils;
 

/
