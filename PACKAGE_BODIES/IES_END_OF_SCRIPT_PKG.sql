--------------------------------------------------------
--  DDL for Package Body IES_END_OF_SCRIPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_END_OF_SCRIPT_PKG" AS
  /* $Header: ieseosb.pls 115.3 2002/12/09 21:13:15 appldev noship $ */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ies_end_of_script_pkg';

   PROCEDURE getTemporaryCLOB (panelClob OUT NOCOPY CLOB, questionClob OUT NOCOPY CLOB) IS

    BEGIN
       DBMS_LOB.CreateTemporary(panelclob, TRUE, DBMS_LOB.CALL);
       DBMS_LOB.CreateTemporary(questionclob, TRUE, DBMS_LOB.CALL);
    END;

  FUNCTION getProperty(element IN xmldom.DOMElement, key IN VARCHAR2) return VARCHAR2 IS
     nl  xmldom.DOMNodeList;
     len number;
     n   xmldom.DOMNode;
     dummyElem xmldom.DOMElement;
     child xmldom.DOMNode;
     retValue  varchar2(2000);
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

  PROCEDURE saveQuestionData(element IN xmldom.DOMElement, intId IN NUMBER, agentId IN NUMBER)  IS
     question_id         NUMBER ;
     lookup_id           NUMBER ;
     answer_id           NUMBER ;
     string_val          VARCHAR2(512);
     display_val         VARCHAR2(512);

     TYPE   answerId IS REF CURSOR;
     obj    answerId;
  BEGIN

     question_id  := getProperty(element, 'QuestionId');
     lookup_id    := getProperty(element, 'LookupId');
     string_val   := getProperty(element, 'Value');
     display_val  := getProperty(element, 'DisplayValue');

     OPEN obj FOR
       'SELECT answer_id
          FROM ies_answers
         WHERE lookup_id = :lkp_id
           AND answer_value = :ans_val
           AND answer_display_value = :ans_disp_val' using lookup_id, string_val, display_val;

     FETCH obj INTO answer_id;
     CLOSE obj;

     INSERT INTO ies_question_data( question_data_id     ,
                                    created_by           ,
                                    creation_date        ,
                                    transaction_id       ,
                                    question_id          ,
                                    lookup_id            ,
                                    answer_id            ,
                                    freeform_string      )
                         VALUES    ( ies_question_data_s.nextval ,
                                     agentId            ,
                                     sysdate            ,
                                     intId              ,
                                     question_id        ,
                                     lookup_id          ,
                                     answer_id          ,
                                     string_val );
  END;

  PROCEDURE insertIESQuestionData
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
            saveQuestionData(dummyElem, interactionId, agentId);

        end loop;

    end if;
  end;

  PROCEDURE insertIESQuestionData (p_element IN CLOB ) IS
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
            saveQuestionData(dummyElem, interactionId, agentId);

        end loop;

    end if;

  END insertIESQuestionData;


  PROCEDURE savePanelData(element IN xmldom.DOMElement, intId IN NUMBER, agentId IN NUMBER)  IS
    panel_id           NUMBER;
    transaction_id     NUMBER;
    elapsed_time       NUMBER;
    sequence_num       NUMBER;
    deleted_status     NUMBER;
  BEGIN

     panel_id        := getProperty(element, 'PanelId');
     elapsed_time    := getProperty(element, 'ElapsedTime');
     sequence_num    := getProperty(element, 'SequenceNumber');
     deleted_Status  := getProperty(element, 'DeletedStatus');

     INSERT INTO ies_panel_data( panel_data_id        ,
                                 created_by           ,
                                 creation_date        ,
                                 panel_id             ,
                                 transaction_id       ,
                                 elapsed_time         ,
                                 sequence_number      ,
                                 deleted_status       )
                     VALUES    ( ies_panel_data_s.nextval ,
                                 agentId                  ,
                                 sysdate                  ,
                                 panel_id               ,
                                 intid                  ,
                                 elapsed_time           ,
                                 sequence_num           ,
                                 deleted_status         );
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

  PROCEDURE insertIESPanelData (p_element IN CLOB ) IS
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

  PROCEDURE updateIESTransactions(interactionId IN NUMBER) IS
  begin

    UPDATE ies_transactions SET end_time = sysdate WHERE transaction_id = interactionId;
  END;


END ies_end_of_script_pkg;

/
