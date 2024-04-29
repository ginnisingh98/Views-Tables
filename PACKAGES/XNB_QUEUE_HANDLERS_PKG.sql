--------------------------------------------------------
--  DDL for Package XNB_QUEUE_HANDLERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNB_QUEUE_HANDLERS_PKG" AUTHID CURRENT_USER AS
/* $Header: XNBVQHLS.pls 120.0 2005/05/30 13:44:52 appldev noship $ */

   g_ecx_message_type			CONSTANT VARCHAR2(30) := 'MESSAGE_TYPE';
   g_ecx_message_standard               CONSTANT VARCHAR2(30) := 'MESSAGE_STANDARD';
   g_ecx_transaction_type		CONSTANT VARCHAR2(30) := 'TRANSACTION_TYPE';
   g_ecx_transaction_subtype		CONSTANT VARCHAR2(30) := 'TRANSACTION_SUBTYPE';
   g_ecx_document_number                CONSTANT VARCHAR2(30) := 'DOCUMENT_NUMBER';
   g_ecx_party_id			CONSTANT VARCHAR2(30) := 'PARTY_ID';
   g_ecx_party_site_id                  CONSTANT VARCHAR2(30) := 'PARTY_SITE_ID';
   g_ecx_party_type			CONSTANT VARCHAR2(30) := 'PARTY_TYPE';
   g_ecx_protocol_type		        CONSTANT VARCHAR2(30) := 'PROTOCOL_TYPE';
   g_ecx_protocol_address		CONSTANT VARCHAR2(30) := 'PROTOCOL_ADDRESS';
   g_ecx_username			CONSTANT VARCHAR2(30) := 'USERNAME';
   g_ecx_password			CONSTANT VARCHAR2(30) := 'PASSWORD';
   g_ecx_attribute1			CONSTANT VARCHAR2(30) := 'ATTRIBUTE1';
   g_ecx_attribute2			CONSTANT VARCHAR2(30) := 'ATTRIBUTE2';
   g_ecx_attribute3			CONSTANT VARCHAR2(30) := 'ATTRIBUTE3';
   g_ecx_attribute4			CONSTANT VARCHAR2(30) := 'ATTRIBUTE4';
   g_ecx_attribute5			CONSTANT VARCHAR2(30) := 'ATTRIBUTE5';


   g_ecx_outbound_q		CONSTANT VARCHAR2(30) := 'ECX_OUTBOUND';
   g_xnb_jms_outbound_q		CONSTANT VARCHAR2(30) := 'XNB_JMS_OUTBOUND';
   g_ecx_inbound_q		CONSTANT VARCHAR2(30) := 'ECX_INBOUND';
   g_xnb_jms_inbound_q		CONSTANT VARCHAR2(30) := 'XNB_JMS_INBOUND';

   g_xnb_party_site_id		CONSTANT VARCHAR2(10) := 'XNB';
   g_apps_schema		CONSTANT VARCHAR2(10) := 'APPS';

PROCEDURE ecx_to_jms_handler (
				  CONTEXT    IN RAW,
				  reginfo    IN SYS.aq$_reg_info,
				  descr      IN SYS.aq$_descriptor,
				  payload    IN RAW,
				  payloadl   IN NUMBER
			  );

PROCEDURE jms_to_ecx_handler (
				  CONTEXT    IN RAW,
				  reginfo    IN SYS.aq$_reg_info,
				  descr      IN SYS.aq$_descriptor,
				  payload    IN RAW,
				  payloadl   IN NUMBER
			  );

END XNB_QUEUE_HANDLERS_PKG;

 

/
