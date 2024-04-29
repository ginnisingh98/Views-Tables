--------------------------------------------------------
--  DDL for Package XNP_XDP_FULFILL_START_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_XDP_FULFILL_START_U" AUTHID CURRENT_USER AS 
PROCEDURE CREATE_MSG  (   XNP$LINE_ID NUMBER DEFAULT NULL,
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
PROCEDURE PUBLISH  (   XNP$LINE_ID NUMBER DEFAULT NULL,
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
PROCEDURE SEND  (   XNP$LINE_ID NUMBER DEFAULT NULL,
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
PROCEDURE PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2,
  p_process_reference IN VARCHAR2 DEFAULT NULL );
PROCEDURE DEFAULT_PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2 ) ;
PROCEDURE VALIDATE (    p_msg_header IN OUT XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT  NUMBER,
  x_error_message  OUT VARCHAR2 ) ;
 
 END XNP_XDP_FULFILL_START_U;

 

/
