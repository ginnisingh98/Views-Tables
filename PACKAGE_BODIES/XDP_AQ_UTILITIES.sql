--------------------------------------------------------
--  DDL for Package Body XDP_AQ_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_AQ_UTILITIES" AS
/* $Header: XDPAQUTB.pls 120.1 2005/06/08 23:41:20 appldev  $ */

/** Private Functions **/

FUNCTION GetWIProvisioningDate(p_workitem_instance_id IN NUMBER) RETURN DATE;

FUNCTION IS_AVAILABLE( object_id   IN NUMBER
                      ,object_type IN VARCHAR2 )
RETURN BOOLEAN;

/** End of Private Functions **/

 invalid_rowid exception;
 pragma exception_init(invalid_rowid, -01410);

 TYPE ROWID_TABLE is TABLE OF ROWID
   index by BINARY_INTEGER;

 G_XDP_SCHEMA            VARCHAR2(80);
 G_XNP_SCHEMA            VARCHAR2(80);
 G_DQ_COUNT              NUMBER := 1000 ;

 g_logdir                VARCHAR2(100);
 g_logdate               DATE;
 g_APPS_MAINTENANCE_MODE VARCHAR2(10);
--
-- Start an AQ to handle pipe handover between WFs
--
PROCEDURE  Start_WF_AQ(
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)
IS
  CURSOR lc_aq IS
  select
    internal_q_name,
    queue_table_name,
    payload_type,
    exception_queue_name,
    NVL(max_retries,0) max_retries,
    is_aq_flag
  from
   xdp_dq_configuration;

BEGIN

  p_return_code := 0;
  FOR lv_aq_rec IN lc_aq LOOP
   IF lv_aq_rec.is_aq_flag = 'Y' then
    Start_WF_AQ(
		p_queue_name  => lv_aq_rec.internal_q_name,
		p_queue_table => lv_aq_rec.queue_table_name,
		p_payload	  => lv_aq_rec.payload_type,
		p_expq_name   => lv_aq_rec.exception_queue_name,
		p_max_retries => lv_aq_rec.max_retries,
		p_return_code => p_return_code,
		p_error_description => p_error_description);
   END IF;
   IF p_return_code <> 0 THEN
       exit;
   END IF;

   ENABLE_SDP_AQ(
	lv_aq_rec.internal_q_name,
	p_return_code,
	p_error_description);

   IF p_return_code <> 0 THEN
       exit;
   END IF;

  END LOOP;


 EXCEPTION
 WHEN OTHERS THEN
   p_return_code := SQLCODE;
  p_error_description := SQLERRM;
END Start_WF_AQ;

--
-- Start an AQ
--
PROCEDURE  Start_WF_AQ(
		p_queue_name  IN varchar2,
		p_queue_table IN varchar2,
		p_payload	  IN varchar2,
		p_expq_name   IN varchar2 DEFAULT NULL,
		p_max_retries IN number default 0,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)
IS
  lv_storage varchar2(80) := 'INITRANS 3 MAXTRANS 6';
BEGIN
  p_return_code := 0;

  /* Create queue table */
  BEGIN
  DBMS_AQADM.CREATE_QUEUE_TABLE(
   	 queue_table => p_queue_table,
   	 queue_payload_type => p_payload,
	 sort_list => 'priority,enq_time',
	 storage_clause => lv_storage);
  Exception
  when others then
     /* ignore queue table exists error*/
      if SQLCODE <> -24001 then
           raise;
     end if;
  End;

  -- Create the queue
  BEGIN
  DBMS_AQADM.CREATE_QUEUE(
    queue_name => p_queue_name,
    queue_table => p_queue_table,
    max_retries => p_max_retries);
  Exception
  when others then
     /* ignore queue exists error*/
      if SQLCODE <> -24006 then
           raise;
     end if;
  End;

  -- Enable enqueue and dequeue operations for SimpleQ.
  DBMS_AQADM.START_QUEUE(p_queue_name);

  -- Create an exception queue
  IF p_expq_name IS NOT NULL THEN
   BEGIN
   DBMS_AQADM.CREATE_QUEUE(
    queue_name => p_expq_name,
    queue_table => p_queue_table,
    queue_type => DBMS_AQADM.EXCEPTION_QUEUE,
    comment => 'Exception queue for '||p_queue_name);
   Exception
   when others then
     /* ignore queue exists error*/
      if SQLCODE <> -24006 then
           raise;
     end if;
   End;

   /* Enable dequeue operations for exceptionQ.*/
   DBMS_AQADM.START_QUEUE(p_expq_name,FALSE,TRUE);
  END IF;


 EXCEPTION
 WHEN OTHERS THEN
   p_return_code := SQLCODE;
  p_error_description := SQLERRM;

END START_WF_AQ;

--
-- Stop the WF AQs
--
PROCEDURE STOP_WF_AQ(
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)
IS
  CURSOR lc_aq IS
  select
    internal_q_name
  from
   xdp_dq_configuration
  where
   is_aq_flag = 'Y';

BEGIN

  p_return_code := 0;
  FOR lv_aq_rec IN lc_aq LOOP
    DBMS_AQADM.STOP_QUEUE(queue_name => lv_aq_rec.internal_q_name);
  END LOOP;

 EXCEPTION
 WHEN OTHERS THEN
   p_return_code := SQLCODE;
   p_error_description := SQLERRM;
END STOP_WF_AQ;
--
-- Drop the WF AQs
--
PROCEDURE DROP_WF_AQ(
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)
IS
  CURSOR lc_aq IS
  select
    distinct queue_table_name
  from
   xdp_dq_configuration
  where
   is_aq_flag = 'Y';

BEGIN

  p_return_code := 0;
  FOR lv_aq_rec IN lc_aq LOOP
    DBMS_AQADM.DROP_QUEUE_TABLE(
                queue_table => lv_aq_rec.queue_table_name,
                force => TRUE);

  END LOOP;
  commit;
 EXCEPTION
 WHEN OTHERS THEN
   p_return_code := SQLCODE;
  p_error_description := SQLERRM;
END DROP_WF_AQ;

--
--  Add order to pending queue
--
/***************   Commented out by SPUSEGAO as pending order Queue has been removed

PROCEDURE Pending_Order_EQ(
		p_order_id IN NUMBER,
		p_prov_date IN DATE,
		p_priority IN NUMBER DEFAULT 100,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_EnqueueOptions DBMS_AQ.ENQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
	lv_date date := sysdate;

BEGIN

  p_return_code := 0;
  lv_wf_object := SYSTEM.XDP_WF_CHANNELQ_TYPE(
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		p_order_id,
		NULL,
		NULL);

-- Enqueue it with the commit on a seperate transaction.
     lv_EnqueueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_MessageProperties.exception_queue := 'XDP_PENDING_ORDER_EXPQ';
     lv_MessageProperties.priority := NVL(p_priority,100);
	 if p_prov_date > lv_date then
     	lv_MessageProperties.delay :=
				(p_prov_date - lv_date)*24*60*60;
	 else
     	lv_MessageProperties.delay := 0;
	 end if;

    DBMS_AQ.ENQUEUE(
      queue_name => G_XDP_SCHEMA||'.'||'XDP_PENDING_ORDER_QUEUE',
      enqueue_options => lv_EnqueueOptions,
      message_properties => lv_MessageProperties,
      payload =>lv_wf_object,
      msgid => lv_MsgID);

	update XDP_ORDER_HEADERS
	set
      last_updated_by = FND_GLOBAL.USER_ID,
      last_update_date = sysdate,
      last_update_login = FND_GLOBAL.LOGIN_ID,
	  STATE = 'WAIT',
	  MSGID = lv_MsgID
	where
		order_id = p_order_id;

	update XDP_ORDER_LINE_ITEMS
	set
      last_updated_by = FND_GLOBAL.USER_ID,
      last_update_date = sysdate,
      last_update_login = FND_GLOBAL.LOGIN_ID,
	  STATE = 'WAIT'
	where
		order_id = p_order_id and
		state = 'PREPROCESS';

 EXCEPTION
 WHEN OTHERS THEN
   p_return_code := SQLCODE;
   p_error_description := SQLERRM;
END Pending_Order_EQ;

******************************/

--
--  Dequeue an order from the pending order queue
--
PROCEDURE  Pending_Order_DQ
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
 	lv_return_code NUMBER;
 	lv_count2 NUMBER;
 	lv_order_id NUMBER;
 	lv_priority NUMBER;
 	lv_error_description VARCHAR2(2000);
 	lv_queue_state varchar2(200);
  	lv_state varchar2(80);
  	lv_state2 varchar2(80);
	lv_item_type varchar2(80);
	lv_item_key varchar2(300);
	lv_ret number;
	lv_err varchar2(800);
	lv_prov_date date;

	cursor c_GetPendingOrders is
	select msgid
 	 from xdp_pending_order_qtab;

BEGIN

  for v_GetPendingOrders in c_GetPendingOrders LOOP
-- while 1=1 LOOP
        -- Check queue state
   lv_queue_state := Get_Queue_State('XDP_PENDING_ORDER_QUEUE');

   IF lv_queue_state = 'ENABLED' THEN       -- proceed
     savepoint pending_q_tag;
     lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
     lv_DequeueOptions.dequeue_mode := DBMS_AQ.LOCKED;
     lv_DequeueOptions.MSGID := NULL;
     lv_DequeueOptions.MSGID := v_GetPendingOrders.msgid;

     BEGIN
        -- Set Dequeue time out to be 1 second
        lv_DequeueOptions.wait := xnp_message.POP_TIMEOUT;
        DBMS_AQ.DEQUEUE(
         queue_name => G_XDP_SCHEMA||'.'||'XDP_PENDING_ORDER_QUEUE',
         dequeue_options => lv_DequeueOptions,
         message_properties => lv_MessageProperties,
         payload => lv_wf_object,
         msgid => lv_MsgID);
      EXCEPTION
       WHEN e_QTimeOut Then
			null;
			GOTO l_continue_loop;
       WHEN OTHERS THEN
         rollback to pending_q_tag;
     	  handle_dq_exception(
	  		p_MESSAGE_ID => lv_MSGID ,
        	p_WF_ITEM_TYPE => null,
         	p_WF_ITEM_KEY => null,
        	p_CALLER_NAME => 'Pending_Order_DQ',
        	p_CALLBACK_TEXT => NULL ,
        	p_Q_NAME => 'XDP_PENDING_ORDER_QUEUE',
        	p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);
         raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
      END;

	  select state,previous_order_id,priority, provisioning_date
	  into lv_state,lv_order_id,lv_priority, lv_prov_date
	  from xdp_order_headers
	  where
	    order_id = lv_wf_object.order_id;

	  if lv_state = 'SUSPENDED' THEN
	  -- Update the msg delay to new high number
	    null;
	    rollback to pending_q_tag;
	  elsif lv_state IN ('WAIT','HOLD') THEN
	   if lv_order_id is not null then
	    begin
		  select state into lv_state2
		  from xdp_order_headers
		  where order_id = lv_order_id;
	      exception
		when no_data_found then
		  lv_state2 := 'CANCELED';
	    end;
	   else
		 lv_state2 := 'CANCELED';
	   end if;
	   if lv_state2 not in( 'COMPLETED','CANCELED') THEN
	    rollback to pending_q_tag;
	   ELSE        -- No dependency found
		BEGIN
	  		XDPCORE.CreateOrderProcess(
				lv_wf_object.order_id,
				lv_item_type,
				lv_item_key);
		EXCEPTION
		  when others then
         	rollback to pending_q_tag;
     	  	handle_dq_exception(
	  			p_MESSAGE_ID => lv_MSGID ,
        		p_WF_ITEM_TYPE => null,
         		p_WF_ITEM_KEY => null,
        		p_CALLER_NAME => 'Pending_Order_DQ',
        		p_CALLBACK_TEXT => NULL ,
        		p_Q_NAME => 'XDP_PENDING_ORDER_QUEUE',
        		p_ERROR_DESCRIPTION => 'Can not create workflow: ' || SQLERRM);
         	raise_application_error(-20530,
					'Can not create workflow: ' || SQLERRM);
		 END;

        Add_OrderToProcessorQ(
			lv_wf_object.order_id,
			null,
			lv_priority,
			lv_prov_date,
			lv_item_type,
			lv_item_key);

        IF lv_ret <> 0 THEN
         ROLLBACK to pending_q_tag;
	   	 handle_dq_exception(
	  		p_MESSAGE_ID => lv_MSGID ,
        	p_WF_ITEM_TYPE => null,
         	p_WF_ITEM_KEY => null,
        	p_CALLER_NAME => 'Pending_Order_DQ',
        	p_CALLBACK_TEXT => NULL ,
        	p_Q_NAME => 'XDP_PENDING_ORDER_QUEUE',
        	p_ERROR_DESCRIPTION => lv_err);
         raise_application_error(-20530,lv_err);
        ELSE
     		lv_DequeueOptions.msgid := lv_MsgID;
     		lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE_NODATA;
        	DBMS_AQ.DEQUEUE(
         		queue_name => G_XDP_SCHEMA||'.'||'XDP_PENDING_ORDER_QUEUE',
         		dequeue_options => lv_DequeueOptions,
         		message_properties => lv_MessageProperties,
         		payload => lv_tmp,
         		msgid => lv_MsgID);
          	COMMIT;
        END IF;
	   END IF;
	  END IF;

   ELSIF lv_queue_state = 'SUSPENDED' THEN      -- notify dequeuer to sleep
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'SHUTDOWN' THEN      -- notify dequeuer to exit
		return;
   ELSIF lv_queue_state = 'DISABLED' THEN      -- notify dequeuer to exit
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'DATA_NOT_FOUND' THEN      -- notify dequeuer to exit
		return;
   ELSE      -- notify dequeuer to exit
		return;
   END IF;
 <<l_continue_loop>>
 null;

 END LOOP;

END Pending_Order_DQ;


/***************   Commented out by SPUSEGAO as pending order Queue has been removed
--
--  Dequeue an order from the pending order queue
--
PROCEDURE  Pending_Order_DQ (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     p_correlation_id IN VARCHAR2,
                             x_message_key OUT NOCOPY VARCHAR2,
                             x_queue_timed_out OUT NOCOPY VARCHAR2 )
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
 	lv_return_code NUMBER;
 	lv_count2 NUMBER;
 	lv_order_id NUMBER;
 	lv_priority NUMBER;
 	lv_error_description VARCHAR2(2000);
 	lv_queue_state varchar2(200);
  	lv_state varchar2(80);
  	lv_state2 varchar2(80);
	lv_item_type varchar2(80);
	lv_item_key varchar2(300);
	lv_ret number;
	lv_err varchar2(800);
	lv_prov_date date;

BEGIN

     savepoint pending_q_tag;
     lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
     lv_DequeueOptions.dequeue_mode := DBMS_AQ.LOCKED;
     lv_DequeueOptions.MSGID := NULL;
     lv_DequeueOptions.correlation := p_correlation_id;

     BEGIN
        -- Set Dequeue time out
        lv_DequeueOptions.wait := p_message_wait_timeout;
        DBMS_AQ.DEQUEUE(
         queue_name => G_XDP_SCHEMA||'.'||'XDP_PENDING_ORDER_QUEUE',
         dequeue_options => lv_DequeueOptions,
         message_properties => lv_MessageProperties,
         payload => lv_wf_object,
         msgid => lv_MsgID);
      EXCEPTION
       WHEN e_QTimeOut Then
--        raise e_NothingToDequeueException;
          x_queue_timed_out := 'Y';
          return;
       WHEN OTHERS THEN
         rollback to pending_q_tag;
     	  handle_dq_exception(
	  		p_MESSAGE_ID => lv_MSGID ,
        	p_WF_ITEM_TYPE => null,
         	p_WF_ITEM_KEY => null,
        	p_CALLER_NAME => 'Pending_Order_DQ',
        	p_CALLBACK_TEXT => NULL ,
        	p_Q_NAME => 'XDP_PENDING_ORDER_QUEUE',
        	p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);
         raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
      END;

-- Set the Context to the Sender name of the Message
-- SetContext(lv_MessageProperties.sender_id.name)

	  select state,previous_order_id,priority, provisioning_date
	  into lv_state,lv_order_id,lv_priority,lv_prov_date
	  from xdp_order_headers
	  where
	    order_id = lv_wf_object.order_id;

	  if lv_state = 'SUSPENDED' THEN
	   ---  Update the msg delay to new high number
	    null;
	    rollback to pending_q_tag;
	  elsif lv_state IN ('WAIT','HOLD') THEN
	   if lv_order_id is not null then
	    begin
		  select state into lv_state2
		  from xdp_order_headers
		  where order_id = lv_order_id;
	      exception
		when no_data_found then
		  lv_state2 := 'CANCELED';
	    end;
	   else
		 lv_state2 := 'CANCELED';
	   end if;
	   if lv_state2 not in( 'COMPLETED','CANCELED') THEN
	    rollback to pending_q_tag;
	   ELSE             ---- No dependency found
		BEGIN
	  		XDPCORE.CreateOrderProcess(
				lv_wf_object.order_id,
				lv_item_type,
				lv_item_key);
		exception
		  when others then
         	rollback to pending_q_tag;
     	  	handle_dq_exception(
	  			p_MESSAGE_ID => lv_MSGID ,
        		p_WF_ITEM_TYPE => null,
         		p_WF_ITEM_KEY => null,
        		p_CALLER_NAME => 'Pending_Order_DQ',
        		p_CALLBACK_TEXT => NULL ,
        		p_Q_NAME => 'XDP_PENDING_ORDER_QUEUE',
        		p_ERROR_DESCRIPTION => 'Can not create workflow: ' || SQLERRM);
         	raise_application_error(-20530,
					'Can not create workflow: ' || SQLERRM);
		 end;

        Add_OrderToProcessorQ(
			lv_wf_object.order_id,
			null,
			lv_priority,
			lv_prov_date,
			lv_item_type,
			lv_item_key);

        IF lv_ret <> 0 THEN
         ROLLBACK to pending_q_tag;
	   	 handle_dq_exception(
	  		p_MESSAGE_ID => lv_MSGID ,
        	p_WF_ITEM_TYPE => null,
         	p_WF_ITEM_KEY => null,
        	p_CALLER_NAME => 'Pending_Order_DQ',
        	p_CALLBACK_TEXT => NULL ,
        	p_Q_NAME => 'XDP_PENDING_ORDER_QUEUE',
        	p_ERROR_DESCRIPTION => lv_err);
         raise_application_error(-20530,lv_err);
        ELSE
     		lv_DequeueOptions.msgid := lv_MsgID;
     		lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE_NODATA;
        	DBMS_AQ.DEQUEUE(
         		queue_name => G_XDP_SCHEMA||'.'||'XDP_PENDING_ORDER_QUEUE',
         		dequeue_options => lv_DequeueOptions,
         		message_properties => lv_MessageProperties,
         		payload => lv_tmp,
         		msgid => lv_MsgID);
          	COMMIT;
        END IF;
	   END IF;
	  END IF;

EXCEPTION
WHEN e_NothingToDequeueException then
          x_queue_timed_out := 'Y';
WHEN OTHERS THEN
  RAISE;
END Pending_Order_DQ;

******************************/

--
--  Add order to order processor queue
--
PROCEDURE Add_OrderToProcessorQ(
		p_order_id IN NUMBER ,
		p_order_type in varchar2 default null,
		p_priority IN NUMBER DEFAULT 100,
		p_prov_date IN DATE default sysdate,
		p_wf_item_type IN varchar2,
		p_wf_item_key  IN Varchar2)

IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_EnqueueOptions DBMS_AQ.ENQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);

	lv_date date := sysdate;

BEGIN

  lv_wf_object := SYSTEM.XDP_WF_CHANNELQ_TYPE(
		NULL,
		NULL,
		p_wf_item_type,
		p_wf_item_key,
		NULL,
		p_order_id,
		NULL,
		NULL);

-- Enqueue it with the commit on a seperate transaction.
     lv_EnqueueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_MessageProperties.exception_queue := G_XDP_SCHEMA||'.'||'XDP_ORDER_PROCESSOR_EXPQ';
     lv_MessageProperties.priority := NVL(p_priority,100);

	 if p_prov_date > lv_date then
     	lv_MessageProperties.delay :=
				(p_prov_date - lv_date)*24*60*60;
	 else
     	lv_MessageProperties.delay := 0;
	 end if;

-- Set the Correlation ID Message Property
     lv_MessageProperties.correlation := p_order_type;

    DBMS_AQ.ENQUEUE(
      queue_name         => G_XDP_SCHEMA||'.'||'XDP_ORDER_PROC_QUEUE',
      enqueue_options    => lv_EnqueueOptions,
      message_properties => lv_MessageProperties,
      payload            =>lv_wf_object,
      msgid              => lv_MsgID);


	update XDP_ORDER_HEADERS
	   set last_updated_by   = FND_GLOBAL.USER_ID,
               last_update_date  = sysdate,
               last_update_login = FND_GLOBAL.LOGIN_ID,
               status_code            = 'READY',
	       MSGID             = lv_MsgID
	 where order_id          = p_order_id;

	update XDP_ORDER_LINE_ITEMS
	   set last_updated_by   = FND_GLOBAL.USER_ID,
               last_update_date  = sysdate,
               last_update_login = FND_GLOBAL.LOGIN_ID,
               status_code            = 'READY'
	 where order_id = p_order_id
           and status_code = 'STANDBY';


EXCEPTION
     WHEN OTHERS THEN
          xdp_utilities.generic_error('XDP_AQ_UTILITIES.Add_OrdertoProcessorQ'
			     ,xdp_order.G_external_order_reference
                             ,sqlcode
                             ,sqlerrm);
END Add_OrderToProcessorQ;

/**** Commented as this code is executed by c dequeuers 07/25/2001

--  Dequeue from order processor queue
--
PROCEDURE Start_OrderProcessor_Workflow
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
 	lv_return_code NUMBER;
 	lv_count2 NUMBER;
 	lv_error_description VARCHAR2(2000);
 	lv_queue_state varchar2(200);
  	lv_state varchar2(80);
  	lv_state2 varchar2(80);

BEGIN

  while 1=1 loop
   -- Check queue state
   lv_queue_state := Get_Queue_State('XDP_ORDER_PROC_QUEUE');
   IF lv_queue_state = 'ENABLED' THEN -- proceed
     savepoint order_q_tag;

     lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
     lv_DequeueOptions.dequeue_mode := DBMS_AQ.LOCKED;
     lv_DequeueOptions.MSGID := NULL;

     BEGIN
        -- Set Dequeue time out to be 1 second
        lv_DequeueOptions.wait := xnp_message.POP_TIMEOUT;

        DBMS_AQ.DEQUEUE(
                        queue_name         => G_XDP_SCHEMA||'.'||'XDP_ORDER_PROC_QUEUE',
                        dequeue_options    => lv_DequeueOptions,
                        message_properties => lv_MessageProperties,
                        payload            => lv_wf_object,
                        msgid              => lv_MsgID);
      EXCEPTION
           WHEN e_QTimeOut Then
		null;
		GOTO l_continue_loop;
           WHEN OTHERS THEN
                rollback to order_q_tag;
     	        handle_dq_exception(
	  		p_MESSAGE_ID        => lv_MSGID ,
                	p_WF_ITEM_TYPE      => null,
          	        p_WF_ITEM_KEY       => null,
        	        p_CALLER_NAME       => 'Start_OrderProcessor_Workflow',
        	        p_CALLBACK_TEXT     => NULL ,
        	        p_Q_NAME            => 'XDP_ORDER_PROC_QUEUE',
        	        p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);
                raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
      END;

	  SELECT status_code
	    INTO lv_state
	    FROM xdp_order_headers
	   WHERE order_id = lv_wf_object.order_id;

--	  if lv_state = 'SUSPENDED' THEN
--	  -- Update the msg delay to new high number
--	    null;
--	    rollback to order_q_tag;

	  if lv_state IN ('READY') THEN
		BEGIN
     		lv_DequeueOptions.msgid := lv_MsgID;
     		lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE_NODATA;

        	DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_ORDER_PROC_QUEUE',
         		         dequeue_options    => lv_DequeueOptions,
         		         message_properties => lv_MessageProperties,
         		         payload            => lv_tmp,
         		         msgid              => lv_MsgID);

         	WF_ENGINE.StartProcess(
				lv_wf_object.wf_item_type,
				lv_wf_object.wf_item_key);
         	COMMIT;
		exception
		  when others then
         	rollback to order_q_tag;
     	  	handle_dq_exception( p_MESSAGE_ID        => lv_MSGID ,
        		             p_WF_ITEM_TYPE      => lv_wf_object.wf_item_type,
         		             p_WF_ITEM_KEY       => lv_wf_object.wf_item_key,
        		             p_CALLER_NAME       => 'Start_OrderProcessor_Workflow',
        		             p_CALLBACK_TEXT     => NULL ,
        		             p_Q_NAME            => 'XDP_ORDER_PROC_QUEUE',
        		             p_ERROR_DESCRIPTION => 'Can not start workflow: ' || SQLERRM);
         	raise_application_error(-20530,
					'Can not create workflow: ' || SQLERRM);
		 end;
	   else
	    rollback to order_q_tag;

	   end if;

   ELSIF lv_queue_state = 'SUSPENDED' THEN --otify dequeuer to sleep
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'SHUTDOWN' THEN -- notify dequeuer to exit
		return;
   ELSIF lv_queue_state = 'DISABLED' THEN -- notify dequeuer to exit
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'DATA_NOT_FOUND' THEN -- notify dequeuer to exit
		return;
   ELSE -- notify dequeuer to exit
		return;
   END IF;

 <<l_continue_loop>>
 null;
 END LOOP;

END Start_OrderProcessor_Workflow;

**************/

PROCEDURE  Start_OrderProcessor_workflow (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     		  p_correlation_id IN VARCHAR2,
                             		  x_message_key OUT NOCOPY VARCHAR2,
                             		  x_queue_timed_out OUT NOCOPY VARCHAR2 )

IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
 	lv_return_code NUMBER;
 	lv_error_description VARCHAR2(2000);

BEGIN

  savepoint order_q_tag;
  lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
  lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
  lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE;
  lv_DequeueOptions.MSGID := NULL;
  lv_DequeueOptions.correlation := p_correlation_id;

	BEGIN
        -- Set Dequeue time out to be 1 second
       		lv_DequeueOptions.wait := p_message_wait_timeout;

		DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_ORDER_PROC_QUEUE',
         		         dequeue_options    => lv_DequeueOptions,
         		         message_properties => lv_MessageProperties,
         		         payload            => lv_wf_object,
         		         msgid              => lv_MsgID);

	EXCEPTION
	WHEN e_QTimeOut Then
		x_queue_timed_out := 'Y';
		return;
	WHEN OTHERS THEN
		rollback to order_q_tag;
		handle_dq_exception(
	  		p_MESSAGE_ID => lv_MSGID ,
        		p_WF_ITEM_TYPE => null,
         		p_WF_ITEM_KEY => null,
        		p_CALLER_NAME => 'Start_OrderProcessor_Workflow',
        		p_CALLBACK_TEXT => NULL ,
        		p_Q_NAME => 'XDP_ORDER_PROC_QUEUE',
        		p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);

         	raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
	END;

        BEGIN
        	SET_CONTEXT( lv_wf_object.order_id, 'ORDER_OBJECT');

	EXCEPTION
        WHEN stop_processing THEN
		x_queue_timed_out := 'Y';
                return;
	END;

	BEGIN

		wf_engine.startprocess( lv_wf_object.wf_item_type,
					lv_wf_object.wf_item_key);

         	COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
		rollback to order_q_tag;
     	  	handle_dq_exception(
	  		p_MESSAGE_ID => lv_MSGID ,
        		p_WF_ITEM_TYPE => lv_wf_object.wf_item_type,
         		p_WF_ITEM_KEY => lv_wf_object.wf_item_key,
        		p_CALLER_NAME => 'Start_OrderProcessor_Workflow',
        		p_CALLBACK_TEXT => NULL ,
        		p_Q_NAME => 'XDP_ORDER_PROC_QUEUE',
        		p_ERROR_DESCRIPTION => 'Can not start workflow: ' || SQLERRM);

	         	raise_application_error(-20530,'Can not create workflow: '||SQLERRM);
	END;

EXCEPTION
WHEN e_NothingToDequeueException then
          x_queue_timed_out := 'Y';
WHEN OTHERS THEN
 RAISE;
END Start_OrderProcessor_workflow;
--
-- Allow API to  start workitem WF through enqueue
--
PROCEDURE Add_WorkItem_ToQ(
		p_order_id IN NUMBER,
		p_wi_instance_id IN NUMBER,
		p_prov_date IN DATE,
		p_wf_item_type IN VARCHAR2 ,
		p_wf_item_key  VARCHAR2,
		p_priority   number DEFAULT 100,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)

IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_EnqueueOptions DBMS_AQ.ENQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
	lv_date date := sysdate;

-- Remove Later??
 	lv_workitem_name varchar2(40);
  cursor c_GetWorkitemName is
   select  xw.workitem_name workitem_name
    from xdp_workitems xw,
	 xdp_fulfill_worklist xfw
    where xfw.workitem_instance_id = p_wi_instance_id
      and xfw.workitem_id = xw.workitem_id;

BEGIN

  p_return_code := 0;
  lv_wf_object := SYSTEM.XDP_WF_CHANNELQ_TYPE(
		NULL,
		NULL,
		p_wf_item_type,
		p_wf_item_key,
		NULL,
		p_order_id,
		p_wi_instance_id,
		NULL);

-- Get Work Item for Correlation ID
  for v_GetWorkitemName in c_GetWorkitemName loop
	lv_workitem_name := v_GetWorkitemName.workitem_name;
  end loop;

-- Set the Correlation ID Message Property
     lv_MessageProperties.correlation := lv_workitem_name;

-- Enqueue it with the commit on a seperate transaction.
     lv_EnqueueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_MessageProperties.exception_queue := G_XDP_SCHEMA||'.'||'XDP_WORKITEM_EXPQ';
     lv_MessageProperties.priority := NVL(p_priority,100);

	 if p_prov_date > lv_date then
     	    lv_MessageProperties.delay := (p_prov_date - lv_date)*24*60*60;
	 else
     	    lv_MessageProperties.delay := 0;
	 end if;

    DBMS_AQ.ENQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_WORKITEM_QUEUE',
                     enqueue_options    => lv_EnqueueOptions,
                     message_properties => lv_MessageProperties,
                     payload            =>lv_wf_object,
                     msgid              => lv_MsgID);

	update XDP_FULFILL_WORKLIST
	   set last_updated_by      = FND_GLOBAL.USER_ID,
               last_update_date     = sysdate,
               last_update_login    = FND_GLOBAL.LOGIN_ID,
	       STATUS_CODE          = 'READY',
	       MSGID                = lv_MsgID
	 where workitem_instance_id = p_wi_instance_id;

EXCEPTION
WHEN OTHERS THEN
	p_return_code := SQLCODE;
	p_error_description := SQLERRM;
END Add_WorkItem_ToQ;

/*****  Commented out as this code is executed by C dequeuer

--  Dequeue from workitem queue
--
Procedure Start_Workitem_Workflow
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
 	lv_return_code NUMBER;
 	lv_count2 NUMBER;
 	lv_error_description VARCHAR2(2000);
 	lv_queue_state varchar2(200);
 	lv_state varchar2(200);

BEGIN

 while 1=1 loop
   lv_queue_state := Get_Queue_State('XDP_WORKITEM_QUEUE');
   IF lv_queue_state = 'ENABLED' THEN  -- proceed
     savepoint workitem_q_tag;

     lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
     lv_DequeueOptions.dequeue_mode := DBMS_AQ.LOCKED;
     lv_DequeueOptions.MSGID := NULL;

     BEGIN
        -- Set Dequeue time out to be 1 second
        lv_DequeueOptions.wait := xnp_message.POP_TIMEOUT;

        DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_WORKITEM_QUEUE',
                         dequeue_options    => lv_DequeueOptions,
                         message_properties => lv_MessageProperties,
                         payload            => lv_wf_object,
                         msgid              => lv_MsgID);
      EXCEPTION
       WHEN e_QTimeOut Then
			null;
			GOTO l_continue_loop;
       WHEN OTHERS THEN
         rollback to workitem_q_tag;
     	 handle_dq_exception( p_MESSAGE_ID        => lv_MSGID ,
        	              p_WF_ITEM_TYPE      => null,
         	              p_WF_ITEM_KEY       => null,
        	              p_CALLER_NAME       => 'Start_WORKITEM_Workflow',
        	              p_CALLBACK_TEXT     => NULL ,
        	              p_Q_NAME            => 'XDP_WORKITEM_QUEUE',
        	              p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);

         raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
      END;

	  select status_code
	  into lv_state
	  from xdp_fulfill_worklist
	  where
	    workitem_instance_id = lv_wf_object.workitem_instance_id;

--	  if lv_state = 'SUSPENDED' THEN
--	  -- Update the msg delay to new high number
--	    null;
--	    rollback to workitem_q_tag;
	  if lv_state IN ('READY') THEN
		BEGIN
     		lv_DequeueOptions.msgid := lv_MsgID;
     		lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE_NODATA;

        	DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_WORKITEM_QUEUE',
         		         dequeue_options    => lv_DequeueOptions,
         		         message_properties => lv_MessageProperties,
         		         payload            => lv_tmp,
         		         msgid              => lv_MsgID);

			update XDP_FULFILL_WORKLIST
			   set last_updated_by      = FND_GLOBAL.USER_ID,
      			       last_update_date     = sysdate,
      			       last_update_login    = FND_GLOBAL.LOGIN_ID,
	  		       STATUS_CODE          = 'IN PROGRESS'
			 where workitem_instance_id = lv_wf_object.workitem_instance_id;

         	WF_ENGINE.StartProcess(
				lv_wf_object.wf_item_type,
				lv_wf_object.wf_item_key);
         	COMMIT;
		exception
		  when others then
	    	rollback to workitem_q_tag;
     	  	handle_dq_exception( p_MESSAGE_ID        => lv_MSGID ,
        		             p_WF_ITEM_TYPE      => lv_wf_object.wf_item_type,
         		             p_WF_ITEM_KEY       => lv_wf_object.wf_item_key,
        		             p_CALLER_NAME       => 'Start_WORKITEM_Workflow',
        		             p_CALLBACK_TEXT     => NULL ,
        		             p_Q_NAME            => 'XDP_WORKITEM_QUEUE',
        		             p_ERROR_DESCRIPTION => 'Can not start workflow: ' || SQLERRM);

         	raise_application_error(-20530, 'Can not start workflow: ' || SQLERRM);
		 end;
	   else
	    	rollback to workitem_q_tag;
	   end if;

   ELSIF lv_queue_state = 'SUSPENDED' THEN   -- Notify dequeuer to sleep
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'SHUTDOWN' THEN    -- notify dequeuer to exit
		return;
   ELSIF lv_queue_state = 'DISABLED' THEN    -- notify dequeuer to exit
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'DATA_NOT_FOUND' THEN    -- notify dequeuer to exit
		return;
   ELSE                                            -- notify dequeuer to exit
		return;
   END IF;

 <<l_continue_loop>>
 null;
 END LOOP;

END Start_Workitem_Workflow;

********/

PROCEDURE  Start_Workitem_Workflow (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     	    p_correlation_id IN VARCHAR2,
                             	    x_message_key OUT NOCOPY VARCHAR2,
                             	    x_queue_timed_out OUT NOCOPY VARCHAR2 )
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);

BEGIN

  savepoint workitem_q_tag;
  lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
  lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
  lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE;
  lv_DequeueOptions.MSGID := NULL;
  lv_DequeueOptions.correlation := p_correlation_id;

	BEGIN
        -- Set Dequeue time out to be 1 second
		lv_DequeueOptions.wait := p_message_wait_timeout;
		DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_WORKITEM_QUEUE',
         		         dequeue_options    => lv_DequeueOptions,
         		         message_properties => lv_MessageProperties,
         		         payload            => lv_wf_object,
         		         msgid              => lv_MsgID);
	EXCEPTION
	WHEN e_QTimeOut Then
		x_queue_timed_out := 'Y';
		return;
	WHEN OTHERS THEN
		rollback to workitem_q_tag;
		handle_dq_exception( p_MESSAGE_ID        => lv_MSGID ,
        		             p_WF_ITEM_TYPE      => null,
         		             p_WF_ITEM_KEY       => null,
        		             p_CALLER_NAME       => 'Start_WORKITEM_Workflow',
        		             p_CALLBACK_TEXT     => NULL ,
        		             p_Q_NAME            => 'XDP_WORKITEM_QUEUE',
        		             p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);

			raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);

	END;

        BEGIN
                SET_CONTEXT( lv_wf_object.order_id, 'ORDER_OBJECT');

        EXCEPTION
        WHEN stop_processing THEN
                x_queue_timed_out := 'Y';
                return;
        END;

	BEGIN

		if lv_wf_object.wf_item_type <> 'XDPPROV' then
			XDPSTATUS.UPDATE_XDP_WORKITEM_STATUS(
				p_status => 'IN PROGRESS',
				p_workitem_instance_id => lv_wf_object.workitem_instance_id);
		end if;

--              Commented out as this initialization is done in Work Item workflow  by spusegao on 08/07/01
--
--		update XDP_FULFILL_WORKLIST
--		set 	last_updated_by = FND_GLOBAL.USER_ID,
--			last_update_date = sysdate,
--			last_update_login = FND_GLOBAL.LOGIN_ID,
--	  		STATUS_CODE = 'IN PROGRESS'
--		where workitem_instance_id = lv_wf_object.workitem_instance_id;

--              Commented out as this evaluation id done in workitem workflow by spusegao on 08/07/01
--		xdp_engine.EvaluateWIParamsOnStart(lv_wf_object.workitem_instance_id);

		WF_ENGINE.StartProcess(
				lv_wf_object.wf_item_type,
				lv_wf_object.wf_item_key);
         	COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
		rollback to workitem_q_tag;
     	  	handle_dq_exception(
	  		p_MESSAGE_ID        => lv_MSGID ,
        		p_WF_ITEM_TYPE      => lv_wf_object.wf_item_type,
         		p_WF_ITEM_KEY       => lv_wf_object.wf_item_key,
        		p_CALLER_NAME       => 'Start_WORKITEM_Workflow',
        		p_CALLBACK_TEXT     => NULL ,
        		p_Q_NAME            => 'XDP_WORKITEM_QUEUE',
        		p_ERROR_DESCRIPTION => 'Can not start workflow: ' || SQLERRM);

         	raise_application_error(-20530,'Can not start workflow: '|| SQLERRM);
	END;


EXCEPTION
WHEN e_NothingToDequeueException then
          x_queue_timed_out := 'Y';
WHEN OTHERS THEN
  RAISE;
END Start_Workitem_Workflow;
--
--  Allow workitem workflow to register a FA through eq
--
PROCEDURE Add_FA_ToQ(
		p_order_id IN NUMBER,
		p_wi_instance_id IN NUMBER,
		p_fa_instance_id IN number,
		p_wf_item_type in VARCHAR2 ,
		p_wf_item_key  in VARCHAR2,
		p_priority  in number default 100,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_EnqueueOptions DBMS_AQ.ENQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
	lv_date date := sysdate;

-- Remove Later??
 	lv_fa_name varchar2(40);
  cursor c_GetFAName is
         select  xf.fulfillment_action fulfillment_action
           from xdp_fulfill_actions xf,
	        xdp_fa_runtime_list xfr
          where xfr.fa_instance_id = p_fa_instance_id
           and xfr.fulfillment_action_id = xf.fulfillment_action_id;

BEGIN
  p_return_code := 0;

  lv_wf_object := SYSTEM.XDP_WF_CHANNELQ_TYPE
                        ( NULL,
		          NULL,
		          p_wf_item_type,
		          p_wf_item_key,
		          NULL,
		          p_order_id,
		          p_wi_instance_id,
		          p_fa_instance_id);

-- Get Work Item for Correlation ID
  for v_GetFAName in c_GetFAName loop
        lv_fa_name := v_GetFAName.fulfillment_action;
  end loop;

-- Set the Correlation ID Message Property
     lv_MessageProperties.correlation := lv_fa_name;

-- Enqueue it with the commit on a seperate transaction.
     lv_EnqueueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_MessageProperties.exception_queue := G_XDP_SCHEMA||'.'||'XDP_FA_EXPQ';
     lv_MessageProperties.priority := NVL(p_priority,100);

    DBMS_AQ.ENQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_FA_QUEUE',
                     enqueue_options    => lv_EnqueueOptions,
                     message_properties => lv_MessageProperties,
                     payload            =>lv_wf_object,
                     msgid              => lv_MsgID);

	update XDP_FA_RUNTIME_LIST
	   set last_updated_by   = FND_GLOBAL.USER_ID,
               last_update_date  = sysdate,
               last_update_login = FND_GLOBAL.LOGIN_ID,
	       STATUS_CODE       = 'READY',
	       MSGID             = lv_MsgID
	where fa_instance_id     = p_fa_instance_id;

EXCEPTION
WHEN OTHERS THEN
	p_return_code := SQLCODE;
	p_error_description := SQLERRM;
END Add_FA_ToQ;



/*****  Commented out as this code is executed by C dequeuer
--
-- Used by API to start FA workflow
-- through dequeue
--
PROCEDURE Start_FA_Workflow
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
 	lv_return_code NUMBER;
 	lv_count2 NUMBER;
 	lv_error_description VARCHAR2(2000);
 	lv_queue_state varchar2(200);
 	lv_state varchar2(200);

BEGIN

 while 1=1 loop
   lv_queue_state := Get_Queue_State('XDP_FA_QUEUE');
   IF lv_queue_state = 'ENABLED' THEN -- proceed
     savepoint fa_q_tag;
     lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
     lv_DequeueOptions.dequeue_mode := DBMS_AQ.LOCKED;
     lv_DequeueOptions.MSGID := NULL;

     BEGIN
        -- Set Dequeue time out to be 1 second
        lv_DequeueOptions.wait := xnp_message.POP_TIMEOUT;

        DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_FA_QUEUE',
                         dequeue_options    => lv_DequeueOptions,
                         message_properties => lv_MessageProperties,
                         payload            => lv_wf_object,
                         msgid              => lv_MsgID);

      EXCEPTION
       WHEN e_QTimeOut Then
         null;
		GOTO l_continue_loop;
       WHEN OTHERS THEN
         rollback to pending_q_tag;
     	 handle_dq_exception( p_MESSAGE_ID        => lv_MSGID ,
        	              p_WF_ITEM_TYPE      => null,
         	              p_WF_ITEM_KEY       => null,
       		              p_CALLER_NAME       => 'Start_FA_Workflow',
       		              p_CALLBACK_TEXT     => NULL ,
       		              p_Q_NAME            => 'XDP_FA_QUEUE',
        	              p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);

         raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
      END;

          SELECT status_code
	    INTO lv_state
	    FROM xdp_fa_runtime_list
	   WHERE fa_instance_id = lv_wf_object.fa_instance_id;

--	  if lv_state = 'SUSPENDED' THEN
--	  -- Update the msg delay to new high number
--	    null;
--	    rollback to fa_q_tag;
	  if lv_state = 'READY' THEN
		BEGIN
     		lv_DequeueOptions.msgid := lv_MsgID;
     		lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE_NODATA;

        	DBMS_AQ.DEQUEUE(queue_name         => G_XDP_SCHEMA||'.'||'XDP_FA_QUEUE',
         		        dequeue_options    => lv_DequeueOptions,
         		        message_properties => lv_MessageProperties,
         		        payload            => lv_tmp,
         		        msgid              => lv_MsgID);

         	WF_ENGINE.StartProcess(
				lv_wf_object.wf_item_type,
				lv_wf_object.wf_item_key);
         	COMMIT;
		EXCEPTION
		     when others then
	    	          rollback to fa_q_tag;
     	  	          handle_dq_exception( p_MESSAGE_ID       => lv_MSGID ,
        		                       p_WF_ITEM_TYPE     => lv_wf_object.wf_item_type,
         		                       p_WF_ITEM_KEY      => lv_wf_object.wf_item_key,
       			                       p_CALLER_NAME      => 'Start_FA_Workflow',
       			                       p_CALLBACK_TEXT    => NULL ,
       			                       p_Q_NAME           => 'XDP_FA_QUEUE',
        		                       p_ERROR_DESCRIPTION => 'Can not start workflow: ' || SQLERRM);
         	         raise_application_error(-20530,'Can not start workflow: ' || SQLERRM);
		 END;
	   else
	    	rollback to fa_q_tag;
	   end if;

   ELSIF lv_queue_state = 'SUSPENDED' THEN  --  notify dequeuer to sleep
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'SHUTDOWN' THEN  --  notify dequeuer to exit
		return;
   ELSIF lv_queue_state = 'DISABLED' THEN  --  notify dequeuer to exit
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'DATA_NOT_FOUND' THEN  --  notify dequeuer to exit
		return;
   ELSE                                           -- notify dequeuer to exit
		return;
   END IF;

 <<l_continue_loop>>
 null;
 END LOOP;

END Start_FA_Workflow;

******/


PROCEDURE  Start_FA_Workflow (  p_message_wait_timeout IN NUMBER DEFAULT 1,
				p_correlation_id IN VARCHAR2,
				x_message_key OUT NOCOPY VARCHAR2,
				x_queue_timed_out OUT NOCOPY VARCHAR2 )
IS
 	lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);

BEGIN

  savepoint fa_q_tag;
  lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
  lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
  lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE;
  lv_DequeueOptions.MSGID := NULL;
  lv_DequeueOptions.correlation := p_correlation_id;

	BEGIN
        -- Set Dequeue time out to be 1 second
       		lv_DequeueOptions.wait := p_message_wait_timeout;

		DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_FA_QUEUE',
         		         dequeue_options    => lv_DequeueOptions,
         		         message_properties => lv_MessageProperties,
         		         payload            => lv_wf_object,
         		         msgid              => lv_MsgID);
	EXCEPTION
	     WHEN e_QTimeOut THEN
	          x_queue_timed_out := 'Y';
	          return;
	     WHEN OTHERS THEN
		rollback to pending_q_tag;
		handle_dq_exception(
	  		p_MESSAGE_ID => lv_MSGID ,
        		p_WF_ITEM_TYPE => null,
         		p_WF_ITEM_KEY => null,
       			p_CALLER_NAME => 'Start_FA_Workflow',
       			p_CALLBACK_TEXT => NULL ,
       			p_Q_NAME => 'XDP_FA_QUEUE',
        		p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);

		raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
	END;

        BEGIN
                SET_CONTEXT( lv_wf_object.order_id, 'ORDER_OBJECT');

        EXCEPTION
        WHEN stop_processing THEN
                x_queue_timed_out := 'Y';
                return;
        END;


	BEGIN

		WF_ENGINE.StartProcess( lv_wf_object.wf_item_type,
					lv_wf_object.wf_item_key);

		COMMIT;
	EXCEPTION
	WHEN OTHERS THEN
		rollback to fa_q_tag;
     	  	handle_dq_exception(
	  		p_MESSAGE_ID => lv_MSGID ,
        		p_WF_ITEM_TYPE => lv_wf_object.wf_item_type,
         		p_WF_ITEM_KEY => lv_wf_object.wf_item_key,
       			p_CALLER_NAME => 'Start_FA_Workflow',
       			p_CALLBACK_TEXT => NULL ,
       			p_Q_NAME => 'XDP_FA_QUEUE',
        		p_ERROR_DESCRIPTION => 'Can not start workflow: ' || SQLERRM);

         	raise_application_error(-20530, 'Can not start workflow: ' || SQLERRM);
	END;

EXCEPTION
WHEN e_NothingToDequeueException then
          x_queue_timed_out := 'Y';
WHEN OTHERS THEN
  RAISE;
END Start_FA_Workflow;
--
-- Allow WF to pass the pipe to next WF through enqueue
--
PROCEDURE HANDOVER_CHANNEL(
		p_channel_name IN  VARCHAR2,
		p_fe_name  IN    VARCHAR2,
		p_wf_item_type IN VARCHAR2,
		p_wf_item_key IN  VARCHAR2,
		p_wf_activity IN Varchar2 Default NULL,
		p_order_id IN number,
		p_wi_instance_id IN number,
		p_fa_instance_id IN number,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)  IS

 lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 lv_EnqueueOptions DBMS_AQ.ENQUEUE_OPTIONS_T;
 lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 lv_MsgID RAW(16);
lv_jobNum NUMBER;

BEGIN

  p_return_code := 0;
  lv_wf_object := SYSTEM.XDP_WF_CHANNELQ_TYPE(
		p_channel_name,
		p_fe_name,
		p_wf_item_type,
		p_wf_item_key,
		p_wf_activity,
		p_order_id,
		p_wi_instance_id,
		p_fa_instance_id);

-- Enqueue it with the commit on a seperate transaction.
     lv_EnqueueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_MessageProperties.exception_queue := G_XDP_SCHEMA||'.'||'XDP_Channel_Exception_Q';
     if p_fe_name is not null then
       lv_MessageProperties.correlation := XDP_ADAPTER_CORE_DB.pv_InstanceName || ':' || p_fe_name;
     else
       lv_MessageProperties.correlation := XDP_ADAPTER_CORE_DB.pv_InstanceName;
     end if;
    DBMS_AQ.ENQUEUE(
      queue_name => G_XDP_SCHEMA||'.'||'XDP_WF_CHANNEL_Q',
      enqueue_options => lv_EnqueueOptions,
      message_properties => lv_MessageProperties,
      payload =>lv_wf_object,
      msgid => lv_MsgID);

--  Change status of the FA Instance to 'READY_FOR_RESOURCE'

   UPDATE xdp_fa_runtime_list
      SET status_code = 'READY_FOR_RESOURCE' ,
	  msgid = lv_MsgID
    WHERE fa_instance_id = p_fa_instance_id ;


 EXCEPTION
 WHEN OTHERS THEN
   p_return_code := SQLCODE;
  p_error_description := SQLERRM;
END  HANDOVER_Channel;


/*****  Commented out as this code is executed by C dequeuer
--
-- Used by DB job to resume a WF with the new pipe
-- through dequeue
--
PROCEDURE Resume_Next_WF IS

 lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 lv_MsgID RAW(16);
 lv_return_code NUMBER;
 lv_error_description VARCHAR2(2000);
 lv_queue_state varchar2(200);
  lv_fa_state varchar2(80);
  lv_wi_state varchar2(80);

BEGIN

 WHILE 1 = 1 LOOP
  BEGIN
   lv_queue_state := Get_Queue_State('XDP_WF_CHANNEL_Q');
   IF lv_queue_state = 'ENABLED' THEN    ----  proceed
      BEGIN
        SAVEPOINT resume_wf1;
        lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
        lv_DequeueOptions.navigation := DBMS_AQ.NEXT_MESSAGE;

        -- Set Dequeue time out to be 1 second
        lv_DequeueOptions.wait := xnp_message.POP_TIMEOUT;
         BEGIN

          DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_WF_Channel_Q',
                           dequeue_options    => lv_DequeueOptions,
                           message_properties => lv_MessageProperties,
                           payload            => lv_wf_object,
                           msgid              => lv_MsgID);

          EXCEPTION
             When e_QNavOut Then
                  lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
                  lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;

           -- Set Dequeue time out to be 1 second
           lv_DequeueOptions.wait := xnp_message.POP_TIMEOUT;
           DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_WF_Channel_Q',
                            dequeue_options    => lv_DequeueOptions,
                            message_properties => lv_MessageProperties,
                            payload            => lv_wf_object,
                            msgid              => lv_MsgID);
         END;
      EXCEPTION
       WHEN e_QTimeOut Then
		 GOTO l_continue_loop;
       WHEN OTHERS THEN
         rollback to resume_wf1;
     	   handle_dq_exception(
	  		p_MESSAGE_ID => NULL ,
        		p_WF_ITEM_TYPE => NULL,
         		p_WF_ITEM_KEY => NULL,
        		p_CALLER_NAME => 'Resume_Next_WF',
        		p_CALLBACK_TEXT => NULL ,
        		p_Q_NAME => 'XDP_WF_Channel_Q',
        		p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);
         raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
      END;

      SELECT frt.status_code,
             fwt.status_code
        INTO lv_fa_state,
             lv_wi_state
        FROM xdp_fa_runtime_list frt,
             xdp_fulfill_worklist fwt
       WHERE fa_instance_id           = lv_wf_object.fa_instance_id
         AND frt.workitem_instance_id = fwt.workitem_instance_id;

      IF (lv_fa_state <> 'CANCELED' OR
          lv_fa_state <> 'ABORTED' ) THEN
        -- And resume work flow.
         SDP_Resume_WF(lv_wf_object.channel_name,
                       lv_wf_object.wf_item_type,
                       lv_wf_object.wf_item_key,
                       lv_wf_object.wf_activity_name,
                       lv_MessageProperties.enqueue_time,
                       lv_return_code,
                       lv_error_description);

          IF lv_return_code <> 0 THEN
           ROLLBACK to resume_wf1;
	     handle_dq_exception( p_MESSAGE_ID => lv_MsgID ,
          		        p_WF_ITEM_TYPE => lv_wf_object.wf_item_type,
           		        p_WF_ITEM_KEY => lv_wf_object.wf_item_key,
          		        p_CALLER_NAME => 'Resume_Next_WF',
          		        p_CALLBACK_TEXT => NULL ,
          		        p_Q_NAME => 'XDP_WF_Channel_Q',
        		        p_ERROR_DESCRIPTION => lv_error_description);
           raise_application_error(-20530,lv_error_description);
          END IF;
      ELSE
         -- Handover the channel to the next one
         null;
	   XDPCORE_FA.HandOverChannel (
			 lv_wf_object.channel_name,
                   0,
                   NULL,
                   'ADMIN',
                   lv_return_code,
                   lv_error_description);
      END IF;
     commit;

   ELSIF lv_queue_state = 'SUSPENDED' THEN         --  notify dequeuer to sleep
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'SHUTDOWN' THEN          --  notify dequeuer to exit
		return;
   ELSIF lv_queue_state = 'DISABLED' THEN          --  notify dequeuer to exit
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'DATA_NOT_FOUND' THEN    --  notify dequeuer to exit
		return;
   ELSE                                            --  notify dequeuer to exit
		return;
   END IF;

 <<l_continue_loop>>
 null;
 EXCEPTION
 WHEN OTHERS THEN
   raise;
 END;
END LOOP;                --- END of infinite loop

END Resume_Next_WF;

********/

PROCEDURE  Resume_Next_WF (p_message_wait_timeout IN NUMBER DEFAULT 1,
			   p_correlation_id IN VARCHAR2,
                           x_message_key OUT NOCOPY VARCHAR2,
                           x_queue_timed_out OUT NOCOPY VARCHAR2 )
IS
 lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
 lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 lv_MsgID RAW(16);

 lv_fa_state varchar2(40);
 lv_return_code NUMBER;
 lv_error_description VARCHAR2(2000);

 lv_high_avail BOOLEAN;

BEGIN

  savepoint resume_wf;
  lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
  lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
  if p_correlation_id is not null then
    lv_DequeueOptions.correlation := XDP_ADAPTER_CORE_DB.pv_InstanceName || ':' || p_correlation_id;
  else
    lv_DequeueOptions.correlation := XDP_ADAPTER_CORE_DB.pv_InstanceName || '%';
  end if;
  lv_DequeueOptions.wait := p_message_wait_timeout;
  lv_high_avail := false;

	BEGIN
		DBMS_AQ.DEQUEUE(
			queue_name => G_XDP_SCHEMA||'.'||'XDP_WF_Channel_Q',
			dequeue_options => lv_DequeueOptions,
         		message_properties => lv_MessageProperties,
         		payload => lv_wf_object,
         		msgid => lv_MsgID);
	EXCEPTION
	WHEN e_QTimeOut Then
		x_queue_timed_out := 'Y';
		return;
	WHEN OTHERS THEN
		rollback to resume_wf;
		handle_dq_exception(
	  		p_MESSAGE_ID => NULL ,
        		p_WF_ITEM_TYPE => NULL,
         		p_WF_ITEM_KEY => NULL,
        		p_CALLER_NAME => 'Resume_Next_WF',
        		p_CALLBACK_TEXT => NULL ,
        		p_Q_NAME => 'XDP_WF_Channel_Q',
        		p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);

         	raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
	END;

	BEGIN
		SET_CONTEXT( lv_wf_object.order_id, 'ORDER_OBJECT');

        EXCEPTION
        WHEN stop_processing THEN
			x_queue_timed_out := 'Y';
                        lv_high_avail := true;
	END;

	SELECT frt.status_code
	INTO lv_fa_state
	FROM xdp_fa_runtime_list frt
	WHERE fa_instance_id = lv_wf_object.fa_instance_id;

	IF (lv_fa_state <> 'CANCELED' AND lv_fa_state <> 'ABORTED' AND lv_high_avail <> TRUE) THEN
	-- And resume work flow.
		SDP_Resume_WF(  lv_wf_object.channel_name,
                   		lv_wf_object.wf_item_type,
                   		lv_wf_object.wf_item_key,
                   		lv_wf_object.wf_activity_name,
                   		lv_MessageProperties.enqueue_time,
                   		lv_return_code,
                   		lv_error_description);

		IF lv_return_code <> 0 THEN
			ROLLBACK to resume_wf;
			handle_dq_exception(
	  			p_MESSAGE_ID => lv_MsgID ,
        			p_WF_ITEM_TYPE => lv_wf_object.wf_item_type,
         			p_WF_ITEM_KEY => lv_wf_object.wf_item_key,
        			p_CALLER_NAME => 'Resume_Next_WF',
        			p_CALLBACK_TEXT => NULL ,
        			p_Q_NAME => 'XDP_WF_Channel_Q',
        			p_ERROR_DESCRIPTION => lv_error_description);

			raise_application_error(-20530,lv_error_description);
		END IF;
	ELSE
         /* Handover the channel to the next one */
		XDPCORE_FA.HandOverChannel (
				lv_wf_object.channel_name,
				0,
				NULL,
				'ADMIN',
				lv_return_code,
				lv_error_description);
	END IF;


	COMMIT;


EXCEPTION
WHEN e_NothingToDequeueException then
          x_queue_timed_out := 'Y';
WHEN OTHERS THEN
  RAISE;
END Resume_Next_WF;


-- PL/SQL Block

PROCEDURE SDP_RESUME_WF
 (p_pipe_name IN VARCHAR2
 ,p_wf_item_type IN VARCHAR2
 ,p_wf_item_key  IN VARCHAR2
 ,p_wf_activity  IN VARCHAR2
 ,p_enq_time IN DATE
 ,P_RETURN_CODE OUT NOCOPY NUMBER
 ,P_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
 )
 IS

-- PL/SQL Block

BEGIN
  p_return_code := 0;

   wf_engine.SetItemAttrText(itemtype => p_wf_item_type,
                             itemkey => p_wf_item_key,
                             aname => 'CHANNEL_NAME',
                             avalue => p_pipe_name);

/*********

   wf_engine.SetItemAttrDate(itemtype => p_wf_item_type,
                             itemkey => p_wf_item_key,
                             aname => 'RE_PROCESS_ENQ_TIME',
                             avalue => p_enq_time);
********/

    wf_engine.CompleteActivity(itemtype => p_wf_item_type,
				   itemkey    => p_wf_item_key,
				   activity   => p_wf_activity,
				   result     => 'RESUME_PROVISIONING');
  COMMIT;

 EXCEPTION
  WHEN OTHERS THEN
      p_return_code := SQLCODE;
      p_error_description := SQLERRM;
END SDP_RESUME_WF;

--
--  Allow workflow to register a notification event through eq
--
PROCEDURE Resume_WF_EQ(
                p_event_id number,
		p_wf_item_type VARCHAR2 ,
                p_wf_item_key  VARCHAR2,
		p_wf_activity  VARCHAR2,
		p_callback VARCHAR2,
		p_priority number default 100,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2)
IS
 lv_wf_object SYSTEM.XDP_WF_RESUMEQ_TYPE;
 lv_EnqueueOptions DBMS_AQ.ENQUEUE_OPTIONS_T;
 lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 lv_MsgID RAW(16);
 lv_jobNum NUMBER;

BEGIN

  p_return_code := 0;
  lv_wf_object := SYSTEM.XDP_WF_RESUMEQ_TYPE(
            event_id => p_event_id,
		callback => p_callback,
            wf_item_type => p_wf_item_type,
            wf_item_key => p_wf_item_key,
		wf_activity_name => p_wf_activity,
            error_description => NULL);

-- Enqueue it with the commit on a seperate transaction.
     lv_EnqueueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_MessageProperties.exception_queue := G_XDP_SCHEMA||'.'||'XDP_WF_SEQUENCING_ExpQ';
     lv_MessageProperties.priority := p_priority;

    DBMS_AQ.ENQUEUE(
      queue_name => G_XDP_SCHEMA||'.'||'XDP_WF_SEQUENCING_Q',
      enqueue_options => lv_EnqueueOptions,
      message_properties => lv_MessageProperties,
      payload =>lv_wf_object,
      msgid => lv_MsgID);

EXCEPTION
 WHEN OTHERS THEN
	p_return_code := SQLCODE;
	p_error_description := SQLERRM;
END Resume_WF_EQ;

--
-- Used by API to notify the parent workflow to resume
-- through dequeue
--
PROCEDURE Resume_Parent_Workflow
IS
 lv_wf_object SYSTEM.XDP_WF_RESUMEQ_TYPE;
 lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 lv_EnqueueOptions DBMS_AQ.ENQUEUE_OPTIONS_T;
 lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 lv_MsgID RAW(16);
 lv_return_code NUMBER;
 lv_error_description VARCHAR2(2000);
 lv_queue_state varchar2(200);
BEGIN

 while 1=1 loop
-- Check queue state
   lv_queue_state := Get_Queue_State('XDP_WF_SEQUENCING_Q');

   IF lv_queue_state = 'ENABLED' THEN /*proceed*/
    BEGIN
      lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
      lv_DequeueOptions.navigation := DBMS_AQ.NEXT_MESSAGE;

     -- Set Dequeue time out to be 2 second
      lv_DequeueOptions.wait := xnp_message.POP_TIMEOUT;
      BEGIN
         DBMS_AQ.DEQUEUE(
          queue_name => G_XDP_SCHEMA||'.'||'XDP_WF_SEQUENCING_Q',
          dequeue_options => lv_DequeueOptions,
          message_properties => lv_MessageProperties,
          payload => lv_wf_object,
          msgid => lv_MsgID);
        EXCEPTION
        WHEN e_QNavOut THEN
       -- Dequeue it with the commit on a seperate transaction.
          lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
          lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;

       -- Set Dequeue time out to be 2 second
          lv_DequeueOptions.wait := xnp_message.POP_TIMEOUT;
          DBMS_AQ.DEQUEUE(
           queue_name => G_XDP_SCHEMA||'.'||'XDP_WF_SEQUENCING_Q',
           dequeue_options => lv_DequeueOptions,
           message_properties => lv_MessageProperties,
           payload => lv_wf_object,
           msgid => lv_MsgID);
        END;
      EXCEPTION
       WHEN e_QTimeOut Then
        null;
		 GOTO l_continue_loop;
       WHEN OTHERS THEN
         rollback;
     	   handle_dq_exception(
	  		p_MESSAGE_ID => NULL ,
        		p_WF_ITEM_TYPE => NULL,
         		p_WF_ITEM_KEY => NULL,
        		p_CALLER_NAME => 'Resume_Parent_Workflow',
        		p_CALLBACK_TEXT => NULL ,
        		p_Q_NAME => 'XDP_WF_SEQUENCING_Q',
        		p_ERROR_DESCRIPTION => 'Can not dequeue: ' || SQLERRM);
         raise_application_error(-20530,'Can not dequeue: ' || SQLERRM);
      END;

      /*XDP_Utilities.Execute_Any_DDL(
				p_ddl_block => lv_wf_object.callback,
				return_code => lv_return_code,
				error_description => lv_error_description);

     IF lv_return_code <> 0 THEN
       rollback;
	 handle_dq_exception(
	  		p_MESSAGE_ID        => lv_MsgID ,
        		p_WF_ITEM_TYPE      => lv_wf_object.wf_item_type,
         		p_WF_ITEM_KEY       => lv_wf_object.wf_item_key,
        		p_CALLER_NAME       => 'Resume_Parent_Workflow',
        		p_CALLBACK_TEXT     => lv_wf_object.callback ,
        		p_Q_NAME            => 'XDP_WF_SEQUENCING_Q',
        		p_ERROR_DESCRIPTION => lv_error_description);
       raise_application_error(-20530,lv_error_description);
     END IF;*/

     BEGIN
        wf_engine.CompleteActivity( itemtype => lv_wf_object.wf_item_type,
  			            itemkey => lv_wf_object.wf_item_key,
            	                    activity => lv_wf_object.wf_activity_name,
                 	            result => 'RESUME_PROVISIONING');
      commit;

     exception
     when others then
       rollback;
	 handle_dq_exception(
	  		p_MESSAGE_ID => lv_MsgID ,
        		p_WF_ITEM_TYPE => lv_wf_object.wf_item_type,
         		p_WF_ITEM_KEY => lv_wf_object.wf_item_key,
        		p_CALLER_NAME => 'Resume_Parent_Workflow',
        		p_CALLBACK_TEXT => lv_wf_object.callback ,
        		p_Q_NAME => 'XDP_WF_SEQUENCING_Q',
        		p_ERROR_DESCRIPTION => SQLERRM);
       raise_application_error(-20530,SQLERRM);
     END;

   ELSIF lv_queue_state = 'SUSPENDED' THEN /* notify dequeuer to sleep */
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'SHUTDOWN' THEN /* notify dequeuer to exit */
		return;
   ELSIF lv_queue_state = 'DISABLED' THEN /* notify dequeuer to exit */
		dbms_lock.sleep(3);
   ELSIF lv_queue_state = 'DATA_NOT_FOUND' THEN /* notify dequeuer to exit */
		return;
   ELSE /* notify dequeuer to exit */
		return;
   END IF;

 <<l_continue_loop>>
 null;
 END LOOP;


END Resume_Parent_Workflow;


--
-- Interface with the OSS System with the order information and its type
--
PROCEDURE InterfaceWithOSS (
          p_OrderID NUMBER,
          p_ObjectType VARCHAR2,
          p_ReturnCode OUT NOCOPY NUMBER,
          p_ErrorDescription OUT NOCOPY VARCHAR2) IS

 l_OrderObj SYSTEM.XDP_ORDER_OBJ;
 l_EnqueueOptions DBMS_AQ.ENQUEUE_OPTIONS_T;
 l_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 l_MsgID RAW(16);

BEGIN

 l_OrderObj := SYSTEM.XDP_ORDER_OBJ(
               p_OrderID,
               p_ObjectType);

 l_EnqueueOptions.visibility := DBMS_AQ.ON_COMMIT;
 l_MessageProperties.exception_queue := G_XDP_SCHEMA||'.'||'XDP_ORDER_OBJ_Excep_Q';


 DBMS_AQ.ENQUEUE (
      queue_name => G_XDP_SCHEMA||'.'||'XDP_ORDER_OBJ_Q',
      enqueue_options => l_EnqueueOptions,
      message_properties => l_MessageProperties,
      payload => l_OrderObj,
      msgid => l_MsgID);

EXCEPTION
WHEN OTHERS THEN
 p_ReturnCode := SQLCODE;
 p_ErrorDescription := SUBSTR(SQLERRM,1,200);
END InterfaceWithOSS;

--
--  Get the current state of the given queue
--
FUNCTION Get_Queue_State(
		p_queue_name IN VARCHAR2)
 RETURN VARCHAR2
IS
  lv_q_state varchar2(200);
BEGIN

  SELECT state
    INTO lv_q_state
    FROM XDP_dq_configuration
   WHERE internal_q_name = p_queue_name;

  RETURN lv_q_state;

 exception
 when NO_DATA_FOUND THEN
   lv_q_state := 'NO_DATA_FOUND';
   rollback to my_get_state;
   return lv_q_state;
 when others then
   lv_q_state := SQLERRM;
   rollback to my_get_state;
   return lv_q_state;

END Get_Queue_State;

--
--  Disable a given queue, if queue_name is not supplied,
--  all queues will be disabled
--
PROCEDURE DISABLE_SDP_AQ(
		p_queue_name IN VARCHAR2,
		p_return_code OUT NOCOPY NUMBER,
            p_error_description OUT NOCOPY VARCHAR2)
IS
  lv_exists varchar2(1);
  CURSOR lc_q IS
   select rowid
   from xdp_dq_configuration;

BEGIN

    p_return_code := 0;
    if p_queue_name is not null then
      update XDP_dq_configuration
      set last_updated_by = FND_GLOBAL.USER_ID,
      last_update_date = sysdate,
      last_update_login = FND_GLOBAL.LOGIN_ID,
      state = 'DISABLED'
      where internal_q_name = UPPER(p_queue_name);
    else
	FOR lv_rec in lc_q loop
        update XDP_dq_configuration
        set state = 'DISABLED',
      	last_updated_by = FND_GLOBAL.USER_ID,
      	last_update_date = sysdate,
      	last_update_login = FND_GLOBAL.LOGIN_ID
	  where rowid = lv_rec.rowid;
	  COMMIT;
	END LOOP;
    end if;

EXCEPTION
WHEN OTHERS THEN
 p_Return_Code := SQLCODE;
 p_Error_Description := SUBSTR(SQLERRM,1,200);
END DISABLE_SDP_AQ;


--
--  Enable a given queue, if queue_name is not supplied,
--  all queues will be enabled
--
PROCEDURE ENABLE_SDP_AQ(
		p_queue_name IN VARCHAR2,
		p_return_code OUT NOCOPY NUMBER,
            p_error_description OUT NOCOPY VARCHAR2)
IS
  lv_exists varchar2(1);
  CURSOR lc_q IS
   select rowid
   from xdp_dq_configuration;

BEGIN

    p_return_code := 0;
    if p_queue_name is not null then
      update XDP_dq_configuration
      set state = 'ENABLED',
      last_updated_by = FND_GLOBAL.USER_ID,
      last_update_date = sysdate,
      last_update_login = FND_GLOBAL.LOGIN_ID
      where internal_q_name = UPPER(p_queue_name);
    else
	FOR lv_rec IN lc_q LOOP
        update XDP_dq_configuration
        set state = 'ENABLED',
      last_updated_by = FND_GLOBAL.USER_ID,
      last_update_date = sysdate,
      last_update_login = FND_GLOBAL.LOGIN_ID
	  where rowid = lv_rec.rowid;
	  COMMIT;
      END LOOP;
    end if;

EXCEPTION
WHEN OTHERS THEN
 p_Return_Code := SQLCODE;
 p_Error_Description := SUBSTR(SQLERRM,1,200);
END ENABLE_SDP_AQ;


--
--  Shut down a given SFM queue, if queue_name is not supplied,
--  all queues will be shutdown
--
PROCEDURE SHUTDOWN_SDP_AQ(
		p_queue_name IN VARCHAR2,
		p_return_code OUT NOCOPY NUMBER,
            p_error_description OUT NOCOPY VARCHAR2)
IS
  CURSOR lc_q IS
   select rowid
   from xdp_dq_configuration;

BEGIN
    p_return_code := 0;
    if p_queue_name is not null then
      update XDP_dq_configuration
      set state = 'SHUTDOWN',
      last_updated_by = FND_GLOBAL.USER_ID,
      last_update_date = sysdate,
      last_update_login = FND_GLOBAL.LOGIN_ID
      where internal_q_name = UPPER(p_queue_name);
    else
      FOR lv_rec IN lc_q LOOP
        update XDP_dq_configuration
        set state = 'SHUTDOWN',
      last_updated_by = FND_GLOBAL.USER_ID,
      last_update_date = sysdate,
      last_update_login = FND_GLOBAL.LOGIN_ID
	  where rowid = lv_rec.rowid;
        COMMIT;
      END LOOP;
    end if;


EXCEPTION
WHEN OTHERS THEN
 p_Return_Code := SQLCODE;
 p_Error_Description := SUBSTR(SQLERRM,1,200);
END SHUTDOWN_SDP_AQ;

--
--  Log the dequeue exceptions for the dequeuer
--  and disable the queue
--
PROCEDURE HANDLE_DQ_Exception(
	  	p_MESSAGE_ID  IN RAW,
        	p_WF_ITEM_TYPE IN VARCHAR2 DEFAULT NULL,
        	p_WF_ITEM_KEY  IN VARCHAR2 DEFAULT NULL,
        	p_CALLER_NAME  IN VARCHAR2,
        	p_CALLBACK_TEXT  IN VARCHAR2 DEFAULT NULL,
        	p_Q_NAME IN VARCHAR2,
        	p_ERROR_DESCRIPTION  IN VARCHAR2,
        	p_ERROR_TIME  IN DATE  DEFAULT sysdate )

IS

  lv_ret number;
  lv_err varchar2(300);
  -- lv_MessageList XDP_TYPES.MESSAGE_TOKEN_LIST;
  x_parameters varchar2(4000);
  lv_ref_id number := 0;
BEGIN

null;
-- Commented out - sacsharm - 11.5.6 changes
-- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'DQ_ERROR';
-- lv_MessageList(1).MESSAGE_TOKEN_VALUE := p_error_description;
-- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_DQ_ERROR',
--                              p_message_ref_id => lv_ref_id,
--                              p_message_param_list => lv_MessageList,
--                              p_appl_name => 'XDP',
--                              p_sql_code => lv_ret,
--                              p_sql_desc => lv_err);
-- Commented out - adabholk - 11.5.6 changes
-- We may remove this procedure completely . Needs to be evaluated.
--
--	x_parameters := 'DQ_ERROR='||p_error_description||'#XDP#';
--	XDP_ERRORS_PKG.Set_Message(p_object_type => 'QUEUE',
--			     p_object_key => p_q_name,
--			     p_message_name => 'XDP_DQ_ERROR',
--                             p_message_parameters => x_parameters);
--
--       insert into XDP_dq_exceptions(
--   			created_by,
--   			creation_date,
--   			last_updated_by,
--   			last_update_date,
--   			last_update_login,
--	  		MESSAGE_ID,
--       			WF_ITEM_TYPE,
--       			WF_ITEM_KEY,
--       			CALLER_NAME ,
--       			CALLBACK_TEXT ,
--       			Q_NAME ,
--			error_ref_id)
--	               values(
--			FND_GLOBAL.USER_ID,
--			sysdate,
--			FND_GLOBAL.USER_ID,
--			sysdate,
--			FND_GLOBAL.LOGIN_ID,
--	  		p_MESSAGE_ID  ,
--       			p_WF_ITEM_TYPE,
--       			p_WF_ITEM_KEY,
--       			p_CALLER_NAME ,
--       			p_CALLBACK_TEXT  ,
--       			p_Q_NAME ,
--			lv_ref_id);
--
--       DISABLE_SDP_AQ( p_q_name ,
--		       lv_ret,
--                       lv_err);
--
--       COMMIT;
--
--      if lv_ret <> 0 THEN
--        raise_application_error(-20530,lv_err,TRUE);
--      end if;
--
-- exception
-- when others then
--   raise;
END Handle_DQ_Exception;

Procedure LogCommandAuditTrail (FAInstanceID  in  number,
                                FeName in  varchar2,
                                FeType in  varchar2,
                                SW_Generic in  varchar2,
                                CommandSent in  varchar2,
                                SentDate in  DATE,
                                Response in  varchar2,
                                ResponseLong in  CLOB,
                                RespDate in  DATE,
                                ProcName in  varchar2)
is

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_response_id      number;
 l_FeName          varchar2(80);
 l_FeType          varchar2(80);
 l_SW_Generic       varchar2(80);
 l_CommandSent     varchar2(32767);
 l_Response         varchar2(32767);
begin

  IF FeName IS NULL then
    l_FeName := 'GOT NULL FE NAME';
  ELSE
    l_FeName := FeName;
 end IF;


 IF FeType IS NULL then
    l_FeType := 'GOT NULL FE TYPE';
 ELSE
    l_FeType := FeType;
 end IF;

 IF SW_Generic IS NULL then
    l_SW_Generic := 'GOT NULL SW_GENERIC';
 ELSE
    l_SW_Generic := SW_Generic;
 end IF;

 IF CommandSent IS NULL then
    l_CommandSent := 'GOT NULL Command to be sent';
 ELSE
    l_CommandSent := CommandSent;
 end IF;

 IF Response IS NULL then
    l_Response := 'GOT NULL Response from the NE';
 ELSE
    l_Response := substr(Response,1,3999);
 end IF;

 /*
  * Insert into the audit trail table.
  */
 INSERT INTO XDP_FE_CMD_AUD_TRAILS (
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               fa_instance_id,
               fe_command_seq,
               fulfillment_element_name,
               fulfillment_element_type,
               sw_generic,
               command_sent,
               command_sent_date,
               response,
	       response_long,
               response_date,
               provisioning_procedure)
              VALUES (
	       FND_GLOBAL.USER_ID,
	       sysdate,
	       FND_GLOBAL.USER_ID,
	       sysdate,
	       FND_GLOBAL.LOGIN_ID,
               FAInstanceID,
               XDP_FE_CMD_AUD_TRAILS_S.NEXTVAL,
               l_FeName,
               l_FeType,
               l_Sw_Generic,
               l_CommandSent,
               SentDate,
               l_Response,
               ResponseLong,
               RespDate,
               ProcName);

 commit;

exception
when others then
	xdp_utilities.generic_error('XDP_AQ_UTILITIES.LogCommandAuditTrail',
				    'FA Instance: ' || FAInstanceID,
				    sqlcode,
				    sqlerrm);
END LogCommandAuditTrail;


Procedure LogCommandAuditTrail (FAInstanceID  in  number,
                                FeName in  varchar2,
                                FeType in  varchar2,
                                SW_Generic in  varchar2,
                                CommandSent in  varchar2,
                                SentDate in  DATE,
                                Response in  varchar2,
                                RespDate in  DATE,
                                ProcName in  varchar2)
is

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_response_id      number;
 l_FeName          varchar2(80);
 l_FeType          varchar2(80);
 l_SW_Generic       varchar2(80);
 l_CommandSent     varchar2(32767);
 l_Response         varchar2(32767);
 l_ResponseLong         varchar2(32767);
begin

  IF FeName IS NULL then
    l_FeName := 'GOT NULL FE NAME';
 ELSE
    l_FeName := FeName;
 end IF;


 IF FeType IS NULL then
    l_FeType := 'GOT NULL FE TYPE';
 ELSE
    l_FeType := FeType;
 end IF;

 IF SW_Generic IS NULL then
    l_SW_Generic := 'GOT NULL SW_GENERIC';
 ELSE
    l_SW_Generic := SW_Generic;
 end IF;

 IF CommandSent IS NULL then
    l_CommandSent := 'GOT NULL Command to be sent';
 ELSE
    l_CommandSent := CommandSent;
 end IF;

 IF Response IS NULL then
    l_Response := 'GOT NULL Response from the NE';
    l_ResponseLong := 'GOT NULL Response from the NE';
 ELSE
    l_Response := substr(Response,1,3999);
    l_ResponseLong := substr(Response,1,32766);
 end IF;

 /*
  * Insert into the audit trail table.
  */
 INSERT INTO XDP_FE_CMD_AUD_TRAILS (
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               fa_instance_id,
               fe_command_seq,
               fulfillment_element_name,
               fulfillment_element_type,
               sw_generic,
               command_sent,
               command_sent_date,
               response,
	       response_long,
               response_date,
               provisioning_procedure)
              VALUES (
	       FND_GLOBAL.USER_ID,
	       sysdate,
	       FND_GLOBAL.USER_ID,
	       sysdate,
	       FND_GLOBAL.LOGIN_ID,
               FAInstanceID,
               XDP_FE_CMD_AUD_TRAILS_S.NEXTVAL,
               l_FeName,
               l_FeType,
               l_Sw_Generic,
               l_CommandSent,
               SentDate,
               l_Response,
               l_ResponseLong,
               RespDate,
               ProcName);

 commit;

exception
when others then
	xdp_utilities.generic_error('XDP_AQ_UTILITIES.LogCommandAuditTrail',
				    'FA Instance: ' || FAInstanceID,
				    sqlcode,
				    sqlerrm);
END LogCommandAuditTrail;

PROCEDURE Find_XDP_SCHEMA
IS
    lv1 varchar2(80);
    lv2 varchar2(80);
    lv_schema varchar2(80);
    lv_ret BOOLEAN;

BEGIN
  	lv_ret := FND_INSTALLATION.get_app_info(
       'XDP',
		lv1,
		lv2,
		lv_schema);
	G_XDP_SCHEMA := NVL(lv_schema,'XDP');

EXCEPTION
  WHEN OTHERS THEN
	G_XDP_SCHEMA := 'XDP';
END Find_XDP_SCHEMA;

PROCEDURE Find_XNP_SCHEMA
IS
    lv1 varchar2(80);
    lv2 varchar2(80);
    lv_schema varchar2(80);
    lv_ret BOOLEAN;

BEGIN
        lv_ret := FND_INSTALLATION.get_app_info(
       'XNP',
                lv1,
                lv2,
                lv_schema);
        G_XNP_SCHEMA := NVL(lv_schema,'XNP');

EXCEPTION
  WHEN OTHERS THEN
        G_XNP_SCHEMA := 'XNP';
END Find_XNP_SCHEMA;

/*
 * Dequeue from Event Queue
 */
PROCEDURE DQ_XNP_EVT_Q( p_return_code       OUT NOCOPY NUMBER,
		        p_error_description OUT NOCOPY VARCHAR2)  AS

l_time_out    VARCHAR2(20) ;
l_message_key VARCHAR2(2000) ;
l_dq_count    NUMBER ;

BEGIN
     p_return_code := 0 ;
     p_error_description := null ;
     l_dq_count := 0 ;

     FOR i IN 1..G_DQ_COUNT

        LOOP
            XNP_EVENT.PROCESS_IN_EVT( p_message_wait_timeout => g_msg_wait_timeout,
                                      p_correlation_id       => null,
                                      x_message_key          => l_message_key,
                                      x_queue_timed_out      => l_time_out );

            IF l_time_out = 'Y' THEN
               EXIT ;
            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;

        fnd_file.put_line(fnd_file.output,'Total Number of Events Dequeued : '||l_dq_count );


EXCEPTION
     WHEN others THEN
          p_return_code := sqlcode ;
          p_error_description := sqlerrm ;
          fnd_file.put_line(fnd_file.log,'Error Code : ' ||p_return_code);
          fnd_file.put_line(fnd_file.log,'Error Message : ' ||p_error_description);

END DQ_XNP_EVT_Q ;

/*
 * Dequeue from Inbound Message Queue
 */
PROCEDURE DQ_XNP_IN_MSG_Q( p_return_code       OUT NOCOPY NUMBER,
  		           p_error_description OUT NOCOPY VARCHAR2)  AS

l_time_out    VARCHAR2(20) ;
l_message_key VARCHAR2(2000) ;
l_dq_count    NUMBER ;

BEGIN
     p_return_code := 0 ;
     p_error_description := null ;
     l_dq_count := 0 ;

     FOR i IN 1..G_DQ_COUNT

        LOOP
            XNP_EVENT.PROCESS_IN_MSG( p_message_wait_timeout => g_msg_wait_timeout,
                                      p_correlation_id       => null,
                                      x_message_key          => l_message_key,
                                      x_queue_timed_out      => l_time_out );

            IF l_time_out = 'Y' THEN
               EXIT ;
            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;

        fnd_file.put_line(fnd_file.output,'Total Number of Messages Dequeued : '||l_dq_count );


EXCEPTION
     WHEN others THEN
          p_return_code := sqlcode ;
          p_error_description := sqlerrm ;
          fnd_file.put_line(fnd_file.log,'Error Code : ' ||p_return_code);
          fnd_file.put_line(fnd_file.log,'Error Message : ' ||p_error_description);

END DQ_XNP_IN_MSG_Q ;

/*
 * Dequeue from Timer Queue
 */
PROCEDURE DQ_XNP_IN_TMR_Q( p_return_code       OUT NOCOPY NUMBER,
                           p_error_description OUT NOCOPY VARCHAR2)  AS

l_time_out    VARCHAR2(20) ;
l_message_key VARCHAR2(2000) ;
l_dq_count    NUMBER ;

BEGIN
     p_return_code := 0 ;
     p_error_description := null ;
     l_dq_count := 0 ;

     FOR i IN 1..G_DQ_COUNT

        LOOP
            XNP_TIMER_MGR.PROCESS_IN_TMR( p_message_wait_timeout => g_msg_wait_timeout,
                                          p_correlation_id       => null,
                                          x_message_key          => l_message_key,
                                          x_queue_timed_out      => l_time_out );

            IF l_time_out = 'Y' THEN
               EXIT ;
            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
        fnd_file.put_line(fnd_file.output,'Total Number of Timers Dequeued: '||l_dq_count );

EXCEPTION
     WHEN others THEN
          p_return_code := sqlcode ;
          p_error_description := sqlerrm ;
          fnd_file.put_line(fnd_file.log,'Error Code : ' ||p_return_code);
          fnd_file.put_line(fnd_file.log,'Error Message : ' ||p_error_description);

END DQ_XNP_IN_TMR_Q ;

/*
 * Dequeue from Order Queue
 */
PROCEDURE DQ_XDP_ORDER_PROC_QUEUE( p_return_code       OUT NOCOPY NUMBER,
                                   p_error_description OUT NOCOPY VARCHAR2)  AS

l_time_out    VARCHAR2(20) ;
l_message_key VARCHAR2(2000) ;
l_dq_count    NUMBER ;

BEGIN
     p_return_code := 0 ;
     p_error_description := null ;
     l_dq_count := 0 ;

     FOR i IN 1..G_DQ_COUNT

        LOOP
            XDP_AQ_UTILITIES.START_ORDERPROCESSOR_WORKFLOW( p_message_wait_timeout => g_msg_wait_timeout,
                                                            p_correlation_id       => null,
                                                            x_message_key          => l_message_key,
                                                            x_queue_timed_out      => l_time_out );

            IF l_time_out = 'Y' THEN
               EXIT ;
            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
        fnd_file.put_line(fnd_file.output,'Total Number of Orders Dequeued : '||l_dq_count );

EXCEPTION
     WHEN others THEN
          p_return_code := sqlcode ;
          p_error_description := sqlerrm ;
          fnd_file.put_line(fnd_file.log,'Error Code : ' ||p_return_code);
          fnd_file.put_line(fnd_file.log,'Error Message : ' ||p_error_description);

END DQ_XDP_ORDER_PROC_QUEUE;

/*
 * Dequeue from Fulfillment Action Queue
 */
PROCEDURE DQ_XDP_FA_QUEUE( p_return_code       OUT NOCOPY NUMBER,
                           p_error_description OUT NOCOPY VARCHAR2)  AS

l_time_out    VARCHAR2(20) ;
l_message_key VARCHAR2(2000) ;
l_dq_count    NUMBER ;

BEGIN
     p_return_code := 0 ;
     p_error_description := null ;
     l_dq_count := 0 ;

     FOR i IN 1..G_DQ_COUNT

        LOOP
            XDP_AQ_UTILITIES.START_FA_WORKFLOW( p_message_wait_timeout => g_msg_wait_timeout,
                                                p_correlation_id       => null,
                                                x_message_key          => l_message_key,
                                                x_queue_timed_out      => l_time_out );

            IF l_time_out = 'Y' THEN
                EXIT ;
            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
        fnd_file.put_line(fnd_file.output,'Total Number of Fulfillment Actions Dequeued : '||l_dq_count );

EXCEPTION
     WHEN others THEN
          p_return_code := sqlcode ;
          p_error_description := sqlerrm ;
          fnd_file.put_line(fnd_file.log,'Error Code : ' ||p_return_code);
          fnd_file.put_line(fnd_file.log,'Error Message : ' ||p_error_description);

END DQ_XDP_FA_QUEUE;

/*
 * Dequeue from Fulfillment Actions Ready Queue
 */
PROCEDURE DQ_XDP_WF_CHANNEL_Q( p_return_code       OUT NOCOPY NUMBER,
                               p_error_description OUT NOCOPY VARCHAR2)  AS

l_time_out    VARCHAR2(20) ;
l_message_key VARCHAR2(2000) ;
l_dq_count    NUMBER ;

BEGIN
     p_return_code := 0 ;
     p_error_description := null ;
     l_dq_count := 0 ;

     FOR i IN 1..G_DQ_COUNT

        LOOP
            XDP_AQ_UTILITIES.RESUME_NEXT_WF( p_message_wait_timeout => g_msg_wait_timeout,
                                             p_correlation_id       => null,
                                             x_message_key          => l_message_key,
                                             x_queue_timed_out      => l_time_out );

-- remember to uncomment this out VBhatia

            IF l_time_out = 'Y' THEN
                EXIT ;
            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
        fnd_file.put_line(fnd_file.output,'Total Number FulFillment Element Ready Queue Dequeued : '||l_dq_count );

EXCEPTION
     WHEN others THEN
          p_return_code := sqlcode ;
          p_error_description := sqlerrm ;
          fnd_file.put_line(fnd_file.log,'Error Code : ' ||p_return_code);
          fnd_file.put_line(fnd_file.log,'Error Message : ' ||p_error_description);

END DQ_XDP_WF_CHANNEL_Q;

/*
 * Dequeue from Work Item Queue
 */
PROCEDURE DQ_XDP_WORKITEM_QUEUE( p_return_code       OUT NOCOPY NUMBER,
                                 p_error_description OUT NOCOPY VARCHAR2)  AS

l_time_out    VARCHAR2(20) ;
l_message_key VARCHAR2(2000) ;
l_dq_count    NUMBER ;

BEGIN
     p_return_code := 0 ;
     p_error_description := null ;
     l_dq_count := 0 ;

     FOR i IN 1..G_DQ_COUNT

        LOOP
            XDP_AQ_UTILITIES.START_WORKITEM_WORKFLOW( p_message_wait_timeout => g_msg_wait_timeout,
                                                      p_correlation_id       => null,
                                                      x_message_key          => l_message_key,
                                                      x_queue_timed_out      => l_time_out );

            IF l_time_out = 'Y' THEN
                EXIT ;
            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
        fnd_file.put_line(fnd_file.output,'Total Number of Workitems Dequeued : '||l_dq_count );

EXCEPTION
     WHEN others THEN
          p_return_code := sqlcode ;
          p_error_description := sqlerrm ;
          fnd_file.put_line(fnd_file.log,'Error Code : ' ||p_return_code);
          fnd_file.put_line(fnd_file.log,'Error Message : ' ||p_error_description);

END DQ_XDP_WORKITEM_QUEUE;


/*
 * This procedure is called from a concurrent program - it reads entries from the Exception Queue
 * and re-enqueues them into the Normal Queue
 */
PROCEDURE DQ_EXCP_REENQ( p_return_code       OUT NOCOPY NUMBER,
                         p_error_description OUT NOCOPY VARCHAR2 )

IS

BEGIN

    p_return_code := 0 ;
    p_error_description := null ;

    /* Order Queue */
    BEGIN

        DQ_XDP_ORDER_PROC_REENQ( p_message_wait_timeout => g_msg_wait_timeout,
                                 p_correlation_id       => null );

    EXCEPTION
        WHEN others THEN
            p_return_code := sqlcode ;
            p_error_description := sqlerrm ;
            fnd_file.put_line(fnd_file.log,'Error in DQ_EXCP_REENQ: DQ_XDP_ORDER_PROC_REENQ');
            fnd_file.put_line(fnd_file.log,'Error Code : ' ||sqlcode);
            fnd_file.put_line(fnd_file.log,'Error Message : ' ||sqlerrm);

        END;

    /* Work Item */
    BEGIN

        DQ_XDP_WORKITEM_REENQ( p_message_wait_timeout => g_msg_wait_timeout,
                               p_correlation_id       => null );

    EXCEPTION
        WHEN others THEN
            p_return_code := p_return_code ||':'|| sqlcode ;
            p_error_description := p_error_description ||':'|| sqlerrm ;
            fnd_file.put_line(fnd_file.log,'Error in DQ_EXCP_REENQ: DQ_XDP_WORKITEM_REENQ');
            fnd_file.put_line(fnd_file.log,'Error Code : ' ||sqlcode);
            fnd_file.put_line(fnd_file.log,'Error Message : ' ||sqlerrm);
    END;

    /* Fulfillment Actions */
    BEGIN

        DQ_XDP_FA_REENQ( p_message_wait_timeout => g_msg_wait_timeout,
                         p_correlation_id       => null );

    EXCEPTION
        WHEN others THEN
            p_return_code := p_return_code ||':'|| sqlcode ;
            p_error_description := p_error_description ||':'|| sqlerrm ;
            fnd_file.put_line(fnd_file.log,'Error in DQ_EXCP_REENQ: DQ_XDP_FA_REENQ');
            fnd_file.put_line(fnd_file.log,'Error Code : ' ||sqlcode);
            fnd_file.put_line(fnd_file.log,'Error Message : ' ||sqlerrm);
    END;

    /* Fulfillment Actions Ready */
    BEGIN

        DQ_XDP_WF_CHANNEL_REENQ( p_message_wait_timeout => g_msg_wait_timeout,
                                 p_correlation_id       => null );

    EXCEPTION
        WHEN others THEN
            p_return_code := p_return_code ||':'|| sqlcode ;
            p_error_description := p_error_description ||':'|| sqlerrm ;
            fnd_file.put_line(fnd_file.log,'Error in DQ_EXCP_REENQ: DQ_XDP_WF_CHANNEL_REENQ');
            fnd_file.put_line(fnd_file.log,'Error Code : ' ||sqlcode);
            fnd_file.put_line(fnd_file.log,'Error Message : ' ||sqlerrm);
    END;

    /* Inbound Message */
    BEGIN

        DQ_XNP_IN_MSG_REENQ( p_message_wait_timeout => g_msg_wait_timeout );

    EXCEPTION
        WHEN others THEN
            p_return_code := p_return_code ||':'|| sqlcode ;
            p_error_description := p_error_description ||':'|| sqlerrm ;
            fnd_file.put_line(fnd_file.log,'Error in DQ_EXCP_REENQ: DQ_XNP_IN_MSG_REENQ');
            fnd_file.put_line(fnd_file.log,'Error Code : ' ||sqlcode);
            fnd_file.put_line(fnd_file.log,'Error Message : ' ||sqlerrm);
    END;

    /* Internal Event */
    BEGIN

        DQ_XNP_IN_EVT_REENQ( p_message_wait_timeout => g_msg_wait_timeout );

    EXCEPTION
        WHEN others THEN
            p_return_code := p_return_code ||':'|| sqlcode ;
            p_error_description := p_error_description ||':'|| sqlerrm ;
            fnd_file.put_line(fnd_file.log,'Error in DQ_EXCP_REENQ: DQ_XNP_IN_EVT_REENQ');
            fnd_file.put_line(fnd_file.log,'Error Code : ' ||sqlcode);
            fnd_file.put_line(fnd_file.log,'Error Message : ' ||sqlerrm);
    END;

    /* Timer */
    BEGIN

        DQ_XNP_IN_TMR_REENQ( p_message_wait_timeout => g_msg_wait_timeout );

    EXCEPTION
        WHEN others THEN
            p_return_code := p_return_code ||':'|| sqlcode ;
            p_error_description := p_error_description ||':'|| sqlerrm ;
            fnd_file.put_line(fnd_file.log,'Error in DQ_EXCP_REENQ: DQ_XNP_IN_TMR_REENQ');
            fnd_file.put_line(fnd_file.log,'Error Code : ' ||sqlcode);
            fnd_file.put_line(fnd_file.log,'Error Message : ' ||sqlerrm);
    END;

    /* Outbound */
    BEGIN

        DQ_XNP_OUT_MSG_REENQ( p_message_wait_timeout => g_msg_wait_timeout );

    EXCEPTION
        WHEN others THEN
            p_return_code := p_return_code ||':'|| sqlcode ;
            p_error_description := p_error_description ||':'|| sqlerrm ;
            fnd_file.put_line(fnd_file.log,'Error in DQ_EXCP_REENQ: DQ_XNP_OUT_MSG_REENQ');
            fnd_file.put_line(fnd_file.log,'Error Code : ' ||sqlcode);
            fnd_file.put_line(fnd_file.log,'Error Message : ' ||sqlerrm);
    END;

END DQ_EXCP_REENQ;


PROCEDURE DQ_XDP_ORDER_PROC_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1,
                                   p_correlation_id IN VARCHAR2 )

IS

        lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
        lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
        lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
        lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
        lv_MsgID RAW(16);
        lv_return_code NUMBER;
        lv_error_description VARCHAR2(2000);
        l_dq_count NUMBER ;
        x_queue_timed_out VARCHAR2(1);

BEGIN

    savepoint order_q_tag;
    lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
    lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
    lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE;
    lv_DequeueOptions.MSGID := NULL;
    lv_DequeueOptions.correlation := p_correlation_id;

    -- Set Dequeue time out to be 1 second
    lv_DequeueOptions.wait := p_message_wait_timeout;
    x_queue_timed_out := 'N';
    l_dq_count := 0;

    FOR i IN 1..G_DQ_COUNT
        LOOP

            BEGIN
                DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_ORDER_PROCESSOR_EXPQ',
                                 dequeue_options    => lv_DequeueOptions,
                                 message_properties => lv_MessageProperties,
                                 payload            => lv_wf_object,
                                 msgid              => lv_MsgID);
            EXCEPTION
              WHEN e_QTimeOut THEN
                  x_queue_timed_out := 'Y';
            END;

            IF x_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE

                Add_OrderToProcessorQ( p_order_id     => lv_wf_object.order_id ,
                                       p_wf_item_type => lv_wf_object.WF_ITEM_TYPE ,
                                       p_wf_item_key  => lv_wf_object.WF_ITEM_KEY );
            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
    fnd_file.put_line(fnd_file.output,'Total Number of Orders Dequeued from Order Exception Queue : '||l_dq_count );

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO order_q_tag;
        RAISE;

END DQ_XDP_ORDER_PROC_REENQ;


PROCEDURE DQ_XDP_FA_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1,
                           p_correlation_id IN VARCHAR2 )

IS

        lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
        lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
        lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
        lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
        lv_MsgID RAW(16);
        lv_return_code NUMBER;
        lv_error_description VARCHAR2(2000);
        l_dq_count NUMBER ;
        x_queue_timed_out VARCHAR2(1);

BEGIN

    savepoint fa_q_tag;
    lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
    lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
    lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE;
    lv_DequeueOptions.MSGID := NULL;
    lv_DequeueOptions.correlation := p_correlation_id;

    -- Set Dequeue time out to be 1 second
    lv_DequeueOptions.wait := p_message_wait_timeout;
    x_queue_timed_out := 'N';
    l_dq_count := 0;

    FOR i IN 1..G_DQ_COUNT
        LOOP

            BEGIN
                DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_FA_EXPQ',
                                 dequeue_options    => lv_DequeueOptions,
                                 message_properties => lv_MessageProperties,
                                 payload            => lv_wf_object,
                                 msgid              => lv_MsgID);
            EXCEPTION
              WHEN e_QTimeOut THEN
                  x_queue_timed_out := 'Y';
            END;

            IF x_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE
                Add_FA_ToQ( p_order_id          => lv_wf_object.order_id ,
                            p_wi_instance_id    => lv_wf_object.WORKITEM_INSTANCE_ID ,
                            p_fa_instance_id    => lv_wf_object.FA_INSTANCE_ID ,
                            p_wf_item_type      => lv_wf_object.WF_ITEM_TYPE ,
                            p_wf_item_key       => lv_wf_object.WF_ITEM_KEY ,
                            p_return_code       => lv_return_code ,
                            p_error_description => lv_error_description );

                IF( lv_return_code <> 0 ) THEN
                    fnd_file.put_line(fnd_file.log, 'Could not ReEnqueue Fulfillment Action - Error: ' ||lv_error_description);
                    ROLLBACK TO fa_q_tag;
                    RETURN;
                END IF;

            END IF ;
            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
    fnd_file.put_line(fnd_file.output,'Total Number of Fulfillment Actions Dequeued from Fulfillment Actions Exception Queue : '||l_dq_count );

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO fa_q_tag;
        RAISE;

END DQ_XDP_FA_REENQ;


PROCEDURE DQ_XDP_WORKITEM_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1,
                                 p_correlation_id IN VARCHAR2 )

IS

        lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
        lv_tmp SYSTEM.XDP_WF_CHANNELQ_TYPE;
        lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
        lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
        lv_MsgID RAW(16);
        lv_return_code NUMBER;
        lv_error_description VARCHAR2(2000);
        l_dq_count NUMBER ;
        x_queue_timed_out VARCHAR2(1);

BEGIN

    savepoint workitem_q_tag;
    lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
    lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
    lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE;
    lv_DequeueOptions.MSGID := NULL;
    lv_DequeueOptions.correlation := p_correlation_id;

    -- Set Dequeue time out to be 1 second
    lv_DequeueOptions.wait := p_message_wait_timeout;
    x_queue_timed_out := 'N';
    l_dq_count := 0;

    FOR i IN 1..G_DQ_COUNT
        LOOP

            BEGIN
                DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_WORKITEM_EXPQ',
                                 dequeue_options    => lv_DequeueOptions,
                                 message_properties => lv_MessageProperties,
                                 payload            => lv_wf_object,
                                 msgid              => lv_MsgID);
            EXCEPTION
              WHEN e_QTimeOut THEN
                  x_queue_timed_out := 'Y';
            END;

            IF x_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE
                Add_WorkItem_ToQ( p_order_id          => lv_wf_object.order_id ,
                                  p_wi_instance_id    => lv_wf_object.WORKITEM_INSTANCE_ID ,
                                  p_prov_date         => GetWIProvisioningDate( lv_wf_object.WORKITEM_INSTANCE_ID ) ,
                                  p_wf_item_type      => lv_wf_object.WF_ITEM_TYPE ,
                                  p_wf_item_key       => lv_wf_object.WF_ITEM_KEY ,
                                  p_return_code       => lv_return_code ,
                                  p_error_description => lv_error_description );

                IF( lv_return_code <> 0 ) THEN
                    fnd_file.put_line(fnd_file.log, 'Could not ReEnqueue WorkItem - Error: ' ||lv_error_description);
                    ROLLBACK TO workitem_q_tag;
                    RETURN;
                END IF;

            END IF ;
            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
    fnd_file.put_line(fnd_file.output,'Total Number of WorkItems dequeued from WorkItem Exception Queue : '||l_dq_count );

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO workitem_q_tag;
        RAISE;

END DQ_XDP_WORKITEM_REENQ;

FUNCTION GetWIProvisioningDate(p_workitem_instance_id IN NUMBER)
 RETURN DATE IS

 l_prov_date   DATE ;
 x_progress    VARCHAR2(2000);

    BEGIN
        SELECT provisioning_date
          INTO l_prov_date
        FROM xdp_fulfill_worklist
        WHERE workitem_instance_id = p_workitem_instance_id ;
        RETURN l_prov_date;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,'Could not get the provisioning date for WorkItem Instance Id');
        RAISE;

END GetWIProvisioningDate ;


PROCEDURE DQ_XDP_WF_CHANNEL_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1,
                                   p_correlation_id IN VARCHAR2 )

IS

        lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
        lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
        lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
        lv_MsgID RAW(16);
        lv_return_code NUMBER;
        lv_error_description VARCHAR2(2000);
        l_dq_count NUMBER ;
        x_queue_timed_out VARCHAR2(1);

BEGIN

    savepoint resume_wf;
    lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
    lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
    lv_DequeueOptions.correlation := p_correlation_id;

    -- Set Dequeue time out to be 1 second
    lv_DequeueOptions.wait := p_message_wait_timeout;
    x_queue_timed_out := 'N';
    l_dq_count := 0;

    FOR i IN 1..G_DQ_COUNT
        LOOP

            BEGIN
                DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_CHANNEL_EXCEPTION_Q',
                                 dequeue_options    => lv_DequeueOptions,
                                 message_properties => lv_MessageProperties,
                                 payload            => lv_wf_object,
                                 msgid              => lv_MsgID);
            EXCEPTION
              WHEN e_QTimeOut THEN
                  x_queue_timed_out := 'Y';
            END;

            IF x_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE
                HANDOVER_CHANNEL( p_channel_name      => lv_wf_object.CHANNEL_NAME ,
                                  p_fe_name           => lv_wf_object.FE_NAME ,
                                  p_wf_item_type      => lv_wf_object.WF_ITEM_TYPE ,
                                  p_wf_item_key       => lv_wf_object.WF_ITEM_KEY ,
                                  p_wf_activity       => lv_wf_object.WF_ACTIVITY_NAME ,
                                  p_order_id          => lv_wf_object.ORDER_ID ,
                                  p_wi_instance_id    => lv_wf_object.WORKITEM_INSTANCE_ID ,
                                  p_fa_instance_id    => lv_wf_object.FA_INSTANCE_ID ,
                                  p_return_code       => lv_return_code ,
                                  p_error_description => lv_error_description );

                IF( lv_return_code <> 0 ) THEN
                    fnd_file.put_line(fnd_file.log, 'Could not ReEnqueue from FE Ready - Error: ' ||lv_error_description);
                    ROLLBACK TO resume_wf;
                    RETURN;
                END IF;

            END IF ;
            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
    fnd_file.put_line(fnd_file.output,'Total Number dequeued from FE Ready Exception Queue : '||l_dq_count );

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO resume_wf;
        RAISE;

END DQ_XDP_WF_CHANNEL_REENQ;


PROCEDURE DQ_XNP_IN_MSG_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1 )

IS

        l_dq_count NUMBER ;
        l_error_code NUMBER;
        l_error_message VARCHAR2(4000);
        l_msg_header XNP_MESSAGE.MSG_HEADER_REC_TYPE;
        l_msg_text VARCHAR2(32767);
        l_body_text VARCHAR2(32767);
        x_queue_timed_out VARCHAR2(1);

BEGIN

    savepoint before_msg_pop;

    x_queue_timed_out := 'N';
    l_dq_count := 0;
    l_error_code := 0;
    l_error_message := NULL;

    FOR i IN 1..G_DQ_COUNT
        LOOP

            XNP_MESSAGE.POP( p_queue_name     => G_XNP_SCHEMA ||'.'||'XNP_IN_MSG_EXCEPTION_Q',
                             x_msg_header     => l_msg_header,
                             x_body_text      => l_body_text,
                             x_error_code     => l_error_code,
                             x_error_message  => l_error_message
                            );

            IF ( l_error_code = XNP_ERRORS.G_DEQUEUE_TIMEOUT ) THEN
                x_queue_timed_out := 'Y';
            END IF ;

            IF x_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE

                ReENQUEUE( p_msg_header     => l_msg_header ,
                           p_body_text      => l_body_text ,
                           p_queue_name     => xnp_event.c_inbound_msg_q ,
                           p_correlation_id => l_msg_header.message_code ,
                           p_commit_mode    => xnp_message.c_on_commit );

            END IF ;

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;

    fnd_file.put_line(fnd_file.output,'Total Number dequeued from Inbound Messages Exception Queue : '||l_dq_count );

EXCEPTION
  WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.output,' Could not Re-enqueue from Inbound Messages Exception Queue: '||SQLCODE||':'||SQLERRM);
      ROLLBACK TO before_msg_pop;
      RAISE;

END DQ_XNP_IN_MSG_REENQ;


PROCEDURE DQ_XNP_IN_EVT_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1 )

IS

        l_dq_count NUMBER ;
        l_error_code NUMBER;
        l_error_message VARCHAR2(4000);
        l_msg_header XNP_MESSAGE.MSG_HEADER_REC_TYPE;
        l_msg_text VARCHAR2(32767);
        l_body_text VARCHAR2(32767);
        x_queue_timed_out VARCHAR2(1);

BEGIN

    savepoint before_evt_pop;

    x_queue_timed_out := 'N';
    l_dq_count := 0;
    l_error_code := 0;
    l_error_message := NULL;

    FOR i IN 1..G_DQ_COUNT
        LOOP

            XNP_MESSAGE.POP( p_queue_name     => G_XNP_SCHEMA ||'.'||'XNP_IN_EVT_EXCEPTION_Q',
                             x_msg_header     => l_msg_header,
                             x_body_text      => l_body_text,
                             x_error_code     => l_error_code,
                             x_error_message  => l_error_message
                            );

            IF ( l_error_code = XNP_ERRORS.G_DEQUEUE_TIMEOUT ) THEN
                x_queue_timed_out := 'Y';
            END IF ;

            IF x_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE

                ReENQUEUE( p_msg_header     => l_msg_header ,
                           p_body_text      => l_body_text ,
                           p_queue_name     => xnp_event.c_internal_evt_q ,
                           p_correlation_id => l_msg_header.message_code ,
                           p_commit_mode    => xnp_message.c_on_commit );

            END IF ;
            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
    fnd_file.put_line(fnd_file.output,'Total Number dequeued from Events Exception Queue : '||l_dq_count );

EXCEPTION
  WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.output,' Could not Re-enqueue from Events Exception Queue: '||SQLCODE||':'||SQLERRM);
      ROLLBACK TO before_evt_pop;
      RAISE;

END DQ_XNP_IN_EVT_REENQ;


PROCEDURE DQ_XNP_IN_TMR_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1 )

IS

        l_dq_count NUMBER ;
        l_error_code NUMBER;
        l_error_message VARCHAR2(4000);
        l_msg_header XNP_MESSAGE.MSG_HEADER_REC_TYPE;
        l_msg_text VARCHAR2(32767);
        l_body_text VARCHAR2(32767);
        x_queue_timed_out VARCHAR2(1);

BEGIN

    savepoint before_tmr_pop;

    x_queue_timed_out := 'N';
    l_dq_count := 0;
    l_error_code := 0;
    l_error_message := NULL;

    FOR i IN 1..G_DQ_COUNT
        LOOP

            XNP_MESSAGE.POP( p_queue_name     =>  G_XNP_SCHEMA ||'.'||'XNP_IN_TMR_EXCEPTION_Q',
                             x_msg_header     => l_msg_header,
                             x_body_text      => l_body_text,
                             x_error_code     => l_error_code,
                             x_error_message  => l_error_message
                            );

            IF ( l_error_code = XNP_ERRORS.G_DEQUEUE_TIMEOUT ) THEN
                x_queue_timed_out := 'Y';
            END IF ;

            IF x_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE

                ReENQUEUE( p_msg_header  => l_msg_header ,
                           p_body_text   => l_body_text ,
                           p_queue_name  => xnp_event.c_timer_q ,
                           p_priority    => 1 ,
                           p_commit_mode => xnp_message.c_on_commit);

            END IF ;
            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;
    fnd_file.put_line(fnd_file.output,'Total Number dequeued from Timer Exception Queue : '||l_dq_count );

EXCEPTION
  WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.output,' Could not Re-enqueue from Timer Exception Queue: '||SQLCODE||':'||SQLERRM);
      ROLLBACK TO before_tmr_pop;
      RAISE;

END DQ_XNP_IN_TMR_REENQ;


PROCEDURE DQ_XNP_OUT_MSG_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1 )

IS

        l_dq_count            NUMBER ;
        x_msg_header          XNP_MESSAGE.MSG_HEADER_REC_TYPE;
        x_msg_text            VARCHAR2(32767);
        x_body_text           VARCHAR2(32767);
        x_queue_timed_out     VARCHAR2(1);
        l_msg_status          VARCHAR2(40) ;
        l_message             SYSTEM.XNP_MESSAGE_TYPE ;
        my_dequeue_options    dbms_aq.dequeue_options_t ;
        message_properties    dbms_aq.message_properties_t ;
        message_handle        RAW(16) ;
        dq_time_out           EXCEPTION;

        PRAGMA  EXCEPTION_INIT ( dq_time_out, -25228 );

BEGIN

    savepoint before_out_msg_pop;

    x_queue_timed_out := 'N';
    l_dq_count := 0;

    my_dequeue_options.wait := p_message_wait_timeout;
    my_dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
    my_dequeue_options.consumer_name := NULL;
    my_dequeue_options.correlation := NULL;
    my_dequeue_options.visibility := DBMS_AQ.ON_COMMIT;

    FOR i IN 1..G_DQ_COUNT
        LOOP

            BEGIN

                my_dequeue_options.dequeue_mode := DBMS_AQ.LOCKED;
                my_dequeue_options.msgid := NULL;

                LOOP

                    DBMS_AQ.DEQUEUE ( queue_name         =>  G_XNP_SCHEMA ||'.'||'XNP_OUT_MSG_EXCEPTION_Q',
                                      dequeue_options    => my_dequeue_options,
                                      message_properties => message_properties,
                                      payload            => l_message,
                                      msgid              => message_handle );

                    x_msg_header.message_id := l_message.message_id;
                    xnp_message.get_status(l_message.message_id, l_msg_status);

                    IF ( l_msg_status = 'READY' OR l_msg_status = 'PROCESSED' ) THEN

                        xnp_message.get(
                            p_msg_id      => l_message.message_id
                           ,x_msg_header  => x_msg_header
                           ,x_msg_text    => x_body_text);

                        EXIT;

                    END IF;

                END LOOP;

            EXCEPTION
                WHEN dq_time_out THEN
                    x_queue_timed_out := 'Y';
            END;
            IF x_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE

                ReENQUEUE( p_msg_header     => x_msg_header ,
                           p_body_text      => x_body_text ,
                           p_queue_name     => xnp_event.c_outbound_msg_q ,
                           p_correlation_id => x_msg_header.message_code ,
                           p_commit_mode    => xnp_message.c_on_commit);

            END IF ;
            my_dequeue_options.dequeue_mode := DBMS_AQ.REMOVE_NODATA;
            my_dequeue_options.msgid := message_handle;

            DBMS_AQ.DEQUEUE ( queue_name         => G_XNP_SCHEMA||'.'||'XNP_OUT_MSG_EXCEPTION_Q',
                              dequeue_options    => my_dequeue_options,
                              message_properties => message_properties,
                              payload            => l_message,
                              msgid              => message_handle );

            l_dq_count := l_dq_count + 1 ;
            DBMS_LOCK.SLEEP(g_sleep_time);

        END LOOP ;

	fnd_file.put_line(fnd_file.output,'Total Number dequeued from Outbound Msg Exception Queue : '||l_dq_count );

EXCEPTION
  WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.output,'Could not Re-enqueue from Outbound Msg Exception Queue: '||SQLCODE||':'||SQLERRM);
      ROLLBACK TO before_out_msg_pop;
      RAISE;

END DQ_XNP_OUT_MSG_REENQ;


PROCEDURE ReENQUEUE( p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE
                    ,p_body_text IN VARCHAR2
                    ,p_queue_name IN VARCHAR2
                    ,p_correlation_id IN VARCHAR2 DEFAULT NULL
                    ,p_priority IN INTEGER DEFAULT 1
                    ,p_commit_mode IN NUMBER DEFAULT XNP_MESSAGE.C_ON_COMMIT
                    ,p_delay IN NUMBER DEFAULT DBMS_AQ.NO_DELAY
                   )

IS

    l_message            SYSTEM.XNP_MESSAGE_TYPE ;
    my_enqueue_options   dbms_aq.enqueue_options_t ;
    message_properties   dbms_aq.message_properties_t ;
    message_handle       RAW(16) ;
    recipients           dbms_aq.aq$_recipient_list_t ;

    l_recipient_name     VARCHAR2(80) ;
    l_recipient_count    INTEGER ;
    l_initial_pos        INTEGER ;
    l_delimeter_pos      INTEGER ;

    l_correlation_id     VARCHAR2(1024) ;
    l_msg_header         xnp_message.msg_header_rec_type ;

    CURSOR get_consumer_name(l_msg system.xnp_message_type) IS
        SELECT consumer_name
        FROM AQ$XNP_OUT_MSG_QTAB a
        WHERE a.user_data = l_msg
	  AND a.queue = 'XNP_OUT_MSG_EXCEPTION_Q';

BEGIN

    l_msg_header := p_msg_header ;
    l_correlation_id := l_msg_header.message_code ;

    UPDATE xnp_msgs
    SET msg_status = 'READY',
        last_update_date = SYSDATE
    WHERE msg_id = l_msg_header.message_id;

   IF (p_commit_mode = XNP_MESSAGE.C_IMMEDIATE) THEN
       COMMIT ;
   END IF ;

   IF (p_priority IS NOT NULL) THEN
       message_properties.priority := p_priority ;
   END IF ;

   IF (p_delay IS NOT NULL) THEN
       message_properties.delay := p_delay ;
   END IF;

   l_message := SYSTEM.xnp_message_type( l_msg_header.message_id ) ;

-- Use the correlation ID if one is specified

   IF ( l_correlation_id is NOT NULL ) THEN
       message_properties.correlation := l_correlation_id ;
   END IF ;

--
-- Check if there are recipients, if there is no recipient, simply enqueue the
-- message on the specified queue
--

    IF( p_queue_name = xnp_event.c_outbound_msg_q ) THEN

        l_recipient_count := 1;

	FOR rec in get_consumer_name(l_message)

        LOOP

            l_recipient_name := rec.consumer_name;
            recipients (l_recipient_count) := sys.aq$_agent ( l_recipient_name,
                                                                NULL, NULL ) ;
            l_recipient_count := l_recipient_count + 1;

        END LOOP;

        message_properties.recipient_list := recipients ;

    END IF;

    IF (p_commit_mode = XNP_MESSAGE.C_IMMEDIATE) THEN
        my_enqueue_options.visibility := DBMS_AQ.IMMEDIATE ;
    ELSE
        my_enqueue_options.visibility := DBMS_AQ.ON_COMMIT ;
    END IF ;
   /* Smoolcha Fixed bug 3537144 Hard coded schema name */
    -- IF p_queue_name = 'XNP.XNP_IN_EVT_Q' THEN
    --    message_properties.exception_queue := 'XNP.XNP_IN_EVT_EXCEPTION_Q' ;
    -- ELSIF p_queue_name = 'XNP.XNP_IN_MSG_Q' THEN
    --    message_properties.exception_queue := 'XNP.XNP_IN_MSG_EXCEPTION_Q' ;
    -- ELSIF p_queue_name = 'XNP.XNP_IN_TMR_Q' THEN
    --    message_properties.exception_queue := 'XNP.XNP_IN_TMR_EXCEPTION_Q' ;
    -- ELSIF p_queue_name = 'XNP.XNP_OUT_MSG_Q' THEN
    --    message_properties.exception_queue := 'XNP.XNP_OUT_MSG_EXCEPTION_Q' ;
    -- END IF ;

    IF instr(p_queue_name,'XNP_IN_EVT_Q') > 0 THEN
        message_properties.exception_queue := G_XNP_SCHEMA || '.XNP_IN_EVT_EXCEPTION_Q' ;
    ELSIF instr(p_queue_name,'XNP_IN_MSG_Q') > 0 THEN
        message_properties.exception_queue := G_XNP_SCHEMA || '.XNP_IN_MSG_EXCEPTION_Q' ;
    ELSIF instr(p_queue_name,'XNP_IN_TMR_Q') > 0  THEN
        message_properties.exception_queue := G_XNP_SCHEMA || '.XNP_IN_TMR_EXCEPTION_Q' ;
    ELSIF instr(p_queue_name,'XNP_OUT_MSG_Q') > 0 THEN
        message_properties.exception_queue := G_XNP_SCHEMA || '.XNP_OUT_MSG_EXCEPTION_Q' ;
    END IF ;

    DBMS_AQ.ENQUEUE (
            queue_name => p_queue_name ,
            enqueue_options => my_enqueue_options,
            message_properties => message_properties,
            payload => l_message,
            msgid => message_handle ) ;

END ReENQUEUE;

/* Sets the context of an entity - message or order to determine whether */
/* its highly available or not     - VBhatia 06/14/2002                  */

PROCEDURE SET_CONTEXT( object_id  IN NUMBER
                      ,object_key IN VARCHAR2 )

IS

BEGIN
	IF IS_AVAILABLE(object_id, object_key) = false THEN
		COMMIT;
          	fnd_file.put_line(fnd_file.log,
                    'SET_CONTEXT: Do not process further for '||object_key||' '||object_id);
		RAISE stop_processing;
	END IF;

END SET_CONTEXT;

/* Finds out if a message or an order is meant to be highly available or not */
/* VBhatia  06/14/2002                                                       */

FUNCTION IS_AVAILABLE( object_id   IN NUMBER
                      ,object_type IN VARCHAR2 )
RETURN BOOLEAN IS

	l_order_id number;
	l_count number;

BEGIN

	l_order_id := object_id;

	IF g_APPS_MAINTENANCE_MODE <> 'MAINT' THEN
		RETURN true;

	ELSE IF object_type = 'MESSAGE_OBJECT' THEN

			SELECT order_id
		         INTO l_order_id
			FROM xnp_msgs
			WHERE msg_id = object_id;

			IF l_order_id IS NULL THEN
				RETURN true;   		--Message is independent, therefore process it
			END IF;
		END IF;
	END IF;

	SELECT count(*)
         INTO l_count
        FROM fnd_lookup_values
        WHERE UPPER(lookup_code) = ( SELECT UPPER(order_type)
	                	     FROM xdp_order_headers
				     WHERE order_id = l_order_id )
        AND lookup_type = 'XDP_HA_ORDER_TYPES';

	IF l_count < 1 THEN
            RETURN false;
        ELSE
            RETURN true;
        END IF;

END IS_AVAILABLE;

/*
Procedure to move messages from FE Ready queue back to Wait-for-channel table.
This is called from admin script incase instances and added / dropped in RAC env.
*/
PROCEDURE DQ_XDP_WF_CHANNEL_REPROCESS

IS
  lv_wf_object SYSTEM.XDP_WF_CHANNELQ_TYPE;
  lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
  lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
  lv_MsgID RAW(16);
  lv_queue_timed_out VARCHAR2(1);

  l_ReProcessEnqTime DATE;
  l_FeID number;


BEGIN

  lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
  lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
  lv_DequeueOptions.correlation := null;

  -- Set Dequeue time out to be 1 second
  lv_DequeueOptions.wait := 1;
  lv_queue_timed_out := 'N';

  select nvl(min(queued_on), sysdate)-1 into l_ReProcessEnqTime from xdp_adapter_job_queue;

  WHILE 1=1 LOOP

            BEGIN
                DBMS_AQ.DEQUEUE( queue_name         => G_XDP_SCHEMA||'.'||'XDP_WF_CHANNEL_Q',
                                 dequeue_options    => lv_DequeueOptions,
                                 message_properties => lv_MessageProperties,
                                 payload            => lv_wf_object,
                                 msgid              => lv_MsgID);
            EXCEPTION
              WHEN e_QTimeOut THEN
                  lv_queue_timed_out := 'Y';
            END;

            IF lv_queue_timed_out = 'Y' THEN
                EXIT ;

            ELSE
  		lv_DequeueOptions.navigation := DBMS_AQ.NEXT_MESSAGE;

                select FE_ID into l_FeID from xdp_fes
                               where fulfillment_element_name = lv_wf_object.FE_NAME;

		insert into XDP_ADAPTER_JOB_QUEUE (
                                   JOB_ID,
                                   FE_ID,
                                   ORDER_ID,
                                   WORKITEM_INSTANCE_ID,
                                   FA_INSTANCE_ID,
                                   QUEUED_ON,
                                   WF_ITEM_TYPE,
                                   CHANNEL_USAGE_CODE,
                                   WF_ITEM_KEY,
                                   SYSTEM_HOLD,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login
                                   )
                           values (XDP_ADAPTER_JOB_QUEUE_S.NEXTVAL,
                                   l_FeID,
                                   lv_wf_object.ORDER_ID,
                                   lv_wf_object.WORKITEM_INSTANCE_ID,
                                   lv_wf_object.FA_INSTANCE_ID,
                                   l_ReProcessEnqTime,
                                   lv_wf_object.WF_ITEM_TYPE,
                                   'NORMAL',
                                   lv_wf_object.WF_ITEM_KEY,
                                   'N',
                                   FND_GLOBAL.USER_ID,
                                   sysdate,
                                   FND_GLOBAL.USER_ID,
                                   sysdate,
                                   FND_GLOBAL.LOGIN_ID);

  			l_ReProcessEnqTime := l_ReProcessEnqTime + (1 / (24*60));
            END IF ;

  END LOOP ;

END DQ_XDP_WF_CHANNEL_REPROCESS;

BEGIN
-- Package initialization
	Find_XDP_SCHEMA;
	Find_XNP_SCHEMA;

	-- Get APPS_MAINTENANCE_MODE parameter for High Availability
	FND_PROFILE.GET('APPS_MAINTENANCE_MODE', g_APPS_MAINTENANCE_MODE);

	IF g_APPS_MAINTENANCE_MODE = 'MAINT' THEN
        /**** Set Log and Output File Names and Directory  ****/

            SELECT nvl(substr(value,1,instr(value,',')-1),value)
              INTO g_logdir
            FROM v$parameter
            WHERE name = 'utl_file_dir';

            select sysdate into g_logdate from dual;

            fnd_file.put_names('XDPAQUTB'||to_char(g_logdate, 'YYYYMMDDHHMISS')||'.log',
                               'XDPAQUTB'||to_char(g_logdate, 'YYYYMMDDHHMISS')||'.out',
                               g_logdir);
        END IF;

END XDP_AQ_UTILITIES;

/
