--------------------------------------------------------
--  DDL for Package Body XDP_DRC_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_DRC_UTIL_PVT" AS
/* $Header: XDPDRCPB.pls 120.1 2005/06/15 22:53:15 appldev  $ */


 PROCEDURE Validate_Task(
	p_workitem_id in NUMBER,
	x_workitem_name OUT NOCOPY VARCHAR2,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);

 PROCEDURE Execute_Workitem_Sync(
	p_workitem_instance_id in number,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);

 PROCEDURE Execute_FA_Sync(
	p_fa_instance_id in number,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);

 PROCEDURE Process_DRC_Order(
 	P_WORKITEM_ID 		IN  NUMBER,
 	P_TASK_PARAMETER 	IN XDP_TYPES.ORDER_PARAMETER_LIST,
	x_SDP_ORDER_ID		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2)
  IS

   lv_ret number;
   lv_str varchar2(800);
   lv_line_id number;
   lv_wi_instance_id number;
   lv_wi varchar2(200);
   lv_index binary_integer;
   lv_count number;
   lv_done varchar2(1);
   lv_proc varchar2(80);
 BEGIN

	-- Standard Start of API savepoint
	-- SAVEPOINT	l_order_tag;

-- Start of API body

	--  Initialize API return status to success
	x_return_code := 0;

   Validate_Task(
		p_workitem_id => p_workitem_id,
		x_workitem_name => lv_wi,
      	return_code => x_return_code,
      	error_description =>x_error_description);

-- Modified by SXBANERJ.10/30/2000
 --  IF lv_ret <> 0 Then
   --  return;
 --  END IF;
If x_return_code<>0 THEN
return;
End If;

   select XDP_ORDER_HEADERS_S.NextVal into x_SDP_ORDER_ID
   from dual;

   insert into xdp_order_headers
   (
    order_id,
    external_order_number,
    status_code,
    state,
    date_received,
    provisioning_date,
    actual_provisioning_date,
    order_type,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login
    )
    values
    (
     x_sdp_order_id,
     'DRC-'||TO_CHAR(x_sdp_order_id),
     'IN PROGRESS',
     'RUNNING',
     sysdate,
     sysdate,
     sysdate,
     'DRC',
	 sysdate,
	 FND_GLOBAL.USER_ID,
	 sysdate,
	 FND_GLOBAL.USER_ID,
	 FND_GLOBAL.LOGIN_ID
    );

   insert into xdp_order_line_items
   (
    line_item_id,
    order_id,
    line_number,
    line_item_name,
    provisioning_required_flag,
    status_code,
    state,
    is_package_flag,
    is_virtual_line_flag,
    line_sequence,
    provisioning_date,
	workitem_id,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login

   )
   values
   (
     XDP_ORDER_LINE_ITEMS_S.NextVal,
     x_SDP_ORDER_ID,
     1,
     lv_wi,
     'Y',
     'IN PROGRESS',
     'RUNNING',
     'N',
     'N',
     0,
     sysdate,
	 p_workitem_id,
	 sysdate,
	 FND_GLOBAL.USER_ID,
	 sysdate,
	 FND_GLOBAL.USER_ID,
	 FND_GLOBAL.LOGIN_ID
   )
   returning line_item_id into lv_line_id;

  IF p_task_parameter.count > 0 THEN
    lv_index := p_task_parameter.first;
    For lv_count in 1..p_task_parameter.count loop
      insert into XDP_ORDER_LINEITEM_DETS
      (
        line_item_id,
        line_parameter_name,
        parameter_value,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login
       )
       values
       (
        lv_line_id,
        p_task_parameter(lv_index).parameter_name,
        p_task_parameter(lv_index).parameter_value,
	 	sysdate,
	 	FND_GLOBAL.USER_ID,
	 	sysdate,
	 	FND_GLOBAL.USER_ID,
	 	FND_GLOBAL.LOGIN_ID
       );
       lv_index := p_task_parameter.next(lv_index);
    end loop;
  END IF;

-- Modified by SXSBANERJ 10/30/2000 .Added two more parameters in Add_WI_toLine
--
  lv_wi_instance_id := XDP_OA_UTIL.Add_WI_toLine(
			p_line_item_id => lv_line_id,
			p_workitem_id => p_workitem_id,
                        x_error_code =>x_return_code,
                        x_error_message => x_error_description);
IF x_return_code<>0 then
   return;
END IF;

-- Modified by SXBANERJ.10/30/2000. Changed lv_ret to x_return_code.

     Execute_Workitem_Sync(
	  p_workitem_instance_id => lv_wi_instance_id,
	  return_code => x_return_code,
	  error_description =>x_error_description);

  Begin
    select 'N' into lv_done
    from dual
    where exists( select 'x' from
          XDP_FULFILL_WORKLIST
          where line_item_id = lv_line_id and
          status_code = 'ERROR');
   exception
    when no_data_found then
       lv_done := 'Y';
   end;

   If lv_done = 'Y' then
     update xdp_order_headers
      set status_code = 'COMPLETED',
          state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
      where order_id = x_sdp_order_id;

      update xdp_order_line_items
      set status_code = 'COMPLETED',
          state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
      where line_item_id = lv_line_id;
   Else
     update xdp_order_headers
      set status_code = 'ERROR',
          state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
      where order_id = x_sdp_order_id;

      update xdp_order_line_items
      set status_code = 'ERROR',
          state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
      where line_item_id = lv_line_id;

   END IF;

   /*COMMIT;*/

EXCEPTION
	WHEN OTHERS THEN
	x_return_code := -191266;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPDRCPB');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        x_error_description := FND_MESSAGE.GET;

END Process_DRC_Order;

 /*
    Task validation
 */
PROCEDURE Validate_Task(
	p_workitem_id in number,
	x_workitem_name OUT NOCOPY VARCHAR2,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
IS
  lv_id number;
  lv_exists  varchar2(1) := 'N';
  lv_type varchar2(80);
BEGIN
   return_code := 0;
   begin
   	select
     workitem_name, wi_type_code
	into
	 x_workitem_name,lv_type
   from
    xdp_workitems wim
   where
     wim.workitem_id = p_workitem_id;
   	if lv_type not in ('STATIC','DYNAMIC') then
	 return_code := -191272;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_CONFIG_ERROR');
     FND_MESSAGE.SET_TOKEN('WORK_ITEM_NAME', x_workitem_name);
     error_description := FND_MESSAGE.GET;
       return;
	end if;
   exception
    when no_data_found then
      return_code := -191273;
      FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_WORKITEM_ID');
      error_description := FND_MESSAGE.GET;
      return;
   end;

   return;

EXCEPTION
   WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPDRCPB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
END Validate_Task;

/*
   execute workitem in a synchronous mode
*/

PROCEDURE Execute_Workitem_Sync(
	p_workitem_instance_id in number,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
 IS
   cursor lc_fa_map is
    select
	wfg.fulfillment_action_id,
	wfg.provisioning_seq
    from
      xdp_wi_fa_mapping wfg,
      XDP_FULFILL_WORKLIST fwt
    where
      fwt.workitem_id = wfg.workitem_id and
      fwt.workitem_instance_id = p_workitem_instance_id
    order by wfg.provisioning_seq;

   cursor lc_fa_list is
    select fa_instance_id
    from xdp_fa_runtime_list
    where
      workitem_instance_id = p_workitem_instance_id;

   lv_proc varchar2(80);
   lv_type  varchar2(40);
   lv_fa_id number;
   lv_order_id number;
   lv_line_item_id number;
   lv_wi varchar2(80);
   lv_fa_fail BOOLEAN := FALSE;
   lv_ret number;
   lv_str varchar2(4000);
   -- lv_MessageList XDP_TYPES.MESSAGE_TOKEN_LIST;
   lv_ref_id number := 0;

   x_parameters varchar2(4000);
 BEGIN
   return_code := 0;
   select
	wim.wi_type_code,
	wim.fa_exec_map_proc,
    fwt.order_id,
    wim.workitem_name,
	fwt.line_item_id
   into
   	lv_type,
	lv_proc,
	lv_order_id,
    lv_wi,
	lv_line_item_id
   from
     xdp_workitems wim,
     XDP_FULFILL_WORKLIST fwt
   where
     wim.workitem_id = fwt.workitem_id and
     fwt.workitem_instance_id = p_workitem_instance_id;

   if lv_type = 'STATIC' then
      for lv_fa_rec in lc_fa_map loop
        lv_fa_id := XDP_ENG_UTIL.Add_FA_toWI(
		p_wi_instance_id => p_workitem_instance_id,
		p_fulfillment_action_id => lv_fa_rec.fulfillment_action_id);
      end loop;
   elsif lv_proc is NOT NULL then
     XDP_UTILITIES.CallFAMapProc(
		p_procedure_name => lv_proc,
          	p_order_id => lv_order_id,
          	p_line_item_id => lv_line_item_id,
          	p_wi_instance_id => p_workitem_instance_id,
          	p_return_code => return_code,
          	p_error_description => error_description);
     if return_code <> 0 then
       -- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'ERROR_STRING';
       -- lv_MessageList(1).MESSAGE_TOKEN_VALUE := error_description;

	-- Changed - sacsharm - 11.5.6 ErrorHandling
       -- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_WI_PROV_ERROR',
       --                              p_message_ref_id => lv_ref_id,
       --                              p_message_param_list => lv_MessageList,
       --                              p_appl_name => 'XDP',
       --                              p_sql_code => lv_ret,
       --                              p_sql_desc => lv_str);

	x_parameters := 'ERROR_STRING='||error_description||'#XDP#';
	XDP_ERRORS_PKG.Set_Message(p_object_type => 'WORKITEM',
			     p_object_key => p_workitem_instance_id,
			     p_message_name => 'XDP_WI_PROV_ERROR',
                             p_message_parameters => x_parameters);

     	UPDATE XDP_FULFILL_WORKLIST
     	set status_code = 'ERROR',
	   	  -- error_ref_id = lv_ref_id,
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
     	where
	 workitem_instance_id = p_workitem_instance_id;
     	/*COMMIT;*/

	 return;
     end if;
   else
	return_code := -191272;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_CONFIG_ERROR');
        FND_MESSAGE.SET_TOKEN('WORK_ITEM_NAME', lv_wi);
        error_description := FND_MESSAGE.GET;
        -- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'ERROR_STRING';
        -- lv_MessageList(1).MESSAGE_TOKEN_VALUE := error_description;

	-- Changed - sacsharm - 11.5.6 ErrorHandling
       -- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_WI_PROV_ERROR',
       --                              p_message_ref_id => lv_ref_id,
       --                              p_message_param_list => lv_MessageList,
       --                              p_appl_name => 'XDP',
       --                              p_sql_code => lv_ret,
       --                              p_sql_desc => lv_str);

	x_parameters := 'ERROR_STRING='||error_description||'#XDP#';
	XDP_ERRORS_PKG.Set_Message(p_object_type => 'WORKITEM',
			     p_object_key => p_workitem_instance_id,
			     p_message_name => 'XDP_WI_PROV_ERROR',
                             p_message_parameters => x_parameters);

     	UPDATE XDP_FULFILL_WORKLIST
     	set status_code = 'ERROR',
	   	--	error_ref_id = lv_ref_id,
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
     	where
	 workitem_instance_id = p_workitem_instance_id;
     	/*COMMIT;*/

      return;
   end if;

   for lv_fa_rec2 in lc_fa_list loop
	execute_fa_sync(
		p_fa_instance_id => lv_fa_rec2.fa_instance_id,
		return_code => lv_ret,
		error_description => lv_str);
     if lv_ret <> 0 then
	lv_fa_fail := TRUE;
     end if;
   end loop;

   IF lv_fa_fail = TRUE THEN
	update XDP_FULFILL_WORKLIST
      set status_code = 'ERROR',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
      where workitem_instance_id = p_workitem_instance_id;
   ELSE
	update XDP_FULFILL_WORKLIST
      set status_code = 'COMPLETED',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
      where workitem_instance_id = p_workitem_instance_id;
   END IF;
   /*COMMIT;*/

 EXCEPTION
   WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPDRCPB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
     -- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'ERROR_STRING';
     -- lv_MessageList(1).MESSAGE_TOKEN_VALUE := error_description;

	-- Changed - sacsharm - 11.5.6 ErrorHandling
     -- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_WI_PROV_ERROR',
     --                                p_message_ref_id => lv_ref_id,
     --                                p_message_param_list => lv_MessageList,
     --                                p_appl_name => 'XDP',
     --                                p_sql_code => lv_ret,
     --                                p_sql_desc => lv_str);

	x_parameters := 'ERROR_STRING='||error_description||'#XDP#';
	XDP_ERRORS_PKG.Set_Message(p_object_type => 'WORKITEM',
			     p_object_key => p_workitem_instance_id,
			     p_message_name => 'XDP_WI_PROV_ERROR',
                             p_message_parameters => x_parameters);

     	UPDATE XDP_FULFILL_WORKLIST
     	set status_code = 'ERROR',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
	   -- ,error_ref_id = lv_ref_id
     	where
	 workitem_instance_id = p_workitem_instance_id;
     	/*COMMIT;*/
END Execute_Workitem_Sync;

/*
   execute FA in a synchronous mode
*/
PROCEDURE Execute_FA_Sync(
	p_fa_instance_id in number,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
 IS
   lv_fe_name varchar2(80);
   lv_fe_id  number;
   lv_fa_id number;
   lv_fetype_id number;
   lv_fetype varchar2(80);
   lv_sw_generic varchar2(80);
   lv_adapter varchar2(80);
   lv_proc varchar2(80);
   lv_channel  varchar2(80);
   lv_order_id number;
   lv_wi_instance_id number;
   lv_ret number;
   lv_str varchar2(300);
   -- lv_MessageList XDP_TYPES.MESSAGE_TOKEN_LIST;
   lv_ref_id number := 0;
   cursor lc_channels(l_fe_id number) is
    select channel_name,adapter_status
    from XDP_ADAPTER_REG
    where adapter_status = 'IDLE' and
	    usage_code = 'TEST' and
	    fe_id = l_fe_id;
  lv_found_lock BOOLEAN := FALSE;
  lv_found_channel BOOLEAN := FALSE;
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);
  lv_count number;
  lv_line_item_id number;

   x_parameters varchar2(4000);
 BEGIN
   return_code := 0;
   select
       fe_routing_proc,
       frt.workitem_instance_id,
       fwt.order_id,
       frt.fulfillment_action_id,
  	 fwt.line_item_id
   into
     lv_proc,
	 lv_wi_instance_id,
	 lv_order_id,
	 lv_fa_id,
	 lv_line_item_id
   from XDP_FULFILL_ACTIONS fan,
		xdp_fa_runtime_list frt,
		XDP_FULFILL_WORKLIST fwt
   where
	 fan.fulfillment_action_id = frt.fulfillment_action_id and
	 fwt.workitem_instance_id = frt.workitem_instance_id and
	 frt.fa_instance_id = p_fa_instance_id;

   XDP_UTILITIES.CallFERoutingProc(
		p_procedure_name  => lv_proc,
      	p_order_id	=> lv_order_id,
      	p_line_item_id	=> lv_line_item_id,
       	p_wi_instance_id 	=> lv_wi_instance_id,
       	p_fa_instance_id => p_fa_instance_id,
     	p_fe_name 	=> lv_fe_name,
 		p_return_code => return_code,
 	   	p_error_description  => error_description);

   IF return_code <> 0 THEN
       -- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'ERROR_STRING';
       -- lv_MessageList(1).MESSAGE_TOKEN_VALUE := error_description;

	-- Changed - sacsharm - 11.5.6 ErrorHandling
       -- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_FA_PROV_ERROR',
       --                              p_message_ref_id => lv_ref_id,
       --                              p_message_param_list => lv_MessageList,
       --                              p_appl_name => 'XDP',
       --                              p_sql_code => lv_ret,
       --                              p_sql_desc => lv_str);

	x_parameters := 'ERROR_STRING='||error_description||'#XDP#';
	XDP_ERRORS_PKG.Set_Message(p_object_type => 'FA',
			     p_object_key => p_fa_instance_id,
			     p_message_name => 'XDP_FA_PROV_ERROR',
                             p_message_parameters => x_parameters);

     UPDATE xdp_fa_runtime_list
     set status_code = 'ERROR',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
	   -- , error_ref_id = lv_ref_id
     where
	 fa_instance_id = p_fa_instance_id;
     /*COMMIT;*/
     return;
   ELSE
     XDP_ENGINE.Get_FE_ConfigInfo(
		lv_fe_name,
	      lv_fe_id,
		lv_fetype_id,
		lv_fetype,
		lv_sw_generic,
		lv_adapter);

     select fulfillment_proc
     into   lv_proc
     from xdp_fa_fulfillment_proc ffp,
		xdp_fe_sw_gen_lookup fsp
     where
	 ffp.fulfillment_action_id = lv_fa_id and
	 ffp.fe_sw_gen_lookup_id = fsp.fe_sw_gen_lookup_id and
	 fsp.fetype_id = lv_fetype_id and
       fsp.sw_generic = lv_sw_generic and
       fsp.adapter_type = lv_adapter;


    FOR lv_count IN 1..3 LOOP
     FOR lv_channel_rec IN lc_channels(lv_fe_id) loop
       lv_found_channel := TRUE;
       begin
         select channel_name
         into lv_channel
         from XDP_ADAPTER_REG
         where channel_name = lv_channel_rec.channel_name and
               adapter_status = 'IDLE' and
               usage_code = 'TEST'
         FOR UPDATE NOWAIT;
         lv_found_lock := TRUE;
         lv_found_channel := TRUE;
         goto l_Outer;
      exception
        when resource_busy then
           null;
        when no_data_found then
           lv_found_channel := FALSE;
		goto l_Outer;
      end;
     END LOOP;
     if lv_found_channel = FALSE then
	  goto l_Outer;
     else
       dbms_lock.sleep(10);
     end if;
    END LOOP;

    <<l_Outer>>
    IF lv_found_channel = FALSE THEN
       -- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'FE_NAME';
       -- lv_MessageList(1).MESSAGE_TOKEN_VALUE := lv_fe_name;

	-- Changed - sacsharm - 11.5.6 ErrorHandling
       -- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_NO_TEST_CHANNEL',
       --                              p_message_ref_id => lv_ref_id,
       --                              p_message_param_list => lv_MessageList,
       --                              p_appl_name => 'XDP',
       --                              p_sql_code => lv_ret,
       --                              p_sql_desc => lv_str);

	x_parameters := 'FE_NAME='||lv_fe_name||'#XDP#';
	XDP_ERRORS_PKG.Set_Message(p_object_type => 'FA',
			     p_object_key => p_fa_instance_id,
			     p_message_name => 'XDP_NO_TEST_CHANNEL',
                             p_message_parameters => x_parameters);

      UPDATE xdp_fa_runtime_list
      set status_code = 'ERROR',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
	   -- ,error_ref_id = lv_ref_id
      where
	 fa_instance_id = p_fa_instance_id;
      /*COMMIT;*/
      return;
    ELSIF lv_found_lock = FALSE THEN
       -- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'FE_NAME';
       -- lv_MessageList(1).MESSAGE_TOKEN_VALUE := lv_fe_name;

	-- Changed - sacsharm - 11.5.6 ErrorHandling
       -- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_TEST_CHANNEL_BUSY',
       --                              p_message_ref_id => lv_ref_id,
       --                              p_message_param_list => lv_MessageList,
       --                              p_appl_name => 'XDP',
       --                              p_sql_code => lv_ret,
       --                              p_sql_desc => lv_str);

	x_parameters := 'FE_NAME='||lv_fe_name||'#XDP#';
	XDP_ERRORS_PKG.Set_Message(p_object_type => 'FA',
			     p_object_key => p_fa_instance_id,
			     p_message_name => 'XDP_TEST_CHANNEL_BUSY',
                             p_message_parameters => x_parameters);

      UPDATE xdp_fa_runtime_list
      set status_code = 'ERROR',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
	   -- ,error_ref_id = lv_ref_id
      where
	 fa_instance_id = p_fa_instance_id;
      /*COMMIT;*/
      return;
    END IF;


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
      	p_return_code => return_code,
      	p_error_description => error_description);
    IF return_code = 0 THEN
      UPDATE xdp_fa_runtime_list
      set status_code = 'COMPLETED',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
     where
	 fa_instance_id = p_fa_instance_id;
     /*COMMIT;*/

    ELSE
       -- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'ERROR_STRING';
       -- lv_MessageList(1).MESSAGE_TOKEN_VALUE := error_description;

	-- Changed - sacsharm - 11.5.6 ErrorHandling
       -- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_FA_PROV_ERROR',
       --                              p_message_ref_id => lv_ref_id,
       --                              p_message_param_list => lv_MessageList,
       --                              p_appl_name => 'XDP',
       --                              p_sql_code => lv_ret,
       --                              p_sql_desc => lv_str);

	x_parameters := 'ERROR_STRING='||error_description||'#XDP#';
	XDP_ERRORS_PKG.Set_Message(p_object_type => 'FA',
			     p_object_key => p_fa_instance_id,
			     p_message_name => 'XDP_FA_PROV_ERROR',
                             p_message_parameters => x_parameters);

      UPDATE xdp_fa_runtime_list
      set status_code = 'ERROR',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
	   -- ,error_ref_id = lv_ref_id
      where
	 fa_instance_id = p_fa_instance_id;
      /*COMMIT;*/
    END IF;

   END IF;


 EXCEPTION
   WHEN OTHERS THEN
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPDRCPB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
     -- lv_MessageList(1).MESSAGE_TOKEN_NAME := 'ERROR_STRING';
     -- lv_MessageList(1).MESSAGE_TOKEN_VALUE := SQLERRM;

	-- Changed - sacsharm - 11.5.6 ErrorHandling
     -- XDP_ERRORS_PKG.Set_Message(p_message_name => 'XDP_FA_PROV_ERROR',
     --                                p_message_ref_id => lv_ref_id,
     --                                p_message_param_list => lv_MessageList,
     --                                p_appl_name => 'XDP',
     --                                p_sql_code => lv_ret,
     --                                p_sql_desc => lv_str);

	x_parameters := 'ERROR_STRING='||SQLERRM||'#XDP#';
	XDP_ERRORS_PKG.Set_Message(p_object_type => 'FA',
			     p_object_key => p_fa_instance_id,
			     p_message_name => 'XDP_FA_PROV_ERROR',
                             p_message_parameters => x_parameters);

     UPDATE xdp_fa_runtime_list
     set status_code = 'ERROR',
		  state = 'COMPLETED',
		  last_update_date = sysdate,
		  last_updated_by = FND_GLOBAL.USER_ID,
		  last_update_login = FND_GLOBAL.LOGIN_ID
	   -- ,error_ref_id = lv_ref_id
     where
	 fa_instance_id = p_fa_instance_id;
     /*COMMIT;*/
 END Execute_FA_Sync;



END XDP_DRC_UTIL_PVT;

/
