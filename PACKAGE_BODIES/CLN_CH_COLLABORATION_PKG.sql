--------------------------------------------------------
--  DDL for Package Body CLN_CH_COLLABORATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_CH_COLLABORATION_PKG" AS
/* $Header: ECXCHCHB.pls 120.4 2006/06/30 07:48:51 susaha noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

--  Package
--      CLN_CH_COLLABORATION_PKG
--
--  Purpose
--      Spec of package CLN_CH_COLLABORATION_PKG. This package
--      is called by both inbound and outbound operations from the application
--      when ever a new collaboration has to be started.Also,the details of any
--      existing collaboration can also be retrieved/updated by calling this package.
--
--  History
--      Mar-26-2002     Rahul Krishan         Created
--      Apr-12-2002     Rahul Krishan         Updated
--      Aug-26-2002     Rahul Krishan         Updated

-- Name
--    GET_CHILD_ELEMENT_VALUE
-- Purpose
--    This procedure is called to retrieve value of child element in an xml
-- Arguments
--    parent element and child element name
-- Notes
--    Only called by get_document_creation_date

    FUNCTION GET_CHILD_ELEMENT_VALUE(
         l_element              IN xmldom.domElement,
         l_child_name           IN VARCHAR2) RETURN VARCHAR2
         IS
           l_child_value        VARCHAR2(100);
         BEGIN
            l_child_value := xmldom.getNodeValue(xmldom.getFirstChild(xmldom.item( Xmldom.getElementsByTagName(l_element, l_child_name), 0 )));
            RETURN l_child_value;
         EXCEPTION
          WHEN OTHERS THEN
            IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('When others in get child element' , 1);
            END IF;
            RETURN NULL;
         END;




-- Name
--    GET_DOCUMENT_CREATION_DATE
-- Purpose
--    This procedure is called to retrieve document creation date based on
--    XML message ID from control area of the payload
-- Arguments
--    XML Gateway Message ID
-- Notes
--    Uses a DOM Parser to parse the document and retrieve the doc creation date

    PROCEDURE GET_DOCUMENT_CREATION_DATE(
         p_msgId                IN  RAW,
         x_doc_creation_date    IN OUT NOCOPY DATE)
   IS
         l_xmlDoc               CLOB;
         l_parser               xmlparser.parser := xmlparser.newParser;
         l_domDoc               xmldom.DOMDocument;
         l_node                 xmldom.domNode;
         l_element              xmldom.domElement;
         l_nodeList             xmldom.domNodeList;
         l_size                 number;
         l_Nname                varchar2(255);
         l_Nvalue               varchar2(255);
         l_error_code           VARCHAR2(255);
         l_error_msg            VARCHAR2(1000);
         l_msg_data             VARCHAR2(1000);
         l_payload              CLOB;
         l_ini_pos              NUMBER(38);
         l_fin_pos              NUMBER(38);
         l_amount               INTEGER;
         l_year                 VARCHAR2(10);
         l_month                VARCHAR2(10);
         l_day                  VARCHAR2(10);
         l_hour                 VARCHAR2(10);
         l_minute               VARCHAR2(10);
         l_second               VARCHAR2(10);
         l_timezone_string      VARCHAR2(10);
         l_timezone_num         VARCHAR2(10);

   BEGIN
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('-----------ENTERING GET_DOCUMENT_CREATION_DATE-----------', 2);
      END IF;

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('WITH PARAMETERS', 1);
              ecx_cln_debug_pub.Add('p_msgId:' || p_msgId, 1);
      END IF;

      x_doc_creation_date := NULL;

      SELECT payload into l_xmlDoc FROM ecx_doclogs  WHERE msgid = HEXTORAW(p_msgId);

      l_ini_pos := -1;
      l_ini_pos := dbms_lob.instr(l_xmlDoc, '!DOCTYPE ');
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('Init Position:' || l_ini_pos, 1);
      END IF;

      IF (l_ini_pos > 0) THEN
         l_fin_pos := dbms_lob.instr(l_xmlDoc, '>', l_ini_pos);
         l_fin_pos := l_fin_pos + 1;
         l_amount  := dbms_lob.getlength(l_xmlDoc);

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('Final Position:' || l_fin_pos, 1);
                 ecx_cln_debug_pub.Add('Length:' || l_amount, 1);
         END IF;

         DBMS_LOB.CREATETEMPORARY(l_payload, TRUE, DBMS_LOB.SESSION);

         dbms_lob.copy(l_payload, l_xmlDoc, l_amount - l_fin_pos + 1, 1, l_fin_pos);

      END IF;

      l_parser := xmlparser.newparser;
      xmlparser.setValidationMode(l_parser,FALSE);
      xmlparser.showWarnings(l_parser,FALSE);

      BEGIN

         IF (l_ini_pos > 0) THEN
            xmlparser.parseClob(l_parser,l_payload);
         ELSE
            xmlparser.parseClob(l_parser,l_xmlDoc);
         END IF;

         l_domDoc       := xmlparser.getDocument(l_parser);
         l_nodeList     := Xmldom.getElementsByTagName(l_domDoc, 'CNTROLAREA');
         l_element      := xmldom.makeElement(xmldom.item( l_nodeList, 0 ));
         l_nodeList     := Xmldom.getElementsByTagName(l_element, 'DATETIME');
         l_element      := xmldom.makeElement(xmldom.item( l_nodeList, 0 ));

         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('About to get values of child elements of DATETIME', 1);
         END IF;
         l_year := GET_CHILD_ELEMENT_VALUE(l_element,'YEAR');
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('l_year : ' || l_year , 1);
         END IF;
         l_month := GET_CHILD_ELEMENT_VALUE(l_element,'MONTH');
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('l_month : ' || l_month , 1);
         END IF;
         l_day := GET_CHILD_ELEMENT_VALUE(l_element,'DAY');
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('l_day : ' || l_day , 1);
         END IF;
         l_hour := GET_CHILD_ELEMENT_VALUE(l_element,'HOUR');
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('l_hour : ' || l_hour , 1);
         END IF;
         l_minute := GET_CHILD_ELEMENT_VALUE(l_element,'MINUTE');
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('l_minute : ' || l_minute , 1);
         END IF;
         l_second := GET_CHILD_ELEMENT_VALUE(l_element,'SECOND');
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('l_second : ' || l_second , 1);
         END IF;
         x_doc_creation_date := to_date(l_year   ||'-'||
                                        l_month  ||'-'||
                                        l_day  ||'-'||
                                        l_hour  ||'-'||
                                        l_minute  ||'-'||
                                        l_second,
                                        'yyyy-mm-dd-hh24-mi-ss');
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('Date before conversion : ' || to_char(x_doc_creation_date,'yyyy-mm-dd-hh24-mi-ss'), 1);
         END IF;
         l_timezone_string := GET_CHILD_ELEMENT_VALUE(l_element,'TIMEZONE');
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('l_timezone_string : ' || l_timezone_string , 1);
         END IF;
         l_timezone_num := to_number(l_timezone_string);
         x_doc_creation_date := x_doc_creation_date - trunc(l_timezone_num/100)/24 - mod(l_timezone_num,100)/1440;
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('Date after conversion : ' || to_char(x_doc_creation_date,'yyyy-mm-dd-hh24-mi-ss'), 1);
             ecx_cln_debug_pub.Add('Server Time Zone : ' || FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE, 1);
         END IF;

         x_doc_creation_date := fnd_timezones_pvt.adjust_datetime(x_doc_creation_date,'GMT',FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE);
         IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('Date after converting to server Time Zone : ' || to_char(x_doc_creation_date,'yyyy-mm-dd-hh24-mi-ss'), 1);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            x_doc_creation_date := NULL;
      END;

      IF (l_ini_pos > 0) THEN
        DBMS_LOB.FREETEMPORARY(l_payload);
      END IF;
      xmlparser.freeparser(l_parser);

      IF (l_Debug_Level <= 5) THEN
              ecx_cln_debug_pub.Add('Document Creation Date:' || x_doc_creation_date,1);
      END IF;
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('EXITING GET_DOCUMENT_CREATION_DATE', 2);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         l_msg_data := l_error_code||' : '||l_error_msg;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(l_msg_data,6);
                 ecx_cln_debug_pub.Add('EXITING GET_APP_REFID', 1);
         END IF;
         x_doc_creation_date := NULL;
   END GET_DOCUMENT_CREATION_DATE;




-- Name
--    GET_CONTROL_AREA_REFID
-- Purpose
--    This procedure is called to retrieve application reference ID based on
--    XML message ID from control area of the payload
-- Arguments
--    XML Gateway Message ID
-- Notes
--    Uses a DOM Parser to parse the document and retrieve the application reference ID

    PROCEDURE GET_CONTROL_AREA_REFID(
         p_msgId                   IN  RAW,
         p_collaboration_standard  IN VARCHAR2,
         x_app_ref_id              IN OUT NOCOPY VARCHAR2,
         p_app_id                  IN  VARCHAR2,
         p_coll_type               IN  VARCHAR2
	 )
   IS
         l_xmlDoc               CLOB;
         l_parser               xmlparser.parser := xmlparser.newParser;
         l_domDoc               xmldom.DOMDocument;
         l_node                 xmldom.domNode;
         l_element              xmldom.domElement;
         l_nodeList             xmldom.domNodeList;
         l_size                 number;
         l_Nname                varchar2(255);
         l_Nvalue               varchar2(255);
         l_error_code           VARCHAR2(255);
         l_error_msg            VARCHAR2(1000);
         l_msg_data             VARCHAR2(1000);
         l_payload              CLOB;
         l_ini_pos              NUMBER(38);
         l_fin_pos              NUMBER(38);
         l_amount               INTEGER;
   BEGIN
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('-----------ENTERING GET_APP_REFID-----------', 2);
      END IF;
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('WITH PARAMETERS', 1);
              ecx_cln_debug_pub.Add('p_msgId:' || p_msgId, 1);
              ecx_cln_debug_pub.Add('p_collaboration_standard:' || p_collaboration_standard, 1);
              ecx_cln_debug_pub.Add('p_app_id:' || p_app_id, 1);
              ecx_cln_debug_pub.Add('p_coll_type:' || p_coll_type, 1);
      END IF;

      IF p_collaboration_standard is NULL THEN
         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('-----------EXITING GET_APP_REFID as collaboration standard is null-----------', 1);
         END IF;
         RETURN;
      END IF;
      x_app_ref_id := NULL;

      SELECT payload into l_xmlDoc FROM ecx_doclogs  WHERE msgid = HEXTORAW(p_msgId);

      l_ini_pos := -1;
      l_ini_pos := dbms_lob.instr(l_xmlDoc, '!DOCTYPE ');
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('Init Position:' || l_ini_pos, 1);
      END IF;

      IF (l_ini_pos > 0) THEN
         l_fin_pos := dbms_lob.instr(l_xmlDoc, '>', l_ini_pos);
         l_fin_pos := l_fin_pos + 1;
         l_amount  := dbms_lob.getlength(l_xmlDoc);

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('Final Position:' || l_fin_pos, 1);
                 ecx_cln_debug_pub.Add('Length:' || l_amount, 1);
         END IF;

         DBMS_LOB.CREATETEMPORARY(l_payload, TRUE, DBMS_LOB.SESSION);

         dbms_lob.copy(l_payload, l_xmlDoc, l_amount - l_fin_pos + 1, 1, l_fin_pos);

      END IF;

      l_parser := xmlparser.newparser;
      xmlparser.setValidationMode(l_parser,FALSE);
      xmlparser.showWarnings(l_parser,FALSE);

      BEGIN

         IF (l_ini_pos > 0) THEN
            xmlparser.parseClob(l_parser,l_payload);
         ELSE
            xmlparser.parseClob(l_parser,l_xmlDoc);
         END IF;

         l_domDoc       := xmlparser.getDocument(l_parser);
         IF(p_collaboration_standard = 'OAG') THEN
            l_nodeList     := Xmldom.getElementsByTagName(l_domDoc, 'CNTROLAREA');
            l_element      := xmldom.makeElement(xmldom.item( l_nodeList, 0 ));
            l_nodeList     := Xmldom.getElementsByTagName(l_element, 'REFERENCEID');
         ELSIF (p_collaboration_standard = 'ROSETTANET') THEN
            l_nodeList     := Xmldom.getElementsByTagName(l_domDoc, 'thisDocumentIdentifier');
            l_element      := xmldom.makeElement(xmldom.item( l_nodeList, 0 ));
            l_nodeList     := Xmldom.getElementsByTagName(l_element, 'ProprietaryDocumentIdentifier');
         ELSE
            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('-----------EXITING GET_APP_REFID as the collaboration standard is not supported-----------', 1);
            END IF;
            RETURN;
         END IF;
         l_node         := xmldom.item( l_nodeList, 0 );
         l_Nvalue       := xmldom.getNodeName(l_node);
         l_node         := xmldom.getFirstChild(l_node);

         IF NOT xmldom.IsNull(l_node) THEN
            l_error_code := SQLCODE;
            l_error_msg := SQLERRM;
            l_msg_data := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    ecx_cln_debug_pub.Add(l_msg_data,6);
            END IF;
            x_app_ref_id := xmldom.getNodeValue(l_node);
	    IF(p_collaboration_standard = 'ROSETTANET' and p_app_id is not null and p_coll_type is not null and x_app_ref_id is not null) THEN
	       x_app_ref_id := p_app_id || p_coll_type || x_app_ref_id;
	    END IF;
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            x_app_ref_id := NULL;
      END;

      IF (l_ini_pos > 0) THEN
        DBMS_LOB.FREETEMPORARY(l_payload);
      END IF;
      xmlparser.freeparser(l_parser);

      IF (l_Debug_Level <= 5) THEN
              ecx_cln_debug_pub.Add('Application Reference ID:' || x_app_ref_id,1);
      END IF;
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('EXITING GET_APP_REFID', 2);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         l_msg_data := l_error_code||' : '||l_error_msg;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(l_msg_data,6);
                 ecx_cln_debug_pub.Add('EXITING GET_APP_REFID', 1);
         END IF;
         x_app_ref_id := NULL;
   END GET_CONTROL_AREA_REFID;




-- Name
--    GET_DATA_AREA_REFID
-- Purpose
--    This procedure is called to retrieve application reference ID based on
--    XML message ID from data area of the payload
-- Arguments
--    XML Gateway Message ID
-- Notes
--    Uses a DOM Parser to parse the document and retrieve the application reference ID

   PROCEDURE GET_DATA_AREA_REFID(
      p_msgId                   IN  RAW,
      p_collaboration_standard  IN VARCHAR2,
      x_app_ref_id              IN OUT NOCOPY VARCHAR2,
      p_app_id                  IN  VARCHAR2,
      p_coll_type               IN  VARCHAR2)
   IS
      l_xmlDoc     CLOB;
      l_parser     xmlparser.parser := xmlparser.newParser;
      l_domDoc     xmldom.DOMDocument;
      l_node       xmldom.domNode;
      l_element    xmldom.domElement;
      l_nodeList   xmldom.domNodeList;
      l_size       number;
      l_Nname      varchar2(255);
      l_Nvalue     varchar2(255);
      l_error_code VARCHAR2(255);
      l_error_msg  VARCHAR2(1000);
      l_msg_data   VARCHAR2(1000);
      l_payload    CLOB;
      l_ini_pos    NUMBER(38);
      l_fin_pos    NUMBER(38);
      l_amount     INTEGER;
   BEGIN
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('ENTERING GET_DATA_AREA_REFID', 2);
      END IF;
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('WITH PARAMETERS', 1);
              ecx_cln_debug_pub.Add('p_msgId:' || p_msgId, 1);
              ecx_cln_debug_pub.Add('p_collaboration_standard:' || p_collaboration_standard, 1);
              ecx_cln_debug_pub.Add('p_app_id:' || p_app_id, 1);
              ecx_cln_debug_pub.Add('p_coll_type:' || p_coll_type, 1);
      END IF;

      IF p_collaboration_standard is NULL THEN
         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('-----------EXITING GET_APP_REFID as collaboration standard is null-----------', 1);
         END IF;
         RETURN;
      END IF;

      x_app_ref_id := NULL;

      SELECT payload into l_xmlDoc FROM ecx_doclogs  WHERE msgid = HEXTORAW(p_msgId);
      IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('payload obtained', 1);
      END IF;

      l_ini_pos := -1;
      l_ini_pos := dbms_lob.instr(l_xmlDoc, '!DOCTYPE ');
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Init Position:' || l_ini_pos, 1);
      END IF;

      IF (l_ini_pos > 0) THEN
         l_fin_pos := dbms_lob.instr(l_xmlDoc, '>', l_ini_pos);
         l_fin_pos := l_fin_pos + 1;
         l_amount  := dbms_lob.getlength(l_xmlDoc);

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Final Position:' || l_fin_pos, 1);
                 ecx_cln_debug_pub.Add('Length:' || l_amount, 1);
         END IF;

         DBMS_LOB.CREATETEMPORARY(l_payload, TRUE, DBMS_LOB.SESSION);

         dbms_lob.copy(l_payload, l_xmlDoc, l_amount - l_fin_pos + 1, 1, l_fin_pos);

      END IF;
      IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('about to initialize parser', 1);
      END IF;

      l_parser := xmlparser.newparser;
      xmlparser.setValidationMode(l_parser,FALSE);
      xmlparser.showWarnings(l_parser,FALSE);
      IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('parser initialized', 1);
      END IF;

      BEGIN

         IF (l_ini_pos > 0) THEN
            xmlparser.parseClob(l_parser,l_payload);
         ELSE
            xmlparser.parseClob(l_parser,l_xmlDoc);
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('xml doc parsed', 1);
         END IF;

         l_domDoc       := xmlparser.getDocument(l_parser);
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('dom doc obtained', 1);
         END IF;
         IF(p_collaboration_standard = 'OAG') THEN
            l_nodeList     := Xmldom.getElementsByTagName(l_domDoc, 'DATAAREA');
            IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('IN OAG, data area found', 1);
            END IF;
            l_element      := xmldom.makeElement(xmldom.item( l_nodeList, 0 ));
            IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('data area element obtained', 1);
            END IF;
            l_nodeList     := Xmldom.getElementsByTagName(l_element, 'REFERENCEID');
            IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Reference id element obtained', 1);
            END IF;
         ELSIF (p_collaboration_standard = 'ROSETTANET') THEN
            l_nodeList     := Xmldom.getElementsByTagName(l_domDoc, 'requestingDocumentIdentifier');
            l_element      := xmldom.makeElement(xmldom.item( l_nodeList, 0 ));
            l_nodeList     := Xmldom.getElementsByTagName(l_element, 'ProprietaryDocumentIdentifier');
         ELSE
            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('-----------EXITING GET_APP_REFID as the collaboration standard is not supported-----------', 1);
            END IF;
            RETURN;
         END IF;

         l_node         := xmldom.item( l_nodeList, 0 );
         l_Nvalue       := xmldom.getNodeName(l_node);
         l_node         := xmldom.getFirstChild(l_node);

         IF NOT xmldom.IsNull(l_node) THEN
            IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('about to obtain the value from the node, as node is not null', 1);
            END IF;
            x_app_ref_id := xmldom.getNodeValue(l_node);
            IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('x_app_ref_id:' || x_app_ref_id, 1);
            END IF;
	    IF(p_collaboration_standard = 'ROSETTANET' and p_app_id is not null and p_coll_type is not null and x_app_ref_id is not null) THEN
	       x_app_ref_id := p_app_id || p_coll_type || x_app_ref_id;
	    END IF;
            IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('x_app_ref_id:' || x_app_ref_id, 1);
            END IF;
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('In when others. so setting appref id to null', 1);
            END IF;
            x_app_ref_id := NULL;
      END;

      IF (l_ini_pos > 0) THEN
        DBMS_LOB.FREETEMPORARY(l_payload);
      END IF;
      xmlparser.freeparser(l_parser);

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('Application Reference ID:' || x_app_ref_id,1);
      END IF;
      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('EXITING GET_DATA_AREA_REFID', 2);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg := SQLERRM;
         l_msg_data := l_error_code||' : '||l_error_msg;
         IF (l_Debug_Level <= 5) THEN
                 ecx_cln_debug_pub.Add(l_msg_data,6);
                 ecx_cln_debug_pub.Add('EXITING GET_DATA_AREA_REFID', 1);
         END IF;
         x_app_ref_id := NULL;
   END GET_DATA_AREA_REFID;



  -- Name
  --   VALIDATE_PARAMS
  -- Purpose
  --   This procedure is called for validation purposes.This checks for validity of all lookup
  --   values passed.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


    PROCEDURE VALIDATE_PARAMS(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_app_id                       IN  VARCHAR2,
         p_doc_dir                      IN  VARCHAR2,
         p_doc_type                     IN  VARCHAR2,
         p_coll_status                  IN  VARCHAR2,
         p_coll_pt                      IN  VARCHAR2,
         p_coll_type                    IN  VARCHAR2,
         p_doc_status                   IN  VARCHAR2,
         p_disposition                  IN  VARCHAR2)

    IS
         l_error_code                   NUMBER;
         l_error_msg                    VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);
         l_meaning                      VARCHAR2(255);
         l_param                        VARCHAR2(255);

    BEGIN

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('-----------Entering VALIDATE_PARAMS API---- ',2);
         END IF;


         -- Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('------------Parameters Received-------------',1);
                 ecx_cln_debug_pub.Add('APPLCATION ID     ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('DOC DIRECTION     ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('DOC TYPE          ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('COLL STATUS       ----- >>>'||p_coll_status,1);
                 ecx_cln_debug_pub.Add('COLL POINT        ----- >>>'||p_coll_pt,1);
                 ecx_cln_debug_pub.Add('COLL TYPE         ----- >>>'||p_coll_type,1);
                 ecx_cln_debug_pub.Add('DOC STATUS        ----- >>>'||p_doc_status,1);
                 ecx_cln_debug_pub.Add('DISPOSITION       ----- >>>'||p_disposition,1);
                 ecx_cln_debug_pub.Add('---------------------------------------------',1);



                 ecx_cln_debug_pub.Add('-------------Validating Parameters-----------',1);

                 ecx_cln_debug_pub.Add('>>>Validating Application ID >>>',1);
         END IF;
         IF (p_app_id IS NOT NULL) THEN
                BEGIN
                        l_meaning := p_app_id;
                        SELECT meaning INTO l_meaning FROM fnd_lookups
                        WHERE lookup_code = p_app_id AND lookup_type = 'CLN_APPLICATION_ID';
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('...........Application ID found as  - '||l_meaning,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_param := 'Application ID';
                             RAISE FND_API.G_EXC_ERROR;
                END;
         END IF;


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('>>>Validating Document Direction >>>',1);
         END IF;
         IF (p_doc_dir IS NOT NULL) THEN
                BEGIN
                        l_meaning := p_doc_dir;
                        SELECT meaning INTO l_meaning FROM fnd_lookups
                        WHERE lookup_code = p_doc_dir AND lookup_type = 'CLN_COLLABORATION_DOC_DIRECTN';
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('...........Document Direction found as  - '||l_meaning,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_param := 'Document Direction';
                             RAISE FND_API.G_EXC_ERROR;
                END;
         END IF;


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('>>>Validating Document Type >>>',1);
         END IF;
         IF (p_doc_type IS NOT NULL) THEN
                BEGIN
                        l_meaning := p_doc_type;
                        SELECT meaning INTO l_meaning FROM fnd_lookups
                        WHERE lookup_code = p_doc_type AND lookup_type = 'CLN_COLLABORATION_DOC_TYPE';
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('...........Document Type found as  - '||l_meaning,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_param := 'Document Type';
                             RAISE FND_API.G_EXC_ERROR;
                END;
         END IF;


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('>>>Validating Collaboration Status >>>',1);
         END IF;
         IF (p_coll_status IS NOT NULL) THEN
                BEGIN
                        l_meaning := p_coll_status;
                        SELECT meaning INTO l_meaning FROM fnd_lookups
                        WHERE lookup_code = p_coll_status AND lookup_type = 'CLN_COLLABORATION_STATUS';
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('...........Collaboration Status found as  - '||l_meaning,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_param := 'Collaboration Status';
                             RAISE FND_API.G_EXC_ERROR;
                END;
         END IF;


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('>>>Validating Collaboration Point >>>',1);
         END IF;
         IF (p_coll_pt IS NOT NULL) THEN
                BEGIN
                        l_meaning := p_coll_pt;
                        SELECT meaning INTO l_meaning FROM fnd_lookups
                        WHERE lookup_code = p_coll_pt AND lookup_type = 'CLN_COLLABORATION_POINT';
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('...........Collaboration Point found as  - '||l_meaning,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_param := 'Collaboration Point';
                             RAISE FND_API.G_EXC_ERROR;
                END;
         END IF;


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('>>>Validating Collaboration Type >>>',1);
         END IF;
         IF (p_coll_type IS NOT NULL) THEN
                BEGIN
                        l_meaning := p_coll_type;
                        SELECT meaning INTO l_meaning FROM fnd_lookups
                        WHERE lookup_code = p_coll_type AND lookup_type = 'CLN_COLLABORATION_TYPE';
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('...........Collaboration Type found as  - '||l_meaning,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_param := 'Collaboration Type';
                             RAISE FND_API.G_EXC_ERROR;
                END;
         END IF;


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('>>>Validating Document Status >>>',1);
         END IF;
         IF (p_doc_status IS NOT NULL) THEN
                BEGIN
                        l_meaning := p_doc_status;
                        SELECT meaning INTO l_meaning FROM fnd_lookups
                        WHERE lookup_code = p_doc_status AND lookup_type = 'CLN_COLLABORATION_DOC_STATUS';
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('...........Collaboration Document Status found as  - '||l_meaning,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_param := 'Collaboration Document Status';
                             RAISE FND_API.G_EXC_ERROR;
                END;
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('>>>Validating Disposition >>>',1);
         END IF;
         IF (p_disposition IS NOT NULL) THEN
                BEGIN
                        l_meaning := p_disposition;
                        SELECT meaning INTO l_meaning FROM fnd_lookups
                        WHERE lookup_code = p_disposition AND lookup_type = 'CLN_DISPOSITION';
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('...........Disposition found as  - '||l_meaning,1);
                        END IF;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             l_param := 'Disposition';
                             RAISE FND_API.G_EXC_ERROR;
                END;
         END IF;


         FND_MESSAGE.SET_NAME('CLN','CLN_CH_VALIDATION_SUCCESS');
         x_msg_data     := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Successfully validated all parameters passed',1);
         END IF;
         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('-------- Exiting VALIDATE_PARAMS API ----- ',2);
         END IF;

    -- Exception Handling
    EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_PARAM_VALIDATION');
              FND_MESSAGE.SET_TOKEN('PARAM',l_param);
              FND_MESSAGE.SET_TOKEN('VALUE',l_meaning);
              x_msg_data        := FND_MESSAGE.GET;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_param||' is irrelevant        -'||l_meaning,4);
                      ecx_cln_debug_pub.Add('-------- Exiting VALIDATE_PARAMS API ----- ',2);
              END IF;


         WHEN OTHERS THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              x_msg_data        :=l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(x_msg_data,6);
                      ecx_cln_debug_pub.Add('-------- Exiting VALIDATE_PARAMS API ----- ',2);
              END IF;


    END VALIDATE_PARAMS;



  -- Name
  --   UPDATE_COLLABORATION_INIT
  -- Purpose
  --   This procedure is called internally by the public procedure CREATE_COLLABORATION
  --   to add the initial details in the CLN_COLL_HIST_DTL table corresponding to newly started
  --   collaboration.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


    PROCEDURE UPDATE_COLLABORATION_INIT(
         x_return_status                        OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER,
         p_doc_type                             IN  VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_coll_pt                              IN  VARCHAR2,
         p_org_ref                              IN  VARCHAR2,
         p_doc_status                           IN  VARCHAR2,
         p_notification_id                      IN  VARCHAR2,
         p_msg_text                             IN  VARCHAR2,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_xmlg_document_id                     IN  VARCHAR2,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_xmlg_internal_control_number         IN  NUMBER,
         p_resend_flag                          IN  VARCHAR2,
         p_xmlg_int_transaction_type            IN  VARCHAR2,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2,
         p_xml_event_key                        IN  VARCHAR2)

    IS
         l_dtl_coll_id                          NUMBER;
         l_error_code                           NUMBER;
         l_error_msg                            VARCHAR2(2000);
         l_msg_data                             VARCHAR2(2000);

    BEGIN


         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------- Entering UPDATE_COLLABORATION_INIT API -------- ',2);
         END IF;


         -- Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('------------Parameters Received-------------',1);
                 ecx_cln_debug_pub.Add('COLLABORATION ID             ----- >>>'||p_coll_id,1);
                 ecx_cln_debug_pub.Add('DOC TYPE                     ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('DOC DIRECTION                ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('COLL POINT                   ----- >>>'||p_coll_pt,1);
                 ecx_cln_debug_pub.Add('ORIGINATOR REFERNCE          ----- >>>'||p_org_ref,1);
                 ecx_cln_debug_pub.Add('DOC STATUS                   ----- >>>'||p_doc_status,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION ID              ----- >>>'||p_notification_id,1);
                 ecx_cln_debug_pub.Add('MESSAGE TEXT                 ----- >>>'||p_msg_text,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE    ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE    ----- >>>'||p_xmlg_int_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE ----- >>>'||p_xmlg_int_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID             ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID              ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO     ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('RESEND FLAG                  ----- >>>'||p_resend_flag,1);
                 ecx_cln_debug_pub.Add('XMLG EVENT KEY               ----- >>>'||p_xml_event_key,1);
                 ecx_cln_debug_pub.Add('---------------------------------------------',1);
         END IF;


         -- Collaboration Detail ID is generated from a sequence.
         SELECT cln_collaboration_dtl_id_s.nextval INTO l_dtl_coll_id FROM dual ;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Collaboration Detail ID generated : '||l_dtl_coll_id,1);


                 ecx_cln_debug_pub.Add('----- Before SQL Query : Adding Details in CLN_COLL_HIST_DTL -----',1);
         END IF;

         -- Initial Collaboration Details are added into CLN_COLL_HIST_DTL Table
         --Bug 3655492 : Added nvl(p_doc_type,'UNKNOWN') for 11.5.10 performance enh, to make sure always Doc Type is not null
         INSERT INTO CLN_COLL_HIST_DTL(
                COLLABORATION_DTL_ID,COLLABORATION_ID,COLLABORATION_DOCUMENT_TYPE,
                DOCUMENT_DIRECTION,COLLABORATION_POINT,
                ORIGINATOR_REFERENCE,DOCUMENT_STATUS,NOTIFICATION_ID,MESSAGE_TEXT,CREATION_DATE,CREATED_BY,
                LAST_UPDATE_DATE,LAST_UPDATED_BY, LAST_UPDATE_LOGIN, XMLG_TRANSACTION_TYPE, XMLG_TRANSACTION_SUBTYPE,
                XMLG_DOCUMENT_ID, XMLG_MSG_ID, XMLG_INTERNAL_CONTROL_NUMBER,
                RESEND_FLAG, XMLG_INT_TRANSACTION_TYPE, XMLG_INT_TRANSACTION_SUBTYPE, XML_EVENT_KEY)
         VALUES(l_dtl_coll_id,p_coll_id,nvl(p_doc_type,'UNKNOWN'),p_doc_dir,p_coll_pt,p_org_ref,p_doc_status,
                p_notification_id,p_msg_text,SYSDATE,FND_GLOBAL.USER_ID,
                SYSDATE,FND_GLOBAL.USER_ID,FND_GLOBAL.LOGIN_ID, p_xmlg_transaction_type,
                p_xmlg_transaction_subtype,p_xmlg_document_id, p_xmlg_msg_id, p_xmlg_internal_control_number,
                p_resend_flag, p_xmlg_int_transaction_type, p_xmlg_int_transaction_subtype, p_xml_event_key);

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('----- After SQL Query : Adding Details in CLN_COLL_HIST_DTL -----',1);
         END IF;


         -- Check whether the above SQL Query resulted in some updations or not.
         IF SQL%FOUND THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration Details successfully entered in CLN_COLL_HIST_DTL TABLE',1);
                END IF;
         ELSE
                l_msg_data := 'Failed to add Collaboration Details in CLN_COLL_HIST_DTL TABLE';
                RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('--------- Exiting UPDATE_COLLABORATION_INIT API -------- ',2);
         END IF;

    -- Exception Handling
    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR ;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('--------- Exiting UPDATE_COLLABORATION_INIT API -------- ',2);
              END IF;

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              l_msg_data        :=l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('--------- Exiting UPDATE_COLLABORATION_INIT API -------- ',2);
              END IF;

         WHEN OTHERS THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              l_msg_data        :=l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('--------- Exiting UPDATE_COLLABORATION_INIT API -------- ',2);
              END IF;


    END UPDATE_COLLABORATION_INIT;



  -- Name
  --   CREATE_COLLABORATION
  -- Purpose
  --   This is the public procedure which starts a new Collaboration
  --   and adds the initial details corresponding to it in both the CLN_COLL_HIST_HDR
  --   and CLN_COLL_HIST_DTL Tables.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


    PROCEDURE CREATE_COLLABORATION(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_app_id                               IN  VARCHAR2,
         p_ref_id                               IN  VARCHAR2,
         p_org_id                               IN  NUMBER,
         p_rel_no                               IN  VARCHAR2,
         p_doc_no                               IN  VARCHAR2,
         p_doc_rev_no                           IN  VARCHAR2,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_xmlg_document_id                     IN  VARCHAR2,
         p_partner_doc_no                       IN  VARCHAR2,
         p_coll_type                            IN  VARCHAR2,
         p_tr_partner_type                      IN  VARCHAR2,
         p_tr_partner_id                        IN  VARCHAR2,
         p_tr_partner_site                      IN  VARCHAR2,
         p_resend_flag                          IN  VARCHAR2,
         p_resend_count                         IN  NUMBER,
         p_doc_owner                            IN  VARCHAR2,
         p_init_date                            IN  DATE,
         p_doc_creation_date                    IN  DATE,
         p_doc_revision_date                    IN  DATE,
         p_doc_type                             IN  VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_coll_pt                              IN  VARCHAR2,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2,
         p_unique2                              IN  VARCHAR2,
         p_unique3                              IN  VARCHAR2,
         p_unique4                              IN  VARCHAR2,
         p_unique5                              IN  VARCHAR2,
         p_sender_component                     IN  VARCHAR2,
         p_rosettanet_check_required            IN  BOOLEAN,
         x_coll_id                              OUT NOCOPY NUMBER,
         p_xmlg_internal_control_number         IN  NUMBER,
         p_xmlg_int_transaction_type            IN  VARCHAR2,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2,
         p_msg_text                             IN  VARCHAR2,
         p_xml_event_key                        IN  VARCHAR2,
         p_collaboration_standard               IN  VARCHAR2,
         p_attribute1                           IN  VARCHAR2,
         p_attribute2                           IN  VARCHAR2,
         p_attribute3                           IN  VARCHAR2,
         p_attribute4                           IN  VARCHAR2,
         p_attribute5                           IN  VARCHAR2,
         p_attribute6                           IN  VARCHAR2,
         p_attribute7                           IN  VARCHAR2,
         p_attribute8                           IN  VARCHAR2,
         p_attribute9                           IN  VARCHAR2,
         p_attribute10                          IN  VARCHAR2,
         p_attribute11                          IN  VARCHAR2,
         p_attribute12                          IN  VARCHAR2,
         p_attribute13                          IN  VARCHAR2,
         p_attribute14                          IN  VARCHAR2,
         p_attribute15                          IN  VARCHAR2,
         p_dattribute1                          IN  DATE,
         p_dattribute2                          IN  DATE,
         p_dattribute3                          IN  DATE,
         p_dattribute4                          IN  DATE,
         p_dattribute5                          IN  DATE,
         p_owner_role                           IN  VARCHAR2 )

    IS

         l_return_status                        VARCHAR2(30);
         l_error_code                           NUMBER;
         l_error_msg                            VARCHAR2(2000);
         l_msg_data                             VARCHAR2(2000);
         l_msg_text                             VARCHAR2(2000);
         l_debug_mode                           VARCHAR2(255);
         l_fnd_profile                          VARCHAR2(100);
         l_protocol_type                        VARCHAR2(5);
         l_update_reqd                          BOOLEAN;
         l_xmlg_internal_control_number         NUMBER;
         l_xmlg_msg_id                          VARCHAR2(100);
         l_xmlg_transaction_type                VARCHAR2(100);
         l_xmlg_transaction_subtype             VARCHAR2(100);
         l_xmlg_int_transaction_type            VARCHAR2(100);
         l_xmlg_int_transaction_subtype         VARCHAR2(100);
         l_xmlg_document_id                     VARCHAR2(256);
         l_doc_dir                              VARCHAR2(240);
         l_tr_partner_type                      VARCHAR2(30);
         l_tr_partner_id                        VARCHAR2(256);
         l_tr_partner_site                      VARCHAR2(256);
         l_sender_component                     VARCHAR2(500);
         l_app_id                               VARCHAR2(10);
         l_coll_type                            VARCHAR2(30);
         l_doc_type                             VARCHAR2(100);
         l_resend_flag                          VARCHAR2(1);
         l_doc_no                               VARCHAR2(255);
         l_coll_status                          VARCHAR2(10);
         l_ref_id                               VARCHAR2(100);
         l_doc_owner                            VARCHAR2(30);
         l_owner_role                           VARCHAR2(30);
         l_coll_pt                              VARCHAR2(20);
         l_xml_event_key                        VARCHAR2(240);
         l_rosettanet_check_required            BOOLEAN;
         l_collaboration_standard               VARCHAR2(30);
         l_doc_creation_date                    DATE;

    BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');


         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------ Entering CREATE_COLLABORATION API ------- ',2);
         END IF;



         -- Standard Start of API savepoint
         SAVEPOINT      CREATE_COLLABORATION_PUB;

         -- Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data      := 'Collaboration successfully created ';


         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('APPLCATION ID                 ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('REFERENCE ID                  ----- >>>'||p_ref_id,1);
                 ecx_cln_debug_pub.Add('ORG ID                        ----- >>>'||p_org_id,1);
                 ecx_cln_debug_pub.Add('RELEASE NUMBER                ----- >>>'||p_rel_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT NO                   ----- >>>'||p_doc_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REV. NO              ----- >>>'||p_doc_rev_no,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE     ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE  ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE     ----- >>>'||p_xmlg_int_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE  ----- >>>'||p_xmlg_int_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID              ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('PARTNER DOCUMENT NO           ----- >>>'||p_partner_doc_no,1);
                 ecx_cln_debug_pub.Add('COLLABORATION TYPE            ----- >>>'||p_coll_type,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER TYPE          ----- >>>'||p_tr_partner_type,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER ID            ----- >>>'||p_tr_partner_id,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER SITE          ----- >>>'||p_tr_partner_site,1);
                 ecx_cln_debug_pub.Add('RESENG FLAG                   ----- >>>'||p_resend_flag,1);
                 ecx_cln_debug_pub.Add('RESEND COUNT                  ----- >>>'||p_resend_count,1);
                 ecx_cln_debug_pub.Add('DOCUMENT OWNER                ----- >>>'||p_doc_owner,1);
                 ecx_cln_debug_pub.Add('OWNER ROLE                    ----- >>>'||p_owner_role,1);
                 ecx_cln_debug_pub.Add('INITIATION DATE               ----- >>>'||p_init_date,1);
                 ecx_cln_debug_pub.Add('DOCUMENT CREATION DATE        ----- >>>'||p_doc_creation_date,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REVISION DATE        ----- >>>'||p_doc_revision_date,1);
                 ecx_cln_debug_pub.Add('DOCUMENT TYPE                 ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION            ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('COLLABORATION POINT           ----- >>>'||p_coll_pt,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID               ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('UNIQUE 1                      ----- >>>'||p_unique1,1);
                 ecx_cln_debug_pub.Add('UNIQUE 2                      ----- >>>'||p_unique2,1);
                 ecx_cln_debug_pub.Add('UNIQUE 3                      ----- >>>'||p_unique3,1);
                 ecx_cln_debug_pub.Add('UNIQUE 4                      ----- >>>'||p_unique4,1);
                 ecx_cln_debug_pub.Add('UNIQUE 5                      ----- >>>'||p_unique5,1);
                 ecx_cln_debug_pub.Add('SENDER COMPONENT              ----- >>>'||p_sender_component,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO      ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('XMLG EVENT KEY                ----- >>>'||p_xml_event_key,1);
                 ecx_cln_debug_pub.Add('MSG TXT                       ----- >>>'||p_msg_text,1);
                 ecx_cln_debug_pub.Add('Collaboration Standard        ----- >>>'||p_collaboration_standard,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE1                    ----- >>>'||p_attribute1,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE2                    ----- >>>'||p_attribute2,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE3                    ----- >>>'||p_attribute3,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE4                    ----- >>>'||p_attribute4,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE5                    ----- >>>'||p_attribute5,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE6                    ----- >>>'||p_attribute6,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE7                    ----- >>>'||p_attribute7,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE8                    ----- >>>'||p_attribute8,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE9                    ----- >>>'||p_attribute9,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE10                   ----- >>>'||p_attribute10,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE11                   ----- >>>'||p_attribute11,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE12                   ----- >>>'||p_attribute12,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE13                   ----- >>>'||p_attribute13,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE14                   ----- >>>'||p_attribute14,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE15                   ----- >>>'||p_attribute15,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE1                   ----- >>>'||p_dattribute1,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE2                   ----- >>>'||p_dattribute2,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE3                   ----- >>>'||p_dattribute3,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE4                   ----- >>>'||p_dattribute4,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE5                   ----- >>>'||p_dattribute5,1);
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;

         -- Assigning parameter to local variables
         l_xmlg_internal_control_number   :=    p_xmlg_internal_control_number;
         l_xmlg_msg_id                    :=    p_xmlg_msg_id;
         l_xmlg_transaction_type          :=    p_xmlg_transaction_type;
         l_xmlg_transaction_subtype       :=    p_xmlg_transaction_subtype;
         l_xmlg_int_transaction_type      :=    p_xmlg_int_transaction_type;
         l_xmlg_int_transaction_subtype   :=    p_xmlg_int_transaction_subtype;
         l_xmlg_document_id               :=    p_xmlg_document_id;
         l_doc_dir                        :=    p_doc_dir;
         l_tr_partner_type                :=    p_tr_partner_type;
         l_tr_partner_id                  :=    p_tr_partner_id;
         l_tr_partner_site                :=    p_tr_partner_site;
         l_sender_component               :=    p_sender_component;
         l_app_id                         :=    p_app_id;
         l_coll_type                      :=    p_coll_type;
         l_doc_type                       :=    p_doc_type;
         l_ref_id                         :=    p_ref_id;
         l_doc_no                         :=    p_doc_no;
         l_doc_owner                      :=    p_doc_owner;
         l_owner_role                     :=    p_owner_role;
         l_coll_pt                        :=    p_coll_pt;
         l_rosettanet_check_required      :=    p_rosettanet_check_required;
         l_msg_text                       :=    p_msg_text;
         l_xml_event_key                  :=    p_xml_event_key;
         l_collaboration_standard         :=    p_collaboration_standard;
         l_doc_creation_date              :=    p_doc_creation_date;


         -- Set Default values.

         -- Removed as per bug #2641981.
         -- Check if document number is passed and set it to default if passed as null
         IF (p_doc_no IS NULL) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Document Number passed as NULL',1);
                END IF;
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_DOC_NUMBER_NOT_GEN');
                l_doc_no        := FND_MESSAGE.GET;
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Setting Document Number :'||l_doc_no,1);
                END IF;


         END IF;


         -- Check for the resend flag value and default it.
         IF (p_resend_count > 0) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Resend Flag is set to Y ',1);
                END IF;
                l_resend_flag   :=     'Y';
         END IF;


         -- If Document Owner passed is null
         IF ((l_doc_owner IS NULL) OR (l_doc_owner = '')) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Document Owner passed as NULL',1);
                END IF;
                l_doc_owner     :=      FND_GLOBAL.USER_ID;
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Document Owner set as  >>    '||l_doc_owner,1);
                END IF;
         END IF;

         -- If Collaboration Point passed is null
         IF ((l_coll_pt IS NULL) OR (l_coll_pt = '')) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration Point passed as NULL',1);
                END IF;
                l_coll_pt       :=      'APPS';
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration Point set as >>     '||l_coll_pt,1);
                END IF;
         END IF;

         -- If RosettaNet Check Reqd value is null
         IF (l_rosettanet_check_required IS NULL) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Rosettanet Check Reqd value passed as NULL',1);
                END IF;
                l_rosettanet_check_required     :=      TRUE;
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Rosettanet Check Reqd value set to true',1);
                END IF;
         END IF;


         -- Call the API to get the trading partner set up details
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Call to GET_TRADING_PARTNER_DETAILS API=============',1);
         END IF;
         GET_TRADING_PARTNER_DETAILS(
                 x_return_status                        => x_return_status,
                 x_msg_data                             => x_msg_data,
                 p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                 p_xmlg_msg_id                          => l_xmlg_msg_id,
                 p_xmlg_transaction_type                => l_xmlg_transaction_type,
                 p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                 p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                 p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                 p_xmlg_document_id                     => l_xmlg_document_id,
                 p_doc_dir                              => l_doc_dir,
                 p_tr_partner_type                      => l_tr_partner_type,
                 p_tr_partner_id                        => l_tr_partner_id,
                 p_tr_partner_site                      => l_tr_partner_site,
                 p_sender_component                     => l_sender_component,
                 p_xml_event_key                        => l_xml_event_key,
                 p_collaboration_standard               => l_collaboration_standard);

         IF ( x_return_status <> 'S') THEN
                 l_msg_data  := 'Error in GET_TRADING_PARTNER_DETAILS ';
                 -- x_msg_data is set to appropriate value by GET_TRADING_PARTNER_DETAILS
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('===========================================',1);


                 -- call the API to get the default parameters through XMLG settings
                 ecx_cln_debug_pub.Add('==========Call to DEFAULT_XMLGTXN_MAPPING API=============',1);
         END IF;
         DEFAULT_XMLGTXN_MAPPING(
                x_return_status                => x_return_status,
                x_msg_data                     => x_msg_data,
                p_xmlg_transaction_type        => l_xmlg_transaction_type,
                p_xmlg_transaction_subtype     => l_xmlg_transaction_subtype,
                p_doc_dir                      => l_doc_dir,
                p_app_id                       => l_app_id,
                p_coll_type                    => l_coll_type,
                p_doc_type                     => l_doc_type );

         IF ( x_return_status <> 'S') THEN
                l_msg_data      := 'Error in DEFAULT_XMLGTXN_MAPPING';
                -- x_msg_data is set to appropriate value by DEFAULT_XMLGTXN_MAPPING
                RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('===========================================',1);

         END IF;

         --  Check for required parameters
         IF((l_app_id IS NULL) OR (l_doc_dir IS NULL)) THEN
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_REQD_PARAMS_MISSING');
                FND_MESSAGE.SET_TOKEN('ACTION','create');
                x_msg_data      := FND_MESSAGE.GET;
                l_msg_data      := 'Failed to create Collaboration as required parameters Application ID/Document_Direction not found';
                RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- GET THE COLLABORATION STATUS HERE IF NOT PASSED
         IF (l_Debug_Level <= 1) THEN
                 IF (l_Debug_Level <= 1) THEN
                         ecx_cln_debug_pub.Add('==========Call to DEFAULT_COLLABORATION_STATUS API=============',1);
                 END IF;

         END IF;

         IF (l_coll_status IS NULL) THEN
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('Collaboration Status is NULL',1);
               END IF;

               DEFAULT_COLLABORATION_STATUS(
                        x_return_status           => x_return_status,
                        x_msg_data                => x_msg_data,
                        x_coll_status             => l_coll_status,
                        p_app_id                  => l_app_id,
                        p_coll_type               => l_coll_type,
                        p_doc_status              => 'SUCCESS',
                        p_doc_type                => l_doc_type,
                        p_doc_dir                 => l_doc_dir,
                        p_coll_id                 => null,
                        p_coll_standard           => l_collaboration_standard
			);

               IF ( x_return_status <> 'S') THEN
                        l_msg_data  := 'Error in DEFAULT_XMLGTXN_MAPPING';
                        -- x_msg_data is set to appropriate value by DEFAULT_XMLGTXN_MAPPING
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
           END IF;

         ecx_cln_debug_pub.Add('===========================================',1);

         -- Validation for few parameters by passing parameters to VALIDATE_PARAMS API
         VALIDATE_PARAMS(
                x_return_status,x_msg_data,l_app_id,l_doc_dir,
                l_doc_type,l_coll_status,l_coll_pt,
                l_coll_type,null,null);

         IF ( x_return_status <> 'S') THEN
                l_msg_data      := 'Validation of parameters failed';
                -- x_msg_data is set to appropriate value by VALIDATE_PARAMS
                RAISE FND_API.G_EXC_ERROR;
         END IF;


         -- RosettaNet Check Required or not.
         IF (l_rosettanet_check_required) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('RosettaNet Check is Required');
                END IF;

                -- Check whether collaboration can be created/upadted based on Profile, Protocol value
                IS_UPDATE_REQUIRED(
                        x_return_status, x_msg_data, l_doc_dir, l_xmlg_transaction_type,
                        l_xmlg_transaction_subtype, l_tr_partner_type, l_tr_partner_id,
                        l_tr_partner_site, l_sender_component, l_update_reqd );

                 IF (l_Debug_Level <= 1) THEN
                         ecx_cln_debug_pub.Add('Status Code Returned By IS_UPDATE_REQUIRED :'||x_return_status,1);
                 END IF;


                 IF (x_return_status <> 'S') THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_REQD_CRITERIA_FAIL');
                     x_msg_data := FND_MESSAGE.GET;
                     l_msg_data :='Failed to verify the required criteria for updating/creating collaboration';
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;
                 IF (l_update_reqd <> TRUE) THEN
                     IF (l_Debug_Level <= 1) THEN
                             ecx_cln_debug_pub.Add('Update Reqd as Returned By IS_UPDATE_REQUIRED -FALSE',1);
                     END IF;

                     -- x_msg_data is set to appropriate value by IS_UPDATE_REQUIRED
                     RETURN;
                 END IF;
         END IF;


         IF (l_collaboration_standard = 'OAG') and (l_doc_type <> 'CONFIRM_BOD' )
            and (l_doc_dir = 'OUT') and (l_ref_id is null)
            and (g_xmlg_oag_application_ref_id is not null) THEN
                 l_ref_id := g_xmlg_oag_application_ref_id;
                 g_xmlg_oag_application_ref_id := NULL;
         END IF;


         -- For OutBound Docs, If Ref id is null, we are obtaining it using xml payload parsing
         -- As an exception, for confirm bod outbound we need not take the reference id
         IF(l_ref_id IS NULL AND l_doc_dir = 'OUT'
                            AND l_doc_type <> 'CONFIRM_BOD'
                            AND l_xmlg_msg_id IS NOT NULL) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Application Reference ID is Null',1);
                END IF;

                GET_CONTROL_AREA_REFID(p_msgId       => l_xmlg_msg_id,
                              p_collaboration_standard => l_collaboration_standard,
                              x_app_ref_id  => l_ref_id,
			      p_app_id => l_app_id,
			      p_coll_type => l_coll_type);
         END IF;


         -- Collaboration ID is generated from a sequence.
         SELECT cln_collaboration_hdr_id_s.NEXTVAL INTO x_coll_id FROM dual;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Collaboration Id generated : '||x_coll_id,1);


                 ecx_cln_debug_pub.Add('----- Before SQL Query : Adding Details in CLN_COLL_HIST_HDR -----',1);
         END IF;

        IF (l_doc_creation_date is null and l_xmlg_msg_id is not null) THEN -- If collaboration history already doesnt have doc creation date and user hasnt passed it then we have to get it by parsing the payload
             Get_document_Creation_date(l_xmlg_msg_id,l_doc_creation_date);
        END IF;


         --Bug 3655492 : Added nvl(l_coll_type,'UNKNOWN') for 11.5.10 performance enh, to make sure always Collaboration Type is not null
         INSERT INTO CLN_COLL_HIST_HDR(
                COLLABORATION_ID,APPLICATION_ID,APPLICATION_REFERENCE_ID,ORG_ID,RELEASE_NO,DOCUMENT_NO,
                DOC_REVISION_NO,PARTNER_DOCUMENT_NO,COLLABORATION_TYPE,TRADING_PARTNER,RESEND_FLAG,
                RESEND_COUNT,DOCUMENT_OWNER,INITIATION_DATE,DOCUMENT_CREATION_DATE,DOCUMENT_REVISION_DATE,
                COLLABORATION_STATUS,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,XMLG_MSG_ID,UNIQUE_ID1,UNIQUE_ID2,UNIQUE_ID3,UNIQUE_ID4,UNIQUE_ID5,
                XMLG_TRANSACTION_TYPE, XMLG_TRANSACTION_SUBTYPE,XMLG_DOCUMENT_ID, TRADING_PARTNER_TYPE, TRADING_PARTNER_SITE,
                XMLG_INTERNAL_CONTROL_NUMBER, DOCUMENT_DIRECTION, XMLG_INT_TRANSACTION_TYPE, XMLG_INT_TRANSACTION_SUBTYPE,
                XML_EVENT_KEY, COLLABORATION_STANDARD,OWNER_ROLE,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,
                ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,
                ATTRIBUTE14,ATTRIBUTE15,DATTRIBUTE1,DATTRIBUTE2,DATTRIBUTE3,DATTRIBUTE4,DATTRIBUTE5 )
         VALUES( x_coll_id,l_app_id,l_ref_id,p_org_id,p_rel_no,l_doc_no,p_doc_rev_no,
                p_partner_doc_no,nvl(l_coll_type,'UNKNOWN'),l_tr_partner_id,l_resend_flag,p_resend_count,
                l_doc_owner,nvl(p_init_date,SYSDATE),l_doc_creation_date,p_doc_revision_date,l_coll_status,
                SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,FND_GLOBAL.LOGIN_ID,l_xmlg_msg_id,
                p_unique1,p_unique2,p_unique3,p_unique4,p_unique5,
                l_xmlg_transaction_type, l_xmlg_transaction_subtype, l_xmlg_document_id,l_tr_partner_type, l_tr_partner_site,
                l_xmlg_internal_control_number, l_doc_dir, l_xmlg_int_transaction_type, l_xmlg_int_transaction_subtype,
                l_xml_event_key, l_collaboration_standard,l_owner_role,p_attribute1,p_attribute2,p_attribute3,p_attribute4,p_attribute5,
                p_attribute6,p_attribute7,p_attribute8,p_attribute9,p_attribute10,p_attribute11,p_attribute12,p_attribute13,
                p_attribute14,p_attribute15, p_dattribute1,p_dattribute2,p_dattribute3,p_dattribute4,p_dattribute5 );

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('------ After SQL Query : Adding Details in CLN_COLL_HIST_HDR --------',1);
         END IF;



         IF SQL%FOUND THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration Details successfully entered in CLN_COLL_HIST_HDR TABLE',1);
                END IF;

         ELSE
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_ADD_DTLS_FAILED');
                FND_MESSAGE.SET_TOKEN('TABLE','CLN_COLL_HIST_HDR');
                x_msg_data      := FND_MESSAGE.GET;
                l_msg_data      := 'Failed to add Collaboration Details in CLN_COLL_HIST_HDR TABLE';
                RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF(l_msg_text IS NULL) THEN
                l_msg_text      :=      'CLN_CH_COLLABORATION_CREATED';
         END IF;


         --FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_CREATED');
         -- Calling UPDATE_COLLABORATION_INIT API

         UPDATE_COLLABORATION_INIT(
                x_return_status,x_coll_id,l_doc_type,l_doc_dir,l_coll_pt,l_doc_no,'SUCCESS',null,
                l_msg_text, l_xmlg_transaction_type, l_xmlg_transaction_subtype, l_xmlg_document_id,
                l_xmlg_msg_id, l_xmlg_internal_control_number, l_resend_flag, l_xmlg_int_transaction_type,
                l_xmlg_int_transaction_subtype, l_xml_event_key );

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Status Code Returned By UPDATE_COLLABORATION_INIT :'||x_return_status,1);
         END IF;


         IF x_return_status <> 'S' THEN
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_ADD_DTLS_FAILED');
                FND_MESSAGE.SET_TOKEN('TABLE','CLN_COLL_HIST_DTL');
                x_msg_data      := FND_MESSAGE.GET;
                l_msg_data      := 'Failed to add Collaboration Details in CLN_COLL_HIST_DTL TABLE';
                RAISE FND_API.G_EXC_ERROR;
         END IF;

         FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_CREATED');
         x_msg_data      := FND_MESSAGE.GET;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add(l_msg_data,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------- Exiting CREATE_COLLABORATION API ---------- ',2);
         END IF;


    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_COLLABORATION_PUB;
              x_return_status :=FND_API.G_RET_STS_ERROR ;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('------- Exiting CREATE_COLLABORATION API ---------- ',2);
              END IF;



         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_COLLABORATION_PUB;
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        :=FND_MESSAGE.GET;
              l_msg_data        :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('------- Exiting CREATE_COLLABORATION API ---------- ',2);
              END IF;



         WHEN OTHERS THEN
              ROLLBACK TO CREATE_COLLABORATION_PUB;
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        :=FND_MESSAGE.GET;
              l_msg_data        :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('------- Exiting CREATE_COLLABORATION API ---------- ',2);
              END IF;

    END CREATE_COLLABORATION;



  -- Name
  --   UPDATE_COLLABORATION
  -- Purpose
  --   This is the public procedure which is called at subsequent stages after creation,
  --   to update collaboration with the progress.It creates a new row in the CLN_COLL_HIST_DTL
  --   table and also modifies the CLN_COLL_HIST_HDR if the need may be.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


    PROCEDURE UPDATE_COLLABORATION(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER,
         p_app_id                               IN  VARCHAR2,
         p_ref_id                               IN  VARCHAR2,
         p_rel_no                               IN  VARCHAR2,
         p_doc_no                               IN  VARCHAR2,
         p_doc_rev_no                           IN  VARCHAR2,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_xmlg_document_id                     IN  VARCHAR2,
         p_resend_flag                          IN  VARCHAR2,
         p_resend_count                         IN  NUMBER,
         p_disposition                          IN  VARCHAR2,
         p_coll_status                          IN  VARCHAR2,
         p_doc_type                             IN  VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_coll_pt                              IN  VARCHAR2,
         p_org_ref                              IN  VARCHAR2,
         p_doc_status                           IN  VARCHAR2,
         p_notification_id                      IN  VARCHAR2,
         p_msg_text                             IN  VARCHAR2,
         p_bsr_verb                             IN  VARCHAR2,
         p_bsr_noun                             IN  VARCHAR2,
         p_bsr_rev                              IN  VARCHAR2,
         p_sdr_logical_id                       IN  VARCHAR2,
         p_sdr_component                        IN  VARCHAR2,
         p_sdr_task                             IN  VARCHAR2,
         p_sdr_refid                            IN  VARCHAR2,
         p_sdr_confirmation                     IN  VARCHAR2,
         p_sdr_language                         IN  VARCHAR2,
         p_sdr_codepage                         IN  VARCHAR2,
         p_sdr_authid                           IN  VARCHAR2,
         p_sdr_datetime_qualifier               IN  VARCHAR2,
         p_sdr_datetime                         IN  VARCHAR2,
         p_sdr_timezone                         IN  VARCHAR2,
         p_attr1                                IN  VARCHAR2,
         p_attr2                                IN  VARCHAR2,
         p_attr3                                IN  VARCHAR2,
         p_attr4                                IN  VARCHAR2,
         p_attr5                                IN  VARCHAR2,
         p_attr6                                IN  VARCHAR2,
         p_attr7                                IN  VARCHAR2,
         p_attr8                                IN  VARCHAR2,
         p_attr9                                IN  VARCHAR2,
         p_attr10                               IN  VARCHAR2,
         p_attr11                               IN  VARCHAR2,
         p_attr12                               IN  VARCHAR2,
         p_attr13                               IN  VARCHAR2,
         p_attr14                               IN  VARCHAR2,
         p_attr15                               IN  VARCHAR2,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2,
         p_unique2                              IN  VARCHAR2,
         p_unique3                              IN  VARCHAR2,
         p_unique4                              IN  VARCHAR2,
         p_unique5                              IN  VARCHAR2,
         p_tr_partner_type                      IN  VARCHAR2,
         p_tr_partner_id                        IN  VARCHAR2,
         p_tr_partner_site                      IN  VARCHAR2,
         p_sender_component                     IN  VARCHAR2,
         p_rosettanet_check_required            IN  BOOLEAN,
         x_dtl_coll_id                          OUT NOCOPY NUMBER,
         p_xmlg_internal_control_number         IN  NUMBER,
         p_partner_doc_no                       IN  VARCHAR2,
         p_org_id                               IN  NUMBER,
         p_doc_creation_date                    IN  DATE,
         p_doc_revision_date                    IN  DATE,
         p_doc_owner                            IN  VARCHAR2,
         p_xmlg_int_transaction_type            IN  VARCHAR2,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2,
         p_xml_event_key                        IN  VARCHAR2,
         p_collaboration_standard               IN  VARCHAR2,
         p_attribute1                           IN  VARCHAR2,
         p_attribute2                           IN  VARCHAR2,
         p_attribute3                           IN  VARCHAR2,
         p_attribute4                           IN  VARCHAR2,
         p_attribute5                           IN  VARCHAR2,
         p_attribute6                           IN  VARCHAR2,
         p_attribute7                           IN  VARCHAR2,
         p_attribute8                           IN  VARCHAR2,
         p_attribute9                           IN  VARCHAR2,
         p_attribute10                          IN  VARCHAR2,
         p_attribute11                          IN  VARCHAR2,
         p_attribute12                          IN  VARCHAR2,
         p_attribute13                          IN  VARCHAR2,
         p_attribute14                          IN  VARCHAR2,
         p_attribute15                          IN  VARCHAR2,
         p_dattribute1                          IN  DATE,
         p_dattribute2                          IN  DATE,
         p_dattribute3                          IN  DATE,
         p_dattribute4                          IN  DATE,
         p_dattribute5                          IN  DATE,
         p_owner_role                           IN  VARCHAR2 )
IS
         l_dtl_coll_id                          NUMBER;
         l_coll_id                              NUMBER;
         l_error_code                           NUMBER;
         l_error_msg                            VARCHAR2(2000);
         l_msg_data                             VARCHAR2(2000);
         l_debug_mode                           VARCHAR2(255);
         l_update_reqd                          BOOLEAN;
         l_collaboration_found                  BOOLEAN;
         l_xmlg_internal_control_number         NUMBER;
         l_xmlg_msg_id                          VARCHAR2(100);
         l_xmlg_transaction_type                VARCHAR2(100);
         l_xmlg_transaction_subtype             VARCHAR2(100);
         l_xmlg_int_transaction_type            VARCHAR2(100);
         l_xmlg_int_transaction_subtype         VARCHAR2(100);
         l_xmlg_document_id                     VARCHAR2(256);
         l_doc_dir                              VARCHAR2(240);
         l_tr_partner_type                      VARCHAR2(30);
         l_tr_partner_id                        VARCHAR2(256);
         l_tr_partner_site                      VARCHAR2(256);
         l_sender_component                     VARCHAR2(500);
         l_app_id                               VARCHAR2(10);
         l_coll_type                            VARCHAR2(30);
         l_doc_type                             VARCHAR2(100);
         l_resend_flag                          VARCHAR2(1);
         l_coll_status                          VARCHAR2(10);
         l_msg_text                             VARCHAR2(2000);
         l_ref_id                               VARCHAR2(100);
         l_doc_owner                            VARCHAR2(30);
         l_owner_role                           VARCHAR2(30);
         l_coll_pt                              VARCHAR2(20);
         l_doc_status                           VARCHAR2(10);
         l_xml_event_key                        VARCHAR2(240);
         l_rosettanet_check_required            BOOLEAN;
         l_collaboration_standard               VARCHAR2(30);
         l_doc_creation_date                    DATE;


    BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');


         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('--------- Entering UPDATE_COLLABORATION API ------------ ',2);
         END IF;


         -- Standard Start of API savepoint
         -- SAVEPOINT    UPDATE_COLLABORATION_PUB;


         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data     := 'Collaboration successfully updated ';


         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('COLLABORATION ID                    ----- >>>'||p_coll_id,1);
                 ecx_cln_debug_pub.Add('APPLCATION ID                       ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('REFERENCE ID                        ----- >>>'||p_ref_id,1);
                 ecx_cln_debug_pub.Add('RELEASE NUMBER                      ----- >>>'||p_rel_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT NO                         ----- >>>'||p_doc_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REV. NO                    ----- >>>'||p_doc_rev_no,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE           ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE        ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE           ----- >>>'||p_xmlg_int_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE        ----- >>>'||p_xmlg_int_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID                    ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('RESENG FLAG                         ----- >>>'||p_resend_flag,1);
                 ecx_cln_debug_pub.Add('RESEND COUNT                        ----- >>>'||p_resend_count,1);
                 ecx_cln_debug_pub.Add('DISPOSITION                         ----- >>>'||p_disposition,1);
                 ecx_cln_debug_pub.Add('COLLABORATION STATUS                ----- >>>'||p_coll_status,1);
                 ecx_cln_debug_pub.Add('DOCUMENT TYPE                       ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION                  ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('COLLABORATION POINT                 ----- >>>'||p_coll_pt,1);
                 ecx_cln_debug_pub.Add('ORIGINATOR REFERENCE                ----- >>>'||p_org_ref,1);
                 ecx_cln_debug_pub.Add('DOCUMENT STATUS                     ----- >>>'||p_doc_status,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION ID                     ----- >>>'||p_notification_id,1);
                 ecx_cln_debug_pub.Add('MESSAGE TEST                        ----- >>>'||p_msg_text,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID                     ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('UNIQUE 1                            ----- >>>'||p_unique1,1);
                 ecx_cln_debug_pub.Add('UNIQUE 2                            ----- >>>'||p_unique2,1);
                 ecx_cln_debug_pub.Add('UNIQUE 3                            ----- >>>'||p_unique3,1);
                 ecx_cln_debug_pub.Add('UNIQUE 4                            ----- >>>'||p_unique4,1);
                 ecx_cln_debug_pub.Add('UNIQUE 5                            ----- >>>'||p_unique5,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER TYPE                ----- >>>'||p_tr_partner_type,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER ID                  ----- >>>'||p_tr_partner_id,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER SITE                ----- >>>'||p_tr_partner_site,1);
                 ecx_cln_debug_pub.Add('SENDER COMPONENT                    ----- >>>'||p_sender_component,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO            ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('PARTNER DOCUMENT NO                 ----- >>>'||p_partner_doc_no,1);
                 ecx_cln_debug_pub.Add('ORG ID                              ----- >>>'||p_org_id,1);
                 ecx_cln_debug_pub.Add('DOCUMENT CREATION DATE              ----- >>>'||p_doc_creation_date,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REVISION DATE              ----- >>>'||p_doc_revision_date,1);
                 ecx_cln_debug_pub.Add('DOCUMENT OWNER                      ----- >>>'||p_doc_owner,1);
                 ecx_cln_debug_pub.Add('OWNER ROLE                          ----- >>>'||p_owner_role,1);
                 ecx_cln_debug_pub.Add('XMLG EVENT KEY                      ----- >>>'||p_xml_event_key,1);
                 ecx_cln_debug_pub.Add('Collaboration Standard              ----- >>>'||p_collaboration_standard,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE1                          ----- >>>'||p_attribute1,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE2                          ----- >>>'||p_attribute2,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE3                          ----- >>>'||p_attribute3,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE4                          ----- >>>'||p_attribute4,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE5                          ----- >>>'||p_attribute5,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE6                          ----- >>>'||p_attribute6,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE7                          ----- >>>'||p_attribute7,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE8                          ----- >>>'||p_attribute8,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE9                          ----- >>>'||p_attribute9,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE10                         ----- >>>'||p_attribute10,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE11                         ----- >>>'||p_attribute11,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE12                         ----- >>>'||p_attribute12,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE13                         ----- >>>'||p_attribute13,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE14                         ----- >>>'||p_attribute14,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE15                         ----- >>>'||p_attribute15,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE1                         ----- >>>'||p_dattribute1,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE2                         ----- >>>'||p_dattribute2,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE3                         ----- >>>'||p_dattribute3,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE4                         ----- >>>'||p_dattribute4,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE5                         ----- >>>'||p_dattribute5,1);
                 ecx_cln_debug_pub.Add('=========================================================',1);
         END IF;



         -- assigning parameter to local variables
         l_xmlg_internal_control_number   :=    p_xmlg_internal_control_number;
         l_xmlg_msg_id                    :=    p_xmlg_msg_id;
         l_xmlg_transaction_type          :=    p_xmlg_transaction_type;
         l_xmlg_transaction_subtype       :=    p_xmlg_transaction_subtype;
         l_xmlg_int_transaction_type      :=    p_xmlg_int_transaction_type;
         l_xmlg_int_transaction_subtype   :=    p_xmlg_int_transaction_subtype;
         l_xmlg_document_id               :=    p_xmlg_document_id;
         l_doc_dir                        :=    p_doc_dir;
         l_tr_partner_type                :=    p_tr_partner_type;
         l_tr_partner_id                  :=    p_tr_partner_id;
         l_tr_partner_site                :=    p_tr_partner_site;
         l_sender_component               :=    p_sender_component;
         l_app_id                         :=    p_app_id;
         l_doc_type                       :=    p_doc_type;
         l_coll_status                    :=    p_coll_status;
         l_msg_text                       :=    ltrim(rtrim(p_msg_text));
         l_ref_id                         :=    p_ref_id;
         l_doc_owner                      :=    p_doc_owner;
         l_owner_role                     :=    p_owner_role;
         l_coll_pt                        :=    p_coll_pt;
         l_doc_status                     :=    p_doc_status;
         l_rosettanet_check_required      :=    p_rosettanet_check_required;
         l_xml_event_key                  :=    p_xml_event_key;
         l_collaboration_standard         :=    P_collaboration_standard;
         l_doc_creation_date              :=    p_doc_creation_date;

         -- enhancement done to support translation issues //15-Nov-2002
         l_msg_text := p_msg_text;

         -- Set Default values.
         -- Check for the Resend Flag value and default it.
         IF (p_resend_count > 0) THEN
                l_resend_flag   :=     'Y';
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Resend Flag is set to Y ',1);
                END IF;

         END IF;

         -- If Document Owner passed is null
         IF ((l_doc_owner IS NULL) OR (l_doc_owner = '')) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Document Owner passed as  NULL',1);
                END IF;

                l_doc_owner     :=      FND_GLOBAL.USER_ID;
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Document Owner set as '||l_doc_owner,1);
                END IF;

         END IF;

         -- If Collaboration Point passed is null
         IF ((l_coll_pt IS NULL) OR (l_coll_pt = '')) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration Point  NULL',1);
                END IF;

                l_coll_pt       :=      'APPS';
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration Point is -- '||l_coll_pt,1);
                END IF;

         END IF;

         -- If Document Status passed is null
         IF ((l_doc_status IS NULL) OR (l_doc_status = '')) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Document Status passed as NULL',1);
                END IF;

                l_doc_status     :=      'SUCCESS';
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Document Status set as  '||l_doc_status,1);
                END IF;

         END IF;

         -- If RosettaNet Check Reqd value is null
         IF (l_rosettanet_check_required IS NULL) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Rosettanet Check Reqd value passed as NULL',1);
                END IF;

                l_rosettanet_check_required     :=      TRUE;
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Rosettanet Check Reqd value set to true',1);
                END IF;

         END IF;

         -- call the API to get the trading partner set up details
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Call to GET_TRADING_PARTNER_DETAILS API=============',1);
         END IF;


         GET_TRADING_PARTNER_DETAILS(
                 x_return_status                        => x_return_status,
                 x_msg_data                             => x_msg_data,
                 p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                 p_xmlg_msg_id                          => l_xmlg_msg_id,
                 p_xmlg_transaction_type                => l_xmlg_transaction_type,
                 p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                 p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                 p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                 p_xmlg_document_id                     => l_xmlg_document_id,
                 p_doc_dir                              => l_doc_dir,
                 p_tr_partner_type                      => l_tr_partner_type,
                 p_tr_partner_id                        => l_tr_partner_id,
                 p_tr_partner_site                      => l_tr_partner_site,
                 p_sender_component                     => l_sender_component,
                 p_xml_event_key                        => l_xml_event_key,
                 p_collaboration_standard               => l_collaboration_standard);

         IF ( x_return_status <> 'S') THEN
                 l_msg_data  := 'Error in GET_TRADING_PARTNER_DETAILS ';
                 -- x_msg_data is set to appropriate value by GET_TRADING_PARTNER_DETAILS
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;




         -- call the API to get the default parameters through XMLG settings
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Call to DEFAULT_XMLGTXN_MAPPING API=============',1);
         END IF;

         DEFAULT_XMLGTXN_MAPPING(
                x_return_status                => x_return_status,
                x_msg_data                     => x_msg_data,
                p_xmlg_transaction_type        => l_xmlg_transaction_type,
                p_xmlg_transaction_subtype     => l_xmlg_transaction_subtype,
                p_doc_dir                      => l_doc_dir,
                p_app_id                       => l_app_id,
                p_coll_type                    => l_coll_type,
                p_doc_type                     => l_doc_type );

         IF ( x_return_status <> 'S') THEN
                l_msg_data  := 'Error in DEFAULT_XMLGTXN_MAPPING';
                -- x_msg_data is set to appropriate value by DEFAULT_XMLGTXN_MAPPING
                RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;



         -- RosettaNet Check Required or not.
         IF (l_rosettanet_check_required ) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('RosettaNet Check is Required');
                END IF;


                -- Check whether collaboration can be created/upadted based on Profile, Protocol value
                IS_UPDATE_REQUIRED(
                        x_return_status, x_msg_data, l_doc_dir, l_xmlg_transaction_type,
                        l_xmlg_transaction_subtype, l_tr_partner_type, l_tr_partner_id,
                        l_tr_partner_site, l_sender_component, l_update_reqd );

                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Status Code Returned By IS_UPDATE_REQUIRED :'||x_return_status,1);
                END IF;


                IF (x_return_status <> 'S') THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_REQD_CRITERIA_FAIL');
                     x_msg_data := FND_MESSAGE.GET;
                     l_msg_data:='Failed to verify the required criteria for updating/creating collaboration';
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_update_reqd <> TRUE) THEN
                     IF (l_Debug_Level <= 1) THEN
                             ecx_cln_debug_pub.Add('Update Reqd as Returned By IS_UPDATE_REQUIRED -FALSE',1);
                     END IF;

                     -- x_msg_data is set to appropriate value by IS_UPDATE_REQUIRED
                     RETURN;
                END IF;
         END IF;


         -- set the message text to default value if found null
         IF (l_msg_text IS NULL OR ltrim(rtrim(l_msg_text)) = '') THEN
                 FND_MESSAGE.SET_NAME('CLN','CLN_CH_DEFAULT_MSG_TXT');
                 l_msg_text := FND_MESSAGE.GET;
                 IF (l_Debug_Level <= 1) THEN
                         ecx_cln_debug_pub.Add('Message Text Value is NULL, Defaulting to : '||l_msg_text,1);
                 END IF;

         END IF;


         -- Remove the comma at the last of message if it is there.First trim the message for possible spaces.
         l_msg_text       :=      ltrim(rtrim(l_msg_text));
         IF ( substr(l_msg_text,-1) )= ',' THEN
                l_msg_text:= substr( l_msg_text, 0, length(l_msg_text) - 1);
         END IF;


         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('l_ref_id       -- '||l_ref_id,1);
                 ecx_cln_debug_pub.Add('l_doc_dir      -- '||l_doc_dir,1);
                 ecx_cln_debug_pub.Add('l_xmlg_msg_id  -- '||l_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('l_doc_type     -- '||l_doc_type,1);
         END IF;


         -- Defaulting Application Reference ID

         IF (l_collaboration_standard = 'OAG') and (l_doc_type <> 'CONFIRM_BOD' )
            and (l_doc_dir = 'OUT') and (l_ref_id is null)
            and (g_xmlg_oag_application_ref_id is not null) THEN
                 l_ref_id := g_xmlg_oag_application_ref_id;
                 g_xmlg_oag_application_ref_id := NULL;
         END IF;



         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('---- Before the call to  GET_REFERENCE_ID Modified-----',1);
         END IF;

         IF(l_ref_id IS NULL AND l_doc_dir = 'OUT'
                            AND l_doc_type <> 'CONFIRM_BOD'
                            AND l_xmlg_msg_id IS NOT NULL) THEN
                GET_CONTROL_AREA_REFID(p_msgId       => l_xmlg_msg_id,
                              p_collaboration_standard => l_collaboration_standard,
                              x_app_ref_id  => l_ref_id,
			      p_app_id => l_app_id,
			      p_coll_type => l_coll_type);
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Application reference id -- ' || l_ref_id, 1);
         END IF;



         --Assign the value of collaboration id to a local variable
         l_coll_id      :=p_coll_id;

         -- Retrieving Collaboration ID incase the value supplied by user is null
        IF l_coll_id IS NULL THEN
             IF (l_Debug_Level <= 1) THEN
                     ecx_cln_debug_pub.Add('Collaboration ID passed as null',1);
                     ecx_cln_debug_pub.Add('==========Call to FIND_COLLABORATION_ID API=============',1);
             END IF;

             FIND_COLLABORATION_ID(
                    x_return_status                        => x_return_status,
                    x_msg_data                             => x_msg_data,
                    x_coll_id                              => l_coll_id,
                    p_app_id                               => l_app_id,
		    p_coll_type                            => l_coll_type,
                    p_ref_id                               => l_ref_id,
                    p_xmlg_transaction_type                => l_xmlg_transaction_type,
                    p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                    p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                    p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                    p_tr_partner_type                      => l_tr_partner_type,
                    p_tr_partner_id                        => l_tr_partner_id,
                    p_tr_partner_site                      => l_tr_partner_site,
                    p_xmlg_document_id                     => l_xmlg_document_id,
                    p_doc_dir                              => l_doc_dir,
                    p_xmlg_msg_id                          => l_xmlg_msg_id,
                    p_unique1                              => p_unique1,
                    p_unique2                              => p_unique2,
                    p_unique3                              => p_unique3,
                    p_unique4                              => p_unique4,
                    p_unique5                              => p_unique5,
                    p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                    p_xml_event_key                        => l_xml_event_key);

             IF ( x_return_status <> 'S') THEN
                    l_msg_data  := 'Error in FIND_COLLABORATION_ID - ' || x_msg_data;
                    -- x_msg_data is set to appropriate value by FIND_COLLABORATION_ID
                    RAISE FND_API.G_EXC_ERROR;
             END IF;

        END IF;

        IF l_coll_id IS NULL THEN
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_NOT_FOUND');
                x_msg_data := FND_MESSAGE.GET;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- If Application ID or Collaboration Type is null (this may be the case when the
        -- document type is CONFIRM_BOD ), we need to get these values from the collaboration
        -- history for these are reqd to get the default status.


        IF (l_Debug_Level <= 1) THEN
            ecx_cln_debug_pub.Add('--- Before the query to find the Application ID/Collaboration Type----',1);
        END IF;

        SELECT APPLICATION_ID, COLLABORATION_TYPE, DOCUMENT_CREATION_DATE
        INTO l_app_id, l_coll_type, l_doc_creation_date
        FROM CLN_COLL_HIST_HDR
        WHERE COLLABORATION_ID  =       l_coll_id;

        IF (l_Debug_Level <= 1) THEN
             ecx_cln_debug_pub.Add('--- After the query to find the Application ID/Collaboration Type----',1);
             ecx_cln_debug_pub.Add('Application ID obtained as           - '||l_app_id,1);
             ecx_cln_debug_pub.Add('Collaboration Type obtained as       - '||l_coll_type,1);
        END IF;

        IF( p_doc_creation_date is not null) THEN
            l_doc_creation_date := p_doc_creation_date;
        ELSIF (l_doc_creation_date is null and l_xmlg_msg_id is not null) THEN -- If collaboration history already doesnt have doc creation date and user hasnt passed it then we have to get it by parsing the payload
             Get_document_Creation_date(l_xmlg_msg_id,l_doc_creation_date);
        END IF;



         -- GET THE COLLABORATION STATUS HERE IF NOT PASSED
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Call to DEFAULT_COLLABORATION_STATUS API=============',1);
         END IF;


         IF (l_coll_status IS NULL) THEN
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('Collaboration Status is NULL',1);
               END IF;

               DEFAULT_COLLABORATION_STATUS(
                        x_return_status           => x_return_status,
                        x_msg_data                => x_msg_data,
                        x_coll_status             => l_coll_status,
                        p_app_id                  => l_app_id,
                        p_coll_type               => l_coll_type,
                        p_doc_status              => l_doc_status,
                        p_doc_type                => l_doc_type,
                        p_doc_dir                 => l_doc_dir,
                        p_coll_id                 => l_coll_id,
                        p_coll_standard           => l_collaboration_standard
			);

               IF ( x_return_status <> 'S') THEN
                        l_msg_data  := 'Error in DEFAULT_XMLGTXN_MAPPING';
                        -- x_msg_data is set to appropriate value by DEFAULT_XMLGTXN_MAPPING
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
           END IF;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;


         --  Check for required parameters
         IF((l_coll_status IS NULL) OR (l_doc_dir IS NULL)) THEN
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_REQD_PARAMS_MISSING');
                FND_MESSAGE.SET_TOKEN('ACTION','update');
                x_msg_data      := FND_MESSAGE.GET;
                l_msg_data      := 'Failed to update Collaboration as required parameters  Collaboration Status / Document Direction not found';
                RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Validation for few parameters by passing parameters to VALIDATE_PARAMS API
         VALIDATE_PARAMS(
                x_return_status,x_msg_data,l_app_id,l_doc_dir,
                l_doc_type,l_coll_status,l_coll_pt,
                null,null,p_disposition);

         IF ( x_return_status <> 'S') THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Validation of parameters failed',1);
                END IF;

                -- x_msg_data is set to appropriate value by VALIDATE_PARAMS
                RAISE FND_API.G_EXC_ERROR;
         END IF;


        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('--- Before SQL Query : Updating CLN_COLL_HIST_HDR ---',1);
        END IF;


        UPDATE CLN_COLL_HIST_HDR
        SET     APPLICATION_ID                          =       NVL(l_app_id,APPLICATION_ID),
                APPLICATION_REFERENCE_ID                =       NVL(l_ref_id,APPLICATION_REFERENCE_ID),
                RELEASE_NO                              =       NVL(p_rel_no,RELEASE_NO),
                DOC_REVISION_NO                         =       NVL(p_doc_rev_no,DOC_REVISION_NO),
                RESEND_FLAG                             =       NVL(l_resend_flag,RESEND_FLAG),
                RESEND_COUNT                            =       NVL(p_resend_count,RESEND_COUNT),
                DISPOSITION                             =       NVL(p_disposition,DISPOSITION),
                COLLABORATION_STATUS                    =       NVL(l_coll_status,COLLABORATION_STATUS),
                DOCUMENT_NO                             =       NVL(p_doc_no,DOCUMENT_NO),
                XMLG_MSG_ID                             =       NVL(l_xmlg_msg_id,XMLG_MSG_ID),
                XMLG_TRANSACTION_TYPE                   =       NVL(l_xmlg_transaction_type,XMLG_TRANSACTION_TYPE),
                XMLG_TRANSACTION_SUBTYPE                =       NVL(l_xmlg_transaction_subtype,XMLG_TRANSACTION_SUBTYPE),
                XMLG_INT_TRANSACTION_TYPE               =       NVL(l_xmlg_int_transaction_type,XMLG_INT_TRANSACTION_TYPE),
                XMLG_INT_TRANSACTION_SUBTYPE            =       NVL(l_xmlg_int_transaction_subtype,XMLG_INT_TRANSACTION_SUBTYPE),
                XMLG_DOCUMENT_ID                        =       NVL(l_xmlg_document_id,XMLG_DOCUMENT_ID),
                UNIQUE_ID1                              =       NVL(p_unique1,UNIQUE_ID1),
                UNIQUE_ID2                              =       NVL(p_unique2,UNIQUE_ID2),
                UNIQUE_ID3                              =       NVL(p_unique3,UNIQUE_ID3),
                UNIQUE_ID4                              =       NVL(p_unique4,UNIQUE_ID4),
                UNIQUE_ID5                              =       NVL(p_unique5,UNIQUE_ID5),
                XMLG_INTERNAL_CONTROL_NUMBER            =       NVL(l_xmlg_internal_control_number,XMLG_INTERNAL_CONTROL_NUMBER),
                DOCUMENT_DIRECTION                      =       NVL(l_doc_dir,DOCUMENT_DIRECTION),
                PARTNER_DOCUMENT_NO                     =       NVL(p_partner_doc_no,PARTNER_DOCUMENT_NO),
                ORG_ID                                  =       NVL(p_org_id,ORG_ID),
                DOCUMENT_CREATION_DATE                  =       NVL(DOCUMENT_CREATION_DATE,l_doc_creation_date),
                DOCUMENT_REVISION_DATE                  =       NVL(p_doc_revision_date,DOCUMENT_REVISION_DATE),
                DOCUMENT_OWNER                          =       NVL(l_doc_owner,DOCUMENT_OWNER),
                XML_EVENT_KEY                           =       NVL(l_xml_event_key, XML_EVENT_KEY),
                COLLABORATION_STANDARD                  =       NVL(p_collaboration_standard,NVL(COLLABORATION_STANDARD,l_collaboration_standard)),
                ATTRIBUTE1                              =       NVL(p_attribute1 ,ATTRIBUTE1),
                ATTRIBUTE2                              =       NVL(p_attribute2 ,ATTRIBUTE2),
                ATTRIBUTE3                              =       NVL(p_attribute3 ,ATTRIBUTE3),
                ATTRIBUTE4                              =       NVL(p_attribute4 ,ATTRIBUTE4),
                ATTRIBUTE5                              =       NVL(p_attribute5 ,ATTRIBUTE5),
                ATTRIBUTE6                              =       NVL(p_attribute6 ,ATTRIBUTE6),
                ATTRIBUTE7                              =       NVL(p_attribute7 ,ATTRIBUTE7),
                ATTRIBUTE8                              =       NVL(p_attribute8 ,ATTRIBUTE8),
                ATTRIBUTE9                              =       NVL(p_attribute9 ,ATTRIBUTE9),
                ATTRIBUTE10                             =       NVL(p_attribute10 ,ATTRIBUTE10),
                ATTRIBUTE11                             =       NVL(p_attribute11 ,ATTRIBUTE11),
                ATTRIBUTE12                             =       NVL(p_attribute12 ,ATTRIBUTE12),
                ATTRIBUTE13                             =       NVL(p_attribute13 ,ATTRIBUTE13),
                ATTRIBUTE14                             =       NVL(p_attribute14 ,ATTRIBUTE14),
                ATTRIBUTE15                             =       NVL(p_attribute15 ,ATTRIBUTE15),
                DATTRIBUTE1                             =       NVL(p_dattribute1 ,DATTRIBUTE1),
                DATTRIBUTE2                             =       NVL(p_dattribute2 ,DATTRIBUTE2),
                DATTRIBUTE3                             =       NVL(p_dattribute3 ,DATTRIBUTE3),
                DATTRIBUTE4                             =       NVL(p_dattribute4 ,DATTRIBUTE4),
                DATTRIBUTE5                             =       NVL(p_dattribute5 ,DATTRIBUTE5),
                OWNER_ROLE                              =       NVL(p_owner_role,OWNER_ROLE)
        WHERE   (COLLABORATION_ID = l_coll_id);
        /* Note on collaboraiton standard update in the above query
        ------------------------------------------------------------
        1. The criteria is, if caller passes collaboration standard to the API explicitely,
        then the column has to be updated with that value.
        2. If caller doesnt pass and if the column is already filled in,
        then the value of the column should be unchanged
        3. If caller doesnt pass and if the column is empty,
        then the value obtained by us from xml gateway tables needs to be filled in
        ===========================================================================*/

        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('--- After SQL Query  : Updating CLN_COLL_HIST_HDR ---',1);
        END IF;



        IF SQL%FOUND THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration Details successfully updated in CLN_COLL_HIST_HDR TABLE',1);
                END IF;

        ELSE
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_NOT_FOUND');
                x_msg_data      := FND_MESSAGE.GET;
                l_msg_data      := 'Unable to find the collaboration in Collaboration History';
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        -- Collaboration Detail ID is generated from a sequence.
        SELECT cln_collaboration_dtl_id_s.nextval INTO l_dtl_coll_id FROM dual ;
        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('Collaboration Detail ID generated : '||l_dtl_coll_id,1);
        END IF;

        x_dtl_coll_id   := l_dtl_coll_id;

        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('---- Before SQL Query : Adding Details in CLN_COLL_HIST_DTL ----',1);
        END IF;

        --Bug 3655492 : Added nvl(l_doc_type,'UNKNOWN') for 11.5.10 performance enh, to make sure always Doc Type is not null
        INSERT INTO CLN_COLL_HIST_DTL(
                COLLABORATION_DTL_ID, COLLABORATION_ID,
                COLLABORATION_DOCUMENT_TYPE, DOCUMENT_DIRECTION, COLLABORATION_POINT,
                ORIGINATOR_REFERENCE, DOCUMENT_STATUS, NOTIFICATION_ID, MESSAGE_TEXT,
                BSR_VERB, BSR_NOUN, BSR_REVISION,SENDER_LOGICAL_ID,SENDER_COMPONENT,
                SENDER_TASK,SENDER_REFERENCEID,SENDER_CONFIRMATION,SENDER_LANGUAGE,
                SENDER_CODEPAGE, SENDER_AUTHID, SENDER_DATETIME_QUALIFIER,
                SENDER_DATETIME,SENDER_TIMEZONE,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,
                ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9, ATTRIBUTE10,
                ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15, CREATION_DATE,CREATED_BY,
                LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,XMLG_TRANSACTION_TYPE,
                XMLG_TRANSACTION_SUBTYPE, XMLG_DOCUMENT_ID, XMLG_MSG_ID, XMLG_INTERNAL_CONTROL_NUMBER,
                RESEND_FLAG, XMLG_INT_TRANSACTION_TYPE, XMLG_INT_TRANSACTION_SUBTYPE, XML_EVENT_KEY )
        VALUES( x_dtl_coll_id,l_coll_id,nvl(l_doc_type,'UNKNOWN'),l_doc_dir,
                l_coll_pt,p_org_ref,l_doc_status,
                p_notification_id,l_msg_text,p_bsr_verb,p_bsr_noun,p_bsr_rev,p_sdr_logical_id,
                p_sdr_component,p_sdr_task,p_sdr_refid,p_sdr_confirmation,p_sdr_language,p_sdr_codepage,
                p_sdr_authid,p_sdr_datetime_qualifier,p_sdr_datetime,p_sdr_timezone,p_attr1,p_attr2,p_attr3,
                p_attr4,p_attr5,p_attr6,p_attr7,p_attr8,p_attr9,p_attr10,
                p_attr11,p_attr12,p_attr13,p_attr14,p_attr15,SYSDATE,FND_GLOBAL.USER_ID,
                SYSDATE,FND_GLOBAL.USER_ID,FND_GLOBAL.LOGIN_ID, l_xmlg_transaction_type,
                l_xmlg_transaction_subtype, l_xmlg_document_id, l_xmlg_msg_id, l_xmlg_internal_control_number,
                l_resend_flag, l_xmlg_int_transaction_type, l_xmlg_int_transaction_subtype, l_xml_event_key);

        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('----- After SQL Query : Adding Details in CLN_COLL_HIST_DTL -----',1);
        END IF;


        IF SQL%FOUND THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration Details successfully entered in CLN_COLL_HIST_DTL TABLE',1);
                END IF;

        ELSE
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_ADD_DTLS_FAILED');
                FND_MESSAGE.SET_TOKEN('TABLE','CLN_COLL_HIST_DTL');
                x_msg_data      := FND_MESSAGE.GET;
                l_msg_data := 'Failed to add Collaboration Details in CLN_COLL_HIST_DTL TABLE';
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_UPDATED');
        x_msg_data      := FND_MESSAGE.GET;
        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('------ Exiting UPDATE_COLLABORATION API ------- ',2);
        END IF;


    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              --ROLLBACK TO UPDATE_COLLABORATION_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              IF (l_Debug_Level <= 4) THEN
                      IF (l_Debug_Level <= 4) THEN
                              ecx_cln_debug_pub.Add(l_msg_data,4);
                              ecx_cln_debug_pub.Add('------ Exiting UPDATE_COLLABORATION API ------- ',2);
                      END IF;

              END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             --ROLLBACK TO UPDATE_COLLABORATION_PUB;
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             x_msg_data :=FND_MESSAGE.GET;
             l_msg_data         :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     ecx_cln_debug_pub.Add(l_msg_data,6);
                     ecx_cln_debug_pub.Add('------ Exiting UPDATE_COLLABORATION API ------- ',2);
             END IF;



        WHEN OTHERS THEN
             --ROLLBACK TO UPDATE_COLLABORATION_PUB;
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             x_msg_data :=FND_MESSAGE.GET;
             l_msg_data         :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     ecx_cln_debug_pub.Add(l_msg_data,4);
                     ecx_cln_debug_pub.Add('------ Exiting UPDATE_COLLABORATION API ------- ',2);
             END IF;


    END UPDATE_COLLABORATION;



  -- Name
  --   FIND_COLLABORATION_STATUS
  -- Purpose
  --   This is the public procedure which may be called by the user to
  --   know the status of any Collaboration.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


    PROCEDURE FIND_COLLABORATION_STATUS(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_coll_id                      IN  NUMBER,
         p_app_id                       IN  VARCHAR2,
         p_ref_id                       IN  VARCHAR2,
         p_rel_no                       IN  VARCHAR2,
         p_doc_no                       IN  VARCHAR2,
         p_doc_rev_no                   IN  VARCHAR2,
         p_xmlg_transaction_type        IN  VARCHAR2,
         p_xmlg_transaction_subtype     IN  VARCHAR2,
         p_xmlg_document_id             IN  VARCHAR2,
         x_coll_status                  OUT NOCOPY VARCHAR2,
         p_unique1                      IN  VARCHAR2,
         p_unique2                      IN  VARCHAR2,
         p_unique3                      IN  VARCHAR2,
         p_unique4                      IN  VARCHAR2,
         p_unique5                      IN  VARCHAR2,
         p_doc_direction                IN  VARCHAR2,
         p_xmlg_msg_id                  IN  VARCHAR2,
         p_xmlg_internal_control_number IN  NUMBER )

    IS
         l_error_code           NUMBER;
         l_error_msg            VARCHAR2(2000);
         l_msg_data             VARCHAR2(2000);
         l_debug_mode           VARCHAR2(255);

    BEGIN

        -- Sets the debug mode to be FILE
        --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');


        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('----- Entering FIND_COLLABORATION_STATUS API -----',2);
        END IF;


        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_data      := 'Collaboration status successfully found ';

         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('COLLABORATION ID           ----- >>>'||p_coll_id,1);
                 ecx_cln_debug_pub.Add('APPLCATION ID              ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('REFERENCE ID               ----- >>>'||p_ref_id,1);
                 ecx_cln_debug_pub.Add('RELEASE NUMBER             ----- >>>'||p_rel_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT NO                ----- >>>'||p_doc_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REV. NO           ----- >>>'||p_doc_rev_no,1);
                 ecx_cln_debug_pub.Add('XMLG TRANSACTION TYPE      ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG TRANSACTION SUBTYPE   ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID           ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('UNIQUE 1                   ----- >>>'||p_unique1,1);
                 ecx_cln_debug_pub.Add('UNIQUE 2                   ----- >>>'||p_unique2,1);
                 ecx_cln_debug_pub.Add('UNIQUE 3                   ----- >>>'||p_unique3,1);
                 ecx_cln_debug_pub.Add('UNIQUE 4                   ----- >>>'||p_unique4,1);
                 ecx_cln_debug_pub.Add('UNIQUE 5                   ----- >>>'||p_unique5,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION         ----- >>>'||p_doc_direction,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID            ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO   ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('===========================================',1);

                 ecx_cln_debug_pub.Add('--- Before SQL Query : Retrieving Collaboration Status ---',1);
         END IF;


        SELECT COLLABORATION_STATUS INTO x_coll_status FROM CLN_COLL_HIST_HDR
        WHERE            (COLLABORATION_ID                        =       p_coll_id)
                         OR    (APPLICATION_REFERENCE_ID          =       p_ref_id)
                         OR      (APPLICATION_ID                  =       p_app_id
                                  AND UNIQUE_ID1                  =       p_unique1)
                         OR      (APPLICATION_ID                  =       p_app_id
                                  AND UNIQUE_ID2                  =       p_unique2)
                         OR      (APPLICATION_ID                  =       p_app_id
                                  AND UNIQUE_ID3                  =       p_unique3)
                         OR      (APPLICATION_ID                  =       p_app_id
                                  AND UNIQUE_ID4                  =       p_unique4)
                         OR      (APPLICATION_ID                  =       p_app_id
                                  AND UNIQUE_ID5                  =       p_unique5)
                         OR      XMLG_MSG_ID                      =       p_xmlg_msg_id
                         OR      XMLG_INTERNAL_CONTROL_NUMBER     =       p_xmlg_internal_control_number;

        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('--- After SQL Query : Retrieving Collaboration Status ----',1);
        END IF;


        FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_STATUS_FOUND');
        x_msg_data      := FND_MESSAGE.GET;

        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('----- Exiting FIND_COLLABORATION_STATUS API -----',2);
        END IF;



    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_STATUS_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              l_msg_data        :='Collaboration status could not be retrieved for the parameters passed '||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('----- Exiting FIND_COLLABORATION_STATUS API -----',2);
              END IF;



         WHEN NO_DATA_FOUND THEN
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add('Unable to find the collaboration status in Collaboration History - Header Table',1);
                      ecx_cln_debug_pub.Add('----- Finding Collaboration status using CLN_COLL_HIST_DTL table ----',1);
              END IF;

              BEGIN
                        SELECT COLLABORATION_STATUS INTO x_coll_status
                        FROM CLN_COLL_HIST_HDR hdr, CLN_COLL_HIST_DTL dtl
                        WHERE   hdr.COLLABORATION_ID                    = dtl.COLLABORATION_ID
                        AND   ( dtl.XMLG_MSG_ID                         = p_xmlg_msg_id
                                OR  dtl.XMLG_INTERNAL_CONTROL_NUMBER    = p_xmlg_internal_control_number
                               )
                         AND ROWNUM < 2;

              EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                IF (l_Debug_Level <= 1) THEN
                                        ecx_cln_debug_pub.Add('Unable to find the collaboration status in Collaboration History - Detail Table',1);
                                END IF;

                                l_error_code      :=SQLCODE;
                                l_error_msg       :=SQLERRM;
                                x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR ;
                                FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_STATUS_NOT_FOUND');
                                FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
                                FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
                                x_msg_data        := FND_MESSAGE.GET;
                                l_msg_data        :='Collaboration status could not be retrieved for the parameters passed '||l_error_code||' : '||l_error_msg;
              END;
              IF (l_Debug_Level <= 1) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,1);
              END IF;

              IF (l_Debug_Level <= 2) THEN
                      ecx_cln_debug_pub.Add('----- Exiting FIND_COLLABORATION_STATUS API -----',2);
              END IF;



         WHEN OTHERS THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_STATUS_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              l_msg_data        :='Collaboration status could not be retrieved for the parameters passed '||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('----- Exiting FIND_COLLABORATION_STATUS API -----',2);
              END IF;



    END FIND_COLLABORATION_STATUS;




  -- Name
  --   RETRIEVE_COLLABORATION_DETAILS
  -- Purpose
  --   This is the public procedure which may be called to retrieve the details of any
  --   collaboration.
  -- Arguments
  --
  -- Notes
  --   No specific notes.

    PROCEDURE RETRIEVE_COLLABORATION_DETAILS(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_dtl_coll_id                  IN  NUMBER,
         p_coll_id                      IN  NUMBER,
         x_app_id                       IN  OUT NOCOPY VARCHAR2,
         x_ref_id                       IN  OUT NOCOPY VARCHAR2,
         x_rel_no                       IN  OUT NOCOPY VARCHAR2,
         x_doc_no                       IN  OUT NOCOPY VARCHAR2,
         x_doc_rev_no                   IN  OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_type        IN  OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_subtype     IN  OUT NOCOPY VARCHAR2,
         p_xmlg_document_id             IN  OUT NOCOPY VARCHAR2,
         x_resend_flag                  OUT NOCOPY VARCHAR2,
         x_resend_count                 OUT NOCOPY NUMBER,
         x_disposition                  OUT NOCOPY VARCHAR2,
         x_coll_status                  OUT NOCOPY VARCHAR2,
         x_org_id                       OUT NOCOPY NUMBER,
         x_tr_partner_id                OUT NOCOPY VARCHAR2,
         x_doc_owner                    OUT NOCOPY VARCHAR2,
         x_init_date                    OUT NOCOPY DATE,
         x_doc_creation_date            OUT NOCOPY DATE,
         x_doc_revision_date            OUT NOCOPY DATE,
         x_doc_type                     IN  OUT NOCOPY  VARCHAR2,
         x_doc_dir                      IN  OUT NOCOPY  VARCHAR2,
         x_coll_pt                      IN  OUT NOCOPY  VARCHAR2,
         x_org_ref                      OUT NOCOPY VARCHAR2,
         x_doc_status                   OUT NOCOPY VARCHAR2,
         x_notification_id              OUT NOCOPY VARCHAR2,
         x_msg_text                     OUT NOCOPY VARCHAR2,
         x_bsr_verb                     OUT NOCOPY VARCHAR2,
         x_bsr_noun                     OUT NOCOPY VARCHAR2,
         x_bsr_rev                      OUT NOCOPY VARCHAR2,
         x_sdr_logical_id               OUT NOCOPY VARCHAR2,
         x_sdr_component                OUT NOCOPY VARCHAR2,
         x_sdr_task                     OUT NOCOPY VARCHAR2,
         x_sdr_refid                    OUT NOCOPY VARCHAR2,
         x_sdr_confirmation             OUT NOCOPY VARCHAR2,
         x_sdr_language                 OUT NOCOPY VARCHAR2,
         x_sdr_codepage                 OUT NOCOPY VARCHAR2,
         x_sdr_authid                   OUT NOCOPY VARCHAR2,
         x_sdr_datetime_qualifier       OUT NOCOPY VARCHAR2,
         x_sdr_datetime                 OUT NOCOPY VARCHAR2,
         x_sdr_timezone                 OUT NOCOPY VARCHAR2,
         x_attr1                        OUT NOCOPY VARCHAR2,
         x_attr2                        OUT NOCOPY VARCHAR2,
         x_attr3                        OUT NOCOPY VARCHAR2,
         x_attr4                        OUT NOCOPY VARCHAR2,
         x_attr5                        OUT NOCOPY VARCHAR2,
         x_attr6                        OUT NOCOPY VARCHAR2,
         x_attr7                        OUT NOCOPY VARCHAR2,
         x_attr8                        OUT NOCOPY VARCHAR2,
         x_attr9                        OUT NOCOPY VARCHAR2,
         x_attr10                       OUT NOCOPY VARCHAR2,
         x_attr11                       OUT NOCOPY VARCHAR2,
         x_attr12                       OUT NOCOPY VARCHAR2,
         x_attr13                       OUT NOCOPY VARCHAR2,
         x_attr14                       OUT NOCOPY VARCHAR2,
         x_attr15                       OUT NOCOPY VARCHAR2,
         x_xmlg_msg_id                  IN  OUT NOCOPY  VARCHAR2,
         p_unique1                      IN  VARCHAR2,
         p_unique2                      IN  VARCHAR2,
         p_unique3                      IN  VARCHAR2,
         p_unique4                      IN  VARCHAR2,
         p_unique5                      IN  VARCHAR2,
         p_xmlg_internal_control_number IN  OUT NOCOPY NUMBER )

    IS

        l_error_code            NUMBER;
        l_error_msg             VARCHAR2(2000);
        l_msg_data              VARCHAR2(2000);
        l_debug_file            VARCHAR2(255);

    BEGIN

        -- Sets the debug mode to be FILE
        --l_debug_file :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');


        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('------ Entering RETRIEVE_COLLABORATION_DETAILS API -----',2);
        END IF;



        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_data      := 'Collaboration details successfully retrieved ';

        FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILS_RETRIEVED');
        x_msg_data      := FND_MESSAGE.GET;

         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('COLLABORATION DETAIL ID    ----- >>>'||p_dtl_coll_id,1);
                 ecx_cln_debug_pub.Add('COLLABORATION ID           ----- >>>'||p_coll_id,1);
                 ecx_cln_debug_pub.Add('APPLCATION ID              ----- >>>'||x_app_id,1);
                 ecx_cln_debug_pub.Add('REFERENCE ID               ----- >>>'||x_ref_id,1);
                 ecx_cln_debug_pub.Add('RELEASE NUMBER             ----- >>>'||x_rel_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT NO                ----- >>>'||x_doc_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REV. NO           ----- >>>'||x_doc_rev_no,1);
                 ecx_cln_debug_pub.Add('XMLG TRANSACTION TYPE      ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG TRANSACTION SUBTYPE   ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID           ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('DOCUMENT TYPE              ----- >>>'||x_doc_type,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION         ----- >>>'||x_doc_dir,1);
                 ecx_cln_debug_pub.Add('COLL POINT                 ----- >>>'||x_coll_pt,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID            ----- >>>'||x_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('UNIQUE 1                   ----- >>>'||p_unique1,1);
                 ecx_cln_debug_pub.Add('UNIQUE 2                   ----- >>>'||p_unique2,1);
                 ecx_cln_debug_pub.Add('UNIQUE 3                   ----- >>>'||p_unique3,1);
                 ecx_cln_debug_pub.Add('UNIQUE 4                   ----- >>>'||p_unique4,1);
                 ecx_cln_debug_pub.Add('UNIQUE 5                   ----- >>>'||p_unique5,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO   ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('===========================================',1);


                 ecx_cln_debug_pub.Add('---- Before SQL Query : Retrieving Collaboration Details -----',1);
         END IF;

        Select  hdr.APPLICATION_ID,hdr.APPLICATION_REFERENCE_ID,
                hdr.RELEASE_NO,hdr.DOCUMENT_NO,hdr.DOC_REVISION_NO,
                hdr.RESEND_FLAG,hdr.RESEND_COUNT,hdr.DISPOSITION,
                hdr.COLLABORATION_STATUS,hdr.ORG_ID,hdr.TRADING_PARTNER,
                hdr.DOCUMENT_OWNER,hdr.INITIATION_DATE,hdr.DOCUMENT_CREATION_DATE,
                hdr.DOCUMENT_REVISION_DATE,hdr.XMLG_MSG_ID,dtl.COLLABORATION_DOCUMENT_TYPE,
                dtl.DOCUMENT_DIRECTION,dtl.COLLABORATION_POINT,
                dtl.ORIGINATOR_REFERENCE,dtl.DOCUMENT_STATUS,dtl.NOTIFICATION_ID,
                dtl.MESSAGE_TEXT,dtl.BSR_VERB,dtl.BSR_NOUN,dtl.BSR_REVISION,
                dtl.SENDER_LOGICAL_ID,dtl.SENDER_COMPONENT,dtl.SENDER_TASK,
                dtl.SENDER_REFERENCEID,dtl.SENDER_CONFIRMATION,
                dtl.SENDER_LANGUAGE,dtl.SENDER_CODEPAGE,dtl.SENDER_AUTHID,
                dtl.SENDER_DATETIME_QUALIFIER,dtl.SENDER_DATETIME,dtl.SENDER_TIMEZONE,
                dtl.ATTRIBUTE1,dtl.ATTRIBUTE2,dtl.ATTRIBUTE3,dtl.ATTRIBUTE4,dtl.ATTRIBUTE5,
                dtl.ATTRIBUTE6,dtl.ATTRIBUTE7,dtl.ATTRIBUTE8,dtl.ATTRIBUTE9,dtl.ATTRIBUTE10,
                dtl.ATTRIBUTE11,dtl.ATTRIBUTE12,dtl.ATTRIBUTE13,dtl.ATTRIBUTE14,dtl.ATTRIBUTE15,
                dtl.XMLG_TRANSACTION_TYPE, dtl.XMLG_TRANSACTION_SUBTYPE,dtl.XMLG_DOCUMENT_ID, dtl.XMLG_INTERNAL_CONTROL_NUMBER
        INTO    x_app_id,x_ref_id,x_rel_no,x_doc_no,x_doc_rev_no,x_resend_flag,
                x_resend_count,x_disposition,x_coll_status,x_org_id,
                x_tr_partner_id,x_doc_owner,x_init_date,x_doc_creation_date,
                x_doc_revision_date,x_xmlg_msg_id,x_doc_type,
                x_doc_dir,x_coll_pt,x_org_ref,x_doc_status,
                x_notification_id,x_msg_text,x_bsr_verb,x_bsr_noun,x_bsr_rev,x_sdr_logical_id,
                x_sdr_component,x_sdr_task,x_sdr_refid,x_sdr_confirmation,x_sdr_language,x_sdr_codepage,
                x_sdr_authid,x_sdr_datetime_qualifier,x_sdr_datetime,x_sdr_timezone,x_attr1,x_attr2,x_attr3,
                x_attr4,x_attr5,x_attr6,x_attr7,x_attr8,x_attr9,x_attr10,
                x_attr11,x_attr12,x_attr13,x_attr14,x_attr15,
                p_xmlg_transaction_type, p_xmlg_transaction_subtype, p_xmlg_document_id, p_xmlg_internal_control_number
        FROM    CLN_COLL_HIST_HDR hdr,CLN_COLL_HIST_DTL dtl
        WHERE   hdr.COLLABORATION_ID                  = dtl.COLLABORATION_ID
        AND     ( dtl.COLLABORATION_DTL_ID            = p_dtl_coll_id
                OR   (
                        ((hdr.COLLABORATION_ID                    =       p_coll_id)
                         OR    (APPLICATION_REFERENCE_ID          =       x_ref_id)
                         OR      (APPLICATION_ID                  =       x_app_id
                                  AND UNIQUE_ID1                  =       p_unique1)
                         OR      (APPLICATION_ID                  =       x_app_id
                                  AND UNIQUE_ID2                  =       p_unique2)
                         OR      (APPLICATION_ID                  =       x_app_id
                                  AND UNIQUE_ID3                  =       p_unique3)
                         OR      (APPLICATION_ID                  =       x_app_id
                                  AND UNIQUE_ID4                  =       p_unique4)
                         OR      (APPLICATION_ID                  =       x_app_id
                                  AND UNIQUE_ID5                  =       p_unique5)
                        )
                        AND dtl.COLLABORATION_POINT     = x_coll_pt
                        AND dtl.DOCUMENT_DIRECTION      = x_doc_dir
                     )
                 OR  dtl.XMLG_MSG_ID                        = x_xmlg_msg_id
                 OR  dtl.XMLG_INTERNAL_CONTROL_NUMBER       = p_xmlg_internal_control_number
                 );
        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('----- After SQL Query : Retrieving Collaboration Details -----',1);
                ecx_cln_debug_pub.Add(l_msg_data,1);
                ecx_cln_debug_pub.Add('---- Exiting RETRIEVE_COLLABORATION_DETAILS API -----',2);
        END IF;



    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILS_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              l_msg_data        :='Collaboration details could not be retrieved for the parameters passed '||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('---- Exiting RETRIEVE_COLLABORATION_DETAILS API -----',2);
              END IF;



         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILS_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              l_msg_data        :='Collaboration details could not be retrieved for the parameters passed '||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('---- Exiting RETRIEVE_COLLABORATION_DETAILS API -----',2);
              END IF;



         WHEN NO_DATA_FOUND THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILS_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              l_msg_data        :='Collaboration details could not be retrieved for the parameters passed '||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('---- Exiting RETRIEVE_COLLABORATION_DETAILS API -----',2);
              END IF;



         WHEN OTHERS THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILS_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              l_msg_data        :='Collaboration details could not be retrieved for the parameters passed '||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('---- Exiting RETRIEVE_COLLABORATION_DETAILS API -----',2);
              END IF;



    END RETRIEVE_COLLABORATION_DETAILS;



  -- Name
  --   ADD_COLLABORATION_MESSAGES
  -- Purpose
  --   This is the public procedure which may be called by user for adding
  --   detail messages related with any Collaboration.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


    PROCEDURE ADD_COLLABORATION_MESSAGES(
            x_return_status                     OUT NOCOPY VARCHAR2,
            x_msg_data                          OUT NOCOPY VARCHAR2,
            p_dtl_coll_id                       IN  NUMBER,
            p_ref1                              IN  VARCHAR2,
            p_ref2                              IN  VARCHAR2,
            p_ref3                              IN  VARCHAR2,
            p_ref4                              IN  VARCHAR2,
            p_ref5                              IN  VARCHAR2,
            p_dtl_msg                           IN  VARCHAR2,
            p_coll_id                           IN  NUMBER,
            p_xmlg_transaction_type             IN  VARCHAR2,
            p_xmlg_transaction_subtype          IN  VARCHAR2,
            p_xmlg_document_id                  IN  VARCHAR2,
            p_doc_type                          IN  VARCHAR2,
            p_doc_direction                     IN  VARCHAR2,
            p_coll_point                        IN  VARCHAR2,
            p_xmlg_internal_control_number      IN  NUMBER,
            p_xmlg_int_transaction_type         IN  VARCHAR2,
            p_xmlg_int_transaction_subtype      IN  VARCHAR2,
            p_xmlg_msg_id                       IN  VARCHAR2,
            p_xml_event_key                     IN  VARCHAR2,
            p_app_id                            IN  VARCHAR2,
            p_ref_id                            IN  VARCHAR2,
            p_unique1                           IN  VARCHAR2,
            p_unique2                           IN  VARCHAR2,
            p_unique3                           IN  VARCHAR2,
            p_unique4                           IN  VARCHAR2,
            p_unique5                           IN  VARCHAR2
         )

    IS

            l_coll_dtl_id                       NUMBER;
            l_error_code                        NUMBER;
            l_dtl_msg_id                        NUMBER;
            l_error_msg                         VARCHAR2(2000);
            l_msg_data                          VARCHAR2(2000);
            l_debug_file                        VARCHAR2(255);
            l_dtl_msg                           VARCHAR2(2000);

    BEGIN

        -- Sets the debug mode to be FILE
        --l_debug_file :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('----- Entering ADD_COLLABORATION_MESSAGES API ------',2);
        END IF;



        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_msg_data      := 'Detail Messages for Collaboration successfully added ';
        l_coll_dtl_id   := p_dtl_coll_id;
        l_dtl_msg       := p_dtl_msg;

        -- get the paramaters passed
        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                ecx_cln_debug_pub.Add('COLLABORATION DETAIL ID      ----- >>>'||l_coll_dtl_id,1);
                ecx_cln_debug_pub.Add('REFERENCE 1                  ----- >>>'||p_ref1,1);
                ecx_cln_debug_pub.Add('REFERENCE 2                  ----- >>>'||p_ref2,1);
                ecx_cln_debug_pub.Add('REFERENCE 3                  ----- >>>'||p_ref3,1);
                ecx_cln_debug_pub.Add('REFERENCE 4                  ----- >>>'||p_ref4,1);
                ecx_cln_debug_pub.Add('REFERENCE 5                  ----- >>>'||p_ref5,1);
                ecx_cln_debug_pub.Add('DETAIL MSG                   ----- >>>'||p_dtl_msg,1);
                ecx_cln_debug_pub.Add('COLLABORATION ID             ----- >>>'||p_coll_id,1);
                ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE    ----- >>>'||p_xmlg_transaction_type,1);
                ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE ----- >>>'||p_xmlg_transaction_subtype,1);
                ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE    ----- >>>'||p_xmlg_int_transaction_type,1);
                ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE ----- >>>'||p_xmlg_int_transaction_subtype,1);
                ecx_cln_debug_pub.Add('XMLG DOCUMENT ID             ----- >>>'||p_xmlg_document_id,1);
                ecx_cln_debug_pub.Add('DOCUMENT TYPE                ----- >>>'||p_doc_type,1);
                ecx_cln_debug_pub.Add('DOCUMENT DIRECTION           ----- >>>'||p_doc_direction,1);
                ecx_cln_debug_pub.Add('COLLABORATION POINT          ----- >>>'||p_coll_point,1);
                ecx_cln_debug_pub.Add('XMLG INTERNAL CTRL NUMBER    ----- >>>'||p_xmlg_internal_control_number,1);
                ecx_cln_debug_pub.Add('XML MESSAGE ID               ----- >>>'||p_xmlg_msg_id,1);
                ecx_cln_debug_pub.Add('XMLG EVENT KEY               ----- >>>'||p_xml_event_key,1);
                ecx_cln_debug_pub.Add('APPLICATION ID               ----- >>>'||P_app_id,1);
                ecx_cln_debug_pub.Add('REFERENCE ID                 ----- >>>'||P_ref_id,1);
                ecx_cln_debug_pub.Add('UNIQUE ID 1                  ----- >>>'||p_unique1,1);
                ecx_cln_debug_pub.Add('UNIQUE ID 2                  ----- >>>'||p_unique2,1);
                ecx_cln_debug_pub.Add('UNIQUE ID 3                  ----- >>>'||p_unique3,1);
                ecx_cln_debug_pub.Add('UNIQUE ID 4                  ----- >>>'||p_unique4,1);
                ecx_cln_debug_pub.Add('UNIQUE ID 5                  ----- >>>'||p_unique5,1);
                ecx_cln_debug_pub.Add('=========================================',1);
        END IF;




        -- Remove the last comma from the message if it exists
        IF ( substr(p_dtl_msg,-1) )= ',' THEN
            l_dtl_msg:= substr( p_dtl_msg, 0, length(p_dtl_msg) - 1);
            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('DETAIL MSG AFTER TRIMMING  ----- >>>'||l_dtl_msg,1);
            END IF;

        END IF;


        -- Collaboration Message Detail ID is generated from a sequence.
        SELECT cln_collaboration_msg_id_s.nextval INTO l_dtl_msg_id FROM dual ;
        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('Message Detail ID generated : '||l_dtl_msg_id,1);
        END IF;


        -- Check for Collaboration Detail ID value
        BEGIN
                IF (l_coll_dtl_id IS NULL) THEN
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('COLLABORATION_DETAIL_ID passed as  null',1);
                                ecx_cln_debug_pub.Add('Before calling CLN_CH_COLLABORATION_PKG.FIND_COLLABORATION_DETAIL_ID API',1);
                        END IF;


                        FIND_COLLABORATION_DETAIL_ID(
                              x_return_status                     => x_return_status,
                              x_msg_data                          => x_msg_data,
                              p_coll_id                           => p_coll_id,
                              p_xmlg_transaction_type             => p_xmlg_transaction_type,
                              p_xmlg_transaction_subtype          => p_xmlg_transaction_subtype,
                              p_xmlg_document_id                  => p_xmlg_document_id,
                              p_doc_type                          => p_doc_type,
                              p_doc_direction                     => p_doc_direction,
                              p_coll_point                        => p_coll_point,
                              x_dtl_coll_id                       => l_coll_dtl_id,
                              p_xmlg_msg_id                       => p_xmlg_msg_id,
                              p_xmlg_internal_control_number      => p_xmlg_internal_control_number,
                              p_xmlg_int_transaction_type         => p_xmlg_int_transaction_type,
                              p_xmlg_int_transaction_subtype      => p_xmlg_int_transaction_subtype,
                              p_xml_event_key                     => p_xml_event_key,
                              p_app_id                            => p_app_id,
                              p_ref_id                            => p_ref_id,
                              p_unique1                           => p_unique1,
                              p_unique2                           => p_unique2,
                              p_unique3                           => p_unique3,
                              p_unique4                           => p_unique4,
                              p_unique5                           => p_unique5
                              );

                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('Return Status from FIND_COLLABORATION_DETAIL_ID  -'||x_return_status  ,1);
                                ecx_cln_debug_pub.Add('COLLABORATION_DETAIL_ID obtained as              -'||l_coll_dtl_id ,1);
                        END IF;


                        IF (x_return_status <> 'S') THEN
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;
                ELSE
                        SELECT collaboration_dtl_id
                        INTO l_coll_dtl_id
                        FROM cln_coll_hist_dtl
                        WHERE collaboration_dtl_id = p_dtl_coll_id;
                END IF;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_NOT_FOUND');
                     FND_MESSAGE.SET_TOKEN('PARAM','Collaboration Detail Id');
                     FND_MESSAGE.SET_TOKEN('VALUE',p_dtl_coll_id);
                     x_msg_data := FND_MESSAGE.GET;
                     l_msg_data :='Collaboration not found for the particular Collaboration Detail Id :'||p_dtl_coll_id;
                     RAISE FND_API.G_EXC_ERROR;
        END;

        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('Before SQL Query : Adding Collaboration Detail Messages',1);
        END IF;


        -- Message Details for a Collaboration are added into CLN_COLL_MESSAGES Table
        INSERT INTO CLN_COLL_MESSAGES(
                DTL_MESSAGE_ID,COLLABORATION_DTL_ID,REFERENCE1,REFERENCE2,REFERENCE3,REFERENCE4,REFERENCE5,
                DTL_MESSAGE_TEXT,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN)
        VALUES( l_dtl_msg_id,l_coll_dtl_id,p_ref1,p_ref2,p_ref3,p_ref4,p_ref5,l_dtl_msg,
                SYSDATE,FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,FND_GLOBAL.LOGIN_ID);


        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add('After SQL Query : Adding Collaboration Detail Messages',1);
        END IF;


        IF SQL%FOUND THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Detail Messages for a collaboration Added',1);
                END IF;

        ELSE
                FND_MESSAGE.SET_NAME('CLN','CLN_CH_ADD_MSGS_FAILED');
                x_msg_data      :=FND_MESSAGE.GET;
                l_msg_data      :='Failed to add Message Details';
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_MSGS_ADDED');
        x_msg_data      := FND_MESSAGE.GET;
        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('------ Exiting ADD_COLLABORATION_MESSAGES API ------',2);
        END IF;


    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status :=FND_API.G_RET_STS_ERROR ;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('------ Exiting ADD_COLLABORATION_MESSAGES API ------',2);
              END IF;



         WHEN NO_DATA_FOUND THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR ;
              l_msg_data        :='Collaboration not found for the particular Collaboration Detail Id :'||l_error_code||' : '||l_error_msg;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILID_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('------ Exiting ADD_COLLABORATION_MESSAGES API ------',2);
              END IF;



         WHEN OTHERS THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        :=FND_MESSAGE.GET;
              l_msg_data        :=l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('------ Exiting ADD_COLLABORATION_MESSAGES API ------',2);
              END IF;



    END ADD_COLLABORATION_MESSAGES;



  -- Name
  --   IS_UPDATE_REQUIRED
  -- Purpose
  --   This is the public procedure which checks for the protocol used
  --   based on few parameters passed in and accordingly,collaboration is updated.
  -- Arguments
  --
  -- Notes
  --   No specific notes.

     PROCEDURE IS_UPDATE_REQUIRED(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_doc_dir                      IN  VARCHAR2,
         p_xmlg_transaction_type        IN  VARCHAR2,
         p_xmlg_transaction_subtype     IN  VARCHAR2,
         p_tr_partner_type              IN  VARCHAR2,
         p_tr_partner_id                IN  VARCHAR2,
         p_tr_partner_site              IN  VARCHAR2,
         p_sender_component             IN  VARCHAR2,
         x_update_reqd                  OUT NOCOPY BOOLEAN)

    IS

         l_error_code                   NUMBER;
         l_msg_data                     VARCHAR2(2000);
         l_error_msg                    VARCHAR2(2000);
         l_debug_mode                   VARCHAR2(255);
         l_fnd_profile                  VARCHAR2(100);
         l_protocol_type                VARCHAR2(50);
         l_hub_user_id                  VARCHAR2(50);

    BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');


         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------ Entering IS_UPDATE_REQUIRED API ------ ',2);
         END IF;


         -- Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;


         FND_MESSAGE.SET_NAME('CLN','CLN_CH_ROSETTANET_STD');
         x_msg_data        := FND_MESSAGE.GET;
         l_msg_data        := 'Collaboration is on RosettaNet standards';
         x_update_reqd     := FALSE;
         l_protocol_type   := p_sender_component ;


         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION             ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE      ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE   ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER TYPE           ----- >>>'||p_tr_partner_type,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER ID             ----- >>>'||p_tr_partner_id,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER SITE           ----- >>>'||p_tr_partner_site,1);
                 ecx_cln_debug_pub.Add('SENDER COMPONENT               ----- >>>'||l_protocol_type,1);
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;



         -- Check for Profile value
         l_fnd_profile :=FND_PROFILE.VALUE('CLN_UPDATION');

         IF(l_fnd_profile = 'NEVER') THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Profile Value - CLN_UPDATION found as NEVER',1);
                END IF;

                FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_NOT_REQD');
                x_msg_data      := FND_MESSAGE.GET;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                x_update_reqd   := FALSE;
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Collaboration need not be created/updated',1);
                END IF;

                Return;
         ELSIF(l_fnd_profile = 'ROSETTANET') THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Profile Value - CLN_UPDATION found as ROSETTANET',1);
                END IF;


                IF (p_doc_dir = 'OUT') THEN
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('Document direction is out',1);
                        END IF;

                        IF (l_protocol_type IS NULL) THEN
                                BEGIN
                                      SELECT  protocol_type,hub_user_id
                                      INTO l_protocol_type, l_hub_user_id
                                      FROM ecx_tp_details  etd, ecx_tp_headers eth,
                                           ecx_ext_processes  eep
                                      WHERE   (eth.party_id   = p_tr_partner_id or p_tr_partner_id is null )
                                      AND  eth.party_site_id  = p_tr_partner_site
                                      AND  eth.party_type     = p_tr_partner_type
                                      AND  eth.tp_header_id   = etd.tp_header_id
                                      AND  eep.ext_type       = p_xmlg_transaction_type
                                      AND  eep.ext_subtype    = p_xmlg_transaction_subtype
                                      AND  eep.ext_process_id = etd.ext_process_id
                                      AND  eep.direction      = 'OUT';
                                EXCEPTION
                                      WHEN NO_DATA_FOUND THEN
                                           l_msg_data   := 'Invalid Trading Partner';
                                           FND_MESSAGE.SET_NAME('CLN','CLN_CH_INVALID_PARAM');
                                           FND_MESSAGE.SET_TOKEN('PARAM','Trading Partner');
                                           x_msg_data   := FND_MESSAGE.GET;
                                           RAISE FND_API.G_EXC_ERROR;
                                END;

                                -- if hub value is also entered along with the protocol or
                                -- only hub value is there , then also we an get protocol value
                                IF l_hub_user_id IS NOT NULL THEN
                                      IF (l_Debug_Level <= 1) THEN
                                              ecx_cln_debug_pub.Add('Hub user id is not null',1);
                                      END IF;


                                      BEGIN
                                           SELECT  protocol_type
                                           INTO l_protocol_type
                                           FROM    ecx_hubs eh, ecx_hub_users ehu
                                           WHERE   eh.hub_id = ehu.hub_id
                                           AND     ehu.hub_user_id = l_hub_user_id;
                                      EXCEPTION
                                           WHEN NO_DATA_FOUND THEN
                                                l_msg_data      := 'Invalid user id for Hub';
                                                FND_MESSAGE.SET_NAME('CLN','CLN_CH_INVALID_USERID_HUB');
                                                x_msg_data      := FND_MESSAGE.GET;
                                                RAISE FND_API.G_EXC_ERROR;
                                      END;
                                END IF;
                          END IF;

                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('Protocol value found as :'||l_protocol_type,1);
                        END IF;


                        IF(l_protocol_type <> 'IAS') THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_NOT_REQD');
                              x_msg_data        := FND_MESSAGE.GET;
                              ecx_cln_debug_pub.Add('Protocol type is not IAS',1);
                              ecx_cln_debug_pub.Add('Collaboration need not be created/updated',1);
                              x_update_reqd     :=FALSE;
                              x_return_status   := FND_API.G_RET_STS_SUCCESS;
                              Return;
                        END IF;
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('Collaboration can be updated',1);
                        END IF;

                        x_update_reqd   := TRUE;

                ELSIF (p_doc_dir = 'IN') THEN
                        ecx_cln_debug_pub.Add('Document direction is IN',1);
                        IF(l_protocol_type = 'IAS') THEN
                              IF (l_Debug_Level <= 1) THEN
                                      ecx_cln_debug_pub.Add('SENDER/COMPONENT tag has the value as IAS',1);
                                      ecx_cln_debug_pub.Add('Collaboration can be updated',1);
                              END IF;

                              x_update_reqd   := TRUE;
                        ELSE
                              IF (l_Debug_Level <= 1) THEN
                                      ecx_cln_debug_pub.Add('SENDER/COMPONENT tag has the value as -'||l_protocol_type,1);
                                      ecx_cln_debug_pub.Add('Collaboration need not be created/updated',1);
                              END IF;

                              x_update_reqd   := FALSE;
                        END IF;
                END IF;
         ELSE
                x_update_reqd   := TRUE;
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add(l_msg_data,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------ Exiting IS_UPDATE_REQUIRED ------- ',2);
         END IF;


    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status :=FND_API.G_RET_STS_ERROR ;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('------ Exiting IS_UPDATE_REQUIRED ------- ',2);
              END IF;



         WHEN OTHERS THEN
              l_error_code       :=SQLCODE;
              l_error_msg        :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        :=FND_MESSAGE.GET;
              l_msg_data        := 'Unexpected Error : '||l_error_code||'-'||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('------ Exiting IS_UPDATE_REQUIRED ------- ',2);
              END IF;


    END IS_UPDATE_REQUIRED;



  -- Name
  --   FIND_COLLABORATION_DETAIL_ID
  -- Purpose
  --   This is the public procedure which may be used to get the latest collaboration detail id
  --   for a particular collaboration id or other paramaters.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


     PROCEDURE FIND_COLLABORATION_DETAIL_ID(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER,
         p_app_id                               IN  VARCHAR2,
         p_ref_id                               IN  VARCHAR2,
         p_rel_no                               IN  VARCHAR2,
         p_doc_no                               IN  VARCHAR2,
         p_doc_rev_no                           IN  VARCHAR2,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_xmlg_document_id                     IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2,
         p_unique2                              IN  VARCHAR2,
         p_unique3                              IN  VARCHAR2,
         p_unique4                              IN  VARCHAR2,
         p_unique5                              IN  VARCHAR2,
         p_doc_type                             IN  VARCHAR2,
         p_doc_direction                        IN  VARCHAR2,
         p_coll_point                           IN  VARCHAR2,
         x_dtl_coll_id                          OUT NOCOPY NUMBER,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_xmlg_internal_control_number         IN  NUMBER,
         p_xmlg_int_transaction_type            IN  VARCHAR2,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2,
         p_xml_event_key                        IN  VARCHAR2)
    IS
         l_error_code                           NUMBER;
         l_error_msg                            VARCHAR2(2000);
         l_msg_data                             VARCHAR2(2000);
         l_debug_mode                           VARCHAR2(255);
         l_coll_id                              VARCHAR2(255);
    BEGIN

        -- Sets the debug mode to be FILE
        --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');


        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('------ Entering FIND_COLLABORATION_DETAIL_ID API -----',2);
        END IF;


        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_msg_data      := 'Collaboration detail id successfully found'||x_dtl_coll_id;

        FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILID_FOUND');
        x_msg_data      := FND_MESSAGE.GET;

         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('COLLABORATION ID               ----- >>>'||p_coll_id,1);
                 ecx_cln_debug_pub.Add('APPLCATION ID                  ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('REFERENCE ID                   ----- >>>'||p_ref_id,1);
                 ecx_cln_debug_pub.Add('RELEASE NUMBER                 ----- >>>'||p_rel_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT NO                    ----- >>>'||p_doc_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REV. NO               ----- >>>'||p_doc_rev_no,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE      ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE   ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE      ----- >>>'||p_xmlg_int_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE   ----- >>>'||p_xmlg_int_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID               ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('UNIQUE 1                       ----- >>>'||p_unique1,1);
                 ecx_cln_debug_pub.Add('UNIQUE 2                       ----- >>>'||p_unique2,1);
                 ecx_cln_debug_pub.Add('UNIQUE 3                       ----- >>>'||p_unique3,1);
                 ecx_cln_debug_pub.Add('UNIQUE 4                       ----- >>>'||p_unique4,1);
                 ecx_cln_debug_pub.Add('UNIQUE 5                       ----- >>>'||p_unique5,1);
                 ecx_cln_debug_pub.Add('DOCUMENT TYPE                  ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION             ----- >>>'||p_doc_direction,1);
                 ecx_cln_debug_pub.Add('COLLABORATION POINT            ----- >>>'||p_coll_point,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID                ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO       ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('XMLG EVENT KEY                 ----- >>>'||p_xml_event_key,1);
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;




         BEGIN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('--Before the query to CLN_COLL_HIST_DTL table ---',1);
                END IF;

                SELECT MAX(collaboration_dtl_id) INTO x_dtl_coll_id
                FROM CLN_COLL_HIST_DTL
                WHERE   COLLABORATION_POINT                     = nvl(p_coll_point,'APPS')
                  AND ( XMLG_MSG_ID                              = p_xmlg_msg_id
                        OR   XMLG_INTERNAL_CONTROL_NUMBER        = p_xmlg_internal_control_number
                       );
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('-- After the query to CLN_COLL_HIST_DTL table ---',1);
                        ecx_cln_debug_pub.Add('Collaboration Detail ID : '||x_dtl_coll_id,1);
                END IF;


         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('Unable to trace collaboration dtl ID using transaction details',1);
                        END IF;

         END;

         IF (x_dtl_coll_id is NULL) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Before SQL Query : Retrieving Collaboration dtl ID using xmlg_document_id',1);
                END IF;


                BEGIN
                   SELECT MAX(collaboration_dtl_id) INTO x_dtl_coll_id
                   FROM CLN_COLL_HIST_DTL
                   WHERE   COLLABORATION_POINT                     = nvl(p_coll_point,'APPS')
                     AND ( (XMLG_TRANSACTION_TYPE                  = p_xmlg_transaction_type
                               AND XMLG_TRANSACTION_SUBTYPE        = p_xmlg_transaction_subtype
                               AND XMLG_DOCUMENT_ID                = p_xmlg_document_id
                               AND DOCUMENT_DIRECTION              = nvl( p_doc_direction, DOCUMENT_DIRECTION)
                               AND (XML_EVENT_KEY is null or p_xml_event_key is null or XML_EVENT_KEY = p_xml_event_key)
                            )
                            OR
                            (XMLG_INT_TRANSACTION_TYPE               = p_xmlg_int_transaction_type
                               AND XMLG_INT_TRANSACTION_SUBTYPE      = p_xmlg_int_transaction_subtype
                               AND XMLG_DOCUMENT_ID                  = p_xmlg_document_id
                               AND DOCUMENT_DIRECTION                = nvl( p_doc_direction, DOCUMENT_DIRECTION)
                               AND (XML_EVENT_KEY is null or p_xml_event_key is null or XML_EVENT_KEY = p_xml_event_key)
                            )
                   );
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('After SQL Query : Retrieving Collaboration dtl ID using xmlg_document_id',1);
                        ecx_cln_debug_pub.Add('Collaboration Detail ID : '||x_dtl_coll_id,1);
                END IF;


                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             IF (l_Debug_Level <= 1) THEN
                                     ecx_cln_debug_pub.Add('Unable to trace Collaboration dtl ID using xmlg_document_id',1);
                             END IF;

                END;
         END IF;

         IF (x_dtl_coll_id IS NOT NULL) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add(l_msg_data,1);
                END IF;

                IF (l_Debug_Level <= 2) THEN
                        ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_DETAIL_ID API ------',2);
                END IF;

                RETURN;
         END IF;



         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Collaboration ID passed as '||p_coll_id,1);
         END IF;

         IF (p_coll_id is NULL) THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('Before SQL Query 1 : Retrieving Collaboration ID using CLN_COLL_HIST_HDR',1);
                END IF;

                BEGIN
                        SELECT COLLABORATION_ID INTO l_coll_id
                        FROM CLN_COLL_HIST_HDR
                        WHERE    APPLICATION_REFERENCE_ID                 = p_ref_id
                                 OR      XMLG_MSG_ID                      = p_xmlg_msg_id
                                 OR      XMLG_INTERNAL_CONTROL_NUMBER     = p_xmlg_internal_control_number;
                EXCEPTION
                       WHEN TOO_MANY_ROWS THEN
                                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNIQUE_COLLABORATION_NF');
                                     x_msg_data := FND_MESSAGE.GET;
                                     l_msg_data := 'Unique Collaboration Not Found';
                                     RAISE FND_API.G_EXC_ERROR;

                        WHEN NO_DATA_FOUND THEN
    			IF p_unique1 IS NOT NULL OR
			  p_unique2 IS NOT NULL OR
			  p_unique3 IS NOT NULL OR
			  p_unique4 IS NOT NULL OR
			  p_unique5 IS NOT NULL THEN

                             IF (l_Debug_Level <= 1) THEN
                                  ecx_cln_debug_pub.Add('Before SQL Query 2 : Retrieving Collaboration ID using CLN_COLL_HIST_HDR',1);
                             END IF;

                             BEGIN
                                  SELECT COLLABORATION_ID INTO l_coll_id
                                  FROM   CLN_COLL_HIST_HDR
                                  WHERE  (APPLICATION_ID          = p_app_id AND UNIQUE_ID1 = p_unique1)
                                         OR      (APPLICATION_ID  = p_app_id AND UNIQUE_ID2 = p_unique2)
                                         OR      (APPLICATION_ID  = p_app_id AND UNIQUE_ID3 = p_unique3)
                                         OR      (APPLICATION_ID  = p_app_id AND UNIQUE_ID4 = p_unique4)
                                         OR      (APPLICATION_ID  = p_app_id AND UNIQUE_ID5 = p_unique5);

                             EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
                                      IF (l_Debug_Level <= 1) THEN
                                       ecx_cln_debug_pub.Add('Unable to find the collaboration in Collaboration History - Header Table',1);
                                      END IF;

                                      FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLLABORATION_NOT_FOUND');
                                      x_msg_data := FND_MESSAGE.GET;
                                      l_msg_data := 'Unable to find the collaboration in Collaboration History - Detail Table';                            RAISE FND_API.G_EXC_ERROR;
                                      WHEN TOO_MANY_ROWS THEN
                                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNIQUE_COLLABORATION_NF');
                                     x_msg_data := FND_MESSAGE.GET;
                                     l_msg_data := 'Unique Collaboration Not Found';
                                     RAISE FND_API.G_EXC_ERROR;
                            	END;
                          	ELSE
		                   IF (l_Debug_Level <= 1) THEN
					cln_debug_pub.Add('Unique IDs from 1 to 5 are NULL',1);
				   END IF;
				END IF;

                END;
                IF (l_Debug_Level <= 1) THEN
                        IF (l_Debug_Level <= 1) THEN
                                ecx_cln_debug_pub.Add('After SQL Query : Retrieving Collaboration ID',1);
                                ecx_cln_debug_pub.Add('Retrieved Collaboration ID' || l_coll_id,1);
                        END IF;

                END IF;

      ELSE
                l_coll_id := p_coll_id;
      END IF;

      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add('--- Before SQL Query : Retrieving Collaboration Detail ID ----',1);
      END IF;

      SELECT max(COLLABORATION_DTL_ID) INTO x_dtl_coll_id
      FROM CLN_COLL_HIST_DTL
      WHERE    COLLABORATION_ID            = l_coll_id
      AND      COLLABORATION_DOCUMENT_TYPE = p_doc_type
      AND      DOCUMENT_DIRECTION          = p_doc_direction
      AND      COLLABORATION_POINT         = p_coll_point;
      IF (l_Debug_Level <= 1) THEN
              ecx_cln_debug_pub.Add(' ---- After SQL Query : Retrieving Collaboration Detail ID ----',1);
              ecx_cln_debug_pub.Add(l_msg_data,1);
      END IF;

      IF (l_Debug_Level <= 2) THEN
              ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_DETAIL_ID API ------',2);
      END IF;



    EXCEPTION

         WHEN NO_DATA_FOUND THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILID_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              l_msg_data        :='Collaboration detail id could not be found for the parameters passed :'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('Error in FIND_COLLABORATION_DETAIL_ID API',2);
                      ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_DETAIL_ID API ------',2);
              END IF;



         WHEN OTHERS THEN
              l_error_code      :=SQLCODE;
              l_error_msg       :=SQLERRM;
              x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_COLL_DETAILID_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data        := FND_MESSAGE.GET;
              l_msg_data        :='Collaboration detail id could not be found for the parameters passed :'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(x_msg_data,6);
                      ecx_cln_debug_pub.Add('Error in FIND_COLLABORATION_DETAIL_ID API',2);
                      ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_DETAIL_ID API ------',2);
              END IF;


    END FIND_COLLABORATION_DETAIL_ID;



  -- Name
  --   GET_TRADING_PARTNER_DETAILS
  -- Purpose
  --   This is the public procedure which checks for the trading partner details from the
  --   xmlg tables based on the parameters passed.
  -- Arguments
  --
  -- Notes
  --   No specific notes.

     PROCEDURE GET_TRADING_PARTNER_DETAILS(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_xmlg_internal_control_number         IN OUT NOCOPY NUMBER,
         p_xmlg_msg_id                          IN OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_type                IN OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_subtype             IN OUT NOCOPY VARCHAR2,
         p_xmlg_int_transaction_type            IN OUT NOCOPY VARCHAR2,
         p_xmlg_int_transaction_subtype         IN OUT NOCOPY VARCHAR2,
         p_xmlg_document_id                     IN OUT NOCOPY VARCHAR2,
         p_doc_dir                              IN OUT NOCOPY VARCHAR2,
         p_tr_partner_type                      IN OUT NOCOPY VARCHAR2,
         p_tr_partner_id                        IN OUT NOCOPY VARCHAR2,
         p_tr_partner_site                      IN OUT NOCOPY VARCHAR2,
         p_sender_component                     IN OUT NOCOPY VARCHAR2,
         p_xml_event_key                        IN OUT NOCOPY VARCHAR2,
         p_collaboration_standard               IN OUT NOCOPY VARCHAR2)

    IS

         l_error_code                           NUMBER;
         l_msg_data                             VARCHAR2(2000);
         l_error_msg                            VARCHAR2(2000);
         l_debug_mode                           VARCHAR2(255);
         l_xmlg_internal_control_number         NUMBER;
         l_xmlg_msg_id                          VARCHAR2(100);
         l_xmlg_transaction_type                VARCHAR2(100);
         l_xmlg_transaction_subtype             VARCHAR2(100);
         l_xmlg_int_transaction_type            VARCHAR2(100);
         l_xmlg_int_transaction_subtype         VARCHAR2(100);
         l_xmlg_document_id                     VARCHAR2(256);
         l_collaboration_standard               VARCHAR2(30);

         l_xml_event_key                        VARCHAR2(240);

         l_doc_dir                              VARCHAR2(240);
         l_tr_partner_type                      VARCHAR2(30);
         l_tr_partner_id                        VARCHAR2(256);
         l_tr_partner_site                      VARCHAR2(256);

         l_txn_partner_type                      VARCHAR2(30);
         l_txn_partner_id                        VARCHAR2(256);
         l_txn_partner_site                      VARCHAR2(256);

         l_sender_component                     VARCHAR2(500);
         l_xmlg_msg_standard                    VARCHAR2(100);
         l_xmlg_msg_type                        VARCHAR2(100);
         l_enhanced_combination_key             BOOLEAN DEFAULT FALSE;

    BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------ Entering GET_TRADING_PARTNER_DETAILS API ------ ',2);
         END IF;


         -- Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO              ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID                       ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('XMLG EXTERNAL TRANSACTION TYPE        ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXTERNAL TRANSACTION SUBTYPE     ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL TRANSACTION TYPE        ----- >>>'||p_xmlg_int_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL TRANSACTION SUBTYPE     ----- >>>'||p_xmlg_int_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID                      ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION                    ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER TYPE                  ----- >>>'||p_tr_partner_type,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER ID                    ----- >>>'||p_tr_partner_id,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER SITE                  ----- >>>'||p_tr_partner_site,1);
                 ecx_cln_debug_pub.Add('SENDER COMPONENT                      ----- >>>'||p_sender_component,1);
                 ecx_cln_debug_pub.Add('XMLG EVENT KEY                        ----- >>>'||p_xml_event_key,1);
                 ecx_cln_debug_pub.Add('Collab Standard                       ----- >>>'||p_collaboration_standard,1);
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;



         -- assigning values to local variables for transaction tyoe/subtype
         l_xmlg_transaction_type        :=      p_xmlg_transaction_type;
         l_xmlg_transaction_subtype     :=      p_xmlg_transaction_subtype;
         l_xmlg_msg_standard            :=      p_collaboration_standard;

         -- Check if we need to call an API to get the trading partner set up details
         IF ( (p_xmlg_internal_control_number IS NULL)
               OR (p_xmlg_msg_id IS NULL)
               OR (p_xmlg_transaction_type IS NULL)
               OR (p_xmlg_transaction_subtype IS NULL)
               OR (p_xmlg_document_id IS NULL)
               OR (p_doc_dir IS NULL)
               OR (p_tr_partner_type IS NULL)
               OR (p_tr_partner_id IS NULL)
               OR (p_tr_partner_site IS NULL)
               OR (p_sender_component IS NULL)
               OR (p_xml_event_key IS NULL)
               OR (p_collaboration_standard IS NULL)
             ) THEN

                BEGIN
                     IF (l_Debug_Level <= 1) THEN
                             ecx_cln_debug_pub.Add('-- Before SQL query to find the trading partner set up from ECX_DOCLOGS --',1);
                     END IF;


                     IF (p_xmlg_msg_id is not null ) THEN
                          SELECT  internal_control_number, msgid, transaction_type, transaction_subtype,
                          document_number, party_type, partyid, party_site_id, direction, protocol_type,
                          message_standard, message_type, event_key
                          INTO  l_xmlg_internal_control_number, l_xmlg_msg_id, l_xmlg_transaction_type, l_xmlg_transaction_subtype,
                          l_xmlg_document_id, l_tr_partner_type, l_tr_partner_id, l_tr_partner_site, l_doc_dir, l_sender_component,
                          l_xmlg_msg_standard, l_xmlg_msg_type, l_xml_event_key
                          FROM ECX_DOCLOGS
                          WHERE  MSGID                 = HEXTORAW(p_xmlg_msg_id);
                     ELSIF (p_xmlg_internal_control_number is not null ) THEN
                          SELECT  internal_control_number, msgid, transaction_type, transaction_subtype,
                          document_number, party_type, partyid, party_site_id, direction, protocol_type,
                          message_standard, message_type, event_key
                          INTO  l_xmlg_internal_control_number, l_xmlg_msg_id, l_xmlg_transaction_type,
                          l_xmlg_transaction_subtype, l_xmlg_document_id, l_tr_partner_type, l_tr_partner_id,
                          l_tr_partner_site, l_doc_dir, l_sender_component, l_xmlg_msg_standard, l_xmlg_msg_type, l_xml_event_key
                          FROM ECX_DOCLOGS
                          WHERE  INTERNAL_CONTROL_NUMBER      = p_xmlg_internal_control_number;
                     ELSIF (p_xmlg_transaction_type is not null and p_xmlg_transaction_subtype is not null and p_xmlg_document_id IS not NULL) THEN
                          SELECT  internal_control_number, msgid, transaction_type, transaction_subtype,
                          document_number, party_type, partyid, party_site_id, direction, protocol_type,
                          message_standard, message_type, event_key
                          INTO  l_xmlg_internal_control_number, l_xmlg_msg_id, l_xmlg_transaction_type,
                          l_xmlg_transaction_subtype, l_xmlg_document_id, l_tr_partner_type, l_tr_partner_id,
                          l_tr_partner_site, l_doc_dir, l_sender_component, l_xmlg_msg_standard, l_xmlg_msg_type, l_xml_event_key
                          FROM ECX_DOCLOGS
                          WHERE  transaction_type      = p_xmlg_transaction_type
                            AND  transaction_subtype   = p_xmlg_transaction_subtype
                            AND  document_number       = p_xmlg_document_id
                            AND  direction             = NVL(p_doc_dir,direction)
                            AND  (event_key is null or p_xml_event_key is null or event_key = p_xml_event_key);
                     ELSIF (p_xmlg_int_transaction_type is not null and p_xmlg_int_transaction_subtype is not null and p_xmlg_document_id IS not NULL) THEN
                          SELECT  doclogs.internal_control_number, doclogs.msgid, doclogs.transaction_type, doclogs.transaction_subtype,
                          doclogs.document_number, doclogs.party_type, doclogs.partyid, doclogs.party_site_id, doclogs.direction,
                          doclogs.protocol_type, doclogs.message_standard, doclogs.message_type, doclogs.event_key
                          INTO  l_xmlg_internal_control_number, l_xmlg_msg_id, l_xmlg_transaction_type, l_xmlg_transaction_subtype,
                          l_xmlg_document_id, l_tr_partner_type, l_tr_partner_id,l_tr_partner_site, l_doc_dir,
                          l_sender_component, l_xmlg_msg_standard, l_xmlg_msg_type, l_xml_event_key
                          FROM ECX_TRANSACTIONS ecxtrans, ECX_EXT_PROCESSES ecxproc,    ECX_DOCLOGS doclogs
                          WHERE  ecxtrans.TRANSACTION_TYPE     = NVL(p_xmlg_int_transaction_type,l_xmlg_int_transaction_type)
                            AND  ecxtrans.TRANSACTION_SUBTYPE  = NVL(p_xmlg_int_transaction_subtype,l_xmlg_int_transaction_subtype)
                            AND  ecxproc.TRANSACTION_ID        = ecxtrans.TRANSACTION_ID
                            AND  ecxproc.DIRECTION             = NVL(p_doc_dir,ecxproc.direction)
                            AND  ecxproc.DIRECTION             = doclogs.DIRECTION
                            AND  (event_key is null or p_xml_event_key is null or event_key = p_xml_event_key)
                            AND  doclogs.transaction_type      = ecxproc.EXT_TYPE
                            AND  doclogs.transaction_subtype   = ecxproc.EXT_SUBTYPE
                            AND  doclogs.document_number       = p_xmlg_document_id;
                     END IF;
                     IF (l_Debug_Level <= 1) THEN
                             ecx_cln_debug_pub.Add('-- After SQL query to find the trading partner set up from ECX_DOCLOGS --',1);
                     END IF;


                EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                               FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_FOUND');
                               x_msg_data := FND_MESSAGE.GET;
                               ecx_cln_debug_pub.Add('Unable to find the set up details for the trading partner',1);
                          WHEN TOO_MANY_ROWS THEN
                               FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_FOUND');
                               x_msg_data := FND_MESSAGE.GET;
                               ecx_cln_debug_pub.Add('More then one row found for the same trading partner set up',1);
                END;

                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('==========Parameters Received From ECX_DOCLOG=============',1);
                        ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO       ----- >>>'||l_xmlg_internal_control_number,1);
                        ecx_cln_debug_pub.Add('XMLG MESSAGE ID                ----- >>>'||l_xmlg_msg_id,1);
                        ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE      ----- >>>'||l_xmlg_transaction_type,1);
                        ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE   ----- >>>'||l_xmlg_transaction_subtype,1);
                        ecx_cln_debug_pub.Add('XMLG DOCUMENT ID               ----- >>>'||l_xmlg_document_id,1);
                        ecx_cln_debug_pub.Add('DOCUMENT DIRECTION             ----- >>>'||l_doc_dir,1);
                        ecx_cln_debug_pub.Add('TRADING PARTNER TYPE           ----- >>>'||l_tr_partner_type,1);
                        ecx_cln_debug_pub.Add('TRADING PARTNER ID             ----- >>>'||l_tr_partner_id,1);
                        ecx_cln_debug_pub.Add('TRADING PARTNER SITE           ----- >>>'||l_tr_partner_site,1);
                        ecx_cln_debug_pub.Add('SENDER COMPONENT               ----- >>>'||l_sender_component,1);
                        ecx_cln_debug_pub.Add('XMLG MESSAGE STANDARD ID       ----- >>>'||l_xmlg_msg_standard,1);
                        ecx_cln_debug_pub.Add('XMLG EVENT KEY                 ----- >>>'||l_xml_event_key,1);
                        ecx_cln_debug_pub.Add('===========================================',1);
                END IF;


                -- Getting External Transaction type and Subtype associated with Internal transaction type
                -- and Internal transaction subtype
                IF ((l_xmlg_transaction_type IS NULL) OR (l_xmlg_transaction_subtype IS NULL) OR (l_xmlg_msg_standard IS NULL ) ) THEN
                     IF (l_Debug_Level <= 1) THEN
                             ecx_cln_debug_pub.Add('Getting values for External Transaction type and SubType and msg standard',1);
                     END IF;

                     BEGIN
                         SELECT ecxproc.EXT_TYPE,ecxproc.EXT_SUBTYPE, estd.standard_code
                         INTO l_xmlg_transaction_type, l_xmlg_transaction_subtype, l_xmlg_msg_standard
                         FROM ecx_tp_headers eth, ecx_tp_details etd, ECX_TRANSACTIONS ecxtrans, ECX_EXT_PROCESSES ecxproc, ecx_standards estd
                         WHERE eth.party_id = p_tr_partner_id
                          AND eth.party_site_id  = p_tr_partner_site
                          AND eth.party_type = nvl(l_tr_partner_type, eth.party_type)
                          AND eth.tp_header_id = etd.tp_header_id
                          AND etd.ext_process_id = ecxproc.ext_process_id
                          AND ecxtrans.transaction_id     = ecxproc.transaction_id
                          AND ecxtrans.transaction_type     = nvl(p_xmlg_int_transaction_type,l_xmlg_int_transaction_type)
                          AND ecxtrans.transaction_subtype  = nvl(p_xmlg_int_transaction_subtype,l_xmlg_int_transaction_subtype)
                          AND ecxproc.direction             = nvl(p_doc_dir,ecxproc.direction)
                          AND estd.standard_id              = ecxproc.standard_id;

                         IF (l_Debug_Level <= 1) THEN
                                 ecx_cln_debug_pub.Add('====Parameters Received From ECX_TRANSACTIONS/ECX_EXT_PROCESSES====',1);
                                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE      ----- >>>'||l_xmlg_transaction_type,1);
                                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE   ----- >>>'||l_xmlg_transaction_subtype,1);
                                 ecx_cln_debug_pub.Add('XMLG Message Standard          ----- >>>'||l_xmlg_msg_standard,1);
                                 ecx_cln_debug_pub.Add('==================================================================',1);
                         END IF;



                     EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_TRANSACTION_NOT_FOUND');
                              x_msg_data := FND_MESSAGE.GET;
                              IF (l_Debug_Level <= 1) THEN
                                      ecx_cln_debug_pub.Add('Unable to find External Transaction Type/ Subtype',1);
                              END IF;


                          WHEN TOO_MANY_ROWS THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_EXCESS_TXN_FOUND');
                              x_msg_data := SUBSTR(FND_MESSAGE.GET,10);
                              IF (l_Debug_Level <= 1) THEN
                                      ecx_cln_debug_pub.Add('More then one row found for the same transaction detail',1);
                              END IF;

                     END;
                END IF;

/*              ***** NOT REQUIRED *******
                -- Getting Internal Transaction type and Subtype associated with External transaction type
                -- and External transaction subtype
                IF ((p_xmlg_int_transaction_type IS NULL) OR (p_xmlg_int_transaction_subtype IS NULL)) THEN
                     ecx_cln_debug_pub.Add('Getting values for Internal Transaction type and SubType',1);
                     BEGIN
                          SELECT distinct ecxtrans.TRANSACTION_TYPE, ecxtrans.TRANSACTION_SUBTYPE
                          INTO l_xmlg_int_transaction_type, l_xmlg_int_transaction_subtype
                          FROM ECX_TRANSACTIONS ecxtrans, ECX_EXT_PROCESSES ecxproc
                          WHERE ecxtrans.TRANSACTION_ID    = ecxproc.TRANSACTION_ID
                          AND ecxproc.EXT_TYPE             = NVL(p_xmlg_transaction_type,l_xmlg_transaction_type)
                          AND ecxproc.EXT_SUBTYPE          = NVL(p_xmlg_transaction_subtype,l_xmlg_transaction_subtype)
                          AND ecxproc.DIRECTION            = NVL(p_doc_dir,l_doc_dir);

                          ecx_cln_debug_pub.Add('====Parameters Received From ECX_TRANSACTIONS/ECX_EXT_PROCESSES====',1);
                          ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE      ----- >>>'||l_xmlg_int_transaction_type,1);
                          ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE   ----- >>>'||l_xmlg_int_transaction_subtype,1);
                          ecx_cln_debug_pub.Add('==================================================================',1);

                     EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_TRANSACTION_NOT_FOUND');
                              x_msg_data := FND_MESSAGE.GET;
                              ecx_cln_debug_pub.Add('Unable to find Internal Transaction Type/ Subtype',1);

                          WHEN TOO_MANY_ROWS THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_EXCESS_TXN_FOUND');
                              x_msg_data := SUBSTR(FND_MESSAGE.GET,10);
                              ecx_cln_debug_pub.Add('More then one row found for the same transaction detail',1);
                     END;
                END IF;
*/



                -- Assingning non null values to the input parameters
                p_xmlg_internal_control_number := NVL(p_xmlg_internal_control_number,l_xmlg_internal_control_number);
                p_xmlg_msg_id                  := NVL(p_xmlg_msg_id,l_xmlg_msg_id);
                p_xmlg_transaction_type        := NVL(p_xmlg_transaction_type,l_xmlg_transaction_type);
                p_xmlg_transaction_subtype     := NVL(p_xmlg_transaction_subtype,l_xmlg_transaction_subtype);
                p_xmlg_int_transaction_type    := NVL(p_xmlg_int_transaction_type,l_xmlg_int_transaction_type);
                p_xmlg_int_transaction_subtype := NVL(p_xmlg_int_transaction_subtype,l_xmlg_int_transaction_subtype);
                p_xmlg_document_id             := NVL(p_xmlg_document_id,l_xmlg_document_id);
                p_doc_dir                      := NVL(p_doc_dir,l_doc_dir);
                p_sender_component             := NVL(p_sender_component,l_sender_component);
                p_xml_event_key                := NVL(p_xml_event_key, l_xml_event_key);
                p_collaboration_standard       := NVL(p_collaboration_standard, l_xmlg_msg_standard);

                IF (p_tr_partner_type IS NULL OR p_tr_partner_id IS NULL OR p_tr_partner_site IS NULL or l_xmlg_msg_standard is null )
                   THEN -- based on the ecx doclogs values we have to get actual TP values
                   BEGIN
                      IF (l_Debug_Level <= 1) THEN
                              ecx_cln_debug_pub.Add('-- Before SQL query to find the trading partner set up from ecx_ext_processes /ecx_tp_details /ecx_tp_headers',1);
                      END IF;


                      SELECT  eth.party_id, eth.party_site_id, eth.party_type, estd.standard_code
                      INTO l_txn_partner_id, l_txn_partner_site, l_txn_partner_type, l_xmlg_msg_standard
                      FROM    ecx_ext_processes eep, ecx_tp_details etd, ecx_tp_headers eth, ecx_standards estd
                      WHERE   eep.ext_type                    = l_xmlg_transaction_type
                      AND     eep.ext_subtype                 = l_xmlg_transaction_subtype
                      AND     eep.standard_id                 = estd.standard_id
                      AND     estd.standard_code              = l_xmlg_msg_standard
                      AND     eep.ext_process_id              = etd.ext_process_id
                      AND     etd.source_tp_location_code     = l_tr_partner_site
                      AND     eep.direction                   = l_doc_dir
                      AND     eth.party_type                  = NVL(l_tr_partner_type,eth.party_type)
                      AND     eth.tp_header_id                = etd.tp_header_id
                      AND     estd.standard_type              = l_xmlg_msg_type;

                      IF (l_Debug_Level <= 1) THEN
                              ecx_cln_debug_pub.Add('-- After SQL query ----',1);
                      END IF;


                      IF (l_Debug_Level <= 1) THEN
                              ecx_cln_debug_pub.Add('====Trading Partner Parameters Changed To IDs Using ecx_ext_processes /ecx_tp_details /ecx_tp_headers =====',1);
                              ecx_cln_debug_pub.Add('TRADING PARTNER TYPE       ----- >>>'||l_txn_partner_id,1);
                              ecx_cln_debug_pub.Add('TRADING PARTNER ID         ----- >>>'||l_txn_partner_site,1);
                              ecx_cln_debug_pub.Add('TRADING PARTNER SITE       ----- >>>'||l_txn_partner_type,1);
                              ecx_cln_debug_pub.Add('Message Standard           ----- >>>'||l_xmlg_msg_standard,1);
                              ecx_cln_debug_pub.Add('===========================================================================',1);
                      END IF;


                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                           FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_FOUND');
                           x_msg_data := FND_MESSAGE.GET;
                           IF (l_Debug_Level <= 1) THEN
                                   ecx_cln_debug_pub.Add('Unable to find the id details for the trading partner',1);
                                   ecx_cln_debug_pub.Add('Trying to find details without considering party type',1);
                           END IF;

                           BEGIN
                              SELECT  eth.party_id, eth.party_site_id, eth.party_type, estd.standard_code
                              INTO l_txn_partner_id, l_txn_partner_site, l_txn_partner_type, l_xmlg_msg_standard
                              FROM    ecx_ext_processes eep, ecx_tp_details etd, ecx_tp_headers eth, ecx_standards estd
                              WHERE   eep.ext_type                    = l_xmlg_transaction_type
                              AND     eep.ext_subtype                 = l_xmlg_transaction_subtype
                              AND     eep.standard_id                 = estd.standard_id
                              AND     estd.standard_code              = l_xmlg_msg_standard
                              AND     eep.ext_process_id              = etd.ext_process_id
                              AND     etd.source_tp_location_code     = l_tr_partner_site
                              AND     eep.direction                   = l_doc_dir
                              AND     eth.tp_header_id                = etd.tp_header_id
                              AND     estd.standard_type              = l_xmlg_msg_type;
                           EXCEPTION
                              WHEN OTHERS THEN
                                   FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_FOUND');
                                   x_msg_data := FND_MESSAGE.GET;
                                   IF (l_Debug_Level <= 1) THEN
                                           ecx_cln_debug_pub.Add('Event without TP, unable to find the id details for the trading partner',1);
                                   END IF;
                           END;


                      WHEN TOO_MANY_ROWS THEN
                           FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS_NOT_FOUND');
                           x_msg_data := FND_MESSAGE.GET;
                           IF (l_Debug_Level <= 1) THEN
                                   ecx_cln_debug_pub.Add('More then one row found for the same trading partner set up',1);
                           END IF;

                   END;
                   p_tr_partner_type              := NVL(p_tr_partner_type,l_txn_partner_type);
                   p_tr_partner_id                := NVL(p_tr_partner_id,l_txn_partner_id);
                   p_tr_partner_site              := NVL(p_tr_partner_site,l_txn_partner_site);
                   p_collaboration_standard       := NVL(p_collaboration_standard,l_xmlg_msg_standard);
                END IF;
         ELSE
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     FND_MESSAGE.SET_NAME('CLN','CLN_CH_API_CALL_NOT_REQD');
                     x_msg_data      := FND_MESSAGE.GET;
                     IF (l_Debug_Level <= 1) THEN
                             ecx_cln_debug_pub.Add('API - GET_TRADING_PARTNER_DETAILS need not be called as all input parameters are having non-null values ',1);
                     END IF;

                     RETURN;
         END IF;

         -- values obtained after the query to ecx_doclogs table
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('====Parameters Just Before Returning To the Main Calling Procedure======',1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO       ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID                ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE      ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUB TYPE  ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE      ----- >>>'||p_xmlg_int_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUB TYPE  ----- >>>'||p_xmlg_int_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID               ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION             ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER TYPE           ----- >>>'||p_tr_partner_type,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER ID             ----- >>>'||p_tr_partner_id,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER SITE           ----- >>>'||p_tr_partner_site,1);
                 ecx_cln_debug_pub.Add('SENDER COMPONENT               ----- >>>'||p_sender_component,1);
                 ecx_cln_debug_pub.Add('XMLG EVENT KEY                 ----- >>>'||p_xml_event_key,1);
                 ecx_cln_debug_pub.Add('Message Standard               ----- >>>'||p_collaboration_standard,1);
                 ecx_cln_debug_pub.Add('=============================================================',1);
         END IF;



         FND_MESSAGE.SET_NAME('CLN','CLN_CH_TP_DETAILS');
         x_msg_data      := FND_MESSAGE.GET;

         l_msg_data := 'Successfully retrieved values for the Trading partner';
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add(l_msg_data,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------ Exiting GET_TRADING_PARTNER_DETAILS ------- ',2);
         END IF;

    EXCEPTION

         WHEN OTHERS THEN
              l_error_code       :=SQLCODE;
              l_error_msg        :=SQLERRM;
              x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR; -- sending back success for backward compatibility
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data         :=FND_MESSAGE.GET;
              l_msg_data         := 'Unexpected Error : '||l_error_code||'-'||l_error_msg;
              IF (l_Debug_Level <= 6) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('------ Exiting GET_TRADING_PARTNER_DETAILS ------- ',2);
              END IF;

    END GET_TRADING_PARTNER_DETAILS;


  -- Name
  --   DEFAULT_XMLGTXN_MAPPING
  -- Purpose
  --   This is the public procedure which returns the application id for a given set of
  --   parameters passed while refering to teh CLN_CH_XMLGTXN_MAPPING.
  -- Arguments
  --
  -- Notes
  --   No specific notes.

     PROCEDURE DEFAULT_XMLGTXN_MAPPING(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_type        IN  VARCHAR2,
         p_xmlg_transaction_subtype     IN  VARCHAR2,
         p_doc_dir                      IN  VARCHAR2,
         p_app_id                       IN OUT NOCOPY VARCHAR2 ,
         p_coll_type                    IN OUT NOCOPY VARCHAR2,
         p_doc_type                     IN OUT NOCOPY VARCHAR2 )

    IS

         l_error_code                   NUMBER;
         l_msg_data                     VARCHAR2(2000);
         l_error_msg                    VARCHAR2(2000);
         l_debug_mode                   VARCHAR2(255);
         l_application_id               NUMBER;
         l_collaboration_type           VARCHAR2(30);
         l_document_type                VARCHAR2(100);


    BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------ Entering DEFAULT_XMLGTXN_MAPPING API ------ ',2);
         END IF;


         -- Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('XMLG TRANSACTION TYPE      ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG TRANSACTION SUBTYPE   ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION         ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('APPLCATION ID              ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('COLL TYPE                  ----- >>>'||p_coll_type,1);
                 ecx_cln_debug_pub.Add('DOCUMENT TYPE              ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('==========================================',1);
         END IF;



         --check for the reqd parameters for this API
         IF ( ( p_xmlg_transaction_type IS NULL)
              OR (p_xmlg_transaction_subtype IS NULL)
              OR (p_doc_dir IS NULL)
             ) THEN
                l_msg_data      := 'Required parameters(p_xmlg_transaction_type/  p_xmlg_transaction_subtype / p_xmlg_document_direction)  missing';
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add(l_msg_data,1);
                END IF;

                FND_MESSAGE.SET_NAME('CLN','CLN_CH_REQD_KEY_MISSING');
                FND_MESSAGE.SET_TOKEN('API','DEFAULT_XMLGTXN_MAPPING');
                x_msg_data      := FND_MESSAGE.GET;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                RETURN;
         END IF;


         -- Get the trading  partner  details
         IF ((p_app_id IS NULL) OR (p_coll_type IS NULL) OR (p_doc_type IS NULL)) THEN
                BEGIN
                       IF (l_Debug_Level <= 1) THEN
                               ecx_cln_debug_pub.Add('-- Before sql query to CLN_CH_XMLGTXN_MAPPING --',1);
                       END IF;

                       SELECT  application_id, collaboration_type, document_type
                       INTO  l_application_id, l_collaboration_type, l_document_type
                       FROM CLN_CH_XMLGTXN_MAPPING
                       WHERE XMLG_TRANSACTION_TYPE    = p_xmlg_transaction_type
                       AND  XMLG_TRANSACTION_SUBTYPE  = p_xmlg_transaction_subtype
                       AND  DOCUMENT_DIRECTION        = p_doc_dir ;
                       IF (l_Debug_Level <= 1) THEN
                               ecx_cln_debug_pub.Add('-- After sql query to CLN_CH_XMLGTXN_MAPPING --',1);
                       END IF;


                EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            -- Here return status is passed as success just because the notification processing module
                            -- has to create an error collaboration incase setup information is wrong or xmlg gives error
                            -- while processing the xml document.
                            l_msg_data := 'Unable to find the default xmlg mapping values for the application';
                            IF (l_Debug_Level <= 1) THEN
                                    ecx_cln_debug_pub.Add(l_msg_data,1);
                            END IF;

                            FND_MESSAGE.SET_NAME('CLN','CLN_CH_XMLGTXN_MAPPING_NF');
                            x_msg_data          := FND_MESSAGE.GET;
                            x_return_status     := FND_API.G_RET_STS_SUCCESS;
                            RETURN;
                END;
         END IF;


         -- Assingning non null values to the input parameters
         p_app_id                := NVL(p_app_id,l_application_id);
         p_coll_type             := NVL(p_coll_type,l_collaboration_type);
         p_doc_type              := NVL(p_doc_type,l_document_type);


         -- values obtained after the query to ecx_doclogs table
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters After Query To ECX_DOCLOGS=============',1);
                 ecx_cln_debug_pub.Add('APPLICATION ID              ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('COLLABORATION TYPE          ----- >>>'||p_coll_type,1);
                 ecx_cln_debug_pub.Add('COLLABORATION DOCUMENT TYPE ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('=============================================================',1);
         END IF;


         l_msg_data     := 'Successfully retrieved default values from the CLN_XMLGTXN_MAPPING';
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add(l_msg_data,1);
                 ecx_cln_debug_pub.Add('------ Exiting DEFAULT_XMLGTXN_MAPPING ------- ',2);
         END IF;



   EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status    := FND_API.G_RET_STS_SUCCESS ;-- sending back success for backward compatibility
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('------ ERROR--------');
                      ecx_cln_debug_pub.Add('------ Exiting DEFAULT_XMLGTXN_MAPPING ------- ',2);
              END IF;



         WHEN OTHERS THEN
              l_error_code       :=SQLCODE;
              l_error_msg        :=SQLERRM;
              x_return_status    := FND_API.G_RET_STS_SUCCESS ; -- sending back success for backward compatibility
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data         :=FND_MESSAGE.GET;
              l_msg_data         := 'Unexpected Error : '||l_error_code||'-'||l_error_msg;
              IF (l_Debug_Level <= 5) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,6);
                      ecx_cln_debug_pub.Add('------ Exiting DEFAULT_XMLGTXN_MAPPING ------- ',2);
              END IF;


    END DEFAULT_XMLGTXN_MAPPING;


  -- Name
  --   DEFAULT_COLLABORATION_STATUS
  -- Purpose
  --   This procedure defaults collaboration status based on the rules defined in
  --   CLN_COLL_STATUS_MAPPING table.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


    PROCEDURE DEFAULT_COLLABORATION_STATUS(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         x_coll_status                  IN  OUT NOCOPY VARCHAR2,
         p_app_id                       IN  VARCHAR2,
         p_coll_type                    IN  VARCHAR2,
         p_doc_status                   IN  VARCHAR2,
         p_doc_type                     IN  VARCHAR2,
         p_doc_dir                      IN  VARCHAR2,
         p_coll_id                      IN  NUMBER,
         p_coll_standard                IN  VARCHAR2
	 )

    IS
         l_error_code                   NUMBER;
         l_error_msg                    VARCHAR2(2000);
         l_msg_data                     VARCHAR2(2000);
         l_debug_mode                   VARCHAR2(255);
         l_message_count                NUMBER;
         l_msg_count_in_hist            NUMBER;

    BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('------Entering DEFAULT_COLLABORATION_STATUS API---- ',2);
         END IF;


         -- Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         FND_MESSAGE.SET_NAME('CLN','CLN_COLL_STATUS_FOUND');

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('------------Parameters Received-------------',1);
                 ecx_cln_debug_pub.Add('APPLCATION ID     ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('COLL TYPE         ----- >>>'||p_coll_type,1);
                 ecx_cln_debug_pub.Add('COLL STANDARD     ----- >>>'||p_coll_standard,1);
                 ecx_cln_debug_pub.Add('DOC STATUS        ----- >>>'||p_doc_status,1);
                 ecx_cln_debug_pub.Add('DOC TYPE          ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('DOC DIRECTION     ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('COLLABORATION ID  ----- >>>'||p_coll_id,1);
                 ecx_cln_debug_pub.Add('---------------------------------------------',1);
         END IF;



         IF (p_doc_status = 'ERROR') THEN
            x_coll_status := 'ERROR';
            FND_MESSAGE.SET_TOKEN('STATUS','ERROR');
            x_msg_data := FND_MESSAGE.GET;
            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('Collaboration Status     ----- >>>'||x_coll_status ,1);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('-------- Exiting DEFAULT_COLLABORATION_STATUS API ----- ',2);
            END IF;

            RETURN;
         END IF;

         x_coll_status := 'STARTED';
         BEGIN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('----- Before querying the CLN_COLL_COMPLETED_STATUS ----',1);
                END IF;


                SELECT  message_count
                INTO  l_message_count
                FROM  CLN_COLL_COMPLETED_STATUS
                WHERE  application_id = p_app_id
                       AND  collaboration_type = p_coll_type
                       AND  nvl(collaboration_standard,nvl(p_coll_standard,'~')) = nvl(p_coll_standard,'~')
                       AND  document_type = p_doc_type
                       AND  document_direction = p_doc_dir;

                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('----- After querying the CLN_COLL_COMPLETED_STATUS ----',1);
                        ecx_cln_debug_pub.Add('----- Message count : '||l_message_count,1);
                END IF;


                IF (l_message_count > 1) THEN
                    -- We have to query coll and find out for howmany messages
                    -- are already there. If they are greater than or equal to
                    -- what is specified then the status is completed normal.
                    IF (l_Debug_Level <= 1) THEN
                            ecx_cln_debug_pub.Add('---- Before querying the collaboration history ---',1);
                    END IF;


                    SELECT count('x')
                    INTO   l_msg_count_in_hist
                    FROM CLN_COLL_HIST_HDR hdr, CLN_COLL_HIST_DTL dtl
                    WHERE  hdr.collaboration_id            = p_coll_id
                       AND hdr.collaboration_id            = dtl.collaboration_id
                       AND hdr.application_id              = p_app_id
                       AND hdr.collaboration_type          = p_coll_type
                       AND dtl.collaboration_document_type = p_doc_type
                       AND dtl.document_direction          = p_doc_dir;

                    IF (l_Debug_Level <= 1) THEN
                            ecx_cln_debug_pub.Add('---- After querying the collaboration history ---, count : ' || l_msg_count_in_hist ,1);
                    END IF;


                    IF (l_msg_count_in_hist >= l_message_count-1) THEN
                          x_coll_status := 'COMPLETED';
                          FND_MESSAGE.SET_TOKEN('STATUS','COMPLETED');
                          x_msg_data := FND_MESSAGE.GET;
                    END IF;
                ELSE
                    x_coll_status := 'COMPLETED';
                    FND_MESSAGE.SET_TOKEN('STATUS','COMPLETED');
                    x_msg_data := FND_MESSAGE.GET;
                END IF;

         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                       x_coll_status := 'STARTED';
                       FND_MESSAGE.SET_TOKEN('STATUS','STARTED');
                       x_msg_data := FND_MESSAGE.GET;
         END;

         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('Collaboration Status     ----- >>>'||x_coll_status ,1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('-------- Exiting DEFAULT_COLLABORATION_STATUS API ----- ',2);
         END IF;


    -- Exception Handling
    EXCEPTION
         WHEN OTHERS THEN
              l_error_code      := SQLCODE;
              l_error_msg       := SQLERRM;
              x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR ;
              x_msg_data        := l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 6) THEN
                      ecx_cln_debug_pub.Add(x_msg_data,6);
                      ecx_cln_debug_pub.Add('-------- Exiting DEFAULT_COLLABORATION_STATUS API WITH ERROR----- ',2);
              END IF;


    END DEFAULT_COLLABORATION_STATUS;



  -- Name
  --   FIND_COLLABORATION_ID
  -- Purpose
  --   This is the public procedure which may be used to get the collaboration id
  --   for a particular transaction.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


     PROCEDURE FIND_COLLABORATION_ID(
            x_return_status                        OUT NOCOPY VARCHAR2,
            x_msg_data                             OUT NOCOPY VARCHAR2,
            x_coll_id                              OUT NOCOPY NUMBER,
            p_app_id                               IN  VARCHAR2,
	    p_coll_type                            IN  VARCHAR2,
            p_ref_id                               IN  VARCHAR2,
            p_xmlg_transaction_type                IN  VARCHAR2,
            p_xmlg_transaction_subtype             IN  VARCHAR2,
            p_xmlg_int_transaction_type            IN  VARCHAR2,--NOT USED FOR THIS RELEASE
            p_xmlg_int_transaction_subtype         IN  VARCHAR2,--NOT USED FOR THIS RELEASE
            p_tr_partner_id                        IN  VARCHAR2,
            p_tr_partner_site                      IN  VARCHAR2,
            p_tr_partner_type                      IN  VARCHAR2,
            p_xmlg_document_id                     IN  VARCHAR2,
            p_doc_dir                              IN  VARCHAR2,
            p_xmlg_msg_id                          IN  VARCHAR2,
            p_unique1                              IN  VARCHAR2,
            p_unique2                              IN  VARCHAR2,
            p_unique3                              IN  VARCHAR2,
            p_unique4                              IN  VARCHAR2,
            p_unique5                              IN  VARCHAR2,
            p_xmlg_internal_control_number         IN  NUMBER,
            p_xml_event_key                        IN  VARCHAR2,
            p_collaboration_standard               IN  VARCHAR2)
    IS
            l_error_code                           NUMBER;
            l_error_msg                            VARCHAR2(2000);
            l_msg_data                             VARCHAR2(2000);
            l_debug_mode                           VARCHAR2(255);
            l_data_area_refid                      VARCHAR2(255);
            l_corrspnd_internal_cntrl_num  NUMBER;
    BEGIN

            -- Sets the debug mode to be FILE
            --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');


            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('--------- Entering FIND_COLLABORATION_ID API ------------ ',2);
            END IF;


            --  Initialize API return status to success
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_msg_data     := 'Collaboration ID successfully found ';


            -- get the paramaters passed
            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                    ecx_cln_debug_pub.Add('APPLCATION ID                       ----- >>>'||p_app_id,1);
                    ecx_cln_debug_pub.Add('REFERENCE ID                        ----- >>>'||p_ref_id,1);
                    ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE           ----- >>>'||p_xmlg_transaction_type,1);
                    ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE        ----- >>>'||p_xmlg_transaction_subtype,1);
                    ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE           ----- >>>'||p_xmlg_int_transaction_type,1);
                    ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE        ----- >>>'||p_xmlg_int_transaction_subtype,1);
                    ecx_cln_debug_pub.Add('XMLG TRADING PARTNER ID             ----- >>>'||p_tr_partner_id,1);
                    ecx_cln_debug_pub.Add('XMLG TRADING PARTNER SITE           ----- >>>'||p_tr_partner_site,1);
                    ecx_cln_debug_pub.Add('XMLG TRADING PARTNER TYPE           ----- >>>'||p_tr_partner_type,1);
                    ecx_cln_debug_pub.Add('XMLG DOCUMENT ID                    ----- >>>'||p_xmlg_document_id,1);
                    ecx_cln_debug_pub.Add('DOCUMENT DIRECTION                  ----- >>>'||p_doc_dir,1);
                    ecx_cln_debug_pub.Add('XMLG MESSAGE ID                     ----- >>>'||p_xmlg_msg_id,1);
                    ecx_cln_debug_pub.Add('UNIQUE 1                            ----- >>>'||p_unique1,1);
                    ecx_cln_debug_pub.Add('UNIQUE 2                            ----- >>>'||p_unique2,1);
                    ecx_cln_debug_pub.Add('UNIQUE 3                            ----- >>>'||p_unique3,1);
                    ecx_cln_debug_pub.Add('UNIQUE 4                            ----- >>>'||p_unique4,1);
                    ecx_cln_debug_pub.Add('UNIQUE 5                            ----- >>>'||p_unique5,1);
                    ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO            ----- >>>'||p_xmlg_internal_control_number,1);
                    ecx_cln_debug_pub.Add('XMLG EVENT KEY                      ----- >>>'||p_xml_event_key,1);
                    ecx_cln_debug_pub.Add('===========================================',1);
            END IF;



            BEGIN
                         IF (l_Debug_Level <= 1) THEN
                          ecx_cln_debug_pub.Add('----- Query 1: Finding Collaboration ID from CLN_COLL_HIST_HDR table ----',1);
                         END IF;

			SELECT COLLABORATION_ID INTO x_coll_id
                         FROM CLN_COLL_HIST_HDR
                         WHERE   (APPLICATION_REFERENCE_ID=p_ref_id)
                                 OR      XMLG_MSG_ID                      =       p_xmlg_msg_id
                                 OR      XMLG_INTERNAL_CONTROL_NUMBER     =       p_xmlg_internal_control_number;

                         IF (l_Debug_Level <= 1) THEN
                                 ecx_cln_debug_pub.Add('Collaboration ID found as - '||x_coll_id,1);
                         END IF;


            EXCEPTION
                        WHEN TOO_MANY_ROWS THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNIQUE_COLLABORATION_NF');
                              x_msg_data := FND_MESSAGE.GET;
                              l_msg_data := 'Unique Collaboration Not Found';
                              RAISE FND_API.G_EXC_ERROR;
			WHEN NO_DATA_FOUND THEN
                        IF (l_Debug_Level <= 1) THEN
			cln_debug_pub.Add('Unable to find the collaboration in Collaboration History - Header Table',1);
			END IF;
			   IF p_unique1 IS NOT NULL OR
                              p_unique2 IS NOT NULL OR
                              p_unique3 IS NOT NULL OR
                              p_unique4 IS NOT NULL OR
                              p_unique5 IS NOT NULL THEN
			     BEGIN
                             IF (l_Debug_Level <= 1) THEN
                                 ecx_cln_debug_pub.Add('----- Query 2: Finding Collaboration ID from CLN_COLL_HIST_HDR table ----',1);
                             END IF;

                             SELECT COLLABORATION_ID INTO x_coll_id
                             FROM CLN_COLL_HIST_HDR
                             WHERE      (APPLICATION_ID  = p_app_id AND UNIQUE_ID1  =       p_unique1)
                                     OR (APPLICATION_ID  = p_app_id AND UNIQUE_ID2  =       p_unique2)
                                     OR (APPLICATION_ID  = p_app_id AND UNIQUE_ID3  =       p_unique3)
                                     OR (APPLICATION_ID  = p_app_id AND UNIQUE_ID4  =       p_unique4)
                                     OR (APPLICATION_ID  = p_app_id AND UNIQUE_ID5  =       p_unique5);

                             IF (l_Debug_Level <= 1) THEN
                                 ecx_cln_debug_pub.Add('Collaboration ID found as - '||x_coll_id,1);
                             END IF;
			  EXCEPTION
                            WHEN NO_DATA_FOUND THEN

                              IF (l_Debug_Level <= 1) THEN
                                      ecx_cln_debug_pub.Add('Unable to find the collaboration in Collaboration History - Header Table',1);
                              END IF;

                            WHEN TOO_MANY_ROWS THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNIQUE_COLLABORATION_NF');
                              x_msg_data := FND_MESSAGE.GET;
                              l_msg_data := 'Unique Collaboration Not Found';
                              RAISE FND_API.G_EXC_ERROR;

            END;
			ELSE
                                  IF (l_Debug_Level <= 1) THEN
                                        cln_debug_pub.Add('Unique_id from 1 to 5 are NULL',1);
                                  END IF;
                               END IF;
               END;

            IF x_coll_id IS NOT NULL THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_ID API ------- ',2);
                END IF;

                RETURN;
            END IF;


            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('----- Finding Collaboration ID from CLN_COLL_HIST_DTL table ----',1);
            END IF;

            BEGIN
                         SELECT COLLABORATION_ID INTO x_coll_id
                         FROM CLN_COLL_HIST_DTL
                         WHERE   (XMLG_MSG_ID                  =       p_xmlg_msg_id
                         OR      XMLG_INTERNAL_CONTROL_NUMBER =       p_xmlg_internal_control_number)
                         AND ROWNUM < 2;
                         IF (l_Debug_Level <= 1) THEN
                                 ecx_cln_debug_pub.Add('Collaboration ID found as - '||x_coll_id,1);
                         END IF;

            EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                              IF (l_Debug_Level <= 1) THEN
                                      ecx_cln_debug_pub.Add('Unable to find the collaboration in Collaboration History - Detail Table',1);
                              END IF;

                         WHEN TOO_MANY_ROWS THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNIQUE_COLLABORATION_NF');
                              x_msg_data := FND_MESSAGE.GET;
                              l_msg_data := 'Unique Collaboration Not Found';
                              RAISE FND_API.G_EXC_ERROR;
            END;

            IF x_coll_id IS NOT NULL THEN
                 IF (l_Debug_Level <= 2) THEN
                         ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_ID API ------- ',2);
                 END IF;

                 RETURN;
            END IF;

            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('----- Finding Collaboration ID from CLN_COLL_HIST_HDR table using Transaction Type/SubType',1);
            END IF;

            BEGIN
                         SELECT COLLABORATION_ID INTO x_coll_id
                         FROM CLN_COLL_HIST_HDR
                         WHERE     XMLG_TRANSACTION_TYPE         =       p_xmlg_transaction_type
                                   AND XMLG_TRANSACTION_SUBTYPE  =       p_xmlg_transaction_subtype
                                   AND XMLG_DOCUMENT_ID          =       p_xmlg_document_id
                                   AND DOCUMENT_DIRECTION        =       nvl(p_doc_dir, DOCUMENT_DIRECTION)
                                   AND (XML_EVENT_KEY is null or p_xml_event_key is null or XML_EVENT_KEY = p_xml_event_key);
                         IF (l_Debug_Level <= 1) THEN
                                 ecx_cln_debug_pub.Add('Collaboration ID found as - '||x_coll_id,1);
                         END IF;

            EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                              IF (l_Debug_Level <= 1) THEN
                                      ecx_cln_debug_pub.Add('Unable to find the collaboration in Collaboration History - Header Table using Transaction Type/SubType',1);
                              END IF;

                         WHEN TOO_MANY_ROWS THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNIQUE_COLLABORATION_NF');
                              x_msg_data := FND_MESSAGE.GET;
                              l_msg_data := 'Unique Collaboration Not Found';
                              RAISE FND_API.G_EXC_ERROR;
            END;


            IF x_coll_id IS NOT NULL THEN
                 IF (l_Debug_Level <= 2) THEN
                         ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_ID API ------- ',2);
                 END IF;

                 RETURN;
            END IF;

            IF (p_doc_dir = 'OUT') and (p_xmlg_msg_id IS NOT NULL) and (p_collaboration_standard is not null) THEN
               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('----- Finding Collaboration ID using the reference id of the payload and then FIELD7 of doclogs',1);
               END IF;

               GET_DATA_AREA_REFID(p_xmlg_msg_id,p_collaboration_standard,l_data_area_refid, p_app_id, p_coll_type);

               IF (l_Debug_Level <= 1) THEN
                       ecx_cln_debug_pub.Add('Data area reference id got as : ' || l_data_area_refid ,1);
               END IF;

               IF l_data_area_refid IS NOT NULL THEN
                  IF (l_Debug_Level <= 1) THEN
                          ecx_cln_debug_pub.Add('Trying to find collaboration based on data area reference id through ecx_doclogs' ,1);
                  END IF;

                  BEGIN
                      IF (l_Debug_Level <= 1) THEN
                              ecx_cln_debug_pub.Add('Trying to get internal control number ',1);
                      END IF;

                      SELECT  doclogs.internal_control_number
                      INTO    l_corrspnd_internal_cntrl_num
                      FROM    ecx_doclogs doclogs, ecx_ext_processes eep, ecx_tp_details etd, ecx_tp_headers eth, ecx_standards estd
                      WHERE   doclogs.direction = 'IN' and doclogs.field7 = l_data_area_refid
                        AND   eep.ext_type                    = doclogs.transaction_type
                        AND   eep.ext_subtype                 = doclogs.transaction_subtype
                        AND   eep.standard_id                 = estd.standard_id
                        AND   estd.standard_code              = doclogs.message_standard
                        AND   eep.ext_process_id              = etd.ext_process_id
                        AND   etd.source_tp_location_code     = doclogs.party_site_id
                        AND   eep.direction                   = doclogs.direction
                        --AND   eth.party_type                  = NVL(doclogs.party_type,eth.party_type)
                        AND   eth.tp_header_id                = etd.tp_header_id
                        AND   estd.standard_type              = doclogs.message_type
                        AND   eth.party_id                    = p_tr_partner_id
                        AND   eth.party_site_id               = p_tr_partner_site
                        AND   eth.party_type                  = p_tr_partner_type;
                      IF (l_Debug_Level <= 1) THEN
                              ecx_cln_debug_pub.Add('Internal control number got : ' || l_corrspnd_internal_cntrl_num,1);
                      END IF;


                      IF (l_Debug_Level <= 1) THEN
                              ecx_cln_debug_pub.Add('Trying to get collaboration id ',1);
                      END IF;


                      SELECT distinct COLLABORATION_ID INTO x_coll_id
                      FROM cln_coll_hist_dtl
                      WHERE  XMLG_INTERNAL_CONTROL_NUMBER = l_corrspnd_internal_cntrl_num;

                  EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                              IF (l_Debug_Level <= 1) THEN
                                      ecx_cln_debug_pub.Add('Unable to find the collaboration in Collaboration History - Header Table using Transaction Type/SubType',1);
                              END IF;

                         WHEN TOO_MANY_ROWS THEN
                              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNIQUE_COLLABORATION_NF');
                              x_msg_data := FND_MESSAGE.GET;
                              l_msg_data := 'Unique Collaboration Not Found';
                              RAISE FND_API.G_EXC_ERROR;
                  END;
               END IF;
            END IF;


            IF (l_Debug_Level <= 1) THEN
                    ecx_cln_debug_pub.Add('Collaboration ID found as : '||x_coll_id,1);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                    ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_ID API ------- ',2);
            END IF;



    EXCEPTION

          WHEN FND_API.G_EXC_ERROR THEN
               x_return_status    := FND_API.G_RET_STS_ERROR ;
               IF (l_Debug_Level <= 4) THEN
                       ecx_cln_debug_pub.Add(l_msg_data,4);
               END IF;

               l_msg_data         :=l_error_code||' : '||l_error_msg;
               IF (l_Debug_Level <= 4) THEN
                       ecx_cln_debug_pub.Add(l_msg_data,4);
                       ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_ID API ------- ',2);
               END IF;


         WHEN OTHERS THEN
              l_error_code       :=SQLCODE;
              l_error_msg        :=SQLERRM;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
              FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
              x_msg_data :=FND_MESSAGE.GET;
              l_msg_data         :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('------ Exiting FIND_COLLABORATION_ID API ------- ',2);
              END IF;


     END FIND_COLLABORATION_ID;

  -- Name
  --   ADD_COLLABORATION
  -- Purpose
  --   This is the public procedure which decides whether the collaboration nneds to be created
  --   or updated.
  -- Arguments
  --
  -- Notes
  --   No specific notes.


    PROCEDURE ADD_COLLABORATION(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER,
         p_app_id                               IN  VARCHAR2,
         p_ref_id                               IN  VARCHAR2,
         p_rel_no                               IN  VARCHAR2,
         p_doc_no                               IN  VARCHAR2,
         p_doc_rev_no                           IN  VARCHAR2,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_xmlg_document_id                     IN  VARCHAR2,
         p_resend_flag                          IN  VARCHAR2,
         p_resend_count                         IN  NUMBER,
         p_disposition                          IN  VARCHAR2,
         p_coll_status                          IN  VARCHAR2,
         p_coll_type                            IN  VARCHAR2,
         p_coll_pt                              IN  VARCHAR2,
         p_doc_type                             IN  VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_org_ref                              IN  VARCHAR2,
         p_doc_status                           IN  VARCHAR2,
         p_notification_id                      IN  VARCHAR2,
         p_msg_text                             IN  VARCHAR2,
         p_attr1                                IN  VARCHAR2,
         p_attr2                                IN  VARCHAR2,
         p_attr3                                IN  VARCHAR2,
         p_attr4                                IN  VARCHAR2,
         p_attr5                                IN  VARCHAR2,
         p_attr6                                IN  VARCHAR2,
         p_attr7                                IN  VARCHAR2,
         p_attr8                                IN  VARCHAR2,
         p_attr9                                IN  VARCHAR2,
         p_attr10                               IN  VARCHAR2,
         p_attr11                               IN  VARCHAR2,
         p_attr12                               IN  VARCHAR2,
         p_attr13                               IN  VARCHAR2,
         p_attr14                               IN  VARCHAR2,
         p_attr15                               IN  VARCHAR2,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2,
         p_unique2                              IN  VARCHAR2,
         p_unique3                              IN  VARCHAR2,
         p_unique4                              IN  VARCHAR2,
         p_unique5                              IN  VARCHAR2,
         p_tr_partner_type                      IN  VARCHAR2,
         p_tr_partner_id                        IN  VARCHAR2,
         p_tr_partner_site                      IN  VARCHAR2,
         p_sender_component                     IN  VARCHAR2,
         p_rosettanet_check_required            IN  BOOLEAN,
         x_dtl_coll_id                          OUT NOCOPY NUMBER,
         p_xmlg_internal_control_number         IN  NUMBER,
         p_partner_doc_no                       IN  VARCHAR2,
         p_org_id                               IN  NUMBER,
         p_init_date                            IN  DATE,
         p_doc_creation_date                    IN  DATE,
         p_doc_revision_date                    IN  DATE,
         p_doc_owner                            IN  VARCHAR2,
         p_xmlg_int_transaction_type            IN  VARCHAR2,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2,
         p_xml_event_key                        IN  VARCHAR2,
         p_collaboration_standard               IN  VARCHAR2,
         p_attribute1                           IN  VARCHAR2,
         p_attribute2                           IN  VARCHAR2,
         p_attribute3                           IN  VARCHAR2,
         p_attribute4                           IN  VARCHAR2,
         p_attribute5                           IN  VARCHAR2,
         p_attribute6                           IN  VARCHAR2,
         p_attribute7                           IN  VARCHAR2,
         p_attribute8                           IN  VARCHAR2,
         p_attribute9                           IN  VARCHAR2,
         p_attribute10                          IN  VARCHAR2,
         p_attribute11                          IN  VARCHAR2,
         p_attribute12                          IN  VARCHAR2,
         p_attribute13                          IN  VARCHAR2,
         p_attribute14                          IN  VARCHAR2,
         p_attribute15                          IN  VARCHAR2,
         p_dattribute1                          IN  DATE,
         p_dattribute2                          IN  DATE,
         p_dattribute3                          IN  DATE,
         p_dattribute4                          IN  DATE,
         p_dattribute5                          IN  DATE,
         p_owner_role                           IN  VARCHAR2 )
    IS
         l_dtl_coll_id                          NUMBER;
         l_coll_id                              NUMBER;
         l_error_code                           NUMBER;
         l_error_msg                            VARCHAR2(2000);
         l_msg_data                             VARCHAR2(2000);
         l_debug_mode                           VARCHAR2(255);
         l_xmlg_transaction_type                VARCHAR2(100);
         l_xmlg_transaction_subtype             VARCHAR2(100);
         l_xmlg_int_transaction_type            VARCHAR2(100);
         l_xmlg_int_transaction_subtype         VARCHAR2(100);
         l_doc_dir                              VARCHAR2(240);
         l_xmlg_internal_control_number         NUMBER;
         l_xmlg_msg_id                          VARCHAR2(100);
         l_xml_event_key                        VARCHAR2(240);
         l_xmlg_document_id                     VARCHAR2(256);
         l_tr_partner_type                      VARCHAR2(30);
         l_tr_partner_id                        VARCHAR2(256);
         l_tr_partner_site                      VARCHAR2(256);
         l_sender_component                     VARCHAR2(500);
         l_collaboration_standard               VARCHAR2(30);
         l_app_id                               VARCHAR2(10);
         l_coll_type                            VARCHAR2(30);
         l_doc_type                             VARCHAR2(100);

    BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=ecx_cln_debug_pub.Set_Debug_Mode('FILE');


         IF (l_Debug_Level <= 2) THEN
                 ecx_cln_debug_pub.Add('--------- Entering ADD_COLLABORATION API ------------ ',2);
         END IF;


         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         l_msg_data     := 'Collaboration successfully created/updated ';



         -- get the paramaters passed
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Parameters Received=============',1);
                 ecx_cln_debug_pub.Add('COLLABORATION ID                    ----- >>>'||p_coll_id,1);
                 ecx_cln_debug_pub.Add('APPLCATION ID                       ----- >>>'||p_app_id,1);
                 ecx_cln_debug_pub.Add('REFERENCE ID                        ----- >>>'||p_ref_id,1);
                 ecx_cln_debug_pub.Add('RELEASE NUMBER                      ----- >>>'||p_rel_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT NO                         ----- >>>'||p_doc_no,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REV. NO                    ----- >>>'||p_doc_rev_no,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION TYPE           ----- >>>'||p_xmlg_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG EXT TRANSACTION SUBTYPE        ----- >>>'||p_xmlg_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION TYPE           ----- >>>'||p_xmlg_int_transaction_type,1);
                 ecx_cln_debug_pub.Add('XMLG INT TRANSACTION SUBTYPE        ----- >>>'||p_xmlg_int_transaction_subtype,1);
                 ecx_cln_debug_pub.Add('XMLG DOCUMENT ID                    ----- >>>'||p_xmlg_document_id,1);
                 ecx_cln_debug_pub.Add('RESENG FLAG                         ----- >>>'||p_resend_flag,1);
                 ecx_cln_debug_pub.Add('RESEND COUNT                        ----- >>>'||p_resend_count,1);
                 ecx_cln_debug_pub.Add('DISPOSITION                         ----- >>>'||p_disposition,1);
                 ecx_cln_debug_pub.Add('COLLABORATION STATUS                ----- >>>'||p_coll_status,1);
                 ecx_cln_debug_pub.Add('COLLABORATION TYPE                  ----- >>>'||p_coll_type,1);
                 ecx_cln_debug_pub.Add('DOCUMENT TYPE                       ----- >>>'||p_doc_type,1);
                 ecx_cln_debug_pub.Add('DOCUMENT DIRECTION                  ----- >>>'||p_doc_dir,1);
                 ecx_cln_debug_pub.Add('COLLABORATION POINT                 ----- >>>'||p_coll_pt,1);
                 ecx_cln_debug_pub.Add('ORIGINATOR REFERENCE                ----- >>>'||p_org_ref,1);
                 ecx_cln_debug_pub.Add('DOCUMENT STATUS                     ----- >>>'||p_doc_status,1);
                 ecx_cln_debug_pub.Add('NOTIFICATION ID                     ----- >>>'||p_notification_id,1);
                 ecx_cln_debug_pub.Add('MESSAGE TEST                        ----- >>>'||p_msg_text,1);
                 ecx_cln_debug_pub.Add('XMLG MESSAGE ID                     ----- >>>'||p_xmlg_msg_id,1);
                 ecx_cln_debug_pub.Add('UNIQUE 1                            ----- >>>'||p_unique1,1);
                 ecx_cln_debug_pub.Add('UNIQUE 2                            ----- >>>'||p_unique2,1);
                 ecx_cln_debug_pub.Add('UNIQUE 3                            ----- >>>'||p_unique3,1);
                 ecx_cln_debug_pub.Add('UNIQUE 4                            ----- >>>'||p_unique4,1);
                 ecx_cln_debug_pub.Add('UNIQUE 5                            ----- >>>'||p_unique5,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER TYPE                ----- >>>'||p_tr_partner_type,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER ID                  ----- >>>'||p_tr_partner_id,1);
                 ecx_cln_debug_pub.Add('TRADING PARTNER SITE                ----- >>>'||p_tr_partner_site,1);
                 ecx_cln_debug_pub.Add('SENDER COMPONENT                    ----- >>>'||p_sender_component,1);
                 ecx_cln_debug_pub.Add('XMLG INTERNAL CONTROL NO            ----- >>>'||p_xmlg_internal_control_number,1);
                 ecx_cln_debug_pub.Add('PARTNER DOCUMENT NO                 ----- >>>'||p_partner_doc_no,1);
                 ecx_cln_debug_pub.Add('ORG ID                              ----- >>>'||p_org_id,1);
                 ecx_cln_debug_pub.Add('DOCUMENT CREATION DATE              ----- >>>'||p_doc_creation_date,1);
                 ecx_cln_debug_pub.Add('DOCUMENT REVISION DATE              ----- >>>'||p_doc_revision_date,1);
                 ecx_cln_debug_pub.Add('INIT DATE                           ----- >>>'||p_init_date,1);
                 ecx_cln_debug_pub.Add('DOCUMENT OWNER                      ----- >>>'||p_doc_owner,1);
                 ecx_cln_debug_pub.Add('OWNER ROLE                          ----- >>>'||p_owner_role,1);
                 ecx_cln_debug_pub.Add('XMLG EVENT KEY                      ----- >>>'||p_xml_event_key,1);
                 ecx_cln_debug_pub.Add('Collaboration Standard              ----- >>>'||p_collaboration_standard,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE1                          ----- >>>'||p_attribute1,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE2                          ----- >>>'||p_attribute2,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE3                          ----- >>>'||p_attribute3,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE4                          ----- >>>'||p_attribute4,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE5                          ----- >>>'||p_attribute5,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE6                          ----- >>>'||p_attribute6,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE7                          ----- >>>'||p_attribute7,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE8                          ----- >>>'||p_attribute8,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE9                          ----- >>>'||p_attribute9,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE10                         ----- >>>'||p_attribute10,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE11                         ----- >>>'||p_attribute11,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE12                         ----- >>>'||p_attribute12,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE13                         ----- >>>'||p_attribute13,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE14                         ----- >>>'||p_attribute14,1);
                 ecx_cln_debug_pub.Add('ATTRIBUTE15                         ----- >>>'||p_attribute15,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE1                         ----- >>>'||p_dattribute1,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE2                         ----- >>>'||p_dattribute2,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE3                         ----- >>>'||p_dattribute3,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE4                         ----- >>>'||p_dattribute4,1);
                 ecx_cln_debug_pub.Add('DATTRIBUTE5                         ----- >>>'||p_dattribute5,1);
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;



         -- assigning values to local variables for transaction tyoe/subtype
         l_coll_id                      :=      p_coll_id;
         l_xmlg_transaction_type        :=      p_xmlg_transaction_type;
         l_xmlg_transaction_subtype     :=      p_xmlg_transaction_subtype;
         l_xmlg_int_transaction_type    :=      p_xmlg_int_transaction_type;
         l_xmlg_int_transaction_subtype :=      p_xmlg_int_transaction_subtype;
         l_xmlg_internal_control_number :=      p_xmlg_internal_control_number;
         l_xmlg_msg_id                  :=      p_xmlg_msg_id;
         l_xmlg_document_id             :=      p_xmlg_document_id;
         l_tr_partner_type              :=      p_tr_partner_type;
         l_tr_partner_id                :=      p_tr_partner_id;
         l_tr_partner_site              :=      p_tr_partner_site;
         l_doc_dir                      :=      p_doc_dir;
         l_sender_component             :=      p_sender_component;
         l_xml_event_key                :=      p_xml_event_key;
         l_collaboration_standard       :=      p_collaboration_standard;

         -- call the API to get the trading partner set up details
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('==========Call to GET_TRADING_PARTNER_DETAILS API=============',1);
         END IF;


         GET_TRADING_PARTNER_DETAILS(
                        x_return_status                        => x_return_status,
                        x_msg_data                             => x_msg_data,
                        p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                        p_xmlg_msg_id                          => l_xmlg_msg_id,
                        p_xmlg_transaction_type                => l_xmlg_transaction_type,
                        p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                        p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                        p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                        p_xmlg_document_id                     => l_xmlg_document_id,
                        p_doc_dir                              => l_doc_dir,
                        p_tr_partner_type                      => l_tr_partner_type,
                        p_tr_partner_id                        => l_tr_partner_id,
                        p_tr_partner_site                      => l_tr_partner_site,
                        p_sender_component                     => l_sender_component,
                        p_xml_event_key                        => l_xml_event_key,
                        p_collaboration_standard               => l_collaboration_standard);

        IF ( x_return_status <> 'S') THEN
                l_msg_data  := 'Error in GET_TRADING_PARTNER_DETAILS ';
                -- x_msg_data is set to appropriate value by GET_TRADING_PARTNER_DETAILS
                RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 ecx_cln_debug_pub.Add('===========================================',1);
         END IF;

	 l_app_id := p_app_id;
	 l_coll_type := p_coll_type;
	 l_doc_type := p_doc_type;

         IF (l_app_id is null or l_coll_type is null and l_doc_type is null) THEN
            DEFAULT_XMLGTXN_MAPPING(
                x_return_status                => x_return_status,
                x_msg_data                     => x_msg_data,
                p_xmlg_transaction_type        => l_xmlg_transaction_type,
                p_xmlg_transaction_subtype     => l_xmlg_transaction_subtype,
                p_doc_dir                      => l_doc_dir,
                p_app_id                       => l_app_id,
                p_coll_type                    => l_coll_type,
                p_doc_type                     => l_doc_type );
         END IF;


         IF l_coll_id IS NULL THEN
             IF (l_Debug_Level <= 1) THEN
                     ecx_cln_debug_pub.Add('Collaboration ID passed as null',1);
                     ecx_cln_debug_pub.Add('==========Call to FIND_COLLABORATION_ID API=============',1);
             END IF;

             FIND_COLLABORATION_ID(
                    x_return_status                        => x_return_status,
                    x_msg_data                             => x_msg_data,
                    x_coll_id                              => l_coll_id,
                    p_app_id                               => l_app_id,
		    p_coll_type                            => l_coll_type,
                    p_ref_id                               => p_ref_id,
                    p_xmlg_transaction_type                => l_xmlg_transaction_type,
                    p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                    p_xmlg_document_id                     => l_xmlg_document_id,
                    p_tr_partner_type                      => l_tr_partner_type,
                    p_tr_partner_id                        => l_tr_partner_id,
                    p_tr_partner_site                      => l_tr_partner_site,
                    p_doc_dir                              => l_doc_dir,
                    p_xmlg_msg_id                          => l_xmlg_msg_id,
                    p_unique1                              => p_unique1,
                    p_unique2                              => p_unique2,
                    p_unique3                              => p_unique3,
                    p_unique4                              => p_unique4,
                    p_unique5                              => p_unique5,
                    p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                    p_xml_event_key                        => l_xml_event_key,
                    p_collaboration_standard               => l_collaboration_standard);

             IF ( x_return_status <> 'S') THEN
                    l_msg_data  := 'Error in FIND_COLLABORATION_ID';
                    -- x_msg_data is set to appropriate value by FIND_COLLABORATION_ID
                    RAISE FND_API.G_EXC_ERROR;
             END IF;
             IF (l_Debug_Level <= 1) THEN
                     ecx_cln_debug_pub.Add('Collaboration ID Found as '||l_coll_id,1);
             END IF;


        END IF;

        IF l_coll_id IS NULL THEN
             IF (l_Debug_Level <= 1) THEN
                     ecx_cln_debug_pub.Add('.....Collaboration Does Not Exist...............',1);
                     ecx_cln_debug_pub.Add('.....Call to Create Collaboration API...........',1);
             END IF;


             CREATE_COLLABORATION(
                       x_return_status                        => x_return_status,
                       x_msg_data                             => x_msg_data,
                       p_app_id                               => l_app_id,
                       p_ref_id                               => p_ref_id,
                       p_org_id                               => p_org_id,
                       p_rel_no                               => p_rel_no,
                       p_doc_no                               => p_doc_no,
                       p_doc_rev_no                           => p_doc_rev_no,
                       p_xmlg_transaction_type                => l_xmlg_transaction_type,
                       p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                       p_xmlg_document_id                     => l_xmlg_document_id,
                       p_partner_doc_no                       => p_partner_doc_no,
                       p_coll_type                            => l_coll_type,
                       p_tr_partner_type                      => l_tr_partner_type,
                       p_tr_partner_id                        => l_tr_partner_id,
                       p_tr_partner_site                      => l_tr_partner_site,
                       p_resend_flag                          => p_resend_flag,
                       p_resend_count                         => p_resend_count,
                       p_doc_owner                            => p_doc_owner,
                       p_init_date                            => p_init_date,
                       p_doc_creation_date                    => p_doc_creation_date,
                       p_doc_revision_date                    => p_doc_revision_date,
                       p_doc_type                             => l_doc_type,
                       p_doc_dir                              => l_doc_dir,
                       p_coll_pt                              => p_coll_pt,
                       p_xmlg_msg_id                          => l_xmlg_msg_id,
                       p_unique1                              => p_unique1,
                       p_unique2                              => p_unique2,
                       p_unique3                              => p_unique3,
                       p_unique4                              => p_unique4,
                       p_unique5                              => p_unique5,
                       p_sender_component                     => l_sender_component,
                       p_rosettanet_check_required            => p_rosettanet_check_required,
                       x_coll_id                              => l_coll_id,
                       p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                       p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                       p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                       p_msg_text                             => p_msg_text,
                       p_xml_event_key                        => l_xml_event_key,
                       p_collaboration_standard               => l_collaboration_standard,
                       p_attribute1                           => p_attribute1,
                       p_attribute2                           => p_attribute2,
                       p_attribute3                           => p_attribute3,
                       p_attribute4                           => p_attribute4,
                       p_attribute5                           => p_attribute5,
                       p_attribute6                           => p_attribute6,
                       p_attribute7                           => p_attribute7,
                       p_attribute8                           => p_attribute8,
                       p_attribute9                           => p_attribute9,
                       p_attribute10                          => p_attribute10,
                       p_attribute11                          => p_attribute11,
                       p_attribute12                          => p_attribute12,
                       p_attribute13                          => p_attribute13,
                       p_attribute14                          => p_attribute14,
                       p_attribute15                          => p_attribute15,
                       p_dattribute1                          => p_dattribute1,
                       p_dattribute2                          => p_dattribute2,
                       p_dattribute3                          => p_dattribute3,
                       p_dattribute4                          => p_dattribute4,
                       p_dattribute5                          => p_dattribute5,
                       p_owner_role                           => p_owner_role );

             IF ( x_return_status <> 'S') THEN
                    l_msg_data  := 'Error in CREATE_COLLABORATION';
                    -- x_msg_data is set to appropriate value by CREATE_COLLABORATION
                    RAISE FND_API.G_EXC_ERROR;
             END IF;
             l_coll_id  :=      null; -- so that update collaboration is not called immediately after create collaboration.
        END IF;


        IF l_coll_id IS NOT NULL THEN
                IF (l_Debug_Level <= 1) THEN
                        ecx_cln_debug_pub.Add('.....Collaboration Exists...........',1);
                        ecx_cln_debug_pub.Add('.....Call to Update Collaboration API...........',1);
                END IF;



                UPDATE_COLLABORATION(
                        x_return_status                        => x_return_status,
                        x_msg_data                             => x_msg_data,
                        p_coll_id                              => l_coll_id,
                        p_app_id                               => l_app_id,
                        p_ref_id                               => p_ref_id,
                        p_rel_no                               => p_rel_no,
                        p_doc_no                               => p_doc_no,
                        p_doc_rev_no                           => p_doc_rev_no,
                        p_xmlg_transaction_type                => l_xmlg_transaction_type,
                        p_xmlg_transaction_subtype             => l_xmlg_transaction_subtype,
                        p_xmlg_document_id                     => l_xmlg_document_id,
                        p_resend_flag                          => p_resend_flag,
                        p_resend_count                         => p_resend_count,
                        p_disposition                          => p_disposition,
                        p_coll_status                          => p_coll_status,
                        p_doc_type                             => l_doc_type,
                        p_doc_dir                              => l_doc_dir,
                        p_coll_pt                              => p_coll_pt,
                        p_org_ref                              => p_org_ref,
                        p_doc_status                           => p_doc_status,
                        p_notification_id                      => p_notification_id,
                        p_msg_text                             => p_msg_text,
                        p_attr1                                => p_attr1,
                        p_attr2                                => p_attr2,
                        p_attr3                                => p_attr3,
                        p_attr4                                => p_attr4,
                        p_attr5                                => p_attr5,
                        p_attr6                                => p_attr6,
                        p_attr7                                => p_attr7,
                        p_attr8                                => p_attr8,
                        p_attr9                                => p_attr9,
                        p_attr10                               => p_attr10,
                        p_attr11                               => p_attr11,
                        p_attr12                               => p_attr12,
                        p_attr13                               => p_attr13,
                        p_attr14                               => p_attr14,
                        p_attr15                               => p_attr15,
                        p_xmlg_msg_id                          => l_xmlg_msg_id,
                        p_unique1                              => p_unique1,
                        p_unique2                              => p_unique2,
                        p_unique3                              => p_unique3,
                        p_unique4                              => p_unique4,
                        p_unique5                              => p_unique5,
                        p_tr_partner_type                      => l_tr_partner_type,
                        p_tr_partner_id                        => l_tr_partner_id,
                        p_tr_partner_site                      => l_tr_partner_site,
                        p_sender_component                     => l_sender_component,
                        p_rosettanet_check_required            => p_rosettanet_check_required,
                        x_dtl_coll_id                          => l_dtl_coll_id,
                        p_xmlg_internal_control_number         => l_xmlg_internal_control_number,
                        p_partner_doc_no                       => p_partner_doc_no,
                        p_org_id                               => p_org_id,
                        p_doc_creation_date                    => p_doc_creation_date,
                        p_doc_revision_date                    => p_doc_revision_date,
                        p_doc_owner                            => p_doc_owner,
                        p_xmlg_int_transaction_type            => l_xmlg_int_transaction_type,
                        p_xmlg_int_transaction_subtype         => l_xmlg_int_transaction_subtype,
                        p_xml_event_key                        => l_xml_event_key,
                        p_collaboration_standard               => l_collaboration_standard,
                        p_attribute1                           => p_attribute1,
                        p_attribute2                           => p_attribute2,
                        p_attribute3                           => p_attribute3,
                        p_attribute4                           => p_attribute4,
                        p_attribute5                           => p_attribute5,
                        p_attribute6                           => p_attribute6,
                        p_attribute7                           => p_attribute7,
                        p_attribute8                           => p_attribute8,
                        p_attribute9                           => p_attribute9,
                        p_attribute10                          => p_attribute10,
                        p_attribute11                          => p_attribute11,
                        p_attribute12                          => p_attribute12,
                        p_attribute13                          => p_attribute13,
                        p_attribute14                          => p_attribute14,
                        p_attribute15                          => p_attribute15,
                        p_dattribute1                          => p_dattribute1,
                        p_dattribute2                          => p_dattribute2,
                        p_dattribute3                          => p_dattribute3,
                        p_dattribute4                          => p_dattribute4,
                        p_dattribute5                          => p_dattribute5,
                        p_owner_role                           => p_owner_role );


             IF ( x_return_status <> 'S') THEN
                    l_msg_data  := 'Error in UPDATE_COLLABORATION';
                    -- x_msg_data is set to appropriate value by UPDATE_COLLABORATION
                    RAISE FND_API.G_EXC_ERROR;
             END IF;

         END IF;


        IF (l_Debug_Level <= 1) THEN
                ecx_cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                ecx_cln_debug_pub.Add('------ Exiting ADD_COLLABORATION API ------- ',2);
        END IF;


    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
              --ROLLBACK TO UPDATE_COLLABORATION_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              IF (l_Debug_Level <= 4) THEN
                      ecx_cln_debug_pub.Add(l_msg_data,4);
                      ecx_cln_debug_pub.Add('------ Exiting ADD_COLLABORATION API ------- ',2);
              END IF;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             --ROLLBACK TO UPDATE_COLLABORATION_PUB;
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             x_msg_data :=FND_MESSAGE.GET;
             l_msg_data         :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     ecx_cln_debug_pub.Add(l_msg_data,6);
                     ecx_cln_debug_pub.Add('------ Exiting ADD_COLLABORATION API ------- ',2);
             END IF;



        WHEN OTHERS THEN
             --ROLLBACK TO UPDATE_COLLABORATION_PUB;
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             x_msg_data :=FND_MESSAGE.GET;
             l_msg_data         :='Unexpected Error -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 4) THEN
                     ecx_cln_debug_pub.Add(l_msg_data,4);
                     ecx_cln_debug_pub.Add('------ Exiting ADD_COLLABORATION API ------- ',2);
             END IF;


    END ADD_COLLABORATION;

END CLN_CH_COLLABORATION_PKG;

/
