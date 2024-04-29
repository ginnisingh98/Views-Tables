--------------------------------------------------------
--  DDL for Package Body XNP_XML_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_XML_UTILS" AS
/* $Header: XNPXMLPB.pls 120.3 2006/10/11 14:33:01 dputhiye ship $ */

/*11 OCT 2006	DPUTHIYE	BUG #:5591258
  Description: R12 Performance fix. Replacing all calls to fnd_global.local_chr in fn CONVERT()
  These will be initialized in the package init block.
*/
g_local_chr_38   VARCHAR2(10);
g_local_chr_127  VARCHAR2(10);

TYPE g_local_chr_table IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
g_local_chrs_0_to_31 g_local_chr_table;					-- characters 0-31.

/***************************************************************************
*****  Procedure:    DECODE()
*****  Purpose:      Provides a simple tag-value lookup
****************************************************************************/

PROCEDURE decode(
	p_msg_text IN VARCHAR2
	,p_tag IN VARCHAR2
	,x_value OUT NOCOPY VARCHAR2
)
IS

	tag_pos           INTEGER := 0 ;
	token             VARCHAR2(1024) := '' ;
	token_delimeter   VARCHAR2(1024) := '' ;
	tag_delimeter_pos INTEGER := 0 ;

BEGIN

	token := '<' || p_tag || '>' ;
	token_delimeter := '</' || p_tag || '>' ;
	tag_pos := INSTR( p_msg_text, token, 1 ) ;

	IF (tag_pos = 0)
	THEN
		x_value := NULL ;
		RETURN ;
	END IF ;

	tag_delimeter_pos := INSTR( p_msg_text, token_delimeter, 1 ) ;

	IF (tag_delimeter_pos = 0)
	THEN
		x_value := NULL ;
		RETURN ;
	END IF ;

	x_value := SUBSTR(p_msg_text, tag_pos + LENGTH(token),
             tag_delimeter_pos - (tag_pos + LENGTH(token))) ;

END decode;

/***************************************************************************
*****  Procedure:    INITIALIZE_DOC()
*****  Purpose:      Initializes the global XML document variable.
****************************************************************************/

PROCEDURE initialize_doc (
	p_msg_code IN VARCHAR2,
	p_dtd_url IN VARCHAR2
)
IS
l_list_count NUMBER := 0;

BEGIN

        xdp_utilities.g_message_list.DELETE;
	xml_decl ;

        l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
        xdp_utilities.g_message_list(l_list_count) := '<!DOCTYPE ' || p_msg_code || ' SYSTEM '|| '"' || p_dtd_url || '">';

END initialize_doc;

/***************************************************************************
*****  Procedure:    INITIALIZE_DOC()
*****  Purpose:      Initializes the global XML document variable.
****************************************************************************/

PROCEDURE initialize_doc
IS
BEGIN

        xdp_utilities.g_message_list.DELETE;

END initialize_doc;

/***************************************************************************
*****  Procedure:    XML_DECL()
*****  Purpose:      writes XML declaration to the document
****************************************************************************/

PROCEDURE xml_decl
IS
l_list_count NUMBER := 0;

BEGIN

        l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
        xdp_utilities.g_message_list(l_list_count) := '<?xml version="1.0"?>' ;

END xml_decl;

/***************************************************************************
*****  Procedure:    GET_DOCUMENT()
*****  Purpose:      Retrieves the constructed XML document.
****************************************************************************/

PROCEDURE get_document(
	p_xml_doc OUT NOCOPY VARCHAR2
)
IS
l_xml_doc VARCHAR2(32767) := null ;
l_msg_len NUMBER := 0;
l_doc_len NUMBER := 0;

BEGIN
  FOR i in 1..xdp_utilities.g_message_list.COUNT
      LOOP
         l_msg_len := LENGTH(xdp_utilities.g_message_list(i));
         l_doc_len := LENGTH(l_xml_doc);

         IF (NVL(l_doc_len,0) + NVL(l_msg_len,0)) < 32767 THEN
            l_xml_doc := l_xml_doc||xdp_utilities.g_message_list(i);
         ELSE
            l_xml_doc := l_xml_doc||substr(xdp_utilities.g_message_list(i),1,(32767 - l_doc_len));
         END IF ;

      END LOOP;

      p_xml_doc := l_xml_doc ;

END get_document;

/***************************************************************************
*****  Procedure:    WRITE_ELEMENT()
*****  Purpose:      Writes a character element to an XML document.
****************************************************************************/

PROCEDURE write_element(
	p_tag IN VARCHAR2
        ,x_value IN VARCHAR2
)
IS
l_list_count NUMBER := 0;
  l_value VARCHAR2(32767);

BEGIN

        IF ((x_value IS NULL) AND (g_remove_empty_nodes = 'Y'))THEN
           null;
        ELSE
           l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
           xdp_utilities.g_message_list(l_list_count) := '<' || p_tag || '>'|| x_value|| '</' || p_tag || '>' ;
        END IF ;

END write_element;

/***************************************************************************
*****  Procedure:    WRITE_ELEMENT()
*****  Purpose:      Writes a date element to an XML document.
****************************************************************************/

PROCEDURE write_element(
	P_TAG IN VARCHAR2
	,X_VALUE IN DATE
)
IS
l_list_count NUMBER := 0;

BEGIN

   IF ((x_value IS NULL) AND (g_remove_empty_nodes = 'Y') )  THEN
      null;
   ELSE
     l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
     xdp_utilities.g_message_list(l_list_count) := '<' || p_tag || '>'|| XNP_UTILS.DATE_TO_CANONICAL(x_value ) || '</' || p_tag || '>' ;
   END IF ;

END write_element;

/***************************************************************************
*****  Procedure:    WRITE_ELEMENT()
*****  Purpose:      writes a numeric element tot an XML document.
****************************************************************************/

PROCEDURE write_element(
	p_tag IN VARCHAR2
	,x_value IN NUMBER
)
IS
l_list_count NUMBER := 0;

BEGIN

     IF ((x_value IS NULL) AND (g_remove_empty_nodes = 'Y') )  THEN
      null;
     ELSE
        l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
        xdp_utilities.g_message_list(l_list_count) := '<' || p_tag || '>'|| TO_CHAR ( x_value )|| '</' || p_tag || '>' ;
     END IF ;

END write_element;


/***************************************************************************
*****  Procedure:    WRITE_LEAF_ELEMENT()
*****  Purpose:      Writes a character LEAF element to an XML document.
****************************************************************************/

PROCEDURE write_leaf_element(
	                     p_tag IN VARCHAR2
                            ,x_value IN VARCHAR2
)
IS
l_list_count NUMBER := 0;
  l_value VARCHAR2(32767);

BEGIN

        IF ((x_value IS NULL) AND (g_remove_empty_nodes = 'Y'))THEN
           null;
        ELSE
           l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
           xdp_utilities.g_message_list(l_list_count) := '<' || p_tag || '>' || convert(x_value) || '</' || p_tag || '>' ;
        END IF ;

END write_leaf_element;

/***************************************************************************
*****  Procedure:    WRITE_LEAF_ELEMENT()
*****  Purpose:      Writes a date element to an XML document.
****************************************************************************/

PROCEDURE write_leaf_element(
	                     P_TAG IN VARCHAR2
	                    ,X_VALUE IN DATE
)
IS
l_list_count NUMBER := 0;

BEGIN

   IF ((x_value IS NULL) AND (g_remove_empty_nodes = 'Y') )  THEN
      null;
   ELSE
     l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
     xdp_utilities.g_message_list(l_list_count) := '<' || p_tag || '>'|| XNP_UTILS.DATE_TO_CANONICAL(x_value ) || '</' || p_tag || '>' ;
   END IF ;

END write_leaf_element;

/***************************************************************************
*****  Procedure:    WRITE_LEAF_ELEMENT()
*****  Purpose:      writes a numeric element tot an XML document.
****************************************************************************/

PROCEDURE write_leaf_element(
	                 p_tag   IN VARCHAR2
	                ,x_value IN NUMBER
)
IS
l_list_count NUMBER := 0;

BEGIN

     IF ((x_value IS NULL) AND (g_remove_empty_nodes = 'Y') )  THEN
      null;
     ELSE
        l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
        xdp_utilities.g_message_list(l_list_count) := '<' || p_tag || '>'|| TO_CHAR ( x_value )|| '</' || p_tag || '>' ;
     END IF ;

END write_leaf_element;

/***************************************************************************
*****  Procedure:    END_SEGMENT()
*****  Purpose:      Adds an end tag to the element being specified.
****************************************************************************/

PROCEDURE end_segment(
	P_TAG IN VARCHAR2
)
IS
l_list_count NUMBER := 0;
l_tag        VARCHAR2(4000);

BEGIN
      l_tag := '<'||p_tag||'>' ;
      l_list_count := (xdp_utilities.g_message_list.COUNT + 1);

      IF xdp_utilities.g_message_list(l_list_count - 1 ) = l_tag  THEN
         xdp_utilities.g_message_list.DELETE(l_list_count - 1 ) ;
      ELSE
         xdp_utilities.g_message_list(l_list_count) := '</' || p_tag || '>' ;
      END IF ;

END end_segment;

/***************************************************************************
*****  Procedure:    BEGIN_SEGMENT()
*****  Purpose:      Adds a start tag for the XML element being constructed.
****************************************************************************/

PROCEDURE begin_segment(
	P_TAG IN VARCHAR2
)
IS
l_list_count NUMBER := 0;

BEGIN
        l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
        xdp_utilities.g_message_list(l_list_count) :=  '<' || p_tag || '>' ;

END begin_segment;

/***************************************************************************
*****  Procedure:    APPEND()
*****  Purpose:      Appends the doc to existing doc.
****************************************************************************/

PROCEDURE append(
	p_xml_doc IN VARCHAR2
)
IS
  l_list_count NUMBER := 0;
  l_xml_doc VARCHAR2(32767);

BEGIN

        l_xml_doc    := p_xml_doc ;
        l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
        xdp_utilities.g_message_list(l_list_count) := l_xml_doc ;

END append ;

/***************************************************************************
*****  Procedure:    APPEND()
*****  Purpose:      Appends the doc to existing doc.
****************************************************************************/

PROCEDURE append (
	p_xml_doc IN NUMBER
)
IS
l_list_count NUMBER := 0;

BEGIN
        l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
        xdp_utilities.g_message_list(l_list_count) := TO_CHAR(p_xml_doc);

END APPEND ;

/***************************************************************************
*****  Procedure:    APPEND()
*****  Purpose:      Appends the doc to existing doc.
****************************************************************************/

PROCEDURE APPEND(
	p_xml_doc IN DATE
)
IS
l_list_count NUMBER := 0;

BEGIN
        l_list_count := (xdp_utilities.g_message_list.COUNT + 1);
        xdp_utilities.g_message_list(l_list_count) :=  XNP_UTILS.DATE_TO_CANONICAL( p_xml_doc) ;

END append ;

/***************************************************************************
*****  Procedure:    CONVERT()
*****  Purpose:      Converts a character string to xml CDATA
****************************************************************************/


FUNCTION CONVERT ( p_value IN VARCHAR2) RETURN VARCHAR2 IS

l_value VARCHAR2(32767);
l_int   NUMBER := 0;

BEGIN
    --11 OCT 2006	DPUTHIYE	BUG #:5591258
    --Description: R12 Performance fix. Replacing all calls to fnd_global.local_chr in this function
    --by pre-initiated package constants. These constants are initialized in the package init block.

    l_value := p_value;

    --20 Jun 2005	DPUTHIYE	R12 GSCC mandate: File.Sql.10  - Do not use CHR(), instead use fnd_global.local_chr()
    /* l_value := replace(l_value,'&',chr(38)||'amp;');
    l_value := replace(l_value,'<',chr(38)||'lt;');
    l_value := replace(l_value,'>',chr(38)||'gt;');
    l_value := replace(l_value,'''',chr(38)||'#39;');
    l_value := replace(l_value,'"',chr(38)||'#34;');
    --11 OCT 2006	DPUTHIYE	BUG #:5591258
    l_value := replace(l_value,'&',fnd_global.local_chr(38)||'amp;');
    l_value := replace(l_value,'<',fnd_global.local_chr(38)||'lt;');
    l_value := replace(l_value,'>',fnd_global.local_chr(38)||'gt;');
    l_value := replace(l_value,'''',fnd_global.local_chr(38)||'#39;');
    l_value := replace(l_value,'"',fnd_global.local_chr(38)||'#34;');
    */

    l_value := replace(l_value,'&',  g_local_chr_38  ||'amp;');
    l_value := replace(l_value,'<',  g_local_chr_38  ||'lt;');
    l_value := replace(l_value,'>',  g_local_chr_38  ||'gt;');
    l_value := replace(l_value,'''', g_local_chr_38  ||'#39;');
    l_value := replace(l_value,'"',  g_local_chr_38  ||'#34;');

    WHILE(TRUE) LOOP
	--20 Jun 2005	DPUTHIYE	R12 GSCC mandate: File.Sql.10  - Do not use CHR(), instead use fnd_global.local_chr()
        --l_value := replace(l_value,chr(l_int),'&#'||l_int||';');
	--11 OCT 2006	DPUTHIYE	BUG #:5591258
	--l_value := replace(l_value,fnd_global.local_chr(l_int),'&#'||l_int||';');

	l_value := replace(l_value, g_local_chrs_0_to_31(l_int),'&#'||l_int||';');
        l_int := l_int + 1;

        IF l_int = 32 THEN
            exit;
        END IF;

    END LOOP;

    --20 Jun 2005	DPUTHIYE	R12 GSCC mandate: File.Sql.10  - Do not use CHR(), instead use fnd_global.local_chr()
    --l_value := replace(l_value,chr(127),'&#'||127||';');
    --11 OCT 2006	DPUTHIYE	BUG #:5591258
    --l_value := replace(l_value,fnd_global.local_chr(127),'&#'||127||';');

    l_value := replace(l_value, g_local_chr_127, '&#'||127||';');

    RETURN l_value;
END CONVERT;

-------------------------------
-- Package initialization code
------------------------------
	--11 OCT 2006	DPUTHIYE	BUG #:5591258
	--Description: R12 Performance fix. Replacing all calls to fnd_global.local_chr in fn CONVERT
	--by pre-initiated package constants. These constants are initialized in this block.
BEGIN

	DECLARE
		l_ack_reqd_flag VARCHAR2(2) := NULL;
		l_remove_empty_nodes VARCHAR2(1) := NULL ;
		l_int	NUMBER := 0;
        BEGIN

                FND_PROFILE.GET(NAME=> 'XNP_REMOVE_EMPTY_NODES',
                                VAL => l_remove_empty_nodes );

                IF l_remove_empty_nodes IS NOT NULL THEN
                   g_remove_empty_nodes := l_remove_empty_nodes ;
                END IF;

		--11 OCT 2006	DPUTHIYE	BUG #:5591258
		--Initiailize the local characters used in Convert()

		g_local_chr_38 := fnd_global.local_chr(38);
		g_local_chr_127 := fnd_global.local_chr(127);

		FOR l_int IN 0..31 LOOP
			g_local_chrs_0_to_31(l_int) := fnd_global.local_chr(l_int);
		END LOOP;

	END ;
END xnp_xml_utils;

/
