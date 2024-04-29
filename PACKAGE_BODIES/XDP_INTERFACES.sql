--------------------------------------------------------
--  DDL for Package Body XDP_INTERFACES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_INTERFACES" AS
/* $Header: XDPINTFB.pls 120.2 2006/08/09 14:38:25 dputhiye noship $ */


resource_busy exception;
 pragma exception_init(resource_busy, -00054);
e_QTimeOut EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_QTimeOut, -25228);
e_QNavOut EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_QNavOut, -25237);

G_XDP_SCHEMA VARCHAR2(80);
G_LOCK_MSG_SUCCESS CONSTANT VARCHAR2(1) := 'S';
G_LOCK_MSG_FAIL CONSTANT VARCHAR2(1) := 'F';
G_LOCK_MSG_ERROR CONSTANT VARCHAR2(1) := 'E';
dbg_msg  VARCHAR2(2000);
--
-- Private API which will lock and remove a message from queue
--
PROCEDURE Lock_and_Remove_Msg(
	p_msg_id in raw,
	p_queue_name in varchar2,
	p_remove_flag in varchar2 DEFAULT 'Y',
	x_user_data OUT NOCOPY SYSTEM.XDP_WF_CHANNELQ_TYPE,
	x_lock_status OUT NOCOPY varchar2,
	x_error OUT NOCOPY varchar2);

--
-- Private API which will remove a canceled order from the pending_order queue
--
PROCEDURE CANCEL_READY_ORDER
  	       (p_sdp_order_id     IN NUMBER,
	        p_msg_id           IN RAW,
	        p_caller_name      IN VARCHAR2,
	        return_code       OUT NOCOPY NUMBER,
	        error_description OUT NOCOPY VARCHAR2);
--
-- Private API which will remove a canceled order from the processor queue
--

PROCEDURE Remove_Order_From_ProcessorQ(
	p_sdp_order_id in number,
	p_caller_name in varchar2,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);

--
-- Private API which will remove a workitem from queue
--
PROCEDURE Remove_WI_From_Q(
	p_wi_instance_id in number,
	p_msg_id in raw,
	p_caller_name in varchar2,
	p_state in varchar2,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);

--
-- Private API which will remove an FA from queue
--
PROCEDURE Remove_FA_From_Q(
	p_fa_instance_id in number,
	p_msg_id in raw,
	p_caller_name in varchar2,
	p_state in varchar2,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);

--
-- Private API which will abort all workflow processes
-- for the given order
--
PROCEDURE Abort_Order_Workflows(
	p_sdp_order_id in number,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);

--
-- Private API which will check if all FAs are ready for cancel
-- for the given order
--
FUNCTION ARE_ALL_FAS_READY_FOR_CANCEL
            ( p_order_id  IN NUMBER
            ) RETURN BOOLEAN ;

--
-- Function to check whether order_type is registered as Maintenance Mode type
--

FUNCTION IS_ORDER_TYPE_MAINT_AVAIL (
        P_ORDER_TYPE     IN VARCHAR2 )
        RETURN BOOLEAN ;

--
-- Private API which will cancel order with status_code 'STANDBY'
--
PROCEDURE CANCEL_STANDBY_ORDER
           (p_order_id           IN NUMBER,
	    p_caller_name        IN VARCHAR2,
 	    return_code 	OUT NOCOPY NUMBER,
 	    error_description 	OUT NOCOPY VARCHAR2);

--
-- Private API which will cancel order with status_code 'ERROR' OR 'IN PROGRESS'
--
PROCEDURE CANCEL_INPROGRESS_ORDER
                 ( p_sdp_order_id     IN NUMBER,
	           p_msg_id           IN RAW,
	           p_caller_name      IN VARCHAR2,
	           return_code       OUT NOCOPY NUMBER,
	           error_description OUT NOCOPY VARCHAR2);


--
-- Private API which will remove an FA from queue
--

PROCEDURE CANCEL_FA
	    (p_order_id         IN NUMBER,
             p_fa_instance_id   IN NUMBER,
	     p_msg_id           IN RAW,
	     p_caller_name      IN VARCHAR2,
             p_fa_wf_item_type  IN VARCHAR2,
             p_fa_wf_item_key   IN VARCHAR2,
	     p_status           IN VARCHAR2,
	     return_code       OUT NOCOPY NUMBER,
	     error_description OUT NOCOPY VARCHAR2);


--
-- Private API which will remove a workitem from queue
--
PROCEDURE CANCEL_WORKITEM
             (p_wi_instance_id   IN NUMBER,
              p_msg_id           IN RAW,
              p_wi_wf_item_type  IN VARCHAR2,
              p_wi_wf_item_key   IN VARCHAR2,
              p_caller_name      IN VARCHAR2,
              p_status           IN VARCHAR2,
              return_code       OUT NOCOPY NUMBER,
              error_description OUT NOCOPY VARCHAR2);

--
-- Private API which will update xdp_order_headers status_code
--
--
PROCEDURE UPDATE_XDP_ORDER_STATUS
            (p_order_id         IN NUMBER ,
             p_status           IN VARCHAR2,
             p_caller_name      IN VARCHAR2,
             return_code       OUT NOCOPY NUMBER,
              error_description OUT NOCOPY VARCHAR2) ;

--
-- Private API which will update xdp_order_line_items status_code
--
--
PROCEDURE UPDATE_XDP_ORDER_LINE_STATUS
            (p_order_id         IN NUMBER,
             p_lineitem_id      IN NUMBER ,
             p_status           IN VARCHAR2,
             p_caller_name      IN VARCHAR2,
             return_code       OUT NOCOPY NUMBER,
             error_description OUT NOCOPY VARCHAR2) ;

--
-- Private API which will update xdp_fulfill_worklist status_code
--
--

PROCEDURE UPDATE_XDP_WI_INSTANCE_STATUS
            (p_order_id          IN NUMBER,
             p_wi_instance_id    IN NUMBER ,
             p_status            IN VARCHAR2,
             p_caller_name       IN VARCHAR2,
             return_code        OUT NOCOPY NUMBER,
              error_description OUT NOCOPY VARCHAR2) ;

--
-- Private API which will update xdp_fa_runtime_list status_code
--
--

PROCEDURE UPDATE_XDP_FA_INSTANCE_STATUS
            (p_fa_instance_id    IN NUMBER ,
             p_status            IN VARCHAR2,
             p_caller_name       IN VARCHAR2,
             return_code        OUT NOCOPY NUMBER,
              error_description OUT NOCOPY VARCHAR2) ;

--
-- Provate API to update status or outbound messages to 'CANCELED' for canceled orders
--

PROCEDURE CANCEL_READY_MSGS(p_order_id       IN NUMBER ,
                            x_error_code    OUT NOCOPY NUMBER,
                            x_error_message OUT NOCOPY VARCHAR2) ;

--
-- Private API which will cancel the order
--
--

PROCEDURE CancelOrder(
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_caller_name 		IN VARCHAR2,
 	RETURN_CODE 		OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2);


PROCEDURE Process_Old_Order(
 	P_ORDER_HEADER 		IN  XDP_TYPES.ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN  XDP_TYPES.ORDER_PARAMETER_LIST,
 	P_ORDER_LINE_LIST 	IN  XDP_TYPES.ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN  XDP_TYPES.LINE_PARAM_LIST,
 	P_execution_mode 	IN  VARCHAR2 DEFAULT 'ASYNC',
	SDP_ORDER_ID		   OUT NOCOPY NUMBER,
 	RETURN_CODE 		IN OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	IN OUT NOCOPY VARCHAR2);

    -- ------------------------------------------
  -- API for upstream ordering system to submit
  -- a service activation order
  -- -------------------------------------------

  PROCEDURE Process_Order(
 	P_ORDER_HEADER 		IN  XDP_TYPES.ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN  XDP_TYPES.ORDER_PARAMETER_LIST,
 	P_ORDER_LINE_LIST 	IN  XDP_TYPES.ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN  XDP_TYPES.LINE_PARAM_LIST,
	SDP_ORDER_ID		   OUT NOCOPY NUMBER,
 	RETURN_CODE 		IN OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	IN OUT NOCOPY VARCHAR2)
IS
   	lv_ORDER_HEADER 		XDP_TYPES.ORDER_HEADER;
 	lv_ORDER_PARAMETER 	XDP_TYPES.ORDER_PARAMETER_LIST;
 	lv_ORDER_LINE_LIST 	XDP_TYPES.ORDER_LINE_LIST;
 	lv_LINE_PARAMETER_LIST 	XDP_TYPES.LINE_PARAM_LIST;

 -- PL/SQL Block
BEGIN
      lv_order_header := P_ORDER_HEADER ;
      lv_order_parameter := P_ORDER_PARAMETER ;
      lv_ORDER_LINE_LIST := P_ORDER_LINE_LIST ;
      lv_LINE_PARAMETER_LIST  := P_LINE_PARAMETER_LIST ;
      Process_Old_Order(
     		lv_ORDER_HEADER 	,
     		lv_ORDER_PARAMETER ,
 	    	lv_ORDER_LINE_LIST ,
 	        lv_LINE_PARAMETER_LIST ,
            'ASYNC',
    		SDP_ORDER_ID,
 	    	RETURN_CODE ,
 		    ERROR_DESCRIPTION);
EXCEPTION
WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
END Process_Order;

PROCEDURE Process_DRC_Order(
	p_workitem_id  IN NUMBER,
	p_task_parameter IN XDP_TYPES.ORDER_PARAMETER_LIST,
	x_order_id OUT NOCOPY NUMBER,
	x_return_code OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2)
IS
   	l_order_header 		  xdp_types.order_header;
 	l_order_parameter 	      xdp_types.order_parameter_list;
 	l_order_line_list 	      xdp_types.order_line_list;
 	l_line_parameter_list 	  xdp_types.line_param_list;

    l_workitem_name VARCHAR2(200);
    l_order_id NUMBER;
BEGIN

    SELECT XDP_ORDER_HEADERS_S.NextVal
        INTO l_order_id
        FROM dual;

    l_ORDER_HEADER.order_number := 'DRC-'||TO_CHAR(l_order_id+1);
    l_ORDER_HEADER.provisioning_date := sysdate;
    l_ORDER_HEADER.order_type := 'DRC';

   	SELECT
        workitem_name
    INTO
        l_workitem_name
    FROM
        xdp_workitems
    WHERE
        workitem_id = p_workitem_id;

    l_order_line_list(1).line_number := 1;
    l_order_line_list(1).workitem_id := p_workitem_id;
    l_order_line_list(1).line_item_name := l_workitem_name;
    l_order_line_list(1).provisioning_date := sysdate;

    IF p_task_parameter.count > 0 THEN
        FOR l_count in 1..p_task_parameter.count LOOP
            l_line_parameter_list(l_count).line_number := 1;
            l_line_parameter_list(l_count).parameter_name := p_task_parameter(l_count).parameter_name;
            l_line_parameter_list(l_count).parameter_value := p_task_parameter(l_count).parameter_value;
        END LOOP;
    END IF;

    Process_Old_Order(
     		l_order_header 	,
     		l_order_parameter ,
 	    	l_order_line_list ,
 	        l_line_parameter_list ,
            'SYNC',
    		x_order_id,
 	    	x_return_code ,
 		    x_error_description);
EXCEPTION
WHEN NO_DATA_FOUND THEN
     x_return_code := SQLCODE;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_WORKITEM_ID');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     x_error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
     x_return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     x_error_description := FND_MESSAGE.GET;
END Process_DRC_Order;

--
-- Private API check if all FAs  are ready for cancel for the given order
--

FUNCTION ARE_ALL_FAS_READY_FOR_CANCEL
            ( p_order_id  IN NUMBER)
  RETURN BOOLEAN IS

l_return  BOOLEAN := TRUE ;

CURSOR c_fa IS
    SELECT 'Y'
      FROM xdp_fulfill_worklist fw,
           xdp_fa_runtime_list fr
     WHERE fw.order_id            = p_order_id
       AND fw.workitem_instance_id = fr.workitem_instance_id
       AND fr.status_code IN ('IN PROGRESS');

BEGIN
   FOR c_fa_rec IN c_fa
       LOOP
           l_return := FALSE ;
       END LOOP ;

   RETURN l_return ;

END ARE_ALL_FAS_READY_FOR_CANCEL;


 -- -------------------------------------------------------------------
 -- check to see whether order type is available during maintenance mode
 -- -------------------------------------------------------------------

    FUNCTION IS_ORDER_TYPE_MAINT_AVAIL (
              p_order_type in varchar2 )
      RETURN BOOLEAN IS
        l_count NUMBER;

    BEGIN

        SELECT count(*)
          INTO l_count
        FROM FND_LOOKUP_VALUES
        WHERE UPPER(lookup_code) = UPPER(p_order_type)
          AND lookup_type = 'XDP_HA_ORDER_TYPES';

        IF l_count < 1 THEN
            return false;
        ELSE
            return true;
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.IS_ORDER_TYPE_MAINT_AVAIL');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);

    END IS_ORDER_TYPE_MAINT_AVAIL;

--
-- API for upstream ordering system to cancel a service activation order
--

PROCEDURE Cancel_Order(
 	P_ORDER_NUMBER 		IN VARCHAR2,
	p_order_version		IN VARCHAR2,
	p_CALLER_NAME		IN VARCHAR2 DEFAULT user,
 	RETURN_CODE 		OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2)
IS
  lv_id number;
BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER')) THEN
         dbg_msg := (' Being Cancel Order for Order Number : '||p_order_number||' Order Version : '||p_order_version);
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER', dbg_msg);
	END IF;
      END IF;
   END IF;


  BEGIN
     IF p_order_version IS NOT NULL THEN
        SELECT order_id
          INTO lv_id
          FROM xdp_order_headers
         WHERE external_order_number = (p_order_number) and
	       external_order_version = (p_order_version);
      ELSE
        SELECT order_id
          INTO lv_id
          FROM xdp_order_headers
        WHERE external_order_number = (p_order_number) and
    	      external_order_version IS NULL;
      END IF;

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER')) THEN
           dbg_msg := ('Order Number is: '||p_order_number||' Order Version is : '||p_order_version||' Order Id is : '||lv_id);
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER', dbg_msg);
	   END IF;
    END IF;
   END IF;

  EXCEPTION
       WHEN no_data_found THEN
	    return_code := -191314;
	    FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_VERSION_NOTEXISTS');
	    FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', p_order_number);
	    FND_MESSAGE.SET_TOKEN('ORDER_VERSION', p_order_version);
	    error_description := FND_MESSAGE.GET;
            return;
  END;

   CANCEL_ORDER(
	        lv_id,
	        p_caller_name,
	        return_code,
	        error_description);

   IF return_code <> 0 THEN
	 return;
   END IF;

EXCEPTION
     WHEN others THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END CANCEL_ORDER;

--
-- API for upstream ordering system to cancel a service activation order
--
PROCEDURE CANCEL_ORDER
 	      (P_SDP_ORDER_ID 		IN NUMBER,
	       p_CALLER_NAME		IN VARCHAR2 DEFAULT user,
 	       RETURN_CODE 		OUT NOCOPY NUMBER,
 	       ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2)
IS
  lv_state     VARCHAR2(40);
  lv_tmp       NUMBER;
  lv_locked_q  VARCHAR2(80);
  lv_timer_ret NUMBER;
  lv_timer_err VARCHAR2(800);
  lv_event_ret NUMBER;
  lv_event_err VARCHAR2(800);
  lv_msg_ret   NUMBER;
  lv_msg_error VARCHAR2(800);

  CURSOR lc_prereq_order IS
	SELECT related_order_id
	  FROM xdp_order_relationships
	 WHERE order_id           = p_sdp_order_id
           AND order_relationship = 'IS_PREREQUISITE_OF';

  lv_user VARCHAR2(80);

  /* --Date: 09-AUG-06. Author: DPUTHIYE  Bug#:5453523
     --Change Description: Need to cancel SFM-OM interface flows as well.
     --Cursor to fetch the item_keys for the SFM-OM Interface flows to be cancelled.
  */
  CURSOR lc_intf_flow_keys (p_order_number NUMBER) IS
      	SELECT line_number
	FROM xdp_order_line_items xoli, xdp_order_headers xoh
	WHERE xoli.order_id = xoh.order_id
	AND   xoh.order_source = 'OE_ORDER_HEADERS_ALL'
        AND   xoh.order_id = p_order_number;

  -- Exception 'Process <item_type>/<item_key> does not exist' expected from the WF API.
  e_no_such_process EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_no_such_process, -20002);
  --End of fix:5453523

BEGIN

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
      IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER')) THEN
        dbg_msg := (' Being Overloaded Cancel Order for Order Id : '||P_SDP_ORDER_ID);
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER', dbg_msg);
	END IF;
      END IF;
   END IF;

   IF p_caller_name IS NULL THEN
      lv_user := user;
   ELSE
     lv_user := p_caller_name;
   END IF;

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER')) THEN
        dbg_msg := ('Calling CANCELORDER');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER', dbg_msg);
	END IF;
     END IF;
   END IF;


   CANCElORDER (p_sdp_order_id,
	        lv_user,
	        return_code,
	        error_description);

   IF return_code <> 0 THEN
	 return;
   END IF;

   /*
	If we had successfully canceled the order,
	we should try to cancel all the orders which
	use this one as prerequisite.  The following
	is commented out for now because we still try
      to finalize the requirement.

	FOR lv_rel_ord_rec in lc_prereq_order
            LOOP
               CANCELORDER
	      	    (p_sdp_order_id    => lv_rel_ord_rec.related_order_id,
		     p_caller_name     => lv_user,
		     return_code       => return_code,
		     error_description => error_description);

	       if return_code <> 0 then
	     	  return;
	       end if;
	   END LOOP;
   */

  /**
    We should also clean upo the timer events.
    Once the timer API is ready, put the following code:
   **/

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER')) THEN
        dbg_msg := ('Completed Order Cancelation deregistering timers');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER', dbg_msg);
	END IF;
     END IF;
   END IF;


     XNP_TIMER_CORE.DEREGISTER(p_order_id      => p_sdp_order_id,
                               x_error_code    => lv_timer_ret,
                               x_error_message => lv_timer_err);
      IF lv_timer_ret <> 0 then
     	lv_timer_err := ' Warning: Can not clean up timer event after '||
			' the order has been canceled. '||lv_timer_err;
      END IF;


   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER')) THEN
        dbg_msg := ('Deregistering Events ');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER', dbg_msg);
	END IF;
     END IF;
   END IF;

  /**
   **  Clean up all the Events/Messages outstanding for the Order
   **/

    XNP_EVENT.DEREGISTER(p_order_id      => p_sdp_order_id,
                         x_error_code    => lv_event_ret,
                         x_error_message => lv_event_err);

    IF lv_event_ret <> 0 THEN
     	lv_event_err := ' Warning: Can not clean up outstanding events or messages '||
			' after the order has been canceled.  '||lv_event_err;
    END IF;

	IF lv_timer_ret <> 0 OR lv_event_ret <> 0 THEN
		return_code := -20111;
		error_description := lv_timer_err||lv_event_err;
	END IF;

    /**
     ** Mark massages for the order in xnp_msgs table to 'CANCELED'
     **/

   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER')) THEN
        dbg_msg := ('Canceling Messages ');
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_ORDER.VALIDATE_ORDER', dbg_msg);
	END IF;
     END IF;
   END IF;

        CANCEL_READY_MSGS(p_order_id      => p_sdp_order_id,
                          x_error_code    => lv_msg_ret,
                          x_error_message => lv_msg_error  );

        IF lv_msg_ret <> 0 THEN
           lv_msg_error := 'Warning : Can not clean up outstanding messages '||
                           'after the order has been canceled.  '||lv_msg_error ;
        END IF;

            IF lv_timer_ret <> 0 OR lv_event_ret <> 0 OR  lv_msg_ret <> 0 THEN
               return_code := -20111;
               error_description := lv_timer_err||lv_event_err;
            END IF;

  /*  Date: 09-AUG-06. Author: DPUTHIYE  Bug#:5453523
  **  Change Description: For orders that originate from Order Management, the SFM-OM Interface flows
  **  must be cancelled.
  */
  IF((FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER')) THEN
        dbg_msg := ('Cancelling SFM-OM Interface flows ');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_ORDER', dbg_msg);
     END IF;
  END IF;

  -- SFM-OM Interface flows have item_key = 'XDPOMINT' and item_key = <xdp_order_line_items.line_number>.
  -- For each interface workflow process generated for this order
  FOR l_intf_flow_key IN lc_intf_flow_keys (p_sdp_order_id)
  LOOP
      BEGIN     --For the exceptions from the WF API call.
          wf_engine.abortProcess('XDPOMINT', l_intf_flow_key.line_number);
      EXCEPTION
          WHEN e_no_such_process THEN
              NULL; -- Ignore. The SFM-OM interface process may not have been created for some lines.
          WHEN OTHERS THEN
              raise;  --An unexpected exception must be thrown out.
      END;
  END LOOP;
  -- End of fix:5453523

EXCEPTION
 when others then
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;

END Cancel_Order;

--
-- Private API to cancel a service order
--
PROCEDURE CANCELORDER(
 	      p_sdp_order_id 	 IN NUMBER,
	      p_caller_name 	 IN VARCHAR2,
 	      return_code 	OUT NOCOPY NUMBER,
 	      error_description OUT NOCOPY VARCHAR2)
IS
  lv_state      VARCHAR2(40);
  lv_msg_id     RAW(16);
  l_status      VARCHAR2(40);
  lv_mode       VARCHAR2(8);  -- maintenance mode profile
  lv_order_type VARCHAR2(40);

-- Declare exception for order_type not registered
  e_order_type_not_reg       EXCEPTION;

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
          dbg_msg := ('Procedure XDP_INTERFACES.CANCELORDER begins.');
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
	  END IF;
       END IF;
     END IF;

     return_code := 0;
     SAVEPOINT lv_order_tag;

     SELECT status_code,
            msgid,
            order_type
       INTO lv_state,
            lv_msg_id,
            lv_order_type
       FROM xdp_order_headers
      WHERE order_id = p_sdp_order_id;

--============================================================
  -- Validate Order Type in High Availability Maintenance Mode
--============================================================
   FND_PROFILE.GET('APPS_MAINTENANCE_MODE', lv_mode);

   IF lv_mode = 'MAINT' THEN

       IF IS_ORDER_TYPE_MAINT_AVAIL(lv_order_type) = false THEN
           raise e_order_type_not_reg;
       END IF;

   END IF;
--============================================================


     IF lv_state IN ('CANCELED','ABORTED') THEN

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
              dbg_msg := ('Order Status is : '||lv_state);
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
	      END IF;
             END IF;
           END IF;

        return_code := -191315;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_CANCEL');
        FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
        error_description := FND_MESSAGE.GET;
        return;

     ELSIF lv_state IN ('SUCCESS','SUCCESS_WITH_OVERRIDE') THEN

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
              dbg_msg := ('Order Status is : '||lv_state);
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
		END IF;
             END IF;
           END IF;

          return_code := -191316;
       	  FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_PROCESS');
	  FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	  error_description := FND_MESSAGE.GET;
          return;

     ELSIF lv_state = 'STANDBY' THEN

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
              dbg_msg := ('Order Status is : '||lv_state||' Calling CANCEL_STANDBY_ORDER ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
		END IF;
             END IF;
           END IF;

           CANCEL_STANDBY_ORDER(p_sdp_order_id,
                                p_caller_name,
 	                        return_code,
 	                        error_description );
           IF return_code <> 0 THEN
              rollback to lv_order_tag;
              return;
           END IF;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
              dbg_msg := ('Completed CANCEL_STANDBY_ORDER ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
		END IF;
             END IF;
           END IF;

     ELSIF lv_state = 'READY' THEN

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
              dbg_msg := ('Order Status is : '||lv_state||' Calling CANCEL_READY_ORDER ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
		END IF;
             END IF;
           END IF;

           CANCEL_READY_ORDER
                 (p_sdp_order_id    => p_sdp_order_id,
                  p_msg_id          => lv_msg_id,
                  p_caller_name     => p_caller_name,
                  return_code       => return_code,
                  error_description => error_description);

           IF return_code <> 0 THEN
              rollback to lv_order_tag;
              return;
           END IF;


           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
              dbg_msg := ('Completed CANCEL_READY_ORDER ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
		END IF;
             END IF;
           END IF;

     ELSIF lv_state IN ('ERROR','IN PROGRESS') THEN

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
              dbg_msg := ('Order Status is : '||lv_state||' Calling CANCEL_INPROGRESS_ORDER ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
		END IF;
             END IF;
           END IF;

           CANCEL_INPROGRESS_ORDER
                 ( p_sdp_order_id    => p_sdp_order_id,
	 	   p_msg_id          => lv_msg_id,
		   p_caller_name     => p_caller_name,
		   return_code       => return_code,
		   error_description => error_description);

           IF return_code <> 0 THEN
              rollback to lv_order_tag;
              return;
           END IF;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
              dbg_msg := ('Completed CANCEL_INPROGRESS_ORDER ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
		END IF;
             END IF;
           END IF;

     ELSE

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER')) THEN
             dbg_msg := ('Unknown Order Status ');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCELORDER', dbg_msg);
	      END IF;
            END IF;
          END IF;

          return_code := -191317;
    	  FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_UNKNOWN');
	  FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	  FND_MESSAGE.SET_TOKEN('STATUS', lv_state);
	  error_description := FND_MESSAGE.GET;
          return;
     END IF;
     commit;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
        rollback to lv_order_tag;
        return_code := SQLCODE;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
        FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
        error_description := FND_MESSAGE.GET;

     WHEN e_order_type_not_reg THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_TYPE_NOT_AVAILABLE');
        FND_MESSAGE.SET_TOKEN('ORDNUM', p_sdp_order_id);
        error_description := FND_MESSAGE.GET;

     WHEN OTHERS THEN
          rollback to lv_order_tag;
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END CANCELORDER;

--
-- Private API to cancel order with 'STANDBY' status
--

PROCEDURE CANCEL_STANDBY_ORDER
           (p_order_id           IN NUMBER,
	    p_caller_name        IN VARCHAR2,
 	    return_code 	OUT NOCOPY NUMBER,
 	    error_description 	OUT NOCOPY VARCHAR2) IS

l_status_code VARCHAR2(40);

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER')) THEN
          dbg_msg := ('Procedure XDP_INTERFACES.CANCEL_STANDBY_ORDER begins. ');
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER', dbg_msg);
	  END IF;
       END IF;
     END IF;

    SELECT status_code
      INTO l_status_code
      FROM xdp_order_headers
     WHERE order_id = p_order_id
       FOR UPDATE NOWAIT ;

    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER')) THEN
          dbg_msg := ('Aquired Lock on XDP_ORDER_HEADERS Calling UPDATE_XDP_ORDER_STATUS ');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER', dbg_msg);
	  END IF;
       END IF;
    END IF;

    -- update status_code of the XDP_ORDER_HEADERS

       UPDATE_XDP_ORDER_STATUS
            (p_order_id          => p_order_id,
             p_status            => 'CANCELED',
             p_caller_name       => p_caller_name,
             return_code         => return_code,
             error_description  => error_description);

           IF return_code <> 0 THEN
              return;
           END IF;


    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER')) THEN
          dbg_msg := ('Completed UPDATE_XDP_ORDER_STATUS Calling UPDATE_XDP_ORDER_LINE_STATUS ');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER', dbg_msg);
	  END IF;
       END IF;
    END IF;

    -- update status_code of the XDP_ORDER_LINE_ITEMS

       UPDATE_XDP_ORDER_LINE_STATUS
            (p_order_id         => p_order_id ,
             p_lineitem_id      => null ,
             p_status           => 'CANCELED',
             p_caller_name      => p_caller_name,
             return_code        => return_code ,
             error_description  => error_description );

           IF return_code <> 0 THEN
              return;
           END IF;



    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER')) THEN
          dbg_msg := ('Completed UPDATE_XDP_ORDER_LINE_STATUS Calling UPDATE_XDP_WI_INSTANCE_STATUS ');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER', dbg_msg);
	  END IF;
       END IF;
    END IF;

    -- update status_code of the XDP_FULFILL_WORKLIST

      UPDATE_XDP_WI_INSTANCE_STATUS
            (
             p_order_id         => p_order_id ,
             p_wi_instance_id   => null,
             p_status           => 'CANCELED',
             p_caller_name      => p_caller_name,
             return_code        => return_code,
              error_description => error_description );

           IF return_code <> 0 THEN
              return;
           END IF;


    IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER')) THEN
          dbg_msg := ('Completed UPDATE_XDP_WI_INSTANCE_STATUS ');
	  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_STANDBY_ORDER', dbg_msg);
	  END IF;
       END IF;
    END IF;

EXCEPTION
     WHEN resource_busy OR no_data_found THEN
          return_code := -191318;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_CANNOT_REMOVE_ORDER');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', sqlcode||' - '||sqlerrm);
          error_description := FND_MESSAGE.GET;
          return;
     WHEN others THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END CANCEL_STANDBY_ORDER ;

--
-- Private API which will remove a canceled order
-- from the pending_order queue
--
PROCEDURE CANCEL_READY_ORDER(
	        p_sdp_order_id     IN NUMBER,
	        p_msg_id           IN RAW,
	        p_caller_name      IN VARCHAR2,
	        return_code       OUT NOCOPY NUMBER,
	        error_description OUT NOCOPY VARCHAR2) IS

lv_id                 NUMBER;
lv_user_data          SYSTEM.XDP_WF_CHANNELQ_TYPE;
lv_lock_status        VARCHAR2(1);
lv_msg_id             RAW(16);
lv_error              VARCHAR2(1000);
lv_state              VARCHAR2(100);
e_cannot_cancel_order EXCEPTION ;

/*  Date: 09-AUG-06. Author: DPUTHIYE  Bug#:5453523
**  Change Description: The %MAIN% order workflow process that also needs to be cancelled.
**  must be cancelled.
*/
l_main_wf_item_type VARCHAR2(8);    --wf_items.item_type%TYPE;
l_main_wf_item_key  VARCHAR2(240);  --wf_items.item_key%TYPE;

-- Exception 'Process <item_type>/<item_key> does not exist' expected from the WF API.
e_no_such_process EXCEPTION;
PRAGMA EXCEPTION_INIT(e_no_such_process, -20002);
--End of Fix: Bug#:5453523

BEGIN

        IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
          IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER')) THEN
            dbg_msg := ('Procedure XDP_INTERFACES.CANCEL_READY_ORDER begins.');
	    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER', dbg_msg);
	    END IF;
          END IF;
        END IF;

  	return_code := 0;

	LOCK_AND_REMOVE_MSG(
		p_msg_id      => cancel_ready_order.p_msg_id,
		p_queue_name  => 'XDP_ORDER_PROC_QUEUE',
		x_user_data   => lv_user_data,
		x_lock_status => lv_lock_status,
		x_error       => lv_error);

	IF lv_lock_status = G_LOCK_MSG_SUCCESS THEN

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER')) THEN
                dbg_msg := ('Aquired Lock on XDP_ORDER_PROC_QUEUE Calling UPDATE_XDP_ORDER_STATUS ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER', dbg_msg);
		END IF;
              END IF;
           END IF;

           UPDATE_XDP_ORDER_STATUS
                  (p_order_id         => p_sdp_order_id,
                   p_status           => 'CANCELED',
                   p_caller_name      => p_caller_name,
                   return_code        => return_code ,
                   error_description  => error_description );

           IF return_code <> 0 THEN
              return;
           END IF;


           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER')) THEN
                dbg_msg := ('Completed UPDATE_XDP_ORDER_STATUS Calling UPDATE_XDP_ORDER_LINE_STATUS ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER', dbg_msg);
		END IF;
              END IF;
           END IF;

            UPDATE_XDP_ORDER_LINE_STATUS
                   (p_order_id        => p_sdp_order_id ,
                    p_lineitem_id     => null ,
                    p_status          => 'CANCELED',
                    p_caller_name     => p_caller_name,
                    return_code       => return_code,
                    error_description => error_description);

           IF return_code <> 0 THEN
              return;
           END IF;


           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER')) THEN
                dbg_msg := ('Completed UPDATE_XDP_ORDER_LINE_STATUS Calling UPDATE_XDP_WI_INSTANCE_STATUS ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER', dbg_msg);
		END IF;
              END IF;
           END IF;

            UPDATE_XDP_WI_INSTANCE_STATUS
                     (p_order_id        => p_sdp_order_id ,
                      p_wi_instance_id  => null ,
                      p_status          => 'CANCELED',
                      p_caller_name     => p_caller_name,
                      return_code       => return_code,
                      error_description => error_description );

           IF return_code <> 0 THEN
              return;
           END IF;

           /*  Date: 09-AUG-06. Author: DPUTHIYE  Bug#:5453523
           **  Change Description: Cancel also the %MAIN% workflow process (XDPPROV) for the READY ORDER
	   **  The wf_item_type and wf_item_key are available from the order header.
           **  A no_data_found is not expected here.
           */
           IF((FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER')) THEN
                 dbg_msg := ('Cancelling the MAIN order workflow process');
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER', dbg_msg);
              END IF;
           END IF;

           SELECT wf_item_type, wf_item_key
           INTO l_main_wf_item_type, l_main_wf_item_key
           FROM xdp_order_headers
           WHERE order_id = p_sdp_order_id;

           IF (l_main_wf_item_type IS NOT NULL AND l_main_wf_item_key IS NOT NULL) THEN
              BEGIN     --For the exceptions from the WF API call.
                  wf_engine.abortProcess(l_main_wf_item_type, l_main_wf_item_key);
              EXCEPTION
              WHEN e_no_such_process THEN
                  NULL; -- Ignore. The process does not exist.
              WHEN OTHERS THEN
                  raise;  --An unexpected exception must be thrown out.
              END;
           END IF;
           --End of Fix: Bug#:5453523

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER')) THEN
                dbg_msg := ('Completed UPDATE_XDP_WI_INSTANCE_STATUS ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER', dbg_msg);
		END IF;
              END IF;
           END IF;

	   return;

	ELSIF lv_lock_status = G_LOCK_MSG_FAIL THEN

              IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER')) THEN
                    dbg_msg := ('Colud not Aquire Lock Calling CANCEL_INPROGRESS_ORDER ');
		    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                   	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_ORDER', dbg_msg);
		    END IF;
                 END IF;
              END IF;

              CANCEL_INPROGRESS_ORDER
                 ( p_sdp_order_id    => cancel_ready_order.p_sdp_order_id,
                   p_msg_id          => cancel_ready_order.p_msg_id ,
                   p_caller_name     => cancel_ready_order.p_caller_name,
                   return_code       => return_code,
                   error_description => error_description);

           IF return_code <> 0 THEN
              return;
           END IF;
           RETURN;
	ELSE
             RAISE e_cannot_cancel_order ;
	END IF;

EXCEPTION
     WHEN e_cannot_cancel_order THEN
          return_code := -191318;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_CANNOT_REMOVE_ORDER');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', lv_error);
          error_description := FND_MESSAGE.GET;
          return;
     WHEN OTHERS THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END CANCEL_READY_ORDER;


PROCEDURE CANCEL_INPROGRESS_ORDER
                 ( p_sdp_order_id     IN NUMBER,
	           p_msg_id           IN RAW,
	           p_caller_name      IN VARCHAR2,
	           return_code       OUT NOCOPY NUMBER,
	           error_description OUT NOCOPY VARCHAR2)
IS

lv_id            NUMBER;
lv_item_type     VARCHAR2(80);
lv_item_key      VARCHAR2(300);
lv_abort_wf      BOOLEAN := FALSE;
lv_state         VARCHAR2(80);
lv_in_queue      VARCHAR2(1) := 'Y';
lv_msg_id        RAW(16);
lv_user_data     SYSTEM.XDP_WF_CHANNELQ_TYPE;
lv_lock_status   VARCHAR2(1);
lv_error         VARCHAR2(1000);
l_fa_item_key    VARCHAR2(300);
l_fa_item_type   VARCHAR2(80);
l_fa_instance_id NUMBER ;

e_xdp_order_state_cancel   EXCEPTION ;
e_xdp_order_state_process  EXCEPTION ;
e_xdp_fa_state_inprogress  EXCEPTION ;

CURSOR c_fa(l_order_id NUMBER) IS
       SELECT fa_instance_id,
              frt.msgid,
              frt.status_code ,
              frt.wf_item_type,
              frt.wf_item_key
         FROM xdp_fa_runtime_list frt,
              xdp_fulfill_worklist fwt
        WHERE fwt.order_id             = l_order_id and
	      fwt.workitem_instance_id = frt.workitem_instance_id;

CURSOR c_wi(l_order_id number) IS
       SELECT workitem_instance_id,
              wf_item_type,
              wf_item_key,
              status_code,
              msgid
         FROM xdp_fulfill_worklist
        WHERE order_id = l_order_id;

CURSOR c_line(l_order_id number) IS
       SELECT line_item_id,
              wf_item_key,
              wf_item_type,
              status_code
         FROM xdp_order_line_items
        WHERE order_id = l_order_id
        ORDER By is_package_flag;

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
	  dbg_msg := ('Procedure XDP_INTERFACES.CANCEL_INPROGRESS_ORDER begins.');
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
	  END IF;
       END IF;
     END IF;

     return_code := 0;

     savepoint lv_order_tag;

     SELECT order_id ,
            wf_item_type,
            wf_item_key,
            status_code,
            msgid
     INTO lv_id,
            lv_item_type,
            lv_item_key,
            lv_state,
            lv_msg_id
     FROM xdp_order_headers
     WHERE order_id = p_sdp_order_id
     FOR UPDATE of XDP_ORDER_HEADERS.STATUS_CODE NOWAIT;

     -- Order has already been canceled
     IF lv_state IN  ('CANCELED','ABORTED') THEN

        IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
           IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
              dbg_msg := ('Order Status is : '||lv_state ||' Can not cancel Order ');
	      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
	      END IF;
           END IF;
        END IF;
        raise e_xdp_order_state_cancel ;

     -- Order has already been completed

     ELSIF lv_state IN ('SUCCESS','SUCCESS_WITH_OVERRIDE') THEN

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                dbg_msg := ('Order Status is : '||lv_state ||' Can not cancel Order ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
		END IF;
              END IF;
           END IF;
           raise e_xdp_order_state_process ;

   -- Order has already been started
     ELSIF lv_state = 'IN PROGRESS' THEN
    	   lv_abort_wf := TRUE;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
              IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                dbg_msg := ('Order Status is : '||lv_state );
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
		END IF;
	      END IF;
           END IF;

	   rollback to lv_order_tag;

   -- release the lock for now as we are using bottom up approach
     ELSE
         rollback to lv_order_tag;
     END IF;

   --  At this point the order process has been started
   --  We will take the bottom up approach to make all
   --  activities within this order to be CANCELED

    IF ARE_ALL_FAS_READY_FOR_CANCEL(p_sdp_order_id ) THEN

        IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
          IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
            dbg_msg := ('FAs Are ready for Cancel Starting with FA ');
	    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
	    END IF;
          END IF;
        END IF;

	FOR c_fa_rec in c_fa(p_sdp_order_id)
        LOOP

                SELECT fr.status_code
                  INTO lv_state
                  FROM xdp_fa_runtime_list fr
                  WHERE fa_instance_id = c_fa_rec.fa_instance_id
                  FOR UPDATE OF fr.status_code NOWAIT;

   		IF lv_state IN ('CANCELED','ABORTED') THEN

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                        dbg_msg := ('Status Of FA : '||c_fa_rec.fa_instance_id||' is '||lv_state);
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
			END IF;
                      END IF;
                   END IF;
		   NULL;

                ELSIF lv_state IN ('SUCCESS','SUCCESS_WITH_OVERRIDE') THEN

                      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                            dbg_msg := ('Status Of FA : '||c_fa_rec.fa_instance_id||' is '||lv_state);
			    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                           	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
			    END IF;
                         END IF;
                      END IF;
                      NULL;
                ELSIF lv_state = 'IN PROGRESS' THEN
                      l_fa_instance_id := c_fa_rec.fa_instance_id ;

                      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                            dbg_msg := ('FA : '||c_fa_rec.fa_instance_id||' is INPROGRESS Can not cancel Order');
			    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                           	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
			    END IF;
                         END IF;
                      END IF;
                      raise e_xdp_fa_state_inprogress;
                      -- raise can not cancel order fa in progress try again
   		ELSE
                     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                            dbg_msg := ('Calling CANCEL_FA for FA : '||c_fa_rec.fa_instance_id);
			    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                            	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
			    END IF;
                         END IF;
                     END IF;

		     CANCEL_FA(p_order_id         => p_sdp_order_id,
                                  p_fa_instance_id   => c_fa_rec.fa_instance_id,
	                          p_msg_id           => c_fa_rec.msgid,
	                          p_caller_name      => p_caller_name,
                                  p_fa_wf_item_type  => c_fa_rec.wf_item_type,
                                  p_fa_wf_item_key   => c_fa_rec.wf_item_key,
	                          p_status           => lv_state,
	                          return_code        => return_code,
	                          error_description  => error_description);

		     if return_code <> 0 then
                        rollback to lv_order_tag;
			return;
		     end if;
   		END IF;
   	END LOOP;

   	FOR c_wi_rec in c_wi(p_sdp_order_id)
        LOOP
                SELECT fw.status_code
                  INTO lv_state
                  FROM xdp_fulfill_worklist fw
                  WHERE workitem_instance_id = c_wi_rec.workitem_instance_id
                  FOR UPDATE OF fw.status_code NOWAIT;

   		IF lv_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') THEN

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                        dbg_msg := ('Status Of WI : '||c_wi_rec.workitem_instance_id||' is '||lv_state);
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                       	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
			END IF;
                      END IF;
                   END IF;
  		   null;
   		ELSE

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                         IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                            dbg_msg := ('Calling CANCEL_WORKITEM for WI : ' ||c_wi_rec.workitem_instance_id);
			    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
			    END IF;
                         END IF;
                   END IF;

                   CANCEL_WORKITEM
	                   (p_wi_instance_id  => c_wi_rec.workitem_instance_id,
	                    p_msg_id          => c_wi_rec.msgid,
                            p_wi_wf_item_type => c_wi_rec.wf_item_type,
                            p_wi_wf_item_key  => c_wi_rec.wf_item_key,
	                    p_caller_name     => p_caller_name,
	                    p_status          => c_wi_rec.status_code,
	                    return_code       => return_code,
	                    error_description => error_description);

	 	   IF return_code <> 0 THEN
                           rollback to lv_order_tag;
	   		   return;
	 	   END IF;
    	        END IF;

  	END LOOP;

   	FOR c_line_rec in c_line(p_sdp_order_id)
        LOOP

   	       SELECT status_code
                  INTO lv_state
     	          FROM xdp_order_line_items
     	          WHERE line_item_id = c_line_rec.line_item_id
     	          FOR UPDATE OF STATUS_CODE NOWAIT;

	       IF lv_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') THEN
                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                         dbg_msg := ('Status Of Line : '||c_line_rec.line_item_id||' is '||lv_state);
			 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
			 END IF;
                      END IF;
                   END IF;
                   NULL ;
     	       ELSE
                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                      IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
		          dbg_msg := ('Calling UPDATE_XDP_ORDER_LINE_STATUS for Line : '||c_line_rec.line_item_id);
			 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
			 END IF;
                      END IF;
                   END IF;

                   UPDATE_XDP_ORDER_LINE_STATUS
                              (p_order_id        => null,
                               p_lineitem_id     => c_line_rec.line_item_id,
                               p_status          => 'CANCELED',
                               p_caller_name     => p_caller_name,
                               return_code       => return_code ,
                               error_description => error_description );

                   IF return_code <> 0 THEN
                      return;
                   END IF;
     	       END IF;
   	END LOOP;

        SELECT oh.status_code            --- ?? Do I need to lock it again ?
            INTO lv_state
            FROM xdp_order_headers oh
            WHERE oh.order_id = p_sdp_order_id
            FOR UPDATE OF oh.status_code  NOWAIT;

   	IF lv_state IN ('CANCELED','ABORTED') then
           raise e_xdp_order_state_cancel ;
   	ELSIF lv_state IN ('SUCCESS','SUCCESS_WITH_OVERRIDE') then
           raise e_xdp_order_state_process ;
   	ELSE
           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
               IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                  dbg_msg := ('Calling UPDATE_XDP_ORDER_STATUS' );
	          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
		  END IF;
               END IF;
           END IF;


           UPDATE_XDP_ORDER_STATUS
                     (p_order_id         => p_sdp_order_id,
                      p_status           => 'CANCELED',
                      p_caller_name      => p_caller_name,
                      return_code        => return_code,
                      error_description  => error_description );

           IF return_code <> 0 THEN
              return;
           END IF;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
               IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER')) THEN
                  dbg_msg := ('Completed UPDATE_XDP_ORDER_STATUS Calling ABORT_ORDER_WORKFLOWS' );
	          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_INPROGRESS_ORDER', dbg_msg);
		  END IF;
               END IF;
           END IF;


	   ABORT_ORDER_WORKFLOWS
                          ( p_sdp_order_id,
	   		    return_code,
	   		    error_description);

           IF return_code <> 0 THEN
              return;
           END IF;
        END IF;
    ELSE
         raise e_xdp_order_state_process;
         -- raise can not cancel order
    END IF;

EXCEPTION
     WHEN resource_busy OR no_data_found THEN
          return_code := -191318;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_CANNOT_REMOVE_ORDER');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', lv_error);
          error_description := FND_MESSAGE.GET;
          return;
     WHEN e_xdp_order_state_process THEN
	   return_code := -191316;
	   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_PROCESS');
	   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	   error_description := FND_MESSAGE.GET;
           rollback to lv_order_tag;
          return;
     WHEN e_xdp_order_state_cancel THEN
   	  return_code := -191315;
	  FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_CANCEL');
	  FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	  error_description := FND_MESSAGE.GET;
          rollback to lv_order_tag;
          return;
     WHEN e_xdp_fa_state_inprogress THEN
          return_code := 197010;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_FA_STATE_INPROGRESS');
          FND_MESSAGE.SET_TOKEN('FA_INSTANCE_ID', l_fa_instance_id);
          error_description := FND_MESSAGE.GET;
          rollback to lv_order_tag;
          return;
     WHEN OTHERS THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END CANCEL_INPROGRESS_ORDER;

--
-- Private API which will remove a canceled order from the processor queue
--
PROCEDURE REMOVE_ORDER_FROM_PROCESSORQ
	          (p_sdp_order_id     IN NUMBER,
	           p_caller_name      IN VARCHAR2,
	           return_code       OUT NOCOPY NUMBER,
	           error_description OUT NOCOPY VARCHAR2) IS

lv_id          NUMBER;
lv_item_type   VARCHAR2(80);
lv_item_key    VARCHAR2(300);
lv_abort_wf    BOOLEAN := FALSE;
lv_state       VARCHAR2(80);
lv_in_queue    VARCHAR2(1) := 'Y';
lv_msg_id      RAW(16);
lv_user_data   SYSTEM.XDP_WF_CHANNELQ_TYPE;
lv_lock_status VARCHAR2(1);
lv_error       VARCHAR2(1000);

CURSOR lc_fa(l_order_id NUMBER) IS
       SELECT fa_instance_id,
              frt.msgid
         FROM xdp_fa_runtime_list frt,
              xdp_fulfill_worklist fwt
        WHERE fwt.order_id             = l_order_id and
              fwt.workitem_instance_id = frt.workitem_instance_id;

CURSOR lc_wi(l_order_id number) IS
       SELECT workitem_instance_id,
              msgid
         FROM xdp_fulfill_worklist
        WHERE order_id = l_order_id;

CURSOR lc_line(l_order_id number) IS
       SELECT line_item_id
         FROM xdp_order_line_items
        WHERE order_id = l_order_id
        ORDER By is_package_flag;

BEGIN
  return_code := 0;

  savepoint lv_order_tag;

  SELECT order_id ,
         wf_item_type,
         wf_item_key,
         status_code,
         msgid
    INTO lv_id,
         lv_item_type,
         lv_item_key,
         lv_state,
         lv_msg_id
    FROM xdp_order_headers
   WHERE order_id = p_sdp_order_id
     FOR UPDATE of XDP_ORDER_HEADERS.STATUS_CODE  NOWAIT;

   -- Order has already been canceled
  IF lv_state IN  ('CANCELED','ABORTED') THEN
	return_code := -191315;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_CANCEL');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	error_description := FND_MESSAGE.GET;
        rollback to lv_order_tag;
	return;

   -- Order has already been completed

  ELSIF lv_state IN ('SUCCESS','SUCCESS_WITH_OVERRIDE') THEN
	return_code := -191316;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_PROCESS');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	error_description := FND_MESSAGE.GET;
        rollback to lv_order_tag;
	return;

-- Order has already been started
  ELSIF lv_state = 'IN PROGRESS' THEN
    lv_in_queue := 'N';
 	lv_abort_wf := TRUE;
	rollback to lv_order_tag;

-- release the lock for now as we are using bottom up approach
  ELSE
      rollback to lv_order_tag;
  END IF;

 IF lv_in_queue = 'Y' THEN
	Lock_and_Remove_Msg(
		p_msg_id => lv_msg_id,
		p_queue_name => 'XDP_ORDER_PROC_QUEUE',
		x_user_data =>lv_user_data,
		x_lock_status => lv_lock_status,
		x_error => lv_error);

	IF lv_lock_status = G_LOCK_MSG_SUCCESS THEN

	-- No Order Workflow has been started
	--	Simply update the state to CANCELED

   		update xdp_order_headers
   		   set last_updated_by = FND_GLOBAL.USER_ID,
                       last_update_date = sysdate,
       		       last_update_login = FND_GLOBAL.LOGIN_ID,
 		       status_code = 'CANCELED',
 		       canceled_by = p_caller_name,
 		       cancel_provisioning_date = sysdate
   		 where order_id = p_sdp_order_id;

   		update xdp_order_line_items
   		   set last_updated_by = FND_GLOBAL.USER_ID,
       		       last_update_date = sysdate,
       		       last_update_login = FND_GLOBAL.LOGIN_ID,
 		       status_code = 'CANCELED',
 		       canceled_by = p_caller_name,
 		       cancel_provisioning_date = sysdate
  		 where order_id = p_sdp_order_id;

   		update XDP_FULFILL_WORKLIST
   		   set last_updated_by = FND_GLOBAL.USER_ID,
                       last_update_date = sysdate,
       		       last_update_login = FND_GLOBAL.LOGIN_ID,
 		       status_code = 'CANCELED',
 		       canceled_by = p_caller_name,
 		       cancel_provisioning_date = sysdate
   		 where order_id = p_sdp_order_id;
   		commit;
		return;
	ELSIF lv_lock_status = G_LOCK_MSG_FAIL THEN
    	      lv_abort_wf := TRUE;
	ELSE
		return_code := -191318;
		/*
		error_description := 'Error: Can not remove order from queue. '||
							lv_error;
		*/
		FND_MESSAGE.SET_NAME('XDP', 'XDP_CANNOT_REMOVE_ORDER');
		FND_MESSAGE.SET_TOKEN('ERROR_STRING', lv_error);
		error_description := FND_MESSAGE.GET;
		return;
	END IF;
  END IF;

--  At this point the order process has been started
--  We will take the bottom up approach to make all
--  activities within this order to be CANCELED

	FOR lv_fa_rec in lc_fa(p_sdp_order_id)
            loop
   		select status_code into lv_state
   		from xdp_fa_runtime_list
   		where fa_instance_id = lv_fa_rec.fa_instance_id;

   		if lv_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') then
			null;
   		else
			remove_fa_from_q(
					lv_fa_rec.fa_instance_id,
					lv_fa_rec.msgid,
					p_caller_name,
					lv_state,
					return_code,
					error_description);
			if return_code <> 0 then
					return;
			end if;
   		end if;
   	END LOOP;

   	FOR lv_wi_rec in lc_wi(p_sdp_order_id)
            loop
   		select status_code into lv_state
   		from XDP_FULFILL_WORKLIST
   		where workitem_instance_id = lv_wi_rec.workitem_instance_id;

   		if lv_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') then
			null;
   		else
	 		remove_wi_from_q(
	   			lv_wi_rec.workitem_instance_id,
	   			lv_wi_rec.msgid,
				p_caller_name,
				lv_state,
	   			return_code,
	   			error_description);
	 		if return_code <> 0 then
	   			return;
	 		end if;
    	end if;

  	END LOOP;

   	FOR lv_line_rec in lc_line(p_sdp_order_id) loop
   	 	savepoint lv_line_tag;

   		select status_code
                  into lv_state
     	          from xdp_order_line_items
     	         where line_item_id = lv_line_rec.line_item_id
     	           for update of status_code;

	if lv_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') then
	 	 	rollback to lv_line_tag;
     	else
	 		update xdp_order_line_items
	 		set
       		last_updated_by = FND_GLOBAL.USER_ID,
       		last_update_date = sysdate,
       		last_update_login = FND_GLOBAL.LOGIN_ID,
	 		status_code = 'CANCELED',
	 		canceled_by = p_caller_name,
	 		cancel_provisioning_date = sysdate
	 		where line_item_id = lv_line_rec.line_item_id;
	 		commit;
     	end if;
   	END LOOP;

   	savepoint lv_order_tag2;

    select status_code
      into lv_state
      from xdp_order_headers
     where order_id = p_sdp_order_id
       FOR UPDATE of XDP_ORDER_HEADERS.STATUS_CODE ;

   	if lv_state IN ('CANCELED','ABORTED') then
     	   return_code := -191315;
	   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_CANCEL');
	   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	   error_description := FND_MESSAGE.GET;
     	   return;
   	elsif lv_state IN ('SUCCESS','SUCCESS_WITH_OVERRIDE') then
     	   rollback to lv_order_tag2;
     	   return_code := -191316;
	   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_STATE_PROCESS');
	   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	   error_description := FND_MESSAGE.GET;
     	   return;
   	else
	 	update xdp_order_headers
	 	   set last_updated_by = FND_GLOBAL.USER_ID,
       	               last_update_date = sysdate,
       	               last_update_login = FND_GLOBAL.LOGIN_ID,
	 	       status_code = 'CANCELED',
	 	       canceled_by = p_caller_name,
	 	       cancel_provisioning_date = sysdate
	 	       where order_id = p_sdp_order_id;

	 	commit;

	 	Abort_Order_Workflows(
	   		p_sdp_order_id,
	   		return_code,
	   		error_description);
   	end if;

EXCEPTION
WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
END Remove_Order_From_ProcessorQ;


--
-- Private API which will remove a workitem from queue
--
PROCEDURE Remove_WI_From_Q(
	p_wi_instance_id in number,
	p_msg_id in raw,
	p_caller_name in varchar2,
	p_state in varchar2,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
IS
  lv_id number;
  lv_lock varchar2(1) := 'Y';
  lv_state varchar2(100);
  lv_user_data SYSTEM.XDP_WF_CHANNELQ_TYPE;
  lv_lock_status varchar2(1);
  lv_error varchar2(1000);

BEGIN
   	return_code := 0;
	if p_state = 'IN PROGRESS' THEN

		Lock_and_Remove_Msg(
			p_msg_id      => p_msg_id,
			p_queue_name  => 'XDP_WORKITEM_QUEUE',
			x_user_data   =>lv_user_data,
			x_lock_status => lv_lock_status,
			x_error       => lv_error);

		IF lv_lock_status = G_LOCK_MSG_SUCCESS THEN
		-- Great, we had lock and remove the WI from queue
  			lv_lock := 'N';

			update XDP_FULFILL_WORKLIST
			   set last_updated_by = FND_GLOBAL.USER_ID,
   			       last_update_date = sysdate,
   			       last_update_login = FND_GLOBAL.LOGIN_ID,
			       status_code = 'CANCELED',
			       canceled_by = p_caller_name,
			       cancel_provisioning_date = sysdate
			 where workitem_instance_id = p_wi_instance_id;

		        commit;
			return;
		ELSE
		-- Now we need to the lock the worklist table
		-- to get the most current state of the WI
  			lv_lock := 'Y';
		END IF;
	end if;

	if lv_lock = 'Y' THEN
		savepoint lv_wi_tag;

		SELECT status_code
		  INTO lv_state
		  FROM xdp_fulfill_worklist
		 WHERE workitem_instance_id = p_wi_instance_id
		   FOR UPDATE of status_code;

		if lv_state in ('SUCCESS','SUCCESS_WITH_OVERRIDE','ABORTED','CANCELED') THEN
			rollback to lv_wi_tag;
			return;
		else
			update XDP_FULFILL_WORKLIST
			   set last_updated_by = FND_GLOBAL.USER_ID,
   			       last_update_date = sysdate,
   			       last_update_login = FND_GLOBAL.LOGIN_ID,
			       status_code = 'CANCELED',
			       canceled_by = p_caller_name,
			       cancel_provisioning_date = sysdate
			 where workitem_instance_id = p_wi_instance_id;
			 commit;
		end if;
	end if;

EXCEPTION
WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
END Remove_WI_From_Q;


--
-- Private API which will remove an FA from queue
--
PROCEDURE Remove_FA_From_Q(
	p_fa_instance_id in number,
	p_msg_id in raw,
	p_caller_name in varchar2,
	p_state in  varchar2,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
IS
  lv_id number;
  lv_in_fa_q varchar2(1) := 'Y';
  lv_item_type varchar2(80);
  lv_item_key varchar2(300);
  lv_state varchar2(100);
  lv_lock varchar2(1) := 'Y';
  lv_user_data SYSTEM.XDP_WF_CHANNELQ_TYPE;
  lv_lock_status varchar2(1);
  lv_error varchar2(1000);
BEGIN

   	return_code := 0;
	if p_state = 'IN PROGRESS' THEN
		Lock_and_Remove_Msg(
			p_msg_id      => p_msg_id,
			p_queue_name  => 'XDP_FA_QUEUE',
			x_user_data   =>lv_user_data,
			x_lock_status => lv_lock_status,
			x_error       => lv_error);

		IF lv_lock_status = G_LOCK_MSG_SUCCESS THEN
		-- Great, we had lock and remove the FA from queue
  			lv_lock := 'N';

			update xdp_fa_runtime_list
			   set last_updated_by   = FND_GLOBAL.USER_ID,
   			       last_update_date  = sysdate,
   			       last_update_login = FND_GLOBAL.LOGIN_ID,
			       status_code            = 'CANCELED',
			       canceled_by       = p_caller_name,
			       cancel_provisioning_date = sysdate
			 where fa_instance_id           = p_fa_instance_id;
			 commit;
			return;
		ELSE
       		        lv_in_fa_q := 'N';
			lv_lock := 'Y';
		END IF;
	END IF;

	if lv_lock = 'Y' THEN
		savepoint lv_fa_tag;

		select status_code,
                       wf_item_type,
                       wf_item_key
		  into lv_state,
                       lv_item_type,
                       lv_item_key
		  from xdp_fa_runtime_list
		 where fa_instance_id = p_fa_instance_id
		   for update of status_code;

		if lv_state in ('SUCCESS','SUCCESS_WITH_OVERRIDE','ABORTED','CANCELED') THEN
			rollback to lv_fa_tag;
			return;
		else
			update xdp_fa_runtime_list
			   set last_updated_by   = FND_GLOBAL.USER_ID,
   			       last_update_date  = sysdate,
   			       last_update_login = FND_GLOBAL.LOGIN_ID,
			       status_code            = 'CANCELED',
			       canceled_by       = p_caller_name,
			       cancel_provisioning_date = sysdate
			 where fa_instance_id = p_fa_instance_id;
			 commit;
		end if;
	end if;

-- At this point the FA process should see the cancel state
-- and abort accordingly
-- As part of the clean up, we also try to see
-- if the fa is in the adapter job queue or not
   IF lv_in_fa_q = 'N' THEN
	 savepoint lv_job_tag;
     begin
    	select job_id into lv_id
    	from xdp_adapter_job_queue
    	where
	   	wf_item_type = lv_item_type and
	   	wf_item_key = lv_item_key
    	for update nowait ;
    	delete from xdp_adapter_job_queue
    	where job_id = lv_id ;
    	commit;
     exception
   	when resource_busy or no_data_found then
	--  this means the fa process is now running.
	--  Since we already updated the state, we will
	--  do nothing and let the process to handle
	--  itself.
		rollback to lv_job_tag;
    	null;
     end;
   END IF;


EXCEPTION
WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
END Remove_FA_From_Q;

--
-- Private API which will abort all workflow processes
-- for the given order
--
PROCEDURE Abort_Order_Workflows(
	p_sdp_order_id in number,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
IS
  CURSOR lc_wf_process(l_type varchar2,l_key varchar2) IS
         select level,
	        item_type,
	        item_key,
	        DECODE(begin_date,NULL,'N','Y') is_active_flag,
	        DECODE(end_date,NULL,'N','Y') is_completed_flag
          from wf_items_v
               start with
	             item_type = l_type and item_key = l_key
                     connect by parent_item_type = prior item_type and
                                parent_item_key = prior item_key
         order by level desc;

  lv_type varchar2(80);
  lv_key varchar2(300);

BEGIN
  return_code := 0;

  select wf_item_type,wf_item_key
    into lv_type, lv_key
    from xdp_order_headers
   where order_id = p_sdp_order_id;


  FOR lv_wf_rec IN lc_wf_process(lv_type,lv_key) LOOP
    IF lv_wf_rec.is_active_flag = 'Y' AND
	 lv_wf_rec.is_completed_flag = 'N' THEN
      begin
        wf_engine.abortProcess(
		itemtype => lv_wf_rec.item_type,
		itemkey =>  lv_wf_rec.item_key);
	  commit;
      exception
       when others then
         null;
      end;
    END IF;
  END LOOP;

exception
when others then
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;

END Abort_Order_Workflows;


PROCEDURE Lock_and_Remove_Msg(
	p_msg_id in raw,
	p_queue_name in varchar2,
	p_remove_flag in varchar2 DEFAULT 'Y',
	x_user_data OUT NOCOPY SYSTEM.XDP_WF_CHANNELQ_TYPE,
	x_lock_status OUT NOCOPY varchar2,
	x_error OUT NOCOPY varchar2)
IS
 	lv_DequeueOptions DBMS_AQ.DEQUEUE_OPTIONS_T;
 	lv_MessageProperties DBMS_AQ.MESSAGE_PROPERTIES_T;
 	lv_MsgID RAW(16);
	lv_user_data SYSTEM.XDP_WF_CHANNELQ_TYPE;

BEGIN
     if( p_msg_id is NULL ) then
       return;
     end if;
     savepoint lv_q_tag;
     lv_DequeueOptions.visibility := DBMS_AQ.ON_COMMIT;
     lv_DequeueOptions.navigation := DBMS_AQ.FIRST_MESSAGE;
     lv_DequeueOptions.msgid := p_msg_id;
     lv_DequeueOptions.dequeue_mode := DBMS_AQ.LOCKED;

     -- Set Dequeue time out to be 1 second
     lv_DequeueOptions.wait := 1;
	 x_lock_status := G_LOCK_MSG_SUCCESS;
/**
     BEGIN
        DBMS_AQ.DEQUEUE(
         queue_name => G_XDP_SCHEMA||'.'||p_queue_name,
         dequeue_options => lv_DequeueOptions,
         message_properties => lv_MessageProperties,
         payload => x_user_data,
         msgid => lv_MsgID);
      EXCEPTION
       WHEN e_QTimeOut or no_data_found Then
	 	x_lock_status := G_LOCK_MSG_FAIL;
		return;
       WHEN OTHERS THEN
        rollback to lv_q_tag;
	 	x_lock_status := G_LOCK_MSG_ERROR;
		x_error := SQLERRM;
		return;
     END;
**/
	if NVL(p_remove_flag,'Y') = 'Y' THEN
     	lv_DequeueOptions.dequeue_mode := DBMS_AQ.REMOVE_NODATA;
        DBMS_AQ.DEQUEUE(
         queue_name => G_XDP_SCHEMA||'.'||p_queue_name,
         dequeue_options => lv_DequeueOptions,
         message_properties => lv_MessageProperties,
         payload => lv_user_data,
         msgid => lv_MsgID);
	end if;

EXCEPTION
  WHEN OTHERS THEN
    rollback to lv_q_tag;
	x_lock_status := G_LOCK_MSG_ERROR;
	x_error := SQLERRM;
END Lock_and_Remove_Msg;

--
-- API for upstream ordering system to retrieve the order status
-- information
--
PROCEDURE Get_Order_Status(
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_order_header		OUT NOCOPY XDP_TYPES.ORDER_HEADER,
	P_Order_lines		OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST,
 	RETURN_CODE 		OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2)
IS

BEGIN
   return_code := 0;
   p_order_header := XDP_OA_UTIL.Get_Order_Header(p_sdp_order_id);
   p_order_lines := XDP_OA_UTIL.Get_Order_Lines(p_sdp_order_id);
   null;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   return_code := SQLCODE;
   /*
   error_description := 'Error:  Order ID '||p_sdp_order_id||' does not exist in SFM.';
   */
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
   error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;

END Get_Order_Status;

 /*
  * Overload Function
  * A light-weight API for upstream ordering system to retrieve
  * only the key order status
  * information
  */
 PROCEDURE Get_Order_Status(
 	P_SDP_ORDER_ID 		IN NUMBER,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2)
IS

BEGIN
   x_return_code := 0;
   select
	 status_code,
         null,
	 completion_date,
	 cancel_provisioning_date
   into
	 x_status,
         x_state ,
	 x_completion_date,
	 x_cancellation_date
   from
	 XDP_ORDER_HEADERS
   WHERE
	 order_id = p_sdp_order_id;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   x_return_code := SQLCODE;
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
   x_error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
     x_return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     x_error_description := FND_MESSAGE.GET;
END Get_Order_Status;

 /*
  * Overload Function
  * A light-weight API for upstream ordering system to retrieve
  * only the key order status
  * information
  */
 PROCEDURE Get_Order_Status(
 	P_ORDER_NUMBER 		IN  VARCHAR2,
 	P_ORDER_VERSION		IN  VARCHAR2,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2)
IS

BEGIN
   x_return_code := 0;
   select
	 status_code,
         null,
	 completion_date,
	 cancel_provisioning_date
   into
	 x_status,
         x_state,
	 x_completion_date,
	 x_cancellation_date
   from
	 XDP_ORDER_HEADERS
   WHERE
	 external_order_number = (p_order_number) and
	 NVL(external_order_version,'-1') = NVL((p_order_version),'-1') ;


EXCEPTION
WHEN NO_DATA_FOUND THEN
   x_return_code := -191314;
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_VERSION_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', p_order_number);
   FND_MESSAGE.SET_TOKEN('ORDER_VERSION', p_order_version);
   x_error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
     x_return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     x_error_description := FND_MESSAGE.GET;
END Get_Order_Status;

 /*
  * A light-weight API for upstream ordering system to retrieve
  * only the key line status
  * information
  */
 PROCEDURE Get_Line_Status(
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_line_number       IN NUMBER,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2)
IS

BEGIN
   x_return_code := 0;
   select
	 status_code,
         null,
	 completion_date,
	 cancel_provisioning_date
   into
	 x_status,
         x_state ,
	 x_completion_date,
	 x_cancellation_date
   from XDP_ORDER_LINE_ITEMS
   WHERE order_id = p_sdp_order_id and
	 line_number = p_line_number ;


EXCEPTION
WHEN NO_DATA_FOUND THEN
   x_return_code := -191323;
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_LINE_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_line_number);
   FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', p_sdp_order_id);
   x_error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
     x_return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     x_error_description := FND_MESSAGE.GET;
END Get_Line_Status;

 /*
  * Overload Function
  * A light-weight API for upstream ordering system to retrieve
  * only the key line status
  * information
  */
 PROCEDURE Get_Line_Status(
 	P_ORDER_NUMBER 		IN  VARCHAR2,
 	P_ORDER_VERSION		IN  VARCHAR2,
	p_line_number       IN NUMBER,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2)
IS

BEGIN
   x_return_code := 0;
   select
	 olm.status_code,
         null,
	 olm.completion_date,
	 olm.cancel_provisioning_date
   into
	 x_status,
         x_state ,
	 x_completion_date,
	 x_cancellation_date
   from
	 XDP_ORDER_LINE_ITEMS olm,
	 XDP_ORDER_HEADERS ohr
   WHERE
	 olm.order_id = ohr.order_id and
	 ohr.external_order_number = (p_order_number) and
	 NVL(ohr.external_order_version,'-1') = NVL((p_order_version) ,'-1') and
	 olm.line_number = p_line_number ;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   x_return_code := -191323;
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_LINE_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_line_number);
   FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', p_order_number);
   x_error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
     x_return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     x_error_description := FND_MESSAGE.GET;
END Get_Line_Status;

 /*
  * Overload Function
  * A light-weight API for upstream ordering system to retrieve
  * only the key line status information
  * This API will return error if more than one order line
  * have the same line item name
  */
 PROCEDURE Get_Line_Status(
 	P_ORDER_NUMBER 		IN  VARCHAR2,
 	P_ORDER_VERSION		IN  VARCHAR2,
	p_line_item_name    IN  VARCHAR2,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2)
IS

	lv_found varchar2(1) := 'N';
	CURSOR lc_line is
	select
		olm.status_code,
		olm.completion_date,
		olm.cancel_provisioning_date
	from
	 XDP_ORDER_LINE_ITEMS olm,
	 XDP_ORDER_HEADERS ohr
   WHERE
	 olm.order_id = ohr.order_id and
	 ohr.external_order_number = (p_order_number) and
	 NVL(ohr.external_order_version,'-1') = NVL((p_order_version) ,'-1') and
	 olm.line_item_name = p_line_item_name ;

BEGIN
   x_return_code := 0;
   FOR lv_line_rec in lc_line loop
	 IF lv_found = 'N' THEN
		lv_found := 'Y';
		x_status := lv_line_rec.status_code;
                x_state  := null ;
		x_completion_date := lv_line_rec.completion_date;
		x_cancellation_date := lv_line_rec.cancel_provisioning_date;
	 ELSE
		x_status := NULL;
                x_state  := null ;
		x_completion_date := NULL;
		x_cancellation_date := NULL;
   		x_return_code := -191325;
   		FND_MESSAGE.SET_NAME('XDP', 'XDP_LINE_NAME_MULTIMATCH');
   		FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', p_order_number);
   		FND_MESSAGE.SET_TOKEN('LINE_NAME', p_line_item_name);
   		x_error_description := FND_MESSAGE.GET;
		return;
	 END IF;
   END LOOP;

   IF lv_found = 'N' THEN
   	x_return_code := -191325;
   	FND_MESSAGE.SET_NAME('XDP', 'XDP_LINE_NAME_NOTEXISTS');
   	FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', p_order_number);
   	FND_MESSAGE.SET_TOKEN('LINE_NAME', p_line_item_name);
   	x_error_description := FND_MESSAGE.GET;
	return;
   END IF;

EXCEPTION
WHEN OTHERS THEN
     x_return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     x_error_description := FND_MESSAGE.GET;
END Get_Line_Status;

--
-- API for upstream ordering system to put a service activation
-- order on hold
--
PROCEDURE Hold_Order(
 	P_SDP_ORDER_ID 		IN NUMBER,
	RETURN_CODE 		OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2)
IS
  lv_state varchar2(40);
  lv_tmp number;
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);
  lv_locked_q varchar2(80);
BEGIN
   return_code := 0;


EXCEPTION
WHEN NO_DATA_FOUND THEN
   return_code := SQLCODE;
   /*
   error_description := 'Error:  Order ID '||p_sdp_order_id||' does not exist in SFM.';
   */
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
   error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
END Hold_Order;

--
-- API for upstream ordering system to resume a service activation order
-- which has been put on hold previously
--
PROCEDURE Resume_Order(
 	P_SDP_ORDER_ID 		IN NUMBER,
 	RETURN_CODE 		OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2)
IS
  lv_state varchar2(40);
  lv_tmp  number;
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);
  lv_locked_q varchar2(80);

BEGIN
   return_code := 0;


EXCEPTION
WHEN NO_DATA_FOUND THEN
   return_code := SQLCODE;
   /*
   error_description := 'Error:  Order ID '||p_sdp_order_id||' does not exist in SFM.';
   */
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
   error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
END Resume_Order;

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

/*
 The following APIs are developed as part of integration with Oracle Sales for Comms.
 12/06/2000
 By Anping Wang
*/

PROCEDURE Get_Order_Param_Value(
 	p_order_id	 		IN  NUMBER,
	p_parameter_name		IN VARCHAR2,
	x_parameter_value		OUT NOCOPY VARCHAR2,
 	x_RETURN_CODE 			OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION		OUT NOCOPY VARCHAR2
)
IS
BEGIN
	x_parameter_value := XDP_ENGINE.Get_Order_Param_Value(p_order_id,p_parameter_name);
	x_RETURN_CODE := 0;
	x_ERROR_DESCRIPTION := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
	WHEN OTHERS THEN
     	x_return_code := -191266;
     	FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     	FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Get_Order_Param_Value');
     	FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     	x_error_description := FND_MESSAGE.GET;
END Get_Order_Param_Value;



FUNCTION Get_Order_Param_List(
 	p_order_id		 		IN  NUMBER,
 	x_RETURN_CODE 			OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION		OUT NOCOPY VARCHAR2
) RETURN XDP_ENGINE.PARAMETER_LIST
IS
BEGIN
   	x_return_code := 0;
	x_error_description := FND_API.G_RET_STS_SUCCESS;
	RETURN XDP_ENGINE.Get_Order_Param_List(p_order_id);
EXCEPTION
	WHEN OTHERS THEN
     	x_return_code := -191266;
     	FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     	FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Get_Order_Param_List');
     	FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     	x_error_description := FND_MESSAGE.GET;
END Get_Order_Param_List;

PROCEDURE Get_Line_Param_Value(
 	p_order_id		 		IN  NUMBER,
	p_line_number			IN  VARCHAR2,
	p_parameter_name		IN VARCHAR2,
	x_parameter_value		OUT NOCOPY VARCHAR2,
 	x_RETURN_CODE 			OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION		OUT NOCOPY VARCHAR2
) IS
l_line_item_id Number;
BEGIN

	SELECT line_item_id
          INTO l_line_item_id
          FROM xdp_order_line_items
         WHERE order_id = p_order_id
  	   AND NVL(LINE_NUMBER,0) = NVL(p_line_number,0);

	x_parameter_value := XDP_ENGINE.Get_Line_Param_Value(l_line_item_id,p_parameter_name);
	x_ERROR_DESCRIPTION := FND_API.G_RET_STS_SUCCESS;
	x_return_code := 0;
EXCEPTION
	WHEN OTHERS THEN
     	x_return_code := -191266;
     	FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     	FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Get_Line_Param_Value');
     	FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     	x_error_description := FND_MESSAGE.GET;
END Get_Line_Param_Value;

PROCEDURE Get_Ord_Fulfillment_Status(
 	p_order_id		 		IN  VARCHAR2,
 	x_fulfillment_status	OUT NOCOPY VARCHAR2,
 	x_fulfillment_result	OUT NOCOPY VARCHAR2,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2
 ) IS
BEGIN
		BEGIN
			x_fulfillment_status := UPPER(XDP_ENGINE.Get_Order_Param_Value(p_order_id,'FULFILLMENT_STATUS'));
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_fulfillment_status := UPPER('Success');
		END;
		BEGIN
			x_fulfillment_result := XDP_ENGINE.Get_Order_Param_Value(p_order_id,'FULFILLMENT_RESULT');
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_fulfillment_result := '';
		END;
		x_ERROR_DESCRIPTION := FND_API.G_RET_STS_SUCCESS;
    	x_return_code := 0;
EXCEPTION
	WHEN OTHERS THEN
     	x_return_code := -191266;
     	FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     	FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Get_Ord_Fulfillment_Status');
     	FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     	x_error_description := FND_MESSAGE.GET;
END Get_Ord_Fulfillment_Status;

PROCEDURE Set_Ord_Fulfillment_Status(
	p_order_id	IN	NUMBER,
	p_fulfillment_status	IN	VARCHAR2 DEFAULT NULL,
	p_fulfillment_result	IN	VARCHAR2 DEFAULT NULL,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2
)
IS
BEGIN
	IF (p_fulfillment_status IS NOT NULL) THEN
		XDP_ENGINE.Set_Order_Param_Value(p_order_id,'FULFILLMENT_STATUS',p_fulfillment_status);
	END IF;

	IF (p_fulfillment_result IS NOT NULL) THEN
		XDP_ENGINE.Set_Order_Param_Value(p_order_id,'FULFILLMENT_RESULT',p_fulfillment_result);
	END IF;
	x_RETURN_CODE := 0;
	x_ERROR_DESCRIPTION := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
	WHEN OTHERS THEN
     	x_return_code := -191266;
     	FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     	FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Set_Ord_Fulfillment_Status');
     	FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     	x_error_description := FND_MESSAGE.GET;
END Set_Ord_Fulfillment_Status;


/*
 From here on are the procedures used to convert the old process order api to
 new process order api
*/

FUNCTION TO_NEW_ORDER_HEADER(p_order_header IN  XDP_TYPES.ORDER_HEADER)
RETURN XDP_TYPES.SERVICE_ORDER_HEADER
IS
      lv_order_header 	    XDP_TYPES.SERVICE_ORDER_HEADER;
BEGIN
      lv_order_header.order_number := p_order_header.order_number;
      lv_order_header.order_version	:= p_order_header.order_version;
      lv_order_header.required_fulfillment_date := p_order_header.provisioning_date;
      lv_order_header.priority  := p_order_header.priority;
      lv_order_header.jeopardy_enabled_flag	 := p_order_header.jeopardy_enabled_flag;
      lv_order_header.execution_mode :=	'ASYNC';
      lv_order_header.account_number := NULL;
      lv_order_header.cust_account_id :=NULL;
      lv_order_header.due_date := p_order_header.due_date;
      lv_order_header.customer_required_date := p_order_header.customer_required_date;
      lv_order_header.customer_name := p_order_header.customer_name;
      lv_order_header.customer_id := p_order_header.customer_id;
      lv_order_header.telephone_number := p_order_header.telephone_number;

      lv_order_header.order_type := p_order_header.order_type;

      lv_order_header.order_source := p_order_header.order_source;
      lv_order_header.org_id:= p_order_header.org_id;

      lv_order_header.related_order_id 	:= p_order_header.related_order_id;
      lv_order_header.previous_order_id := p_order_header.previous_order_id;
      lv_order_header.next_order_id := p_order_header.next_order_id;
      lv_order_header.order_ref_name := p_order_header.order_ref_name;
      lv_order_header.order_ref_value := p_order_header.order_ref_value;
      lv_order_header.order_comments := NULL;
      lv_order_header.order_id := p_order_header.sdp_order_id;
      lv_order_header.order_status:= p_order_header.order_status;
      lv_order_header.fulfillment_status := NULL;
      lv_order_header.fulfillment_result := NULL;
      lv_order_header.completion_date := NULL;
      lv_order_header.actual_fulfillment_date := NULL;

      lv_order_header.attribute_category := NULL;
      lv_order_header.attribute1 := NULL;
      lv_order_header.attribute2 := NULL;
      lv_order_header.attribute3 := NULL;
      lv_order_header.attribute4 := NULL;
      lv_order_header.attribute5 := NULL;
      lv_order_header.attribute6 := NULL;
      lv_order_header.attribute7 := NULL;
      lv_order_header.attribute8 := NULL;
      lv_order_header.attribute9 := NULL;
      lv_order_header.attribute10 := NULL;
      lv_order_header.attribute11 := NULL;
      lv_order_header.attribute12 := NULL;
      lv_order_header.attribute13 := NULL;
      lv_order_header.attribute14 := NULL;
      lv_order_header.attribute15 := NULL;
      lv_order_header.attribute16 := NULL;
      lv_order_header.attribute17 := NULL;
      lv_order_header.attribute18 := NULL;
      lv_order_header.attribute19 := NULL;
      lv_order_header.attribute20 := NULL;
      RETURN lv_order_header;

END TO_NEW_ORDER_HEADER;

PROCEDURE TO_NEW_ORDER_PARAM_LIST(
    p_order_parameter IN XDP_TYPES.ORDER_PARAMETER_LIST,
    x_order_param_list IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST)
IS
    lv_param_index  BINARY_INTEGER;
BEGIN
    IF p_order_parameter.COUNT > 0 THEN
        lv_param_index := p_order_parameter.first;
        LOOP
            x_order_param_list(lv_param_index).parameter_name :=  p_order_parameter(lv_param_index).parameter_name;
            x_order_param_list(lv_param_index).parameter_value := p_order_parameter(lv_param_index).parameter_value;
            EXIT WHEN lv_param_index = p_order_parameter.last;
            lv_param_index := p_order_parameter.next(lv_param_index);
        END LOOP;
   END IF;
END;

FUNCTION TO_NEW_LINE_ITEM(
        p_line_item IN XDP_TYPES.LINE_ITEM,
        p_default_action_code IN VARCHAR2)
RETURN XDP_TYPES.SERVICE_LINE_ITEM
IS
        x_order_line_item XDP_TYPES.SERVICE_LINE_ITEM;
BEGIN
       x_order_line_item.line_number := p_line_item.line_number;
       x_order_line_item.line_source := NULL; -- MAYA

       -- Inventory item id will be one of the following values
       --   service_id
       --   package_id
       -- These fields are mutual exclusive in the old strucuture.

       x_order_line_item.inventory_item_id := p_line_item.service_id;
       x_order_line_item.inventory_item_id :=
            nvl(x_order_line_item.inventory_item_id,p_line_item.package_id);
--       x_order_line_item.inventory_item_id :=
--            nvl(x_order_line_item.inventory_item_id,p_line_item.workitem_id);

       /** Workitem_id has been added to the new structure **/
       x_order_line_item.workitem_id := p_line_item.workitem_id;
       x_order_line_item.service_item_name := p_line_item.line_item_name;

       x_order_line_item.version := p_line_item.version;

       --
       -- If it is an workitem, action code will be NULL
       -- else action code will be defaulted to default_action_code if
       -- p_line_item.action is NULL
       --

       IF UPPER(p_line_item.is_workitem_flag) = 'Y' THEN
            x_order_line_item.action_code := NULL;
       ELSE
            x_order_line_item.action_code := nvl(p_line_item.action,p_default_action_code);
       END IF;

       x_order_line_item.organization_code         := NULL;
       x_order_line_item.organization_id           := NULL;
       x_order_line_item.site_use_id               := NULL;
       x_order_line_item.ib_source                 := 'NONE';
       x_order_line_item.ib_source_id              := NULL;
       x_order_line_item.required_fulfillment_date := p_line_item.provisioning_date;
       x_order_line_item.fulfillment_required_flag := p_line_item.provisioning_required_flag;
       x_order_line_item.fulfillment_sequence      := p_line_item.provisioning_sequence;
       x_order_line_item.bundle_id                 := p_line_item.bundle_id;
       x_order_line_item.bundle_sequence           := p_line_item.bundle_sequence;
       x_order_line_item.priority                  := p_line_item.priority;
       x_order_line_item.due_date                  := p_line_item.due_date;
       x_order_line_item.jeopardy_enabled_flag     := p_line_item.jeopardy_enabled_flag;
       x_order_line_item.customer_required_date    := p_line_item.customer_required_date;
       x_order_line_item.starting_number           := p_line_item.starting_number;
       x_order_line_item.ending_number             := p_line_item.ending_number;
       x_order_line_item.line_item_id              := p_line_item.line_item_id;
       x_order_line_item.line_status               := p_line_item.line_status;
       x_order_line_item.completion_date           := p_line_item.completion_date;
       x_order_line_item.actual_fulfillment_date   := NULL;
       x_order_line_item.is_package_flag           := 'N';
       x_order_line_item.parent_line_number        := NULL;
       x_order_line_item.attribute_category        := NULL;
       x_order_line_item.attribute1 := NULL;
       x_order_line_item.attribute2 := NULL;
       x_order_line_item.attribute3 := NULL;
       x_order_line_item.attribute4 := NULL;
       x_order_line_item.attribute5 := NULL;
       x_order_line_item.attribute6 := NULL;
       x_order_line_item.attribute7 := NULL;
       x_order_line_item.attribute8 := NULL;
       x_order_line_item.attribute9 := NULL;
       x_order_line_item.attribute10 := NULL;
       x_order_line_item.attribute11 := NULL;
       x_order_line_item.attribute12 := NULL;
       x_order_line_item.attribute13 := NULL;
       x_order_line_item.attribute14 := NULL;
       x_order_line_item.attribute15 := NULL;
       x_order_line_item.attribute16 := NULL;
       x_order_line_item.attribute17 := NULL;
       x_order_line_item.attribute18 := NULL;
       x_order_line_item.attribute19 := NULL;
       x_order_line_item.attribute20 := NULL;
       RETURN x_order_line_item;
END;

PROCEDURE TO_NEW_LINE_LIST(
    p_line_list IN XDP_TYPES.ORDER_LINE_LIST,
    x_order_line_list OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    p_default_action_code IN VARCHAR2)
IS
    lv_param_index  BINARY_INTEGER;
BEGIN
    IF p_line_list.COUNT > 0 THEN
        lv_param_index := p_line_list.first;
        LOOP
            x_order_line_list(lv_param_index) := TO_NEW_LINE_ITEM(p_line_list(lv_param_index),p_default_action_code);
            EXIT WHEN lv_param_index = p_line_list.last;
            lv_param_index := p_line_list.next(lv_param_index);
        END LOOP;
    END IF;
END;

PROCEDURE TO_NEW_LINE_PARAM_LIST(
    p_line_parameter_list IN XDP_TYPES.LINE_PARAM_LIST,
    x_line_param_list OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST)
IS
    lv_param_index  BINARY_INTEGER;
BEGIN
    IF p_line_parameter_list.COUNT > 0 THEN
        lv_param_index := p_line_parameter_list.first;
        LOOP
            x_line_param_list(lv_param_index).line_number        := p_line_parameter_list(lv_param_index).line_number;
            x_line_param_list(lv_param_index).parameter_name     := p_line_parameter_list(lv_param_index).parameter_name;
            x_line_param_list(lv_param_index).parameter_value    := p_line_parameter_list(lv_param_index).parameter_value;
            x_line_param_list(lv_param_index).parameter_ref_value:= p_line_parameter_list(lv_param_index).parameter_ref_value;

            EXIT WHEN lv_param_index = p_line_parameter_list.last;
                      lv_param_index := p_line_parameter_list.next(lv_param_index);
        END LOOP;
   END IF;
END;

/* This is the wrapper over the old API */

PROCEDURE Process_Old_Order(
 	P_ORDER_HEADER 		IN  XDP_TYPES.ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN  XDP_TYPES.ORDER_PARAMETER_LIST,
 	P_ORDER_LINE_LIST 	IN  XDP_TYPES.ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN  XDP_TYPES.LINE_PARAM_LIST,
 	P_execution_mode 	IN  VARCHAR2 DEFAULT 'ASYNC',
	SDP_ORDER_ID		   OUT NOCOPY NUMBER,
 	RETURN_CODE 		IN OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	IN OUT NOCOPY VARCHAR2)
IS
 	lv_order_header 	    XDP_TYPES.SERVICE_ORDER_HEADER;
 	lv_order_param_list 	XDP_TYPES.SERVICE_ORDER_PARAM_LIST;
 	lv_order_line_list	    XDP_TYPES.SERVICE_ORDER_LINE_LIST;
 	lv_line_param_list 	    XDP_TYPES.SERVICE_LINE_PARAM_LIST;
BEGIN
      lv_order_header := TO_NEW_ORDER_HEADER(P_ORDER_HEADER);
      TO_NEW_ORDER_PARAM_LIST(P_ORDER_PARAMETER,lv_order_param_list);
      TO_NEW_LINE_LIST(P_ORDER_LINE_LIST,lv_order_line_list,p_order_header.order_action);
      TO_NEW_LINE_PARAM_LIST(P_LINE_PARAMETER_LIST,lv_line_param_list);
      lv_order_header.execution_mode := p_execution_mode;
/*
    In the old structure, the order header has an action_code field which was to be used
    as default action code for its line itmes if the item does not
    have action code itself. Bearing in mind that now action code is used for
    two folds of meaning. When it is null, the internal API will think this
    call will be used
*/

      XDP_ORDER.Process_Order(
     		lv_order_header,
     		lv_order_param_list,
 	    	lv_order_line_list,
 		    lv_line_param_list,
    		SDP_ORDER_ID,
 	    	RETURN_CODE ,
 		    ERROR_DESCRIPTION );

EXCEPTION
WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.PROCESS_OLD_ORDER');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
END Process_Old_Order;

/*
 The following procedures are used to retreive order information.


 This is a private procedure used by private API Get_Order_Status in
 this package.
*/

PROCEDURE Get_Order_Status(
    p_order_id IN NUMBER,
    x_order_status OUT NOCOPY XDP_TYPES.SERVICE_ORDER_STATUS,
    x_return_code OUT NOCOPY NUMBER,
    x_error_description OUT NOCOPY VARCHAR2)
IS
  CURSOR lc_order_param IS
	SELECT Order_parameter_name,
               order_parameter_value
	  FROM xdp_order_parameters
	 WHERE order_id = p_order_id;

    lv_param_count NUMBER := 0;
BEGIN
    SELECT order_id,
           status_code,
  	   external_order_number,
      	   external_order_version,
    	   actual_provisioning_date,
	   completion_date
    INTO x_order_status.order_id,
      	 x_order_status.order_status,
  	 x_order_status.order_number,
      	 x_order_status.order_version,
      	 x_order_status.actual_fulfillment_date,
  	 x_order_status.completion_date
    FROM XDP_ORDER_HEADERS
   WHERE order_id = p_order_id;

    BEGIN
        x_order_status.fulfillment_status := XDP_ENGINE.Get_Order_Param_Value(p_order_id,'FULFILLMENT_STATUS');
	EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    	x_order_status.fulfillment_status := NULL;
	END;
	BEGIN
		x_order_status.fulfillment_result := XDP_ENGINE.Get_Order_Param_Value(p_order_id,'FULFILLMENT_RESULT');
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_order_status.fulfillment_result := NULL;
	END;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_return_code := SQLCODE;
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_order_id);
    x_error_description := FND_MESSAGE.GET;
END Get_Order_Status;

/*
 This is a private procedure used by Get_Order_Details in this package
*/

PROCEDURE Get_Order_Header(
    p_order_id IN NUMBER,
    x_order_header OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
    x_order_param_list OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
    x_return_code OUT NOCOPY NUMBER,
    x_error_description OUT NOCOPY VARCHAR2)
IS
  CURSOR lc_order_param IS
	select order_parameter_name,order_parameter_value
	from  xdp_order_parameters
	where order_id = p_order_id;
    lv_param_count NUMBER := 0;
BEGIN
    SELECT
        external_order_number,
        external_order_version,
        provisioning_date,
        priority,
        jeopardy_enabled_flag,
--        execution_mode,
--        account_number,
        cust_account_id,
        due_date,
        customer_required_date,
    	customer_name,
	    customer_id,
	    telephone_number,
        order_type,
        order_source,
        org_id,
        related_order_id,
        previous_order_id,
        next_order_id,
        order_ref_name,
        order_ref_value,
        order_comment,
        order_id,
        status_code,
        completion_date,
        actual_provisioning_date,
	attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20
    INTO
        x_order_header.order_number,
        x_order_header.order_version,
        x_order_header.required_fulfillment_date,
        x_order_header.priority,
        x_order_header.jeopardy_enabled_flag,
--        x_order_header.execution_mode,
--        x_order_header.account_number,
        x_order_header.cust_account_id,
        x_order_header.due_date,
        x_order_header.customer_required_date,
    	x_order_header.customer_name,
	x_order_header.customer_id,
	x_order_header.telephone_number,
        x_order_header.order_type,
        x_order_header.order_source,
        x_order_header.org_id,
        x_order_header.related_order_id,
        x_order_header.previous_order_id,
        x_order_header.next_order_id,
        x_order_header.order_ref_name,
        x_order_header.order_ref_value,
        x_order_header.order_comments,
        x_order_header.order_id,
        x_order_header.order_status,
        x_order_header.completion_date,
        x_order_header.actual_fulfillment_date,
	x_order_header.attribute_category,
        x_order_header.attribute1,
        x_order_header.attribute2,
        x_order_header.attribute3,
        x_order_header.attribute4,
        x_order_header.attribute5,
        x_order_header.attribute6,
        x_order_header.attribute7,
        x_order_header.attribute8,
        x_order_header.attribute9,
        x_order_header.attribute10,
        x_order_header.attribute11,
        x_order_header.attribute12,
        x_order_header.attribute13,
        x_order_header.attribute14,
        x_order_header.attribute15,
        x_order_header.attribute16,
        x_order_header.attribute17,
        x_order_header.attribute18,
        x_order_header.attribute19,
        x_order_header.attribute20
    FROM XDP_ORDER_HEADERS
    WHERE order_id = p_order_id;
    x_order_header.execution_mode := NULL;
    x_order_header.account_number:= NULL;
    x_order_header.fulfillment_status := NULL;
    x_order_header.fulfillment_result := NULL;

    IF x_order_header.cust_account_id IS NOT NULL THEN
	SELECT account_number INTO x_order_header.account_number
	FROM HZ_CUST_ACCOUNTS WHERE cust_account_id = x_order_header.cust_account_id;
    END IF;

    FOR lv_param_rec IN lc_order_param LOOP
        lv_param_count := lv_param_count + 1;
        x_order_param_list(lv_param_count).parameter_name := lv_param_rec.order_parameter_name;
        x_order_param_list(lv_param_count).parameter_value := lv_param_rec.order_parameter_value;
        IF (UPPER(lv_param_rec.order_parameter_name) = 'FULFILLMENT_STATUS') THEN
            x_order_header.fulfillment_status := lv_param_rec.order_parameter_value;
        END IF;
        IF (UPPER(lv_param_rec.order_parameter_name) = 'FULFILLMENT_RESULT') THEN
            x_order_header.fulfillment_result := lv_param_rec.order_parameter_value;
        END IF;
    END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_return_code := SQLCODE;
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_order_id);
    x_error_description := FND_MESSAGE.GET;
END Get_Order_Header;

--
-- This is a private api used by Get_Order_Details
--

PROCEDURE Get_Order_Lines(
    p_order_id IN NUMBER,
    x_line_list OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    x_line_param_list OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST)
IS
  CURSOR lc_line IS
    SELECT
        line_number,
        line_source,
        inventory_item_id,
        line_item_name,
        version,
        line_item_action_code,
        organization_id,
        site_use_id,
        ib_source,
        ib_source_id,
        provisioning_date,
        provisioning_required_flag,
        line_sequence, -- not provisioning_sequence
        bundle_id,
        bundle_sequence,
        priority,
        due_date,
        jeopardy_enabled_flag,
        customer_required_date,
        starting_number,
        ending_number,
        line_item_id,
        status_code, -- not line_status
        completion_date,
        actual_provisioning_date,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20
    FROM
        xdp_order_line_items
    WHERE
        order_id = p_order_id
    AND
		is_virtual_line_flag = 'N';

    CURSOR lc_line_param(p_lineitem NUMBER) IS
        SELECT line_parameter_name,parameter_value,parameter_reference_value
        FROM  xdp_order_lineitem_dets
        WHERE line_item_id = p_lineitem;

    lv_count NUMBER := 0;
    lv_param_count NUMBER := 0;
BEGIN
    FOR lv_line_rec IN lc_line LOOP
    	lv_count := lv_count + 1;

        x_line_list(lv_count).line_number := lv_line_rec.line_number;
        x_line_list(lv_count).line_source := lv_line_rec.line_source;
        x_line_list(lv_count).inventory_item_id := lv_line_rec.inventory_item_id;
        x_line_list(lv_count).service_item_name := lv_line_rec.line_item_name;
        x_line_list(lv_count).version := lv_line_rec.version;
        x_line_list(lv_count).action_code := lv_line_rec.line_item_action_code;
        x_line_list(lv_count).organization_code := null; -- lv_line_rec.organization_code;
        x_line_list(lv_count).organization_id := lv_line_rec.organization_id;

	IF (lv_line_rec.organization_id IS NOT NULL) THEN
	    SELECT organization_code into x_line_list(lv_count).organization_code
	    FROM MTL_PARAMETERS WHERE organization_id = lv_line_rec.organization_id;
	END IF;

        x_line_list(lv_count).site_use_id := lv_line_rec.site_use_id;
        x_line_list(lv_count).ib_source := lv_line_rec.ib_source;
        x_line_list(lv_count).ib_source_id := lv_line_rec.ib_source_id;
        x_line_list(lv_count).required_fulfillment_date := lv_line_rec.provisioning_date;
        x_line_list(lv_count).fulfillment_required_flag := lv_line_rec.provisioning_required_flag;
        x_line_list(lv_count).fulfillment_sequence := lv_line_rec.line_sequence;
        x_line_list(lv_count).bundle_id := lv_line_rec.bundle_id;
        x_line_list(lv_count).bundle_sequence := lv_line_rec.bundle_sequence;
        x_line_list(lv_count).priority := lv_line_rec.priority;
        x_line_list(lv_count).due_date := lv_line_rec.due_date;
        x_line_list(lv_count).jeopardy_enabled_flag := lv_line_rec.jeopardy_enabled_flag;
        x_line_list(lv_count).customer_required_date := lv_line_rec.customer_required_date;
        x_line_list(lv_count).starting_number := lv_line_rec.starting_number;
        x_line_list(lv_count).ending_number := lv_line_rec.ending_number;
        x_line_list(lv_count).line_item_id := lv_line_rec.line_item_id;
        x_line_list(lv_count).line_status := lv_line_rec.status_code;
        x_line_list(lv_count).completion_date := lv_line_rec.completion_date;
        x_line_list(lv_count).actual_fulfillment_date := lv_line_rec.actual_provisioning_date;
	x_line_list(lv_count).attribute_category := lv_line_rec.attribute_category;
        x_line_list(lv_count).attribute1 := lv_line_rec.attribute1;
        x_line_list(lv_count).attribute2 := lv_line_rec.attribute2;
        x_line_list(lv_count).attribute3 := lv_line_rec.attribute3;
        x_line_list(lv_count).attribute4 := lv_line_rec.attribute4;
        x_line_list(lv_count).attribute5 := lv_line_rec.attribute5;
        x_line_list(lv_count).attribute6 := lv_line_rec.attribute6;
        x_line_list(lv_count).attribute7 := lv_line_rec.attribute7;
        x_line_list(lv_count).attribute8 := lv_line_rec.attribute8;
        x_line_list(lv_count).attribute9 := lv_line_rec.attribute9;
        x_line_list(lv_count).attribute10 := lv_line_rec.attribute10;
        x_line_list(lv_count).attribute11 := lv_line_rec.attribute11;
        x_line_list(lv_count).attribute12 := lv_line_rec.attribute12;
        x_line_list(lv_count).attribute13 := lv_line_rec.attribute13;
        x_line_list(lv_count).attribute14 := lv_line_rec.attribute14;
        x_line_list(lv_count).attribute15 := lv_line_rec.attribute15;
        x_line_list(lv_count).attribute16 := lv_line_rec.attribute16;
        x_line_list(lv_count).attribute17 := lv_line_rec.attribute17;
        x_line_list(lv_count).attribute18 := lv_line_rec.attribute18;
        x_line_list(lv_count).attribute19 := lv_line_rec.attribute19;
        x_line_list(lv_count).attribute20 := lv_line_rec.attribute20;

        FOR lv_param_rec IN lc_line_param(lv_line_rec.line_item_id) LOOP
            lv_param_count := lv_param_count + 1;
            x_line_param_list(lv_param_count).line_number := lv_line_rec.line_number;
            x_line_param_list(lv_param_count).parameter_name := lv_param_rec.line_parameter_name;
            x_line_param_list(lv_param_count).parameter_value := lv_param_rec.parameter_value;
            x_line_param_list(lv_param_count).parameter_ref_value := lv_param_rec.parameter_reference_value;
       END LOOP;
    END LOOP;
END Get_Order_Lines;
/*
 This is the private API for retrieving order status. It is used
 by public API to retrieve order status information.
 Data is stored in x_order_status
*/
Procedure Get_Order_Status(
        p_order_id 		    IN  NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        p_order_number  	IN  VARCHAR2	DEFAULT	FND_API.G_MISS_CHAR,
        p_order_version	  	IN  VARCHAR2 	DEFAULT	'1',
        x_order_status      OUT NOCOPY XDP_TYPES.SERVICE_ORDER_STATUS,
        x_return_code 		OUT NOCOPY NUMBER,
        x_error_description	OUT NOCOPY VARCHAR2)
IS
    l_order_id NUMBER;
BEGIN
    l_order_id := p_order_id;

    IF l_order_id IS NULL THEN
        SELECT order_id into l_order_id
          FROM XDP_ORDER_HEADERS
         WHERE EXTERNAL_ORDER_NUMBER  = (p_order_number)
           AND NVL(EXTERNAL_ORDER_VERSION,'-1') = NVL((p_order_version),'-1') ;
    END IF;

    Get_Order_Status(l_order_id,x_order_status,x_return_code,x_error_description);
EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_return_code := SQLCODE;
    FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_VERSION_NOTEXISTS');
    FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', p_order_number);
    FND_MESSAGE.SET_TOKEN('ORDER_VERSION', p_order_version);
    x_error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
    x_return_code := -191266;
    FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
    FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.GET_ORDER_STATUS');
    FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
    x_error_description := FND_MESSAGE.GET;
END Get_Order_Status;


/*
    This is the internal API for geting order details. It is used
    by public API to retrieve order detail information.
    Data is stored in four data structures as defined in XDP_TYPES
*/
Procedure Get_Order_Details(
        p_order_id 		    IN  NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        p_order_number  	IN  VARCHAR2	DEFAULT	FND_API.G_MISS_CHAR,
        p_order_version	  	IN  VARCHAR2 	DEFAULT	'1',
        x_order_header		OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
        x_order_param_list	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
        x_line_item_list	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
        x_line_param_list	OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
 	    x_return_code 		OUT NOCOPY NUMBER,
 	    x_error_description	OUT NOCOPY VARCHAR2)
IS
    l_order_id NUMBER;
BEGIN
    l_order_id := p_order_id;

    IF l_order_id IS NULL THEN
        SELECT order_id into l_order_id
          FROM XDP_ORDER_HEADERS
         WHERE EXTERNAL_ORDER_NUMBER  = (p_order_number)
           AND NVL(EXTERNAL_ORDER_VERSION,'-1') = NVL((p_order_version),'-1') ;
    END IF;

    Get_Order_Header(l_order_id,x_order_header,x_order_param_list,x_return_code,x_error_description);
    Get_Order_Lines(l_order_id,x_line_item_list,x_line_param_list);

EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_return_code := SQLCODE;
    FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_VERSION_NOTEXISTS');
    FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', p_order_number);
    FND_MESSAGE.SET_TOKEN('ORDER_VERSION', p_order_version);
    x_error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
    x_return_code := -191266;
    FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
    FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.GET_ORDER_DETAILS');
    FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
    x_error_description := FND_MESSAGE.GET;

END Get_Order_Details;

--
-- Private API which will remove an FA from queue
--

PROCEDURE CANCEL_FA
	    (p_order_id         IN NUMBER,
             p_fa_instance_id   IN NUMBER,
	     p_msg_id           IN RAW,
	     p_caller_name      IN VARCHAR2,
             p_fa_wf_item_type  IN VARCHAR2,
             p_fa_wf_item_key   IN VARCHAR2,
	     p_status           IN VARCHAR2,
	     return_code       OUT NOCOPY NUMBER,
	     error_description OUT NOCOPY VARCHAR2)
IS
  lv_id             NUMBER;
  lv_in_fa_q        VARCHAR2(1) := 'Y';
  lv_item_type      VARCHAR2(80);
  lv_item_key       VARCHAR2(300);
  lv_state          VARCHAR2(100);
  lv_lock           VARCHAR2(1) := 'Y';
  lv_user_data      SYSTEM.XDP_WF_CHANNELQ_TYPE;
  lv_lock_status    VARCHAR2(1);
  lv_error          VARCHAR2(1000);
  lv_fa_instance_id NUMBER;

  e_xdp_fa_state_success     EXCEPTION ;
  e_xdp_fa_state_inprogress EXCEPTION ;

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
          dbg_msg := ('Procedure XDP_INTERFACES.CANCEL_FA begins for FA instance : ' ||p_fa_instance_id);
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
	  END IF;
       END IF;
     END IF;

   	return_code := 0;
        IF p_status = 'WAIT_FOR_RESOURCE' THEN

           BEGIN
                SELECT fa_instance_id
                  INTO lv_fa_instance_id
                  FROM xdp_adapter_job_queue
                 WHERE fa_instance_id = p_fa_instance_id
                   AND wf_item_type   = p_fa_wf_item_type
                   AND wf_item_key    = p_fa_wf_item_key
    	           FOR UPDATE NOWAIT;

                IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                  IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                    dbg_msg := ('Aquired Lock Deleting From XDP_ADAPTER_JOB_QUEUE ');
		    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
		    END IF;
                  END IF;
                END IF;

                DELETE from xdp_adapter_job_queue
                 WHERE fa_instance_id = p_fa_instance_id
                   AND wf_item_type   = p_fa_wf_item_type
                   AND wf_item_key    = p_fa_wf_item_key;

                IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                  IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                    dbg_msg := ('Deleted From XDP_ADAPTER_JOB_QUEUE Calling UPDATE_XDP_FA_INSTANCE_STATUS ');
		    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
		    END IF;
                  END IF;
                END IF;

                UPDATE_XDP_FA_INSTANCE_STATUS
                     (p_fa_instance_id  => p_fa_instance_id,
                      p_status          => 'CANCELED',
                      p_caller_name     => p_caller_name,
                      return_code       =>  return_code ,
                      error_description => error_description );

                      IF return_code <> 0 THEN
                         return ;
                      END IF ;



           EXCEPTION
   	        WHEN resource_busy or no_data_found THEN
                     raise e_xdp_fa_state_inprogress ;
                     -- raise can not cancel order FA in progress
           END ;

        ELSIF p_status = 'READY_FOR_RESOURCE' THEN

		LOCK_AND_REMOVE_MSG
                       (p_msg_id      => p_msg_id,
			p_queue_name  => 'XDP_WF_CHANNEL_Q',
			x_user_data   =>lv_user_data,
			x_lock_status => lv_lock_status,
			x_error       => lv_error);

		IF lv_lock_status = G_LOCK_MSG_SUCCESS THEN

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                        dbg_msg := ('Aquired Lock on XDP_WF_CHANNEL_Q Calling UPDATE_XDP_FA_INSTANCE_STATUS');
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
			END IF;
                     END IF;
                   END IF;

                        UPDATE_XDP_FA_INSTANCE_STATUS
                             (p_fa_instance_id  => p_fa_instance_id,
                              p_status          => 'CANCELED',
                              p_caller_name     => p_caller_name,
                              return_code       =>  return_code ,
                              error_description => error_description );

                      IF return_code <> 0 THEN
                         return ;
                      END IF ;


                ELSE

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                        dbg_msg := ('Colud Not Aquire Lock on XDP_WF_CHANNEL_Q FA is IN PROGRESS');
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
			END IF;
                     END IF;
                   END IF;

                     raise e_xdp_fa_state_inprogress ;
                     -- raise can not cancel order FA in progress try again
                END IF;
        ELSIF p_status = 'READY' THEN

                LOCK_AND_REMOVE_MSG
                       (p_msg_id      => p_msg_id,
                        p_queue_name  => 'XDP_FA_QUEUE',
                        x_user_data   => lv_user_data,
                        x_lock_status => lv_lock_status,
                        x_error       => lv_error);

                IF lv_lock_status = G_LOCK_MSG_SUCCESS THEN

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                        dbg_msg := ('Aquired Lock on XDP_FA_QUEUE Calling UPDATE_XDP_FA_INSTANCE_STATUS ');
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
			END IF;
                     END IF;
                   END IF;

                      UPDATE_XDP_FA_INSTANCE_STATUS
                             (p_fa_instance_id  => p_fa_instance_id,
                              p_status          => 'CANCELED',
                              p_caller_name     => p_caller_name,
                              return_code       =>  return_code ,
                              error_description => error_description );

                      IF return_code <> 0 THEN
                         return ;
                      END IF ;


                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                        dbg_msg := ('Completed UPDATE_XDP_FA_INSTANCE_STATUS ');
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
			END IF;
                     END IF;
                   END IF;


                ELSE
                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                        dbg_msg := ('Colud Not Aquire Lock on XDP_FA_QUEUE FA is IN PROGRESS');
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
			END IF;
                     END IF;
                   END IF;

                     raise e_xdp_fa_state_inprogress ;
                     -- raise can not cancel order FA in progress try again
                END IF;

        ELSIF p_status IN ('ERROR','STANDBY') THEN

              IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                  dbg_msg := ('FA Status is '||p_status||' Calling UPDATE_XDP_FA_INSTANCE_STATUS ');
		  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
		  END IF;
                END IF;
              END IF;

               UPDATE_XDP_FA_INSTANCE_STATUS
                             (p_fa_instance_id  => p_fa_instance_id,
                              p_status          => 'CANCELED',
                              p_caller_name     => p_caller_name,
                              return_code       =>  return_code ,
                              error_description => error_description );

              IF return_code <> 0 THEN
                 return ;
              END IF ;


             IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
               IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA')) THEN
                  dbg_msg := ('Completed UPDATE_XDP_FA_INSTANCE_STATUS ');
		  IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_FA', dbg_msg);
		  END IF;
               END IF;
             END IF;

        END IF;

EXCEPTION
     WHEN resource_busy OR no_data_found THEN
          return_code := -191318;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_CANNOT_REMOVE_ORDER');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', lv_error);
          error_description := FND_MESSAGE.GET;
          return;
     WHEN e_xdp_fa_state_inprogress THEN
          return_code := 197010;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_FA_STATE_INPROGRESS');
          FND_MESSAGE.SET_TOKEN('ORDER_ID', p_order_id);
          error_description := FND_MESSAGE.GET;
          return;
     WHEN OTHERS THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END CANCEL_FA ;


--
-- Private API which will remove a workitem from queue
--
PROCEDURE CANCEL_WORKITEM
	     (p_wi_instance_id   IN NUMBER,
	      p_msg_id           IN RAW,
              p_wi_wf_item_type  IN VARCHAR2,
              p_wi_wf_item_key   IN VARCHAR2,
	      p_caller_name      IN VARCHAR2,
	      p_status           IN VARCHAR2,
	      return_code       OUT NOCOPY NUMBER,
	      error_description OUT NOCOPY VARCHAR2)
IS
  lv_id          NUMBER;
  lv_lock        VARCHAR2(1) := 'Y';
  lv_state       VARCHAR2(100);
  lv_user_data   SYSTEM.XDP_WF_CHANNELQ_TYPE;
  lv_lock_status VARCHAR2(1);
  lv_error       VARCHAR2(1000);

  e_xdp_wi_state_inprogress EXCEPTION;

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_WORKITEM')) THEN
         dbg_msg := ('Procedure XDP_INTERFACES.CANCEL_WORKITEM begins for WI Instance : '||p_wi_instance_id);
	IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_WORKITEM', dbg_msg);
	END IF;
       END IF;
     END IF;
   	return_code := 0;
        IF p_status IN ('STANDBY','ERROR','IN PROGRESS') THEN

             IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
               IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_WORKITEM')) THEN
                dbg_msg := ('Workitem Status is :' ||p_status||' Calling UPDATE_XDP_WI_INSTANCE_STATUS ');
		IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_WORKITEM', dbg_msg);
		END IF;
               END IF;
             END IF;

           UPDATE_XDP_WI_INSTANCE_STATUS
                 (p_order_id        => null,
                  p_wi_instance_id  => p_wi_instance_id,
                  p_status          => 'CANCELED',
                  p_caller_name     => p_caller_name,
                  return_code       => return_code,
                  error_description => error_description );

           IF return_code <> 0 THEN
              return ;
           END IF ;

        ELSIF p_status = 'READY' THEN

              IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_WORKITEM')) THEN
                    dbg_msg := ('Workitem Status is :' ||p_status||' Removing From XDP_WORKITEM_QUEUE ');
		    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_WORKITEM', dbg_msg);
		    END IF;
                 END IF;
               END IF;

              LOCK_AND_REMOVE_MSG(
                        p_msg_id      => p_msg_id,
                        p_queue_name  => 'XDP_WORKITEM_QUEUE',
                        x_user_data   =>lv_user_data,
                        x_lock_status => lv_lock_status,
                        x_error       => lv_error);


                IF lv_lock_status = G_LOCK_MSG_SUCCESS THEN

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_WORKITEM')) THEN
                        dbg_msg := ('Workitem Removed From XDP_WORKITEM_QUEUE Calling UPDATE_XDP_WI_INSTANCE_STATUS ');
			IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'xdp.plsql.XDP_INTERFACES.CANCEL_WORKITEM', dbg_msg);
			END IF;
                     END IF;
                   END IF;

                   UPDATE_XDP_WI_INSTANCE_STATUS
                        (p_order_id        => null,
                         p_wi_instance_id  => p_wi_instance_id,
                         p_status          => 'CANCELED',
                         p_caller_name     => p_caller_name,
                         return_code       => return_code,
                         error_description => error_description );

                   IF return_code <> 0 THEN
                      return ;
                   END IF ;
                   return;
                ELSE
                    raise e_xdp_wi_state_inprogress ;
                    -- raise workitem in progress please try again
                END IF;
        END IF;


EXCEPTION
     WHEN e_xdp_wi_state_inprogress THEN
          return_code := -191318;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_CANNOT_REMOVE_ORDER');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', lv_error);
          error_description := FND_MESSAGE.GET;
          return;
     WHEN OTHERS THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END CANCEL_WORKITEM;


--
-- Private API which will update xdp_order_headers status_code
--
--
PROCEDURE update_xdp_order_status
            (p_order_id  IN NUMBER ,
             p_status    IN VARCHAR2,
             p_caller_name      IN VARCHAR2,
             return_code       OUT NOCOPY NUMBER,
              error_description OUT NOCOPY VARCHAR2) IS

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.UPDATE_XDP_ORDER_STATUS')) THEN
          dbg_msg := ('Procedure XDP_INTERFACES.UPDATE_XDP_ORDER_STATUS begins.');
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.UPDATE_XDP_ORDER_STATUS', dbg_msg);
	  END IF;
       END IF;
     END IF;

    UPDATE xdp_order_headers
       SET last_updated_by          = FND_GLOBAL.USER_ID,
           last_update_date         = sysdate,
           last_update_login        = FND_GLOBAL.LOGIN_ID,
           status_code              = p_status,
           canceled_by              = p_caller_name,
           cancel_provisioning_date = sysdate
     WHERE order_id                 = p_order_id ;

     IF UPPER(p_status) = 'CANCELLED' THEN
        XDP_ENGINE.Set_Order_Param_Value(p_order_id,'FULFILLMENT_STATUS',p_status);
     END IF;

EXCEPTION
     WHEN OTHERS THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB. UPDATE_XDP_ORDER_STATUS');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END UPDATE_XDP_ORDER_STATUS;

--
-- Private API which will update xdp_order_line_items status_code
--
--

PROCEDURE UPDATE_XDP_ORDER_LINE_STATUS
            (p_order_id         IN NUMBER,
             p_lineitem_id      IN NUMBER ,
             p_status           IN VARCHAR2,
             p_caller_name      IN VARCHAR2,
             return_code       OUT NOCOPY NUMBER,
              error_description OUT NOCOPY VARCHAR2) IS

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.UPDATE_XDP_ORDER_LINE_STATUS')) THEN
          dbg_msg := ('Procedure XDP_INTERFACES.UPDATE_XDP_ORDER_LINE_STATUS begins.');
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.UPDATE_XDP_ORDER_LINE_STATUS', dbg_msg);
	  END IF;
       END IF;
     END IF;

    UPDATE xdp_order_line_items
       SET last_updated_by          = FND_GLOBAL.USER_ID,
           last_update_date         = sysdate,
           last_update_login        = FND_GLOBAL.LOGIN_ID,
           status_code              = p_status,
           canceled_by              = p_caller_name,
           cancel_provisioning_date = sysdate
     WHERE order_id                 = NVL(p_order_id ,order_id)
       AND line_item_id             = NVL(p_lineitem_id , line_item_id) ;

EXCEPTION
     WHEN OTHERS THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.UPDATE_XDP_ORDER_LINE_STATUS');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END UPDATE_XDP_ORDER_LINE_STATUS;

--
-- Private API which will update xdp_fulfill_worklist status_code
--
--

PROCEDURE UPDATE_XDP_WI_INSTANCE_STATUS
            (p_order_id         IN NUMBER,
             p_wi_instance_id   IN NUMBER ,
             p_status           IN VARCHAR2,
             p_caller_name      IN VARCHAR2,
             return_code       OUT NOCOPY NUMBER,
             error_description OUT NOCOPY VARCHAR2) IS

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.UPDATE_XDP_WI_INSTANCE_STATUS')) THEN
          dbg_msg := ('Procedure XDP_INTERFACES.UPDATE_XDP_WI_INSTANCE_STATUS begins.');
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.UPDATE_XDP_WI_INSTANCE_STATUS', dbg_msg);
	  END IF;
       END IF;
     END IF;
          UPDATE xdp_fulfill_worklist
              SET last_updated_by          = FND_GLOBAL.USER_ID,
                  last_update_date         = sysdate,
                  last_update_login        = FND_GLOBAL.LOGIN_ID,
                  status_code              = p_status,
                  canceled_by              = p_caller_name,
                  cancel_provisioning_date = sysdate
            WHERE order_id                 = NVL(p_order_id , order_id )
              AND workitem_instance_id     = NVL(p_wi_instance_id,workitem_instance_id);

EXCEPTION
     WHEN OTHERS THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.UPDATE_XDP_WI_INSTANCE_STATUS');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END UPDATE_XDP_WI_INSTANCE_STATUS;

--
-- Private API which will update xdp_fa_runtime_list status_code
--
--

PROCEDURE UPDATE_XDP_FA_INSTANCE_STATUS
            (p_fa_instance_id   IN NUMBER ,
             p_status           IN VARCHAR2,
             p_caller_name      IN VARCHAR2,
             return_code       OUT NOCOPY NUMBER,
              error_description OUT NOCOPY VARCHAR2) IS

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.UPDATE_XDP_FA_INSTANCE_STATUS')) THEN
          dbg_msg := ('Procedure XDP_INTERFACES.UPDATE_XDP_FA_INSTANCE_STATUS begins.');
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.UPDATE_XDP_FA_INSTANCE_STATUS', dbg_msg);
	  END IF;
       END IF;
     END IF;
         UPDATE xdp_fa_runtime_list
            SET last_updated_by          = FND_GLOBAL.USER_ID,
                last_update_date         = sysdate,
                last_update_login        = FND_GLOBAL.LOGIN_ID,
                status_code              = p_status,
                canceled_by              = p_caller_name,
                cancel_provisioning_date = sysdate
          WHERE fa_instance_id           = p_fa_instance_id;

EXCEPTION
     WHEN OTHERS THEN
          return_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.UPDATE_XDP_FA_INSTANCE_STATUS');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          error_description := FND_MESSAGE.GET;
END UPDATE_XDP_FA_INSTANCE_STATUS;

--
-- Provate API to update status or outbound messages to 'CANCELED' for canceled orders
--

PROCEDURE CANCEL_READY_MSGS(p_order_id       IN NUMBER ,
                            x_error_code    OUT NOCOPY NUMBER,
                            x_error_message OUT NOCOPY VARCHAR2) is

BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_MSGS')) THEN
          dbg_msg := ('Procedure XDP_INTERFACES.CANCEL_READY_MSGS begins.');
	  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'xdp.plsql.XDP_INTERFACES.CANCEL_READY_MSGS', dbg_msg);
	  END IF;
       END IF;
     END IF;

     UPDATE xnp_msgs
        SET msg_status = 'CANCELED',
            last_update_date = SYSDATE
      WHERE order_id   = p_order_id
        AND msg_status = 'READY';

EXCEPTION
     WHEN OTHERS THEN
          x_error_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.CANCEL_READY_MSGS');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          x_error_message := FND_MESSAGE.GET;
END CANCEL_READY_MSGS ;



PROCEDURE Set_Line_Fulfillment_Status(
        p_line_item_id          IN      NUMBER,
        p_fulfillment_status    IN      VARCHAR2 DEFAULT NULL,
        x_RETURN_CODE           OUT NOCOPY NUMBER,
        x_ERROR_DESCRIPTION     OUT NOCOPY VARCHAR2
)
IS
BEGIN
        IF (p_fulfillment_status IS NOT NULL) THEN
                XDP_ENGINE.Set_Line_Param_Value(p_line_item_id,'FULFILLMENT_STATUS',p_fulfillment_status,null);
        END IF;

        x_RETURN_CODE := 0;
        x_ERROR_DESCRIPTION := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
        WHEN OTHERS THEN
        x_return_code := -191266;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Set_Line_Fulfillment_Status');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        x_error_description := FND_MESSAGE.GET;
END Set_Line_Fulfillment_Status;


PROCEDURE Set_Line_Fulfillment_Status(
        p_order_id      IN      NUMBER,
        p_line_number   IN      NUMBER,
        p_fulfillment_status    IN      VARCHAR2 DEFAULT NULL,
        x_RETURN_CODE           OUT NOCOPY NUMBER,
        x_ERROR_DESCRIPTION     OUT NOCOPY VARCHAR2
)
IS
l_line_item_id NUMBER:=NULL;
BEGIN
        BEGIN
           SELECT line_item_id
             INTO l_line_item_id
             FROM xdp_order_line_items xoli
            WHERE xoli.order_id = p_order_id
              AND xoli.line_number = p_line_number;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
               null;
        END;

        IF (p_fulfillment_status IS NOT NULL) THEN
                XDP_ENGINE.Set_Line_Param_Value(l_line_item_id,'FULFILLMENT_STATUS',p_fulfillment_status,null);
        END IF;

        x_RETURN_CODE := 0;
        x_ERROR_DESCRIPTION := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
        WHEN OTHERS THEN
        x_return_code := -191266;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Set_Line_Fulfillment_Status');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        x_error_description := FND_MESSAGE.GET;
END Set_Line_Fulfillment_Status;



PROCEDURE Get_Line_Fulfillment_Status(
        p_line_item_id          IN  NUMBER,
        x_fulfillment_status    OUT NOCOPY VARCHAR2,
        x_RETURN_CODE           OUT NOCOPY NUMBER,
        x_ERROR_DESCRIPTION     OUT NOCOPY VARCHAR2
 ) IS
l_item_line_id NUMBER:=NULL;
BEGIN
                BEGIN
                        x_fulfillment_status := UPPER(XDP_ENGINE.Get_Line_Param_Value(p_line_item_id,'FULFILLMENT_STATUS'))
;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                x_fulfillment_status := UPPER('Success');
                END;

                x_ERROR_DESCRIPTION := FND_API.G_RET_STS_SUCCESS;
        x_return_code := 0;
EXCEPTION
        WHEN OTHERS THEN
        x_return_code := -191266;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Get_Line_Fulfillment_Status');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        x_error_description := FND_MESSAGE.GET;
END Get_Line_Fulfillment_Status;



PROCEDURE Get_Line_Fulfillment_Status(
        p_order_id              IN  NUMBER,
        p_line_number           IN  NUMBER,
        x_fulfillment_status    OUT NOCOPY VARCHAR2,
        x_RETURN_CODE           OUT NOCOPY NUMBER,
        x_ERROR_DESCRIPTION     OUT NOCOPY VARCHAR2
 ) IS
l_line_item_id number;
BEGIN
               BEGIN
               SELECT line_item_id
                 INTO l_line_item_id
                 FROM xdp_order_line_items xoli
                WHERE xoli.order_id = p_order_id
                  AND xoli.line_number = p_line_number;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      null;
               END;

                BEGIN
                        x_fulfillment_status := UPPER(XDP_ENGINE.Get_Line_Param_Value(l_line_item_id,'FULFILLMENT_STATUS'))
;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                x_fulfillment_status := UPPER('Success');
                END;
                x_ERROR_DESCRIPTION := FND_API.G_RET_STS_SUCCESS;
        x_return_code := 0;
EXCEPTION
        WHEN OTHERS THEN
        x_return_code := -191266;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPINTFB.Get_Line_Fulfillment_Status');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        x_error_description := FND_MESSAGE.GET;
END Get_Line_Fulfillment_Status;

BEGIN
-- Package initialization
	Find_XDP_SCHEMA;
END XDP_INTERFACES;

/
