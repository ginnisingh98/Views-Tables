--------------------------------------------------------
--  DDL for Package Body IES_NEW_END_OF_SCRIPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_NEW_END_OF_SCRIPT_PKG" AS
   /* $Header: iesneosb.pls 120.0 2005/06/03 07:32:22 appldev noship $ */
   G_PKG_NAME CONSTANT VARCHAR2(30) := 'ies_end_of_script_pkg';


   PROCEDURE getTemporaryCLOB (clob OUT NOCOPY CLOB) IS

    BEGIN
       DBMS_LOB.CreateTemporary(clob, TRUE, DBMS_LOB.CALL);
    END;

  FUNCTION getProperty(element IN xmldom.DOMElement, key IN VARCHAR2) return VARCHAR2 IS
     nl  xmldom.DOMNodeList;
     len number;
     n   xmldom.DOMNode;
     dummyElem xmldom.DOMElement;
     child xmldom.DOMNode;
     retValue  varchar2(4000);
  BEGIN
       nl  := xmldom.getChildNodes(xmldom.makeNode(element));
       len := xmldom.getLength(nl);

       if (xmldom.getTagName(element) = 'IESQuestionData' OR xmldom.getTagName(element) = 'IESPanelData') then
           if (key = 'InteractionId') then
               return xmldom.getAttribute(element,'InteractionId');
           end if;
           if (key = 'AgentId') then
               return xmldom.getAttribute(element,'AgentId');
           end if;
       end if;

       for i in 0..len-1 loop
           n := xmldom.item(nl, i);
           dummyElem := xmldom.makeElement(n);

           if (xmldom.getAttribute(dummyElem,'NAME') = key) then
               child := xmldom.getFirstChild(n);
               if NOT (xmldom.isNull(child)) then
        	  retValue := xmldom.getNodeValue(child);
        	  return retValue;
               else
                  return NULL;
               end if;
	   end if;
       end loop;
       return NULL;
  END;

  FUNCTION getDummyFootprintDataTag return xmldom.DOMElement IS
    parser  xmlparser.parser;
    doc     xmldom.DOMDocument;
    element xmlDom.DOMElement;
    p_element      VARCHAR2(256) := '<IESFootprintData></IESFootprintData>';
  BEGIN
    -- API body
    parser := xmlparser.newParser;

    xmlparser.setValidationMode(parser, FALSE);
    xmlparser.showWarnings(parser, TRUE);
    xmlparser.parseBuffer(parser, p_element);

    doc := xmlparser.getDocument(parser);
    element := xmldom.getDocumentElement(doc);

    return element;
  end;

  FUNCTION getDummyQuestionDataTag return xmldom.DOMElement IS
    parser  xmlparser.parser;
    doc     xmldom.DOMDocument;
    element xmlDom.DOMElement;
    p_element      VARCHAR2(256) := '<IESQuestionData></IESQuestionData>';
  BEGIN
    -- API body
    parser := xmlparser.newParser;

    xmlparser.setValidationMode(parser, FALSE);
    xmlparser.showWarnings(parser, TRUE);
    xmlparser.parseBuffer(parser, p_element);

    doc := xmlparser.getDocument(parser);
    element := xmldom.getDocumentElement(doc);

    return element;
  end;


  FUNCTION getFootprintDataElement(element IN xmldom.DOMElement) return xmldom.DOMELement IS
     nl  xmldom.DOMNodeList;
     len number;
     n   xmldom.DOMNode;
     dummyElem xmldom.DOMElement;
  BEGIN
       nl  := xmldom.getChildNodes(xmldom.makeNode(element));
       len := xmldom.getLength(nl);


       for i in 0..len-1 loop
           n := xmldom.item(nl, i);
           dummyElem := xmldom.makeElement(n);

           if (xmldom.getTagName(dummyElem) = 'IESFootprintData') then
               return dummyElem;
           end if;
       end loop;

       return getDummyFootprintDataTag; -- need this because null returned is not recognized when xmldom.isNull check is done
  END;

  FUNCTION getQuestionDataElement(element IN xmldom.DOMElement) return xmldom.DOMELement IS
     nl  xmldom.DOMNodeList;
     len number;
     n   xmldom.DOMNode;
     dummyElem xmldom.DOMElement;
  BEGIN
       nl  := xmldom.getChildNodes(xmldom.makeNode(element));
       len := xmldom.getLength(nl);


       for i in 0..len-1 loop
           n := xmldom.item(nl, i);
           dummyElem := xmldom.makeElement(n);

           if (xmldom.getTagName(dummyElem) = 'IESQuestionData') then
               return dummyElem;
           end if;
       end loop;

       return getDummyQuestionDataTag; -- need this because null returned is not recognized when xmldom.isNull check is done
  END;

  PROCEDURE saveFootprintData(element IN xmldom.DOMElement, panelDataId IN NUMBER, intId IN NUMBER, agentId IN NUMBER, seq IN NUMBER)  IS
     elapsedtime         NUMBER ;

     TYPE   answerId IS REF CURSOR;
     obj    answerId;
     insertStmt varchar2(4000);
     seqval number;
  BEGIN

     elapsedtime  := getProperty(element, 'ElapsedTime');

     EXECUTE IMMEDIATE 'SELECT IES_FOOTPRINTING_DATA_S.nextval  FROM dual' INTO seqval;

     insertStmt := 'INSERT INTO IES_FOOTPRINTING_DATA( FOOTPRINTING_DATA_ID   ,
                                    created_by           ,
                                    creation_date        ,
                                    elapsed_time         ,
                                    sequence_number      ,
                                    panel_data_id)
                         VALUES    ( :seq,
                                     :1,
                                     :2,
                                     :3,
                                     :4,
                                     :5)';
         EXECUTE immediate insertStmt using  seqval, agentId, sysdate,
                                             elapsedTime, seq+1, panelDataId;
  END;

  PROCEDURE insertFootprintData
  (
     p_element                        IN     xmldom.DOMElement,
     panel_data_id                    IN     number,
     interactionId                    IN     number,
     agentId                          IN     number
  ) IS

    --element xmlDom.DOMElement;
    dummyelem xmlDom.DOMElement;
    nl      xmlDom.DOMNodeList;
    n       xmldom.DOMNode;
    len           NUMBER;
  BEGIN

    -- API body
    --element := p_element;

    if NOT (xmldom.isnull(p_element)) then
        nl  := xmldom.getChildNodes(xmldom.makeNode(p_element));
        len := xmldom.getLength(nl);

        for i in 0..len-1 loop
            n := xmldom.item(nl, i);

            dummyElem := xmldom.makeElement(n);
            saveFootprintData(dummyElem, panel_data_id, interactionId, agentId, i);

        end loop;

    end if;
  END;



  PROCEDURE saveQuestionData(element IN xmldom.DOMElement, panelDataId IN NUMBER, intId IN NUMBER, agentId IN NUMBER)  IS
     question_id         NUMBER ;
     lookup_id           NUMBER ;
     answer_id           NUMBER ;
     string_val          VARCHAR2(4000);

     insertStmt varchar2(4000);
     seqval  number;
  BEGIN

     question_id  := getProperty(element, 'QuestionId');
	lookup_id    := getProperty(element, 'LookupId');
	string_val   := getProperty(element, 'Value');
	answer_id    := getProperty(element, 'AnswerId');


     EXECUTE IMMEDIATE 'SELECT ies_question_data_s.nextval  FROM dual' INTO seqval;

     insertStmt := 'INSERT INTO ies_question_data( question_data_id     ,
                                    created_by           ,
                                    creation_date        ,
                                    transaction_id       ,
                                    question_id          ,
                                    lookup_id            ,
                                    answer_id            ,
                                    freeform_string      ,
                                    panel_data_id)
                         VALUES    ( :seq ,
                                     :1,
                                     :2,
                                     :3,
                                     :4,
                                     :5,
                                     :6,
                                     :7,
                                     :8)';
     EXECUTE immediate insertStmt using  seqval  ,
                              agentId            ,
                              sysdate            ,
                              intId              ,
                              question_id        ,
                              lookup_id          ,
                              answer_id          ,
                              string_val,
                              panelDataId;
  END;

  PROCEDURE insertIESQuestionData
  (
     p_element                        IN     xmldom.DOMElement,
     panel_data_id                    IN     number,
     interactionId                    IN     number,
     agentId                          IN     number
  ) IS

    --element xmlDom.DOMElement;
    dummyelem xmlDom.DOMElement;
    nl      xmlDom.DOMNodeList;
    n       xmldom.DOMNode;
    len           NUMBER;
  BEGIN

    -- API body
    --element := p_element;

    if NOT (xmldom.isnull(p_element)) then
        nl  := xmldom.getChildNodes(xmldom.makeNode(p_element));
        len := xmldom.getLength(nl);

        for i in 0..len-1 loop
            n := xmldom.item(nl, i);

            dummyElem := xmldom.makeElement(n);
            saveQuestionData(dummyElem, panel_data_id, interactionId, agentId);

        end loop;

    end if;
  END;




  PROCEDURE savePanelData(element IN xmldom.DOMElement, intId IN NUMBER, agentId IN NUMBER)  IS
    panel_id           NUMBER;
    id                 NUMBER;
    transaction_id     NUMBER;
    elapsed_time       NUMBER;
    sequence_num       NUMBER;
    deleted_status     NUMBER;
    qd_element         XMLDOM.DOMElement;
    fp_element         XMLDOM.DOMElement;

    insertStmt varchar2(4000);
    seqval  number;
    nullval number;
  BEGIN

     panel_id        := getProperty(element, 'PanelId');
     sequence_num    := getProperty(element, 'SequenceNumber');
     deleted_Status  := getProperty(element, 'DeletedStatus');

    EXECUTE IMMEDIATE 'SELECT ies_panel_data_s.nextval  FROM dual' INTO seqval;

    insertStmt := 'INSERT INTO ies_panel_data( panel_data_id        ,
                                 created_by           ,
                                 creation_date        ,
                                 panel_id             ,
                                 transaction_id       ,
                                 elapsed_time         ,
                                 sequence_number      ,
                                 deleted_status       )
                     VALUES    ( :seq ,
                                 :1,
                                 :2,
                                 :3,
                                 :4,
                                 :5,
                                 :6,
                                 :7) returning panel_data_id INTO :8';
     execute immediate insertStmt using seqval,
                                 agentId,
                                 sysdate,
                                 panel_id,
                                 intid,
                                 nullval,
                                 sequence_num,
                                 deleted_status returning INTO id;

     fp_element := getFootprintDataElement(element);
     if NOT (xmldom.isNULL(fp_element))  then
         insertFootprintData(fp_element, id, intId, agentId);
     end if;


     qd_element := getQuestionDataElement(element);

     if NOT (xmldom.isNULL(qd_element))  then
         insertIESQuestionData(qd_element, id, intId, agentId);
     end if;

  END;



  PROCEDURE insertIESPanelData
  (
     p_element                        IN     varchar2
  ) IS

    parser  xmlparser.parser;
    doc     xmldom.DOMDocument;
    element xmlDom.DOMElement;
    dummyelem xmlDom.DOMElement;
    nl      xmlDom.DOMNodeList;
    n       xmldom.DOMNode;
    len           NUMBER;
    interactionId NUMBER;
    agentId       NUMBER;
  BEGIN

    -- API body
    parser := xmlparser.newParser;

    xmlparser.setValidationMode(parser, FALSE);
    xmlparser.showWarnings(parser, TRUE);
    xmlparser.parseBuffer(parser, p_element);

    doc := xmlparser.getDocument(parser);
    element := xmldom.getDocumentElement(doc);

    if NOT (xmldom.isnull(element)) then
        interactionId := to_number(getProperty(element, 'InteractionId'));
        agentId       := to_number(getProperty(element, 'AgentId'));
        nl  := xmldom.getChildNodes(xmldom.makeNode(element));
        len := xmldom.getLength(nl);

        for i in 0..len-1 loop
            n := xmldom.item(nl, i);

            dummyElem := xmldom.makeElement(n);
            savePanelData(dummyElem, interactionId, agentId);

        end loop;

    end if;
  end;

  PROCEDURE saveEndOfScriptData (p_element IN CLOB ) IS
    parser  xmlparser.parser;
    doc     xmldom.DOMDocument;
    element xmlDom.DOMElement;
    dummyelem xmlDom.DOMElement;
    nl      xmlDom.DOMNodeList;
    n       xmldom.DOMNode;
    len           NUMBER;
    interactionId NUMBER;
    agentId       NUMBER;
  BEGIN
    -- Standard Start of API savepoint
    -- API body
    parser := xmlparser.newParser;

    xmlparser.setValidationMode(parser, FALSE);
    xmlparser.showWarnings(parser, TRUE);
    xmlparser.parseClob(parser, p_element);

    doc := xmlparser.getDocument(parser);
    element := xmldom.getDocumentElement(doc);

    if NOT (xmldom.isnull(element)) then
        interactionId := to_number(getProperty(element, 'InteractionId'));
        agentId       := to_number(getProperty(element, 'AgentId'));
        nl  := xmldom.getChildNodes(xmldom.makeNode(element));
        len := xmldom.getLength(nl);

        for i in 0..len-1 loop
            n := xmldom.item(nl, i);

            dummyElem := xmldom.makeElement(n);
            savePanelData(dummyElem, interactionId, agentId);

        end loop;

    end if;
  END;

END ies_new_end_of_script_pkg;

/
