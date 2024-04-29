--------------------------------------------------------
--  DDL for Package CN_NOTIFY_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_NOTIFY_ORDERS" AUTHID CURRENT_USER AS
-- $Header: cnnooes.pls 120.2 2005/08/29 08:11:32 vensrini ship $
--
-- Procedure Name
--   regular_col_notify
-- Purpose
--   This procedure collects source data for orders
-- History
--
PROCEDURE regular_col_notify
  (
   x_start_period	 cn_periods.period_id%TYPE,
   x_end_period	         cn_periods.period_id%TYPE,
   x_adj_flag	         VARCHAR2,
   parent_proc_audit_id  NUMBER,
   debug_pipe	         VARCHAR2 DEFAULT NULL,
   debug_level	         NUMBER	 DEFAULT NULL,
   x_org_id 			 NUMBER ); -- R12 MOAC Changes

--
-- Procedure Name
--   Get_Notice
-- Purpose
--   This procedure collects order updates from the Order Capture Notification
--   API. It is an infinite loop which
--   gets the latest notification off of the queue. If the order is Booked,
--   this procedure initiates processing the adjustments to the
--   order for OSC.
-- History
--
PROCEDURE Get_Notice(p_parent_proc_audit_id IN  NUMBER,
					 x_org_id IN  NUMBER ); -- R12 MOAC Changes

------------------------------------------------------------------------------+
-- Procedure Name
--   Get_Notice_Conc
-- Purpose
--   Concurrent Program "Order Update Notification" wrapper
--   on top of Get_Notice
------------------------------------------------------------------------------+
PROCEDURE Get_Notice_Conc
  (x_errbuf               OUT NOCOPY VARCHAR2,
   x_retcode              OUT NOCOPY NUMBER,
   p_org_id IN  NUMBER ); -- R12 MOAC Changes

END cn_notify_orders;
 

/
