--------------------------------------------------------
--  DDL for Package Body XNP_SYNC_ERR_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_SYNC_ERR_U" AS
/* $Header: XNPSYERB.pls 120.2 2006/02/13 07:54:48 dputhiye ship $*/
PROCEDURE CREATE_MSG  (   XNP$SYNC_LABEL VARCHAR2,
  XNP$SDP_RESULT_CODE VARCHAR2 DEFAULT NULL,
  x_msg_header OUT NOCOPY  XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  x_msg_text   OUT NOCOPY  VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message OUT NOCOPY VARCHAR2,
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
BEGIN
  x_error_code := 0 ;
  x_error_message := NULL ;
  XNP_XML_UTILS.initialize_doc ( ) ;
/* construct the message body */
    XNP_XML_UTILS.begin_segment ( 'SYNC_ERR' ) ;
    IF ( XNP$SYNC_LABEL IS NULL) THEN
      x_error_message :='Missing Mandatory Attribute - SYNC_LABEL' ;
      RAISE e_MISSING_MANDATORY_DATA ;
    END IF ;
    XNP_XML_UTILS.write_element ( 'SYNC_LABEL', XNP$SYNC_LABEL ) ;
  XNP_XML_UTILS.end_segment ( 'SYNC_ERR' ) ;
/* get the message body */
  XNP_XML_UTILS.get_document ( l_xml_body ) ;
IF (l_xml_body IS NULL) THEN
  XNP_XML_UTILS.write_element('SYNC_ERR',l_xml_body );
  XNP_XML_UTILS.get_document( l_xml_body ) ;
END IF;
/* initialize the XML header variable */
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
  XNP_XML_UTILS.write_element ( 'REFERENCE_ID',l_msg_header.reference_id ) ;
  l_msg_header.opp_reference_id := p_opp_reference_id ;
  XNP_XML_UTILS.write_element ( 'OPP_REFERENCE_ID',l_msg_header.opp_reference_id ) ;
  l_msg_header.message_code := 'SYNC_ERR' ;
  XNP_XML_UTILS.write_element ( 'MESSAGE_CODE',l_msg_header.message_code ) ;
  l_msg_header.version := p_version ;
  XNP_XML_UTILS.write_element ( 'VERSION',l_msg_header.version ) ;
  l_msg_header.creation_date := SYSDATE ;
  l_msg_header.recipient_name := p_recipient_list ;
  XNP_XML_UTILS.write_element ( 'CREATION_DATE',l_msg_header.creation_date ) ;
  l_msg_header.sender_name := p_sender_name ;
  XNP_XML_UTILS.write_element ( 'SENDER_NAME',l_msg_header.sender_name ) ;
  XNP_XML_UTILS.write_element ( 'RECIPIENT_NAME',l_msg_header.recipient_name ) ;
  l_msg_header.direction_indr := 'E' ;
  l_msg_header.order_id := p_order_id ;
  l_msg_header.wi_instance_id := p_wi_instance_id ;
  l_msg_header.fa_instance_id := p_fa_instance_id ;
  XNP_XML_UTILS.write_element ( 'SYNC_LABEL', XNP$SYNC_LABEL );
  XNP_XML_UTILS.write_element ( 'SDP_RESULT_CODE', XNP$SDP_RESULT_CODE );
/* retreieve the XML header */
  XNP_XML_UTILS.get_document ( l_xml_header ) ;
/* append the XML headerto message */
  XNP_XML_UTILS.initialize_doc ( ) ;
  XNP_XML_UTILS.xml_decl ;
  XNP_XML_UTILS.begin_segment ( 'MESSAGE') ;
  XNP_XML_UTILS.write_element( 'HEADER', l_xml_header );
  XNP_XML_UTILS.append ( l_xml_body ) ;
  XNP_XML_UTILS.end_segment ( 'MESSAGE') ;
  XNP_XML_UTILS.get_document( l_xml_doc ) ;
/* assign the header and msg text to output parameters */
  x_msg_header := l_msg_header ;
  x_msg_text := l_xml_doc ;
/* handle exceptions */
  EXCEPTION
  WHEN e_MISSING_MANDATORY_DATA THEN
    x_error_code := XNP_ERRORS.G_MISSING_MANDATORY_DATA ;
  WHEN OTHERS THEN
    x_error_code := SQLCODE ;
    x_error_message := 'SYNC_ERR.create_msg()::' || SQLERRM ;
END ;
PROCEDURE PUBLISH  (   XNP$SYNC_LABEL VARCHAR2,
  XNP$SDP_RESULT_CODE VARCHAR2 DEFAULT NULL,
  x_message_id OUT NOCOPY  NUMBER,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message OUT NOCOPY VARCHAR2,
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
    XNP_MESSAGE.GET_SUBSCRIBER_LIST( 'SYNC_ERR', l_consumer_list );
  END IF;
  l_recipient_list := p_recipient_list ;
l_queue_name := 'XNP_IN_EVT_Q';
/* create the XML message */
  CREATE_MSG (
    XNP$SYNC_LABEL=>XNP$SYNC_LABEL,
    XNP$SDP_RESULT_CODE=>XNP$SDP_RESULT_CODE,
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
      p_correlation_id => 'MSG_SERVER',
      p_priority=>'2',
      p_commit_mode => XNP_MESSAGE.C_ON_COMMIT );
    IF (l_consumer_list IS NOT NULL) THEN
      XNP_MESSAGE.GET_SEQUENCE(l_msg_header.message_id) ;
      XNP_MESSAGE.push (
        p_msg_header => l_msg_header,
        p_body_text => l_msg_text,
      p_queue_name => xnp_event.c_outbound_msg_q,
        p_recipient_list => l_consumer_list,
        p_correlation_id => TO_CHAR(x_message_id),
        p_priority=>'2' ) ;
    END IF ;
/* out processing logic */
NULL;
  END IF ;
EXCEPTION
  WHEN e_NO_DESTINATION THEN
    x_error_code := XNP_ERRORS.G_NO_DESTINATION ;
  WHEN OTHERS THEN
    x_error_code := SQLCODE ;
    x_error_message := SQLERRM ;
END ;
PROCEDURE SEND  (   XNP$SYNC_LABEL VARCHAR2,
  XNP$SDP_RESULT_CODE VARCHAR2 DEFAULT NULL,
  x_message_id OUT NOCOPY  NUMBER,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message OUT NOCOPY VARCHAR2,
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
    XNP$SYNC_LABEL=>XNP$SYNC_LABEL,
    XNP$SDP_RESULT_CODE=>XNP$SDP_RESULT_CODE,
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
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2,
  p_process_reference IN VARCHAR2 DEFAULT NULL ) IS
BEGIN
NULL ;
XNP_WF_SYNC.PROCESS_SYNC_ERR(p_msg_header, x_error_code, x_error_message);
END ;
PROCEDURE VALIDATE (    p_msg_header IN OUT NOCOPY XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2 )  IS
BEGIN
NULL ;
NULL;
END ;
PROCEDURE DEFAULT_PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2 )  IS
BEGIN
NULL ;
NULL;
END ;
END XNP_SYNC_ERR_U;

/
