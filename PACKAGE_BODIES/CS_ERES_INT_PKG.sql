--------------------------------------------------------
--  DDL for Package Body CS_ERES_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_ERES_INT_PKG" AS
/* $Header: cserespb.pls 120.30.12010000.2 2010/01/06 09:55:43 vpremach ship $ */

G_PKG_NAME VARCHAR2(30) := 'CS_ERES_INT_PKG' ;
dbg_msg    VARCHAR2(4000) ;

PROCEDURE Start_Approval_Process
 ( P_Incident_id              IN        NUMBER,
   P_Incident_type_id         IN        NUMBER,
   P_Incident_Status_Id       IN        NUMBER,
   P_QA_Collection_Id         IN        NUMBER,
   X_Approval_status         OUT NOCOPY VARCHAR2,
   X_Return_status           OUT NOCOPY VARCHAR2,
   X_Msg_count               OUT NOCOPY NUMBER,
   X_Msg_data                OUT NOCOPY VARCHAR2 ) IS

 -- Cursors
    CURSOR get_det_erec_flag IS
           SELECT NVL(detailed_erecord_req_flag ,'N')
             FROM cs_incident_types_b
            WHERE incident_type_id = p_incident_type_id ;

 -- Local variables
    l_det_erec_req     VARCHAR2(3);
    l_xml_doc          CLOB;
    l_return_status    VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_child_erecords   EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE;
    l_event            EDR_ERES_EVENT_PUB.ERES_EVENT_REC_TYPE;
    l_qa_erecord_tbl   QA_RESULT_GRP.QA_ERECORD_TBL_TYPE;
    l_send_ackn        BOOLEAN := FALSE;
    l_txn_status       VARCHAR2(30);
    l_str              VARCHAR2(240);
    l_api_name         VARCHAR2(40) := 'Start_Approval_Process';
 -- Exceptions

BEGIN
    -- Log the input parameters

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN

          dbg_msg := ('In CS_ERES_INT_PKG.START_APPROVAL_PROCESS Procedure');
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
          END IF;

          dbg_msg := ('P_Incident_id :'||P_Incident_id);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
          END IF;

          dbg_msg := ('P_Incident_type_id :'||P_Incident_type_id);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
          END IF;

          dbg_msg := ('P_Incident_status_id :'||P_Incident_status_id);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
          END IF;

          dbg_msg := ('P_QA_collection_id :'||P_QA_collection_id);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
          END IF;
        END IF;
      END IF;

    -- Populate the fixed event parameters required by the ERES event.

       l_event.EVENT_NAME     := 'oracle.apps.cs.sr.ServiceRequestApproval';
       l_event.EVENT_KEY      := p_incident_id;
       l_event.ERECORD_ID     := null;
       l_event.EVENT_STATUS   := null;
       l_event.PARAM_NAME_1   := 'DEFERRED';
       l_event.PARAM_VALUE_1  := 'Y';
       l_event.PARAM_NAME_2   := 'POST_OPERATION_API';
       l_event.PARAM_VALUE_2  := 'CS_ERES_INT_PKG.Post_Approval_Process('||
                                 'p_incident_id =>'||p_incident_id||
                                 ',P_Intermediate_Status_Id =>'||p_incident_status_id||')';
       l_event.PARAM_NAME_3   := 'PSIG_USER_KEY_LABEL';
       l_event.PARAM_VALUE_3  := 'CSERES';
       l_event.PARAM_NAME_4   := 'PSIG_USER_KEY_VALUE';
       l_event.PARAM_VALUE_4  := 'CS_ERES';
       l_event.PARAM_NAME_5   := 'PSIG_TRANSACTION_AUDIT_ID';
       l_event.PARAM_VALUE_5  := -1;
       l_event.PARAM_NAME_6   := '#WF_SOURCE_APPLICATION_TYPE';
       l_event.PARAM_VALUE_6  := 'DB';
       l_event.PARAM_NAME_7   := '#WF_SIGN_REQUESTER';
       l_event.PARAM_VALUE_7  := fnd_global.user_name;
       l_event.PARAM_NAME_8   := 'TRANSFORM_XML';
       l_event.PARAM_VALUE_8  := 'N';

    -- Construct a call to the function that returns an XML document. This call will be executed by the ERES API
    -- if approval rules are found.

       -- Check what type of XML document is to be generated (Details or Light)

          OPEN get_det_erec_flag;
         FETCH get_det_erec_flag INTO l_det_erec_req;
         CLOSE get_det_erec_flag;

         IF NVL(l_det_erec_req,'N') = 'N' THEN
            l_event.PARAM_NAME_9 := 'XML_GENERATION_API';
            l_str := 'CS_ERES_INT_PKG.Generate_XML_Document('||p_incident_id||',''N'')';
            l_event.PARAM_VALUE_9  := l_str;
         ELSE
            l_event.PARAM_NAME_9 := 'XML_GENERATION_API';
            l_str := 'CS_ERES_INT_PKG.Generate_XML_Document('||p_incident_id||',''Y'')';
            l_event.PARAM_VALUE_9  := l_str;
         END IF ;

    -- Construct a string to pass the FND attachment details
       l_event.PARAM_NAME_10  := 'EDR_PSIG_ATTACHMENT';
       l_event.PARAM_VALUE_10 := 'CS:entity=CS_INCIDENTS&'||'pk1name=INCIDENT_ID&'||'pk1value='||p_incident_id;

    -- Call the QA API to get eRecord for the QA records.

       IF p_qa_collection_id IS NOT NULL THEN

          l_return_status := FND_API.G_RET_STS_SUCCESS;

          QA_RESULT_GRP.Get_QA_Results_Erecords
               ( p_api_version          => 1.0,
                 p_init_msg_list        => fnd_api.g_false,
                 p_commit               => fnd_api.g_false,
                 p_Validation_Level	=> fnd_api.g_valid_level_full,
                 p_Collection_Id	=> p_qa_collection_id,
                 X_qa_erecord_tbl	=> l_qa_erecord_tbl,
                 x_return_status        => l_return_status,
                 x_msg_count            => x_msg_count,
                 x_msg_data             => x_msg_data );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSE
              IF l_qa_erecord_tbl.COUNT > 0 THEN
                 FOR i IN 1..l_qa_erecord_tbl.COUNT
                    LOOP
                       l_child_erecords(i) := l_qa_erecord_tbl(i).erec_id;
                    END LOOP;
              END IF;
           END IF;
        END IF;

       -- Log the parameter being passed to the ERES API.

          dbg_msg := ('P_Incident_id :'||P_Incident_id);

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
              dbg_msg := ('Calling EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT API ');
              IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
              END IF;
            END IF;
          END IF;

       -- Call the ERES API to raise ERES event.

       l_return_status := FND_API.G_RET_STS_SUCCESS;

       --dbms_output.put_line('Start Approval Process - Calling EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT');

       EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT
         ( p_api_version                 => 1.0 ,
           p_init_msg_list               => fnd_api.g_false,
           p_validation_level            => fnd_api.g_valid_level_full,
           x_return_status               => l_return_status,
           x_msg_count                   => x_msg_count ,
           x_msg_data                    => x_msg_data ,
           p_child_erecords              => l_child_erecords ,
           x_event                       => l_event );

          --dbms_output.put_line('ERES API Return Status : '||l_return_status);
          --dbms_output.put_line('ERecord ID : '||l_event.ERECORD_ID);
          --dbms_output.put_line('Event Status : '||l_event.event_status);

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
              dbg_msg := ('After Calling EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT API ');
              IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
              END IF;

              dbg_msg := ('EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT API Return Status : '||l_return_status);
              IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
              END IF;

              dbg_msg := ('EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT API Event Status : '||l_event.event_status);
              IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
              END IF;

              dbg_msg := ('EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT API ERecord ID : '||l_event.ERECORD_ID);
              IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
              END IF;
            END IF;
          END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

           -- send an acknowledge to ERES about the business transaction being completed successfully
           -- This acknowledgement will not be sent from this API if the ERES API response is 'PENDING'.

           IF (l_event.event_status = 'PENDING') THEN
               l_send_ackn       := FALSE;
               l_txn_status      := 'SUCCESS';
               x_return_status   := FND_API.G_RET_STS_SUCCESS;
               x_approval_status := 'PENDING';
           ELSIF (l_event.event_status ='ERROR') AND (l_event.ERECORD_ID IS NOT NULL) THEN
               l_send_ackn       := TRUE;
               l_txn_status      := 'ERROR';
               x_return_status   := FND_API.G_RET_STS_ERROR;
               x_approval_status := 'ERROR';
           ELSIF (l_event.event_status = 'NOACTION') THEN

               IF l_event.ERECORD_ID IS NOT NULL THEN
                  l_send_ackn       := TRUE;
                  l_txn_status      := 'SUCCESS';
               END IF ;

               x_return_status   := FND_API.G_RET_STS_SUCCESS;
               x_approval_status := 'NO_ACTION';
           END IF ;

           IF l_send_ackn = TRUE THEN

              -- Log that EDR_TRANS_ACKN_PUB.SEND_ACKN is being called.

              IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
                  dbg_msg := ('Calling EDR_TRANS_ACKN_PUB.SEND_ACKN API ');
                  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
                  END IF;
                END IF;
              END IF;

              l_return_status := FND_API.G_RET_STS_SUCCESS;

              EDR_TRANS_ACKN_PUB.SEND_ACKN
                 ( p_api_version          => 1.0,
                   p_init_msg_list        => FND_API.G_TRUE   ,
                   x_return_status        => l_return_status,
                   x_msg_count            => x_msg_count,
                   x_msg_data             => x_msg_data,
                   p_event_name           => l_event.event_name,
                   p_event_key            => l_event.event_key,
                   p_ERECord_id           => l_event.ERECORD_ID,
                   p_trans_status         => l_txn_status,
                   p_ackn_by              => 'Service Request Approval Process',
                   p_ackn_note            => 'Service Request Approval Initiation process completed',
                   p_autonomous_commit    => FND_API.G_FALSE   );

               -- Log output of EDR_TRANS_ACKN_PUB.SEND_ACKN call

                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                   IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
                     dbg_msg := ('After Calling EDR_TRANS_ACKN_PUB.SEND_ACKN API ');
                     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
                     END IF;

                     dbg_msg := ('EDR_TRANS_ACKN_PUB.SEND_ACKN API Return Status : '||l_return_status);
                     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
                     END IF;
                   END IF;
                 END IF;

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF ;
           END IF ; -- l_send_ackn

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
END Start_Approval_Process ;

--------------------------------------------------------------------------------
-- Function  Name : make_node
-- Parameters     :
-- IN             :
-- RETURN VALUE   :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 10/25/05 grwang   Created
-- 10/31/05 smisra   added log messages
--------------------------------------------------------------------------------
FUNCTION make_node
( p_doc          IN dbms_xmldom.domdocument
, p_element_name IN VARCHAR2
, p_value        IN VARCHAR2) RETURN dbms_xmldom.DOMNode AS

  elem        dbms_xmldom.DOMElement;
  nelem       dbms_xmldom.DOMNode;
  agnode      dbms_xmldom.DOMNode;
  text        dbms_xmldom.DOMText;
  tempnode    dbms_xmldom.DOMNode :=  NULL;
BEGIN

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    IF FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS') THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', 'Inside function make_node');
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', 'P_element_name :' || p_element_name);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', 'P_value :' || p_value);
    END IF;
  END IF;
  --
  elem := dbms_xmldom.createelement(p_doc, p_element_name);
  agnode := dbms_xmldom.makenode(elem);

  -- create a text node
  text := dbms_xmldom.createtextnode(p_doc, p_value);
  -- make node
  nelem := dbms_xmldom.makeNode(text);

  tempnode := dbms_xmldom.appendchild(agnode,nelem);

  IF((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
      dbg_msg := 'Returning Successfully from make_Node function';
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
    END IF;
  END IF;
  RETURN agnode;
EXCEPTION
     WHEN OTHERS THEN
       IF((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
           dbg_msg := 'Exception raised in make_Node function';
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
         END IF;
       END IF;
    RETURN tempnode;
END make_node;

--------------------------------------------------------------------------------
-- Function  Name : Append_ea_data
-- Parameters     :
-- IN             :
-- RETURN VALUE   :
--
-- Description    :
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 10/25/05 grwang   Created
-- 10/31/05 smisra   added log messages
-- 11/07/05 smisra   If get_sr_ext_attr returns an error then this function
--                   returns NULL
--------------------------------------------------------------------------------
FUNCTION append_ea_data
( P_Incident_Id	IN NUMBER
, p_xml_doc     IN CLOB) RETURN CLOB AS

xmldoc CLOB := p_xml_doc;

indomdoc   dbms_xmldom.domdocument;
innode     dbms_xmldom.domnode;
childnode  dbms_xmldom.DOMNode;
srnode     dbms_xmldom.DOMNode;
myParser   dbms_xmlparser.Parser;

elem       dbms_xmldom.DOMElement;
attrm      dbms_xmldom.DOMElement;
topm       dbms_xmldom.DOMElement;
topattrm   dbms_xmldom.DOMElement;
topn       dbms_xmldom.DOMNode;
topattrn   dbms_xmldom.DOMNode;
nelem      dbms_xmldom.DOMNode;
attrelem   dbms_xmldom.DOMNode;
agnode     dbms_xmldom.DOMNode;
attrnode   dbms_xmldom.DOMNode;

attr_disp_value_node_ele   dbms_xmldom.DOMElement;
attr_disp_value_node       dbms_xmldom.DOMNode;

attr_disp_value_text_ele   dbms_xmldom.DOMText;
attr_disp_value_text_node  dbms_xmldom.DOMNode;


text        dbms_xmldom.DOMText;
attrtext    dbms_xmldom.DOMText;
tempnode    dbms_xmldom.DOMNode;
sreanode    dbms_xmldom.DOMNode;

l_extensibility_table    CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE;
l_ext_attr_table         CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE;

l_failed_row_id_list     VARCHAR2(4000);
l_return_status          VARCHAR2(1);
l_errorcode              NUMBER;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(4000);

l_errm                   VARCHAR2(100);
l_msg                    VARCHAR2(250);

l_server_timezone_id     VARCHAR2(15) := fnd_profile.value('SERVER_TIMEZONE_ID');
l_client_timezone_id     VARCHAR2(15) := fnd_profile.value('CLIENT_TIMEZONE_ID');
l_timezone_enabled       VARCHAR2(2) := fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS');
l_date_format            VARCHAR2(240) := fnd_profile.value('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS';



BEGIN
  IF((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
      dbg_msg := 'Inside function append_ea_data';
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
    END IF;
  END IF;
  --
  -- get sr ea data
  --dbms_output.put_line('Going to call get sr ext data<br>');

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  CS_SR_EXTATTRIBUTES_PVT.Get_SR_Ext_Attrs
  ( p_api_version      => 1.0
  , p_init_msg_list    => FND_API.G_FALSE
  , p_commit           => FND_API.G_FALSE
  , p_incident_id      => p_incident_id
  , p_object_name      => 'CS_SERVICE_REQUEST'
  , x_ext_attr_grp_tbl => l_extensibility_table
  , x_ext_attr_tbl     => l_ext_attr_table
  , x_return_status    => l_return_status
  , x_msg_count        => l_msg_count
  , x_msg_data         => l_msg_data
  );
  IF((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
      dbg_msg := 'Status returned by Get_SR_Ext_Attr:' || l_return_status;
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
    END IF;
  END IF;
  --dbms_output.put_line('after call get sr ext data:' || l_return_status || '<br>');
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN NULL;
  END IF;

  --dbms_output.put_line('return status is '||l_return_status);
  --dbms_output.put_line('number of attr grp '||l_extensibility_table.count);
  IF l_extensibility_table IS NOT NULL AND
     l_extensibility_table.count > 0
  THEN
    myParser := dbms_xmlparser.newParser;
    dbms_xmlparser.parseBuffer(myParser, xmldoc);
    indomdoc   := dbms_xmlparser.getDocument(myParser);
    innode     := dbms_xmldom.makeNode(indomdoc);

    childnode := dbms_xmldom.getfirstchild(innode);
    srnode := dbms_xmldom.getfirstchild(childnode);

    -- make sr ea node
    elem := dbms_xmldom.createelement(indomdoc, 'EXTATTR');
    sreanode := dbms_xmldom.makenode(elem);


    FOR i IN l_extensibility_table.First..l_extensibility_table.LAST
    LOOP

      topm := dbms_xmldom.createelement(indomdoc, 'ATTR_GROUP');
      topn := dbms_xmldom.makenode(topm);

      -- add attribute group display name
      tempnode := dbms_xmldom.appendchild
                  ( topn
                  , Make_Node
                    ( indomdoc
                    , 'ATTR_GROUP_DISP_NAME'
                    , l_extensibility_table(i).ATTR_GROUP_DISP_NAME
                    )
                  );
      -- end attribute group display name


      -- add_context
      tempnode := dbms_xmldom.appendchild
                  ( topn
                  , Make_Node
                    ( indomdoc
                    , 'CONTEXT'
                    , l_extensibility_table(i).CONTEXT
                    )
                  );
      -- end add_context

      FOR j IN  l_ext_attr_table.FIRST..l_ext_attr_table.LAST
      LOOP

        IF l_extensibility_table(i).ROW_IDENTIFIER = l_ext_attr_table(j).ROW_IDENTIFIER
        THEN
           -- add attributes
          topattrm := dbms_xmldom.createelement(indomdoc, 'ATTRS');
          topattrn := dbms_xmldom.makenode(topattrm);

          -- add attr_name
          tempnode := dbms_xmldom.appendchild
                      ( topattrn
                      , Make_Node
                        ( indomdoc
                        , 'ATTR_DISP_NAME'
                        , l_ext_attr_table(j).ATTR_DISP_NAME
                        )
                      );
          -- attr_name eof

          -- attr_value_display
           IF l_ext_attr_table(j).ATTR_VALUE_DATE IS NOT NULL THEN
              IF l_timezone_enabled = 'Y' THEN

                 tempnode := dbms_xmldom.appendchild
                      ( topattrn
                      , Make_Node
                        ( indomdoc
                        , 'ATTR_VALUE_DISPLAY'
                        , to_char(hz_timezone_pub.convert_datetime(l_server_timezone_id,l_client_timezone_id,l_ext_attr_table(j).ATTR_VALUE_DATE),l_date_format)
                        )
                      );
              ELSE
                 tempnode := dbms_xmldom.appendchild
                      ( topattrn
                      , Make_Node
                        ( indomdoc
                        , 'ATTR_VALUE_DISPLAY'
                        , to_char(l_ext_attr_table(j).ATTR_VALUE_DATE,l_date_format)
                        )
                      );
              END IF;
           ELSE
              tempnode := dbms_xmldom.appendchild
                      ( topattrn
                      , Make_Node
                        ( indomdoc
                        , 'ATTR_VALUE_DISPLAY'
                        , l_ext_attr_table(j).ATTR_VALUE_DISPLAY
                        )
                      );
           END IF ;
          -- attr_value_display_eof

          tempnode := dbms_xmldom.appendchild
                      ( topattrn
                      , Make_Node
                        ( indomdoc
                        , 'ATTR_UNIT_OF_MEASURE'
                        , l_ext_attr_table(j).ATTR_UNIT_OF_MEASURE
                        )
                      );
          tempnode := dbms_xmldom.appendchild(topn, topattrn);

        END IF;

      END LOOP;

      tempnode := dbms_xmldom.appendchild(sreanode, topn);

    END LOOP; -- l_extensibility_table_end_loop

  tempnode := dbms_xmldom.appendchild(srnode,sreanode);
  dbms_xmldom.writetoclob(innode, xmldoc);

  END IF; --if_l_extensibility_table_null_eof
  --
  IF((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS')) THEN
      dbg_msg := 'Returning Successfully from function append_ea_data';
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.START_APPROVAL_PROCESS', dbg_msg);
    END IF;
  END IF;
  --
  RETURN xmldoc;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME  ('CS'     , 'CS_ERES_XML_GEN_FAILED');
    FND_MESSAGE.SET_TOKEN ('SQLCODE', SQLCODE);
    FND_MESSAGE.SET_TOKEN ('SQLERRM', SQLERRM);
    FND_MSG_PUB.ADD;
    RETURN NULL;
END Append_EA_Data ;

-- Following functions are internally used by the Generate_XML_Document while generating the
-- XML Document.
---------------------------------------------------------------------------------------------

FUNCTION Get_Related_Objs (x_incident_id number) return cs_sr_related_OBJ_list_t  as

  CURSOR Get_Rel_Obj IS
  SELECT CAST(MULTISET
    (SELECT obj.name RelatedOB_name
          , SrLnkEO.object_number RelatedOB_Number
          , csz_servicerequest_util_pvt.get_rel_obj_details(SrLnkEO.object_type,
                                                          SrLnkEO.object_id) RelatedOB_Description
     FROM cs_incident_links SrLnkEO
        , jtf_objects_tl obj
     WHERE SrLnkEO.subject_id = x_incident_id
     AND SrLnkEO.subject_type = 'SR'
     AND SrLnkEO.object_type <> 'SR'
     AND obj.object_code (+) = SrLnkEO.object_type
     AND obj.language (+) = userenv('LANG')
     AND sysdate between nvl(SrLnkEO.start_date_active,sysdate)
     AND nvl(SrLnkEO.end_date_active,sysdate) ) AS cs_sr_related_OBJ_list_t) RELATED_OB_LIST
  FROM DUAL;

l_rel_onj_list cs_sr_related_OBJ_list_t;

BEGIN
   OPEN  Get_Rel_Obj;
  FETCH Get_Rel_Obj INTO l_rel_onj_list;
  CLOSE Get_Rel_Obj;

  return l_rel_onj_list;
END;

FUNCTION Get_Related_SRs (x_incident_id number) return cs_sr_related_SR_list_t  as

CURSOR Get_Rel_Sr IS
 SELECT CAST(MULTISET
  (SELECT ltype.name RelatedSR_Name
        , status.name RelatedSR_Status
        , fnd1.user_name RelatedSR_Created_By
        , tlSR.summary RelatedSR_Summary
        , SrLnkEO.object_number RelatedSR_Number
        , severity.name RelatedSR_Severity
        , (SELECT rs.resource_name
           FROM jtf_rs_resource_extns_tl rs
           WHERE rs.resource_id = relSR.incident_owner_id
           AND rs.language = userenv('LANG')) RelatedSR_Owner
   FROM cs_incident_links SrLnkEO
      , cs_sr_link_types_tl ltype
      , fnd_user fnd1
      , cs_incidents_all_b relSR
      , cs_incidents_all_tl tlSR
      , cs_incident_statuses_tl status
      , cs_incident_severities_tl severity
  WHERE SrLnkEO.subject_id = x_incident_id
    AND SrLnkEO.subject_type = 'SR'
    AND SrLnkEO.object_type = 'SR'
    AND SrLnkEO.link_type_id = ltype.link_type_id
    AND ltype.LANGUAGE = userenv('LANG')
    AND SrLnkEO.created_by = fnd1.user_id
    AND SrLnkEO.object_number = relSR.incident_number
    AND relSR.incident_status_id = status.incident_status_id
    AND status.LANGUAGE = userenv('LANG')
    AND relSR.incident_severity_id = severity.incident_severity_id
    AND severity.LANGUAGE = userenv('LANG')
    AND tlSR.incident_id = relSR.incident_id
    AND tlSR.language = userenv('lang')
    AND sysdate between nvl(SrLnkEO.start_date_active,sysdate)
                   AND nvl(SrLnkEO.end_date_active,sysdate) ) AS cs_sr_related_SR_list_t) RELATED_SR_LIST
 FROM DUAL;

   l_rel_sr_list cs_sr_related_SR_list_t;

BEGIN
    OPEN  Get_Rel_Sr;
   FETCH Get_Rel_Sr INTO l_rel_sr_list;
   CLOSE Get_Rel_Sr;

  return l_rel_sr_list;
END;

FUNCTION Get_SR_Notes (x_incident_id number,
                                         l_source_timezone_id number,
                                         l_desc_timezone_id number,
                                         l_date_format varchar2) return cs_sr_note_list_t  as

CURSOR Get_Notes IS
 SELECT CAST(MULTISET
   (SELECT nvl2(ext_usert.resource_name, ext_usert.resource_name, fnd1.user_name) as Note_Created_By
         , DECODE(JNB.entered_date,'','',to_char(hz_timezone_pub.convert_datetime(l_source_timezone_id,l_desc_timezone_id,JNB.ENTERED_DATE),l_date_format)) Note_Creation_Date
         , FLS.MEANING Note_Type
         , FLP.MEANING Note_Visibility
         , JNT.NOTES Note_Description
         , JNT.NOTES_DETAIL Note_Detail
    FROM JTF_NOTES_B JNB ,
         JTF_NOTES_TL JNT ,
         FND_LOOKUPS FLS ,
         FND_LOOKUPS FLP,
         jtf_rs_resource_extns ext_userb,
         jtf_rs_resource_extns_tl ext_usert,
         FND_USER fnd1
   WHERE JNB.JTF_NOTE_ID = JNT.JTF_NOTE_ID
     AND JNT.LANGUAGE = USERENV('LANG')
     AND FLS.LOOKUP_TYPE(+) = 'JTF_NOTE_TYPE'
     AND FLS.LOOKUP_CODE(+) = JNB.NOTE_TYPE
     AND FLP.lookup_type = 'JTF_NOTE_STATUS'
     AND FLP.lookup_code = JNB.note_status
     AND JNB.source_object_code = 'SR'
     AND JNB.source_object_id = x_incident_id
     AND ((JNB.note_status <> 'P') OR
         (JNB.note_status = 'P' and JNB.created_by = fnd_profile.value_wnps('USER_ID') ))
     AND JNB.created_by = fnd1.user_id
     AND ext_userb.user_id (+) = fnd1.user_id
     AND ext_usert.language (+)= userenv('LANG')
     AND ext_userb.resource_id = ext_usert.resource_id (+)
     AND ext_userb.category = ext_usert.category (+)
     order by JNB.entered_date ) AS cs_sr_note_list_t) NOTE_LIST
 FROM DUAL;

 l_note_list cs_sr_note_list_t;

BEGIN
   OPEN  Get_Notes;
  FETCH Get_Notes INTO l_note_list;
  CLOSE Get_Notes;

  return l_note_list;
END;


FUNCTION Get_SR_Tasks (x_incident_id number,
                                         l_source_timezone_id number,
                                         l_desc_timezone_id number,
                                         l_date_format varchar2) return cs_sr_task_list_t  as

CURSOR Get_Tasks IS
 SELECT CAST(MULTISET
  (SELECT
      DECODE(jtf1B.creation_date,'','',to_char(hz_timezone_pub.convert_datetime(l_source_timezone_id,l_desc_timezone_id,jtf1B.creation_date),l_date_format))  Task_Creation_Date
    , jtf1B.task_number Task_Number
    , type.name Task_Type
    , jtf1T.TASK_NAME  Task_Name
    , jtf1T.DESCRIPTION  Task_Description
    , priority.name Task_Priority
    , statusT.name Task_Status
    , jtf_task_utl.get_owner(jtf1B.owner_type_code, jtf1B.owner_id) Task_Owner
    , obj_vl.name Task_ownertype
    , jtf2.task_number Task_parenttasknumber
    , jtf1B.planned_effort task_planned_effort
    , (SELECT unit_of_measure
         FROM mtl_units_of_measure_vl um
        WHERE um.uom_code = jtf1B.planned_effort_uom) as task_planned_effort_uom
    , jtf1B.actual_effort task_actual_effort
    , (SELECT unit_of_measure
         FROM mtl_units_of_measure_tl um
        WHERE um.uom_code = jtf1B.actual_effort_uom
          AND  um.LANGUAGE = USERENV('LANG') ) as task_actual_effort_uom
    , jtf1B.duration task_duration
    , (SELECT unit_of_measure
         FROM mtl_units_of_measure_tl um
        WHERE  um.uom_code = jtf1B.duration_uom
          AND  um.LANGUAGE = USERENV('LANG') ) AS task_duration_uom
    , DECODE(jtf1B.planned_start_date,'','',to_char(hz_timezone_pub.convert_datetime(l_source_timezone_id,l_desc_timezone_id,jtf1B.planned_start_date),l_date_format))  task_planned_start_date
    , DECODE(jtf1B.planned_end_date,'','',to_char(hz_timezone_pub.convert_datetime(l_source_timezone_id,l_desc_timezone_id,jtf1B.planned_end_date),l_date_format)) task_planned_end_date
    , DECODE(jtf1B.scheduled_start_date,'','',to_char(hz_timezone_pub.convert_datetime(l_source_timezone_id,l_desc_timezone_id,jtf1B.scheduled_start_date),l_date_format)) task_scheduled_start_date
    , DECODE(jtf1B.scheduled_end_date,'','',to_char(hz_timezone_pub.convert_datetime(l_source_timezone_id,l_desc_timezone_id,jtf1B.scheduled_end_date),l_date_format))  task_scheduled_end_date
    , DECODE(jtf1B.actual_start_date,'','',to_char(hz_timezone_pub.convert_datetime(l_source_timezone_id,l_desc_timezone_id,jtf1B.ACTUAL_START_DATE),l_date_format))  task_actual_start_date
    , DECODE(jtf1B.actual_end_date,'','',to_char(hz_timezone_pub.convert_datetime(l_source_timezone_id,l_desc_timezone_id,jtf1B.ACTUAL_END_DATE),l_date_format))  task_actual_end_date
   FROM JTF_TASKS_TL jtf1T, JTF_TASKS_B jtf1B
      , jtf_tasks_b jtf2
      , jtf_task_types_tl type
      , jtf_task_priorities_tl priority
      , JTF_TASK_STATUSES_TL statusT, JTF_TASK_STATUSES_B statusB
      , jtf_objects_tl obj_vl
   WHERE jtf1B.source_object_type_code='SR'
     AND jtf1B.source_object_id    = x_incident_id
     AND jtf1B.TASK_ID = jtf1T.TASK_ID
     AND jtf1T.LANGUAGE = userenv('LANG')
     AND type.task_type_id = jtf1B.task_type_id
     AND type.LANGUAGE = userenv('LANG')
     AND priority.task_priority_id = jtf1B.task_priority_id
     AND priority.LANGUAGE = userenv('LANG')
     AND statusB.TASK_STATUS_ID = statusT.TASK_STATUS_ID
     AND statusT.LANGUAGE = userenv('LANG')
     AND statusb.usage = 'TASK'
     AND statusB.task_status_id = jtf1B.task_status_id
     AND obj_vl.object_code = jtf1B.owner_type_code
     AND obj_vl.LANGUAGE = userenv('LANG')
     AND jtf1B.parent_task_id = jtf2.task_id (+)
     ORDER BY jtf1B.creation_date) AS cs_sr_task_list_t) TASK_LIST
 FROM DUAL;

 l_task_list cs_sr_task_list_t;

BEGIN
   OPEN  Get_Tasks;
  FETCH Get_Tasks INTO l_task_list;
  CLOSE Get_Tasks;

  return l_task_list;
END;

--------------------------------------------------------------------------------
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 11/07/05 smisra   In case of exception, this function returns NULL
-- 11/07/05 smisra   Called append_ea_data only if SR has some ext records
--------------------------------------------------------------------------------

FUNCTION Generate_XML_Document
 ( P_Incident_Id	  IN	NUMBER,
   P_Detailed_xml_reqd	  IN	VARCHAR2 ) RETURN CLOB AS

  -- Local Variables

     Ctx1         DBMS_XMLGEN.ctxHandle;
     Ctx2         DBMS_XMLGEN.ctxHandle;
     xmldoc       CLOB;
     pass         BOOLEAN;
     l_query      VARCHAR2(32000) := null;
     l_api_name   VARCHAR2(40) := 'Generate_XML_Document';
     l_server_timezone_id VARCHAR2(15) := fnd_profile.value('SERVER_TIMEZONE_ID');
     l_client_timezone_id VARCHAR2(15) := fnd_profile.value('CLIENT_TIMEZONE_ID');
     l_timezone_enabled VARCHAR2(2) := fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS');
     --l_display_timezone_id VARCHAR2(15);
     l_date_format            VARCHAR2(240) := fnd_profile.value('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS';
     l_ext_rec_count          NUMBER;

  --New Cursors and Vars

     l_display_timezone_id NUMBER;
     l_source_timezone_id NUMBER;
     l_desc_timezone_id NUMBER;

      CURSOR GET_SR (v_display_timezone_id NUMBER,
                v_source_timezone_id NUMBER,
                v_desc_timezone_id NUMBER,
                v_date_format VARCHAR2) IS
           SELECT sr.incident_id Incident_Id
                 ,sr.incident_number Incident_Number
                 ,sr.incident_type_id
                 ,sr.incident_status_id  Incident_Status_Id
                 ,sr.incident_severity_id Incident_Severity_Id
                 ,sr.incident_urgency_id Incident_Urgency_Id
                 ,sr.owner_group_id Sr_Group_Id
                 ,sr.incident_owner_id Sr_Owner_Id
                 ,sr.problem_code Problem_code_id
                 ,sr.resolution_code Resolution_code_id
                 ,tl.summary
                 ,tl.resolution_summary
                 ,sr.publish_flag Publish_Flag
                 ,tl.summary Problem_Summary
                 ,sr.time_zone_id TimeZone_Id
                 ,sr.customer_id Customer_Id
                 ,sr.account_id Account_Id
                 ,sr.inventory_item_id Inventory_Item_Id
                 ,nvl2(sr.incident_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id, sr.incident_date),v_date_format),null) reported_date
                 ,nvl2(sr.incident_last_modified_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id,sr.incident_last_modified_date),v_date_format),null)Last_Update_Date
                 ,nvl2(sr.incident_occurred_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id,sr.incident_occurred_date),v_date_format),null) Incident_Date
                 ,nvl2(sr.close_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id,sr.close_date),v_date_format),null) Close_Date
                 ,nvl2(sr.incident_resolved_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id,sr.incident_resolved_date),v_date_format),null) incident_resolved_date
                 ,nvl2(sr.obligation_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id,sr.obligation_date),v_date_format),null) respond_by_date
                 ,nvl2(sr.expected_resolution_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id,sr.expected_resolution_date),v_date_format),null) resolve_by_date
                 ,nvl2(sr.inc_responded_by_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id,sr.inc_responded_by_date),v_date_format),null) inc_responded_by_date
                 ,nvl2(sr.actual_resolution_date,TO_CHAR(hz_timezone_pub.convert_datetime(v_source_timezone_id,v_desc_timezone_id,sr.actual_resolution_date),v_date_format),null) Actual_Resolution_Date
                 ,sr.status_flag Status_Flag_Code
                 ,sr.created_by Created_By_Id
                 ,sr.customer_product_id Customer_Product_Id
                 ,sr.org_id Organization_Id
                 ,sr.inv_organization_id Inventory_Org_Id
                 ,instance.instance_number  Instance_Number
                 ,nvl(instance.serial_number,sr.current_serial_number) Serial_Number
                 ,nvl(instance.external_reference,sr.external_reference) Tag_Number
                 , nvl2(sr.customer_product_id, instance.inventory_revision, sr.inv_item_revision) Item_Revision
                 , nvl2(sr.customer_product_id, (select instance.inventory_revision
                                                 from mtl_system_items_b_kfv product_a,
                                                      csi_item_instances  instance
                                                 where product_a.inventory_item_id = instance.inventory_item_id
                                                 and product_a.organization_id = sr.inv_organization_id
                                                 and sr.cp_component_id=instance.instance_id), sr.inv_component_version) Component_Revision
                 , nvl2(sr.customer_product_id, (select instance.inventory_revision
                                                 from mtl_system_items_b_kfv product_b,
                                                      csi_item_instances  instance
                                                 where product_b.inventory_item_id = instance.inventory_item_id
                                                 and product_b.organization_id = sr.inv_organization_id
                                                 and sr.cp_subcomponent_id = instance.instance_id ), sr.inv_subcomponent_version) Sub_Component_Revision
                 ,sr.incident_attribute_1 Attribute1
                 ,sr.incident_attribute_2 Attribute2
                 ,sr.incident_attribute_3 Attribute3
                 ,sr.incident_attribute_4 Attribute4
                 ,sr.incident_attribute_5 Attribute5
                 ,sr.incident_attribute_6 Attribute6
                 ,sr.incident_attribute_7 Attribute7
                 ,sr.incident_attribute_8 Attribute8
                 ,sr.incident_attribute_9 Attribute9
                 ,sr.incident_attribute_10 Attribute10
                 ,sr.incident_attribute_11 Attribute11
                 ,sr.incident_attribute_12 Attribute12
                 ,sr.incident_attribute_13 Attribute13
                 ,sr.incident_attribute_14 Attribute14
                 ,sr.incident_attribute_15 Attribute15
                 ,sr.incident_context Incident_Context
                 ,sr.external_attribute_1 Ext_Attribute1
                 ,sr.external_attribute_2 Ext_Attribute2
                 ,sr.external_attribute_3 Ext_Attribute3
                 ,sr.external_attribute_4 Ext_Attribute4
                 ,sr.external_attribute_5 Ext_Attribute5
                 ,sr.external_attribute_6 Ext_Attribute6
                 ,sr.external_attribute_7 Ext_Attribute7
                 ,sr.external_attribute_8 Ext_Attribute8
                 ,sr.external_attribute_9 Ext_Attribute9
                 ,sr.external_attribute_10 Ext_Attribute10
                 ,sr.external_attribute_11 Ext_Attribute11
                 ,sr.external_attribute_12 Ext_Attribute12
                 ,sr.external_attribute_13 Ext_Attribute13
                 ,sr.external_attribute_14 Ext_Attribute14
                 ,sr.external_attribute_15 Ext_Attribute15
                 ,sr.external_context Ext_Context
                 ,sr.sr_creation_channel
                 ,sr.contract_service_id
                 ,sr.category_id
                 ,sr.system_id
                 ,sr.inv_component_id
                 ,sr.cp_subcomponent_id
                 ,sr.resource_type
                 ,sr.incident_LOCATION_ID
                 ,sr.incident_address
                 ,nvl2(sr.incident_city, ','||sr.incident_city, NULL)
                 ,nvl2(sr.incident_state, ', ' ||sr.incident_state, NULL)
                 ,nvl2(sr.incident_province, ', '||sr.incident_province, NULL)
                 ,nvl2(sr.incident_postal_code, ' '||sr.incident_postal_code, NULL)
                 ,nvl2(sr.incident_country, ' ' ||sr.incident_country, NULL)
                 ,instance.inventory_item_id
                 ,instance.instance_id
                 ,sr.cp_component_id
                 ,sr.inv_subcomponent_id
                 ,sr.incident_location_type
            FROM cs_incidents_b_sec sr
                ,cs_incidents_all_tl tl
                ,csi_item_instances instance
           WHERE sr.incident_id = tl.incident_id
             AND tl.language = userenv('lang')
             AND sr.incident_id = P_Incident_Id
             AND sr.inventory_item_id = instance.inventory_item_id (+)
             AND sr.customer_product_id = instance.instance_id (+);

      l_Incident_Id                  NUMBER;
      l_Incident_Number              VARCHAR2(64);
      l_incident_type_id             NUMBER;
      l_Incident_Status_Id           NUMBER;
      l_Incident_Severity_Id         NUMBER;
      l_Incident_Urgency_Id          NUMBER;
      l_Sr_Group_Id                  NUMBER;
      l_Sr_Owner_Id                  NUMBER;
      l_Problem_code_id              VARCHAR2(30);
      l_Resolution_code_id           VARCHAR2(30);
      l_summary                      VARCHAR2(240);
      l_resolution_summary           VARCHAR2(250);
      l_Publish_Flag                 VARCHAR2(1);
      l_Problem_Summary              VARCHAR2(240);
      l_TimeZone_Id                  NUMBER;
      l_Customer_Id                  NUMBER;
      l_Account_Id                   NUMBER;
      l_Inventory_Item_Id            NUMBER;
      l_reported_date                VARCHAR2(30);
      l_Last_Update_Date             VARCHAR2(30);
      l_Incident_Date                VARCHAR2(30);
      l_Close_Date                   VARCHAR2(30);
      l_incident_resolved_date       VARCHAR2(30);
      l_respond_by_date              VARCHAR2(30);
      l_resolve_by_date              VARCHAR2(30);
      l_inc_responded_by_date        VARCHAR2(30);
      l_Actual_Resolution_Date       VARCHAR2(30);
      l_Status_Flag_Code             VARCHAR2(3);
      l_Created_By_Id                NUMBER;
      l_Customer_Product_Id          NUMBER;
      l_Organization_Id              NUMBER;
      l_Inventory_Org_Id             NUMBER;
      l_Instance_Number              VARCHAR2(30);
      l_Serial_Number                VARCHAR2(30);
      l_Tag_Number                   VARCHAR2(30);
      l_Item_Revision                VARCHAR2(240);
      l_Component_Revision           VARCHAR2(90);
      l_Sub_Component_Revision       VARCHAR2(90);
      l_Attribute1                   VARCHAR2(150);
      l_Attribute2                   VARCHAR2(150);
      l_Attribute3                   VARCHAR2(150);
      l_Attribute4                   VARCHAR2(150);
      l_Attribute5                   VARCHAR2(150);
      l_Attribute6                   VARCHAR2(150);
      l_Attribute7                   VARCHAR2(150);
      l_Attribute8                   VARCHAR2(150);
      l_Attribute9                   VARCHAR2(150);
      l_Attribute10                  VARCHAR2(150);
      l_Attribute11                  VARCHAR2(150);
      l_Attribute12                  VARCHAR2(150);
      l_Attribute13                  VARCHAR2(150);
      l_Attribute14                  VARCHAR2(150);
      l_Attribute15                  VARCHAR2(150);
      l_Incident_Context             VARCHAR2(30);
      l_Ext_Attribute1               VARCHAR2(150);
      l_Ext_Attribute2               VARCHAR2(150);
      l_Ext_Attribute3               VARCHAR2(150);
      l_Ext_Attribute4               VARCHAR2(150);
      l_Ext_Attribute5               VARCHAR2(150);
      l_Ext_Attribute6               VARCHAR2(150);
      l_Ext_Attribute7               VARCHAR2(150);
      l_Ext_Attribute8               VARCHAR2(150);
      l_Ext_Attribute9               VARCHAR2(150);
      l_Ext_Attribute10              VARCHAR2(150);
      l_Ext_Attribute11              VARCHAR2(150);
      l_Ext_Attribute12              VARCHAR2(150);
      l_Ext_Attribute13              VARCHAR2(150);
      l_Ext_Attribute14              VARCHAR2(150);
      l_Ext_Attribute15              VARCHAR2(150);
      l_Ext_Context                  VARCHAR2(30);
      l_sr_creation_channel          VARCHAR2(50);
      l_contract_service_id          NUMBER;
      l_category_id                  NUMBER;
      l_system_id                    NUMBER;
      l_inv_component_id             NUMBER;
      l_cp_subcomponent_id           NUMBER;
      l_resource_type_code           VARCHAR2(30);
      l_incident_LOCATION_ID         NUMBER;
      l_incident_addr                VARCHAR2(960);
      l_incident_city                VARCHAR2(60);
      l_incident_state               VARCHAR2(60);
      l_incident_province            VARCHAR2(60);
      l_incident_postal_code         VARCHAR2(60);
      l_incident_country             VARCHAR2(60);
      l_instance_inventory_item_id   NUMBER;
      l_instance_id                  NUMBER;
      l_cp_component_id              NUMBER;
      l_inv_subcomponent_id          NUMBER;
      l_incident_location_type       VARCHAR2(30);

--:Incident_Type
--:Detailed_Erecord

 CURSOR Incident_Type (v_incident_type_id NUMBER) IS
   SELECT typest.name, nvl(typesb.detailed_erecord_req_flag,'N') Detailed_Erecord
     FROM cs_incident_types_tl typest,
          cs_incident_types_b typesb
    WHERE typesb.incident_type_id = v_incident_type_id
      AND typesb.incident_type_id = typest.incident_type_id
      AND typest.language = userenv('LANG');

     l_Incident_Type    VARCHAR2(90); -- Bug 8365703 ,changed length from 30 to 90, vpremach
     l_Detailed_Erecord VARCHAR2(1);

--:Incident_Status
--:status_sort_order
 CURSOR Get_Inc_Status ( v_incident_status_id NUMBER) IS
  SELECT status.name ,status_b.sort_order
    FROM cs_incident_statuses_tl status, cs_incident_statuses_b status_b
   WHERE status.incident_status_id = v_incident_status_id
     AND status.incident_status_id = status_b.incident_status_id
     AND status.language = userenv('LANG');

    l_Incident_Status       VARCHAR2(30);
    l_status_sort_order     NUMBER;

--:Incident_Severity
--:Sev_Importance_Level
 CURSOR Get_Inc_Severity (v_incident_severity_id NUMBER) IS
  SELECT sevt.name, sevb.importance_level
  FROM cs_incident_severities_tl sevt, cs_incident_severities_b sevb
  WHERE sevb.incident_severity_id = v_incident_severity_id
  AND sevt.incident_severity_id = sevb.incident_severity_id
  AND sevt.language = userenv('LANG');

 l_Incident_Severity VARCHAR2(80);
 l_Sev_Importance_Level NUMBER;

--:Incident_Urgency
 CURSOR Get_Inc_Urg (v_incident_urgency_id NUMBER) IS
  SELECT urgency.name
  FROM cs_incident_urgencies_tl urgency
  WHERE urgency.incident_urgency_id = v_incident_urgency_id
  AND urgency.language = userenv('LANG');

 l_Incident_Urgency VARCHAR2(30);

-- :Sr_Group
 CURSOR Get_Group (v_owner_group_id NUMBER) IS
  SELECT gr.group_name
  FROM jtf_rs_groups_tl gr
  WHERE gr.group_id =v_owner_group_id
  AND gr.LANGUAGE = userenv('LANG');

 l_Sr_Group VARCHAR2(60);

-- :Sr_Owner
 CURSOR Get_Resource (v_incident_owner_id NUMBER) IS
  SELECT rs.resource_name
  FROM  jtf_rs_resource_extns_tl rs
  WHERE  rs.resource_id = v_incident_owner_id
  AND language = userenv('LANG');

 l_Sr_Owner VARCHAR2(360);
--

-- :Problem_code
-- :Resolution_code
-- :Sr_Creation_Channel
-- :Customer_Type
 CURSOR Get_Cs_Lookup (v_lookup_code VARCHAR2, v_lookup_type VARCHAR2) IS
  SELECT meaning
  FROM   FND_LOOKUP_VALUES
  WHERE  lookup_code = v_lookup_code
  AND lookup_type = v_lookup_type
  AND LANGUAGE = userenv('LANG')
  AND View_APPLICATION_ID = 170
  AND SECURITY_GROUP_ID = fnd_global.lookup_security_group(LOOKUP_TYPE,
                                                           VIEW_APPLICATION_ID);

l_Problem_code VARCHAR2(80);
l_Resolution_code VARCHAR2(80);
l_Sr_Creation_Channel_Name VARCHAR2(80);
l_Customer_Type VARCHAR2(80);

--:Created_By
 CURSOR Get_Fnd_User (v_user_id NUMBER) IS
  SELECT usr.user_name
  FROM fnd_user usr
  WHERE  usr.user_id  = v_user_id;

 l_Created_By VARCHAR2(100);

-- :Contact_Type
 CURSOR Get_Contact_Type (v_incident_id NUMBER) IS
  SELECT cont_type_lkup.meaning
  FROM  FND_LOOKUP_VALUES cont_type_lkup
       ,cs_hz_sr_contact_points sr_cont
  WHERE sr_cont.contact_type=cont_type_lkup.lookup_code
  AND cont_type_lkup.lookup_type='CS_SR_CONTACT_TYPE'
  AND sr_cont.incident_id = v_incident_id
  ANd sr_cont.primary_flag = 'Y'
  AND cont_type_lkup.LANGUAGE = userenv('LANG')
  AND cont_type_lkup.View_APPLICATION_ID = 170
  AND cont_type_lkup.SECURITY_GROUP_ID = fnd_global.lookup_security_group(cont_type_lkup.LOOKUP_TYPE,
                                                                          cont_type_lkup.VIEW_APPLICATION_ID);
 l_Contact_Type VARCHAR2(80);


-- :Contact_Name
 CURSOR Get_Contact_Name (v_incident_id NUMBER, v_customer_id NUMBER) IS
  SELECT  CSZ_SERVICEREQUEST_UTIL_PVT.get_contact_name(sr_cont.contact_type,
                                                       sr_cont.party_id,
                                                       v_customer_id)
  FROM  cs_hz_sr_contact_points sr_cont
  WHERE sr_cont.incident_id = v_incident_id
  AND sr_cont.primary_flag = 'Y';

 l_Contact_Name VARCHAR2(360);

--:TimeZone_Name
--:display_timezone
 CURSOR Get_Timezone (v_time_zone_id NUMBER) IS
  SELECT tz_tl.name
  FROM fnd_timezones_b tz, fnd_timezones_tl tz_tl
  WHERE tz.upgrade_tz_id = v_time_zone_id
  AND tz.TIMEZONE_CODE = tz_tl.TIMEZONE_CODE
  AND tz_tl.language = USERENV('LANG');

 l_TimeZone_Name VARCHAR2(80);
 l_display_timezone VARCHAR2(80);

-- :account_number
 CURSOR Get_Account (v_account_id NUMBER) IS
  SELECT account.account_number
  FROM hz_cust_accounts account
  WHERE account.cust_account_id = v_account_id;

 l_account_number VARCHAR2(30);

-- :Product
-- :Product_Description
 CURSOR Get_Product (v_inventory_item_id NUMBER, v_inv_organization_id NUMBER) IS
  SELECT concatenated_segments, description
  FROM MTL_SYSTEM_ITEMS_VL
  WHERE inventory_item_id = v_inventory_item_id
  AND   organization_id = v_inv_organization_id;

 l_Product VARCHAR2(40);
 l_Product_Description VARCHAR2(240);

-- :Contract_Number
-- :Contract_Service
-- :Contract_Coverage
 CURSOR Get_Contract (v_contract_service_id NUMBER) IS
  SELECT contract_number, service_description, coverage_description
  FROM oks_ent_line_details_v
  WHERE service_line_id = v_contract_service_id;

 l_Contract_Number VARCHAR2(120);
 l_Contract_Service VARCHAR2(240);
 l_Contract_Coverage VARCHAR2(1995);

--:Customer_Number
--:Customer_Name
--:customer_phone
--:Customer_Email
--:party_type
CURSOR Get_Party (v_customer_id NUMBER) IS
 SELECT party.party_number,
        party.party_name,
        nvl2(party.primary_phone_country_code, party.primary_phone_country_code||'-',null)||
        nvl2(party.primary_phone_area_code, party.primary_phone_area_code||'-',null)||
        party.primary_phone_number customer_phone,
        party.email_address,
        party.party_type
FROM hz_parties party
WHERE party.party_id = v_customer_id;

l_Customer_Number VARCHAR2(30);
l_Customer_Name  VARCHAR2(360);
l_customer_phone VARCHAR2(70);
l_Customer_Email VARCHAR2(2000);
l_party_type VARCHAR2(30);

---------------------------------

--:Contact_Phone_Number
-- :Contact_Telephone_Type
 CURSOR Get_Contact_Phone (v_incident_id NUMBER) IS
  SELECT  ar.meaning PHONE_TYPE,
          nvl2(party_cont.phone_country_code, party_cont.phone_country_code || '-',null ) ||
          nvl2(party_cont.phone_area_code, party_cont.phone_area_code || '-', null) ||
          party_cont.phone_number PHONE_NUMBER
   FROM hz_contact_points party_cont,
        cs_hz_sr_contact_points sr_cont,
        FND_LOOKUP_VALUES ar
   WHERE sr_cont.incident_id            = v_incident_id
   AND   sr_cont.contact_point_id       = party_cont.contact_point_id
   AND   sr_cont.contact_type  <> 'EMPLOYEE'
   AND   party_cont.contact_point_type = 'PHONE'
   AND   party_cont.phone_line_type     = ar.lookup_code
   AND   ar.lookup_type             = 'PHONE_LINE_TYPE'
   AND   ar.LANGUAGE = userenv('LANG')
   AND   ar.VIEW_APPLICATION_ID = 222
   AND   ar.SECURITY_GROUP_ID = 0
   AND   sr_cont.primary_flag='Y'
   UNION
   SELECT  hrl.meaning PHONE_TYPE,
           pp.phone_number PHONE_NUMBER
   FROM  cs_hz_sr_contact_points sr_cont,
         per_phones pp,
         hr_lookups hrl
   WHERE sr_cont.incident_id  = v_incident_id
   AND   sr_cont.contact_type = 'EMPLOYEE'
   AND   pp.phone_id       = sr_cont.contact_point_id
   AND   pp.parent_table   = 'PER_ALL_PEOPLE_F'
   AND   pp.phone_type        = hrl.lookup_code
   AND   hrl.lookup_type   = 'PHONE_TYPE'
   AND sr_cont.contact_point_type = 'PHONE'
   AND sr_cont.primary_flag='Y';

 l_Contact_Phone_Number  VARCHAR2(70);
 l_Contact_Telephone_Type VARCHAR2(80);

--:Contact_Email
 CURSOR Get_Contact_Email (v_incident_id NUMBER) IS
  SELECT  party_cont.email_address EMAIL
  FROM  hz_contact_points party_cont,
        cs_hz_sr_contact_points sr_cont
  WHERE sr_cont.incident_id     = v_incident_id
  AND   sr_cont.contact_point_id      = party_cont.contact_point_id
  AND   sr_cont.contact_type          <> 'EMPLOYEE'
  AND   party_cont.contact_point_type = 'EMAIL'
  AND sr_cont.primary_flag = 'Y'
  AND party_cont.email_address is not null
  UNION
  SELECT pap.email_address EMAIL
  FROM  cs_hz_sr_contact_points sr_cont,
        per_all_people_f pap
  WHERE sr_cont.incident_id  = v_incident_id
  AND   sr_cont.contact_type = 'EMPLOYEE'
  AND   pap.person_id        = sr_cont.party_id
  AND   sr_cont.primary_flag = 'Y'
  AND   pap.email_address is not null
  AND   sr_cont.contact_point_type = 'EMAIL';

 l_Contact_Email VARCHAR2(2000);

--:Item_Category
 CURSOR Get_Item_Category (v_category_id NUMBER) IS
  SELECT cat.concatenated_segments
  FROM mtl_categories_b_kfv cat
  WHERE cat.category_id = v_category_id;

 l_Item_Category VARCHAR2(40);

-- :System_Number
 CURSOR Get_System_Number (v_system_id NUMBER) IS
  SELECT sys.name
  FROM CSI_SYSTEMS_TL sys
  WHERE sys.system_id = v_system_id
  AND sys.LANGUAGE = USERENV('LANG');
 l_System_Number VARCHAR2(50);


--:Component
--:Sub_Component
 CURSOR Get_Component_Instance (v_cp_component_id NUMBER, v_inv_organization_id NUMBER) IS
  SELECT product_b.concatenated_segments
  FROM mtl_system_items_b_kfv product_b,
       csi_item_instances  instance
  WHERE product_b.inventory_item_id = instance.inventory_item_id
  AND product_b.organization_id = v_inv_organization_id
  AND instance.instance_id = v_cp_component_id;


 CURSOR Get_Component (v_inv_component_id NUMBER, v_inv_organization_id NUMBER) IS
  SELECT product_b.concatenated_segments
  FROM mtl_system_items_b_kfv product_b
  WHERE product_b.inventory_item_id = v_inv_component_id
  AND product_b.organization_id = v_inv_organization_id;

l_Component VARCHAR2(40);
l_Sub_Component VARCHAR2(40);

-- :Resource_Type
 CURSOR Get_Res_Type (v_resource_type VARCHAR2) IS
  SELECT name
  FROM jtf_objects_tl o,
       jtf_object_usages ou
  WHERE o.object_code = ou.object_code
  AND ou.object_user_code = 'RESOURCES'
  AND o.object_code = v_resource_type
  AND o.LANGUAGE = userenv ( 'LANG' );
 l_Resource_Type VARCHAR2(30);



--:Incident_Address
 CURSOR Get_SR_Location (v_incident_location_id NUMBER) IS
  SELECT loc.address1 || nvl2(loc.address2,', '||loc.address2,NULL) ||
         nvl2(loc.address3,', '||loc.address3,NULL) ||
         nvl2(loc.address4,', '||loc.address4,NULL) ||
         nvl2(loc.city, ', '||loc.city,  NULL) ||
         nvl2(loc.state, ', ' ||loc.state, NULL) ||
         nvl2(loc.province,', '||loc.province, NULL)||
         nvl2(loc.postal_code, ' '||loc.postal_code,NULL) ||
         nvl2(loc.country, ' ' || loc.country, NULL )
  FROM HZ_LOCATIONS LOC
  WHERE loc.location_id = v_incident_location_id;

 CURSOR Get_SR_PS_Location (v_incident_location_id NUMBER) IS
  SELECT loc.address1 || nvl2(loc.address2,','||loc.address2,NULL) ||
         nvl2(loc.address3,', '||loc.address3,NULL) ||
         nvl2(loc.address4,', '||loc.address4,NULL) ||
         nvl2(loc.city, ', '||loc.city, NULL)||
         nvl2(loc.state, ', ' ||loc.state, NULL) ||
         nvl2(loc.province,', '||loc.province, NULL) ||
         nvl2(loc.postal_code, ' '||loc.postal_code,NULL) ||
         nvl2(loc.country, ' ' || loc.country, NULL)
  FROM HZ_LOCATIONS LOC,
       hz_party_sites hzp
  WHERE hzp.party_site_id = v_incident_location_id
  AND hzp.location_id = loc.location_id;

l_Incident_Address VARCHAR2(2000);

--:escalation
 CURSOR Get_Escalation (v_incident_id NUMBER) IS
  SELECT fnd1.meaning escalation_level
  FROM fnd_lookups fnd1,
       jtf_task_references_b r,
       jtf_tasks_b t
  WHERE fnd1.lookup_type = 'JTF_EC_ESC_LEVEL'and
        fnd1.lookup_code = t.escalation_level and
        v_incident_id = r.OBJECT_ID and
        r.object_type_code = 'SR' and
        r.reference_code = 'ESC' and
        r.task_id  = t.task_id and
        t.task_type_id = 22;
   l_escalation VARCHAR2(80);

BEGIN
  -- Log the input parameter

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Generate_XML_Document')) THEN
        dbg_msg := ('In CS_ERES_INT_PKG.Generate_XML_Document Procedure');
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Generate_XML_Document', dbg_msg);
        END IF;
        dbg_msg := ('P_Incident_Id : '||P_Incident_Id);
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Generate_XML_Document', dbg_msg);
        END IF;
        dbg_msg := ('P_Detailed_xml_reqd : '||P_Detailed_xml_reqd);
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Generate_XML_Document', dbg_msg);
        END IF;
      END IF;
    END IF;

    IF NVL(P_Detailed_xml_reqd,'N') ='N' THEN

       l_query := 'SELECT
	 sr.incident_number Incident_Number
	,(SELECT type.name
  	     FROM cs_incident_types_tl type
	  WHERE type.incident_type_id = sr.incident_type_id
	        AND type.language = userenv(''LANG'')) Incident_Type
	 ,(SELECT type.detailed_erecord_req_flag
	   FROM cs_incident_types_b type
	   WHERE type.incident_type_id = sr.incident_type_id) Detailed_Erecord
	,(SELECT status.name
	      FROM cs_incident_statuses_tl status
	   WHERE status.incident_status_id = sr.incident_status_id
	         AND status.language = userenv(''LANG'') )Incident_Status
	,(SELECT sev.name
	      FROM cs_incident_severities_tl sev
	   WHERE sev.incident_severity_id = sr.incident_severity_id
	         AND sev.language = userenv(''LANG''))Incident_Severity
	,(SELECT sev.importance_level
	      FROM cs_incident_severities_b sev
	   WHERE sev.incident_severity_id = sr.incident_severity_id
	   ) Sev_Importance_Level
	,(SELECT urgency.name
	    FROM cs_incident_urgencies_tl urgency
	   WHERE urgency.incident_urgency_id = sr.incident_urgency_id
	     AND urgency.language = userenv(''LANG'')) Incident_Urgency
	,(SELECT gr.group_name
	    FROM jtf_rs_groups_tl gr
	   WHERE gr.group_id = sr.owner_group_id
             AND gr.LANGUAGE = userenv(''LANG''))Sr_Group
        ,(SELECT rs.resource_name
            FROM jtf_rs_resource_extns_tl rs
           WHERE rs.resource_id = sr.incident_owner_id
             AND rs.language = userenv(''LANG'') )Sr_Owner
        ,(SELECT problem.meaning
            FROM fnd_lookup_values problem
           WHERE problem.lookup_code = sr.problem_code
             AND problem.lookup_type = ''REQUEST_PROBLEM_CODE''
             AND problem.LANGUAGE = userenv(''LANG'')
             AND problem.View_APPLICATION_ID = 170
             AND problem.SECURITY_GROUP_ID = fnd_global.lookup_security_group(problem.LOOKUP_TYPE, problem.VIEW_APPLICATION_ID) ) Problem_code
        ,(SELECT resolution.meaning
            FROM fnd_lookup_values resolution
           WHERE resolution.lookup_code = sr.resolution_code
             AND resolution.lookup_type = ''REQUEST_RESOLUTION_CODE''
             AND resolution.LANGUAGE = userenv(''LANG'')
             AND resolution.View_APPLICATION_ID = 170
             AND resolution.SECURITY_GROUP_ID = fnd_global.lookup_security_group(resolution.LOOKUP_TYPE,resolution.VIEW_APPLICATION_ID)) Resolution_code
       ,tl.summary Problem_summary
       ,tl.resolution_summary  Resolution_Summary
          FROM cs_incidents_b_sec sr, cs_incidents_all_tl tl
	  WHERE sr.incident_id = tl.incident_id
	  AND tl.language = userenv(''lang'')
          AND  sr.incident_id = :INCIDENT_ID' ;
    ELSE

-- Get Content
   --dbms_output.put_line('time_zone_enabled '||l_timezone_enabled);
   --dbms_output.put_line('server_timezone '||l_server_timezone_id);
   --dbms_output.put_line('client_timezone '||l_client_timezone_id);

    IF  NVL(P_Detailed_xml_reqd,'N') ='Y' THEN
      IF l_timezone_enabled = 'Y' THEN
        l_display_timezone_id := to_number(nvl(l_client_timezone_id, l_server_timezone_id));
        l_source_timezone_id :=  to_number(l_server_timezone_id);
        l_desc_timezone_id := to_number(nvl(l_client_timezone_id, l_server_timezone_id));
      ELSE
        l_display_timezone_id := to_number(l_server_timezone_id);
        l_source_timezone_id :=  to_number(l_server_timezone_id);
        l_desc_timezone_id := to_number(l_server_timezone_id);
      END IF;
    END IF; --detailed_xml

   OPEN  GET_SR (l_display_timezone_id, l_source_timezone_id, l_desc_timezone_id, l_date_format);
   FETCH GET_SR INTO l_Incident_Id
 ,l_Incident_Number
 ,l_incident_type_id
 ,l_Incident_Status_Id
 ,l_Incident_Severity_Id
 ,l_Incident_Urgency_Id
 ,l_Sr_Group_Id
 ,l_Sr_Owner_Id
 ,l_Problem_code_id
 ,l_Resolution_code_id
 ,l_summary
 ,l_resolution_summary
 ,l_Publish_Flag
 ,l_Problem_Summary
 ,l_TimeZone_Id
 ,l_Customer_Id
 ,l_Account_Id
 ,l_Inventory_Item_Id
 ,l_reported_date
 ,l_Last_Update_Date
 ,l_Incident_Date
 ,l_Close_Date
 ,l_incident_resolved_date
 ,l_respond_by_date
 ,l_resolve_by_date
 ,l_inc_responded_by_date
 ,l_Actual_Resolution_Date
 ,l_Status_Flag_Code
 ,l_Created_By_Id
 ,l_Customer_Product_Id
 ,l_Organization_Id
 ,l_Inventory_Org_Id
 ,l_Instance_Number
 ,l_Serial_Number
 ,l_Tag_Number
 ,l_Item_Revision
 ,l_Component_Revision
 ,l_Sub_Component_Revision
 ,l_Attribute1
 ,l_Attribute2
 ,l_Attribute3
 ,l_Attribute4
 ,l_Attribute5
 ,l_Attribute6
 ,l_Attribute7
 ,l_Attribute8
 ,l_Attribute9
 ,l_Attribute10
 ,l_Attribute11
 ,l_Attribute12
 ,l_Attribute13
 ,l_Attribute14
 ,l_Attribute15
 ,l_Incident_Context
 ,l_Ext_Attribute1
 ,l_Ext_Attribute2
 ,l_Ext_Attribute3
 ,l_Ext_Attribute4
 ,l_Ext_Attribute5
 ,l_Ext_Attribute6
 ,l_Ext_Attribute7
 ,l_Ext_Attribute8
 ,l_Ext_Attribute9
 ,l_Ext_Attribute10
 ,l_Ext_Attribute11
 ,l_Ext_Attribute12
 ,l_Ext_Attribute13
 ,l_Ext_Attribute14
 ,l_Ext_Attribute15
 ,l_Ext_Context
 ,l_sr_creation_channel
 ,l_contract_service_id
 ,l_category_id
 ,l_system_id
 ,l_inv_component_id
 ,l_cp_subcomponent_id
 ,l_resource_type_code
 ,l_incident_LOCATION_ID
 ,l_incident_addr
 ,l_incident_city
 ,l_incident_state
 ,l_incident_province
 ,l_incident_postal_code
 ,l_incident_country
 ,l_instance_inventory_item_id
 ,l_instance_id
 ,l_cp_component_id
 ,l_inv_subcomponent_id
 ,l_incident_location_type;
   CLOSE GET_SR;

IF l_Incident_Id IS NOT NULL THEN

  OPEN  Incident_Type (l_incident_type_id);
  FETCH Incident_Type INTO l_Incident_Type, l_Detailed_Erecord;
  CLOSE Incident_Type;

  OPEN  Get_Inc_Status (l_incident_status_id);
  FETCH Get_Inc_Status INTO l_Incident_Status,l_status_sort_order;
  CLOSE Get_Inc_Status;

  OPEN  Get_Inc_Severity (l_incident_severity_id);
  FETCH Get_Inc_Severity INTO l_Incident_Severity, l_Sev_Importance_Level;
  CLOSE Get_Inc_Severity;

  OPEN  Get_Inc_Urg (l_incident_urgency_id);
  FETCH Get_Inc_Urg INTO l_Incident_Urgency;
  CLOSE Get_Inc_Urg;

  OPEN  Get_Group (l_Sr_Group_Id);
  FETCH Get_Group INTO l_Sr_Group;
  CLOSE Get_Group;

  OPEN  Get_Resource (l_Sr_Owner_Id);
  FETCH Get_Resource INTO l_Sr_Owner;
  CLOSE Get_Resource;

  OPEN  Get_Cs_Lookup ( l_Problem_code_id, 'REQUEST_PROBLEM_CODE');
  FETCH Get_Cs_Lookup INTO l_Problem_code;
  CLOSE Get_Cs_Lookup;

  OPEN  Get_Cs_Lookup ( l_Resolution_code_id, 'REQUEST_RESOLUTION_CODE');
  FETCH Get_Cs_Lookup INTO l_Resolution_code;
  CLOSE Get_Cs_Lookup;

  OPEN  Get_Cs_Lookup ( l_Sr_Creation_Channel, 'CS_SR_CREATION_CHANNEL');
  FETCH Get_Cs_Lookup INTO l_Sr_Creation_Channel_Name;
  CLOSE Get_Cs_Lookup;


  OPEN  Get_Fnd_User (l_Created_By_Id);
  FETCH Get_Fnd_User INTO l_Created_By;
  CLOSE Get_Fnd_User;

  OPEN  Get_Contact_Type(l_incident_id);
  FETCH Get_Contact_Type INTO l_Contact_Type;
  CLOSE Get_Contact_Type;

  OPEN  Get_Contact_Name(l_incident_id, l_customer_id);
  FETCH Get_Contact_Name INTO l_Contact_Name;
  CLOSE Get_Contact_Name;

  OPEN  Get_Timezone (l_timezone_id);
  FETCH Get_Timezone INTO l_TimeZone_Name;
  CLOSE Get_Timezone;

  OPEN  Get_Account (l_account_id);
  FETCH Get_Account INTO l_account_number;
  CLOSE Get_Account;

  OPEN  Get_Timezone (l_display_timezone_id);
  FETCH Get_Timezone INTO l_display_timezone;
  CLOSE Get_Timezone;

  OPEN  Get_Product (l_inventory_item_id, l_Inventory_Org_Id);
  FETCH Get_Product INTO l_Product, l_Product_Description;
  CLOSE Get_Product;

   OPEN  Get_Party (l_customer_id );
  FETCH Get_Party INTO l_Customer_Number, l_Customer_Name, l_customer_phone, l_Customer_Email, l_party_type;
  CLOSE Get_Party;

  OPEN  Get_Cs_Lookup (l_party_type, 'CS_SR_CALLER_TYPE');
  FETCH Get_Cs_Lookup INTO l_Customer_Type;
  CLOSE Get_Cs_Lookup;

  OPEN  Get_Contract (l_contract_service_id);
  FETCH Get_Contract INTO l_Contract_Number, l_Contract_Service, l_Contract_Coverage;
  CLOSE Get_Contract;

  OPEN  Get_Contact_Phone (l_incident_id);
  FETCH Get_Contact_Phone INTO  l_Contact_Phone_Number, l_Contact_Telephone_Type;
  CLOSE Get_Contact_Phone;

  OPEN  Get_Contact_Email (l_incident_id);
  FETCH Get_Contact_Email INTO l_Contact_Email;
  CLOSE Get_Contact_Email;

  OPEN  Get_Item_Category (l_category_id);
  FETCH Get_Item_Category INTO l_Item_Category;
  CLOSE Get_Item_Category;

  OPEN  Get_System_Number (l_system_id);
  FETCH Get_System_Number INTO l_System_Number;
  CLOSE Get_System_Number;

  OPEN  Get_Res_Type (l_resource_type_code);
  FETCH Get_Res_Type INTO l_Resource_Type;
  CLOSE Get_Res_Type;

  OPEN  Get_Escalation (l_incident_id);
  FETCH Get_Escalation INTO l_escalation;
  CLOSE Get_Escalation;

 IF l_Customer_Product_Id IS NOT NULL THEN
   OPEN  Get_Component_Instance (l_cp_component_id, l_Inventory_Org_Id);
   FETCH Get_Component_Instance INTO l_Component;
   CLOSE Get_Component_Instance;

   OPEN  Get_Component_Instance (l_cp_subcomponent_id, l_Inventory_Org_Id);
   FETCH Get_Component_Instance INTO l_Sub_Component;
   CLOSE Get_Component_Instance;

 ELSE
   OPEN  Get_Component (l_inv_component_id, l_Inventory_Org_Id);
   FETCH Get_Component INTO l_Component;
   CLOSE Get_Component;

   OPEN  Get_Component (l_inv_subcomponent_id, l_Inventory_Org_Id);
   FETCH Get_Component INTO l_Sub_Component;
   CLOSE Get_Component;

 END IF;

 IF l_incident_location_id IS NOT NULL THEN
   IF l_incident_location_type ='HZ_LOCATIONS' THEN
     OPEN  Get_SR_Location (l_incident_location_id);
     FETCH Get_SR_Location INTO l_Incident_Address;
     CLOSE Get_SR_Location;
   ELSIF l_incident_location_type = 'HZ_PARTY_SITE' THEN
     OPEN  Get_SR_PS_Location (l_incident_location_id);
     FETCH Get_SR_PS_Location INTO l_Incident_Address;
     CLOSE Get_SR_PS_Location;
   END IF;
 ELSE

   l_Incident_Address := l_incident_addr || l_incident_city || l_incident_state ||
                         l_incident_province || l_incident_postal_code || l_incident_country;
 END IF;
END IF;

 	l_query :=
	'SELECT
  :INCIDENT_ID AS INCIDENT_ID
 ,:INCIDENT_NUMBER AS INCIDENT_NUMBER
 ,:INCIDENT_TYPE_ID AS INCIDENT_TYPE_ID
 ,:INCIDENT_TYPE AS INCIDENT_TYPE
 ,:DETAILED_ERECORD AS DETAILED_ERECORD
 ,:INCIDENT_STATUS_ID AS INCIDENT_STATUS_ID
 ,:INCIDENT_STATUS AS INCIDENT_STATUS
 ,:INCIDENT_SEVERITY_ID AS INCIDENT_SEVERITY_ID
 ,:INCIDENT_SEVERITY AS INCIDENT_SEVERITY
 ,:SEV_IMPORTANCE_LEVEL AS SEV_IMPORTANCE_LEVEL
 ,:INCIDENT_URGENCY_ID AS INCIDENT_URGENCY_ID
 ,:INCIDENT_URGENCY  AS INCIDENT_URGENCY
 ,:SR_GROUP_ID AS SR_GROUP_ID
 ,:SR_GROUP AS SR_GROUP
 ,:SR_OWNER_ID AS SR_OWNER_ID
 ,:SR_OWNER AS SR_OWNER
 ,:PROBLEM_CODE_ID AS PROBLEM_CODE_ID
 ,:PROBLEM_CODE AS PROBLEM_CODE
 ,:RESOLUTION_CODE_ID AS RESOLUTION_CODE_ID
 ,:RESOLUTION_CODE AS RESOLUTION_CODE
 ,:SUMMARY AS SUMMARY
 ,:RESOLUTION_SUMMARY AS resolution_summary
 ,:PUBLISH_FLAG AS PUBLISH_FLAG
 ,:SR_CREATION_CHANNEL AS SR_CREATION_CHANNEL
 ,:PROBLEM_SUMMARY AS PROBLEM_SUMMARY
 ,:RESOLUTION_SUMMARY AS  RESOLUTION_SUMMARY
 ,:CREATED_BY AS CREATED_BY
 ,:CONTACT_TYPE AS CONTACT_TYPE
 ,:CONTACT_NAME AS CONTACT_NAME
 ,:TIMEZONE_ID AS TIMEZONE_ID
 ,:TIMEZONE_NAME AS TIMEZONE_NAME
 ,:CUSTOMER_ID AS CUSTOMER_ID
 ,:CUSTOMER_NUMBER AS CUSTOMER_NUMBER
 ,:CUSTOMER_NAME AS CUSTOMER_NAME
 ,:ACCOUNT_ID AS ACCOUNT_ID
 ,:ACCOUNT_NUMBER AS ACCOUNT_NUMBER
 ,:INVENTORY_ITEM_ID AS INVENTORY_ITEM_ID
 ,:PRODUCT AS PRODUCT
 ,:PRODUCT_DESCRIPTION AS PRODUCT_DESCRIPTION
 ,:DISPLAY_TIMEZONE AS DISPLAY_TIMEZONE
 ,:REPORTED_DATE AS REPORTED_DATE
 ,:LAST_UPDATE_DATE AS LAST_UPDATE_DATE
 ,:INCIDENT_DATE AS INCIDENT_DATE
 ,:CLOSE_DATE AS CLOSE_DATE
 ,:INCIDENT_RESOLVED_DATE AS INCIDENT_RESOLVED_DATE
 ,:RESPOND_BY_DATE AS RESPOND_BY_DATE
 ,:RESOLVE_BY_DATE AS RESOLVE_BY_DATE
 ,:INC_RESPONDED_BY_DATE AS INC_RESPONDED_BY_DATE
 ,:ACTUAL_RESOLUTION_DATE AS ACTUAL_RESOLUTION_DATE
 ,:STATUS_SORT_ORDER AS STATUS_SORT_ORDER
 ,:STATUS_FLAG_CODE AS STATUS_FLAG_CODE
 ,:CREATED_BY_ID AS CREATED_BY_ID
 ,:CUSTOMER_PRODUCT_ID AS CUSTOMER_PRODUCT_ID
 ,:ORGANIZATION_ID AS ORGANIZATION_ID
 ,:INVENTORY_ORG_ID AS INVENTORY_ORG_ID
 ,:CUSTOMER_PHONE AS CUSTOMER_PHONE
 ,:CUSTOMER_EMAIL AS CUSTOMER_EMAIL
 ,:CUSTOMER_TYPE AS CUSTOMER_TYPE
 ,:CONTRACT_NUMBER AS CONTRACT_NUMBER
 ,:CONTRACT_SERVICE AS CONTRACT_SERVICE
 ,:CONTRACT_COVERAGE AS CONTRACT_COVERAGE
 ,:CONTACT_PHONE_NUMBER AS CONTACT_PHONE_NUMBER
 ,:CONTACT_EMAIL AS CONTACT_EMAIL
 ,:CONTACT_TELEPHONE_TYPE AS CONTACT_TELEPHONE_TYPE
 ,:ITEM_CATEGORY AS ITEM_CATEGORY
 ,:INSTANCE_NUMBER AS INSTANCE_NUMBER
 ,:SERIAL_NUMBER AS SERIAL_NUMBER
 ,:TAG_NUMBER AS TAG_NUMBER
 ,:SYSTEM_NUMBER AS SYSTEM_NUMBER
 ,:COMPONENT AS COMPONENT
 ,:SUB_COMPONENT AS SUB_COMPONENT
 ,:ITEM_REVISION AS ITEM_REVISION
 ,:COMPONENT_REVISION AS COMPONENT_REVISION
 ,:SUB_COMPONENT_REVISION AS SUB_COMPONENT_REVISION
 ,:INCIDENT_ADDRESS AS INCIDENT_ADDRESS
 ,:RESOURCE_TYPE AS  RESOURCE_TYPE
 ,:ATTRIBUTE1 AS ATTRIBUTE1
 ,:ATTRIBUTE2 AS ATTRIBUTE2
 ,:ATTRIBUTE3 AS ATTRIBUTE3
 ,:ATTRIBUTE4 AS ATTRIBUTE4
 ,:ATTRIBUTE5 AS ATTRIBUTE5
 ,:ATTRIBUTE6 AS ATTRIBUTE6
 ,:ATTRIBUTE7 AS ATTRIBUTE7
 ,:ATTRIBUTE8 AS ATTRIBUTE8
 ,:ATTRIBUTE9 AS ATTRIBUTE9
 ,:ATTRIBUTE10 AS ATTRIBUTE10
 ,:ATTRIBUTE11 AS ATTRIBUTE11
 ,:ATTRIBUTE12 AS ATTRIBUTE12
 ,:ATTRIBUTE13 AS ATTRIBUTE13
 ,:ATTRIBUTE14 AS ATTRIBUTE14
 ,:ATTRIBUTE15 AS ATTRIBUTE15
 ,:INCIDENT_CONTEXT AS INCIDENT_CONTEXT
 ,:EXT_ATTRIBUTE1 AS EXT_ATTRIBUTE1
 ,:EXT_ATTRIBUTE2 AS EXT_ATTRIBUTE2
 ,:EXT_ATTRIBUTE3 AS EXT_ATTRIBUTE3
 ,:EXT_ATTRIBUTE4 AS EXT_ATTRIBUTE4
 ,:EXT_ATTRIBUTE5 AS EXT_ATTRIBUTE5
 ,:EXT_ATTRIBUTE6 AS EXT_ATTRIBUTE6
 ,:EXT_ATTRIBUTE7 AS EXT_ATTRIBUTE7
 ,:EXT_ATTRIBUTE8 AS EXT_ATTRIBUTE8
 ,:EXT_ATTRIBUTE9 AS EXT_ATTRIBUTE9
 ,:EXT_ATTRIBUTE10 AS EXT_ATTRIBUTE10
 ,:EXT_ATTRIBUTE11 AS EXT_ATTRIBUTE11
 ,:EXT_ATTRIBUTE12 AS EXT_ATTRIBUTE12
 ,:EXT_ATTRIBUTE13 AS EXT_ATTRIBUTE13
 ,:EXT_ATTRIBUTE14 AS EXT_ATTRIBUTE14
 ,:EXT_ATTRIBUTE15 AS EXT_ATTRIBUTE15
 ,:EXT_CONTEXT AS EXT_CONTEXT
 ,:ESCALATION AS ESCALATION
 , CS_ERES_INT_PKG.Get_SR_Tasks (:INCIDENT_ID, :L_SOURCE_TIMEZONE_ID, :L_DESC_TIMEZONE_ID, :L_DATE_FORMAT) AS TASK_LIST
        , CS_ERES_INT_PKG.Get_SR_Notes (:incident_id, :l_source_timezone_id, :l_desc_timezone_id, :l_date_format) NOTE_LIST
        , CS_ERES_INT_PKG.Get_Related_SRs(:incident_id) RELATED_SR_LIST
        , CS_ERES_INT_PKG.Get_Related_Objs(:incident_id) RELATED_OB_LIST
  FROM DUAL';


    END IF ;

    -- Log that XMLGen is being called

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Generate_XML_Document')) THEN
          dbg_msg := ('Calling DBMS_XMLGEN.getXML Procedure');
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Generate_XML_Document', dbg_msg);
          END IF;
        END IF;
      END IF;

    dbms_lob.createtemporary(xmldoc,true,DBMS_LOB.CALL);
    Ctx1 := DBMS_XMLGEN.newContext(l_query);

    dbms_xmlgen.setRowTag(Ctx1,'oracle.apps.cs.sr.ServiceRequestApproval');
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_ID', p_incident_id);

   --dbms_output.put_line('time_zone_enabled '||l_timezone_enabled);
   --dbms_output.put_line('server_timezone '||l_server_timezone_id);
   --dbms_output.put_line('client_timezone '||l_client_timezone_id);
   --dbms_output.put_line('l_date_format : '||l_date_format);

    IF  NVL(P_Detailed_xml_reqd,'N') ='Y' THEN

        IF l_timezone_enabled = 'Y' THEN
           l_client_timezone_id := nvl(l_client_timezone_id, l_server_timezone_id);
--           DBMS_XMLGEN.setBindValue(Ctx1,'l_display_timezone_id',l_client_timezone_id);
           DBMS_XMLGEN.setBindValue(Ctx1,'l_source_timezone_id',l_server_timezone_id);
           DBMS_XMLGEN.setBindValue(Ctx1,'l_desc_timezone_id',l_client_timezone_id);
           DBMS_XMLGEN.setBindValue(Ctx1,'l_date_format',l_date_format);
        ELSE
--           DBMS_XMLGEN.setBindValue(Ctx1,'l_display_timezone_id',l_server_timezone_id);
           DBMS_XMLGEN.setBindValue(Ctx1,'l_source_timezone_id',l_server_timezone_id);
           DBMS_XMLGEN.setBindValue(Ctx1,'l_desc_timezone_id',l_server_timezone_id);
           DBMS_XMLGEN.setBindValue(Ctx1,'l_date_format',l_date_format);
        END IF;

    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_NUMBER', l_Incident_Number);
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_TYPE_ID', l_incident_type_id);
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_TYPE', l_Incident_Type);
    DBMS_XMLGEN.setBindValue(Ctx1,'DETAILED_ERECORD', l_Detailed_Erecord);
--
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_STATUS_ID', l_Incident_Status_Id);
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_STATUS', l_Incident_Status);
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_SEVERITY_ID', l_Incident_Severity_Id);
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_SEVERITY', l_Incident_Severity);
    DBMS_XMLGEN.setBindValue(Ctx1,'SEV_IMPORTANCE_LEVEL', nvl(to_char(l_Sev_Importance_Level),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_URGENCY_ID', nvl(to_char(l_Incident_Urgency_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'INCIDENT_URGENCY', nvl(l_Incident_Urgency,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'SR_GROUP_ID', nvl(to_char(l_Sr_Group_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'SR_GROUP', nvl(l_Sr_Group,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'SR_OWNER_ID', nvl(to_char(l_Sr_Owner_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'SR_OWNER', nvl(l_Sr_Owner,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Problem_code_id', nvl(to_char(l_Problem_code_id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Problem_code', nvl(l_Problem_code,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Resolution_code_id', nvl(to_char(l_Resolution_code_id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Resolution_code', nvl(l_Resolution_code,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'summary', nvl(l_summary,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'resolution_summary', nvl(l_resolution_summary,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Publish_Flag', nvl(l_Publish_Flag,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Sr_Creation_Channel', nvl(l_Sr_Creation_Channel,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Problem_Summary', nvl(l_Problem_Summary,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Created_By', nvl(l_Created_By,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Contact_Type', nvl(l_Contact_Type,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Contact_Name', nvl(l_Contact_Name,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'TimeZone_Id', nvl(to_char(l_TimeZone_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'TimeZone_Name', nvl(l_TimeZone_Name,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Customer_Id', nvl(to_char(l_Customer_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Customer_Number', nvl(l_Customer_Number,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Customer_Name', nvl(l_Customer_Name,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Account_Id', nvl(to_char(l_Account_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'account_number', nvl(l_account_number,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Inventory_Item_Id', nvl(to_char(l_Inventory_Item_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Product', nvl(l_Product,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Product_Description', nvl(l_Product_Description,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'display_timezone', nvl(l_display_timezone,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'reported_date', nvl(l_reported_date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Last_Update_Date', nvl(l_Last_Update_Date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Incident_Date', nvl(l_Incident_Date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Close_Date', nvl(l_Close_Date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'incident_resolved_date', nvl(l_incident_resolved_date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'respond_by_date', nvl(l_respond_by_date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'resolve_by_date', nvl(l_resolve_by_date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'inc_responded_by_date', nvl(l_inc_responded_by_date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Actual_Resolution_Date', nvl(l_Actual_Resolution_Date,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'status_sort_order', nvl(to_char(l_status_sort_order),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Status_Flag_Code', nvl(l_Status_Flag_Code,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Created_By_Id', nvl(to_char(l_Created_By_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Customer_Product_Id', nvl(to_char(l_Customer_Product_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Organization_Id', nvl(to_char(l_Organization_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Inventory_Org_Id', nvl(to_char(l_Inventory_Org_Id),' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'customer_phone', nvl(l_customer_phone,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Customer_Email', nvl(l_Customer_Email,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Customer_Type', nvl(l_Customer_Type,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Contract_Number', nvl(l_Contract_Number,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Contract_Service', nvl(l_Contract_Service,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Contract_Coverage', nvl(l_Contract_Coverage,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Contact_Phone_Number', nvl(l_Contact_Phone_Number,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Contact_Email', nvl(l_Contact_Email,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Contact_Telephone_Type', nvl(l_Contact_Telephone_Type,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Item_Category', nvl(l_Item_Category,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Instance_Number', nvl(l_Instance_Number,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Serial_Number', nvl(l_Serial_Number,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Tag_Number', nvl(l_Tag_Number,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'System_Number', nvl(l_System_Number,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Component', nvl(l_Component,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Sub_Component', nvl(l_Sub_Component,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Item_Revision', nvl(l_Item_Revision,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Component_Revision', nvl(l_Component_Revision,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Sub_Component_Revision', nvl(l_Sub_Component_Revision,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Incident_Address', nvl(l_Incident_Address,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Resource_Type', nvl(l_Resource_Type,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute1', nvl(l_Attribute1,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute2', nvl(l_Attribute2,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute3', nvl(l_Attribute3,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute4', nvl(l_Attribute4,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute5', nvl(l_Attribute5,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute6', nvl(l_Attribute6,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute7', nvl(l_Attribute7,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute8', nvl(l_Attribute8,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute9', nvl(l_Attribute9,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute10', nvl(l_Attribute10,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute11', nvl(l_Attribute11,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute12', nvl(l_Attribute12,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute13', nvl(l_Attribute13,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute14', nvl(l_Attribute14,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Attribute15', nvl(l_Attribute15,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Incident_Context', nvl(l_Incident_Context,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute1', nvl(l_Ext_Attribute1,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute2', nvl(l_Ext_Attribute2,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute3', nvl(l_Ext_Attribute3,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute4', nvl(l_Ext_Attribute4,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute5', nvl(l_Ext_Attribute5,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute6', nvl(l_Ext_Attribute6,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute7', nvl(l_Ext_Attribute7,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute8', nvl(l_Ext_Attribute8,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute9', nvl(l_Ext_Attribute9,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute10', nvl(l_Ext_Attribute10,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute11', nvl(l_Ext_Attribute11,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute12', nvl(l_Ext_Attribute12,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute13', nvl(l_Ext_Attribute13,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute14', nvl(l_Ext_Attribute14,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Attribute15', nvl(l_Ext_Attribute15,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'Ext_Context', nvl(l_Ext_Context,' '));
    DBMS_XMLGEN.setBindValue(Ctx1,'escalation', nvl(l_escalation,' '));

    END IF; --detailed_xml

      DBMS_XMLGEN.setNullHandling(Ctx1, 2);
      DBMS_XMLGEN.getXML(Ctx1,xmldoc,dbms_xmlgen.SCHEMA);
      dbms_xmlgen.closeContext(Ctx1);

    -- Log that XMLGen call is complete

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Generate_XML_Document')) THEN
        dbg_msg := ('After Calling DBMS_XMLGEN.getXML Procedure');
        IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Generate_XML_Document', dbg_msg);
        END IF;
      END IF;
    END IF;

    -- get number of service request extensible attribute records

    SELECT COUNT(1)
    INTO   l_ext_rec_count
    FROM   CS_INCIDENTS_EXT
    WHERE  incident_id = p_incident_id;

    -- If a service request has any extensible atribute records only then call
    -- append_ea_data

    IF l_ext_rec_count > 0 THEN
      xmldoc := append_ea_data(p_incident_id, xmldoc);
    END IF;
    --

    RETURN xmldoc;

EXCEPTION
  WHEN OTHERS THEN
--dbms_output.put_line('Other Error: '||sqlcode||sqlerrm);
       FND_MESSAGE.SET_NAME('CS','CS_ERES_XML_GEN_FAILED');
       FND_MESSAGE.SET_TOKEN ('SQLCODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN ('SQLERRM',SQLERRM);
       FND_MSG_PUB.ADD;
       RETURN NULL;
END Generate_XML_Document ;

--------------------------------------------------------------------------------
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 12/19/05 smisra   Bug 4896857
--                   for note tpye value used the profile
--                   'CS_SR_ERES_COMMENT_NOTE_TYPE' instead of
--                   'Service: Note Type For ERES Comment'
--------------------------------------------------------------------------------
PROCEDURE Post_Approval_Process
 ( P_Incident_id              IN        NUMBER,
   P_Intermediate_Status_Id   IN        NUMBER ) IS

 -- Cursor to get service request version number, current status
 -- and lock the service request

    CURSOR c_Get_SR_Version IS
           SELECT object_version_number , incident_status_id
             FROM cs_incidents_all_b
            WHERE incident_id = p_incident_id
              FOR UPDATE;


 -- Variables to pass to the EDR APIs

    l_eRecord_Id         NUMBER;
    l_document_rec       EDR_PSIG_DOCUMENTS%ROWTYPE;
    l_doc_param_table    EDR_EvidenceStore_PUB.Params_tbl_type;
    l_Signatures_tbl     EDR_EvidenceStore_PUB.Signature_tbl_type;
    l_SignatureDetails 	 EDR_PSIG_DETAILS%ROWTYPE;
    l_Signatureparams    EDR_EvidenceStore_PUB.params_tbl_type;

 -- Variables to be passed to the Update SR API
    l_note_status        VARCHAR2(240);
    l_note_type          VARCHAR2(240);
    l_notes_table        CS_ServiceRequest_PVT.Notes_Table;
    l_notes_table_dummy  CS_ServiceRequest_PVT.Notes_Table;
    l_ServiceRequest_Rec CS_ServiceRequest_PVT.Service_Request_Rec_Type;
    l_sr_version         NUMBER;
    l_note_text          VARCHAR2(4000);
    l_contacts_table     CS_ServiceRequest_PVT.Contacts_Table;
    l_sr_update_out_rec  CS_ServiceRequest_PVT.sr_update_out_rec_type;

 -- Local Variables
    l_sig_status         VARCHAR2(40);
    l_target_status_id   NUMBER;
    l_return_status      VARCHAR2(3);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(1000);
    l_sr_status_id       NUMBER;
    q                    NUMBER := 1 ;
    l_approver           VARCHAR2(240);
    l_note_detail        VARCHAR2(32000);
    l_comment            VARCHAR2(30000);
    l_action             VARCHAR2(240);
    l_note_title         VARCHAR2(280);
    lx_msg_count         NUMBER;
    lx_msg_data          VARCHAR2(4000);
    lx_return_status     VARCHAR2(1);
    lx_msg_index_out     NUMBER;
    l_chr_newline        VARCHAR2(8) := fnd_global.newline;
    l_api_name           VARCHAR2(240) := 'Post_Approval_Process';
    l_spl_excp           VARCHAR2(3) := 'N';
    l_note_id            NUMBER;
    l_note_err_msg       VARCHAR2(240);
    l_validate_sr_close  VARCHAR2(30) := FND_PROFILE.VALUE('CS_SR_AUTO_CLOSE_CHILDREN');
--    l_close_sr_child     VARCHAR2(3) := FND_PROFILE.VALUE('CS_SR_AUTO_CLOSE_CHILDREN');


BEGIN
  -- Log the input parameters

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
        dbg_msg := ('In CS_ERES_INT_PKG.Post_Approval_Process Procedure');
        IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
        END IF;

        dbg_msg := ('P_Incident_id : '||P_Incident_id);
        IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
        END IF;

        dbg_msg := ('P_Intermediate_Status_Id : '||P_Intermediate_Status_Id);
        IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
        END IF;

      END IF;
    END IF;

   -- Get the approval status

      l_sig_status         := EDR_STANDARD_PUB.G_SIGNATURE_STATUS;

    -- Log the E Signature Status

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
          dbg_msg := ('E Signature Status : '||l_sig_status);
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;
        END IF;
      END IF;

    -- Log Get_Target_SR_Status is being called

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
          dbg_msg := ('Calling Get_Target_SR_Status');
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;
        END IF;
      END IF;

   -- Get the target Service request status

      l_return_status := FND_API.G_RET_STS_SUCCESS;

      Get_Target_SR_Status
       ( P_Incident_Id              => P_Incident_id,
         P_Intermediate_Status_Id   => P_Intermediate_Status_Id,
         P_Action                   => l_sig_status ,
         X_Target_Status_Id         => l_target_status_id,
         X_Return_Status            => l_return_status,
         X_Msg_count                => l_msg_count ,
         X_Msg_data                 => l_msg_data );

   -- Log the output of Get_Target_SR_Status

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN

          dbg_msg := ('After Calling Get_Target_SR_Status');
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;

          dbg_msg := ('Get_Target_SR_Status Return Status : '||l_return_status||' Msg Data : '||l_msg_data);
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;

          dbg_msg := ('Target Status Id : '||l_target_status_id);
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;

        END IF;
      END IF;


    -- Log EDR_Standard_PUB.Get_ERecord_ID is being called

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
          dbg_msg := ('Calling EDR_Standard_PUB.Get_ERecord_ID');
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;
        END IF;
      END IF;

   -- Get the document ID (Erecord Id) using the event key and event name

      l_return_status := FND_API.G_RET_STS_SUCCESS;

      EDR_Standard_PUB.Get_ERecord_ID
        (p_api_version        => 1.0,
         p_init_msg_list      => fnd_api.g_false,
         p_event_name         => 'oracle.apps.cs.sr.ServiceRequestApproval',
         p_event_key          => P_Incident_id,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count ,
         x_msg_data	      => l_msg_data,
         x_erecord_id         => l_eRecord_Id );


    -- Log EDR_Standard_PUB.Get_ERecord_ID return status

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
          dbg_msg := ('After Calling EDR_Standard_PUB.Get_ERecord_ID');
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;
          dbg_msg := ('EDR_Standard_PUB.Get_ERecord_ID Return Status : '||l_return_status);
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;
          dbg_msg := ('EDR_Standard_PUB.Get_ERecord_ID ERecord ID : '||l_eRecord_Id);
          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
          END IF;
        END IF;
      END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_spl_excp := 'Y';
         END IF ;

         IF l_eRecord_Id IS NOT NULL THEN

            -- Log EDR_EvidenceStore_PUB.Get_DocumentDetails is being called

              IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                  dbg_msg := ('Calling EDR_EvidenceStore_PUB.Get_DocumentDetails');
                  IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                  END IF;
                END IF;
              END IF;
            -- Get Document Details using the eRecord/Document Id.

            l_return_status := FND_API.G_RET_STS_SUCCESS;

            EDR_EvidenceStore_PUB.Get_DocumentDetails
               ( P_api_version           => 1.0,
                P_init_msg_list         => FND_API.G_TRUE,
                p_document_id           => l_eRecord_id,
                X_return_status         => l_return_status,
                X_msg_count             => l_msg_count,
                X_msg_data              => l_msg_data,
                x_document_rec          => l_document_rec,
                x_doc_parameters_tbl    => l_doc_param_table,
                x_signatures_tbl        => l_signatures_tbl) ;


                -- Log EDR_Standard_PUB.Get_ERecord_ID return status

                  IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                      dbg_msg := ('After Calling EDR_EvidenceStore_PUB.Get_DocumentDetails');
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                      dbg_msg := ('EDR_EvidenceStore_PUB.Get_DocumentDetails Return Status : '||l_return_status);
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                      dbg_msg := ('EDR_EvidenceStore_PUB.Get_DocumentDetails Sig Table Count : '||l_signatures_tbl.COUNT);
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                    END IF;
                  END IF;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   l_spl_excp := 'Y';
                END IF;

                IF l_signatures_tbl.COUNT > 0 THEN

                   -- Get signature details for each signature in the document details.
                   -- Retrive the signer's comment from the signature details.
                   -- Populate the each signer's comment to a note

                   -- Get the approval variables populated.

                    FND_MESSAGE.SET_NAME('CS','CS_ERES_SR_APPROVER_NAME');
                    l_approver := FND_MESSAGE.GET;
                    FND_MESSAGE.SET_NAME('CS','CS_ERES_SR_APPROVER_ACTION');
                    l_action   := FND_MESSAGE.GET;
                    FND_MESSAGE.SET_NAME('CS','CS_ERES_SR_APPROVER_COMMENT');
                    l_comment  := FND_MESSAGE.GET;
                    FND_MESSAGE.SET_NAME('CS','CS_ERES_SR_APPROVAL_RESULT');
                    l_note_title :=  FND_MESSAGE.GET;

                    -- Get the note type and status from the profile option

                    FND_PROFILE.Get('JTF_NTS_NOTE_STATUS',l_note_status);
                    FND_PROFILE.Get('CS_SR_ERES_COMMENT_NOTE_TYPE',l_note_type);

                    FOR i IN 1..l_signatures_tbl.COUNT
                       LOOP
                          -- Retrive the signer's comment from the signature details.

                          l_approver := l_approver||'  '||l_signatures_tbl(i).user_display_name||
                                                       ' ('||l_signatures_tbl(i).user_name||')';
                          l_action   := l_action||'  '||l_signatures_tbl(i).user_response;


                          -- Log EDR_EvidenceStore_PUB.GET_SignatureDetails is being called

                            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                              IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                dbg_msg := ('Calling EDR_EvidenceStore_PUB.GET_SignatureDetails');
                                IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                END IF;
                              END IF;
                            END IF;

                             l_return_status := FND_API.G_RET_STS_SUCCESS;

                             EDR_EvidenceStore_PUB.GET_SignatureDetails
                                ( P_api_version      => 1.0,
                                  P_init_msg_list    => FND_API.G_TRUE   ,
                                  P_signature_id     => l_signatures_tbl(i).signature_id,
                                  X_return_status    => l_return_status,
                                  X_msg_count        => l_msg_count,
                                  X_msg_data         => l_msg_data,
                                  X_SIGNATUREDETAILS => l_signatureDetails,
                                  X_SIGNATUREPARAMS  => l_Signatureparams ) ;


                              -- Log EDR_EvidenceStore_PUB.GET_SignatureDetails return status

                                IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                                  IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                    dbg_msg := ('After Calling EDR_EvidenceStore_PUB.GET_SignatureDetails');
                                    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                    END IF;
                                    dbg_msg := ('EDR_EvidenceStore_PUB.GET_SignatureDetails Return Status : '||l_return_status);
                                    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                    END IF;
                                    dbg_msg := ('EDR_EvidenceStore_PUB.GET_SignatureDetails Sig Param Table Count : '||l_Signatureparams.COUNT);
                                    IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                    END IF;
                                  END IF;
                                END IF;

                              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 null;
                              END IF ;

                              FOR j IN 1..l_Signatureparams.COUNT
                                 LOOP
                                     IF l_Signatureparams(j).param_name = 'SIGNERS_COMMENT' THEN
                                        --l_notes_table.extend;
                                        l_comment := l_comment||'  '||l_Signatureparams(j).param_value;
                                        l_note_detail := l_note_title||l_chr_newline||l_approver||l_chr_newline||
                                                         l_action||l_chr_newline||l_comment||l_chr_newline;

                                        l_notes_table(q).NOTE               := substr(l_note_detail,1,2000) ;
                                        l_notes_table(q).NOTE_DETAIL        := l_note_detail ;
                                        l_notes_table(q).NOTE_TYPE          := l_note_type;
                                        l_notes_table(q).NOTE_STATUS        := NVL(l_note_status,'I');
                                        l_notes_table(q).SOURCE_OBJECT_CODE := 'SR';
                                        l_notes_table(q).SOURCE_OBJECT_ID   := p_incident_id;
                                        q := q + 1 ;
                                     END IF ;
                                  END LOOP;
                       END LOOP;

                END IF ; -- signature_table.count

         END IF ;  -- l_ERecord_ID

         IF l_spl_excp = 'Y' THEN

            FND_MESSAGE.SET_NAME('CS','CS_ERES_SR_APPROVAL_RESULT');
            l_note_title :=  FND_MESSAGE.GET;

            -- Get the note type and status from the profile option

            FND_PROFILE.Get('JTF_NTS_NOTE_STATUS',l_note_status);
            FND_PROFILE.Get('CS_SR_ERES_COMMENT_NOTE_TYPE',l_note_type);

            l_notes_table(q).NOTE               := l_note_title||l_chr_newline ;
            l_notes_table(q).NOTE_DETAIL        := l_note_title||l_chr_newline||l_sig_status ;
            l_notes_table(q).NOTE_TYPE          := l_note_type;
            l_notes_table(q).NOTE_STATUS        := NVL(l_note_status,'I');
            l_notes_table(q).SOURCE_OBJECT_CODE := 'SR';
            l_notes_table(q).SOURCE_OBJECT_ID   := p_incident_id;
            q := q + 1 ;

         END IF;

         -- Get SR Version and lock the SR for update
            OPEN c_Get_SR_Version ;
           FETCH c_Get_SR_Version INTO l_sr_version,l_sr_status_id;

         -- Call Update Service Request API to update the SR Status and Create Notes

            -- Initialize the service request record.
               CS_ServiceRequest_PVT.Initialize_Rec(l_servicerequest_Rec);

               IF l_sr_status_id = p_intermediate_status_id THEN
                  l_servicerequest_Rec.status_id := l_target_status_id;
               END IF ;

               -- populate the program code = 'ERES'
                  l_servicerequest_Rec.last_update_program_code := 'ERES';

         -- If UpdateService Request API call fails then add additional note and
         -- update the service request status to the initial status


         -- Log CS_ServiceRequest_PVT.Update_ServiceRequest is being called

            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                dbg_msg := ('Calling CS_ServiceRequest_PVT.Update_ServiceRequest (1)');
                IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                END IF;
              END IF;
            END IF;

            l_return_status := FND_API.G_RET_STS_SUCCESS ;

            CS_ServiceRequest_PVT.Update_ServiceRequest
               ( p_api_version                 => 4.0,
                 x_return_status               => l_return_status,
                 x_msg_count                   => l_msg_count,
                 x_msg_data                    => l_msg_data,
                 p_request_id                  => p_incident_id,
                 p_audit_id                    => null,
                 p_object_version_number       => l_sr_version,
                 p_last_updated_by             => fnd_global.user_id,
                 p_last_update_date            => sysdate,
                 p_service_request_rec         => l_servicerequest_Rec,
                 p_notes                       => l_notes_table_dummy,
                 p_contacts                    => l_contacts_table,
                 p_validate_sr_closure         => NVL(l_validate_sr_close,'N'),
                 p_auto_close_child_entities   => NVL(l_validate_sr_close,'N'),
                 x_sr_update_out_rec           => l_sr_update_out_rec );



             -- Log CS_ServiceRequest_PVT.Update_ServiceRequest return status

               IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                   dbg_msg := ('After Calling CS_ServiceRequest_PVT.Update_ServiceRequest');
                   IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                   END IF;
                   dbg_msg := ('CS_ServiceRequest_PVT.Update_ServiceRequest Return Status : '||l_return_status);
                   IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                   END IF;
                 END IF;
               END IF;

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

               IF l_note_type IS NOT NULL THEN

                  -- Log JTF_NOTES_PUB API is being called to create notes for signer's comments.

                     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                        dbg_msg := ('Calling JTF_NOTES_PUB.Create_Note (1)');
                        IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                        END IF;
                      END IF;
                    END IF;

                    FOR k IN 1..l_notes_table.COUNT
                        LOOP
                           l_note_id := NULL;
                           l_return_status := FND_API.G_RET_STS_SUCCESS ;

                           JTF_Notes_PUB.Create_Note
                           ( p_api_version           => 1.0
                           , p_init_msg_list         => fnd_api.g_false
                           , p_commit                => fnd_api.g_false
                           , p_validation_level      => fnd_api.g_valid_level_full
                           , p_source_object_id      => p_incident_id
                           , p_source_object_code    => 'SR'
                           , p_notes                 => l_notes_table(k).note
                           , p_notes_detail          => l_notes_table(k).note_detail
                           , p_note_status           => NVL(l_note_status,'I')
                           , p_entered_by            => fnd_global.user_id
                           , p_entered_date          => sysdate
                           , p_last_update_date      => sysdate
                           , p_last_updated_by       => fnd_global.user_id
                           , p_creation_date         => sysdate
                           , p_created_by            => fnd_global.user_id
                           , p_last_update_login     => fnd_global.login_id
                           , p_note_type             => l_note_type
                           , x_return_status         => l_return_status
                           , x_msg_count             => l_msg_count
                           , x_msg_data              => l_msg_data
                           , x_jtf_note_id           => l_note_id );


                           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                             IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                               dbg_msg := ('After Calling JTF_Notes_PUB.Create API (1)');
                               IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                               END IF;
                               dbg_msg := ('JTF_Notes_PUB.Create API Return Status (1) : '||l_return_status ||' Note Id : '||l_note_id);
                               IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                               END IF;
                             END IF;
                           END IF;

                          -- if JTF API errors out then do not raise any errors

                            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                               --Get all the error messages and add error messages to the note

                               IF (FND_MSG_PUB.Count_Msg > 1) THEN
                                   FOR j in  1..FND_MSG_PUB.Count_Msg
                                      LOOP
                                         FND_MSG_PUB.Get(
                                             p_msg_index     => j,
                                             p_encoded       => 'F',
                                             p_data          => lx_msg_data,
                                             p_msg_index_out => lx_msg_index_out);

                                         l_note_text := l_note_text||' - '||lx_msg_data;
                                       END LOOP;
                                  -- Log the error message returned by the SR Update API

                                     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                                       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                          dbg_msg := ('Create Notes (1) JTF API Error ');
                                          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                          END IF;
                                          dbg_msg := ('Error : '||l_note_text);
                                          IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                          END IF;
                                       END IF;
                                     END IF;
                               ELSE
                                    --Only one error
                                   FND_MSG_PUB.Get(
                                      p_msg_index     => 1,
                                      p_encoded       => 'F',
                                      p_data          => lx_msg_data,
                                      p_msg_index_out => lx_msg_index_out);

                                      l_note_text := l_note_text||l_chr_newline||lx_msg_data;

                                   -- Log the error message returned by the SR Update API

                                      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                                        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                           dbg_msg := ('Create Notes(1) JTF API Error ');
                                           IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                           END IF;
                                           dbg_msg := ('Error : '||l_note_text);
                                           IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                           END IF;
                                        END IF;
                                      END IF;
                               END IF ; -- fnd_msg_pub

                            END IF ;

                        END LOOP;

               END IF ;

               -- Log EDR_TRANS_ACKN_PUB.SEND_ACKN is being called

                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                   IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                     dbg_msg := ('Calling EDR_TRANS_ACKN_PUB.SEND_ACKN');
                     IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                     END IF;
                   END IF;
                 END IF;

               -- Send an EDR acknowledgement.
                l_return_status := FND_API.G_RET_STS_SUCCESS ;

                EDR_TRANS_ACKN_PUB.SEND_ACKN
                    ( p_api_version          	=> 1.0,
                      p_init_msg_list        	=> FND_API.G_TRUE   ,
                      x_return_status        	=> l_return_status,
                      x_msg_count            	=> l_msg_count,
                      x_msg_data             	=> l_msg_data,
                      p_event_name           	=> 'oracle.apps.cs.sr.ServiceRequesstApproval',
                      p_event_key            	=> p_incident_id,
                      p_ERECord_id           	=> l_ERECORD_ID,
                      p_trans_status         	=> 'SUCCESS',
                      p_ackn_by              	=> 'Service Request Approval Process',
                      p_ackn_note            	=> 'Service Request Approval Completed',
                      p_autonomous_commit     => FND_API.G_FALSE   );


                -- Log EDR_TRANS_ACKN_PUB.SEND_ACKN return status

                  IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                      dbg_msg := ('After Calling EDR_TRANS_ACKN_PUB.SEND_ACKN');
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                      dbg_msg := ('EDR_TRANS_ACKN_PUB.SEND_ACKN Return Status : '||l_return_status);
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                    END IF;
                  END IF;

                CLOSE c_Get_SR_Version ;
            ELSE

               -- Updating SR to the target status has failed.
               -- Additional note about this failure should be created and SR should be updated
               -- to the previous status.

                  -- Populate note details
                     IF l_sig_status = 'APPROVED' THEN
                        fnd_message.set_name ('CS', 'CS_SR_ERES_APPROVED');
                        l_note_text :=  fnd_message.get;
                     ELSIF l_sig_status = 'REJECTED' THEN
                        fnd_message.set_name ('CS', 'CS_SR_ERES_REJECTED');
                        l_note_text :=  fnd_message.get;
                     END IF ;

                  -- Add a note that an error encountered while ERES processing.

                     fnd_message.set_name ('CS','CS_ERES_ERROR_COMMENT_MSG');
                        l_note_err_msg := fnd_message.get;
                        l_note_text := l_note_text||l_chr_newline||l_note_err_msg||l_chr_newline;

                  --Get all the error messages and add error messages to the note

                     IF (FND_MSG_PUB.Count_Msg > 1) THEN
                         FOR j in  1..FND_MSG_PUB.Count_Msg
   			    LOOP
                               FND_MSG_PUB.Get(
                                   p_msg_index     => j,
                                   p_encoded       => 'F',
                                   p_data          => lx_msg_data,
                                   p_msg_index_out => lx_msg_index_out);

                               l_note_text := l_note_text||lx_msg_data;
                             END LOOP;
                        -- Log the error message returned by the SR Update API

                           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                             IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                dbg_msg := ('Update Service Request(1) API Error ');
                                IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                END IF;
                                dbg_msg := ('Error : '||l_note_text);
                                IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                END IF;
                             END IF;
                           END IF;
                     ELSE
                          --Only one error
                         FND_MSG_PUB.Get(
                            p_msg_index     => 1,
                            p_encoded       => 'F',
                            p_data          => lx_msg_data,
                            p_msg_index_out => lx_msg_index_out);

                            l_note_text := l_note_text||l_chr_newline||lx_msg_data;

                         -- Log the error message returned by the SR Update API

                            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                              IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                 dbg_msg := ('Update Service Request(1) API Error ');
                                 IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                 END IF;
                                 dbg_msg := ('Error : '||l_note_text);
                                 IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                 END IF;
                              END IF;
                            END IF;
                     END IF;

                      --l_notes_table.extend;
                      l_notes_table(q).NOTE               := l_note_text;
                      l_notes_table(q).NOTE_DETAIL        := l_note_text;
                      l_notes_table(q).NOTE_TYPE          := l_note_type;
                      l_notes_table(q).NOTE_STATUS        := NVL(l_note_status,'I');
                      l_notes_table(q).SOURCE_OBJECT_CODE := 'SR';
                      l_notes_table(q).SOURCE_OBJECT_ID   := p_incident_id;
                      q := q + 1 ;

                -- Log Get_Target_SR_Status is being called

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                       dbg_msg := ('Calling Get_Target_SR_Status (2)');
                       IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                       END IF;
                     END IF;
                   END IF;

                -- Get the initial status of the service request.

                   l_return_status := FND_API.G_RET_STS_SUCCESS;

                   Get_Target_SR_Status
                      ( P_Incident_Id              => P_Incident_id,
                        P_Intermediate_Status_Id   => P_Intermediate_Status_Id,
                        P_Action                   => 'ERROR' ,
                        X_Target_Status_Id         => l_target_status_id,
                        X_Return_Status            => l_return_status,
                        X_Msg_count                => l_msg_count ,
                        X_Msg_data                 => l_msg_data );


                -- Log Get_Target_SR_Status return status

                  IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                      dbg_msg := ('After Calling Get_Target_SR_Status (2)');
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                      dbg_msg := ('Get_Target_SR_Status Return Status : '||l_return_status);
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                      dbg_msg := ('Get_Target_SR_Status Target Status ID : '||l_target_status_id);
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                    END IF;
                  END IF;

                -- Log CS_ServiceRequest_PVT.Update_ServiceRequest is being called

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                       dbg_msg := ('Calling CS_ServiceRequest_PVT.Update_ServiceRequest (2)');
                       IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                       END IF;
                     END IF;
                   END IF;

                -- call update service request api to update the service request to the initial status.

                   l_servicerequest_Rec.status_id := l_target_status_id;
                   l_return_status := FND_API.G_RET_STS_SUCCESS ;


                   CS_ServiceRequest_PVT.Update_ServiceRequest
                      ( p_api_version                 => 4.0,
                        x_return_status               => l_return_status,
                        x_msg_count                   => l_msg_count,
                        x_msg_data                    => l_msg_data,
                        p_request_id                  => p_incident_id,
                        p_audit_id                    => null,
                        p_object_version_number       => l_sr_version,
                        p_last_updated_by             => fnd_global.user_id,
                        p_last_update_date            => sysdate,
                        p_service_request_rec         => l_servicerequest_Rec,
                        p_notes                       => l_notes_table_dummy,
                        p_contacts                    => l_contacts_table,
                        p_validate_sr_closure         => NVL(l_validate_sr_close,'N'),
                        p_auto_close_child_entities   => NVL(l_validate_sr_close,'N'),
                        x_sr_update_out_rec           => l_sr_update_out_rec );

                -- Log CS_ServiceRequest_PVT.Update_ServiceRequest return status

                  IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                      dbg_msg := ('After Calling CS_ServiceRequest_PVT.Update_ServiceRequest (2)');
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                      dbg_msg := ('CS_ServiceRequest_PVT.Update_ServiceRequest Return Status : '||l_return_status);
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                    END IF;
                  END IF;

                  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

                     IF l_note_type IS NOT NULL THEN

                        -- Log JTF_NOTES_PUB API is being called to create notes for signer's comments.

                           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                              dbg_msg := ('Calling JTF_NOTES_PUB.Create_Note (2)');
                              IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                              END IF;
                            END IF;
                          END IF;

                          FOR k IN 1..l_notes_table.COUNT
                              LOOP
                                 l_note_id := NULL;
                                 l_return_status := FND_API.G_RET_STS_SUCCESS;

                                 JTF_Notes_PUB.Create_Note
                                 ( p_api_version           => 1.0
                                 , p_init_msg_list         => fnd_api.g_false
                                 , p_commit                => fnd_api.g_false
                                 , p_validation_level      => fnd_api.g_valid_level_full
                                 , p_source_object_id      => p_incident_id
                                 , p_source_object_code    => 'SR'
                                 , p_notes                 => l_notes_table(k).note
                                 , p_notes_detail          => l_notes_table(k).note_detail
                                 , p_note_status           => NVL(l_note_status,'I')
                                 , p_entered_by            => fnd_global.user_id
                                 , p_entered_date          => sysdate
                                 , p_last_update_date      => sysdate
                                 , p_last_updated_by       => fnd_global.user_id
                                 , p_creation_date         => sysdate
                                 , p_created_by            => fnd_global.user_id
                                 , p_last_update_login     => fnd_global.login_id
                                 , p_note_type             => l_note_type
                                 , x_return_status         => l_return_status
                                 , x_msg_count             => l_msg_count
                                 , x_msg_data              => l_msg_data
                                 , x_jtf_note_id           => l_note_id );


                                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                                   IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                     dbg_msg := ('After Calling JTF_Notes_PUB.Create API (2)');
                                     IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                     END IF;
                                     dbg_msg := ('JTF_Notes_PUB.Create API Return Status (2) : '||l_return_status ||' Note Id : '||l_note_id);
                                     IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                     END IF;
                                   END IF;
                                 END IF;

                                -- if JTF API errors out then do not raise any errors

                                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                     --Get all the error messages and add error messages to the note

                                     IF (FND_MSG_PUB.Count_Msg > 1) THEN
                                         FOR j in  1..FND_MSG_PUB.Count_Msg
                                            LOOP
                                               FND_MSG_PUB.Get(
                                                   p_msg_index     => j,
                                                   p_encoded       => 'F',
                                                   p_data          => lx_msg_data,
                                                   p_msg_index_out => lx_msg_index_out);

                                               l_note_text := l_note_text||' - '||lx_msg_data;
                                             END LOOP;
                                        -- Log the error message returned by the SR Update API

                                           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                                             IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                                dbg_msg := ('Create Notes (2) JTF API Error ');
                                                IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                                END IF;
                                                dbg_msg := ('Error : '||l_note_text);
                                                IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                                END IF;
                                             END IF;
                                           END IF;
                                     ELSE
                                          --Only one error
                                         FND_MSG_PUB.Get(
                                            p_msg_index     => 1,
                                            p_encoded       => 'F',
                                            p_data          => lx_msg_data,
                                            p_msg_index_out => lx_msg_index_out);

                                            l_note_text := l_note_text||l_chr_newline||lx_msg_data;

                                         -- Log the error message returned by the SR Update API

                                            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                                              IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                                                 dbg_msg := ('Create Notes(2) JTF API Error ');
                                                 IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                                 END IF;
                                                 dbg_msg := ('Error : '||l_note_text);
                                                 IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                                                 END IF;
                                              END IF;
                                            END IF;
                                     END IF ; -- fnd_msg_pub
                                  END IF ;
                              END LOOP;

                     END IF ; -- end if for the note_type check

                  END IF ; -- End if for the return status of the Update SR call (2)


               -- Log EDR_TRANS_ACKN_PUB.SEND_ACKN is being called

                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                   IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                     dbg_msg := ('Calling EDR_TRANS_ACKN_PUB.SEND_ACKN (3)');
                     IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                     END IF;
                   END IF;
                 END IF;

               -- Send an EDR acknowledgement.

                  l_return_status := FND_API.G_RET_STS_SUCCESS;

                  EDR_TRANS_ACKN_PUB.SEND_ACKN
                      ( p_api_version         => 1.0,
                        p_init_msg_list       => FND_API.G_TRUE   ,
                        x_return_status       => l_return_status,
                        x_msg_count           => l_msg_count,
                        x_msg_data            => l_msg_data,
                        p_event_name          => 'oracle.apps.cs.sr.ServiceRequesstApproval',
                        p_event_key           => p_incident_id,
                        p_ERECord_id          => l_ERECORD_ID,
                        p_trans_status        => 'SUCCESS',
                        p_ackn_by             => 'Service Request Approval Process',
                        p_ackn_note           => 'Service Request Approval Completed',
                        p_autonomous_commit   => FND_API.G_FALSE   );

                -- Log EDR_TRANS_ACKN_PUB.SEND_ACKN return status

                  IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process')) THEN
                      dbg_msg := ('After Calling EDR_TRANS_ACKN_PUB.SEND_ACKN');
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                      dbg_msg := ('EDR_TRANS_ACKN_PUB.SEND_ACKN Return Status : '||l_return_status);
                      IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_ERES_INT_PKG.Post_Approval_Process', dbg_msg);
                      END IF;
                    END IF;
                  END IF;
                  CLOSE c_Get_SR_Version ;

         END IF ;

EXCEPTION
  WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('CS','CS_ERES_CALLBACK_API_FAILED');
       FND_MESSAGE.SET_TOKEN ('P_SQLCODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN ('P_SQLERRM',SQLERRM);
       FND_MSG_PUB.ADD;
       RAISE;

END Post_Approval_Process ;

PROCEDURE Get_Target_SR_Status
 ( P_Incident_Id              IN        NUMBER,
   P_Intermediate_Status_Id   IN        NUMBER,
   P_Action                   IN        VARCHAR2,
   X_Target_Status_Id        OUT NOCOPY NUMBER,
   X_Return_Status           OUT NOCOPY VARCHAR2,
   X_Msg_count               OUT NOCOPY NUMBER,
   X_Msg_data                OUT NOCOPY NUMBER)  IS

 -- Cursor to get the target status using status definition setup.

    CURSOR c_get_target_status IS
       SELECT incident_status_id ,
              approval_action_status_id ,
              rejection_action_status_id
         FROM cs_incident_statuses a
        WHERE a.intermediate_status_id = P_Intermediate_Status_Id;

 -- Cursor to get the target status using SR audit.

    CURSOR c_get_initial_status IS
    SELECT old_incident_status_id
      FROM cs_incidents_audit_b
     WHERE rowid = ( SELECT max(rowid)
                       FROM cs_incidents_audit_b
                      WHERE incident_id 	    = p_incident_id
                        AND incident_status_id      = p_intermediate_status_id
                        AND old_incident_status_id <> p_intermediate_status_id
                      GROUP BY incident_id , incident_status_id);

 -- Local Variables

    l_status_id              NUMBER;
    l_approved_status_id     NUMBER;
    l_rejected_status_id     NUMBER;
    l_initial_status_id      NUMBER;

BEGIN
    IF p_action = 'ERROR' THEN

       OPEN c_get_initial_status ;
      FETCH c_get_initial_status INTO l_initial_status_id;
      CLOSE c_get_initial_status;

      X_Target_Status_Id := l_initial_status_id;
    ELSE
       OPEN c_get_target_status ;
      FETCH c_get_target_status INTO l_status_id,l_approved_status_id,l_rejected_status_id;
      CLOSE c_get_target_status ;

       IF p_action = 'SUCCESS' THEN
          IF l_approved_status_id IS NOT NULL THEN
             X_Target_Status_Id := l_approved_status_id;
          ELSE
             X_Target_Status_Id := l_status_id;
          END IF ;
       ELSIF p_action IN ('REJECTED','TIMEOUT') THEN
          IF l_rejected_status_id IS NOT NULL THEN
             X_Target_Status_Id := l_rejected_status_id;
          ELSE
             OPEN c_get_initial_status ;
            FETCH c_get_initial_status INTO l_initial_status_id;
            CLOSE c_get_initial_status;

             X_Target_Status_Id := l_initial_status_id;

          END IF ;
       END IF ;
    END IF ;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('CS','CS_ERES_INVLD_INTMED_STS');
    FND_MSG_PUB.ADD;
    RAISE;
END Get_Target_SR_Status ;

END CS_ERES_INT_PKG;

/
