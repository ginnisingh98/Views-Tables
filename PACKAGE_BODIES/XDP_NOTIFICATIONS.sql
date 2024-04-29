--------------------------------------------------------
--  DDL for Package Body XDP_NOTIFICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_NOTIFICATIONS" AS
/* $Header: XDPNOTFB.pls 120.1 2005/06/09 00:18:39 appldev  $ */

--
--Wrapper API for OA Framework 5.6
--
PROCEDURE WI_Response(
        p_workitem_instance_id IN NUMBER,
        p_parameter_name       IN VARCHAR2,
        p_parameter_value      IN VARCHAR2,
        p_parameter_old_value  IN VARCHAR2,
        p_order_id             IN VARCHAR2,
        p_itemtype             IN VARCHAR2,
        p_itemkey              IN VARCHAR2)
 IS
 p_order_retry_params           XDP_TYPES.FMC_RETRY_PARAM_LIST;
 p_workitem_retry_params        XDP_TYPES.FMC_RETRY_PARAM_LIST;
 p_fa_retry_params              XDP_TYPES.FMC_RETRY_PARAM_LIST;
 p_response                     VARCHAR2(30);
 p_fa_instance_id               NUMBER:=NULL;
 return_code                    NUMBER;
 error_description              VARCHAR2(240);


 BEGIN

    --will take these out later
    p_response := 'RETRY_FA_PROCESSING';
    p_workitem_retry_params(1).PARAMETER_NAME := p_parameter_name;
    p_workitem_retry_params(1).PARAM_RETRY_VAL := p_parameter_value;
    p_workitem_retry_params(1).PARAM_PREVIOUS_VAL := p_parameter_old_value;

    XDP_Notifications.NotificationResponse(
       p_response                => p_response,
       p_order_id                => p_order_id,
       p_workitem_instance_id    => p_workitem_instance_id,
       p_fa_instance_id          => p_fa_instance_id,
       P_ORDER_RETRY_PARAMS      => p_order_retry_params,
       P_workitem_RETRY_PARAMS   => p_workitem_retry_params,
       P_FA_RETRY_PARAMS         => p_fa_retry_params,
       p_workflow_Item_Type      => p_itemtype,
       p_workflow_ItemKey        => p_itemkey ,
       RETURN_CODE               => return_code,
       ERROR_DESCRIPTION         => error_description);

  EXCEPTION
  WHEN OTHERS THEN
        return_code := 1;
        error_description := SUBSTR(SQLERRM,1,280);
 END WI_Response;

--
--API for getting URL link to modify WI params
--
Procedure Get_WI_Update_URL(
        p_workitem_instance_id IN NUMBER,
        p_order_id             IN NUMBER,
        p_itemtype             IN VARCHAR2,
        p_itemkey              IN VARCHAR2,
        x_url                 OUT NOCOPY VARCHAR2)
IS
l_click_here VARCHAR2(30);
l_text VARCHAR2(100);
BEGIN

      FND_MESSAGE.SET_NAME('XDP','XDP_WI_URL_LINK_CLICK_HERE');
      l_click_here :=FND_MESSAGE.GET || fnd_global.local_CHR(10);

      FND_MESSAGE.SET_NAME('XDP','XDP_WI_URL_LINK_TEXT');
      l_text := FND_MESSAGE.GET || fnd_global.local_CHR(10);

      FND_MESSAGE.SET_NAME('XDP','XDP_WI_URL_LINK');
      FND_MESSAGE.SET_TOKEN('WI_INSTANCE_ID',p_workitem_instance_id);
      FND_MESSAGE.SET_TOKEN('CLICK_HERE',l_click_here);
      FND_MESSAGE.SET_TOKEN('TO_UPDATE_WI_PARAM',l_text);
      FND_MESSAGE.SET_TOKEN('ITEM_KEY',p_itemkey);
      FND_MESSAGE.SET_TOKEN('ORDER_ID',p_order_id);
      FND_MESSAGE.SET_TOKEN('ITEM_TYPE',p_itemtype);
      x_url := FND_MESSAGE.GET || fnd_global.local_CHR(10);

END Get_WI_Update_URL;


--
 --API for Upstream systems to perform FMC function
 --
 PROCEDURE NotificationResponse(
	p_response IN VARCHAR2,
	p_order_id IN NUMBER,
 	P_workitem_instance_id IN NUMBER,
 	P_fa_instance_id IN NUMBER,
 	P_ORDER_RETRY_PARAMS    IN OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
 	P_workitem_RETRY_PARAMS IN OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
 	P_FA_RETRY_PARAMS       IN OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
 	p_workflow_Item_Type IN VARCHAR2 ,
	p_workflow_ItemKey   IN VARCHAR2 ,
	RETURN_CODE IN OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION IN OUT NOCOPY VARCHAR2)
 IS
   lv_param_index BINARY_INTEGER;
   lv_fmc_id INTEGER;
   lv_param_check VARCHAR2(1);
   lv_fe_id  number;
   lv_fe_name varchar2(40);
   lv_sw_generic varchar2(40);
   lv_adapter varchar2(40);
   lv_fetype_id number;
   lv_fetype varchar2(40);
   lv_count number;
   lv_param_old_val varchar2(4000);

 -- PL/SQL Block
BEGIN

  return_code := 0;

  /* Check null condition */
  IF p_response IS NULL THEN
    return_code := 1;
    error_description := 'Error: Response code is required.';
    return;
  ELSIF P_workitem_instance_ID IS NULL THEN
    return_code := 1;
    error_description := 'Error: workitem instance id is required.';
    return;
  END IF;


  /* populate fmc audit trail */
  SAVEPOINT FMC_UPDATE;
  select XDP_FMC_ID_S.NextVal
	into lv_fmc_id from dual;

  IF p_fa_instance_id is not null then
    select fe_id into lv_fe_id
    from xdp_fa_runtime_list
    where fa_instance_id = p_fa_instance_id;

    XDP_ENGINE.Get_FE_ConfigInfo(
		lv_fe_id,
		lv_fe_name,
		lv_fetype_id,
		lv_fetype,
	      lv_sw_generic,
		lv_adapter);
  end if;

  INSERT INTO XDP_FMC_AUDIT_TRAILS(
	 created_by,
	 creation_date,
	 last_updated_by,
	 last_update_date,
	 last_update_login,
  	 fmc_id,
	 workitem_instance_id,
     fmc_response_code,
	 wf_item_type,
	 wf_item_key,
	 fe_name,
     sw_generic)
   VALUES(
	 FND_GLOBAL.USER_ID,
	 sysdate,
	 FND_GLOBAL.USER_ID,
	 sysdate,
	 FND_GLOBAL.LOGIN_ID,
	 lv_fmc_id,
	 p_workitem_instance_id,
	 p_response,
	 p_workflow_item_type,
	 p_workflow_itemkey,
	 lv_fe_name,
	 lv_sw_generic
	);

  IF P_ORDER_RETRY_PARAMS.COUNT > 0 THEN
     lv_param_index := p_order_retry_params.first;
     for lv_count in 1..p_order_retry_params.count loop

	 XDP_ENGINE.SET_ORDER_PARAM_VALUE(
		p_order_id => p_order_id,
		p_parameter_name =>p_order_retry_params(lv_param_index).parameter_name,
		p_parameter_value => p_order_retry_params(lv_param_index).param_retry_val);

	 insert into XDP_FMC_AUD_TRAIL_DETS(
	 	created_by,
	 	creation_date,
	 	last_updated_by,
	 	last_update_date,
	 	last_update_login,
		fmc_id,
 		parameter_name,
		parameter_type,
		value,
		retry_value)
	 values (
	 	FND_GLOBAL.USER_ID,
	 	sysdate,
	 	FND_GLOBAL.USER_ID,
	 	sysdate,
	 	FND_GLOBAL.LOGIN_ID,
		lv_fmc_id,
		p_order_retry_params(lv_param_index).parameter_name,
		'ORDER',
		p_order_retry_params(lv_param_index).param_previous_val,
		p_order_retry_params(lv_param_index).param_retry_val);

       lv_param_index := p_order_retry_params.next(lv_param_index);
     end loop;
  END IF;

  IF P_WORKITEM_RETRY_PARAMS.COUNT > 0 THEN
     lv_param_index := p_workitem_retry_params.first;
     for lv_count in 1..p_workitem_retry_params.count loop

	 XDP_ENGINE.SET_WORKITEM_PARAM_VALUE(
		p_wi_instance_id => p_workitem_instance_id,
		p_parameter_name =>p_workitem_retry_params(lv_param_index).parameter_name,
		p_parameter_value => p_workitem_retry_params(lv_param_index).param_retry_val);

	 insert into XDP_FMC_AUD_TRAIL_DETS(
	 	created_by,
	 	creation_date,
	 	last_updated_by,
	 	last_update_date,
	 	last_update_login,
		fmc_id,
 		parameter_name,
		parameter_type,
		value,
		retry_value)
	 values (
	 	FND_GLOBAL.USER_ID,
	 	sysdate,
	 	FND_GLOBAL.USER_ID,
	 	sysdate,
	 	FND_GLOBAL.LOGIN_ID,
		lv_fmc_id,
		p_workitem_retry_params(lv_param_index).parameter_name,
		'WORKITEM',
		p_workitem_retry_params(lv_param_index).param_previous_val,
		p_workitem_retry_params(lv_param_index).param_retry_val);

       lv_param_index := p_workitem_retry_params.next(lv_param_index);
     end loop;
  END IF;

  IF P_FA_RETRY_PARAMS.COUNT > 0 THEN
     lv_param_index := p_fa_retry_params.first;
     for lv_count in 1..p_fa_retry_params.count loop

	 XDP_ENGINE.SET_FA_PARAM_VALUE(
		p_fa_instance_id => p_fa_instance_id,
		p_parameter_name =>p_fa_retry_params(lv_param_index).parameter_name,
		p_parameter_value => p_fa_retry_params(lv_param_index).param_retry_val);

	 insert into XDP_FMC_AUD_TRAIL_DETS(
	 	created_by,
	 	creation_date,
	 	last_updated_by,
	 	last_update_date,
	 	last_update_login,
		fmc_id,
 		parameter_name,
		parameter_type,
		value,
		retry_value)
	 values (
	 	FND_GLOBAL.USER_ID,
	 	sysdate,
	 	FND_GLOBAL.USER_ID,
	 	sysdate,
	 	FND_GLOBAL.LOGIN_ID,
		lv_fmc_id,
		p_fa_retry_params(lv_param_index).parameter_name,
		'FA',
		p_fa_retry_params(lv_param_index).param_previous_val,
		p_fa_retry_params(lv_param_index).param_retry_val);

       lv_param_index := p_fa_retry_params.next(lv_param_index);
     end loop;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
  	return_code := 1;
  	error_description := SUBSTR(SQLERRM,1,280);
	ROLLBACK  TO SAVEPOINT FMC_UPDATE;
 END NotificationResponse;

 --
 -- Returns the latest service parameter changes for a work item
 --
 -- When             Who      What
 -- 07/21/2001       rnyberg  Changed SELECT statement which returned service name as
--                            DECODE(olm.service_id,NULL,NULL,line_item_name)
--                            to instead just return line_item_name.
 --
 Procedure Get_Latest_FMC_Changes(
	p_workitem_instance_id IN NUMBER,
	p_order_id  OUT NOCOPY NUMBER,
	p_service_name OUT NOCOPY VARCHAR2,
	p_service_version OUT NOCOPY VARCHAR2,
	p_action_code OUT NOCOPY VARCHAR2,
	p_workitem_name OUT NOCOPY VARCHAR2,
	p_fmc_response OUT NOCOPY VARCHAR2,
	p_order_param_change_list OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
	p_wi_param_change_list OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
	p_fa_param_change_list OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
      return_code OUT NOCOPY NUMBER,
      error_description OUT NOCOPY VARCHAR2)
 IS
    CURSOR lc_last_fmc IS
	select fmc_id,fmc_response_code
	from xdp_fmc_audit_trails
	where
	  workitem_instance_id = p_workitem_instance_id
	order by fmc_id desc;

    CURSOR lc_last_params(l_fmc_id number) IS
	select parameter_name,value,retry_value,parameter_type
	from XDP_FMC_AUD_TRAIL_DETS
	where fmc_id = l_fmc_id;
   lv_fmc_id NUMBER := NULL;
   lv_ord_index BINARY_INTEGER := 0;
   lv_wi_index BINARY_INTEGER := 0;
   lv_fa_index BINARY_INTEGER := 0;

 begin

     return_code := 0;
     FOR lv_fmc_rec in lc_last_fmc loop
	  p_fmc_response := lv_fmc_rec.fmc_response_code;
	  lv_fmc_id := lv_fmc_rec.fmc_id;
	  exit;
     END LOOP;

    IF lv_fmc_id IS NOT NULL THEN
	select fwt.order_id,
		line_item_name,
		DECODE(olm.workitem_id,NULL,NULL,line_item_name),
		olm.line_item_action_code,
		olm.version
	into
		p_order_id,
		p_service_name,
		p_workitem_name,
		p_action_code,
		p_service_version
	from
		XDP_FULFILL_WORKLIST fwt,
		xdp_order_line_items olm
	where
		fwt.workitem_instance_id = p_workitem_instance_id and
		fwt.line_item_id = olm.line_item_id;

	FOR lv_param_rec in lc_last_params(lv_fmc_id) loop
	  IF lv_param_rec.parameter_type = 'ORDER' THEN
		lv_ord_index := lv_ord_index + 1;
		p_order_param_change_list(lv_ord_index).parameter_name :=
			lv_param_rec.parameter_name;
		p_order_param_change_list(lv_ord_index).param_previous_val :=
			lv_param_rec.value;
		p_order_param_change_list(lv_ord_index).param_retry_val :=
			lv_param_rec.retry_value;
	  ELSIF lv_param_rec.parameter_type = 'WORKITEM' THEN
		lv_wi_index := lv_wi_index + 1;
		p_wi_param_change_list(lv_wi_index).parameter_name :=
			lv_param_rec.parameter_name;
		p_wi_param_change_list(lv_wi_index).param_previous_val :=
			lv_param_rec.value;
		p_wi_param_change_list(lv_wi_index).param_retry_val :=
			lv_param_rec.retry_value;
	  ELSIF lv_param_rec.parameter_type = 'FA' THEN
		lv_fa_index := lv_fa_index + 1;
		p_fa_param_change_list(lv_fa_index).parameter_name :=
			lv_param_rec.parameter_name;
		p_fa_param_change_list(lv_fa_index).param_previous_val :=
			lv_param_rec.value;
		p_fa_param_change_list(lv_fa_index).param_retry_val :=
			lv_param_rec.retry_value;
	  END IF;
	END LOOP;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
  	return_code := SQLCODE;
  	error_description := SUBSTR(SQLERRM,1,280);
 END Get_Latest_FMC_Changes;

END XDP_NOTIFICATIONS;

/
