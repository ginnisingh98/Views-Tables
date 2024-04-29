--------------------------------------------------------
--  DDL for Package Body XNB_QUEUE_HANDLERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNB_QUEUE_HANDLERS_PKG" AS
/* $Header: XNBVQHLB.pls 120.0 2005/05/30 13:46:22 appldev noship $ */

--------------------------------------------------------------------------------------
/***** This is a private procedure to dequeue messages from the		*/
/*     ECX_OUTBOUND to XNB_JMS_OUTBOUND                             */
/*                                                                  */


---------------------------------------------------------------------------------------

PROCEDURE ecx_to_jms_handler (
				  CONTEXT    IN RAW,
				  reginfo    IN SYS.aq$_reg_info,
				  descr      IN SYS.aq$_descriptor,
				  payload    IN RAW,
				  payloadl   IN NUMBER
			  )
AS

	l_ecx_dequeue_options		DBMS_AQ.dequeue_options_t;
	l_ecx_message_properties	DBMS_AQ.message_properties_t;
	l_ecx_message_handle		RAW (16);
	l_ecx_message			SYSTEM.ecxmsg;
	l_jms_enqueue_options		DBMS_AQ.enqueue_options_t;
	l_jms_message_properties	DBMS_AQ.message_properties_t;
	l_jms_message_handle		RAW (16);
	l_jms_message			SYS.aq$_jms_text_message;
	l_error_msg			VARCHAR2 (1000);
        l_payload_length		NUMBER;
	l_payload_vc			VARCHAR2(4000);

	NO_NEW_MESSAGES EXCEPTION;

	pragma exception_init (NO_NEW_MESSAGES, -25228);
	l_more_messages BOOLEAN ;

BEGIN


   --------------------------------------------------------------------------------------
   --   DEQUEUE FROM XML GATEWAY OUTBOUND QUEUE
   --
   -------------------------------------------------------------------------------------
	 xnb_debug.log('ecx_to_jms','Begin of ecx_to_jms Handler');
   l_more_messages := TRUE;
   l_ecx_dequeue_options.wait := 1;

   WHILE (l_more_messages) LOOP

	BEGIN
		l_ecx_dequeue_options.deq_condition := 'tab.USER_DATA.PARTY_SITE_ID = ''XNB''';
		l_ecx_dequeue_options.dequeue_mode := DBMS_AQ.REMOVE;


		DBMS_AQ.DEQUEUE(queue_name 		=> g_apps_schema||'.'||g_ecx_outbound_q
  		                ,dequeue_options 	=> l_ecx_dequeue_options
				,message_properties 	=> l_ecx_message_properties
                                ,payload 		=> l_ecx_message
                                ,msgid 		=> l_ecx_message_handle);
        COMMIT;
        xnb_debug.log('ecx_to_jms','After DEqueue from ECX_outbound');
		--------------------------------------------------------------------------------------
		--   TRANSFORM FROM SYSTEM.ECXMSG TO SYS.AQ$_JMS_TEXT_MESSAGE
		--   Create JMS text message and set properties
		--
		--------------------------------------------------------------------------------------

		l_jms_message := SYS.AQ$_JMS_TEXT_MESSAGE.CONSTRUCT();

		l_jms_message.SET_STRING_PROPERTY(g_ecx_message_type, l_ecx_message.message_type);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_message_standard, l_ecx_message.message_standard);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_transaction_type, l_ecx_message.transaction_type);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_transaction_subtype, l_ecx_message.transaction_subtype);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_document_number, l_ecx_message.document_number);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_party_id, l_ecx_message.partyid);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_party_site_id, l_ecx_message.party_site_id);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_party_type, l_ecx_message.party_type);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_protocol_type, l_ecx_message.protocol_type);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_protocol_address, l_ecx_message.protocol_address);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_username, l_ecx_message.username);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_password, l_ecx_message.password);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_attribute1, l_ecx_message.attribute1);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_attribute2, l_ecx_message.attribute2);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_attribute3, l_ecx_message.attribute3);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_attribute4, l_ecx_message.attribute4);
		l_jms_message.SET_STRING_PROPERTY(g_ecx_attribute5, l_ecx_message.attribute5);

		--------------------------------------------------------------------------------------
		--  Retain the MSG_ID attribute of the Message
		--
		-------------------------------------------------------------------------------------

		l_jms_message_handle := l_ecx_message_handle;

		-------------------------------------------------------------------------------------
		--  Find out the length of the message
		--
		-------------------------------------------------------------------------------------

		l_payload_length := dbms_lob.getlength(l_ecx_message.payload);

		-------------------------------------------------------------------------------------
		--  If the length of the message is more than 4000 it has to be represented
		--  as a CLOB in the JMS message otherwise as a VARCHAR
		--
		-------------------------------------------------------------------------------------

		IF (l_payload_length) >  4000 THEN

			l_jms_message.SET_TEXT(l_ecx_message.payload);

		ELSE

			DBMS_LOB.READ(l_ecx_message.payload, l_payload_length, 1, l_payload_vc);
			l_jms_message.SET_TEXT(l_payload_vc);

		END IF;

		------------------------------------------------------------
		--   ENQUEUE ON JMS OUTBOUND QUEUE
		--
		------------------------------------------------------------

		dbms_aq.enqueue(queue_name 		=> g_apps_schema||'.'||g_xnb_jms_outbound_q
				  ,enqueue_options 	=> l_jms_enqueue_options
		                  ,message_properties 	=> l_jms_message_properties
				  ,payload 		=> l_jms_message
		                  ,msgid 		=> l_jms_message_handle);

		COMMIT;

        xnb_debug.log('ecx_to_jms','After Enqueue into XNB_JMS_OUTBOUND');

		EXCEPTION

		  WHEN NO_NEW_MESSAGES THEN
		 	  xnb_debug.log('XNB_QUEUE_HANDLERS_PKG.ecx_to_jms_handler','No New Message in ECX_OUTBOUND');
			  l_more_messages := FALSE;
		  END;

	END LOOP;

   EXCEPTION
	WHEN OTHERS THEN
		l_error_msg := SQLERRM;
                xnb_debug.log('XNB_QUEUE_HANDLERS_PKG.ecx_to_jms_handler',l_error_msg);

END ecx_to_jms_handler;


---------------------------------------------------------------------------------------
/***** This is a private procedure to dequeue messages from the		*/
/*     XNB_JMS_INBOUND TO ECX_INBOUND                               */
/*                                                                  */
---------------------------------------------------------------------------------------

PROCEDURE jms_to_ecx_handler (
				  CONTEXT    IN RAW,
				  reginfo    IN SYS.aq$_reg_info,
				  descr      IN SYS.aq$_descriptor,
				  payload    IN RAW,
				  payloadl   IN NUMBER
			  )
AS

	l_jms_dequeue_options		DBMS_AQ.dequeue_options_t;
	l_jms_message_properties	DBMS_AQ.message_properties_t;
	l_jms_message_handle		RAW (16);
	l_jms_message			SYS.aq$_jms_text_message;
	l_ecx_enqueue_options		DBMS_AQ.enqueue_options_t;
	l_ecx_message_properties	DBMS_AQ.message_properties_t;
	l_ecx_message_handle		RAW (16);
	l_ecx_message			SYSTEM.ecxmsg;
	l_error_msg			VARCHAR2 (1000);
        l_payload_length		NUMBER;

	NO_NEW_MESSAGES EXCEPTION;

	pragma exception_init (NO_NEW_MESSAGES, -25228);
	l_more_messages BOOLEAN ;

BEGIN

   --------------------------------------------------------------------------------------
   --   DEQUEUE FROM JMS INBOUND QUEUE
   --
   -------------------------------------------------------------------------------------
  l_more_messages := TRUE;
  l_jms_dequeue_options.wait := 1;
  xnb_debug.log('jms_to_ecx','Begin of jms_to_ecx_handler Handler');

   WHILE (l_more_messages) LOOP

	BEGIN

--		l_jms_dequeue_options.msgid := descr.msg_id;

		l_jms_dequeue_options.dequeue_mode := DBMS_AQ.REMOVE;


   		DBMS_AQ.DEQUEUE(  queue_name		=> g_apps_schema||'.'||g_xnb_jms_inbound_q
				  ,dequeue_options 	=> l_jms_dequeue_options
				  ,message_properties 	=> l_jms_message_properties
				  ,payload 		=> l_jms_message
		          	  ,msgid 		=> l_jms_message_handle);
        COMMIT;
		xnb_debug.log('jms_to_ecx','After Dequeu from inbound');

		--------------------------------------------------------------------------------------
		--   TRANSFORM FROM SYS.AQ$_JMS_TEXT_MESSAGE TO SYSTEM.ECXMSG
		--   Create ECX text message and set Headers
		--
		--------------------------------------------------------------------------------------

		--------------------------------------------------------------------------------------
		--  Retain the MSG_ID attribute of the Message
		--
		-------------------------------------------------------------------------------------

		l_ecx_message_handle := l_jms_message_handle;


		-------------------------------------------------------------------------------------
		--  Find out the length of the message
		--
		-------------------------------------------------------------------------------------

		l_payload_length := l_jms_message.TEXT_LEN;

		xnb_debug.log('jms_to_ecx',' AFTER REtreivING Payload'||l_payload_length);

		-------------------------------------------------------------------------------------
		--  If the length of the message is more than 4000 it has to be represented
		--  as a CLOB in the JMS message otherwise as a VARCHAR
		--
		 -------------------------------------------------------------------------------------

		IF (l_payload_length) >  4000 THEN

			xnb_debug.log('jms_to_ecx','Inside If payload > 4000');
			l_ecx_message := SYSTEM.ECXMSG(	l_jms_message.GET_STRING_PROPERTY(g_ecx_message_type),		    --MESSAGE_TYPE
							l_jms_message.GET_STRING_PROPERTY(g_ecx_message_standard),         --MESSAGE_STAND
				                        l_jms_message.GET_STRING_PROPERTY(g_ecx_transaction_type),     --TRANSACTION_T
					                l_jms_message.GET_STRING_PROPERTY(g_ecx_transaction_subtype),  --TRANSACTION_S
							l_jms_message.GET_STRING_PROPERTY(g_ecx_document_number),          --DOCUMENT_NUMB
							l_jms_message.GET_STRING_PROPERTY(g_ecx_party_id),		    --PARTYID
							l_jms_message.GET_STRING_PROPERTY(g_ecx_party_site_id),            --PARTY_SITE_ID
							l_jms_message.GET_STRING_PROPERTY(g_ecx_party_type),		    --PARTY_TYPE
							l_jms_message.GET_STRING_PROPERTY(g_ecx_protocol_type),	    --PROTOCOL_TYPE
							l_jms_message.GET_STRING_PROPERTY(g_ecx_protocol_address),	    --PROTOCOL_ADDR
							l_jms_message.GET_STRING_PROPERTY(g_ecx_username),		    --USERNAME
							l_jms_message.GET_STRING_PROPERTY(g_ecx_password),		    --PASSWORD
							l_jms_message.TEXT_LOB,					    --PAYLOAD is an
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute1),		    --ATTRIBUTE1
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute2),		    --ATTRIBUTE2
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute3),		    --ATTRIBUTE3
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute4),		    --ATTRIBUTE4
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute5)); 	            --ATTRIBUTE5


		ELSE

			xnb_debug.log('jms_to_ecx','Inside Else');


			l_ecx_message := SYSTEM.ECXMSG(	l_jms_message.GET_STRING_PROPERTY(g_ecx_message_type),		    --MESSAGE_TYPE
							l_jms_message.GET_STRING_PROPERTY(g_ecx_message_standard),         --MESSAGE_STAND
				                        l_jms_message.GET_STRING_PROPERTY(g_ecx_transaction_type),     --TRANSACTION_T
					                l_jms_message.GET_STRING_PROPERTY(g_ecx_transaction_subtype),  --TRANSACTION_S
							l_jms_message.GET_STRING_PROPERTY(g_ecx_document_number),          --DOCUMENT_NUMB
							l_jms_message.GET_STRING_PROPERTY(g_ecx_party_id),		    --PARTYID
							l_jms_message.GET_STRING_PROPERTY(g_ecx_party_site_id),            --PARTY_SITE_ID
							l_jms_message.GET_STRING_PROPERTY(g_ecx_party_type),		    --PARTY_TYPE
							l_jms_message.GET_STRING_PROPERTY(g_ecx_protocol_type),	    --PROTOCOL_TYPE
							l_jms_message.GET_STRING_PROPERTY(g_ecx_protocol_address),	    --PROTOCOL_ADDR
							l_jms_message.GET_STRING_PROPERTY(g_ecx_username),		    --USERNAME
							l_jms_message.GET_STRING_PROPERTY(g_ecx_password),		    --PASSWORD
							l_jms_message.TEXT_VC,					    --PAYLOAD is an
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute1),		    --ATTRIBUTE1
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute2),		    --ATTRIBUTE2
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute3),		    --ATTRIBUTE3
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute4),		    --ATTRIBUTE4
							l_jms_message.GET_STRING_PROPERTY(g_ecx_attribute5)); 	            --ATTRIBUTE5


		END IF;

			xnb_debug.log('jms_to_ecx','Before Enqueue');
		------------------------------------------------------------
		--   ENQUEUE ON ECX INBOUND QUEUE
		--
		------------------------------------------------------------

		dbms_aq.enqueue(queue_name 		=> g_apps_schema||'.'||g_ecx_inbound_q
				,enqueue_options 	=> l_ecx_enqueue_options
				,message_properties 	=> l_ecx_message_properties
				,payload 		=> l_ecx_message
				,msgid 		=> l_ecx_message_handle);

		xnb_debug.log('jms_to_ecx','After Enqueue');

		COMMIT;

		EXCEPTION

		  WHEN NO_NEW_MESSAGES THEN
		 	  xnb_debug.log('XNB_QUEUE_HANDLERS_PKG.jms_to_ecx_handler','No New Message in XNB_JMS_INBOUND');
			  l_more_messages := FALSE;
		  END;

	END LOOP;

   EXCEPTION
	WHEN OTHERS THEN
		l_error_msg := SQLERRM;
                xnb_debug.log('XNB_QUEUE_HANDLERS_PKG.jms_to_ecx_handler',l_error_msg);

END jms_to_ecx_handler;

END XNB_QUEUE_HANDLERS_PKG;

/
