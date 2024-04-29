--------------------------------------------------------
--  DDL for Package Body XNP_T_DUMMY_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_T_DUMMY_U" AS
/*$Header: XNPTDUMB.pls 120.1 2005/06/17 03:52:49 appldev  $*/
PROCEDURE CREATE_MSG  (   XNP$PAYLOAD VARCHAR2 DEFAULT NULL,
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
/* get the message body */
  XNP_XML_UTILS.get_document ( l_xml_body ) ;
IF (l_xml_body IS NULL) THEN
  XNP_XML_UTILS.begin_segment ( 'T_DUMMY' ) ;
  XNP_XML_UTILS.write_element('DELAY', p_delay);
  XNP_XML_UTILS.write_element('INTERVAL', p_interval);
  XNP_XML_UTILS.end_segment ( 'T_DUMMY' ) ;
  XNP_XML_UTILS.get_document( l_xml_body ) ;
END IF;
/* initialize the XML header variable */
  XNP_XML_UTILS.initialize_doc ( ) ;
/*construct the XML header */
/* retreive the next message ID */
  IF (p_reference_id IS NULL) THEN
    XNP_MESSAGE.get_sequence ( l_msg_header.message_id ) ;
    l_msg_header.reference_id := l_msg_header.message_id ;
  ELSE
    l_msg_header.message_id := p_reference_id;
    l_msg_header.reference_id := p_reference_id ;
  END IF ;
/* append header parameters to make header */
  XNP_XML_UTILS.write_element ( 'MESSAGE_ID',l_msg_header.message_id ) ;
  XNP_XML_UTILS.write_element ( 'REFERENCE_ID',l_msg_header.reference_id ) ;
  l_msg_header.opp_reference_id := p_opp_reference_id ;
  XNP_XML_UTILS.write_element ( 'OPP_REFERENCE_ID',l_msg_header.opp_reference_id ) ;
  l_msg_header.message_code := 'T_DUMMY' ;
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
  XNP_XML_UTILS.write_element ( 'PAYLOAD', XNP$PAYLOAD );
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
    x_error_message := 'T_DUMMY.create_msg()::' || SQLERRM ;
END ;
PROCEDURE PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2,
  p_process_reference IN VARCHAR2 DEFAULT NULL ) IS
BEGIN
NULL ;
NULL;
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
PROCEDURE FIRE  (   x_timer_id   OUT NOCOPY  NUMBER,
  x_timer_contents   OUT NOCOPY  VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message OUT NOCOPY VARCHAR2,
  p_sender_name IN VARCHAR2 DEFAULT NULL,
  p_recipient_list IN VARCHAR2 DEFAULT NULL,
  p_version IN NUMBER DEFAULT 1,
  p_reference_id IN VARCHAR2 DEFAULT NULL,
  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,
  p_order_id IN NUMBER DEFAULT NULL,
  p_wi_instance_id  IN NUMBER DEFAULT NULL,
  p_fa_instance_id  IN NUMBER  DEFAULT NULL )
	IS
	l_msg_header xnp_message.msg_header_rec_type ;
	l_msg_text VARCHAR2(32767);

	BEGIN
	x_error_code := 0;
	x_error_message := NULL;
	CREATE_MSG (x_msg_header=>l_msg_header,
	x_msg_text=>l_msg_text,
	x_error_code=>x_error_code,
	x_error_message=>x_error_message,
	p_sender_name=>p_sender_name,
	p_recipient_list=>p_recipient_list,
	p_version=>p_version,
	p_reference_id=>p_reference_id,
	p_opp_reference_id=>p_reference_id,
	p_order_id=>p_order_id,
	p_wi_instance_id=>p_wi_instance_id,
	p_fa_instance_id=>p_fa_instance_id );
	IF (x_error_code = 0) THEN
	xnp_timer.start_timer(l_msg_header,
	l_msg_text,
	x_error_code,
	x_error_message );
	x_timer_id := l_msg_header.message_id ;
	x_timer_contents := l_msg_text;
	END IF;
	END ;

END XNP_T_DUMMY_U;

/
