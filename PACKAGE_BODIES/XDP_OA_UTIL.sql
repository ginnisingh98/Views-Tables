--------------------------------------------------------
--  DDL for Package Body XDP_OA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_OA_UTIL" AS
/* $Header: XDPOAUTB.pls 120.1 2005/06/16 01:42:30 appldev  $ */

-- PL/SQL Specification
-- Global variables

g_Validation_Procedure VARCHAR2(80);
g_Validation_Enabled_Flag VARCHAR2(1);
g_order_id  NUMBER;
--
-- Private API which will try to obtain a lock on the order Q
--
 PROCEDURE LOCK_ORDERQ(
	p_sdp_order_id IN NUMBER,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2);

--
-- Find and replace order header attribute on the where block
--
PROCEDURE Find_Replace_Ord_Header(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2);

--
-- Find and replace order Line attribute on the where block
--
PROCEDURE Find_Replace_Line(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2);

--
-- Find and replace order Line parameter on the where block
--
PROCEDURE Find_Replace_Line_Param(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2);

--
-- Find and replace workitem attribute on the where block
--
PROCEDURE Find_Replace_WI(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2);

--
-- Find and replace workitem parameter on the where block
--
PROCEDURE Find_Replace_WI_Param(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2);



 /*****************************************
   This function will add a workitem to
   an order line. It will also create the
   workitem parameter list in the database
   base on the order line information.
   The workitem_instance_id will return at
   the end of the function call.

<CHANGE>
   Date: 03-Feb-2005  Author: DPUTHIYE. Bug#: 4083708
   After this fix, the parameters p_workitem_name and p_workitem_version
     will be mandatory (as these are mandatory in the WI definition).
     Earlier SFM used to figure out the version, if only a single version
     of the WI existed.
     The following changes have been made in code.

     1) The fix is marked between <FIX Bug=4083708> and </FIX Bug=4083708>
     2) The block marked between <REPLACED> and </REPLACED> has
        be rewritten and replaced with the code below
     3) The procedure now checks if WI_NAME with VERSION exists.
        cursor lc_wi is obsolete since this fix.
     4) The following messages will no longer be thrown by this API
        XDP_CANNOT_DETERMINE_WI_VER - The message name in its definition has a typo.
        XDP_UNKNOWN_WI - Replaced by a more explicit message for user.
     5) Two new, more explicit messages are added to SFM
        a) XDP_WI_NAME_VER_NOT_EXIST - Workitem <WORK_ITEM_NAME> with version <WI_VERSION> does not exist.
        b) XDP_WI_NAME_VER_NOT_GIVEN - Workitem Name and Workitem Version are mandatory in the call to Add_WI_toLine.
     6) A new block has been introduced around the SELECT that fetches the WI details, catching NO_DATA_FOUND.
        Exception OTHERS will be caught by the calling API (overloaded public API Add_WI_To_Line).
</CHANGE>
 ******************************************/
 Function Add_WI_toLine(
	p_line_item_id IN NUMBER,
	p_workitem_name IN VARCHAR2,
--	p_workitem_version IN VARCHAR2 DEFAULT NULL,			--defaulting removed to fix bug 4083708
	p_workitem_version IN VARCHAR2,
	p_provisioning_date IN Date DEFAULT null,
	p_priority IN number Default 100,
	p_provisioning_seq IN Number Default 0,
	p_due_date IN Date Default NULL,
	p_customer_required_date IN DATE Default NULL,
	p_oa_added_flag  IN VARCHAR2 DEFAULT 'Y')
   RETURN NUMBER
  IS
    lv_instance_id  NUMBER;
    lv_wi_id  NUMBER;
    lv_order_id number;
    lv_prov_date date;
    lv_line_number number;

--<FIX Bug=4083708>
    -- Date: 13-Jan-2005  Author: DPUTHIYE. Bug#: 4083708
    -- Change: Modified the cursor lc_wi_param.
    -- The cursor now fetches the default_value of the param from xdp_wi_parameters
    -- and defaults parameter_value with it if parameter_value is null.
    CURSOR lc_wi_param(l_wi_id NUMBER,l_line_id number) IS
      select 	 wpr2.parameter_name,
    --	 	 parameter_value,
		 nvl(parameter_value, wpr2.default_value) parameter_value, --modified to fix 4083708
		 parameter_reference_value,
		 wpr2.evaluation_seq
      from (select parameter_name,
                   default_value,					-- added to fix 4083708
                   evaluation_seq
            from xdp_wi_parameters wpr
	    where  wpr.workitem_id = l_wi_id
		  ) wpr2,
		 XDP_ORDER_LINEITEM_DETS oll
	where wpr2.parameter_name = oll.line_parameter_name(+) and
		 oll.line_item_id(+) = l_line_id
	order by wpr2.evaluation_seq;

    -- Date: 03-Feb-2005  Author: DPUTHIYE. Bug#: 4083708
    -- Change: obsoleted the following cursor.
    -- The singleton SELECT for workitem details validates the WI and Ver better.
    /*	CURSOR lc_wi IS
	 select workitem_id
	 from xdp_workitems
	 where workitem_name = p_workitem_name;
    */
  BEGIN

    select XDP_FULFILL_WORKLIST_S.nextval
    into lv_instance_id
    from dual;

   select order_id,
          line_number
     into lv_order_id,
          lv_line_number
     from xdp_order_line_items
    where line_item_id = p_line_item_id;

   g_order_id:= lv_order_id;

--<REPLACED_CODE>
--   IF p_workitem_version IS NOT NULL THEN
--     select workitem_id,
--            workitem_name,
--            Validation_procedure,
--            validation_enabled_flag
--       into lv_wi_id,
--            g_Workitem_Name,
--            g_Validation_Procedure,
--            g_Validation_Enabled_Flag
--       from xdp_workitems
--      where workitem_name = p_workitem_name and
-- 	    version = p_workitem_version;
--   ELSE
--      lv_wi_id :=  NULL;
--	FOR lv_wi_rec in lc_wi LOOP
--        IF lv_wi_id IS NOT NULL THEN
--		FND_MESSAGE.SET_NAME('XDP', 'XDP_CANNOT_DETERMINE_WI_VER');
--		FND_MESSAGE.SET_TOKEN('WORK_ITEM_NAME', p_workitem_name);
--		APP_EXCEPTION.RAISE_EXCEPTION;
--		exit;
--	  END IF;
--	  lv_wi_id :=  lv_wi_rec.workitem_id;
--	END LOOP;
--	IF lv_wi_id IS NULL THEN
--      FND_MESSAGE.SET_NAME('XDP', 'XDP_UNKNOWN_WI');
--	FND_MESSAGE.SET_TOKEN('WORK_ITEM_NAME', p_workitem_name);
--	APP_EXCEPTION.RAISE_EXCEPTION;
--	END IF;
--   END IF;
--</REPLACED_CODE>

   --see that WI Name and WI Version are supplied to the API.
   IF (p_workitem_name IS NULL) OR
      (p_workitem_version IS NULL) THEN
      FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_NAME_VER_NOT_GIVEN');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   --WI Name and WI version are given. Get the WI details.
   BEGIN
       SELECT workitem_id,
              workitem_name,
              Validation_procedure,
              validation_enabled_flag
       INTO   lv_wi_id,
              g_Workitem_Name,
              g_Validation_Procedure,
              g_Validation_Enabled_Flag
       FROM xdp_workitems
       WHERE workitem_name = p_workitem_name
       AND version = p_workitem_version;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_NAME_VER_NOT_EXIST');
		 FND_MESSAGE.SET_TOKEN('WORK_ITEM_NAME', p_workitem_name);
		 FND_MESSAGE.SET_TOKEN('WI_VERSION', p_workitem_version);
		 APP_EXCEPTION.RAISE_EXCEPTION;
       -- OTHERS will be caught by the calling API; Add_WI_toLine, the public version.
    END;
--</FIX Bug=4083708>

   if p_provisioning_date is not null then
     lv_prov_date :=  p_provisioning_date;
   else
     select provisioning_date into lv_prov_date
     from xdp_order_line_items
     where line_item_id = p_line_item_id;
   end if;

   insert into XDP_FULFILL_WORKLIST
   (workitem_instance_id,
    line_item_id,
    order_id,
    line_number,
    workitem_id,
    status_code,
    provisioning_date,
    priority,
    wi_sequence,
    due_date,
    customer_required_date,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
   )
   values
    (lv_instance_id,
     p_line_item_id,
     lv_order_id,
     lv_line_number,
     lv_wi_id,
     'STANDBY',
     lv_prov_date,
     p_priority,
     p_provisioning_seq ,
     p_due_date,
     p_customer_required_date,
     FND_GLOBAL.USER_ID,
     sysdate,
     FND_GLOBAL.USER_ID,
     sysdate,
     FND_GLOBAL.LOGIN_ID
    );


   FOR lv_param_rec in lc_wi_param(lv_wi_id,p_line_item_id) LOOP
	XDP_ENGINE.Set_Workitem_Param_value(
		p_wi_instance_id => lv_instance_id,
		p_parameter_name => lv_param_rec.parameter_name,
		p_parameter_value => lv_param_rec.parameter_value,
		p_parameter_reference_value =>
			lv_param_rec.parameter_reference_value,
		p_evaluation_required => TRUE);
   END LOOP;

    return lv_instance_id;

  END Add_WI_toLine;


 /*****************************************
   Overload function.
   This function will add a workitem to
   an order line. It will also create the
   workitem parameter list in the database
   base on the order line information.
   The workitem_instance_id will return at
   the end of the function call.
 ******************************************/
 Function Add_WI_toLine(
	p_line_item_id IN NUMBER,
	p_workitem_id IN Number,
	p_provisioning_date IN Date default null,
	p_priority IN number Default 100,
	p_provisioning_seq IN Number Default 0,
	p_due_date IN Date Default NULL,
	p_customer_required_date IN DATE Default NULL,
	p_oa_added_flag  IN VARCHAR2 DEFAULT 'Y')
 RETURN NUMBER
 IS
    lv_instance_id  NUMBER;
    lv_wi_id  NUMBER;
    lv_order_id number;
    lv_line_number number;
    lv_prov_date date;
    CURSOR lc_wi_param(l_wi_id NUMBER,l_line_id number) IS
      select 	 wpr2.parameter_name,
		 parameter_value,
		 parameter_reference_value,
		 wpr2.evaluation_seq
      from
		 (select parameter_name,
                         evaluation_seq
		  from xdp_wi_parameters wpr
		  where wpr.workitem_id = l_wi_id --and
			) wpr2,
		 XDP_ORDER_LINEITEM_DETS oll
	where
		 wpr2.parameter_name = oll.line_parameter_name(+) and
		 oll.line_item_id(+) = l_line_id
	order by wpr2.evaluation_seq;


  BEGIN

    select XDP_FULFILL_WORKLIST_S.nextval
    into lv_instance_id
    from dual;

   select order_id,line_number into lv_order_id,lv_line_number
   from xdp_order_line_items
   where line_item_id = p_line_item_id;

   g_order_id:= lv_order_id;

   select workitem_id,workitem_name,validation_procedure,
          validation_enabled_flag
    into lv_wi_id,g_Workitem_Name,g_Validation_Procedure,
         g_Validation_Enabled_Flag
    from xdp_workitems
   where workitem_id = p_workitem_id;

   if p_provisioning_date is not null then
     lv_prov_date :=  p_provisioning_date;
   else
     select provisioning_date into lv_prov_date
     from xdp_order_line_items
     where line_item_id = p_line_item_id;
   end if;

   insert into XDP_FULFILL_WORKLIST
   (workitem_instance_id,
    line_item_id,
    order_id,
    line_number,
    workitem_id,
    status_code,
    provisioning_date,
    priority,
    wi_sequence,
    due_date,
    customer_required_date,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
   )
   values
    (lv_instance_id,
     p_line_item_id,
     lv_order_id,
     lv_line_number,
     lv_wi_id,
     'PENDING',
     lv_prov_date,
     p_priority,
     p_provisioning_seq ,
     p_due_date,
     p_customer_required_date,
     FND_GLOBAL.USER_ID,
     sysdate,
     FND_GLOBAL.USER_ID,
     sysdate,
     FND_GLOBAL.LOGIN_ID
    );


   FOR lv_param_rec in lc_wi_param(lv_wi_id,p_line_item_id) LOOP
	XDP_ENGINE.Set_Workitem_Param_value(
		p_wi_instance_id => lv_instance_id,
		p_parameter_name => lv_param_rec.parameter_name,
		p_parameter_value => lv_param_rec.parameter_value,
		p_parameter_reference_value => lv_param_rec.parameter_reference_value,
		p_evaluation_required => TRUE);
   END LOOP;


  return lv_instance_id;

 END Add_WI_toLine;

 --
 -- Private API which will lock the order from the appropriate queue
 --
 PROCEDURE LOCK_ORDERQ(
	p_sdp_order_id IN NUMBER,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2)
 IS
  lv_tmp  number;
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);

 BEGIN

    return_code := 0;
	/*
    savepoint lv_order_tag;
    begin
	select order_id into lv_tmp
          from xdp_pre_order_queue
   	 where order_id = p_sdp_order_id
	   for update NOWAIT;

	return;
    exception
    when resource_busy then
	rollback to lv_order_tag;
	return_code := -191274;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_LOCK_ERROR');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	error_description := FND_MESSAGE.GET;
	return;
    when no_data_found then
	   null;
    when others then
	rollback to lv_order_tag;
        return_code := -191266;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        error_description := FND_MESSAGE.GET;
	return;
    end;

    begin
     select order_id into lv_tmp from xdp_pending_order_queue
     where order_id = p_sdp_order_id
     for update NOWAIT;
     return;

   exception
   when resource_busy then
     rollback to lv_order_tag;
     	return_code := -191275;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_LOCK_PENDING_ERROR');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	error_description := FND_MESSAGE.GET;
     return;
   when no_data_found then
     null;
   when others then
     rollback to lv_order_tag;
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
     return;
   end;

   begin
    select order_id into lv_tmp from XDP_ORDER_PROC_QUEUE
    where order_id = p_sdp_order_id
    for update NOWAIT;
    return;

   exception
   when resource_busy or no_data_found then
     rollback to lv_order_tag;
     return_code := SQLCODE;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_PROCESS_ERROR');
     FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
     error_description := FND_MESSAGE.GET;
     return;
   when others then
     rollback to lv_order_tag;
     return_code := -191266;
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
     FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
     FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
     error_description := FND_MESSAGE.GET;
     return;
   end;
*/

EXCEPTION
WHEN NO_DATA_FOUND THEN
 --  rollback to lv_order_tag;
   return_code := SQLCODE;
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
   error_description := FND_MESSAGE.GET;
WHEN OTHERS THEN
 --   rollback to lv_order_tag;
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;

 END LOCK_ORDERQ;


/*
  Cancel a line item from a given order
*/
 Procedure Cancel_Line(
	p_sdp_order_id in NUMBER,
	p_line_item_id IN NUMBER,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
IS
  lv_state varchar2(40);
  lv_tmp  number;
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);
BEGIN
   return_code := 0;
   SAVEPOINT lv_order_tag2;

   select status_code into lv_state
   from xdp_order_line_items
   where line_item_id = p_line_item_id and
	   order_id = p_sdp_order_id;

   if lv_state IN ('CANCELED','ABORTED') Then
	rollback to lv_order_tag;
        return_code := -191310;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_LI_STATE_CANCEL');
	FND_MESSAGE.SET_TOKEN('LINE_ITEM_ID', p_line_item_id);
	error_description := FND_MESSAGE.GET;
	return;
   elsif lv_state not in ('IN PROGRESS') then
     rollback to lv_order_tag;
      return_code := -191311;
      FND_MESSAGE.SET_NAME('XDP', 'XDP_LI_STATE_PROCESS');
      FND_MESSAGE.SET_TOKEN('LINE_ITEM_ID', p_line_item_id);
      error_description := FND_MESSAGE.GET;
      return;
   else
      LOCK_ORDERQ(
	  p_sdp_order_id => p_sdp_order_id,
	  return_code => return_code,
	  error_description => error_description);
      IF return_code = 0 THEN
	  update xdp_order_line_items
	     set last_updated_by   = FND_GLOBAL.USER_ID,
                 last_update_date  = sysdate,
                 last_update_login = FND_GLOBAL.LOGIN_ID,
	         status_code            = 'CANCELED'
	   where line_item_id = p_line_item_id;
	   return;
      ELSE
        return;
      END IF;

   end if;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
       rollback to lv_order_tag2;
       return_code := SQLCODE;
       FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_LI_NOTEXISTS');
       FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
       FND_MESSAGE.SET_TOKEN('LINE_ITEM_ID', p_line_item_id);
       error_description := FND_MESSAGE.GET;

     WHEN OTHERS THEN
        rollback to lv_order_tag2;
       return_code := -191266;
       FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
       FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
       FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
       error_description := FND_MESSAGE.GET;
END Cancel_line;

/*
  Cancel a workitem item from a given order
*/
 Procedure Cancel_Workitem(
	p_sdp_order_id in NUMBER,
	p_workitem_instance_id IN NUMBER,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
IS
  lv_state varchar2(40);
  lv_tmp  number;
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);
BEGIN
   return_code := 0;

   SAVEPOINT lv_order_tag2;

   select status_code into lv_state
   from XDP_FULFILL_WORKLIST
   where workitem_instance_id = p_workitem_instance_id and
	   order_id = p_sdp_order_id;

   if lv_state IN ('CANCELED','ABORTED') Then
	return_code := -191312;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_STATE_CANCEL');
	FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_workitem_instance_id);
	error_description := FND_MESSAGE.GET;
	return;
   elsif lv_state not in ('IN PROGRESS') then
	return_code := -191313;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_STATE_PROCESS');
	FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_workitem_instance_id);
	error_description := FND_MESSAGE.GET;
	return;
      return;
   else

      LOCK_ORDERQ(
	  p_sdp_order_id    => p_sdp_order_id,
	  return_code       => return_code,
	  error_description => error_description);

      IF return_code = 0 THEN
	  update XDP_FULFILL_WORKLIST
	     set last_updated_by = FND_GLOBAL.USER_ID,
                 last_update_date = sysdate,
                 last_update_login = FND_GLOBAL.LOGIN_ID,
	         status_code = 'CANCELED'
	   where workitem_instance_id = p_workitem_instance_id;
	   return;
      ELSIF return_code = -54 THEN /*resource_busy exception */
        begin
	    update XDP_FULFILL_WORKLIST
	       set last_updated_by = FND_GLOBAL.USER_ID,
                   last_update_date = sysdate,
                   last_update_login = FND_GLOBAL.LOGIN_ID,
	           status_code = 'CANCELED'
	     where workitem_instance_id = p_workitem_instance_id;
	     return;
        exception
	  when resource_busy or no_data_found then
	    rollback to lv_order_tag2;
	    return_code := -191281;
	    FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_WI_ERROR');
	    FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
	    FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_workitem_instance_id);
	    error_description := FND_MESSAGE.GET;
	return;
	    return;
	  when others then
	    rollback to lv_order_tag2;
            return_code := -191266;
            FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
            FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
            error_description := FND_MESSAGE.GET;
	    return;
	  end;
      ELSE
         return;
      END IF;
   end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   rollback to lv_order_tag2;
   return_code := SQLCODE;
   FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_WI_NOTEXISTS');
   FND_MESSAGE.SET_TOKEN('ORDER_ID', p_sdp_order_id);
   FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_workitem_instance_id);
   error_description := FND_MESSAGE.GET;

WHEN OTHERS THEN
     rollback to lv_order_tag2;
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Cancel_Workitem;


/*******************************************************************
  Set Order Realtionships
  the p_order_relationship argument take the
  following enumerated Constant value:
  Values:					Meaning:
  XDP_TYPES.IS_PREREQUISITE_OF 	Related order will not get executed
						until the current order is
						completed. If the current order is
						canceled, the related order will
						also be canceled.

  XDP_TYPES.COMES_BEFORE       	Related order will not get executed
						until	the current order is
						completed or the current order is
						canceled.

  XDP_TYPES.COMES_AFTER			Current order will not get executed
						until	the related order is
						completed or the related order is
						canceled.

  XDP_TYPES.IS_CHILD_OF			Current order is the child order of
						the related order.

*******************************************************************/
Procedure Set_Order_Relationships(
	p_curr_sdp_order_id in NUMBER,
	p_related_sdp_order_id IN NUMBER,
      p_order_relationship  IN BINARY_INTEGER,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2)
IS
  lv_curr_state varchar2(40);
  lv_rel_state  varchar2(40);
  lv_exists varchar2(1);
  lv_relation varchar2(40);
BEGIN

   return_code := 0;
   SAVEPOINT lv_order_tag2;
   select status_code into lv_curr_state
   from xdp_order_headers
   where order_id = p_curr_sdp_order_id;

   select status_code into lv_rel_state
   from xdp_order_headers
   where order_id = p_related_sdp_order_id;

   IF p_order_relationship = XDP_TYPES.IS_PREREQUISITE_OF OR
	p_order_relationship = XDP_TYPES.COMES_BEFORE
   THEN
    IF lv_curr_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') THEN
	return_code := -191283;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_RELATION_ERROR');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_curr_sdp_order_id);
	error_description := FND_MESSAGE.GET;
	return;
    ELSIF lv_rel_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') THEN
	return_code := -191284;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_REL_RELATION_ERROR');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_related_sdp_order_id);
	error_description := FND_MESSAGE.GET;
	return;
    ELSIF lv_curr_state IN ('STANDBY') AND
	    lv_rel_state IN ('STANDBY')
    THEN
      LOCK_ORDERQ(
	  p_sdp_order_id => p_curr_sdp_order_id,
	  return_code => return_code,
	  error_description => error_description);
      IF return_code <> 0 THEN
         return;
	END IF;

      LOCK_ORDERQ(
	  p_sdp_order_id => p_related_sdp_order_id,
	  return_code => return_code,
	  error_description => error_description);
      IF return_code <> 0 THEN
         return;
	END IF;

      if p_order_relationship = XDP_TYPES.IS_PREREQUISITE_OF THEN
	  lv_relation := 'IS_PREREQUISITE_OF';
	else
	  lv_relation := 'COMES_BEFORE';
	end if;
      BEGIN
	  select 'Y' into lv_exists
	  from dual
	  where EXISTS(
		select 'x' from xdp_order_relationships
		where order_id = p_curr_sdp_order_id AND
			related_order_id = p_related_sdp_order_id);
	exception
	when no_data_found then
		lv_exists := 'N';
      END;

	IF lv_exists = 'N' then
        INSERT INTO XDP_ORDER_RELATIONSHIPS
	  (ORDER_ID,
	   RELATED_ORDER_ID,
	   ORDER_RELATIONSHIP,
	     created_by,
	     creation_date,
	     last_updated_by,
	     last_update_date,
	     last_update_login
	  )
	  VALUES
	  (p_curr_sdp_order_id,
	   p_related_sdp_order_id,
	   lv_relation,
		FND_GLOBAL.USER_ID,
		sysdate,
		FND_GLOBAL.USER_ID,
		sysdate,
		FND_GLOBAL.LOGIN_ID
	  );

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	   next_order_id = p_related_sdp_order_id
	  where order_id = p_curr_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    previous_order_id = p_curr_sdp_order_id
	  where order_id = p_related_sdp_order_id;

	  return;
	ELSE
        UPDATE XDP_ORDER_RELATIONSHIPS
	  SET
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    ORDER_RELATIONSHIP = lv_relation
	  where order_id = p_curr_sdp_order_id AND
	        related_order_id = p_related_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    next_order_id = p_related_sdp_order_id
	  where order_id = p_curr_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	   previous_order_id = p_curr_sdp_order_id
	  where order_id = p_related_sdp_order_id;

	  return;
	END IF;

    ELSIF lv_curr_state = 'IN PROGRESS' AND
	    lv_rel_state IN ('STANDBY')
    THEN
      LOCK_ORDERQ(
	  p_sdp_order_id => p_related_sdp_order_id,
	  return_code => return_code,
	  error_description => error_description);
      IF return_code <> 0 THEN
         return;
	END IF;

      if p_order_relationship = XDP_TYPES.IS_PREREQUISITE_OF THEN
	  lv_relation := 'IS_PREREQUISITE_OF';
	else
	  lv_relation := 'COMES_BEFORE';
	end if;
      BEGIN
	  select 'Y' into lv_exists
	  from dual
	  where EXISTS(
		select 'x' from xdp_order_relationships
		where order_id = p_curr_sdp_order_id AND
			related_order_id = p_related_sdp_order_id);
	exception
	when no_data_found then
		lv_exists := 'N';
      END;

	IF lv_exists = 'N' then
        INSERT INTO XDP_ORDER_RELATIONSHIPS
	  (ORDER_ID,
           RELATED_ORDER_ID,
           ORDER_RELATIONSHIP,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
	  )
	  VALUES
	  (p_curr_sdp_order_id,
	   p_related_sdp_order_id,
	   lv_relation,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   FND_GLOBAL.LOGIN_ID
	  );

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	   next_order_id = p_related_sdp_order_id
	  where order_id = p_curr_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	   previous_order_id = p_curr_sdp_order_id
	  where order_id = p_related_sdp_order_id;

	  return;
	ELSE
        UPDATE XDP_ORDER_RELATIONSHIPS
	  SET
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
    	    ORDER_RELATIONSHIP = lv_relation
	  where order_id = p_curr_sdp_order_id AND
	        related_order_id = p_related_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    next_order_id = p_related_sdp_order_id
	  where order_id = p_curr_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    previous_order_id = p_curr_sdp_order_id
	  where order_id = p_related_sdp_order_id;

	  return;
	END IF;

      null;
    ELSE
    	return_code := -191300;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_RELATION_PROCESS');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_related_sdp_order_id);
	error_description := FND_MESSAGE.GET;
	return;
    END IF;

   ELSIF p_order_relationship = XDP_TYPES.COMES_AFTER THEN
    IF lv_curr_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') THEN
	return_code := -191283;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_RELATION_ERROR');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_curr_sdp_order_id);
	error_description := FND_MESSAGE.GET;
	return;
    ELSIF lv_rel_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') THEN
	return_code := -191284;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_REL_RELATION_ERROR');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_related_sdp_order_id);
	error_description := FND_MESSAGE.GET;
	return;
    ELSIF lv_curr_state IN ('STANDBY') AND
	    lv_rel_state IN ('STANDBY')
    THEN
      LOCK_ORDERQ(
	  p_sdp_order_id => p_curr_sdp_order_id,
	  return_code => return_code,
	  error_description => error_description);
      IF return_code <> 0 THEN
         return;
	END IF;

      LOCK_ORDERQ(
	  p_sdp_order_id => p_related_sdp_order_id,
	  return_code => return_code,
	  error_description => error_description);
      IF return_code <> 0 THEN
         return;
	END IF;

	lv_relation := 'COMES_AFTER';

      BEGIN
	  select 'Y' into lv_exists
	  from dual
	  where EXISTS(
		select 'x' from xdp_order_relationships
		where order_id = p_curr_sdp_order_id AND
			related_order_id = p_related_sdp_order_id);
	exception
	when no_data_found then
		lv_exists := 'N';
      END;

	IF lv_exists = 'N' then
        INSERT INTO XDP_ORDER_RELATIONSHIPS
	  (ORDER_ID,
	   RELATED_ORDER_ID,
	   ORDER_RELATIONSHIP,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login
	  )
	  VALUES
	  (p_curr_sdp_order_id,
	   p_related_sdp_order_id,
	   lv_relation,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   FND_GLOBAL.LOGIN_ID
	  );

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	   previous_order_id = p_related_sdp_order_id
	  where order_id = p_curr_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	   next_order_id = p_curr_sdp_order_id
	  where order_id = p_related_sdp_order_id;

	  return;
	ELSE
        UPDATE XDP_ORDER_RELATIONSHIPS
	  SET
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    ORDER_RELATIONSHIP = lv_relation
	  where order_id = p_curr_sdp_order_id AND
	        related_order_id = p_related_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	   previous_order_id = p_related_sdp_order_id
	  where order_id = p_curr_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    next_order_id = p_curr_sdp_order_id
	  where order_id = p_related_sdp_order_id;

	  return;
	END IF;
    ELSIF lv_rel_state = 'IN PROGRESS' AND
	  lv_curr_state = 'STANDBY'
    THEN
      LOCK_ORDERQ(
	  p_sdp_order_id => p_related_sdp_order_id,
	  return_code => return_code,
	  error_description => error_description);
      IF return_code <> 0 THEN
         return;
      END IF;

	lv_relation := 'COMES_AFTER';
      BEGIN
	  select 'Y' into lv_exists
	  from dual
	  where EXISTS(
		select 'x' from xdp_order_relationships
		where order_id = p_curr_sdp_order_id AND
			related_order_id = p_related_sdp_order_id);
	exception
	when no_data_found then
		lv_exists := 'N';
      END;

	IF lv_exists = 'N' then
        INSERT INTO XDP_ORDER_RELATIONSHIPS
	  (ORDER_ID,
	   RELATED_ORDER_ID,
	   ORDER_RELATIONSHIP,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login
	  )
	  VALUES
	  (p_curr_sdp_order_id,
	   p_related_sdp_order_id,
	   lv_relation,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   FND_GLOBAL.LOGIN_ID
	  );

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    previous_order_id = p_related_sdp_order_id
	  where order_id = p_curr_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
            next_order_id = p_curr_sdp_order_id
	  where order_id = p_related_sdp_order_id;

	  return;
	ELSE
        UPDATE XDP_ORDER_RELATIONSHIPS
	  SET
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
            ORDER_RELATIONSHIP = lv_relation
	  where order_id = p_curr_sdp_order_id AND
	        related_order_id = p_related_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    previous_order_id = p_related_sdp_order_id
	  where order_id = p_curr_sdp_order_id;

	  update xdp_order_headers
        set
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    next_order_id = p_curr_sdp_order_id
	  where order_id = p_related_sdp_order_id;

	  return;
	END IF;

      null;
    ELSE
	return_code := -191300;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_RELATION_PROCESS');
	FND_MESSAGE.SET_TOKEN('ORDER_ID', p_curr_sdp_order_id);
	error_description := FND_MESSAGE.GET;
	return;
    END IF;

	null;

   ELSIF p_order_relationship = XDP_TYPES.IS_CHILD_OF THEN
	lv_relation := 'IS_CHILD_OF';
      BEGIN
	  select 'Y' into lv_exists
	  from dual
	  where EXISTS(
		select 'x' from xdp_order_relationships
		where order_id = p_curr_sdp_order_id AND
			related_order_id = p_related_sdp_order_id);
	exception
	when no_data_found then
		lv_exists := 'N';
      END;

	IF lv_exists = 'N' then
        INSERT INTO XDP_ORDER_RELATIONSHIPS
	  (ORDER_ID,
	   RELATED_ORDER_ID,
	   ORDER_RELATIONSHIP,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login
          )
	  VALUES
	  (p_curr_sdp_order_id,
	   p_related_sdp_order_id,
	   lv_relation,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   FND_GLOBAL.USER_ID,
	   sysdate,
	   FND_GLOBAL.LOGIN_ID
	  );

	  return;
	ELSE
        UPDATE XDP_ORDER_RELATIONSHIPS
	  SET
       	    last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID,
	    ORDER_RELATIONSHIP = lv_relation
	  where order_id = p_curr_sdp_order_id AND
	        related_order_id = p_related_sdp_order_id;

	  return;
	END IF;

   ELSE
	return_code := -191285;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_ORDER_RELATION');
	error_description := FND_MESSAGE.GET;
	return;
   END IF;

EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Set_Order_Relationships;


/*
  Set Workitem Realtionships
  the p_wi_relationship argument take the
  following enumerated Constant value:

  Values:				Meaning:
  XDP_TYPES.MERGED_INTO		Related workitem is merged into the
					current workitem.	If the current
					workitem is completed, then the
					related workitem is completed.
*/
 Procedure Set_Workitem_Relationships(
	p_curr_wi_instance_id    IN NUMBER,
	p_related_wi_instance_id IN NUMBER,
        p_wi_relationship        IN BINARY_INTEGER,
	return_code             OUT NOCOPY NUMBER,
	error_description       OUT NOCOPY VARCHAR2)
IS
  lv_curr_state varchar2(80);
  lv_curr_order_id number;
  lv_rel_state  varchar2(80);
  lv_rel_order_id number;
  lv_exists varchar2(1);
  lv_relation varchar2(80);
BEGIN

   return_code := 0;
   SAVEPOINT lv_wi_tag;
   select status_code,order_id
   into lv_curr_state,lv_curr_order_id
   from XDP_FULFILL_WORKLIST
   where workitem_instance_id = p_curr_wi_instance_id;

   select status_code ,order_id
   into lv_rel_state,lv_rel_order_id
   from XDP_FULFILL_WORKLIST
   where workitem_instance_id = p_related_wi_instance_id;

   IF p_wi_relationship = XDP_TYPES.MERGED_INTO THEN
    IF lv_curr_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') THEN
	return_code := -191286;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_RELATION_ERROR');
	FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_curr_wi_instance_id);
	error_description := FND_MESSAGE.GET;
	return;
    ELSIF lv_rel_state IN ('CANCELED','ABORTED','SUCCESS','SUCCESS_WITH_OVERRIDE') THEN
	return_code := -191287;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_REL_RELATION_ERROR');
	FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_related_wi_instance_id);
	error_description := FND_MESSAGE.GET;
	return;
    ELSIF lv_curr_state = 'STANDBY' AND
	  lv_rel_state  = 'STANDBY'
    THEN
        LOCK_ORDERQ(
	  p_sdp_order_id => lv_curr_order_id,
	  return_code => return_code,
	  error_description => error_description);
        IF return_code <> 0 THEN
           return;
        END IF;

        LOCK_ORDERQ(
  	    p_sdp_order_id => lv_rel_order_id,
	    return_code => return_code,
	    error_description => error_description);
        IF return_code <> 0 THEN
           return;
	  END IF;

        lv_relation := 'MERGED_INTO';

        BEGIN
  	    select 'Y' into lv_exists
	    from dual
	    where EXISTS(
	  	  select 'x' from xdp_wi_relationships
		  where workitem_instance_id = p_curr_wi_instance_id AND
			  related_wi_instance_id = p_related_wi_instance_id);
	EXCEPTION
	     WHEN no_data_found THEN
		  lv_exists := 'N';
        END;

	IF lv_exists = 'N' then
           INSERT INTO XDP_WI_RELATIONSHIPS
	           (Workitem_instance_id,
	            RELATED_wi_instance_id,
	            wi_RELATIONSHIP,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login
	           )
	           VALUES
	           (p_curr_wi_instance_id ,
	            p_related_wi_instance_id,
	            lv_relation,
	            FND_GLOBAL.USER_ID,
	            sysdate,
	            FND_GLOBAL.USER_ID,
	            sysdate,
	            FND_GLOBAL.LOGIN_ID
	           );

	           UPDATE XDP_FULFILL_WORKLIST
	           SET
       	             last_updated_by = FND_GLOBAL.USER_ID,
                     last_update_date = sysdate,
                     last_update_login = FND_GLOBAL.LOGIN_ID,
                     status_code   = 'MERGED'
--	             state = 'MERGERD'
	           where workitem_instance_id = p_related_wi_instance_id;
	           return;
	ELSE
                 UPDATE XDP_WI_RELATIONSHIPS
	           SET
       	             last_updated_by = FND_GLOBAL.USER_ID,
                     last_update_date = sysdate,
                     last_update_login = FND_GLOBAL.LOGIN_ID,
	             WI_RELATIONSHIP = lv_relation
	           where workitem_instance_id = p_curr_wi_instance_id AND
		           related_wi_instance_id = p_related_wi_instance_id;

	           UPDATE XDP_FULFILL_WORKLIST
	           SET
       	             last_updated_by = FND_GLOBAL.USER_ID,
                     last_update_date = sysdate,
                     last_update_login = FND_GLOBAL.LOGIN_ID,
	             status_code = 'MERGERD'
--	             state = 'MERGERD'
	           where workitem_instance_id = p_related_wi_instance_id;

	           return;
	END IF;
    ELSIF lv_curr_state = 'IN PROGRESS' THEN
	return_code := -191301;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_RELATION_PROCESS');
	FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_curr_wi_instance_id);
	error_description := FND_MESSAGE.GET;
	return;

    ELSIF lv_rel_state = 'IN PROGRESS' THEN
	return_code := -191301;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_RELATION_PROCESS');
	FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_related_wi_instance_id);
	error_description := FND_MESSAGE.GET;
	return;

    ELSE
	return_code := -191301;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_RELATION_PROCESS');
	FND_MESSAGE.SET_TOKEN('WORK_ITEM_ID', p_related_wi_instance_id);
	error_description := FND_MESSAGE.GET;
	return;
    END IF;
  ELSE
    return_code := -191288;
    FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_WI_RELATION');
    FND_MESSAGE.SET_TOKEN('WI_RELATIONSHIP', p_wi_relationship);
    error_description := FND_MESSAGE.GET;
    return;

  END IF;


EXCEPTION
WHEN OTHERS THEN
  rollback to lv_wi_tag;
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Set_Workitem_Relationships;



/*
   Get the order header information for a giving order
*/
FUNCTION Get_Order_Header(p_sdp_order_id IN NUMBER)
  return XDP_TYPES.ORDER_HEADER
IS
  lv_header XDP_TYPES.ORDER_HEADER;
BEGIN
  select
	order_id,
  	external_order_number,
  	status_code,
  	provisioning_date,
	actual_provisioning_date,
	completion_date,
  	due_date,
  	customer_required_date,
  	external_order_version,
  	--order_action, -- remove for R11.5.6
  	order_source,
  	customer_id,
  	customer_name,
  	org_id,
  	--service_provider_id,-- remove for R11.5.6
  	telephone_number,
  	priority,
  	related_order_id,
  	order_type,
  	previous_order_id,
  	next_order_id
   into
 	lv_header.sdp_order_id,
  	lv_header.order_number  ,
  	lv_header.order_status,
  	lv_header.provisioning_date,
  	lv_header.actual_provisioning_date,
  	lv_header.completion_date,
  	lv_header.due_date,
  	lv_header.customer_required_date ,
  	lv_header.order_version,
  	--lv_header.order_action  ,-- remove for R11.5.6
  	lv_header.order_source ,
  	lv_header.customer_id  ,
  	lv_header.customer_name,
  	lv_header.org_id ,
  	--lv_header.service_provider_id ,-- remove for R11.5.6
  	lv_header.telephone_number,
  	lv_header.priority ,
  	lv_header.related_order_id ,
  	lv_header.order_type,
  	lv_header.previous_order_id,
  	lv_header.next_order_id
    from
	xdp_order_headers
    where
	order_id = p_sdp_order_id;

  return lv_header;
END Get_Order_Header;

/*
  Get all the line items for a given line item id
*/
FUNCTION Get_Order_Lines( p_sdp_order_id IN NUMBER)
  return XDP_TYPES.ORDER_LINE_LIST
IS
  lv_line_list XDP_TYPES.ORDER_LINE_LIST;
  CURSOR lc_line IS
	select *
	from	xdp_order_line_items
	where order_id = p_sdp_order_id and
		is_virtual_line_flag = 'N';
   lv_count number := 0;
BEGIN

  for lv_line_rec in lc_line loop
    	lv_count := lv_count + 1;
	lv_line_list(lv_count).LINE_NUMBER := lv_line_rec.line_number;
  	lv_line_list(lv_count).LINE_ITEM_NAME := lv_line_rec.line_item_name;
  	lv_line_list(lv_count).VERSION := lv_line_rec.version;
  	lv_line_list(lv_count).ACTION := lv_line_rec.line_item_action_code;
	lv_line_list(lv_count).PROVISIONING_DATE := lv_line_rec.provisioning_date;
	lv_line_list(lv_count).PROVISIONING_REQUIRED_FLAG  :=
				lv_line_rec.PROVISIONING_REQUIRED_FLAG  ;
  	lv_line_list(lv_count).PROVISIONING_SEQUENCE := lv_line_rec.line_sequence;
      lv_line_list(lv_count).BUNDLE_ID := lv_line_rec.bundle_id;
	lv_line_list(lv_count).BUNDLE_SEQUENCE  := lv_line_rec.bundle_sequence;
	lv_line_list(lv_count).PRIORITY := lv_line_rec.priority;
	lv_line_list(lv_count).due_date := lv_line_rec.due_date;
	lv_line_list(lv_count).customer_required_date :=
							lv_line_rec.customer_required_date;
	lv_line_list(lv_count).line_status := lv_line_rec.status_code;
	lv_line_list(lv_count).completion_date  := lv_line_rec.completion_date;
        -- remove for R11.5.6
	--lv_line_list(lv_count).service_id := lv_line_rec.service_id;
	--lv_line_list(lv_count).package_id := lv_line_rec.package_id;
	lv_line_list(lv_count).workitem_id := lv_line_rec.workitem_id;
	lv_line_list(lv_count).line_item_id := lv_line_rec.line_item_id;
  end loop;

  return lv_line_list;
END Get_Order_Lines;

/*
  Get all the line item for a given line_item_id
*/
FUNCTION Get_LineRec( p_line_item_id IN NUMBER)
  return XDP_TYPES.LINE_ITEM
IS
  lv_line XDP_TYPES.LINE_ITEM;
  CURSOR lc_line IS
	select *
	from	xdp_order_line_items
	where line_item_id = p_line_item_id;
   lv_count number := 0;
BEGIN

  for lv_line_rec in lc_line loop
	lv_line.LINE_NUMBER := lv_line_rec.line_number;
  	lv_line.LINE_ITEM_NAME := lv_line_rec.line_item_name;
  	lv_line.VERSION := lv_line_rec.version;
  	lv_line.ACTION := lv_line_rec.line_item_action_code;
	lv_line.PROVISIONING_DATE := lv_line_rec.provisioning_date;
	lv_line.PROVISIONING_REQUIRED_FLAG := lv_line_rec.PROVISIONING_REQUIRED_FLAG;
  	lv_line.PROVISIONING_SEQUENCE := lv_line_rec.line_sequence;
      lv_line.BUNDLE_ID := lv_line_rec.bundle_id;
	lv_line.BUNDLE_SEQUENCE  := lv_line_rec.bundle_sequence;
	lv_line.PRIORITY := lv_line_rec.priority;
	lv_line.due_date := lv_line_rec.due_date;
	lv_line.customer_required_date := lv_line_rec.customer_required_date;
	lv_line.line_status := lv_line_rec.status_code;
	lv_line.completion_date  := lv_line_rec.completion_date;
	lv_line.workitem_id := lv_line_rec.workitem_id;
	lv_line.line_item_id := lv_line_rec.line_item_id;
  end loop;

  return lv_line;
END Get_LineRec;


/*
  Get all the workitems for a given workitem instance id
*/
FUNCTION Get_WorkitemRec( p_wi_instance_id IN NUMBER)
  return XDP_TYPES.workitem_rec
IS
  lv_wi XDP_TYPES.Workitem_rec;
  lv_count number := 0;
  CURSOR lc_wi IS
  select
	workitem_instance_id,
	fwt.workitem_id,
	wim.workitem_name,
	fwt.line_number,
	fwt.line_item_id,
	wi_sequence,
	priority,
	status_code
   from
	XDP_FULFILL_WORKLIST fwt,
	xdp_workitems wim
   where
	fwt.workitem_instance_id = p_wi_instance_id and
	fwt.workitem_id = wim.workitem_id
   order by fwt.line_item_id;

BEGIN

  for lv_wi_rec in lc_wi loop
    lv_wi.workitem_instance_id := lv_wi_rec.workitem_instance_id;
    lv_wi.workitem_id := lv_wi_rec.workitem_id;
    lv_wi.line_item_id := lv_wi_rec.line_item_id;
    lv_wi.line_number := lv_wi_rec.line_number;
    lv_wi.workitem_name := lv_wi_rec.workitem_name;
    lv_wi.provisioning_sequence := lv_wi_rec.wi_sequence;
    lv_wi.priority := lv_wi_rec.priority;
    lv_wi.workitem_status := lv_wi_rec.status_code;
  end loop;

  return lv_wi;
END Get_WorkitemRec;

/*
  Get all the workitems for a given line item id
*/
FUNCTION Get_Order_Workitems( p_sdp_order_id IN NUMBER)
  return XDP_TYPES.Workitem_List
IS
  lv_wi_list XDP_TYPES.Workitem_List;
  lv_count number := 0;
  CURSOR lc_wi IS
  select
	workitem_instance_id,
	fwt.workitem_id,
	wim.workitem_name,
	fwt.line_number,
	fwt.line_item_id,
	wi_sequence,
	priority,
	status_code
   from
	XDP_FULFILL_WORKLIST fwt,
	xdp_workitems wim
   where
	fwt.order_id = p_sdp_order_id and
	fwt.workitem_id = wim.workitem_id
   order by fwt.line_item_id;

BEGIN

  for lv_wi_rec in lc_wi loop
    lv_count := lv_count + 1;
    lv_wi_list(lv_count).workitem_instance_id := lv_wi_rec.workitem_instance_id;
    lv_wi_list(lv_count).workitem_id := lv_wi_rec.workitem_id;
    lv_wi_list(lv_count).line_item_id := lv_wi_rec.line_item_id;
    lv_wi_list(lv_count).line_number := lv_wi_rec.line_number;
    lv_wi_list(lv_count).workitem_name := lv_wi_rec.workitem_name;
    lv_wi_list(lv_count).provisioning_sequence := lv_wi_rec.wi_sequence;
    lv_wi_list(lv_count).priority := lv_wi_rec.priority;
    lv_wi_list(lv_count).workitem_status := lv_wi_rec.status_code;

  end loop;

  return lv_wi_list;
END Get_Order_Workitems;

/*
  Find orders which meets the user defined searching
  criteria.  The user can use Most of the commands which are allowed
  in the SQL where clause such as Like, = , substr,etc.., in their
  searching criteria.  The User should use the following Macros to
  refer to the order information:
  $ORDER.<Order Header Record Attribute Name>$
  $LINE.<Line item record attribute>$

  Note: The user must omit the key word WHERE in the argument p_where
*/
PROCEDURE Find_Orders(
   p_where IN OUT NOCOPY Varchar2,
   p_order_list OUT NOCOPY XDP_TYPES.ORDER_HEADER_LIST,
   return_code  OUT NOCOPY number,
   error_description OUT NOCOPY varchar2)
IS
   lv_plsql varchar2(32000);
   lv_where varchar2(32000);
   lv_order_flag BOOLEAN := FALSE;
   lv_line_flag BOOLEAN := FALSE;
   lv_id_list  DBMS_SQL.NUMBER_TABLE;
   lv_index number;
   lv_count number;
BEGIN

   return_code := 0;
   Find_Replace_Ord_Header(
	p_where_block =>p_where,
	p_replace_block =>lv_where,
	p_found_flag =>lv_order_flag,
	return_code => return_code,
	error_description => error_description);

   IF return_code <> 0 Then
	return;
   END IF;

   p_where := lv_where;
   Find_Replace_Line(
	p_where_block => p_where,
	p_replace_block => lv_where,
	p_found_flag =>lv_line_flag,
	return_code => return_code,
	error_description => error_description);

   IF return_code <> 0 Then
	return;
   END IF;

   IF lv_order_flag = FALSE AND lv_line_flag = FALSE THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_SEARCH_CRITERIA_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING1', '$ORDER');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING2','$LINE');
	error_description := FND_MESSAGE.GET;
	return;
   END IF;

   p_where := lv_where;

   IF INSTR(UPPER(p_where),'$LINE_PARAM.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$LINE_PARAM');
	error_description := FND_MESSAGE.GET;
	return;
   ELSIF INSTR(UPPER(p_where),'$WORKITEM.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$WORKITEM');
	error_description := FND_MESSAGE.GET;
	return;
   ELSIF INSTR(UPPER(p_where),'$WI_PARAM.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$WI_PARAM');
	error_description := FND_MESSAGE.GET;
	return;
   END IF;

   IF lv_order_flag = TRUE and lv_line_flag = TRUE THEN
	lv_plsql := 'SELECT DISTINCT OHR.ORDER_ID FROM '||
			'XDP_ORDER_HEADERS OHR, XDP_ORDER_LINE_ITEMS OLM '||
			' WHERE OHR.ORDER_ID = OLM.ORDER_ID AND '||
			p_where;
   ELSIF lv_order_flag = TRUE and lv_line_flag = FALSE THEN
	lv_plsql := 'SELECT DISTINCT OHR.ORDER_ID FROM '||
			'XDP_ORDER_HEADERS OHR '||
			' WHERE '||
			p_where;

   ELSIF lv_order_flag = FALSE and lv_line_flag = TRUE THEN
	lv_plsql := 'SELECT DISTINCT OLM.ORDER_ID FROM '||
			' XDP_ORDER_LINE_ITEMS OLM '||
			' WHERE '||
			p_where;
   END IF;

   XDP_UTILITIES.Execute_GetID_QUERY(
				p_query_block => lv_plsql,
          			p_id_list => lv_id_list,
				return_code => return_code,
				error_description => error_description);

  IF return_code <> 0 then
	return;
  END IF;

  IF lv_id_list.COUNT = 0 THEN
	return;
  ELSE
    lv_index := lv_id_list.FIRST;
  END IF;

  FOR lv_count IN 1..lv_id_list.count LOOP
 	p_order_list(lv_count) := Get_Order_Header(
				p_sdp_order_id => lv_id_list(lv_index));
	lv_index := lv_id_list.NEXT(lv_index);
  END LOOP;


EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Find_Orders;


/*
  Find line item in a given order which meets the user defined searching
  criteria.  The user can use most of the commands which are allowed
  in the SQL where clause such as Like, = , substr,etc.., in their
  searching criteria.  The User should use the following Macros to
  refer to the order information:
  $LINE.<Line item record attribute>$
  $LINE_PARAM.<Line parameter name>$

  Note: The user must omit the key word WHERE in the argument p_where
*/
PROCEDURE Find_Lines(
   p_sdp_order_id IN NUMBER,
   p_where IN OUT NOCOPY Varchar2,
   p_order_line_list OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST,
   return_code  OUT NOCOPY number,
   error_description OUT NOCOPY varchar2)
IS
   lv_plsql varchar2(32000);
   lv_where varchar2(32000);
   lv_line_flag BOOLEAN := FALSE;
   lv_param_flag BOOLEAN := FALSE;
   lv_id_list  DBMS_SQL.NUMBER_TABLE;
   lv_index number;
   lv_count number;
BEGIN

   return_code := 0;
   Find_Replace_Line(
	p_where_block => p_where,
	p_replace_block => lv_where,
	p_found_flag =>lv_line_flag,
	return_code => return_code,
	error_description => error_description);

   IF return_code <> 0 Then
	return;
   END IF;

   p_where := lv_where;
   Find_Replace_Line_Param(
	p_where_block => p_where,
	p_replace_block => lv_where,
	p_found_flag =>lv_line_flag,
	return_code => return_code,
	error_description => error_description);

   IF return_code <> 0 Then
	return;
   END IF;

   IF lv_line_flag = FALSE AND lv_param_flag = FALSE THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_SEARCH_CRITERIA_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING1', '$LINE');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING2','$LINE_PARAM');
	error_description := FND_MESSAGE.GET;
	return;
   END IF;

   p_where := lv_where;

   IF INSTR(UPPER(p_where),'$ORDER.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$ORDER');
	error_description := FND_MESSAGE.GET;
	return;
   ELSIF INSTR(UPPER(p_where),'$WORKITEM.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$WORKITEM');
	error_description := FND_MESSAGE.GET;
	return;
   ELSIF INSTR(UPPER(p_where),'$WI_PARAM.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$WI_PARAM');
	error_description := FND_MESSAGE.GET;
	return;
   END IF;

   lv_plsql := 'SELECT DISTINCT OLM.LINE_ITEM_ID FROM '||
			' XDP_ORDER_LINE_ITEMS OLM '||
			' WHERE OLM.ORDER_ID = '||
			p_sdp_order_id ||
			' AND ' ||
			p_where;


   XDP_UTILITIES.Execute_GetID_QUERY(
				p_query_block => lv_plsql,
          			p_id_list => lv_id_list,
				return_code => return_code,
				error_description => error_description);

  IF return_code <> 0 then
	return;
  END IF;

  IF lv_id_list.COUNT = 0 THEN
	return;
  ELSE
    lv_index := lv_id_list.FIRST;
  END IF;

  FOR lv_count IN 1..lv_id_list.count LOOP
 	p_order_line_list(lv_count) := Get_LineRec(
				p_line_item_id => lv_id_list(lv_index));
	lv_index := lv_id_list.NEXT(lv_index);
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Find_Lines;


/*
  Find Work item in a given order which meets the user defined searching
  criteria.  The user can use most of the commands which are allowed
  in the SQL where clause such as Like, = , substr,etc.., in their
  searching criteria.  The User should use the following Macros to
  refer to the order information:
  $WORKITEM.<Workitem record attribute>$
  $WI_PARAM.<Workitem parameter name>$

  Note: The user must omit the key word WHERE in the argument p_where
*/
PROCEDURE Find_Workitems(
   p_sdp_order_id IN NUMBER,
   p_where IN OUT NOCOPY Varchar2,
   p_workitem_list OUT NOCOPY XDP_TYPES.Workitem_LIST,
   return_code  OUT NOCOPY number,
   error_description OUT NOCOPY varchar2)
IS
   lv_plsql varchar2(32000);
   lv_where varchar2(32000);
   lv_wi_flag BOOLEAN := FALSE;
   lv_param_flag BOOLEAN := FALSE;
   lv_id_list  DBMS_SQL.NUMBER_TABLE;
   lv_index number;
   lv_count number;
BEGIN

   return_code := 0;

   Find_Replace_WI(
	p_where_block => p_where,
	p_replace_block => lv_where,
	p_found_flag =>lv_wi_flag,
	return_code => return_code,
	error_description => error_description);

   IF return_code <> 0 Then
	return;
   END IF;

   p_where := lv_where;
   Find_Replace_WI_Param(
	p_where_block => p_where,
	p_replace_block => lv_where,
	p_found_flag =>lv_param_flag,
	return_code => return_code,
	error_description => error_description);

   IF return_code <> 0 Then
	return;
   END IF;

   IF lv_wi_flag = FALSE AND lv_param_flag = FALSE THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_SEARCH_CRITERIA_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING1', '$WORKITEM');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING2','$WI_PARAM');
	error_description := FND_MESSAGE.GET;
	return;
   END IF;

   p_where := lv_where;

   IF INSTR(UPPER(p_where),'$ORDER.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$ORDER');
	error_description := FND_MESSAGE.GET;
	return;
   ELSIF INSTR(UPPER(p_where),'$LINE.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$LINE');
	error_description := FND_MESSAGE.GET;
	return;
   ELSIF INSTR(UPPER(p_where),'$LINE_PARAM.') <> 0 THEN
	return_code := 0;
	FND_MESSAGE.SET_NAME('XDP', 'XDP_MACRO_CONTEXT_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR_STRING', '$LINE_PARAM');
	error_description := FND_MESSAGE.GET;
	return;
   END IF;

   lv_plsql := 'SELECT DISTINCT FWT.WORKITEM_INSTANCE_ID FROM '||
			' XDP_FULFILL_WORKLIST FWT '||
			' WHERE FWT.ORDER_ID = '||
			p_sdp_order_id ||
			' AND ' ||
			p_where;


   XDP_UTILITIES.Execute_GetID_QUERY(
				p_query_block => lv_plsql,
          			p_id_list => lv_id_list,
				return_code => return_code,
				error_description => error_description);

  IF return_code <> 0 then
	return;
  END IF;

  IF lv_id_list.COUNT = 0 THEN
	return;
  ELSE
    lv_index := lv_id_list.FIRST;
  END IF;

  FOR lv_count IN 1..lv_id_list.count LOOP
 	p_workitem_list(lv_count) := Get_WorkitemRec(
				p_wi_instance_id => lv_id_list(lv_index));
	lv_index := lv_id_list.NEXT(lv_index);
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Find_Workitems;


/*
  This API allows user to copy an existing line item to a
  order_line_list. The user may choose the copy method to be either
  APPEND_TO OR OVERRIDE.  The copy result will be returned to the user
  in out argument p_order_line_list and p_line_parameter_list.
*/
 PROCEDURE Copy_Line(
	p_src_sdp_order_id IN 	NUMBER,
	p_src_line_item_id IN 	NUMBER,
	p_copy_mode		IN 	BINARY_INTEGER default XDP_TYPES.APPEND_TO,
	p_order_line_list  	IN OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST,
	p_line_parameter_list 	IN OUT NOCOPY XDP_TYPES.LINE_PARAM_LIST,
	return_code 		OUT NOCOPY NUMBER,
	error_description 	OUT NOCOPY VARCHAR2)
IS
  lv_src_found BOOLEAN := FALSE;
  CURSOR lc_line IS
   select * from
   xdp_order_line_items
   where line_item_id = p_src_line_item_id;
  CURSOR lc_line_param IS
   select * from
   XDP_ORDER_LINEITEM_DETS
   where line_item_id = p_src_line_item_id;
  lv_count number ;
  lv_index number;
  lv_max_line number := 0;
  lv_line_num_list DBMS_SQL.NUMBER_TABLE;

BEGIN

   return_code :=  0;
   IF p_copy_mode = XDP_TYPES.OVERRIDE THEN
     p_order_line_list.DELETE;
     p_line_parameter_list.DELETE;
   ELSIF p_copy_mode = XDP_TYPES.APPEND_TO THEN
     IF p_order_line_list.COUNT > 0 THEN
       lv_index := p_order_line_list.FIRST;
	 FOR lv_count IN 1..p_order_line_list.COUNT LOOP
	   lv_line_num_list(p_order_line_list(lv_index).line_number) := 1;
	   lv_index := p_order_line_list.NEXT(lv_index);
       END LOOP;
       lv_max_line := lv_line_num_list.LAST;
     END IF;
   ELSE
	return_code := -191291;
	error_description := 'Error: Invalid copy mode.';
	FND_MESSAGE.SET_NAME('XDP', 'XDP_INVALID_COPY_MODE');
	error_description := FND_MESSAGE.GET;
	return;
   END IF;

   lv_index := p_order_line_list.LAST;
   IF lv_index IS NULL THEN
     lv_index := 0;
   END IF;

   lv_index := lv_index + 1;
   lv_max_line := lv_max_line + 1;
   FOR lv_line_rec in lc_line loop
      lv_src_found := TRUE;
 	p_order_line_list(lv_index).LINE_NUMBER := lv_max_line;
  	p_order_line_list(lv_index).LINE_ITEM_NAME := lv_line_rec.line_item_name;
  	p_order_line_list(lv_index).VERSION := lv_line_rec.version;
  	p_order_line_list(lv_index).ACTION := lv_line_rec.line_item_action_code;
	p_order_line_list(lv_index).PROVISIONING_DATE := lv_line_rec.provisioning_date;
	p_order_line_list(lv_index).PROVISIONING_REQUIRED_FLAG :=
						lv_line_rec.PROVISIONING_REQUIRED_FLAG;
  	p_order_line_list(lv_index).PROVISIONING_SEQUENCE := lv_line_rec.line_sequence;
      p_order_line_list(lv_index).BUNDLE_ID := lv_line_rec.bundle_id;
	p_order_line_list(lv_index).BUNDLE_SEQUENCE  := lv_line_rec.bundle_sequence;
	p_order_line_list(lv_index).PRIORITY := lv_line_rec.priority;
	p_order_line_list(lv_index).due_date := lv_line_rec.due_date;
	p_order_line_list(lv_index).customer_required_date :=
						lv_line_rec.customer_required_date;
   END LOOP;

   IF lv_src_found = FALSE then
     return_code := -191292;
      FND_MESSAGE.SET_NAME('XDP', 'XDP_LI_NOTIN_ORDER');
      FND_MESSAGE.SET_TOKEN('LINE_ITEM_ID', p_src_line_item_id);
      FND_MESSAGE.SET_TOKEN('ORDER_ID', p_src_sdp_order_id);
      error_description := FND_MESSAGE.GET;
     return;
   End if;

   lv_index := p_line_parameter_list.LAST;
   IF lv_index IS NULL THEN
     lv_index := 0;
   END IF;
   lv_index := lv_index + 1;

   FOR lv_line_param_rec in lc_line_param loop
      p_line_parameter_list(lv_index).line_number := lv_max_line;
	p_line_parameter_list(lv_index).parameter_name :=
				lv_line_param_rec.line_parameter_name;
	p_line_parameter_list(lv_index).parameter_value :=
				lv_line_param_rec.parameter_value;
	p_line_parameter_list(lv_index).parameter_ref_value :=
				lv_line_param_rec.parameter_reference_value;
	lv_index := lv_index + 1;
   END loop;


EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Copy_Line;

--
-- Find and replace order header attribute on the where block
--
PROCEDURE Find_Replace_Ord_Header(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2)
IS
  lv_loc number;
  lv_loc2 number;
BEGIN
	return_code := 0;
	p_found_flag := FALSE;
	p_replace_block := p_where_block;

      IF INSTR(UPPER(p_replace_block),'$ORDER.ORDER_NUMBER$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.ORDER_NUMBER$',
						'OHR.EXTERNAL_ORDER_NUMBER');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.ORDER_VERSION$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.ORDER_VERSION$',
						'OHR.EXTERNAL_ORDER_VERSION');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.PROVISIONING_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.PROVISIONING_DATE$',
						'OHR.PROVISIONING_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.PRIORITY$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.PRIORITY$',
						'OHR.PRIORITY');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.DUE_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.DUE_DATE$',
						'OHR.DUE_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.CUSTOMER_REQUIRED_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.CUSTOMER_REQUIRED_DATE$',
						'OHR.CUSTOMER_REQUIRED_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.ORDER_TYPE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.ORDER_TYPE$',
						'OHR.ORDER_TYPE');
      END IF;

	-- remove for R11.5.6
      /**IF INSTR(UPPER(p_replace_block),'$ORDER.ORDER_ACTION$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.ORDER_ACTION$',
						'OHR.ORDER_ACTION');
      END IF;**/

      IF INSTR(UPPER(p_replace_block),'$ORDER.ORDER_SOURCE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.ORDER_SOURCE$',
						'OHR.ORDER_SOURCE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.RELATED_ORDER_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.RELATED_ORDER_ID$',
						'OHR.RELATED_ORDER_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.ORG_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.ORG_ID$',
						'OHR.ORG_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.CUSTOMER_NAME$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.CUSTOMER_NAME$',
						'OHR.CUSTOMER_NAME');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.CUSTOMER_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.CUSTOMER_ID$',
						'OHR.CUSTOMER_ID');
      END IF;

	-- remove for R11.5.6
     /*** IF INSTR(UPPER(p_replace_block),'$ORDER.SERVICE_PROVIDER_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.SERVICE_PROVIDER_ID$',
						'OHR.SERVICE_PROVIDER_ID');
      END IF;***/

      IF INSTR(UPPER(p_replace_block),'$ORDER.TELEPHONE_NUMBER$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.TELEPHONE_NUMBER$',
						'OHR.TELEPHONE_NUMBER');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.ORDER_STATUS$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.ORDER_STATUS$',
						'OHR.STATUS_CODE');
      END IF;


      IF INSTR(UPPER(p_replace_block),'$ORDER.ACTUAL_PROVISIONING_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.ACTUAL_PROVISIONING_DATE$',
						'OHR.ACTUAL_PROVISIONING_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.COMPLETION_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.COMPLETION_DATE$',
						'OHR.COMPLETION_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.PREVIOUS_ORDER_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.PREVIOUS_ORDER_ID$',
						'OHR.PREVIOUS_ORDER_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.NEXT_ORDER_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.NEXT_ORDER_ID$',
						'OHR.NEXT_ORDER_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$ORDER.SDP_ORDER_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$ORDER.SDP_ORDER_ID$',
						'OHR.ORDER_ID');
      END IF;

	lv_loc := INSTR(UPPER(p_replace_block),'$ORDER.');
      IF lv_loc > 0 THEN
	  lv_loc2 := INSTR(UPPER(p_replace_block),'$',lv_loc,2);
	  if lv_loc2 = 0 then
		lv_loc2 := LENGTH(p_replace_block);
	  end if;
	  return_code := -191293;
	  FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_HEADER_ERROR');
	  FND_MESSAGE.SET_TOKEN('HEADER_ATTR', SUBSTR(p_replace_block, lv_loc,lv_loc2- lv_loc + 1));
	  error_description := FND_MESSAGE.GET;
	  return;
      END IF;


EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Find_Replace_Ord_Header;

--
-- Find and replace order Line attribute on the where block
--
PROCEDURE Find_Replace_Line(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2)
IS
  lv_loc number;
  lv_loc2 number;
BEGIN
	return_code := 0;
	p_found_flag := FALSE;
	p_replace_block := p_where_block;

      IF INSTR(UPPER(p_replace_block),'$LINE.LINE_NUMBER$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.LINE_NUMBER$',
						'OLM.LINE_NUMBER');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.LINE_ITEM_NAME$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.LINE_ITEM_NAME$',
						'OLM.LINE_ITEM_NAME');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.PROVISIONING_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.PROVISIONING_DATE$',
						'OLM.PROVISIONING_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.PRIORITY$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.PRIORITY$',
						'OLM.PRIORITY');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.DUE_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.DUE_DATE$',
						'OLM.DUE_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.CUSTOMER_REQUIRED_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.CUSTOMER_REQUIRED_DATE$',
						'OLM.CUSTOMER_REQUIRED_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.VERSION$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.VERSION$',
						'OLM.VERSION');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.ACTION$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.ACTION$',
						'OLM.LINE_ITEM_ACTION_CODE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.IS_WORKITEM_FLAG$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.IS_WORKITEM_FLAG$',
						'XDP_UTILITIES.OA_GET_LINE_WI_FLAG(line_item_id)');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.PROVISIONING_REQUIRED_FLAG$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.PROVISIONING_REQUIRED_FLAG$',
						'OLM.PROVISIONING_REQUIRED_FLAG');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.PROVISIONING_SEQUENCE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.PROVISIONING_SEQUENCE$',
						'OLM.LINE_SEQUENCE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.BUNDLE_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.BUNDLE_ID$',
						'OLM.BUNDLE_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.BUNDLE_SEQUENCE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.BUNDLE_SEQUENCE$',
						'OLM.BUNDLE_SEQUENCE');
      END IF;


       -- remove for R11.5.6
      /***IF INSTR(UPPER(p_replace_block),'$LINE.SERVICE_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.SERVICE_ID$',
						'OLM.SERVICE_ID');
      END IF;***/


  	-- remove for R11.5.6
      /***IF INSTR(UPPER(p_replace_block),'$LINE.PACKAGE_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.PACKAGE_ID$',
						'OLM.PACKAGE_ID');
      END IF;***/

      IF INSTR(UPPER(p_replace_block),'$LINE.LINE_STATUS$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.LINE_STATUS$',
						'OLM.STATUS_CODE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.COMPLETION_DATE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.COMPLETION_DATE$',
						'OLM.COMPLETION_DATE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.WORKITEM_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.WORKITEM_ID$',
						'OLM.WORKITEM_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$LINE.LINE_ITEM_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$LINE.LINE_ITEM_ID$',
						'OLM.LINE_ITEM_ID');
      END IF;

	lv_loc := INSTR(UPPER(p_replace_block),'$LINE.');
      IF lv_loc > 0 THEN
	  lv_loc2 := INSTR(UPPER(p_replace_block),'$',lv_loc,2);
	  if lv_loc2 = 0 then
		lv_loc2 := LENGTH(p_replace_block);
	  end if;
	  return_code := -191294;
	  FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_LINE_ATTR_ERROR');
	  FND_MESSAGE.SET_TOKEN('ERROR_STR', SUBSTR(p_replace_block, lv_loc,lv_loc2- lv_loc + 1));
	  error_description := FND_MESSAGE.GET;
	  return;
      END IF;

EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Find_Replace_Line;


--
-- Find and replace order Line parameter on the where block
--
PROCEDURE Find_Replace_Line_Param(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2)
IS
  lv_loc number;
  lv_loc2 number;
  lv_tmp_str1 varchar2(32000);
  lv_tmp_str2 varchar2(32000);
BEGIN
	return_code := 0;
	p_found_flag := FALSE;
	p_replace_block := p_where_block;
	IF INSTR(UPPER(p_replace_block),'$LINE_PARAM.') > 0 THEN
	  p_found_flag := TRUE;
	  p_replace_block := REPLACE(UPPER(p_replace_block),
				'$LINE_PARAM.',
				' XDP_UTILITIES.OA_GetLineParam(OLM.LINE_ITEM_ID,''');
	  lv_loc := INSTR(UPPER(p_replace_block),'OA_GETLINEPARAM');
	  while lv_loc > 0 loop
		lv_loc2 := INSTR(UPPER(p_replace_block),'$',lv_loc,1);
		IF lv_loc2 = 0 THEN
		  return_code := -191295;
	          FND_MESSAGE.SET_NAME('XDP', 'XDP_LINEPARAM_MACRO_ERROR');
	          error_description := FND_MESSAGE.GET;
		  return;
		ELSE
		  lv_loc := INSTR(UPPER(p_replace_block),'OA_GETLINEPARAM',lv_loc2);
		  lv_tmp_str1 := SUBSTR(p_replace_block,1,lv_loc2 - 1);
		  lv_tmp_str2 := SUBSTR(p_replace_block,lv_loc2 + 1);
		  p_replace_block := lv_tmp_str1 ||
					   ''')'||
					   lv_tmp_str2;
		END IF;
	  end loop;
	END IF;
EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Find_Replace_Line_Param;


--
-- Find and replace workitem attribute on the where block
--
PROCEDURE Find_Replace_WI(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2)
IS
  lv_loc number;
  lv_loc2 number;
BEGIN
	return_code := 0;
	p_found_flag := FALSE;
	p_replace_block := p_where_block;


      IF INSTR(UPPER(p_replace_block),'$WORKITEM.WORKITEM_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$WORKITEM.WORKITEM_ID$',
						'FWT.WORKITEM_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$WORKITEM.PROVISIONING_SEQUENCE$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$WORKITEM.PROVISIONING_SEQUENCE$',
						'FWT.WI_SEQUENCE');
      END IF;


      IF INSTR(UPPER(p_replace_block),'$WORKITEM.PRIORITY$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$WORKITEM.PRIORITY$',
						'FWT.PRIORITY');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$WORKITEM.WORKITEM_NAME$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
					'$WORKITEM.WORKITEM_NAME$',
					'XDP_UTILITIES.OA_GETWINAME(FWT.WORKITEM_INSTANCE_ID)');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$WORKITEM.WORKITEM_STATUS$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$WORKITEM.WORKITEM_STATUS$',
						'FWT.STATUS_CODE');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$WORKITEM.WORKITEM_INSTANCE_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$WORKITEM.WORKITEM_INSTANCE_ID$',
						'FWT.WORKITEM_INSTANCE_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$WORKITEM.LINE_NUMBER$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$WORKITEM.LINE_NUMBER$',
						'FWT.LINE_NUMBER');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$WORKITEM.LINE_ITEM_ID$') > 0 THEN
		p_found_flag := TRUE;
		p_replace_block := REPLACE(UPPER(p_replace_block),
						'$WORKITEM.LINE_ITEM_ID$',
						'FWT.LINE_ITEM_ID');
      END IF;

      IF INSTR(UPPER(p_replace_block),'$WORKITEM.ERROR_DESCRIPTION$') > 0 THEN
	  return_code := -191296;
	  FND_MESSAGE.SET_NAME('XDP', 'XDP_SEARCH_WI_ERROR');
	  error_description := FND_MESSAGE.GET;
      END IF;

	lv_loc := INSTR(UPPER(p_replace_block),'$WORKITEM.');
      IF lv_loc > 0 THEN
	  lv_loc2 := INSTR(UPPER(p_replace_block),'$',lv_loc,2);
	  if lv_loc2 = 0 then
		lv_loc2 := LENGTH(p_replace_block);
	  end if;
	  return_code := -191297;
	  FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_RECORD_ATTR_ERROR');
	  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SUBSTR(p_replace_block, lv_loc,lv_loc2- lv_loc + 1));
	  error_description := FND_MESSAGE.GET;
	  return;
      END IF;

EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Find_Replace_WI;


--
-- Find and replace workitem parameter on the where block
--
PROCEDURE Find_Replace_WI_Param(
	p_where_block IN VARCHAR2,
	p_replace_block OUT NOCOPY VARCHAR2,
	p_found_flag OUT NOCOPY BOOLEAN,
	return_code OUT NOCOPY NUMBER,
	error_description OUT NOCOPY VARCHAR2)
IS
  lv_loc number;
  lv_loc2 number;
  lv_tmp_str1 varchar2(32000);
  lv_tmp_str2 varchar2(32000);
BEGIN
	return_code := 0;
	p_found_flag := FALSE;
	p_replace_block := p_where_block;
	IF INSTR(UPPER(p_replace_block),'$WI_PARAM.') > 0 THEN
	  p_found_flag := TRUE;
	  p_replace_block := REPLACE(UPPER(p_replace_block),
				'$WI_PARAM.',
				' XDP_UTILITIES.OA_GetWIParam(FWT.WORKITEM_INSTANCE_ID,''');
	  lv_loc := INSTR(UPPER(p_replace_block),'OA_GETWIPARAM');
	  while lv_loc > 0 loop
		lv_loc2 := INSTR(UPPER(p_replace_block),'$',lv_loc,1);
		IF lv_loc2 = 0 THEN
		  return_code := -191298;
	          FND_MESSAGE.SET_NAME('XDP', 'XDP_WI_PARAM_MACRO_ERROR');
	          error_description := FND_MESSAGE.GET;
		  return;
		ELSE
		  lv_loc := INSTR(UPPER(p_replace_block),'OA_GETWIPARAM',lv_loc2);
		  lv_tmp_str1 := SUBSTR(p_replace_block,1,lv_loc2 - 1);
		  lv_tmp_str2 := SUBSTR(p_replace_block,lv_loc2 + 1);
		  p_replace_block := lv_tmp_str1 ||
					   ''')'||
					   lv_tmp_str2;
		END IF;
	  end loop;
	END IF;

EXCEPTION
WHEN OTHERS THEN
  return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPOAUTB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  error_description := FND_MESSAGE.GET;
END Find_Replace_WI_Param;

--  Added procedure to dynamically execute
-- user defined procedure for  validation of Workitem.

PROCEDURE Validate_Workitem(
                  p_order_id   IN NUMBER
                 ,p_line_item_id IN NUMBER
                 ,p_wi_instance_id IN NUMBER
                 ,p_procedure_name IN VARCHAR2
                 ,x_error_code    OUT NOCOPY NUMBER
                 ,x_error_message OUT NOCOPY VARCHAR2)
   IS
      lv_plsql_blk varchar2(32000);
   BEGIN

     x_error_code := 0;
     lv_plsql_blk := 'BEGIN  '||
                     p_procedure_name||
                     '(  :p_order_id,
                         :p_line_item_id,
 			 :p_wi_instance_id,
                         :x_error_code,
                         :x_error_message
                         ); end;';

     execute immediate lv_plsql_blk
      USING
             p_order_id
            ,p_line_item_id
            ,p_wi_instance_id
            ,OUT x_error_code
            ,OUT x_error_message;

   EXCEPTION
   WHEN OTHERS THEN
    x_error_code := SQLCODE;
    x_error_message := SQLERRM;
   END Validate_Workitem;

-- Overloaded Add_WI_toLine Function.
-- Calls user defined Validation procedure for Workitem.

 Function Add_WI_toLine(
         p_line_item_id IN NUMBER,
         p_workitem_id IN Number,
         p_provisioning_date IN Date default null,
         p_priority IN number Default 100,
         p_provisioning_seq IN Number Default 0,
         p_due_date IN Date Default NULL,
         p_customer_required_date IN DATE Default NULL,
         p_oa_added_flag  IN VARCHAR2 DEFAULT 'Y',
         x_error_code    OUT NOCOPY NUMBER,
         x_error_message OUT NOCOPY VARCHAR2)
  RETURN NUMBER
  IS

      lv_wi_instance_id  NUMBER:=0;
   BEGIN
     lv_wi_instance_id:= Add_WI_toLine(
 		p_line_item_id          => p_line_item_id,
 		p_workitem_id           => p_workitem_id,
 		p_provisioning_date     => p_provisioning_date,
                p_priority              => p_priority,
 		p_provisioning_seq      => p_provisioning_seq,
 		p_due_date              => p_due_date,
 		p_customer_required_date=> p_customer_required_date,
 		p_oa_added_flag         => p_oa_added_flag);

 IF  g_Validation_Enabled_Flag = 'Y' THEN
      Validate_Workitem(
                  p_order_id       => g_order_id
                 ,p_line_item_id   =>p_line_item_id
                 ,p_wi_instance_id =>lv_wi_instance_id
                 ,p_procedure_name =>g_Validation_Procedure
                 ,x_error_code     => x_error_code
                 ,x_error_message  => x_error_message);





 END IF;
return lv_wi_instance_id;

 EXCEPTION
   WHEN OTHERS THEN
    x_error_code := SQLCODE;
    x_error_message := SQLERRM;
    return lv_wi_instance_id;
 END Add_WI_toLine;

-- Overloaded Add_Wi_toLine Function.
-- Calls user defined Validation procedure for Workitem
Function Add_WI_toLine(
	p_line_item_id IN NUMBER,
	p_workitem_name IN VARCHAR2,
	p_workitem_version IN VARCHAR2 DEFAULT NULL,
	p_provisioning_date IN Date default NULL,
	p_priority IN number Default 100,
	p_provisioning_seq IN Number Default 0,
	p_due_date IN Date Default NULL,
	p_customer_required_date IN DATE Default NULL,
	p_oa_added_flag  IN VARCHAR2 DEFAULT 'Y',
        x_error_code     OUT NOCOPY NUMBER,
        x_error_message   OUT NOCOPY VARCHAR2)


  RETURN NUMBER
  IS

      lv_wi_instance_id NUMBER:=0;
   BEGIN
     lv_wi_instance_id:= Add_WI_toLine(
 		p_line_item_id          => p_line_item_id,
 		p_workitem_name         => p_workitem_name,
                p_workitem_version      => p_workitem_version,
 		p_provisioning_date     => p_provisioning_date,
                p_priority              => p_priority,
 		p_provisioning_seq      => p_provisioning_seq,
 		p_due_date              => p_due_date,
 		p_customer_required_date=> p_customer_required_date,
 		p_oa_added_flag         => p_oa_added_flag);

 IF  g_Validation_Enabled_flag = 'Y' THEN
      Validate_Workitem(
                  p_order_id        =>g_order_id
                 ,p_line_item_id    =>p_line_item_id
                 ,p_wi_instance_id  =>lv_wi_instance_id
                 ,p_procedure_name  =>g_Validation_Procedure
                 ,x_error_code      => x_error_code
                 ,x_error_message   => x_error_message);


END IF;
return lv_wi_instance_id;

 EXCEPTION
   WHEN OTHERS THEN
    x_error_code := SQLCODE;
    x_error_message := SQLERRM;
 return lv_wi_instance_id;
 END Add_WI_toLine;



END XDP_OA_UTIL;

/
