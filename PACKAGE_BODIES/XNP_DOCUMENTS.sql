--------------------------------------------------------
--  DDL for Package Body XNP_DOCUMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_DOCUMENTS" AS
/* $Header: XNPDOCUB.pls 120.2 2006/02/13 07:45:01 dputhiye ship $ */


 ------------------------------------------------------------------
 -- Porting Approval request for a TN range
 ------------------------------------------------------------------
PROCEDURE PORTING_APPROVAL
 (DOCUMENT_ID  IN VARCHAR2
 ,DISPLAY_TYPE IN VARCHAR2
 ,DOCUMENT     IN OUT NOCOPY VARCHAR2
 ,DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2
 )
IS
 l_STARTING_NUMBER VARCHAR2(40);
 l_ENDING_NUMBER VARCHAR2(40);
 l_PORTING_TIME VARCHAR2(40);
 l_WORKITEM_INSTANCE_ID NUMBER := 0;
BEGIN
 -- Get the workitem instance id from the DOCUMENT_ID
 -- and convert to a number
 l_WORKITEM_INSTANCE_ID := to_number(DOCUMENT_ID);

 -- Get the starting and ending number from WI parameters
  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_PORTING_TIME :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'PORTING_TIME'
   );


  IF l_PORTING_TIME IS NULL THEN
  l_PORTING_TIME :=
   XNP_STANDARD.GET_WORKITEM_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'NEW_SP_DUE_DATE'
   );
  END IF;


  DOCUMENT := NULL;
  fnd_message.set_name('XNP','PORTING_APPROVAL');
  fnd_message.set_token('STARTING_NUMBER',l_starting_number);
  fnd_message.set_token('ENDING_NUMBER',l_ending_number);
  fnd_message.set_token('PORTING_TIME',l_PORTING_TIME);

  IF (DISPLAY_TYPE = 'text/html') THEN
   DOCUMENT := DOCUMENT || htf.bodyOpen;
   DOCUMENT := DOCUMENT || fnd_message.get;
   DOCUMENT := DOCUMENT || htf.bodyClose;

   DOCUMENT_TYPE := 'text/html';
   return;
  END IF;

  IF (DISPLAY_TYPE = 'text/plain') THEN

    DOCUMENT := DOCUMENT || fnd_message.get;
    DOCUMENT_TYPE := 'text/plain';
    return;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
     XNP_TRACE.LOG
      (1
      ,'XNP_DOCUMENTS.PORTING_APPROVAL_DOCUMENT'
      ,'FAILED TO PREPARE DOCUMENT: WI INSTANCE ID:'||l_WORKITEM_INSTANCE_ID
       ||'Error:'||to_char(SQLCODE)||':'||SQLERRM
      );

END PORTING_APPROVAL;

PROCEDURE PORTING_INQUIRY_RESPONSE
 (DOCUMENT_ID  IN VARCHAR2
 ,DISPLAY_TYPE IN VARCHAR2
 ,DOCUMENT     IN OUT NOCOPY VARCHAR2
 ,DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2
 )
IS
 l_STARTING_NUMBER VARCHAR2(40);
 l_ENDING_NUMBER VARCHAR2(40);
 l_ORDER_RESULT VARCHAR2(40);
 l_WORKITEM_INSTANCE_ID NUMBER := 0;
BEGIN
 -- Get the workitem instance id from the DOCUMENT_ID
 -- and convert to a number
 l_WORKITEM_INSTANCE_ID := to_number(DOCUMENT_ID);

 -- Get the starting and ending number from WI parameters
  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_ORDER_RESULT :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'ORDER_RESULT'
   );

  DOCUMENT := NULL;
  fnd_message.set_name('XNP','PORTING_INQUIRY_RESPONSE');
  fnd_message.set_token('STARTING_NUMBER',l_starting_number);
  fnd_message.set_token('ENDING_NUMBER',l_ending_number);
  fnd_message.set_token('RESPONSE',l_ORDER_RESULT);

  IF (DISPLAY_TYPE = 'text/html') THEN
   DOCUMENT := DOCUMENT || htf.bodyOpen;
   DOCUMENT := DOCUMENT || fnd_message.get;
   DOCUMENT := DOCUMENT || htf.bodyClose;

   DOCUMENT_TYPE := 'text/html';
   return;
  END IF;

  IF (DISPLAY_TYPE = 'text/plain') THEN
    DOCUMENT := DOCUMENT || fnd_message.get;

    DOCUMENT_TYPE := 'text/plain';
    return;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
     XNP_TRACE.LOG
      (1
      ,'XNP_DOCUMENTS.PORTING_INQUIRY_RESPONSE'
      ,'FAILED TO PREPARE DOCUMENT: WI INSTANCE ID:'||l_WORKITEM_INSTANCE_ID
       ||'Error:'||to_char(SQLCODE)||':'||SQLERRM
      );

END PORTING_INQUIRY_RESPONSE;


PROCEDURE PORTING_NOTIFICATION_REJECTION
 (DOCUMENT_ID  IN VARCHAR2
 ,DISPLAY_TYPE IN VARCHAR2
 ,DOCUMENT     IN OUT NOCOPY VARCHAR2
 ,DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2
 )
IS
 l_STARTING_NUMBER VARCHAR2(40);
 l_ENDING_NUMBER VARCHAR2(40);
 l_ORDER_REJECT_EXPLN VARCHAR2(40);
 l_WORKITEM_INSTANCE_ID NUMBER := 0;
BEGIN
 -- Get the workitem instance id from the DOCUMENT_ID
 -- and convert to a number
 l_WORKITEM_INSTANCE_ID := to_number(DOCUMENT_ID);

 -- Get the starting and ending number from WI parameters
  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  l_ORDER_REJECT_EXPLN :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'ORDER_REJECT_EXPLN'
   );


  DOCUMENT := NULL;
  fnd_message.set_name('XNP','PORTING_NOTIFICATION_REJECTION');
  fnd_message.set_token('STARTING_NUMBER',l_starting_number);
  fnd_message.set_token('ENDING_NUMBER',l_ending_number);
  fnd_message.set_token('ORDER_REJECT_EXPLN',l_ORDER_REJECT_EXPLN);

  IF (DISPLAY_TYPE = 'text/html') THEN
   DOCUMENT := DOCUMENT || htf.bodyOpen;
   DOCUMENT := DOCUMENT || fnd_message.get;
   DOCUMENT := DOCUMENT || htf.bodyClose;
   DOCUMENT_TYPE := 'text/html';
   return;
  END IF;

  IF (DISPLAY_TYPE = 'text/plain') THEN
   DOCUMENT := DOCUMENT || fnd_message.get;

    DOCUMENT_TYPE := 'text/plain';
    return;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
     XNP_TRACE.LOG
      (1
      ,'XNP_DOCUMENTS.PORTING_NOTIFICATION_REJECTION'
      ,'FAILED TO PREPARE DOCUMENT: WI INSTANCE ID:'||l_WORKITEM_INSTANCE_ID
       ||'Error:'||to_char(SQLCODE)||':'||SQLERRM
      );

END PORTING_NOTIFICATION_REJECTION;

PROCEDURE PORTING_NOTIFICATION_REMINDER
 (DOCUMENT_ID  IN VARCHAR2
 ,DISPLAY_TYPE IN VARCHAR2
 ,DOCUMENT     IN OUT NOCOPY VARCHAR2
 ,DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2
 )
IS
 l_STARTING_NUMBER VARCHAR2(40);
 l_ENDING_NUMBER VARCHAR2(40);
 l_ORDER_RESULT VARCHAR2(40);
 l_WORKITEM_INSTANCE_ID NUMBER := 0;
BEGIN
 -- Get the workitem instance id from the DOCUMENT_ID
 -- and convert to a number
 l_WORKITEM_INSTANCE_ID := to_number(DOCUMENT_ID);

 -- Get the starting and ending number from WI parameters
  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  DOCUMENT := NULL;
  fnd_message.set_name('XNP','PORTING_NOTIFICATION_REMINDER');
  fnd_message.set_token('STARTING_NUMBER',l_starting_number);
  fnd_message.set_token('ENDING_NUMBER',l_ending_number);

  IF (DISPLAY_TYPE = 'text/html') THEN
   DOCUMENT := DOCUMENT || htf.bodyOpen;
   DOCUMENT := DOCUMENT || fnd_message.get;
   DOCUMENT := DOCUMENT || htf.bodyClose;
   DOCUMENT_TYPE := 'text/html';
   return;
  END IF;

  IF (DISPLAY_TYPE = 'text/plain') THEN
    DOCUMENT := DOCUMENT || fnd_message.get;

    DOCUMENT_TYPE := 'text/plain';
    return;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
     XNP_TRACE.LOG
      (1
      ,'XNP_DOCUMENTS.PORTING_NOTIFICATION_REMINDER'
      ,'FAILED TO PREPARE DOCUMENT: WI INSTANCE ID:'||l_WORKITEM_INSTANCE_ID
       ||'Error:'||to_char(SQLCODE)||':'||SQLERRM
      );

END PORTING_NOTIFICATION_REMINDER;

PROCEDURE PORTING_REFERENCE_DATA
 (DOCUMENT_ID  IN VARCHAR2
 ,DISPLAY_TYPE IN VARCHAR2
 ,DOCUMENT     IN OUT NOCOPY VARCHAR2
 ,DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2
 )
IS
 l_STARTING_NUMBER VARCHAR2(40);
 l_ENDING_NUMBER VARCHAR2(40);
 l_WORKITEM_INSTANCE_ID NUMBER := 0;
BEGIN
 -- Get the workitem instance id from the DOCUMENT_ID
 -- and convert to a number
 l_WORKITEM_INSTANCE_ID := to_number(DOCUMENT_ID);

 -- Get the starting and ending number from WI parameters
  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );

  DOCUMENT := NULL;
  fnd_message.set_name('XNP','PORTING_REFERENCE_DATA');
  fnd_message.set_token('STARTING_NUMBER',l_starting_number);
  fnd_message.set_token('ENDING_NUMBER',l_ending_number);

  IF (DISPLAY_TYPE = 'text/html') THEN
   DOCUMENT := DOCUMENT || htf.bodyOpen;
   DOCUMENT := DOCUMENT || fnd_message.get;
   DOCUMENT := DOCUMENT || htf.bodyClose;
   DOCUMENT_TYPE := 'text/html';
   return;
  END IF;

  IF (DISPLAY_TYPE = 'text/plain') THEN
    DOCUMENT := DOCUMENT || fnd_message.get;

    DOCUMENT_TYPE := 'text/plain';
    return;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
     XNP_TRACE.LOG
      (1
      ,'XNP_DOCUMENTS.PORTING_REFERENCE_DATA'
      ,'FAILED TO PREPARE DOCUMENT: WI INSTANCE ID:'||l_WORKITEM_INSTANCE_ID
       ||'Error:'||to_char(SQLCODE)||':'||SQLERRM
      );


END PORTING_REFERENCE_DATA;

PROCEDURE SERVICE_PROCESSING_ERROR
 (DOCUMENT_ID  IN VARCHAR2
 ,DISPLAY_TYPE IN VARCHAR2
 ,DOCUMENT     IN OUT NOCOPY VARCHAR2
 ,DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2
 )

IS
 l_MESSAGE_ID NUMBER := 0;
BEGIN

 -- Get the item type and item key
 l_MESSAGE_ID := to_number(DOCUMENT_ID);


  DOCUMENT := NULL;
  fnd_message.set_name('XNP','SERVICE_PROCESSING_ERROR');
  fnd_message.set_token('MESSAGE_ID',DOCUMENT_ID);

  IF (DISPLAY_TYPE = 'text/html') THEN
   DOCUMENT := DOCUMENT || htf.bodyOpen;
   DOCUMENT := DOCUMENT || fnd_message.get;
   DOCUMENT := DOCUMENT || htf.bodyClose;
   DOCUMENT_TYPE := 'text/html';
   return;
  END IF;

  IF (DISPLAY_TYPE = 'text/plain') THEN
    DOCUMENT := DOCUMENT || fnd_message.get;

    DOCUMENT_TYPE := 'text/plain';
    return;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
     XNP_TRACE.LOG
      (1
      ,'XNP_DOCUMENTS.SERVICE_PROCESSING_ERROR'
      ,'FAILED TO PREPARE DOCUMENT: Message id:'||to_char(l_MESSAGE_ID)
       ||'Error:'||to_char(SQLCODE)||':'||SQLERRM
      );

END SERVICE_PROCESSING_ERROR;

PROCEDURE NO_ACK_RECEIVED
 (DOCUMENT_ID  IN VARCHAR2
 ,DISPLAY_TYPE IN VARCHAR2
 ,DOCUMENT     IN OUT NOCOPY VARCHAR2
 ,DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2
 )
IS
 l_MESSAGE_ID NUMBER := 0;
BEGIN

 -- Get the item type and item key
 l_MESSAGE_ID := to_number(DOCUMENT_ID);

 DOCUMENT := NULL;
 fnd_message.set_name('XNP','NO_ACK_RECEIVED');
 fnd_message.set_token('MESSAGE_ID',DOCUMENT_ID);

  IF (DISPLAY_TYPE = 'text/html') THEN

   DOCUMENT := DOCUMENT || htf.bodyOpen;
   DOCUMENT := DOCUMENT || fnd_message.get;
   DOCUMENT := DOCUMENT || htf.bodyClose;

   DOCUMENT_TYPE := 'text/html';
   return;
  END IF;

  IF (DISPLAY_TYPE = 'text/plain') THEN
   DOCUMENT := DOCUMENT || fnd_message.get;

   DOCUMENT_TYPE := 'text/plain';
   return;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN

     XNP_TRACE.LOG
      (1
      ,'XNP_DOCUMENTS.NO_ACK_RECEIVED'
      ,'FAILED TO PREPARE DOCUMENT: Message id:'||to_char(l_MESSAGE_ID)
       ||'Error:'||to_char(SQLCODE)||':'||SQLERRM
      );

END NO_ACK_RECEIVED;

PROCEDURE INVALID_PARAMETERS
 (DOCUMENT_ID  IN VARCHAR2
 ,DISPLAY_TYPE IN VARCHAR2
 ,DOCUMENT     IN OUT NOCOPY VARCHAR2
 ,DOCUMENT_TYPE IN OUT NOCOPY VARCHAR2
 )

IS
 l_WORKITEM_INSTANCE_ID NUMBER := 0;
 l_starting_number varchar2(40) := NULL;
 l_ending_number varchar2(40) := NULL;
BEGIN

 -- Get the item type and item key
 l_WORKITEM_INSTANCE_ID := to_number(DOCUMENT_ID);

 -- Get the starting and ending number from WI parameters
  l_starting_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'STARTING_NUMBER'
   );

  l_ending_number :=
   XNP_STANDARD.GET_MANDATORY_WI_PARAM_VALUE
   (l_WORKITEM_INSTANCE_ID
   ,'ENDING_NUMBER'
   );


 DOCUMENT := NULL;
 fnd_message.set_name('XNP','INVALID_PARAMETERS');
 fnd_message.set_token('STARTING_NUMBER',l_starting_number);
 fnd_message.set_token('ENDING_NUMBER',l_ending_number);

  IF (DISPLAY_TYPE = 'text/html') THEN

   DOCUMENT := DOCUMENT || htf.bodyOpen;
   DOCUMENT := DOCUMENT || fnd_message.get;
   DOCUMENT := DOCUMENT || htf.bodyClose;

   DOCUMENT_TYPE := 'text/html';
   return;
  END IF;

  IF (DISPLAY_TYPE = 'text/plain') THEN
   DOCUMENT := DOCUMENT || fnd_message.get;

   DOCUMENT_TYPE := 'text/plain';
   return;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN

     XNP_TRACE.LOG
      (1
      ,'XNP_DOCUMENTS.INVALID_PARAMETERS'
      ,'FAILED TO PREPARE DOCUMENT: Worktiem instance id:'||to_char(l_workitem_instance_id)
       ||'Error:'||to_char(SQLCODE)||':'||SQLERRM
      );

END INVALID_PARAMETERS;

END XNP_DOCUMENTS;


/
