--------------------------------------------------------
--  DDL for Package Body XNP_XDP_PERF_BM_EVT_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_XDP_PERF_BM_EVT_U" AS 
PROCEDURE CREATE_MSG  (   x_msg_header OUT  XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  x_msg_text   OUT  VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message OUT VARCHAR2,
  p_sender_name IN VARCHAR2 DEFAULT NULL,
  p_recipient_list IN VARCHAR2 DEFAULT NULL,
  p_version IN NUMBER DEFAULT 1,
  p_reference_id IN VARCHAR2 DEFAULT NULL,
  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,
  p_order_id IN NUMBER DEFAULT NULL,
  p_wi_instance_id  IN NUMBER DEFAULT NULL,
  p_fa_instance_id  IN NUMBER  DEFAULT NULL,
  p_delay  IN NUMBER  DEFAULT NULL,
  p_interval  IN NUMBER  DEFAULT NULL )  IS
  e_MISSING_MANDATORY_DATA EXCEPTION ;
  e_NO_DESTINATION EXCEPTION ;
  l_xml_body VARCHAR2(32767) ;
  l_xml_doc  VARCHAR2(32767) ;
  l_xml_header VARCHAR2(32767) ;
  l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
  XNP$SUBSCRIPTION_TN   VARCHAR2( 16000) ;
  XNP$CUSTOMER_NAME   VARCHAR2( 16000) ;
  XNP$ADDRESS_LINE1   VARCHAR2( 16000) ;
  XNP$ADDRESS_LINE2   VARCHAR2( 16000) ;
  XNP$CITY   VARCHAR2( 16000) ;
  XNP$ZIP_CODE   VARCHAR2( 16000) ;
  XNP$SERVICE_TYPE   VARCHAR2( 16000) ;
  XNP$STATUS   VARCHAR2( 16000) ;
  XNP$CUSTOMER_TYPE   VARCHAR2( 16000) ;
  XNP$FEATURE_TYPE   VARCHAR2( 16000) ;
BEGIN
  x_error_code := 0 ;
  x_error_message := NULL ;
  XNP_XML_UTILS.initialize_doc ( ) ;
/*construct the XML header */
/* retreive the next message ID */
  XNP_MESSAGE.get_sequence ( l_msg_header.message_id ) ;
  IF (p_reference_id IS NULL) THEN
    l_msg_header.reference_id := l_msg_header.message_id ;
  ELSE
    l_msg_header.reference_id := p_reference_id ;
  END IF ;
/* append header parameters to make header */
  XNP_XML_UTILS.write_element ( 'MESSAGE_ID',l_msg_header.message_id ) ;
  XNP_XML_UTILS.write_leaf_element ( 'REFERENCE_ID',l_msg_header.reference_id ) ;
  l_msg_header.opp_reference_id := p_opp_reference_id ;
  XNP_XML_UTILS.write_leaf_element ( 'OPP_REFERENCE_ID',l_msg_header.opp_reference_id ) ;
  l_msg_header.message_code := 'XDP_PERF_BM_EVT' ;
  XNP_XML_UTILS.write_leaf_element ( 'MESSAGE_CODE',l_msg_header.message_code ) ;
  l_msg_header.version := p_version ;
  XNP_XML_UTILS.write_leaf_element ( 'VERSION',l_msg_header.version ) ;
  l_msg_header.creation_date := SYSDATE ;
  l_msg_header.recipient_name := p_recipient_list ;
  XNP_XML_UTILS.write_element ( 'CREATION_DATE',l_msg_header.creation_date ) ;
  l_msg_header.sender_name := p_sender_name ;
  XNP_XML_UTILS.write_leaf_element ( 'SENDER_NAME',l_msg_header.sender_name ) ;
  XNP_XML_UTILS.write_leaf_element ( 'RECIPIENT_NAME',l_msg_header.recipient_name ) ;
  l_msg_header.direction_indr := 'E' ;
  l_msg_header.order_id := p_order_id ;
  l_msg_header.wi_instance_id := p_wi_instance_id ;
  l_msg_header.fa_instance_id := p_fa_instance_id ;
/* retreieve the XML header */
  XNP_XML_UTILS.get_document ( l_xml_header ) ;
/* append the XML headerto message */
  XNP_XML_UTILS.initialize_doc ( ) ;
  XNP_XML_UTILS.xml_decl ;
  XNP_XML_UTILS.begin_segment ( 'MESSAGE') ;
  XNP_XML_UTILS.write_element( 'HEADER', l_xml_header );
/* construct the message body */
    XNP_XML_UTILS.begin_segment ( 'XDP_PERF_BM_EVT' ) ;
    BEGIN
    XNP$SUBSCRIPTION_TN := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'SUBSCRIPTION_TN' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','SUBSCRIPTION_TN' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$SUBSCRIPTION_TN IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','SUBSCRIPTION_TN' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'SUBSCRIPTION_TN', XNP$SUBSCRIPTION_TN ) ;
    BEGIN
    XNP$CUSTOMER_NAME := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'CUSTOMER_NAME' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','CUSTOMER_NAME' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$CUSTOMER_NAME IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','CUSTOMER_NAME' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'CUSTOMER_NAME', XNP$CUSTOMER_NAME ) ;
    BEGIN
    XNP$ADDRESS_LINE1 := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'ADDRESS_LINE1' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','ADDRESS_LINE1' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$ADDRESS_LINE1 IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','ADDRESS_LINE1' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'ADDRESS_LINE1', XNP$ADDRESS_LINE1 ) ;
    BEGIN
    XNP$ADDRESS_LINE2 := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'ADDRESS_LINE2' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','ADDRESS_LINE2' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$ADDRESS_LINE2 IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','ADDRESS_LINE2' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'ADDRESS_LINE2', XNP$ADDRESS_LINE2 ) ;
    BEGIN
    XNP$CITY := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'CITY' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','CITY' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$CITY IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','CITY' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'CITY', XNP$CITY ) ;
    BEGIN
    XNP$ZIP_CODE := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'ZIP_CODE' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','ZIP_CODE' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$ZIP_CODE IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','ZIP_CODE' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'ZIP_CODE', XNP$ZIP_CODE ) ;
    BEGIN
    XNP$SERVICE_TYPE := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'SERVICE_TYPE' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','SERVICE_TYPE' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$SERVICE_TYPE IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','SERVICE_TYPE' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'SERVICE_TYPE', XNP$SERVICE_TYPE ) ;
    BEGIN
    XNP$STATUS := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'STATUS' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','STATUS' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$STATUS IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','STATUS' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'STATUS', XNP$STATUS ) ;
    BEGIN
    XNP$CUSTOMER_TYPE := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'CUSTOMER_TYPE' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','CUSTOMER_TYPE' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$CUSTOMER_TYPE IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','CUSTOMER_TYPE' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'CUSTOMER_TYPE', XNP$CUSTOMER_TYPE ) ;
    BEGIN
    XNP$FEATURE_TYPE := XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, 
    'FEATURE_TYPE' );
      EXCEPTION WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('XNP', 'XNP_WI_DATA_NOT_FOUND' );
       fnd_message.set_token( 'PARAMETER','FEATURE_TYPE' ) ;
      x_error_message := fnd_message.get ; 
    END;
    IF ( XNP$FEATURE_TYPE IS NULL) THEN
       fnd_message.set_name('XNP', 'XNP_MISSING_MANDATORY_ATTR' );
       fnd_message.set_token( 'ATTRIBUTE','FEATURE_TYPE' ) ;
      x_error_message := fnd_message.get ; 
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_leaf_element ( 'FEATURE_TYPE', XNP$FEATURE_TYPE ) ;
    XNP_XML_UTILS.end_segment ( 'XDP_PERF_BM_EVT' ) ;
  XNP_XML_UTILS.end_segment ( 'MESSAGE') ;
  XNP_XML_UTILS.get_document( l_xml_doc ) ;
/* assign the header and msg text to output parameters */
  x_msg_header := l_msg_header ;
  x_msg_text   := l_xml_doc ;
/* handle exceptions */
  EXCEPTION
  WHEN e_MISSING_MANDATORY_DATA THEN
    x_error_code := XNP_ERRORS.G_MISSING_MANDATORY_DATA ;
  WHEN OTHERS THEN
    x_error_code := SQLCODE ;
    x_error_message := 'XDP_PERF_BM_EVT.create_msg()::' || SQLERRM ;
END ;
PROCEDURE PUBLISH  (   x_message_id OUT  NUMBER,
  x_error_code OUT  NUMBER,
  x_error_message OUT VARCHAR2,  
  p_consumer_list IN VARCHAR2 DEFAULT NULL,  
  p_sender_name IN VARCHAR2 DEFAULT NULL,  
  p_recipient_list IN VARCHAR2 DEFAULT NULL,
  p_version IN NUMBER DEFAULT 1,
  p_reference_id IN VARCHAR2 DEFAULT NULL,
  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,
  p_order_id IN NUMBER DEFAULT NULL,
  p_wi_instance_id  IN NUMBER DEFAULT NULL,
  p_fa_instance_id  IN NUMBER  DEFAULT NULL )  IS
  e_NO_DESTINATION EXCEPTION ;
  l_recipient_list VARCHAR2 (2000) ;
  l_consumer_list VARCHAR2 (4000) ;
  l_queue_name VARCHAR2 (2000) ;
  l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;
  l_msg_text VARCHAR2(32767) ;
BEGIN
  x_error_code := 0 ;
  x_error_message := NULL ;
/* check if the consumer list is NULL */
  l_consumer_list := p_consumer_list ;
  IF (l_consumer_list IS NULL) THEN
    XNP_MESSAGE.GET_SUBSCRIBER_LIST( 'XDP_PERF_BM_EVT', l_consumer_list );
  END IF;
  l_recipient_list := p_recipient_list ;
l_queue_name := 'XNP_IN_EVT_Q';
/* create the XML message */
  CREATE_MSG (
    x_msg_header=>l_msg_header,
    x_msg_text=>l_msg_text,
    x_error_code=>x_error_code,
    x_error_message=>x_error_message,
    p_sender_name=>p_sender_name,
    p_recipient_list=>l_recipient_list,
    p_version=>p_version,
    p_reference_id=>p_reference_id,
    p_opp_reference_id=>p_opp_reference_id,
    p_order_id=>p_order_id,
    p_wi_instance_id=>p_wi_instance_id,
    p_fa_instance_id=>p_fa_instance_id ) ;
  x_message_id := l_msg_header.message_id ;
/* enqueue the XML message for delivery */
  IF (x_error_code = 0) THEN
    XNP_MESSAGE.push ( 
      p_msg_header => l_msg_header, 
      p_body_text => l_msg_text, 
      p_queue_name => xnp_event.c_internal_evt_q, 
      p_correlation_id => l_msg_header.message_code, 
      p_priority=>'3', 
      p_commit_mode => XNP_MESSAGE.C_ON_COMMIT ); 
    IF (l_consumer_list IS NOT NULL) THEN
      XNP_MESSAGE.GET_SEQUENCE(l_msg_header.message_id) ;
      l_msg_header.direction_indr := 'O';
      XNP_MESSAGE.push ( 
        p_msg_header => l_msg_header, 
        p_body_text => l_msg_text, 
      p_queue_name => xnp_event.c_outbound_msg_q, 
        p_recipient_list => l_consumer_list, 
      p_correlation_id => l_msg_header.message_code, 
        p_priority=>'3' ) ; 
    END IF ;
/* out processing logic */
  END IF ;
EXCEPTION
  WHEN e_NO_DESTINATION THEN
    x_error_code := XNP_ERRORS.G_NO_DESTINATION ;
  WHEN OTHERS THEN
    x_error_code := SQLCODE ;
    x_error_message := SQLERRM ;
END ;
PROCEDURE SEND  (   x_message_id OUT  NUMBER,
  x_error_code OUT  NUMBER,
  x_error_message OUT VARCHAR2,  
  p_consumer_name  IN VARCHAR2,  
  p_sender_name  IN VARCHAR2 DEFAULT NULL,  
  p_recipient_name  IN VARCHAR2 DEFAULT NULL,  
  p_version  IN NUMBER DEFAULT 1,  
  p_reference_id IN VARCHAR2 DEFAULT NULL,
  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,
  p_order_id IN NUMBER DEFAULT NULL,
  p_wi_instance_id  IN NUMBER DEFAULT NULL,
  p_fa_instance_id  IN NUMBER  DEFAULT NULL )  IS
l_recipient_name  VARCHAR2(80);
BEGIN
  x_error_code := 0;
  x_error_message := NULL ;
  l_recipient_name := p_recipient_name ;
  IF (l_recipient_name IS NULL) THEN
    l_recipient_name := p_consumer_name ;
  END IF;
  PUBLISH (
    x_message_id=>x_message_id,
    x_error_code=>x_error_code,
    x_error_message=>x_error_message,
    p_consumer_list=>p_consumer_name,
    p_sender_name=>p_sender_name,
    p_recipient_list=>l_recipient_name,
    p_version=>p_version,
    p_reference_id=>p_reference_id,
    p_opp_reference_id=>p_opp_reference_id,
    p_order_id=>p_order_id,
    p_wi_instance_id=>p_wi_instance_id,
    p_fa_instance_id=>p_fa_instance_id ) ;
END ;
PROCEDURE PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2,
  p_process_reference IN VARCHAR2 DEFAULT NULL ) IS
BEGIN
NULL ;
END ;
PROCEDURE DEFAULT_PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2 )  IS
BEGIN
NULL ;
END ;
PROCEDURE VALIDATE (    p_msg_header IN OUT XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2 )  IS
BEGIN
NULL ;
END ;
 
 END XNP_XDP_PERF_BM_EVT_U;

/
