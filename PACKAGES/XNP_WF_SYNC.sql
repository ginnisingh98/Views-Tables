--------------------------------------------------------
--  DDL for Package XNP_WF_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_WF_SYNC" AUTHID CURRENT_USER AS
/* $Header: XNPSYNCS.pls 120.2 2006/02/13 07:55:53 dputhiye ship $ */

-- Synchronise a workflow process
--
PROCEDURE process_sync (
  itemtype	IN  VARCHAR2
 ,itemkey		IN  VARCHAR2
 ,actid		IN  NUMBER
 ,funcmode	IN  VARCHAR2
 ,resultout	OUT NOCOPY VARCHAR2
);

-- Register an order for Synchronisation
--
PROCEDURE Sync_Register (
  pp_order_id		IN  NUMBER
 ,po_error_code	OUT NOCOPY NUMBER
 ,po_error_msg	OUT NOCOPY VARCHAR2
);

-- Set the status of a Synchronisation Request to ERROR
--
PROCEDURE Raise_Sync_Error (
  itemtype  	  IN  VARCHAR2
 ,itemkey       IN  VARCHAR2
 ,actid         IN  NUMBER
 ,funcmode      IN  VARCHAR2
 ,resultout     OUT NOCOPY VARCHAR2
);

-- Default Processing Logic for SYNC_ERR Event
--
PROCEDURE Process_Sync_Err (
  p_msg_header	  IN  XNP_MESSAGE.MSG_HEADER_REC_TYPE
 ,x_error_code	  OUT NOCOPY NUMBER
 ,x_error_message   OUT NOCOPY VARCHAR2
);

-- Default Processing Logic for SYNC_TIMER Event
--
PROCEDURE Process_Sync_Timer (
  p_msg_header	  IN  XNP_MESSAGE.MSG_HEADER_REC_TYPE
 ,x_error_code	  OUT NOCOPY NUMBER
 ,x_error_message   OUT NOCOPY VARCHAR2
);

-- Procedure to reset a Synchronisation request
--
PROCEDURE Reset_Sync_Register (
  pp_sync_label		IN  VARCHAR2
 ,po_error_code		OUT NOCOPY NUMBER
 ,po_error_msg		OUT NOCOPY VARCHAR2
);

-- Packaged activity for the following activities
-- IS_LAST_SYNC and PROCESS_SYNC
--
PROCEDURE synchronize (
    itemtype    IN  VARCHAR2
    ,itemkey        IN  VARCHAR2
    ,actid      IN  NUMBER
    ,funcmode   IN  VARCHAR2
    ,resultout  OUT NOCOPY VARCHAR2
);

-- Checks if the work flow invoking this procedure is
-- the last one to synchronize.  Uses the parties_not_in_sync
-- column in xnp_sync_registration table to determine.
--
PROCEDURE is_last_sync (
    itemtype    IN  VARCHAR2
    ,itemkey        IN  VARCHAR2
    ,actid      IN  NUMBER
    ,funcmode   IN  VARCHAR2
    ,resultout  OUT NOCOPY VARCHAR2
);

-- Sets the SDP_RESULT_CODE workflow item attribute
--
PROCEDURE set_result_code (
    p_itemtype    IN  VARCHAR2
    ,p_itemkey    IN  VARCHAR2
    ,p_result_value IN VARCHAR2
);

-- Workflow activity for sync notification
--
PROCEDURE syncnotif ( itemtype     in  varchar2,
	itemkey      in  VARCHAR2,
	actid        in  NUMBER,
	funcmode     in  VARCHAR2,
	result       OUT NOCOPY VARCHAR2
) ;
END xnp_wf_sync;

 

/
