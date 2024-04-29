--------------------------------------------------------
--  DDL for Package XNP_ADAPTER_ADMIN_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_ADAPTER_ADMIN_U" AUTHID CURRENT_USER AS
/* $Header: XNPADMNS.pls 120.1 2005/06/18 00:37:40 appldev  $ */
--  Create message procedure for message type adapter admin

--    18/06/2005  DPUTHIYE   R12 GSCC Mandate: SQL.39 fixed(NOCOPY hint added).
PROCEDURE CREATE_MSG  (   XNP$REQUEST_TYPE VARCHAR2,
  XNP$REQUEST_ID VARCHAR2,
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
  p_interval  IN NUMBER  DEFAULT NULL ) ;
--
--  Publish message procedure for message type adapter admin
PROCEDURE PUBLISH  (   XNP$REQUEST_TYPE VARCHAR2,
  XNP$REQUEST_ID VARCHAR2,
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
  p_fa_instance_id  IN NUMBER  DEFAULT NULL ) ;
--
-- Send message procedure for message type adapter admin
PROCEDURE SEND  (   XNP$REQUEST_TYPE VARCHAR2,
  XNP$REQUEST_ID VARCHAR2,
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
  p_fa_instance_id  IN NUMBER  DEFAULT NULL ) ;                                --
-- Process message procedure for message type adapter admin
PROCEDURE PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2,
  p_process_reference IN VARCHAR2 DEFAULT NULL );                              --
-- Deafault process procedure for message type adapter admin
PROCEDURE DEFAULT_PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,

  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2 ) ;
--
-- Validate message procedure for message type adapter admin
PROCEDURE VALIDATE (    p_msg_header IN OUT NOCOPY XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2 ) ;
END XNP_ADAPTER_ADMIN_U;

 

/
