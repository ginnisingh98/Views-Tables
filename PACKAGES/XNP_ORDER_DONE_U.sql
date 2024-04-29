--------------------------------------------------------
--  DDL for Package XNP_ORDER_DONE_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_ORDER_DONE_U" AUTHID CURRENT_USER AS
/* $Header: XNPORDNS.pls 115.5 2000/03/29 16:20:49 pkm ship     $ */


--Create message procedure for message type ORDER_DONE
--
PROCEDURE CREATE_MSG  (   XNP$SDP_RESULT_CODE VARCHAR2,
  x_msg_header OUT  XNP_MESSAGE.MSG_HEADER_REC_TYPE,
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
  p_interval  IN NUMBER  DEFAULT NULL ) ;
--Create publish procedure for message type ORDER_DONE
--
PROCEDURE PUBLISH  (   XNP$SDP_RESULT_CODE VARCHAR2,
  x_message_id OUT  NUMBER,
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
  p_fa_instance_id  IN NUMBER  DEFAULT NULL ) ;

--Create send procedure for message type ORDER_DONE
--
PROCEDURE SEND  (   XNP$SDP_RESULT_CODE VARCHAR2,
  x_message_id OUT  NUMBER,
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
  p_fa_instance_id  IN NUMBER  DEFAULT NULL ) ;

--Create process procedure for message type ORDER_DONE
--
PROCEDURE PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2,
  p_process_reference IN VARCHAR2 DEFAULT NULL );
--Create default process procedure for message type ORDER_DONE
--
PROCEDURE DEFAULT_PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2 ) ;
--Create validate procedure for message type ORDER_DONE
--
PROCEDURE VALIDATE (    p_msg_header IN OUT XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2 ) ;
END XNP_ORDER_DONE_U;

 

/
