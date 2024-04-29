--------------------------------------------------------
--  DDL for Package XNP_ADAPTER_READY_U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_ADAPTER_READY_U" AUTHID CURRENT_USER AS
/* $Header: XNPADRES.pls 120.2 2006/02/13 07:39:50 dputhiye ship $ */
--Create message procedure for message type adapter ready
--

PROCEDURE CREATE_MSG  (   XNP$CHANNEL VARCHAR2,
  XNP$STATUS VARCHAR2,
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
-- Publish message procedure for message type adapter ready
--
PROCEDURE PUBLISH  (   XNP$CHANNEL VARCHAR2,
  XNP$STATUS VARCHAR2,
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
-- Send message procedure for message type adapter ready
--
PROCEDURE SEND  (   XNP$CHANNEL VARCHAR2,
  XNP$STATUS VARCHAR2,
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
  p_fa_instance_id  IN NUMBER  DEFAULT NULL ) ;
-- Process message procedure for message type adapter ready
--
PROCEDURE PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2,
  p_process_reference IN VARCHAR2 DEFAULT NULL );
-- Deafault process procedure for message type adapter ready
--
PROCEDURE DEFAULT_PROCESS (    p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,

  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2 ) ;
-- Validate message procedure for message type adapter ready
--
PROCEDURE VALIDATE (    p_msg_header IN OUT NOCOPY XNP_MESSAGE.MSG_HEADER_REC_TYPE,
  p_msg_text IN VARCHAR2,
  x_error_code OUT NOCOPY  NUMBER,
  x_error_message  OUT NOCOPY VARCHAR2 ) ;
END XNP_ADAPTER_READY_U;

 

/
