--------------------------------------------------------
--  DDL for Package OE_INVOICE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INVOICE_WF" OE_Invoice_WF	AUTHID CURRENT_USER AS
/* $Header: OEXWINVS.pls 120.1 2006/03/29 16:52:30 spooruli noship $	*/

-- PROCEDURE XX_ACTIVITY_NAME
--
-- <describe the activity here>
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of	the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--	 - COMPLETE[:<result>]
--	     activity has completed with the indicated result
--	 - WAITING
--	     activity is waiting for additional	transitions
--	 - DEFERED
--	     execution should be defered to background
--	 - NOTIFIED[:<notification_id>:<assigned_user>]
--	     activity has notified an external entity that this
--	     step must be performed.  A	call to	wf_engine.CompleteActivty
--	     will signal when this step	is complete.  Optional
--	     return of notification ID and assigned user.
--	 - ERROR[:<error_code>]
--	     function encountered an error.

PROCEDURE Invoice_Interface
(   itemtype     IN     VARCHAR2
,   itemkey      IN     VARCHAR2
,   actid        IN     NUMBER
,   funcmode     IN     VARCHAR2
,   resultout    IN OUT NOCOPY VARCHAR2
);

END ;

/
