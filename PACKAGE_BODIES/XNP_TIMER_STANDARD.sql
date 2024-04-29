--------------------------------------------------------
--  DDL for Package Body XNP_TIMER_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_TIMER_STANDARD" AS
/* $Header: XNPTSTAB.pls 120.2 2006/02/13 07:58:05 dputhiye ship $ */

PROCEDURE FIRE
 (p_order_id NUMBER DEFAULT NULL
 ,p_workitem_instance_id NUMBER DEFAULT NULL
 ,p_fa_instance_id NUMBER DEFAULT NULL
 ,p_timer_code VARCHAR2
 ,p_callback_ref_id VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 )
IS
 l_message_id NUMBER := 0;

 l_msg_text VARCHAR2(32767) ;

 l_cursor NUMBER := 0;
 l_proc_call VARCHAR2(32767) := NULL;
 l_num_rows NUMBER := 0;

 l_sender_name varchar2(200) := null;
 l_recipient_list varchar2(200) := null;
 l_version varchar2(200) := null;
 l_pkg_name VARCHAR2(200) := null;
BEGIN
  x_error_code := 0;


  -- Construct the dynamic SQL

--
-- The following line was added to fix bug 1650369
-- By Anping Wang
-- 02/20/2001

  l_pkg_name := XNP_MESSAGE.g_pkg_prefix || p_timer_code || XNP_MESSAGE.g_pkg_suffix;
  l_PROC_CALL :=
    'BEGIN
     '||l_pkg_name||'.fire(' ||
       ':l_message_id' ||
       ',:l_msg_text' ||
       ',:x_error_code' ||
       ',:x_error_message' ||
       ',:p_sender_name' ||
       ',:p_recipient_list' ||
       ',:p_version' ||
       ',:p_reference_id' ||
       ',:p_opp_reference_id' ||
       ',:p_ORDER_ID' ||
       ',:p_WORKITEM_INSTANCE_ID' ||
       ',:p_FA_INSTANCE_ID' ||
       ');
     END;';
  BEGIN

    EXECUTE IMMEDIATE l_proc_call USING
	OUT l_message_id
	,OUT l_msg_text
	,OUT x_error_code
	,OUT x_error_message
	,l_sender_name
	,l_recipient_list
	,l_version
	,p_callback_ref_id
	,p_callback_ref_id
	,p_order_id
	,p_workitem_instance_id
	,p_fa_instance_id;

  EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_TIMER_STANDARD.FIRE');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;
  END;


END FIRE;

PROCEDURE START_RELATED_TIMERS
(p_message_code VARCHAR2
 ,p_ORDER_ID NUMBER DEFAULT NULL
 ,p_workitem_instance_id NUMBER DEFAULT NULL
 ,p_fa_instance_id NUMBER DEFAULT NULL
 ,p_CALLBACK_REF_ID VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 )
IS
 l_message_id NUMBER := 0;
 l_callback_reference VARCHAR2(1024) := NULL;
 l_CURSOR NUMBER := 0;
 l_PROC_CALL VARCHAR2(2000) := NULL;
 l_NUM_ROWS NUMBER := 0;

BEGIN
  x_error_message := NULL;
  x_error_code := 0;

  xnp_timer_core.start_related_timers(
	p_message_code => p_message_code
	,p_reference_id => p_CALLBACK_REF_ID
	,x_error_code => x_error_code
	,x_error_message => x_error_message
	,p_order_id => p_order_id
	,p_wi_instance_id => p_workitem_instance_id
	,p_fa_instance_id => p_fa_instance_id
   );

    EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_TIMER_STANDARD.START_RELATED_TIMERS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END START_RELATED_TIMERS;

PROCEDURE GET_TIMER_STATUS
(
 p_reference_id IN VARCHAR2
 ,p_timer_message_code IN VARCHAR2
 ,x_timer_id OUT NOCOPY NUMBER
 ,x_status OUT NOCOPY VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 )
IS
 l_callback_reference VARCHAR2(1024) := NULL;

BEGIN
  x_error_message := NULL;
  x_error_code := 0;

  xnp_timer_core.get_timer_status(
	p_reference_id => p_reference_id
	,p_timer_message_code => p_timer_message_code
	,x_timer_id => x_timer_id
	,x_status => x_status
	,x_error_code => x_error_code
	,x_error_message => x_error_message
   );

   EXCEPTION
     WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_TIMER_STANDARD.GET_TIMER_STATUS');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END GET_TIMER_STATUS;

PROCEDURE RESTART_ALL
(
 p_reference_id IN VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 )
IS

BEGIN
  x_error_message := NULL;
  x_error_code := 0;

  xnp_timer_core.restart_all(
	p_reference_id => p_reference_id
	,x_error_code => x_error_code
	,x_error_message => x_error_message
   );

   EXCEPTION
     WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_TIMER_STANDARD.RESTART_ALL');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END RESTART_ALL;

PROCEDURE RECALCULATE_ALL
(
 p_reference_id IN VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 )
IS

BEGIN
  x_error_message := NULL;
  x_error_code := 0;

  xnp_timer_core.recalculate_all(
	p_reference_id => p_reference_id
	,x_error_code => x_error_code
	,x_error_message => x_error_message
   );

   EXCEPTION
     WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_TIMER_STANDARD.RECALCULATE_ALL');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END RECALCULATE_ALL;

PROCEDURE REMOVE
(
 p_reference_id IN VARCHAR2
 ,p_timer_message_code IN VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 )
IS

BEGIN
  x_error_message := NULL;
  x_error_code := 0;

  xnp_timer_core.remove_timer(
	p_reference_id => p_reference_id
	,p_timer_message_code => p_timer_message_code
	,x_error_code => x_error_code
	,x_error_message => x_error_message
   );

   EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_TIMER_STANDARD.REMEOVE');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END REMOVE;

PROCEDURE DEREGISTER
(
 p_order_id	NUMBER
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 )
IS

BEGIN
  x_error_message := NULL;
  x_error_code := 0;

  xnp_timer_core.deregister(
	p_order_id => p_order_id
	,x_error_code => x_error_code
	,x_error_message => x_error_message
   );

   EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_TIMER_STANDARD.DEREGISTER');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END DEREGISTER;

PROCEDURE DEREGISTER_FOR_WORKITEM
 (
 p_workitem_instance_id IN NUMBER
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
)
IS

BEGIN
  x_error_message := NULL;
  x_error_code := 0;

  xnp_timer_core.deregister_for_workitem(
	p_workitem_instance_id => p_workitem_instance_id
	,x_error_code => x_error_code
	,x_error_message => x_error_message
   );

   EXCEPTION
      WHEN OTHERS THEN
        -- Grab the error message and error no.
        x_error_code := SQLCODE;

        fnd_message.set_name('XNP','STD_ERROR');
        fnd_message.set_token('ERROR_LOCN'
          ,'XNP_TIMER_STANDARD.DEREGISTER');
        fnd_message.set_token('ERROR_TEXT',SQLERRM);
        x_error_message := fnd_message.get;

END DEREGISTER_FOR_WORKITEM;

--------------------------------------------------------------------------------
----- API Name    : Get Jeopardy Flag
----- Type        : Public
----- Purpose     : Retrieve the jeopardy flag given the order id
----- Parameters  : p_order_id
-----               x_flag
-----               x_error_code
-----               x_error_message
-----------------------------------------------------------------------------------
PROCEDURE GET_JEOPARDY_FLAG
(
 p_order_id IN NUMBER
 ,x_flag OUT NOCOPY VARCHAR2
 ,x_error_code OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_error_message := NULL;
  x_error_code := 0;

  xnp_timer_core.get_jeopardy_flag(
	p_order_id => p_order_id
	,x_flag => x_flag
	,x_error_code => x_error_code
	,x_error_message => x_error_message
   );

    EXCEPTION
	WHEN OTHERS THEN
        	-- Grab the error message and error no.
        	x_error_code := SQLCODE;

        	fnd_message.set_name('XNP','STD_ERROR');
        	fnd_message.set_token('ERROR_LOCN'
          	,'XNP_TIMER_STANDARD.GET_JEOPARDY_FLAG');
        	fnd_message.set_token('ERROR_TEXT',SQLERRM);
        	x_error_message := fnd_message.get;

END GET_JEOPARDY_FLAG;

END XNP_TIMER_STANDARD;

/
