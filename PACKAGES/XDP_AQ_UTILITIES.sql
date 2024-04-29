--------------------------------------------------------
--  DDL for Package XDP_AQ_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_AQ_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: XDPAQUTS.pls 120.1 2005/06/15 21:52:13 appldev  $ */

-- PL/SQL Specification
-- Define exception
  e_QTimeOut EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_QTimeOut, -25228);
  e_QNavOut EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_QNavOut, -25237);
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);

  e_NothingToDequeueException exception;
  stop_processing exception;

--Global variables
    g_msg_wait_timeout      NUMBER := 10;
    g_sleep_time            NUMBER := 0.01;

--
-- Start SFM AQs
--
PROCEDURE  Start_WF_AQ(
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2);

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
		p_error_description OUT NOCOPY VARCHAR2);

--
-- Stop the SFM AQ
--
PROCEDURE STOP_WF_AQ(
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2);
--
-- DROP the SFM AQ
--
PROCEDURE DROP_WF_AQ(
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2);

/***************   Commented out by SPUSEGAO as pending order Queue has been removed
--
--  Add order to pending queue
--
PROCEDURE Pending_Order_EQ(
		p_order_id IN NUMBER,
		p_prov_date IN DATE,
		p_priority IN NUMBER DEFAULT 100,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2);

****************/
--
--  Dequeue an order from the pending order queue
--

PROCEDURE  Pending_Order_DQ;

/***************   Commented out by SPUSEGAO as pending order Queue has been removed

PROCEDURE  Pending_Order_DQ (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     p_correlation_id IN VARCHAR2,
			     x_message_key OUT NOCOPY VARCHAR2,
			     x_queue_timed_out OUT NOCOPY VARCHAR2);

****************/

/*
--
--  Remove an order from the pending order queue
--  Obsolete
PROCEDURE  Remove_Pending_Order(
		p_order_id IN NUMBER,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2);
*/

--
--  Add order to order processor queue
--
PROCEDURE Add_OrderToProcessorQ(
		p_order_id IN NUMBER ,
		p_order_type in varchar2 default null,
		p_priority IN NUMBER DEFAULT 100,
		p_prov_date IN DATE DEFAULT SYSDATE,
		p_wf_item_type IN varchar2,
		p_wf_item_key  IN Varchar2);

/************** Commented out as this code was being executed by old C dequeuers
--
--  Dequeue from order processor queue
--
PROCEDURE Start_OrderProcessor_Workflow;

****************/

PROCEDURE  Start_OrderProcessor_Workflow (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     p_correlation_id IN VARCHAR2,
			     x_message_key OUT NOCOPY VARCHAR2,
			     x_queue_timed_out OUT NOCOPY VARCHAR2);

--
-- Allow API to  start workitem WF through enqueue
--
PROCEDURE Add_WorkItem_ToQ(
		p_order_id IN NUMBER,
		p_wi_instance_id IN NUMBER,
		p_prov_date IN DATE,
		p_wf_item_type IN VARCHAR2 ,
        p_wf_item_key  IN VARCHAR2,
		p_priority   IN number DEFAULT 100,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2);

/************** Commented out as this code was being executed by old C dequeuers
--
--  Dequeue from workitem queue
--
Procedure Start_Workitem_Workflow;

****************/

PROCEDURE  Start_Workitem_Workflow (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     p_correlation_id IN VARCHAR2,
			     x_message_key OUT NOCOPY VARCHAR2,
			     x_queue_timed_out OUT NOCOPY VARCHAR2);

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
		p_error_description OUT NOCOPY VARCHAR2);

/************** Commented out as this code was being executed by old C dequeuers
--
-- Used by API to start FA workflow
-- through dequeue
--
PROCEDURE Start_FA_Workflow;

****************/

PROCEDURE  Start_FA_Workflow (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     p_correlation_id IN VARCHAR2,
			     x_message_key OUT NOCOPY VARCHAR2,
			     x_queue_timed_out OUT NOCOPY VARCHAR2);

--
-- Allow WF to pass the pipe to next WF through enqueue
--
PROCEDURE HANDOVER_Channel(
		p_channel_name IN  VARCHAR2,
		p_fe_name  IN    VARCHAR2,
		p_wf_item_type IN VARCHAR2,
		p_wf_item_key IN  VARCHAR2,
		p_wf_activity IN Varchar2 Default NULL,
		p_order_id IN number,
		p_wi_instance_id IN number,
		p_fa_instance_id IN number,
		p_return_code OUT NOCOPY NUMBER,
		p_error_description OUT NOCOPY VARCHAR2);


/************** Commented out as this code was being executed by old C dequeuers
--
-- Used by DB job to resume a WF with the new pipe
-- through dequeue
--

PROCEDURE Resume_Next_WF;

****************/

PROCEDURE  Resume_Next_WF (p_message_wait_timeout IN NUMBER DEFAULT 1,
			     p_correlation_id IN VARCHAR2,
			     x_message_key OUT NOCOPY VARCHAR2,
			     x_queue_timed_out OUT NOCOPY VARCHAR2);

PROCEDURE SDP_RESUME_WF
 (p_pipe_name IN VARCHAR2
 ,p_wf_item_type IN VARCHAR2
 ,p_wf_item_key  IN VARCHAR2
 ,p_wf_activity  IN VARCHAR2
 ,p_enq_time IN DATE
 ,P_RETURN_CODE OUT NOCOPY NUMBER
 ,P_ERROR_DESCRIPTION OUT NOCOPY VARCHAR2
 );

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
		p_error_description OUT NOCOPY VARCHAR2);
--
-- Used by API to notify the parent workflow to resume
-- through dequeue
--
PROCEDURE Resume_Parent_Workflow;

--
--  Get the current state of the given queue
--
FUNCTION Get_Queue_State(
		p_queue_name IN VARCHAR2)
 RETURN VARCHAR2;

--
--  Suspend a given queue, if queue_name is not supplied,
--  all queues will be disabled
--
PROCEDURE DISABLE_SDP_AQ(
		p_queue_name IN VARCHAR2,
		p_return_code OUT NOCOPY NUMBER,
            p_error_description OUT NOCOPY VARCHAR2);

--
--  Enable a given queue, if queue_name is not supplied,
--  all queues will be enabled
--
PROCEDURE ENABLE_SDP_AQ(
		p_queue_name IN VARCHAR2,
		p_return_code OUT NOCOPY NUMBER,
            p_error_description OUT NOCOPY VARCHAR2);

--
--  Shut down a given SFM queue, if queue_name is not supplied,
--  all queues will be shutdown
--
PROCEDURE SHUTDOWN_SDP_AQ(
		p_queue_name IN VARCHAR2,
		p_return_code OUT NOCOPY NUMBER,
            p_error_description OUT NOCOPY VARCHAR2);

--
--  Log the dequeue exceptions for the dequeuer
--
PROCEDURE Handle_DQ_Exception(
	  	p_MESSAGE_ID  IN RAW,
        	p_WF_ITEM_TYPE IN VARCHAR2 DEFAULT NULL,
        	p_WF_ITEM_KEY  IN VARCHAR2 DEFAULT NULL,
        	p_CALLER_NAME  IN VARCHAR2,
        	p_CALLBACK_TEXT  IN VARCHAR2 DEFAULT NULL,
        	p_Q_NAME IN VARCHAR2,
        	p_ERROR_DESCRIPTION  IN VARCHAR2,
        	p_ERROR_TIME  IN DATE  DEFAULT sysdate );


PROCEDURE InterfaceWithOSS (
          p_OrderID IN NUMBER,
          p_ObjectType IN VARCHAR2,
          p_ReturnCode OUT NOCOPY NUMBER,
          p_ErrorDescription OUT NOCOPY VARCHAR2);

Procedure LogCommandAuditTrail (FAInstanceID  in  number,
                                FeName in  varchar2,
                                FeType in  varchar2,
                                SW_Generic in  varchar2,
                                CommandSent in  varchar2,
                                SentDate in  DATE,
                                Response in  varchar2,
                                ResponseLong in  CLOB,
                                RespDate in  DATE,
                                ProcName in  varchar2);

Procedure LogCommandAuditTrail (FAInstanceID  in  number,
                                   FeName in  varchar2,
                                   FeType in  varchar2,
                                   SW_Generic in  varchar2,
                                   CommandSent in  varchar2,
                                   SentDate in  DATE,
                                   Response in  varchar2,
                                   RespDate in  DATE,
                                   ProcName in  varchar2);


PROCEDURE DQ_XNP_EVT_Q( p_return_code       OUT NOCOPY NUMBER,
                        p_error_description OUT NOCOPY VARCHAR2)  ;

PROCEDURE DQ_XNP_IN_MSG_Q( p_return_code       OUT NOCOPY NUMBER,
                           p_error_description OUT NOCOPY VARCHAR2)  ;

PROCEDURE DQ_XNP_IN_TMR_Q( p_return_code       OUT NOCOPY NUMBER,
                           p_error_description OUT NOCOPY VARCHAR2)  ;

PROCEDURE DQ_XDP_ORDER_PROC_QUEUE( p_return_code       OUT NOCOPY NUMBER,
                                   p_error_description OUT NOCOPY VARCHAR2)  ;

PROCEDURE DQ_XDP_FA_QUEUE( p_return_code       OUT NOCOPY NUMBER,
                           p_error_description OUT NOCOPY VARCHAR2)  ;

PROCEDURE DQ_XDP_WF_CHANNEL_Q( p_return_code       OUT NOCOPY NUMBER,
                               p_error_description OUT NOCOPY VARCHAR2)  ;

PROCEDURE DQ_XDP_WORKITEM_QUEUE( p_return_code       OUT NOCOPY NUMBER,
                                 p_error_description OUT NOCOPY VARCHAR2)  ;

PROCEDURE DQ_EXCP_REENQ( p_return_code       OUT NOCOPY NUMBER,
                         p_error_description OUT NOCOPY VARCHAR2) ;

PROCEDURE DQ_XDP_ORDER_PROC_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1,
                                   p_correlation_id IN VARCHAR2 );

PROCEDURE DQ_XDP_FA_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1,
                           p_correlation_id IN VARCHAR2 );

PROCEDURE DQ_XDP_WORKITEM_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1,
                                 p_correlation_id IN VARCHAR2 );

PROCEDURE DQ_XDP_WF_CHANNEL_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1,
                                   p_correlation_id IN VARCHAR2 );

PROCEDURE DQ_XNP_IN_MSG_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1 );

PROCEDURE DQ_XNP_IN_EVT_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1 );

PROCEDURE DQ_XNP_IN_TMR_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1 );

PROCEDURE DQ_XNP_OUT_MSG_REENQ( p_message_wait_timeout IN NUMBER DEFAULT 1 );

PROCEDURE ReENQUEUE( p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE
                    ,p_body_text IN VARCHAR2
                    ,p_queue_name IN VARCHAR2
                    ,p_correlation_id IN VARCHAR2 DEFAULT NULL
                    ,p_priority IN INTEGER DEFAULT 1
                    ,p_commit_mode IN NUMBER DEFAULT XNP_MESSAGE.C_ON_COMMIT
                    ,p_delay IN NUMBER DEFAULT DBMS_AQ.NO_DELAY
                   );

PROCEDURE SET_CONTEXT( object_id  IN NUMBER
                      ,object_key IN VARCHAR2
                     );

PROCEDURE DQ_XDP_WF_CHANNEL_REPROCESS;

END XDP_AQ_UTILITIES;

 

/
