--------------------------------------------------------
--  DDL for Package Body XDP_ENG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ENG_UTIL" AS
/* $Header: XDPENGUB.pls 120.1 2005/06/15 22:57:10 appldev  $ */


Procedure Load_FA_Runtime_List( p_wi_instance_id IN NUMBER,
				p_fa_id		 IN NUMBER,
				p_status	 IN VARCHAR2,
				p_fe_id		 IN NUMBER,
				p_prov_seq	 IN NUMBER,
				p_priority	 IN NUMBER,
				p_fa_instance_id OUT NOCOPY NUMBER);

-- PL/SQL Specification

 /*
   This function will add a fulfillment action instnace
   to a workitem instance.  The FA instance ID will return.
  */
 FUNCTION Add_FA_toWI
           (p_wi_instance_id    IN NUMBER,
	    p_fa_name           IN VARCHAR2,
	    p_fe_name           IN VARCHAR2 DEFAULT NULL,
	    p_priority          IN number default 100,
	    p_provisioning_seq  IN NUMBER default 0)
   return NUMBER IS

  lv_fa_instance_id NUMBER;
  lv_fa_id          NUMBER := -1;
  lv_fe_id          NUMBER := -1;

  CURSOR lc_fa_param(l_fa_id number) IS
	 SELECT parameter_name,
                NVL(evaluation_seq,0)
	   FROM xdp_fa_parameters
          WHERE fulfillment_action_id = l_fa_id
	  ORDER by evaluation_seq;

  CURSOR c_GetFAID IS
         SELECT fulfillment_action_id
           FROM XDP_FULFILL_ACTIONS
           WHERE fulfillment_action = p_fa_name;

  CURSOR c_GetFEID is
         SELECT fe_id
           FROM XDP_FES
          WHERE fulfillment_element_name = p_fe_name;

BEGIN

  FOR v_GetFAID in c_GetFAID
      LOOP
	lv_fa_id := v_GetFAID.fulfillment_action_id;
	EXIT;
      END LOOP;

  IF lv_fa_id = -1 THEN
	RAISE no_data_found;
  END IF;

  IF p_fe_name IS NOT NULL THEN
    FOR v_GetFEID in c_GetFEID
        LOOP
           lv_fe_id := v_GetFEID.fe_id;
   	   EXIT;
        END LOOP;

    IF lv_fe_id = -1 THEN
	RAISE no_data_found;
    END IF;
  ELSE
    lv_fe_id := NULL;
  END IF;

	Load_FA_Runtime_List(   p_wi_instance_id => Add_FA_toWI.p_wi_instance_id,
				p_fa_id => lv_fa_id,
				p_status => 'STANDBY',
				p_fe_id => lv_fe_id,
				p_prov_seq => p_provisioning_seq,
				p_priority => p_priority,
				p_fa_instance_id => lv_fa_instance_id);

  For lv_param_rec in lc_fa_param(lv_fa_id) loop
    BEGIN
	XDP_ENGINE.Set_FA_Param_value(
		p_fa_instance_id => lv_fa_instance_id,
		p_parameter_name => lv_param_rec.parameter_name,
		p_parameter_value => NULL,
		p_evaluation_required => TRUE);
      EXCEPTION
        WHEN OTHERS THEN
          raise;
    END;
  END loop;

  return lv_fa_instance_id;
 EXCEPTION
   when others then
     xdpcore.context( 'XDP_ENG_UTIL', 'Add_FA_toWI', 'WI',p_wi_instance_id );
     raise;

END Add_FA_toWI;

 /*
   This function will add a fulfillment action instnace
   to a workitem instance.  The FA instance ID will return.
   This is an overload function which takes the fulfillment
   action ID as one of its arguments.
  */

 FUNCTION Add_FA_toWI(
	p_wi_instance_id 	IN   NUMBER,
	p_fulfillment_action_id IN   NUMBER,
	p_fe_name               IN VARCHAR2 DEFAULT NULL,
	p_priority              IN NUMBER default 100,
	p_provisioning_seq      IN NUMBER default 0)
   RETURN NUMBER
IS
  lv_fa_instance_id NUMBER;
  lv_fe_id          NUMBER := -1;
  lv_dummy          NUMBER;

  CURSOR lc_fa_param IS
	SELECT parameter_name,
               NVL(evaluation_seq,0)
	  FROM xdp_fa_parameters
         WHERE fulfillment_action_id = p_fulfillment_action_id
 	 ORDER BY evaluation_seq;

  CURSOR c_GetFEID IS
         SELECT fe_id
           FROM XDP_FES
           WHERE fulfillment_element_name = p_fe_name;
BEGIN

  /* Check if the fa ID exists in our configuration table*/
  select 1 into lv_dummy
  from XDP_FULFILL_ACTIONS
  where fulfillment_action_id = p_fulfillment_action_id;

  if p_fe_name is not null then
    For v_GetFEID in c_GetFEID loop
	lv_fe_id := v_GetFEID.fe_id;
	exit;
    end loop;

    if lv_fe_id = -1 then
	raise no_data_found;
    end if;

  else
    lv_fe_id := NULL;
  END IF;

	Load_FA_Runtime_List(   p_wi_instance_id => Add_FA_toWI.p_wi_instance_id,
				p_fa_id => p_fulfillment_action_id,
				p_status => 'STANDBY',
				p_fe_id => lv_fe_id,
				p_prov_seq => p_provisioning_seq,
				p_priority => p_priority,
				p_fa_instance_id => lv_fa_instance_id);

  For lv_param_rec in lc_fa_param loop
	XDP_ENGINE.Set_FA_Param_value(
		p_fa_instance_id => lv_fa_instance_id,
		p_parameter_name => lv_param_rec.parameter_name,
		p_parameter_value => NULL,
		p_evaluation_required => TRUE);
  END loop;

  return lv_fa_instance_id;

exception
  when others then
   xdpcore.context( 'XDP_ENG_UTIL', 'Add_FA_toWI', 'WI', p_wi_instance_id );
   raise;
END Add_FA_toWI;


 /*
   This function will add a fulfillment action instnace
   to a workitem instance.  The FA instance ID will return.
   This is an overloaded with FE_ID as input
  */
 FUNCTION Add_FA_toWI(
	p_wi_instance_id IN NUMBER,
	p_fa_name   IN VARCHAR2,
	p_fe_id  IN NUMBER DEFAULT NULL,
	p_priority  IN number default 100,
	p_provisioning_seq  IN NUMBER default 0)
   return NUMBER
IS
  lv_fa_instance_id NUMBER;
  lv_fa_id  NUMBER := -1;
  lv_fe_id  NUMBER := -1;

  CURSOR lc_fa_param(l_fa_id number) IS
	select parameter_name,
             NVL(evaluation_seq,0)
	from xdp_fa_parameters
      where
         fulfillment_action_id = l_fa_id
	order by evaluation_seq;

  CURSOR c_GetFAID is
   select fulfillment_action_id
  from XDP_FULFILL_ACTIONS
  where fulfillment_action = p_fa_name;

BEGIN

  For v_GetFAID in c_GetFAID loop
	lv_fa_id := v_GetFAID.fulfillment_action_id;
	exit;
  end loop;

  if lv_fa_id = -1 then
	raise no_data_found;
  end if;

	Load_FA_Runtime_List(   p_wi_instance_id => Add_FA_toWI.p_wi_instance_id,
				p_fa_id => lv_fa_id,
				p_status => 'STANDBY',
				p_fe_id => Add_FA_toWI.p_fe_id,
				p_prov_seq => p_provisioning_seq,
				p_priority => p_priority,
				p_fa_instance_id => lv_fa_instance_id);

  For lv_param_rec in lc_fa_param(lv_fa_id) loop
	XDP_ENGINE.Set_FA_Param_value(
		p_fa_instance_id => lv_fa_instance_id,
		p_parameter_name => lv_param_rec.parameter_name,
		p_parameter_value => NULL,
		p_evaluation_required => TRUE);
  END loop;

  return lv_fa_instance_id;

END Add_FA_toWI;


 /*
   This function will resubmit a fulfillment action instnace
   for a workitem instance.  The FA instance ID will return.
  */

 FUNCTION Resubmit_FA(
	p_resubmission_job_id 	IN   NUMBER,
	p_resub_fa_instance_id  IN   NUMBER)
   return NUMBER
IS
  lv_fa_instance_id NUMBER;

BEGIN
  select XDP_FA_RUNTIME_LIST_S.nextval
  into lv_fa_instance_id
  from  dual;

  insert into xdp_fa_runtime_list
  (fa_instance_id,
   workitem_instance_id,
   fulfillment_action_id,
   status_code,
   resubmission_job_id,
   fe_id,
   provisioning_sequence,
   priority,
   start_provisioning_date,
   created_by,
   creation_date,
   last_updated_by,
   last_update_date,
   last_update_login
   )
  select
   lv_fa_instance_id,
   workitem_instance_id,
   fulfillment_action_id ,
   'STANDBY',
   p_resubmission_job_id ,
   fe_id,
   provisioning_sequence,
   priority,
   sysdate,
   FND_GLOBAL.USER_ID,
   sysdate,
   FND_GLOBAL.USER_ID,
   sysdate,
   FND_GLOBAL.LOGIN_ID
  from
    xdp_fa_runtime_list
  where
    fa_instance_id = p_resub_fa_instance_id;

  insert into xdp_fa_details(
    fa_instance_id,
    parameter_name,
    fulfillment_action_id,
    is_value_evaluated,
    parameter_value,
    parameter_ref_value,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
  )
  select
    lv_fa_instance_id,
    parameter_name,
    fulfillment_action_id,
    is_value_evaluated,
    parameter_value,
    parameter_ref_value,
    FND_GLOBAL.USER_ID,
    sysdate,
    FND_GLOBAL.USER_ID,
    sysdate,
    FND_GLOBAL.LOGIN_ID
  from
    xdp_fa_details
  where
    fa_instance_id = p_resub_fa_instance_id;

  return lv_fa_instance_id;

END Resubmit_FA;



 /*
   This procedure will execute the SFM FA execution
   process.  The workflow item type and item key for
   the workitem are needed to establish parent child
   relationship between the WI workflow and the FA
   process.  At the end of the FA process, a call
   to CONTINUEFLOW will be made to notify its parent
   to continue process.
  */
 PROCEDURE Execute_FA(
		p_order_id       IN NUMBER,
		p_wi_instance_id IN NUMBER,
		p_fa_instance_id IN NUMBER,
		p_wi_item_type   IN varchar2,
		p_wi_item_key    IN varchar2,
		p_return_code    OUT NOCOPY NUMBER,
		p_error_description  OUT NOCOPY VARCHAR2,
		p_fa_caller  IN VARCHAR2 DEFAULT 'EXTERNAL')
IS

  lv_fa_itemtype varchar2(8);
  lv_fa_itemkey  varchar2(240);
  lv_priority  number;
  lv_master varchar2(240);

  CURSOR c_GetPriority is
   select priority
   from xdp_fa_runtime_list
   where
     fa_instance_id = p_fa_instance_id;

BEGIN
	p_return_code := 0;

   for v_GetPriority in c_GetPriority loop
	lv_priority := v_GetPriority.priority;
	exit;
   end loop;

   /*
     Create FA workflow process
   */


      XDPCORE_FA.CreateFAProcess(
			orderID => p_order_id,
			WIInstanceID => p_wi_instance_id,
			FAInstanceID => p_fa_instance_id,
			ParentItemType =>p_wi_item_type,
			ParentItemKey => p_wi_item_key,
			FACaller => p_fa_caller,
			FAMaster => lv_master,
			FAItemType => lv_fa_itemtype,
			FAItemKey => lv_fa_itemkey,
			ErrCode => p_return_code,
			ErrStr => p_error_description);


   If p_return_code = 0 Then
      XDP_AQ_UTILITIES.Add_FA_ToQ(
		p_order_id => p_order_id,
		p_wi_instance_id => p_wi_instance_id,
		p_fa_instance_id => p_fa_instance_id,
	        p_wf_item_type => lv_fa_itemtype ,
                p_wf_item_key => lv_fa_itemkey,
		p_priority => lv_priority,
		p_return_code => p_return_code,
		p_error_description => p_error_description);
   END If;


EXCEPTION
WHEN OTHERS THEN
  p_return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGUB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  p_error_description := FND_MESSAGE.GET;
END Execute_FA;

 /*
   This procedure will execute the SFM FA execution
   process for resubmission. The workflow item type and item key for
   the workitem are needed to establish parent child
   relationship between the WI workflow and the FA
   process.  At the end of the FA process, a call
   to CONTINUEFLOW will be made to notify its parent
   to continue process.
  */
 PROCEDURE Execute_Resubmit_FA(
		p_order_id       IN NUMBER,
		p_line_item_id   IN NUMBER,
		p_wi_instance_id IN NUMBER,
		p_fa_instance_id IN NUMBER,
		p_oru_item_type   IN varchar2,
		p_oru_item_key    IN varchar2,
		p_fa_master		IN VARCHAR2,
		p_resubmission_job_id IN NUMBER,
		p_return_code    OUT NOCOPY NUMBER,
		p_error_description  OUT NOCOPY VARCHAR2,
		p_fa_caller  IN VARCHAR2 DEFAULT 'EXTERNAL')
IS

  lv_fa_itemtype varchar2(8);
  lv_fa_itemkey  varchar2(240);
  lv_priority  number;
  lv_master varchar2(240);

  CURSOR c_GetPriority is
   select priority
   from xdp_fa_runtime_list
   where
     fa_instance_id = p_fa_instance_id;

BEGIN
	p_return_code := 0;

   for v_GetPriority in c_GetPriority loop
	lv_priority := v_GetPriority.priority;
	exit;
   end loop;

   /*
     Create FA workflow process
   */


      XDPCORE_FA.CreateFAProcess(
			orderID => p_order_id,
			lineItemID => p_line_item_id,
			WIInstanceID => p_wi_instance_id,
			FAInstanceID => p_fa_instance_id,
			ParentItemType =>p_oru_item_type,
			ParentItemKey => p_oru_item_key,
			FACaller => p_fa_caller,
			FAMaster => p_fa_master,
			resubmissionJobID => p_resubmission_job_id,
			FAItemType => lv_fa_itemtype,
			FAItemKey => lv_fa_itemkey,
			ErrCode => p_return_code,
			ErrStr => p_error_description);


   If p_return_code = 0 Then
      XDP_AQ_UTILITIES.Add_FA_ToQ(
		p_order_id => p_order_id,
		p_wi_instance_id => p_wi_instance_id,
		p_fa_instance_id => p_fa_instance_id,
	        p_wf_item_type => lv_fa_itemtype ,
                p_wf_item_key => lv_fa_itemkey,
		p_priority => lv_priority,
		p_return_code => p_return_code,
		p_error_description => p_error_description);
   END If;


EXCEPTION
WHEN OTHERS THEN
  p_return_code := -191266;
  FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
  FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGUB');
  FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
  p_error_description := FND_MESSAGE.GET;
END Execute_Resubmit_FA;


Procedure Load_FA_Runtime_List( p_wi_instance_id IN NUMBER,
				p_fa_id		 IN NUMBER,
				p_status	 IN VARCHAR2,
				p_fe_id		 IN NUMBER,
				p_prov_seq	 IN NUMBER,
				p_priority	 IN NUMBER,
				p_fa_instance_id OUT NOCOPY NUMBER)
is

begin

  insert into xdp_fa_runtime_list
  (fa_instance_id,
   workitem_instance_id,
   fulfillment_action_id,
   status_code,
   fe_id,
   provisioning_sequence,
   priority,
   start_provisioning_date,
   created_by,
   creation_date,
   last_updated_by,
   last_update_date,
   last_update_login
   )
  values
  ( XDP_FA_RUNTIME_LIST_S.nextval,
   p_wi_instance_id,
   p_fa_id,
   p_status,
   p_fe_id,
   p_prov_seq,
   p_priority,
   sysdate,
   FND_GLOBAL.USER_ID,
   sysdate,
   FND_GLOBAL.USER_ID,
   sysdate,
   FND_GLOBAL.LOGIN_ID
  ) returning fa_instance_id into p_fa_instance_id;

exception
  When others then
   raise;
end Load_FA_Runtime_List;


END XDP_ENG_UTIL;

/
