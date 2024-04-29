--------------------------------------------------------
--  DDL for Package Body XDP_FQUEUE_TOOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_FQUEUE_TOOLS" AS
/* $Header: XDPFQTLB.pls 115.4 2002/05/14 13:23:03 pkm ship       $ */

FUNCTION No_Entries (queued_id VARCHAR2) RETURN NUMBER IS
  entries_number NUMBER := 0;
BEGIN
  IF queued_id = 'XDP_PENDING_ORDER_QUEUE' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xdp_pending_order_qtab;
  ELSIF queued_id = 'XDP_ORDER_PROC_QUEUE' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   XDP_ORDER_PROCESSOR_qtab;
  ELSIF queued_id = 'XDP_WORKITEM_QUEUE' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xdp_workitem_qtab;
  ELSIF queued_id = 'XDP_FA_QUEUE' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xdp_fa_qtab;
  ELSIF queued_id = 'XDP_ADAPTER_JOB_QUEUE' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xdp_adapter_job_queue;
  ELSIF queued_id = 'XDP_WF_CHANNEL_Q' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xdp_wf_channel_qtab;
/*  ELSIF queued_id = 'XDP_ADAPTER_ADMIN_REQUEST' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   XDP_ADAPTER_ADMIN_REQS; */
  ELSIF queued_id = 'XNP_IN_MSG_Q' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xnp_in_msg_qtab;
  ELSIF queued_id = 'XNP_OUT_MSG_Q' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xnp_out_msg_qtab;
  ELSIF queued_id = 'XNP_IN_EVT_Q' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xnp_in_evt_qtab;
  ELSIF queued_id = 'XNP_IN_TMR_Q' THEN
     SELECT count(1)
     INTO   entries_number
     FROM   xnp_in_tmr_qtab;
  END IF;
  RETURN entries_number;
END No_Entries;
FUNCTION Max_Entry_Date (queued_id VARCHAR2) RETURN DATE IS
  entry_date DATE;
BEGIN
  IF queued_id = 'XDP_PENDING_ORDER_QUEUE' THEN
     SELECT max(ENQ_TIME)
     INTO   entry_date
     FROM   xdp_pending_order_qtab;
  ELSIF queued_id = 'XDP_ORDER_PROC_QUEUE' THEN
     SELECT max(ENQ_TIME)
     INTO   entry_date
     FROM   XDP_ORDER_PROCESSOR_qtab;
  ELSIF queued_id = 'XDP_WORKITEM_QUEUE' THEN
     SELECT max(ENQ_TIME)
     INTO   entry_date
     FROM   xdp_workitem_qtab;
  ELSIF queued_id = 'XDP_FA_QUEUE' THEN
     SELECT max(ENQ_TIME)
     INTO   entry_date
     FROM   xdp_fa_qtab;
  ELSIF queued_id = 'XDP_ADAPTER_JOB_QUEUE' THEN
     SELECT max(QUEUED_ON)
     INTO   entry_date
     FROM   xdp_adapter_job_queue;
  ELSIF queued_id = 'XDP_WF_CHANNEL_Q' THEN
     SELECT max(enq_time)
     INTO   entry_date
     FROM   xdp_wf_channel_qtab;
/*  ELSIF queued_id = 'XDP_ADAPTER_ADMIN_REQS' THEN
     SELECT max(REQUEST_DATE)
     INTO   entry_date
     FROM   XDP_ADAPTER_ADMIN_REQS; */
  ELSIF queued_id = 'XNP_IN_MSG_Q' THEN
     SELECT max(ENQ_TIME)
     INTO   entry_date
     FROM   xnp_in_msg_qtab;
  ELSIF queued_id = 'XNP_OUT_MSG_Q' THEN
     SELECT max(ENQ_TIME)
     INTO   entry_date
     FROM   xnp_out_msg_qtab;
  ELSIF queued_id = 'XNP_IN_EVT_Q' THEN
     SELECT max(ENQ_TIME)
     INTO   entry_date
     FROM   xnp_in_evt_qtab;
  END IF;
  RETURN entry_date;
END Max_Entry_Date;

FUNCTION Processors_Running (queued_id VARCHAR2) RETURN NUMBER IS
  procs_number NUMBER := 0;
BEGIN
     SELECT count(1)
     INTO   procs_number
     FROM   xdp_dqer_registration
     WHERE  internal_q_name = queued_id;
  RETURN procs_number;
END Processors_Running;

PROCEDURE Do_Commit IS
BEGIN
  COMMIT;
END Do_Commit;
END XDP_FQUEUE_TOOLS;

/
