--------------------------------------------------------
--  DDL for Package OTA_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_WF" AUTHID CURRENT_USER as
/* $Header: ottomiwf.pkh 115.2 2002/11/29 13:20:16 jbharath noship $ */



-- ----------------------------------------------------------------------------
-- |---------------------------------< CANCEL_ORDER >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be use to cancel an order.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE CANCEL_ORDER (
itemtype 	IN	VARCHAR2
,itemkey 	IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout   OUT NOCOPY VARCHAR2

);


-- ----------------------------------------------------------------------------
-- |---------------------------------< CREATE_RMA >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to create RMA.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE  CREATE_RMA (
itemtype 	IN	VARCHAR2
,itemkey 	IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout   OUT NOCOPY VARCHAR2
);
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_FULFILL_DATE >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to update Order Line Fulfillment Date.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE  UPDATE_FULFILL_DATE (
itemtype	IN	VARCHAR2
,itemkey	IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout   OUT NOCOPY VARCHAR2

);

-- ----------------------------------------------------------------------------
-- |----------------------------< CHK_INVOICE_EXISTS >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check whethet the Order Line has been
--   invoiced or not.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
--
-- Out Arguments:
--   resultout
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE  CHK_INVOICE_EXISTS (
itemtype 	IN 	VARCHAR2
,itemkey	IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2
);

-- ----------------------------------------------------------------------------
-- |------------------------------------< CHECK_UOM>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the uom of the order line.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
-- Out Arguments:
--   resultout
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE  CHECK_UOM(
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2
);

-- ----------------------------------------------------------------------------
-- |------------------------------------< CHECK_CREATION>------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_user_id,
--   p_login_id
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE CHECK_CREATION(
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2
);

-- ----------------------------------------------------------------------------
-- |------------------------< CHK_ENROLL_STATUS_ADV >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the status of the Enrollment.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
-- Out Arguments:
--   resultout
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE CHK_ENROLL_STATUS_ADV (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid      	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2) ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< CHK_ENROLL_STATUS_ARR >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the Status for Enrollment.This is for
--   Invoicing Rule in arrear.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
-- Out Arguments:
--   resultout
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE CHK_ENROLL_STATUS_ARR (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid  	      IN    NUMBER
,funcmode   	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2);

--
-- ----------------------------------------------------------------------------
-- |----------------------------< CHECK_INVOICE_RULE >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check invoicing rule of the order line.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
--
-- Out Arguments:
--   resultout
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE CHECK_INVOICE_RULE (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2);


-- ----------------------------------------------------------------------------
-- |----------------------------< CANCEL_ENROLLMENT>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to cancel an enrollment.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
--   actid
--   funcmode
--
-- Out Arguments:
--   resultout
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE CANCEL_ENROLLMENT(
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2);


--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_OWNER_EMAIL >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the invoicing rule of the order line.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE UPDATE_OWNER_EMAIL (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2);


-- ----------------------------------------------------------------------------
-- |------------------------< CHK_EVENT_ENROLL_STATUS >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the Status for Enrollment.This is for
--   Invoicing Rule in arrear.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
-- Out Arguments:
--   resultout
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE CHK_EVENT_ENROLL_STATUS (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid  	      IN    NUMBER
,funcmode   	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2);



end  ota_wf;

 

/
