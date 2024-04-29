--------------------------------------------------------
--  DDL for Package Body XDP_ORDER_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ORDER_SYNC" AS
/* $Header: XDPSORDB.pls 120.1 2005/06/09 00:30:45 appldev  $ */

PROCEDURE Execute_LineItem_Sync(
    p_order_id in NUMBER,
	p_lineItem_id in NUMBER,
	x_return_code OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2);

PROCEDURE Execute_Workitem_Sync(
	p_order_id in NUMBER,
	p_lineitem_id in NUMBER,
	p_workitem_instance_id in NUMBER,
	x_return_code OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2);

PROCEDURE Execute_FA_Sync(
	p_fa_instance_id in NUMBER,
	x_return_code OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2);


PROCEDURE UPDATE_XDP_ORDER_STATUS(p_status   IN VARCHAR2,
                                  p_order_id IN NUMBER) IS
x_progress VARCHAR2(2000);

BEGIN
   IF p_status IN ('SUCCESS_WITH_OVERRIDE','ABORTED','SUCCESS') THEN

     UPDATE xdp_order_headers
        SET status_code       = p_status ,
            completion_date   = sysdate ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE order_id          = p_order_id ;
   ELSE
     UPDATE xdp_order_headers
        SET status_code       = p_status ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE order_id          = p_order_id ;

   END IF ;

EXCEPTION
     WHEN others THEN
          RAISE ;
END UPDATE_XDP_ORDER_STATUS;



PROCEDURE UPDATE_XDP_ORDER_LINE_STATUS(p_status   IN VARCHAR2,
                                       p_line_item_id IN NUMBER)IS
x_progress VARCHAR2(2000);


BEGIN
  IF p_status IN ('IN PROGRESS','ERROR') THEN

     UPDATE xdp_order_line_items
        SET status_code       = p_status ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE line_item_id = p_line_item_id ;
  ELSE
     UPDATE xdp_order_line_items
        SET status_code       = p_status ,
            completion_date   = sysdate ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE line_item_id = p_line_item_id ;
  END IF ;


EXCEPTION
     WHEN others THEN
          RAISE ;
END UPDATE_XDP_ORDER_LINE_STATUS;



PROCEDURE UPDATE_XDP_WORKITEM_STATUS(p_status               IN VARCHAR2,
                                     p_workitem_instance_id IN NUMBER)IS
x_progress VARCHAR2(2000);


BEGIN
  IF p_status IN ('IN PROGRESS','ERROR') THEN

     UPDATE xdp_fulfill_worklist
        SET status_code       = p_status ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE workitem_instance_id = p_workitem_instance_id ;
  ELSE
     UPDATE xdp_fulfill_worklist
        SET status_code       = p_status ,
            completion_date   = sysdate ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE workitem_instance_id = p_workitem_instance_id ;
  END IF ;


EXCEPTION
     WHEN others THEN
          RAISE ;
END UPDATE_XDP_WORKITEM_STATUS;



PROCEDURE UPDATE_XDP_FA_STATUS(p_status         IN VARCHAR2,
                               p_fa_instance_id IN NUMBER)IS
x_progress VARCHAR2(2000);

BEGIN
  IF p_status IN ('IN PROGRESS','ERROR') THEN

     UPDATE xdp_fa_runtime_list
        SET status_code       = p_status ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE fa_instance_id = p_fa_instance_id ;
  ELSE
    UPDATE xdp_fa_runtime_list
        SET status_code       = p_status ,
            completion_date   = sysdate ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE fa_instance_id = p_fa_instance_id ;

  END IF ;


EXCEPTION
     WHEN others THEN
          RAISE ;
END UPDATE_XDP_FA_STATUS;


PROCEDURE Execute_Order_SYNC(
 	p_Order_ID 		IN  NUMBER,
	x_return_code		OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2)
IS
    l_done VARCHAR2(1);
    l_ret_code NUMBER := 0;
    l_ret_str  VARCHAR2(2000);
    e_exec_order_failure EXCEPTION;
BEGIN
	x_return_code := 0;
--
--  Initialize Order
--
    Update_XDP_Order_Status('IN_PROGRESS',p_Order_ID);

-- Execute lineitems in sequence
    FOR c_lineitem IN
        (SELECT line_item_id FROM xdp_order_line_items
            WHERE order_id=p_order_id ORDER BY line_sequence)
    LOOP
        Execute_LineItem_Sync(
	       p_order_id => p_order_id,
	       p_lineitem_id => c_lineitem.line_item_id,
	       x_return_code => x_return_code,
	       x_error_description =>x_error_description);
        IF(x_return_code <> 0) THEN
            RAISE e_exec_order_failure;
        END IF;
    END LOOP;

-- See if any line has error status
    BEGIN
        SELECT 'N' INTO l_done
        FROM dual
        WHERE EXISTS( SELECT 'x' FROM
          xdp_order_line_items
          WHERE order_id = p_order_id AND
          status_code = 'ERROR');
    EXCEPTION
    WHEN no_data_found THEN
       l_done := 'Y';
    END;

    IF l_done = 'Y' THEN
        Update_XDP_Order_Status('SUCCESS',p_Order_ID);
    ELSE
        Update_XDP_Order_Status('ERROR',p_Order_ID);
    END IF;

--  Tell the world we have done the order, failure or success
    XNP_STANDARD.PUBLISH_EVENT(
        p_ORDER_ID => p_order_id,
        p_WORKITEM_INSTANCE_ID => NULL,
        p_FA_INSTANCE_ID => NULL,
        p_EVENT_TYPE => 'XDP_ORDER_DONE',
        p_PARAM_LIST => NULL,
        p_CALLBACK_REF_ID => p_order_id,
        x_error_code => l_ret_code,
        x_error_message => l_ret_str
    );
EXCEPTION
    WHEN e_exec_order_failure THEN
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'XDP_ORDER_SYNC.Execute_Order_SYNC', SQLERRM);
	END IF;
        Update_XDP_Order_Status( 'ERROR',p_Order_ID);

	WHEN OTHERS THEN
	IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'XDP_ORDER_SYNC.Execute_Order_SYNC', SQLERRM);
	END IF;
	    x_return_code := SQLCODE;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_ORDER_SYNC.Execute_Order_SYNC');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        x_error_description := FND_MESSAGE.GET;
        Update_XDP_Order_Status( 'ERROR',p_Order_ID);

END Execute_Order_SYNC;

/*
   execute lineitem in a synchronous mode
*/
PROCEDURE Execute_LineItem_Sync(
    p_order_id in NUMBER,
    p_lineitem_id in NUMBER,
    x_return_code OUT NOCOPY NUMBER,
    x_error_description OUT NOCOPY VARCHAR2)
IS
    lv_done VARCHAR2(1);
    lv_ib_error_code NUMBER;
    e_exec_line_failure EXCEPTION;
    lv_ib_err_desc varchar2(2000);

BEGIN
    x_return_code := 0;

-- Initialize LineItem for processing
    UPDATE_XDP_ORDER_LINE_STATUS('IN PROGRESS',p_lineItem_id);


-- Execute all workitems in sequence
    FOR c_workitem_instance in
        (SELECT workitem_instance_id FROM xdp_fulfill_worklist
            WHERE line_item_id=p_lineItem_id order by wi_sequence)
    LOOP
        Execute_Workitem_Sync(
            p_order_id => p_order_id,
            p_lineitem_id =>p_lineitem_id,
            p_workitem_instance_id => c_workitem_instance.workitem_instance_id,
            x_return_code => x_return_code,
            x_error_description =>x_error_description);

        IF (x_return_code <> 0 ) THEN
	    IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_LineItem_Sync', 'Execute_Workitem_Sync '||'returns error');
	    END IF;
            RAISE e_exec_line_failure;
        END IF;

    END LOOP;

-- Check if any workitem was in error status
    BEGIN
        SELECT 'N' INTO lv_done FROM dual
        WHERE EXISTS( SELECT 'x' FROM
            XDP_FULFILL_WORKLIST
            WHERE line_item_id = p_lineItem_id AND
                status_code = 'ERROR');
    EXCEPTION
        WHEN no_data_found THEN
            lv_done := 'Y';
    END;

    IF lv_done = 'Y' THEN
        UPDATE_XDP_ORDER_LINE_STATUS('SUCCESS',p_lineItem_id);
    ELSE
        UPDATE_XDP_ORDER_LINE_STATUS('ERROR',p_lineItem_id);
    END IF;
    XDP_INSTALL_BASE.UPDATE_IB(p_order_id,p_lineItem_id,lv_ib_error_code,lv_ib_err_desc);
EXCEPTION
    WHEN e_exec_line_failure THEN
        UPDATE_XDP_ORDER_LINE_STATUS('ERROR',p_lineItem_id);
    WHEN OTHERS THEN
	IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_LineItem_Sync', 'unexpected exception occurred.');
	END IF;
        x_return_code := -191266;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_ORDER_SYNC.Execute_LineItem_Sync');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        x_error_description := FND_MESSAGE.GET;
        UPDATE_XDP_ORDER_LINE_STATUS('ERROR',p_lineItem_id);
END Execute_LineItem_Sync;

PROCEDURE Execute_Workitem_Sync(
    p_order_id in NUMBER,
    p_lineitem_id in NUMBER,
    p_workitem_instance_id in NUMBER,
    x_return_code OUT NOCOPY NUMBER,
    x_error_description OUT NOCOPY VARCHAR2)
IS
    CURSOR lc_fa_map is
        SELECT
            wfg.fulfillment_action_id,
            wfg.provisioning_seq
        FROM
            xdp_wi_fa_mapping wfg,
            XDP_FULFILL_WORKLIST fwt
        WHERE
            fwt.workitem_id = wfg.workitem_id and
            fwt.workitem_instance_id = p_workitem_instance_id
        ORDER BY wfg.provisioning_seq;

    CURSOR lc_fa_list IS
        SELECT fa_instance_id
        FROM xdp_fa_runtime_list
        WHERE
            workitem_instance_id = p_workitem_instance_id
        ORDER BY provisioning_sequence;

    lv_proc VARCHAR2(80);
    lv_type  VARCHAR2(40);
    lv_wi VARCHAR2(80);
    lv_workitem_id NUMBER;

    lv_fa_id NUMBER;
    lv_fa_fail BOOLEAN := FALSE;

    lv_user_item_type varchar2(10);
    lv_user_item_key varchar2(240);
    lv_user_item_key_prefix varchar2(240);
    lv_user_WI_proc varchar2(40);
    lv_user_WF_process varchar2(40);

    x_parameters VARCHAR2(4000);

    e_exec_wi_failure EXCEPTION;
    l_status_code VARCHAR2(32);
BEGIN
    x_return_code := 0;

-- Initialize worktime
    UPDATE_XDP_WORKITEM_STATUS('IN PROGRESS',p_workitem_instance_id);

-- Evaluate procedure if there is one for this workitem
    xdp_engine.EvaluateWIParamsOnStart(p_workitem_instance_id);

-- Get workitem configuration data
    SELECT
        wim.wi_type_code,
        wim.fa_exec_map_proc,
        wim.workitem_name,
        wim.workitem_id,
        wim.user_wf_item_type,
        wim.user_wf_item_key_prefix,
        wim.user_wf_process_name,
        wim.wf_exec_proc
    INTO
   	    lv_type,
	    lv_proc,
        lv_wi,
        lv_workitem_id,
        lv_user_item_type,
        lv_user_item_key_prefix,
        lv_user_wf_process,
        lv_user_wi_proc
    FROM
        xdp_workitems wim,
        xdp_fulfill_worklist fwt
    WHERE
       wim.workitem_id = fwt.workitem_id AND
       fwt.workitem_instance_id = p_workitem_instance_id;

    IF lv_type = 'STATIC' THEN
        -- populate xdp_fa_runtime_list
        FOR lv_fa_rec IN lc_fa_map LOOP
           lv_fa_id := XDP_ENG_UTIL.Add_FA_toWI(
    		   p_wi_instance_id => p_workitem_instance_id,
	       	   p_fulfillment_action_id => lv_fa_rec.fulfillment_action_id);
        END LOOP;
    ELSIF lv_type = 'DYNAMIC' then
        -- populate xdp_fa_runtime_list with its dynamic mapping procedure
        IF lv_proc IS NOT NULL THEN
            XDP_UTILITIES.CallFAMapProc(
	       	    p_procedure_name => lv_proc,
            	p_order_id => p_order_id,
                p_line_item_id => p_lineitem_id,
                p_wi_instance_id => p_workitem_instance_id,
                p_return_code => x_return_code,
                p_error_description => x_error_description);

            IF x_return_code <> 0 THEN
		IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', 'Error returned '
                        ||x_return_code
                        ||' from XDP_ERRORS_PKG.Set_Message');
		END IF;
                RAISE e_exec_wi_failure;
            END IF;
        ELSE
            FND_MESSAGE.SET_NAME('XDP', 'XDP_FA_EXEC_MAP_PROC_NOT_EXIST');
            x_error_description := FND_MESSAGE.GET;
            x_return_code := -191156;
	    IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', x_error_description);
	    END IF;
            RAISE e_exec_wi_failure;
        END IF;
    ELSIF lv_type = 'WORKFLOW_PROC' THEN
        IF lv_user_wi_proc is null THEN
            FND_MESSAGE.SET_NAME('XDP', 'XDP_WF_PROC_NOT_EXIST');
            x_error_description := FND_MESSAGE.GET;
            x_return_code := -191266;
	    IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', x_error_description);
	    END IF;
            RAISE e_exec_wi_failure;
        END IF;

        -- Call user defined workflow procedure, which should call wf createprocess
        -- and return process_name, item_type and item_name.

        XDP_UTILITIES.CallWIWorkflowProc (
            P_PROCEDURE_NAME => lv_user_wi_proc,
            P_ORDER_ID => p_order_id,
            P_LINE_ITEM_ID => p_lineitem_id,
            P_WI_INSTANCE_ID => p_workitem_instance_id,
            P_WF_ITEM_TYPE => lv_user_item_type,
            P_WF_ITEM_KEY => lv_user_item_key,
            P_WF_PROCESS_NAME => lv_user_wf_process,
            P_RETURN_CODE => x_return_code,
            P_ERROR_DESCRIPTION => x_error_description);

        IF x_return_code <> 0 THEN
	    IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', 'Error '
               ||x_return_code
               ||' returned from XDP_UTILITIES.CallWIWorkflowProc');
	    END IF;
             RAISE e_exec_wi_failure;
        END IF;

        -- in case of the process does not have line_item_id as attribute
        XDPCORE.CheckNAddItemAttrNumber (
            itemtype => lv_user_item_type,
            itemkey => lv_user_item_key,
            AttrName => 'LINE_ITEM_ID',
            AttrValue => p_lineitem_id,
            ErrCode => x_return_code,
            ErrStr => x_error_description);

        IF x_return_code <> 0 THEN
	   IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', 'Error '
              ||x_return_code
              ||' returned from XDPCORE.CheckNAddItemAttrNumber - LINE_ITEM_ID');
	   END IF;
           RAISE e_exec_wi_failure;
        END IF;

        -- in case of the process does not have WORKITEM_INSTANCE_ID as attribute
        XDPCORE.CheckNAddItemAttrNumber (
            itemtype => lv_user_item_type,
            itemkey => lv_user_item_key,
            AttrName => 'WORKITEM_INSTANCE_ID',
            AttrValue => p_workitem_instance_id,
            ErrCode => x_return_code,
            ErrStr => x_error_description);

        IF x_return_code <> 0 THEN
	   IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', 'Error '
               ||x_return_code
               ||' returned from XDPCORE.CheckNAddItemAttrNumber - WORKITEM_INSTANCE_ID');
	   END IF;
           RAISE e_exec_wi_failure;
        END IF;

        -- in case of the process does not have ORDER_ID as attribute
        XDPCORE.CheckNAddItemAttrNumber (
            itemtype => lv_user_item_type,
            itemkey => lv_user_item_key,
            AttrName => 'ORDER_ID',
            AttrValue => p_order_id,
            ErrCode => x_return_code,
            ErrStr => x_error_description);

        IF x_return_code <> 0 THEN
	  IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', 'Error '
             ||x_return_code
             ||' returned from XDPCORE.CheckNAddItemAttrNumber - ORDER_ID');
	  END IF;
          RAISE e_exec_wi_failure;
        END IF;

        UPDATE XDP_FULFILL_WORKLIST
            SET WF_ITEM_TYPE = lv_user_item_type,
                WF_ITEM_KEY = lv_user_item_key,
                LAST_UPDATE_DATE = SYSDATE, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
           WHERE WORKITEM_INSTANCE_ID = p_workitem_instance_id;

        --Start the process
        WF_ENGINE.StartProcess(lv_user_item_type,lv_user_item_key);
        -- bypass the execution of FA List
        GOTO UpdateStatus;
    ELSIF lv_type = 'WORKFLOW' THEN
        IF  (lv_user_item_type IS NULL) OR
            (lv_user_wf_process IS NULL) THEN

            FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_ORDER_SYNC.Execute_Workitem_Sync');
            x_error_description :=
                'XDP_ORDER_SYNC.execute_workitem_sync. process_name or item_type not specified for a '
                || 'defined Workflow of workitem: '
                || lv_workitem_id ;

            FND_MESSAGE.SET_TOKEN('ERROR_STRING', x_error_description);
            x_error_description := FND_MESSAGE.GET;
            x_return_code := -191266;


	  IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', 'Some required fields for WORKFLOW are null.');
	  END IF;
--            dbms_output.put_line('XDP_ORDER_SYNC.Execute_Workitem_Sync 8' || x_return_code);
          RAISE e_exec_wi_failure;
        END IF;

        -- Create user defined workflow process
        XDPCORE.CreateAndAddAttrNum(
            itemtype => lv_user_item_type,
            itemkey => wf_engine.eng_synch,
            processname => lv_user_wf_process,
            parentitemtype => NULL,
            parentitemkey => NULL,
            OrderID => p_order_id,
            LineitemID => p_lineitem_id,
            WIInstanceID => p_workitem_instance_id,
            FAInstanceID => null);

        update XDP_FULFILL_WORKLIST
            set WF_ITEM_TYPE = lv_user_item_type,
                WF_ITEM_KEY = lv_user_item_key,
                LAST_UPDATE_DATE = sysdate,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
            where
                WORKITEM_INSTANCE_ID = p_workitem_instance_id;
        -- Start the process
		WF_ENGINE.StartProcess(lv_user_item_type,wf_engine.eng_synch);
        -- bypass the execution of FA List
        GOTO UpdateStatus;
    ELSE
        FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_CONFIG_ERROR');
        FND_MESSAGE.SET_TOKEN('WORK_ITEM_NAME', lv_wi);
        x_error_description := FND_MESSAGE.GET;
        x_return_code := 191272;
	IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync ', x_error_description);
	END IF;
--        dbms_output.put_line('XDP_ORDER_SYNC.Execute_Workitem_Sync 9' || x_return_code);
        RAISE e_exec_wi_failure;
    END IF;

-- Execute all FAs
    FOR lv_fa_rec2 IN lc_fa_list LOOP
    	execute_fa_sync(
	      	p_fa_instance_id => lv_fa_rec2.fa_instance_id,
	       	x_return_code => x_return_code,
    		x_error_description => x_error_description);
        IF x_return_code <> 0 THEN
            -- Continue even one FA fails,
            -- but the status for this workitem will be marked as error
--            dbms_output.put_line('XDP_ORDER_SYNC.Execute_Workitem_Sync 10 ' || x_return_code);
            RAISE e_exec_wi_failure;
            NULL;
        END IF;
    END LOOP;

<<UpdateStatus>>
    IF (XDPSTATUS.IS_WI_IN_ERROR(p_workitem_instance_id)) THEN
        x_return_code := 0;
        l_status_code := 'ERROR';
    ELSE
        x_return_code := 0;
        l_status_code :='SUCCESS';
    END IF;

    UPDATE_XDP_WORKITEM_STATUS(l_status_code,p_workitem_instance_id);

EXCEPTION
    WHEN e_exec_wi_failure THEN
--        dbms_output.put_line('XDP_ORDER_SYNC.Execute_Workitem_Sync ' || x_return_code);
   	    x_parameters := 'ERROR_STRING='||x_error_description||'#XDP#';
	    XDP_ERRORS_PKG.Set_Message(
            p_object_type => 'WORKITEM',
            p_object_key => p_workitem_instance_id,
            p_message_name => 'XDP_WI_PROV_ERROR',
            p_message_parameters => x_parameters);

        UPDATE_XDP_WORKITEM_STATUS('ERROR',p_workitem_instance_id);

    WHEN OTHERS THEN
	IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_WI_Sync', 'Unexpected exception '||sqlcode);
	END IF;
        x_return_code := sqlcode;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_ORDER_SYNC.Execute_Workitem_Sync');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        x_error_description := FND_MESSAGE.GET ||' - '||lv_wi;

        x_parameters := 'ERROR_STRING='||x_error_description||'#XDP#';
        XDP_ERRORS_PKG.Set_Message(p_object_type => 'WORKITEM',
            p_object_key => p_workitem_instance_id,
            p_message_name => 'XDP_WI_PROV_ERROR',
            p_message_parameters => x_parameters);

        UPDATE_XDP_WORKITEM_STATUS('ERROR',p_workitem_instance_id);

END Execute_Workitem_Sync;
/*
   execute FA in a synchronous mode
*/
PROCEDURE Execute_FA_Sync(
	p_fa_instance_id IN NUMBER,
	x_return_code OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2)
IS
    lv_fe_name VARCHAR2(80);
    lv_fe_id  NUMBER;
    lv_fa_id NUMBER;
    lv_fetype_id NUMBER;
    lv_fetype VARCHAR2(80);
    lv_sw_generic VARCHAR2(80);
    lv_adapter VARCHAR2(80);
    lv_proc VARCHAR2(80);
    lv_channel  VARCHAR2(80);
    lv_order_id NUMBER;
    lv_wi_instance_id NUMBER;
    lv_ret NUMBER;
    lv_str VARCHAR2(300);
    lv_ref_id NUMBER := 0;

    lv_locked_flag varchar2(1) := 'N';

    CURSOR lc_channels(l_fe_id NUMBER) IS
        SELECT channel_name,adapter_status
        FROM XDP_ADAPTER_REG
        WHERE adapter_status = 'IDLE' AND
	    usage_code = 'TEST' AND
	    fe_id = l_fe_id;

    lv_line_item_id NUMBER;

    e_exec_fa_failure EXCEPTION;
    x_parameters VARCHAR2(4000);

BEGIN
    x_return_code := 0;

-- Initialization
    UPDATE_XDP_FA_STATUS('IN PROGRESS',p_fa_instance_id);

-- Get the configuration data for the fa
    SELECT
         fe_routing_proc,
         frt.workitem_instance_id,
         fwt.order_id,
         frt.fulfillment_action_id,
  	     fwt.line_item_id
    INTO
        lv_proc,
        lv_wi_instance_id,
	    lv_order_id,
    	lv_fa_id,
	    lv_line_item_id
    FROM XDP_FULFILL_ACTIONS fan,
		xdp_fa_runtime_list frt,
		XDP_FULFILL_WORKLIST fwt
    WHERE
	    fan.fulfillment_action_id = frt.fulfillment_action_id and
	    fwt.workitem_instance_id = frt.workitem_instance_id and
	    frt.fa_instance_id = p_fa_instance_id;

-- Get routing procedure, which will be used to get FE

    XDP_UTILITIES.CallFERoutingProc(
        p_procedure_name  => lv_proc,
        p_order_id	=> lv_order_id,
        p_line_item_id	=> lv_line_item_id,
        p_wi_instance_id 	=> lv_wi_instance_id,
        p_fa_instance_id => p_fa_instance_id,
        p_fe_name 	=> lv_fe_name,
        p_return_code => x_return_code,
        p_error_description  => x_error_description);

    IF x_return_code <> 0 THEN
	IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_FA_Sync', 'Error '
	  ||x_return_code
	  ||' returned when call XDP_UTILITIES.CallFERoutingProc');
	END IF;
        RAISE e_exec_fa_failure;
    ELSE
        -- get configuration for the FE
        XDP_ENGINE.Get_FE_ConfigInfo(
                lv_fe_name,
                lv_fe_id,
                lv_fetype_id,
                lv_fetype,
                lv_sw_generic,
                lv_adapter);

        SELECT fulfillment_proc
        INTO
                lv_proc
        FROM xdp_fa_fulfillment_proc ffp,
                xdp_fe_sw_gen_lookup fsp
        WHERE
            ffp.fulfillment_action_id = lv_fa_id AND
            ffp.fe_sw_gen_lookup_id = fsp.fe_sw_gen_lookup_id AND
            fsp.fetype_id = lv_fetype_id AND
            fsp.sw_generic = lv_sw_generic AND
            fsp.adapter_type = lv_adapter;

        -- Try to obtain an available channel,
        XDPCORE_FA.SearchAndLockChannel(lv_fe_id,'TEST','N',
		XDP_ADAPTER.pv_statusRunning,lv_locked_flag,lv_channel);
        IF lv_locked_flag = 'N' THEN --COD
            -- if fails, try an adapter that can be started on demand
            XDPCORE_FA.SearchAndLockChannel(
		lv_fe_id,
		'TEST',
		'Y',
		XDP_ADAPTER.pv_statusDisconnected,
		lv_locked_flag,
		lv_channel);

            IF(lv_locked_flag = 'Y') THEN
                -- if success, the connect the adapter, and lock the channel
                lv_locked_flag := XDPCORE_FA.ConnectOnDemand(lv_channel,x_return_code,x_error_description);
            END IF;
        END IF;

        IF lv_locked_flag = 'N' THEN -- try a different type of adapter
            XDPCORE_FA.SearchAndLockChannel(lv_fe_id,'NORMAL','N',
			XDP_ADAPTER.pv_statusRunning,lv_locked_flag,lv_channel);
            IF lv_locked_flag = 'N' THEN --COD
            -- if fails, try an adapter that can be started on demand
                XDPCORE_FA.SearchAndLockChannel(lv_fe_id,
			'NORMAL',
			'Y',
			XDP_ADAPTER.pv_statusDisconnected,
			lv_locked_flag,lv_channel);
                IF(lv_locked_flag = 'Y') THEN
                -- if success, the connect the adapter, and lock the channel
                    lv_locked_flag := XDPCORE_FA.ConnectOnDemand(lv_channel,x_return_code,x_error_description);
                END IF;
            END IF;
        END IF;

        IF lv_locked_flag = 'N' THEN
            -- if still fails, get out
            x_return_code := -191142;
            FND_MESSAGE.SET_NAME('XDP', 'XDP_CANNOT_START_ADAPTER');
            FND_MESSAGE.SET_TOKEN('CHANNEL_NAME', lv_channel);
            FND_MESSAGE.SET_TOKEN('ADAPTER_NAME', lv_adapter);
            FND_MESSAGE.SET_TOKEN('ERROR_STRING', x_error_description);
            FND_MESSAGE.SET_TOKEN('FE_NAME', lv_fe_name);
            x_error_description := FND_MESSAGE.GET;

	    IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'XDP_ORDER_SYNC.Execute_FA_Sync',
                   x_error_description);
	        END IF;
            RAISE e_exec_fa_failure;
        END IF;

        -- Execute the fulfillment procedure with the given channel
        XDP_UTILITIES.CallFulfillmentProc(
            p_procedure_name => lv_proc,
            p_order_id => lv_order_id,
            p_line_item_id => lv_line_item_id,
            p_wi_instance_id => lv_wi_instance_id,
            p_fa_instance_id => p_fa_instance_id,
            p_channel_name	=> lv_channel,
            p_fe_name	=>lv_fe_name,
            p_fa_item_type => NULL,
            p_fa_item_key  => NULL,
            p_return_code => x_return_code,
            p_error_description => x_error_description);

        -- Release the channel
        XDPCORE_FA.HandOverChannel (
            lv_channel,
            lv_fe_id,
            'TEST',
            'FA',
            lv_ret,
            lv_str);

        IF x_return_code <> 0 THEN
	  IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_FA_Sync', 'Error '
            ||x_error_description
            ||' returned when call XDP_UTILITIES.CallFulfillmentProc.');
	  END IF;
            RAISE e_exec_fa_failure;
        ELSE
        -- Set FA Status
            UPDATE_XDP_FA_STATUS('SUCCESS',p_fa_instance_id);
        END IF;
    END IF;
EXCEPTION
    WHEN e_exec_fa_failure THEN
        x_parameters := 'ERROR_STRING='||x_error_description||'#XDP#';
        x_error_description := x_error_description ||' - '||lv_fe_name;

        XDP_ERRORS_PKG.Set_Message(
            p_object_type => 'FA',
            p_object_key => p_fa_instance_id,
            p_message_name => 'XDP_FA_PROV_ERROR',
            p_message_parameters => x_parameters);

        UPDATE_XDP_FA_STATUS('ERROR',p_fa_instance_id);

    WHEN OTHERS THEN
	IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'XDP_ORDER_SYNC.Execute_FA_Sync', 'Unexpected exception '||SQLCODE);
	  END IF;
        x_return_code := SQLCODE;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDP_ORDER_SYNC.Execute_FA_Sync');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);

        x_error_description := FND_MESSAGE.GET ||' - '||lv_fe_name;

        x_parameters := 'ERROR_STRING='||SQLERRM||'#XDP#';
        XDP_ERRORS_PKG.Set_Message(
            p_object_type => 'FA',
            p_object_key => p_fa_instance_id,
            p_message_name => 'XDP_FA_PROV_ERROR',
            p_message_parameters => x_parameters);

        UPDATE_XDP_FA_STATUS('ERROR',p_fa_instance_id);

END Execute_FA_Sync;

End XDP_ORDER_SYNC;


/
