--------------------------------------------------------
--  DDL for Package Body XDP_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ENGINE" AS
/* $Header: XDPENGNB.pls 120.1 2005/06/15 22:56:01 appldev  $ */


    Procedure Get_WI_Parameter_info (p_wi_instance_id 	  IN NUMBER,
				   p_parameter_name 	  IN VARCHAR2,
				   p_evaluation_procedure OUT NOCOPY VARCHAR2,
				   p_evaluation_mode	  OUT NOCOPY VARCHAR2,
				   p_default_value	  OUT NOCOPY VARCHAR2,
				   p_parameter_value	  OUT NOCOPY VARCHAR2,
				   p_parameter_ref_value  OUT NOCOPY VARCHAR2,
				   p_audit_flag		  OUT NOCOPY VARCHAR2,
				   p_workitem_id	  OUT NOCOPY NUMBER);

    Procedure Get_FA_Parameter_info (p_fa_instance_id 	  IN NUMBER,
				   p_parameter_name 	  IN VARCHAR2,
				   p_evaluation_procedure OUT NOCOPY VARCHAR2,
				   p_fa_id		  OUT NOCOPY NUMBER,
				   p_default_value	  OUT NOCOPY VARCHAR2,
				   p_parameter_value	  OUT NOCOPY VARCHAR2,
				   p_parameter_ref_value  OUT NOCOPY VARCHAR2,
				   p_audit_flag		  OUT NOCOPY VARCHAR2);

    Function DoesWIParamExist (p_wi_instance_id IN NUMBER,
			     p_parameter_name IN VARCHAR2) return VARCHAR2;


    Function DoesFAParamExist (p_fa_instance_id IN NUMBER,
			     p_parameter_name IN VARCHAR2) return VARCHAR2;

    Function DoesOrderParamExist (p_order_id IN NUMBER,
			        p_parameter_name IN VARCHAR2) return VARCHAR2;

    Function DoesLineParamExist (p_line_item_id IN NUMBER,
			       p_parameter_name IN VARCHAR2) return VARCHAR2;

    Procedure LoadWorklistDetails(p_wi_instance_id 	IN NUMBER,
				p_parameter_name 	IN VARCHAR2,
				p_workitem_id 		IN NUMBER,
				p_is_value_evaluated	IN VARCHAR2,
				p_parameter_value	IN VARCHAR2,
				p_parameter_ref_value	IN VARCHAR2);

    Procedure UpdateWorklistDetails(
                p_wi_instance_id 	IN NUMBER,
                p_parameter_name      IN VARCHAR2,
                p_is_value_evaluated  IN VARCHAR2,
                p_parameter_value	    IN VARCHAR2,
                p_parameter_ref_value	IN VARCHAR2);

    Procedure LoadFADetails(p_fa_instance_id 	IN NUMBER,
			  p_parameter_name	IN VARCHAR2,
			  p_fa_id 		IN NUMBER,
			  p_is_value_evaluated	IN VARCHAR2,
			  p_parameter_value	IN VARCHAR2,
			  p_parameter_ref_value	IN VARCHAR2);

    Procedure UpdateFaDetails(p_fa_instance_id 	IN NUMBER,
			    p_parameter_name    IN VARCHAR2,
			    p_evaluated_flag    IN VARCHAR2,
			    p_parameter_value	IN VARCHAR2,
			    p_parameter_ref_value	IN VARCHAR2);

    Procedure LoadOrderParameters(p_order_id 		IN NUMBER,
				p_parameter_name 	IN VARCHAR2,
				p_parameter_value 	IN VARCHAR2);

    Procedure LoadLineDetails(p_line_item_id 		IN NUMBER,
			    p_parameter_name 		IN VARCHAR2,
			    p_parameter_value 		IN VARCHAR2,
			    p_parameter_reference_value IN VARCHAR2);

    Procedure CallWIEvalProc (p_wi_instance_id 	IN NUMBER,
			    p_procedure_name	IN VARCHAR2,
			    p_order_id 		IN NUMBER,
			    p_line_item_id	IN NUMBER,
			    p_param_val 	IN VARCHAR2,
			    p_param_ref_val 	IN VARCHAR2,
			    p_param_eval_val 	OUT NOCOPY VARCHAR2,
			    p_param_eval_ref_val OUT NOCOPY VARCHAR2,
			    p_return_code 	OUT NOCOPY NUMBER,
			    p_error_description OUT NOCOPY VARCHAR2);

    Procedure ComputeWIParamValue(p_raise 		IN VARCHAR2,
				p_mode 			IN VARCHAR2,
				p_wi_instance_id 	IN NUMBER,
				p_procedure_name 	IN VARCHAR2,
				p_param_val 		IN VARCHAR2,
				p_param_ref_val 	IN VARCHAR2,
				p_default_value 	IN VARCHAR2,
				p_param_eval_val 	OUT NOCOPY VARCHAR2,
				p_param_eval_ref_val 	OUT NOCOPY VARCHAR2,
				p_return_code 		OUT NOCOPY NUMBER,
				p_error_description 	OUT NOCOPY VARCHAR2);

    Procedure EvaluateWIParamValue(
			p_order_id    	      IN NUMBER,
			p_line_item_id        IN NUMBER,
            p_workitem_id         IN NUMBER,
			p_wi_instance_id      IN NUMBER,
 			p_parameter_name 	  IN VARCHAR2,
			p_procedure_name      IN VARCHAR2,
			p_mode 			      IN VARCHAR2,
			p_param_val 	      IN VARCHAR2,
			p_param_ref_val       IN VARCHAR2,
			p_param_eval_val 	  OUT NOCOPY VARCHAR2,
			p_param_eval_ref_val  OUT NOCOPY VARCHAR2,
			p_return_code 		  OUT NOCOPY NUMBER,
			p_error_description   OUT NOCOPY VARCHAR2);

    Procedure SetWIParamValue(
            p_wi_instance_id 	     IN NUMBER,
            p_workitem_id 		     IN NUMBER,
            p_parameter_name 	     IN VARCHAR2,
            p_parameter_value 	     IN VARCHAR2,
            p_parameter_ref_value 	 IN VARCHAR2,
            p_is_value_evaluated 	 IN VARCHAR2,
            x_return_code            OUT NOCOPY NUMBER,
            x_error_description      IN VARCHAR2);

    Procedure CallFAEvalProc (p_fa_instance_id 	IN NUMBER,
			    p_wi_instance_id    IN NUMBER,
			    p_procedure_name	IN VARCHAR2,
			    p_order_id 		IN NUMBER,
			    p_line_item_id	IN NUMBER,
			    p_param_val 	IN VARCHAR2,
			    p_param_ref_val 	IN VARCHAR2,
			    p_param_eval_val 	OUT NOCOPY VARCHAR2,
			    p_param_eval_ref_val OUT NOCOPY VARCHAR2,
			    p_return_code 	OUT NOCOPY NUMBER,
			    p_error_description OUT NOCOPY VARCHAR2);

    Procedure ComputeFAParamValue(p_raise 		IN VARCHAR2,
				p_mode 			IN VARCHAR2,
				p_fa_instance_id 	IN NUMBER,
				p_procedure_name 	IN VARCHAR2,
				p_order_id 		IN NUMBER,
				p_wi_instance_id 	IN NUMBER,
				p_line_item_id		IN NUMBER,
				p_param_val 		IN VARCHAR2,
				p_param_ref_val 	IN VARCHAR2,
				p_default_value 	IN VARCHAR2,
				p_log_flag 		OUT NOCOPY BOOLEAN,
				p_param_eval_val 	OUT NOCOPY VARCHAR2,
				p_param_eval_ref_val 	OUT NOCOPY VARCHAR2,
				p_return_code 		OUT NOCOPY NUMBER,
				p_error_description 	OUT NOCOPY VARCHAR2);

    Procedure SetFAParamValue (	p_fa_instance_id	IN NUMBER,
				p_wi_instance_id 	IN NUMBER,
	 			p_fa_id 		IN NUMBER,
	 			p_parameter_name        IN VARCHAR2,
	 			p_default_value 	IN VARCHAR2,
	 			p_parameter_value 	IN VARCHAR2,
	 			p_parameter_ref_value 	IN VARCHAR2,
	 			p_eval_flag 		IN BOOLEAN,
	 			p_eval_mode 		IN VARCHAR2,
	 			p_procedure_name 	IN VARCHAR2,
	 			p_order_id 		IN NUMBER,
	 			p_line_item_id		IN NUMBER,
	 			p_return_code 		OUT NOCOPY NUMBER,
	 			p_error_description 	OUT NOCOPY VARCHAR2);

    Procedure GetFeConfigInfoText(p_fe 		IN VARCHAR2,
				p_fe_id   	OUT NOCOPY NUMBER,
				p_fetype_id 	OUT NOCOPY NUMBER,
				p_fetype    	OUT NOCOPY VARCHAR2,
				p_fe_sw_generic OUT NOCOPY varchar2,
				p_adapter_type 	OUT NOCOPY varchar2,
				p_gen_lookup_id OUT NOCOPY NUMBER,
				p_connect_proc  OUT NOCOPY VARCHAR2,
				p_disconnect_proc OUT NOCOPY VARCHAR2);

    Procedure GetFeConfigInfoNum (p_fe_id 	IN NUMBER,
				p_fe   		OUT NOCOPY VARCHAR2,
				p_fetype_id 	OUT NOCOPY NUMBER,
				p_fetype    	OUT NOCOPY VARCHAR2,
				p_fe_sw_generic OUT NOCOPY varchar2,
				p_adapter_type 	OUT NOCOPY varchar2,
				p_gen_lookup_id OUT NOCOPY NUMBER,
				p_connect_proc  OUT NOCOPY VARCHAR2,
				p_disconnect_proc OUT NOCOPY VARCHAR2);

    Function GetAttrVal(	p_attribute_name 	IN VARCHAR2,
			p_fe_id 		IN NUMBER,
			p_fe_sw_gen_lookup  IN NUMBER) return varchar2 ;

    Function DecodeAttrValue ( p_attribute_value in varchar2) return varchar2;


-- PL/SQL Specification

 /****************************
   Get a workitem parameter value.  The macro
   $WI.<parameter_name> in FP actually uses this
   function for runtime value substitution.
  *****************************/
 FUNCTION GET_WORKITEM_PARAM_VALUE(
	p_wi_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2
 IS
   lv_param_value VARCHAR2(4000);
   lv_curr_val varchar2(4000);
   lv_curr_ref_val varchar2(4000);
   lv_default  varchar2(4000);
   lv_proc  varchar2(80);
   lv_log_flag  varchar2(1);
   lv_order_id number;
   lv_line_id number;
   lv_mode varchar2(30);
   lv_tmp varchar2(4000);
   lv_ret number;
   lv_str varchar2(2000);
   lv_order_id number;
   lv_line_item_id number;
   lv_workitem_id number;
   lv_workitem_name varchar2(50);
   x_progress varchar2(2000);
   e_compute_WI_param_failed exception;
 BEGIN

  Get_WI_Parameter_info (p_wi_instance_id => GET_WORKITEM_PARAM_VALUE.p_wi_instance_id,
			 p_parameter_name => GET_WORKITEM_PARAM_VALUE.p_parameter_name,
			 p_evaluation_procedure => lv_proc,
			 p_evaluation_mode => lv_mode,
			 p_default_value => lv_default,
			 p_parameter_value => lv_curr_val,
			 p_parameter_ref_value => lv_curr_ref_val,
			 p_audit_flag => lv_log_flag,
			 p_workitem_id => lv_workitem_id);

  ComputeWIParamValue ( p_raise => 'Y',
			p_mode => lv_mode,
			p_wi_instance_id => GET_WORKITEM_PARAM_VALUE.p_wi_instance_id,
			p_procedure_name => lv_proc,
			p_param_val => lv_curr_val,
			p_param_ref_val => lv_curr_ref_val,
			p_default_value => lv_default,
			p_param_eval_val => lv_param_value,
			p_param_eval_ref_val => lv_tmp,
			p_return_code => lv_ret,
			p_error_description => lv_str);
   IF ( lv_ret <> 0 ) THEN
     x_progress := 'ComputeWIParamValue failed error code : ' || lv_ret || ' error description : ' || lv_str;
     RAISE e_compute_WI_param_failed;
   END IF;

   return lv_param_value;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_WORKITEM_PARAM_VALUE',  'WI', p_wi_instance_id, x_progress );
     RAISE;

 END GET_WORKITEM_PARAM_VALUE;

 /*
   This procedure is used by SEND function to
   get the additional information regarding
   an Workitem parameter.  It will also return a flag
   to indicate if the parameter contains decrypted value
   for an encypted parameter.  If it does, the command
   string which SFM is about to send will not be logged
   in our command audit trail tables.
  */
 PROCEDURE GET_WORKITEM_PARAM_VALUE(
	p_wi_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	p_param_val	     OUT NOCOPY VARCHAR2,
	p_param_ref_val  OUT NOCOPY VARCHAR2,
	p_log_value_flag  OUT NOCOPY BOOLEAN,
	p_return_code   OUT NOCOPY number,
	p_error_description  OUT NOCOPY VARCHAR2)
IS
   lv_param_value VARCHAR2(4000);
   lv_curr_val varchar2(4000);
   lv_curr_ref_val varchar2(4000);
   lv_default  varchar2(4000);
   lv_proc  varchar2(80);
   lv_order_id number;
   lv_line_item_id number;
   lv_workitem_id number;
   lv_mode varchar2(30);
   lv_tmp varchar2(4000);
   lv_log_flag varchar2(1);
 BEGIN
     p_return_code := 0;

  Get_WI_Parameter_info (p_wi_instance_id => GET_WORKITEM_PARAM_VALUE.p_wi_instance_id,
			 p_parameter_name => GET_WORKITEM_PARAM_VALUE.p_parameter_name,
			 p_evaluation_procedure => lv_proc,
			 p_evaluation_mode => lv_mode,
			 p_default_value => lv_default,
			 p_parameter_value => lv_curr_val,
			 p_parameter_ref_value => lv_curr_ref_val,
			 p_audit_flag => lv_log_flag,
			 p_workitem_id => lv_workitem_id);

   if lv_log_flag = 'Y' then
	p_log_value_flag := TRUE;
   else
	p_log_value_flag := FALSE;
   end if;

  ComputeWIParamValue
		(p_raise => 'N',
		 p_mode => lv_mode,
		 p_wi_instance_id => GET_WORKITEM_PARAM_VALUE.p_wi_instance_id,
		 p_procedure_name => lv_proc,
		 p_param_val => lv_curr_val,
		 p_param_ref_val => lv_curr_ref_val,
		 p_default_value => lv_default,
		 p_param_eval_val => GET_WORKITEM_PARAM_VALUE.p_param_val,
		 p_param_eval_ref_val => GET_WORKITEM_PARAM_VALUE.p_param_ref_val,
		 p_return_code => GET_WORKITEM_PARAM_VALUE.p_return_code,
		 p_error_description => GET_WORKITEM_PARAM_VALUE.p_error_description);

   IF ( p_return_code <> 0 ) THEN
     XDPCORE.context('XDP_ENGINE', 'GET_WORKITEM_PARAM_VALUE', 'WI', p_wi_instance_id );
   END IF;


 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_WORKITEM_PARAM_VALUE', 'WI', p_wi_instance_id);
     RAISE;

 END GET_WORKITEM_PARAM_VALUE;



 /****************************
   Get a workitem parameter reference value.  The macro
   $WI_REF.<parameter_name> in FP actually uses this
   function for runtime value substitution.
  *****************************/

 FUNCTION GET_WORKITEM_PARAM_REF_VALUE(
	p_wi_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2
 IS
   lv_param_value VARCHAR2(4000);
   lv_curr_val varchar2(4000);
   lv_curr_ref_val varchar2(4000);
   lv_default  varchar2(4000);
   lv_proc  varchar2(80);
   lv_log_flag  varchar2(1);
   lv_order_id number;
   lv_line_item_id number;
   lv_workitem_id number;
   lv_mode varchar2(30);
   lv_tmp varchar2(4000);
   lv_ret number;
   lv_str varchar2(2000);

   x_progress varchar2(2000);
   e_compute_WI_param_failed exception;

 BEGIN

  Get_WI_Parameter_info
		(p_wi_instance_id => GET_WORKITEM_PARAM_REF_VALUE.p_wi_instance_id,
		 p_parameter_name => GET_WORKITEM_PARAM_REF_VALUE.p_parameter_name,
		 p_evaluation_procedure => lv_proc,
		 p_evaluation_mode => lv_mode,
		 p_default_value => lv_default,
		 p_parameter_value => lv_curr_val,
		 p_parameter_ref_value => lv_curr_ref_val,
		 p_audit_flag => lv_log_flag,
		 p_workitem_id => lv_workitem_id);

  ComputeWIParamValue
		(p_raise => 'Y',
		 p_mode => lv_mode,
		 p_wi_instance_id => GET_WORKITEM_PARAM_REF_VALUE.p_wi_instance_id,
		 p_procedure_name => lv_proc,
		 p_param_val => lv_curr_val,
		 p_param_ref_val => lv_curr_ref_val,
		 p_default_value => lv_default,
		 p_param_eval_val => lv_tmp,
		 p_param_eval_ref_val => lv_param_value,
		 p_return_code => lv_ret,
		 p_error_description => lv_str);

   IF ( lv_ret <> 0 ) THEN
     x_progress := 'ComputeWIParamValue failed error code : ' || lv_ret || ' error description : ' || lv_str;
     RAISE e_compute_WI_param_failed;
   END IF;

   return lv_param_value;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_WORKITEM_PARAM_REF_VALUE', 'PARAMETER', p_parameter_name, x_progress );
     RAISE;

 END GET_WORKITEM_PARAM_REF_VALUE;

 /****************************
   Get a list of the parameter values for
   a given workitem instance
  *****************************/
 FUNCTION GET_WORKITEM_PARAM_List( -- done need to check where lv_param_list is being used
	p_wi_instance_id IN NUMBER)

   RETURN XDP_ENGINE.PARAMETER_LIST
 IS
   lv_param_list XDP_ENGINE.PARAMETER_LIST;
   CURSOR lc_param IS
    select
      wpr.parameter_name,
      is_value_evaluated,
      decode(parameter_value,NULL,wpr.default_value,wdl.parameter_value) param_value,
      parameter_ref_value
     from
       xdp_wi_parameters wpr,
       xdp_worklist_details wdl
     where
       wpr.parameter_name = wdl.parameter_name and
       wpr.workitem_id = wdl.workitem_id and
       wdl.workitem_instance_id = p_wi_instance_id;

   lv_index NUMBER := 0;
 BEGIN

   FOR lv_param_rec in lc_param LOOP
     lv_index := lv_index + 1;
     lv_param_list(lv_index).parameter_name := lv_param_rec.parameter_name;
     lv_param_list(lv_index).IS_VALUE_EVALUATED_FLAG :=
                                      lv_param_rec.IS_VALUE_EVALUATED ;
     lv_param_list(lv_index).PARAMETER_VALUE := lv_param_rec.PARAM_VALUE ;
     lv_param_list(lv_index).PARAMETER_REFERENCE_VALUE :=
                                      lv_param_rec.PARAMETER_REF_VALUE ;
   END LOOP;

   return lv_param_list;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_WORKITEM_PARAM_List', 'WI', p_wi_instance_id );
     RAISE;

 END GET_WORKITEM_PARAM_List;


/****************************
   Set the workitem parameter value for
   a given workitem instance.  The parameter
   evaluation procedure will NOT be executed.

   --p_evaluation_required is obsolete from 11.5.6

   --  Date: 13-Jan-2005  Author: DPUTHIYE. Bug#: 4083708
   --  p_evaluation_required is again supported from 11.5.9
   --  to fix the bug 4083708. This API is called by XDP_OA_UTIL.Add_WI_To_Line
   --  and is required to set a param value with evaluation_required = TRUE
   --  APIs will need to explicitly set evaluation_required = TRUE to force evaluation
  *****************************/

PROCEDURE Set_Workitem_Param_value(
		p_wi_instance_id IN NUMBER,
		p_parameter_name IN VARCHAR2,
		p_parameter_value IN VARCHAR2,
		p_parameter_reference_value IN VARCHAR2 DEFAULT NULL,
        p_evaluation_required IN BOOLEAN DEFAULT FALSE)
IS
    l_return_code NUMBER;
    l_error_description VARCHAR2(2000);
    l_param_evaluated CHAR(1) := 'Y';           --introduced to fix bug 4083708
    x_progress varchar2(2000);
    Set_WI_param_failed exception;

BEGIN

    if ( p_evaluation_required = TRUE ) then    -- Fixing bug 4083708
        l_param_evaluated := 'N';
    end if;

    SetWIParamValue(
        p_wi_instance_id =>p_wi_instance_id,
        p_workitem_id => NULL,
        p_parameter_name =>p_parameter_name,
        p_is_value_evaluated => l_param_evaluated,
        p_parameter_value =>p_parameter_value,
        p_parameter_ref_value => p_parameter_reference_value,
        x_return_code => l_return_code,
        x_error_description => l_error_description
    );

   IF ( l_return_code <> 0 ) THEN
     x_progress := 'SetWIParamValue failed error code : ' || l_return_code || ' error_description : ' || l_error_description;
     RAISE Set_WI_param_failed;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_WORKITEM_PARAM_VALUE','WI', p_wi_instance_id, x_progress );
     RAISE;

END SET_WORKITEM_PARAM_VALUE;

 /***************************
   Get the Fulfillment Date for a Workitem Instance
 ***************************/
 FUNCTION GET_WORKITEM_PROV_DATE(
               p_wi_instance_id IN NUMBER)
   RETURN DATE
 IS
  lv_prov_date DATE;
 BEGIN
  select
    provisioning_date
  into
    lv_prov_date
  from
    XDP_FULFILL_WORKLIST
  where
    workitem_instance_id = p_wi_instance_id;

  return lv_prov_date;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_WORKITEM_PROV_DATE','WI', p_wi_instance_id );
     RAISE;

 END GET_WORKITEM_PROV_DATE;


 /****************************
  Set the Fulfillment Date for a Workitem Instance
  If the Workitem is being processed or already processed an error code is returned
  ****************************/


 PROCEDURE SET_WORKITEM_PROV_DATE(
		p_wi_instance_id in NUMBER,
		p_prov_date IN DATE,
      		p_return_code   OUT NOCOPY NUMBER,
        	p_error_description  OUT NOCOPY VARCHAR2)
 IS
  cursor c_update_prov_date is
   select status_code  status
    from XDP_FULFILL_WORKLIST
   where workitem_instance_id = p_wi_instance_id
   for update of provisioning_date nowait;

 e_InvalidWIStatusException exception;
 lv_wi_name VARCHAR2(200);
 lv_message_params VARCHAR2(1000);
 BEGIN
  p_return_code := 0;

  SavePoint UpdateProvDate;

  FOR v_update_prov_date in c_update_prov_date LOOP
    if v_update_prov_date.status NOT in ('IN PROGRESS','SUCCESS','SUCCESS_WITH_OVERRIDE','CANCELED') then

      update XDP_FULFILL_WORKLIST
       set last_updated_by = FND_GLOBAL.USER_ID,
         last_update_date = sysdate,
         last_update_login = FND_GLOBAL.LOGIN_ID,
	 provisioning_date = p_prov_date
      where current of c_update_prov_date;

    else
      rollback to UpdateProvDate;
      raise e_InvalidWIStatusException;
    end if;
  END LOOP;

 EXCEPTION
  when e_InvalidWIStatusException then

    lv_wi_name := XDPCORE_WI.get_display_name( p_wi_instance_id );

    lv_message_params := 'WORK_ITEM='||lv_wi_name||'#XDP#';

    XDPCORE.error_context( 'WI', p_wi_instance_id, 'XDP_WI_UPDATE_NOT_ALLOWED', lv_message_params);
    XDPCORE.context('XDP_ENGINE', 'SET_WORKITEM_PROV_DATE','WI', p_wi_instance_id );
    XDPCORE.RAISE;

  when others then
    rollback to UpdateProvDate;
    XDPCORE.context('XDP_ENGINE', 'SET_WORKITEM_PROV_DATE','WI', p_wi_instance_id );
    p_return_code := SQLCODE;
    p_error_description := SQLERRM;
 END SET_WORKITEM_PROV_DATE;


 /****************************
   Get an FA parameter value.  The macro
   $FA.<parameter_name> in FP actually uses this
   function for runtime value substitution.
  *****************************/

 FUNCTION GET_FA_PARAM_VALUE(
	p_fa_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2
 IS
   lv_param_value varchar2(4000);
   lv_curr_val varchar2(4000);
   lv_curr_ref_val varchar2(4000);
   lv_default  varchar2(4000);
   lv_proc  varchar2(80);
   lv_order_id number;
   lv_line_item_id number;
   lv_wi_id  number;
   lv_fa_id number;
   lv_mode varchar2(30);
   lv_tmp varchar2(4000);
   lv_ret number;
   lv_str varchar2(2000);
   lv_log_flag boolean;

   x_progress varchar2(2000);
   e_compute_FA_param_failed exception;

 BEGIN

  Get_FA_Parameter_info (p_fa_instance_id => GET_FA_PARAM_VALUE.p_fa_instance_id,
			 p_parameter_name => GET_FA_PARAM_VALUE.p_parameter_name,
			 p_evaluation_procedure => lv_proc,
			 p_fa_id => lv_fa_id,
			 p_default_value => lv_default,
			 p_parameter_value => lv_curr_val,
			 p_parameter_ref_value => lv_curr_ref_val,
			 p_audit_flag => lv_mode);

  ComputeFAParamValue ( p_raise => 'Y',
			p_mode => lv_mode,
			p_fa_instance_id => p_fa_instance_id,
			p_procedure_name => lv_proc,
			p_order_id => NULL,
			p_wi_instance_id => NULL,
			p_line_item_id=> NULL,
			p_param_val => lv_curr_val,
			p_param_ref_val => lv_curr_ref_val,
			p_default_value => lv_default,
			p_log_flag => lv_log_flag,
			p_param_eval_val => lv_param_value,
			p_param_eval_ref_val => lv_tmp,
			p_return_code => lv_ret,
			p_error_description => lv_str);

   IF ( lv_ret <> 0 ) THEN
     x_progress := 'ComputeFAParamValue failed error code : ' || lv_ret || ' error_description : ' || lv_str;
     RAISE e_compute_FA_param_failed;
   END IF;

   return lv_param_value;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_FA_PARAM_VALUE', 'FA', p_fa_instance_id, x_progress );
     RAISE;

 END GET_FA_PARAM_VALUE;

 /****************************
   Get an FA parameter reference value.  The macro
   $FA_REF.<parameter_name> in FP actually uses this
   function for runtime value substitution.
  *****************************/

 FUNCTION GET_FA_PARAM_REF_VALUE(
	p_fa_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2
 IS
   lv_param_value varchar2(4000);
   lv_curr_val varchar2(4000);
   lv_curr_ref_val varchar2(4000);
   lv_default  varchar2(4000);
   lv_proc  varchar2(80);
   lv_order_id number;
   lv_line_item_id number;
   lv_wi_id  number;
   lv_fa_id number;
   lv_mode varchar2(30);
   lv_tmp varchar2(4000);
   lv_ret number;
   lv_str varchar2(2000);
   lv_log_flag boolean;

   x_progress varchar2(2000);
   e_compute_FA_param_failed exception;

 BEGIN

    Get_FA_Parameter_info (p_fa_instance_id => GET_FA_PARAM_REF_VALUE.p_fa_instance_id,
			 p_parameter_name => GET_FA_PARAM_REF_VALUE.p_parameter_name,
			 p_evaluation_procedure => lv_proc,
			 p_fa_id => lv_fa_id,
			 p_default_value => lv_default,
			 p_parameter_value => lv_curr_val,
			 p_parameter_ref_value => lv_curr_ref_val,
			 p_audit_flag => lv_mode);

    ComputeFAParamValue ( p_raise => 'Y',
			p_mode => lv_mode,
			p_fa_instance_id => p_fa_instance_id,
			p_procedure_name => lv_proc,
			p_order_id => NULL,
			p_wi_instance_id => NULL,
			p_line_item_id=> NULL,
			p_param_val => lv_curr_val,
			p_param_ref_val => lv_curr_ref_val,
			p_default_value => lv_default,
			p_log_flag => lv_log_flag,
			p_param_eval_val => lv_tmp,
			p_param_eval_ref_val => lv_param_value,
			p_return_code => lv_ret,
			p_error_description => lv_str);

   IF ( lv_ret <> 0 ) THEN
     x_progress := 'ComputeFAParamValue failed error code : ' || lv_ret || ' error_description : ' || lv_str;
     RAISE e_compute_FA_param_failed;
   END IF;

   RETURN lv_param_value;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_FA_PARAM_REF_VALUE', 'FA', p_fa_instance_id, x_progress );
     RAISE;

END GET_FA_PARAM_REF_VALUE;

 /****************************
   This procedure is used by SEND function to
   get the additional information regarding
   an FA parameter.  It will also return a flag
   to indicate if the parameter contains decrypted value
   for an encypted parameter.  If it does, the command
   string which SFM is about to send will not be logged
   in our command audit trail tables.
  *****************************/
PROCEDURE GET_FA_PARAM(
    p_fa_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	p_param_val	     OUT NOCOPY VARCHAR2,
	p_param_ref_val  OUT NOCOPY VARCHAR2,
	p_log_value_flag  OUT NOCOPY BOOLEAN,
	p_return_code   OUT NOCOPY number,
	p_error_description  OUT NOCOPY VARCHAR2)
IS
   lv_curr_val varchar2(4000);
   lv_curr_ref_val varchar2(4000);
   lv_default  varchar2(4000);
   lv_proc  varchar2(80);
   lv_order_id number;
   lv_line_item_id number;
   lv_wi_id  number;
   lv_fa_id number;
   lv_mode varchar2(30);
   lv_tmp varchar2(4000);
   lv_ret number;
   lv_str varchar2(2000);
BEGIN
    p_return_code := 0;
    Get_FA_Parameter_info (p_fa_instance_id => GET_FA_PARAM.p_fa_instance_id,
			 p_parameter_name => GET_FA_PARAM.p_parameter_name,
			 p_evaluation_procedure => lv_proc,
			 p_fa_id => lv_fa_id,
			 p_default_value => lv_default,
			 p_parameter_value => lv_curr_val,
			 p_parameter_ref_value => lv_curr_ref_val,
			 p_audit_flag => lv_mode);

    ComputeFAParamValue ( p_raise => 'N',
			p_mode => lv_mode,
			p_fa_instance_id => p_fa_instance_id,
			p_procedure_name => lv_proc,
			p_order_id => NULL,
			p_wi_instance_id => NULL,
			p_line_item_id=> NULL,
			p_param_val => lv_curr_val,
			p_param_ref_val => lv_curr_ref_val,
			p_default_value => lv_default,
			p_log_flag => p_log_value_flag,
			p_param_eval_val => p_param_val,
			p_param_eval_ref_val => p_param_ref_val,
			p_return_code => p_return_code,
			p_error_description => p_error_description);

   IF ( p_return_code <> 0 ) THEN
     XDPCORE.context('XDP_ENGINE', 'GET_FA_PARAM', 'FA', p_fa_instance_id );
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_FA_PARAM', 'FA', p_fa_instance_id );
     RAISE;

 END GET_FA_PARAM;

 /****************************
   Get a list of the parameter values for
   a given FA instance
  *****************************/
 FUNCTION GET_FA_PARAM_List(  --Done
	p_fa_instance_id IN NUMBER)
   RETURN XDP_ENGINE.PARAMETER_LIST
 IS
   lv_param_list XDP_ENGINE.PARAMETER_LIST;
   CURSOR lc_param IS
    select
      fpr.parameter_name,
      is_value_evaluated,
      decode(parameter_value,NULL,fpr.default_value,fdl.parameter_value) param_value,
      parameter_ref_value
     from
       xdp_fa_parameters fpr,
       xdp_fa_details fdl
     where
	fpr.fulfillment_action_id = fdl.fulfillment_action_id and
	fpr.parameter_name = fdl.parameter_name and
	fdl.fa_instance_id = p_fa_instance_id;

   lv_index NUMBER := 0;
 BEGIN

   FOR lv_param_rec in lc_param LOOP
     lv_index := lv_index + 1;
     lv_param_list(lv_index).parameter_name := lv_param_rec.parameter_name;
     lv_param_list(lv_index).IS_VALUE_EVALUATED_FLAG :=
                                      lv_param_rec.IS_VALUE_EVALUATED ;
     lv_param_list(lv_index).PARAMETER_VALUE := lv_param_rec.PARAM_VALUE ;
     lv_param_list(lv_index).PARAMETER_REFERENCE_VALUE :=
                                      lv_param_rec.PARAMETER_REF_VALUE ;
   END LOOP;

   return lv_param_list;

 EXCEPTION
   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'GET_FA_PARAM_List', 'FA', p_fa_instance_id );
     RAISE;

 END GET_FA_PARAM_List;

 /****************************
   Set the FA parameter value for
   a given FA instance.  The parameter
   evaluation procedure will be executed if
   applicable.
  *****************************/
 PROCEDURE Set_FA_Param_value(
		p_fa_instance_id IN NUMBER,
		p_parameter_name IN VARCHAR2,
		p_parameter_value IN VARCHAR2,
		p_parameter_reference_value IN VARCHAR2 DEFAULT NULL,
		p_evaluation_required IN BOOLEAN DEFAULT FALSE)
 IS

    lv_proc  varchar2(80);
    lv_exists varchar2(1) := 'N';
    lv_eval_mode  varchar2(30);
    lv_param_id number;
    lv_wi_id number;
    lv_fa_id number;
    lv_order_id number;
    lv_line_item_id number;
    lv_wi_instance_id number;
    lv_eval_val varchar2(4000);
    lv_eval_ref_val varchar2(4000);
    lv_default_val varchar2(4000);
    lv_ret number;
    lv_str varchar2(2000);
    lv_eval_flag varchar2(1);

    x_progress varchar2(2000);
    set_FA_param_failed exception;


  CURSOR c_GetFADetails is
    select
	fwt.order_id,
	fwt.line_item_id,
	frt.workitem_instance_id,
	fpr.parameter_name,
	NVL(log_in_audit_trail_flag,'Y') log_flag,
	evaluation_procedure,
	fpr.default_value,
	frt.fulfillment_action_id
    from
      xdp_fa_runtime_list frt,
	xdp_fa_parameters fpr,
	XDP_FULFILL_WORKLIST fwt
    where
	frt.fa_instance_id = p_fa_instance_id and
	frt.workitem_instance_id = fwt.workitem_instance_id and
	frt.fulfillment_action_id = fpr.fulfillment_action_id and
	fpr.parameter_name = p_parameter_name;

 BEGIN
    for v_GetFADetails in c_GetFADetails loop
	lv_order_id := v_GetFADetails.order_id;
	lv_line_item_id := v_GetFADetails.line_item_id;
	lv_wi_instance_id := v_GetFADetails.workitem_instance_id;
	lv_eval_mode := v_GetFADetails.log_flag;
	lv_proc := v_GetFADetails.evaluation_procedure;
	lv_default_val := v_GetFADetails.default_value;
	lv_fa_id := v_GetFADetails.fulfillment_action_id;

	lv_exists := 'Y';

    end loop;


    if lv_exists = 'N' then
	raise no_data_found;
    end if;

	SetFAParamValue
	(p_fa_instance_id => Set_FA_Param_value.p_fa_instance_id,
	 p_wi_instance_id => lv_wi_instance_id,
	 p_fa_id => lv_fa_id,
	 p_parameter_name => Set_FA_Param_value.p_parameter_name,
	 p_default_value => lv_default_val,
	 p_parameter_value => Set_FA_Param_value.p_parameter_value,
	 p_parameter_ref_value => Set_FA_Param_value.p_parameter_reference_value,
	 p_eval_flag => Set_FA_Param_value.p_evaluation_required,
	 p_eval_mode => lv_eval_mode,
	 p_procedure_name => lv_proc,
	 p_order_id => lv_order_id,
	 p_line_item_id => lv_line_item_id,
	 p_return_code => lv_ret,
	 p_error_description => lv_str);

   IF ( lv_ret <> 0 ) THEN
     x_progress := 'SetFAParamValue failed error code : ' || lv_ret || ' error_description : ' || lv_str;
     RAISE set_FA_param_failed;
   END IF;

 EXCEPTION

   WHEN OTHERS THEN
     XDPCORE.context('XDP_ENGINE', 'SET_FA_PARAM_VALUE', 'FA', p_fa_instance_id, x_progress );
     RAISE;

 END SET_FA_PARAM_VALUE;


 /****************************
   Get the value of an order parameter
  *****************************/
 FUNCTION GET_ORDER_PARAM_VALUE(
	p_order_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2
 IS
   lv_param_value varchar2(4000);

 CURSOR c_GetOrderParam is
   select order_parameter_value
   from xdp_order_parameters
   where
      order_id = p_order_id and
	order_parameter_name = p_parameter_name;

  lv_exists varchar2(1) := 'N';
 BEGIN
   for v_GetOrderParam in c_GetOrderParam loop
	lv_param_value := v_GetOrderParam.order_parameter_value;
	lv_exists := 'Y';
   end loop;

   if lv_exists = 'N' then
	raise no_data_found;
   end if;

   return lv_param_value;


 END GET_ORDER_PARAM_VALUE;

 /****************************
   Get a list of the order parameter values
   for a given order
  *****************************/
 FUNCTION GET_ORDER_PARAM_List(
	p_order_id IN NUMBER  )
   RETURN XDP_ENGINE.PARAMETER_LIST
 IS
   lv_param_list XDP_ENGINE.PARAMETER_LIST;
   CURSOR lc_param IS
    select
      order_parameter_name parameter_name,
	order_parameter_value parameter_value
     from
       xdp_order_parameters
     where
	 order_id = p_order_id;

   lv_index NUMBER := 0;
 BEGIN

   FOR lv_param_rec in lc_param LOOP
     lv_index := lv_index + 1;
     lv_param_list(lv_index).parameter_name := lv_param_rec.parameter_name;
     lv_param_list(lv_index).PARAMETER_VALUE := lv_param_rec.PARAMETER_VALUE ;
   END LOOP;


   return lv_param_list;


 END GET_ORDER_PARAM_LIST;

 /****************************
   Set an order parameter value
  *****************************/
 PROCEDURE Set_ORDER_Param_value(
		p_order_id IN NUMBER,
		p_parameter_name IN VARCHAR2,
		p_parameter_value IN VARCHAR2)
 IS
   lv_exists varchar2(1);
 BEGIN

    lv_exists := DoesOrderParamExist
		(p_order_id => Set_Order_Param_Value.p_order_id,
		 p_parameter_name => Set_Order_Param_value.p_parameter_name);

   IF lv_exists = 'Y' then
     update xdp_order_parameters
     set
       last_updated_by = FND_GLOBAL.USER_ID,
       last_update_date = sysdate,
       last_update_login = FND_GLOBAL.LOGIN_ID,
	order_parameter_value = p_parameter_value
     where
		order_id = p_order_id and
		order_parameter_name = p_parameter_name;
   ELSE
	LoadOrderParameters(p_order_id => set_order_param_value.p_order_id,
			    p_parameter_name => set_order_param_value.p_parameter_name,
			    p_parameter_value => set_order_param_value.p_parameter_value);

   END IF;

 END SET_ORDER_PARAM_VALUE;

 /****************************
   Get the value of a line parameter
  *****************************/
 FUNCTION GET_line_PARAM_VALUE(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2
 IS
   lv_param_value varchar2(4000);

  CURSOR c_GetLineParam is
   select parameter_value
   from XDP_ORDER_LINEITEM_DETS
   where
      line_item_id = p_line_item_id and
	line_parameter_name = p_parameter_name;

  lv_exists varchar2(1) := 'N';
 BEGIN
   for v_GetLineParam in c_GetLineParam loop
	lv_param_value := v_GetLineParam.parameter_value;
	lv_exists := 'Y';
   end loop;

   if lv_exists = 'N' then
	raise no_data_found;
   end if;

   return lv_param_value;

 END GET_LINE_PARAM_VALUE;

 /****************************
   Get the reference value of a line parameter
  *****************************/
 FUNCTION GET_line_PARAM_REF_VALUE(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2
 IS
   lv_param_value varchar2(4000);

  CURSOR c_GetLineParam is
   select parameter_reference_value
   from XDP_ORDER_LINEITEM_DETS
   where
	line_item_id = p_line_item_id and
	line_parameter_name = p_parameter_name;

  lv_exists varchar2(1) := 'N';

 BEGIN
   for v_GetLineParam in c_GetLineParam loop
	lv_param_value := v_GetLineParam.parameter_reference_value;
	lv_exists := 'Y';
   end loop;

   if lv_exists = 'N' then
	raise no_data_found;
   end if;

   return lv_param_value;

 END GET_LINE_PARAM_REF_VALUE;

 /********************************************
   Add a runtime parameter to a given line
  *******************************************/
 PROCEDURE ADD_LINE_PARAM(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	p_parameter_value IN VARCHAR2,
	p_parameter_reference_value IN VARCHAR2 DEFAULT NULL)
 IS
   lv_exists varchar2(1);

 BEGIN

   lv_exists := DoesLineParamExist
		(p_line_item_id => Add_line_param.p_line_item_id,
		 p_parameter_name => Add_line_param.p_parameter_name);

   if lv_exists = 'Y' then
     FND_MESSAGE.SET_NAME('XDP', 'XDP_API_PARAM_NAME_EXISTS');
     FND_MESSAGE.SET_TOKEN('PARAM_NAME', p_parameter_name);
     APP_EXCEPTION.RAISE_EXCEPTION;
   else
	LoadLineDetails
	   (p_line_item_id => Add_line_param.p_line_item_id,
	    p_parameter_name => Add_line_param.p_parameter_name,
	    p_parameter_value => Add_line_param.p_parameter_value,
	    p_parameter_reference_value => Add_line_param.p_parameter_reference_value);

   end if;

 END Add_Line_Param;

 /********************************************
   Update an existing parameter value for a given line
  *******************************************/
 PROCEDURE Set_LINE_PARAM_Value(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	p_parameter_value IN VARCHAR2,
	p_parameter_reference_value IN VARCHAR2 DEFAULT NULL)
 IS
   lv_exists varchar2(1);

 BEGIN

   lv_exists := DoesLineParamExist
		(p_line_item_id => set_line_param_value.p_line_item_id,
		 p_parameter_name => set_line_param_value.p_parameter_name);

   if lv_exists = 'N' then
	raise no_data_found;
   end if;

  update XDP_ORDER_LINEITEM_DETS
   set
     last_updated_by = FND_GLOBAL.USER_ID,
     last_update_date = sysdate,
     last_update_login = FND_GLOBAL.LOGIN_ID,
      parameter_value = p_parameter_value,
      parameter_reference_value = p_parameter_reference_value
  where
     line_item_id = p_line_item_id and
     line_parameter_name = p_parameter_name;

 END Set_Line_Param_Value;


 /****************************
   Retrieve the configuration data
   for a given fulfillment element
  *****************************/
 PROCEDURE Get_FE_ConfigInfo(
		p_fe IN VARCHAR2,
		p_fe_id   OUT NOCOPY NUMBER, /* Internal ID for the FE*/
		p_fetype_id OUT NOCOPY NUMBER, /* Internal id for the FE type */
		p_fetype    OUT NOCOPY VARCHAR2, /* name of the FETYPE*/
		p_fe_sw_generic  OUT NOCOPY varchar2,/* The current software generic of the FE*/
		p_adapter_type OUT NOCOPY varchar2 /* the current adapter type of the FE */)
 IS
   lv_dummynum number;
   lv_dummyvar varchar2(80);
 BEGIN

	GetFeConfigInfoText(p_fe => Get_FE_ConfigInfo.p_fe,
			    p_fe_id => Get_FE_ConfigInfo.p_fe_id,
			    p_fetype_id => Get_FE_ConfigInfo.p_fetype_id,
			    p_fetype => Get_FE_ConfigInfo.p_fetype,
			    p_fe_sw_generic => Get_FE_ConfigInfo.p_fe_sw_generic,
			    p_adapter_type  => Get_FE_ConfigInfo.p_adapter_type,
			    p_gen_lookup_id => lv_dummynum,
			    p_connect_proc  => lv_dummyvar,
			    p_disconnect_proc => lv_dummyvar);

 END GET_FE_ConfigInfo;

 /****************************
   Retrieve the configuration data
   for a given fulfillment element
  *****************************/
 PROCEDURE Get_FE_ConfigInfo(
		p_fe_id IN NUMBER,
		p_fe_name   OUT NOCOPY VARCHAR2, /* name of the FE*/
		p_fetype_id OUT NOCOPY NUMBER, /* Internal id for the FE type */
		p_fetype    OUT NOCOPY VARCHAR2, /* name of the FETYPE*/
		p_fe_sw_generic  OUT NOCOPY varchar2,/* The current software generic of the FE*/
		p_adapter_type OUT NOCOPY varchar2 /* the current adapter type of the FE */)
 IS

   lv_dummynum number;
   lv_dummyvar varchar2(80);
 BEGIN
	GetFeConfigInfoNum (p_fe_id => Get_FE_ConfigInfo.p_fe_id,
			    p_fe => Get_FE_ConfigInfo.p_fe_name,
			    p_fetype_id => Get_FE_ConfigInfo.p_fetype_id,
			    p_fetype => Get_FE_ConfigInfo.p_fetype,
			    p_fe_sw_generic => Get_FE_ConfigInfo.p_fe_sw_generic,
			    p_adapter_type  => Get_FE_ConfigInfo.p_adapter_type,
			    p_gen_lookup_id => lv_dummynum,
			    p_connect_proc  => lv_dummyvar,
			    p_disconnect_proc => lv_dummyvar);

    null;
 END GET_FE_ConfigInfo;

 /********************************
 ** Retrieve the FE Attribute value
 ** for a given fulfillment element
 **********************************/
 FUNCTION  Get_FE_AttributeVal(
		p_fe_name IN VARCHAR2,
		p_attribute_name IN VARCHAR2)
  return varchar2
IS
  lv_attrVal varchar2(4000);
  lv_fe_id  NUMBER;
  lv_fetype_id  NUMBER;
  lv_fetype     varchar2(40);
  lv_fe_sw_generic   varchar2(40);
  lv_adapter_type  varchar2(40);
  lv_gen_lookup_id number;

   lv_dummyvar varchar2(80);

BEGIN
	GetFeConfigInfoText(p_fe => Get_FE_AttributeVal.p_fe_name,
			    p_fe_id => lv_fe_id,
			    p_fetype_id => lv_fetype_id,
			    p_fetype => lv_fetype,
			    p_fe_sw_generic => lv_fe_sw_generic,
			    p_adapter_type  => lv_adapter_type,
			    p_gen_lookup_id => lv_gen_lookup_id,
			    p_connect_proc  => lv_dummyvar,
			    p_disconnect_proc => lv_dummyvar);

	lv_attrVal := GetAttrVal(
		p_attribute_name => Get_FE_AttributeVal.p_attribute_name,
		p_fe_id => lv_fe_id,
		p_fe_sw_gen_lookup => lv_gen_lookup_id);

  return lv_attrVal;

END Get_FE_AttributeVal;

 /********************************
 ** Retrieve the FE Attribute value
 ** for a given fulfillment element
 **********************************/
 FUNCTION  Get_FE_AttributeVal(
		p_fe_id IN NUMBER,
		p_attribute_name IN VARCHAR2)
  return varchar2
IS
  lv_attrVal varchar2(4000);
  lv_fe_name  varchar2(40);
  lv_fetype_id  NUMBER;
  lv_fetype     varchar2(40);
  lv_fe_sw_generic   varchar2(40);
  lv_adapter_type  varchar2(40);

  lv_gen_lookup_id number;

   lv_dummyvar varchar2(80);
BEGIN
	GetFeConfigInfoNum (p_fe_id => Get_FE_AttributeVal.p_fe_id,
			    p_fe => lv_fe_name,
			    p_fetype_id => lv_fetype_id,
			    p_fetype => lv_fetype,
			    p_fe_sw_generic => lv_fe_sw_generic,
			    p_adapter_type  => lv_adapter_type,
			    p_gen_lookup_id => lv_gen_lookup_id,
			    p_connect_proc  => lv_dummyvar,
			    p_disconnect_proc => lv_dummyvar);

	lv_attrVal := GetAttrVal(
		p_attribute_name => Get_FE_AttributeVal.p_attribute_name,
		p_fe_id => Get_FE_AttributeVal.p_fe_id,
		p_fe_sw_gen_lookup => lv_gen_lookup_id);

  return lv_attrVal;

END Get_FE_AttributeVal;

 /*
	Retrieve all the FE Attribute value
   for a given fulfillment element
 */
 FUNCTION  Get_FE_AttributeVal_List(
		  p_fe_name in varchar2)
   RETURN XDP_TYPES.ORDER_PARAMETER_LIST
 IS
  lv_attrVal varchar2(4000);
  lv_fe_id  NUMBER;
  lv_fetype_id  NUMBER;
  lv_fetype     varchar2(40);
  lv_fe_sw_generic   varchar2(40);
  lv_adapter_type  varchar2(40);
  lv_conceal_data VARCHAR2(10);
  lv_gen_lookup_id number;
  lv_attr_list XDP_TYPES.ORDER_PARAMETER_LIST;
  lv_index number := 0;

  lv_dummyvar varchar2(80);

  CURSOR lc_FE_Attr(l_fe_id number,l_gen_lookup_id number) IS
  select
	fan.fe_attribute_name fe_attribute_name,
	decode(fe_attribute_value,NULL,default_value,fe_attribute_value) fe_attribute_value,
	fan.conceal_data conceal_data
  from
	xdp_fe_attribute_def fan,
	(select fe_attribute_id, fe_attribute_value
	 from
	   XDP_FE_ATTRIBUTE_VAL fae,
	   XDP_FE_GENERIC_CONFIG fge
	 where
	 fae.fe_generic_config_id = fge.fe_generic_config_id and
	 fge.fe_id = l_fe_id and
	 fge.fe_sw_gen_lookup_id = l_gen_lookup_id ) fae2
  where
	fan.fe_sw_gen_lookup_id = l_gen_lookup_id and
	fan.fe_attribute_id = fae2.fe_attribute_id(+);
 BEGIN

	GetFeConfigInfoText(p_fe => Get_FE_AttributeVal_List.p_fe_name,
			    p_fe_id => lv_fe_id,
			    p_fetype_id => lv_fetype_id,
			    p_fetype => lv_fetype,
			    p_fe_sw_generic => lv_fe_sw_generic,
			    p_adapter_type  => lv_adapter_type,
			    p_gen_lookup_id => lv_gen_lookup_id,
			    p_connect_proc  => lv_dummyvar,
			    p_disconnect_proc => lv_dummyvar);


  FOR lv_attr_rec IN lc_FE_Attr(lv_fe_id,lv_gen_lookup_id) LOOP
	lv_index := lv_index + 1;
	lv_attrVal := lv_attr_rec.fe_attribute_value;

	lv_attr_list(lv_index).parameter_name := lv_attr_rec.fe_attribute_name;
	lv_attr_list(lv_index).parameter_value := lv_attrVal;
  	IF lv_attr_rec.conceal_data = 'Y' THEN
     		lv_attrVal:= DecodeAttrValue(lv_attrVal);
		lv_attr_list(lv_index).parameter_value := lv_attrVal;
	END IF;

  END LOOP;

  return lv_attr_list;

 END Get_FE_AttributeVal_List;

 /*
	Retrieve all the FE Attribute value
   for a given fulfillment element
 */
 FUNCTION  Get_FE_AttributeVal_List(
		  p_fe_id in number)
   RETURN XDP_TYPES.ORDER_PARAMETER_LIST
 IS
  lv_attrVal varchar2(4000);
  lv_fe_name  varchar2(80);
  lv_fetype_id  NUMBER;
  lv_fetype     varchar2(40);
  lv_fe_sw_generic   varchar2(40);
  lv_adapter_type  varchar2(40);
  lv_conceal_data VARCHAR2(10);
  lv_gen_lookup_id number;
  lv_attr_list XDP_TYPES.ORDER_PARAMETER_LIST;
  lv_index number := 0;

  lv_dummyvar varchar2(80);

  CURSOR lc_FE_Attr(l_fe_id number,l_gen_lookup_id number) IS
  select
	fan.fe_attribute_name fe_attribute_name,
	decode(fe_attribute_value,NULL,default_value,fe_attribute_value) fe_attribute_value,
	fan.conceal_data conceal_data
  from
	xdp_fe_attribute_def fan,
	(select fe_attribute_id, fe_attribute_value
	 from
	   XDP_FE_ATTRIBUTE_VAL fae,
	   XDP_FE_GENERIC_CONFIG fge
	 where
	 fae.fe_generic_config_id = fge.fe_generic_config_id and
	 fge.fe_id = l_fe_id and
	 fge.fe_sw_gen_lookup_id = l_gen_lookup_id ) fae2
  where
	fan.fe_sw_gen_lookup_id = l_gen_lookup_id and
	fan.fe_attribute_id = fae2.fe_attribute_id(+);
 BEGIN

	GetFeConfigInfoNum( p_fe_id => Get_FE_AttributeVal_List.p_fe_id,
			    p_fe => lv_fe_name,
			    p_fetype_id => lv_fetype_id,
			    p_fetype => lv_fetype,
			    p_fe_sw_generic => lv_fe_sw_generic,
			    p_adapter_type  => lv_adapter_type,
			    p_gen_lookup_id => lv_gen_lookup_id,
			    p_connect_proc  => lv_dummyvar,
			    p_disconnect_proc => lv_dummyvar);


  FOR lv_attr_rec IN lc_FE_Attr(p_fe_id, lv_gen_lookup_id) LOOP
	lv_index := lv_index + 1;
	lv_attrVal := lv_attr_rec.fe_attribute_value;
	lv_attr_list(lv_index).parameter_name := lv_attr_rec.fe_attribute_name;
	lv_attr_list(lv_index).parameter_value := lv_attrVal;
  	IF lv_attr_rec.conceal_data = 'Y' THEN
     		lv_attrVal:= DecodeAttrValue(lv_attrVal);
		lv_attr_list(lv_index).parameter_value := lv_attrVal;
  	END IF;
  END LOOP;

  return lv_attr_list;

 END Get_FE_AttributeVal_List;


  /*
   Retrieve the FE connect/disconnect procedure name
   for a given fulfillment element
  */
PROCEDURE  Get_FE_ConnectionProc(
		p_fe_name IN VARCHAR2,
		p_connect_proc_name OUT NOCOPY VARCHAR2,
		p_disconnect_proc_name OUT NOCOPY VARCHAR2)
IS
  lv_fe_id  NUMBER;
  lv_fetype_id  NUMBER;
  lv_fetype     varchar2(40);
  lv_fe_sw_generic   varchar2(40);
  lv_adapter_type  varchar2(40);

  lv_dummynum  NUMBER;

BEGIN
	GetFeConfigInfoText
		(p_fe => Get_FE_ConnectionProc.p_fe_name,
		 p_fe_id => lv_fe_id,
		 p_fetype_id => lv_fetype_id,
		 p_fetype => lv_fetype,
		 p_fe_sw_generic => lv_fe_sw_generic,
		 p_adapter_type  => lv_adapter_type,
		 p_gen_lookup_id => lv_dummynum,
		 p_connect_proc  => Get_FE_ConnectionProc.p_connect_proc_name,
		 p_disconnect_proc => Get_FE_ConnectionProc.p_disconnect_proc_name);

END Get_FE_ConnectionProc;

 /*
   Retrieve the FE connect/disconnect procedure name
   for a given fulfillment element
  */
PROCEDURE  Get_FE_ConnectionProc(
		p_fe_id IN NUMBER,
		p_connect_proc_name OUT NOCOPY VARCHAR2,
		p_disconnect_proc_name OUT NOCOPY VARCHAR2)
IS
  lv_fe_name  varchar2(80);
  lv_fetype_id  NUMBER;
  lv_fetype     varchar2(40);
  lv_fe_sw_generic   varchar2(40);
  lv_adapter_type  varchar2(40);

  lv_dummynum NUMBER;
BEGIN
	GetFeConfigInfoNum
		(p_fe_id => Get_FE_ConnectionProc.p_fe_id,
		 p_fe => lv_fe_name,
		 p_fetype_id => lv_fetype_id,
		 p_fetype => lv_fetype,
		 p_fe_sw_generic => lv_fe_sw_generic,
		 p_adapter_type  => lv_adapter_type,
		 p_gen_lookup_id => lv_dummynum,
		 p_connect_proc  => Get_FE_ConnectionProc.p_connect_proc_name,
		 p_disconnect_proc => Get_FE_ConnectionProc.p_disconnect_proc_name);

END Get_FE_ConnectionProc;


Function Is_Fe_Valid(p_fe_id in number) return BOOLEAN
is
 lv_valid boolean := FALSE;
  lv_dummynum NUMBER;
  lv_dummyvar VARCHAR2(80);

begin

  begin
	GetFeConfigInfoNum
		(p_fe_id => Is_Fe_Valid.p_fe_id,
		 p_fe => lv_dummyvar,
		 p_fetype_id => lv_dummynum,
		 p_fetype => lv_dummyvar,
		 p_fe_sw_generic => lv_dummyvar,
		 p_adapter_type  => lv_dummyvar,
		 p_gen_lookup_id => lv_dummynum,
		 p_connect_proc  => lv_dummyvar,
		 p_disconnect_proc => lv_dummyvar);

	lv_valid := TRUE;

  exception
  when no_data_found then
	lv_valid := FALSE;
  end;

	return (lv_valid);

end Is_Fe_Valid;


Function Is_Fe_Valid(p_fe_name in varchar2) return BOOLEAN
is
 lv_valid boolean := FALSE;
  lv_dummynum NUMBER;
  lv_dummyvar VARCHAR2(80);

begin

  begin
	GetFeConfigInfoText
		(p_fe => Is_Fe_Valid.p_fe_name,
		 p_fe_id => lv_dummynum,
		 p_fetype_id => lv_dummynum,
		 p_fetype => lv_dummyvar,
		 p_fe_sw_generic => lv_dummyvar,
		 p_adapter_type  => lv_dummyvar,
		 p_gen_lookup_id => lv_dummynum,
		 p_connect_proc  => lv_dummyvar,
		 p_disconnect_proc => lv_dummyvar);

	lv_valid := TRUE;

  exception
  when no_data_found then
	lv_valid := FALSE;
  end;

	return (lv_valid);
end Is_Fe_Valid;


/*
  Retrieve the list of the workitems SFM has executed for the given order.
*/
Function Get_Workitem_List(
	p_sdp_order_id NUMBER)
  return XDP_TYPES.WORKITEM_LIST
IS
  lv_list XDP_TYPES.WORKITEM_LIST;
  lv_index number;
  lv_err  varchar2(4000);
  lv_ret  number;
  lv_str  varchar2(2000);
  lv_err_list XDP_TYPES.MESSAGE_LIST;
  CURSOR lc_wi IS
   select
	fwt.workitem_instance_id,
	fwt.workitem_id,
	wim.workitem_name,
	fwt.wi_sequence,
	fwt.status_code,
	fwt.priority,
	fwt.line_item_id,
	fwt.line_number,
	fwt.provisioning_date,
	NVL(fwt.error_ref_id,0) error_ref_id
   from
	XDP_FULFILL_WORKLIST fwt,
	xdp_workitems wim
  where
	fwt.order_id = p_sdp_order_id and
	fwt.workitem_id = wim.workitem_id;

  lv_index2 binary_integer;
  lv_error_type varchar2(30);
  lv_date  DATE;

BEGIN

  lv_index := 0;

  for lv_wi_rec in lc_wi loop
	lv_index := lv_index + 1;
	lv_list(lv_index).workitem_name := lv_wi_rec.workitem_name;
	lv_list(lv_index).workitem_id  := lv_wi_rec.workitem_id;
	lv_list(lv_index).provisioning_sequence := lv_wi_rec.wi_sequence;
	lv_list(lv_index).provisioning_date := lv_wi_rec.provisioning_date;
	lv_list(lv_index).priority := lv_wi_rec.priority;
	lv_list(lv_index).workitem_status := lv_wi_rec.status_code;
	lv_list(lv_index).workitem_instance_id := lv_wi_rec.workitem_instance_id;
	lv_list(lv_index).line_item_id := lv_wi_rec.line_item_id;
	lv_list(lv_index).line_number := lv_wi_rec.line_number;

	-- if lv_wi_rec.error_ref_id > 0 then
	if lv_wi_rec.status_code = 'ERROR' then

		-- XDP_ERRORS_PKG.Get_Message_List (
		-- 	p_message_ref_id => lv_wi_rec.error_ref_id ,
		-- 	p_message_list => lv_err_list,
		-- 	p_sql_code => lv_ret,
		-- 	p_sql_desc => lv_str);

		-- if lv_err_list.count > 0 then
		-- 	lv_index2 := lv_err_list.first;
		-- 	lv_list(lv_index).error_description :=
		-- 	lv_err_list(lv_index2).message_text;
		-- end if;

		XDP_ERRORS_PKG.Get_Last_Message (
		 	p_object_type => 'WORKITEM',
		 	p_object_key => lv_wi_rec.workitem_instance_id,
		 	p_message => lv_list(lv_index).error_description,
			p_error_type => lv_error_type,
		 	p_message_timestamp => lv_date);
	end if;

  end loop;

  return lv_list;

END  Get_Workitem_List;

/*
  Retrieve the list of the fulfillment actions SFM has executed
  for the given workitem.
*/
Function Get_FA_List(
	p_wi_instance_id NUMBER)
  return XDP_TYPES.FULFILLMENT_ACTION_LIST
IS
  lv_list XDP_TYPES.FULFILLMENT_ACTION_LIST;
  lv_index number;
  lv_err  varchar2(4000);
  lv_ret  number;
  lv_str  varchar2(2000);
  lv_err_list XDP_TYPES.MESSAGE_LIST;
  lv_index2 binary_integer;

  lv_error_type varchar2(30);
  lv_date  DATE;


  CURSOR lc_fa IS
   select
	frt.fa_instance_id,
	fan.fulfillment_action,
	frt.status_code,
	frt.fulfillment_action_id,
	frt.priority,
	frt.provisioning_sequence,
      NVL(frt.error_ref_id, 0) error_ref_id
  from
	xdp_fa_runtime_list frt,
	XDP_FULFILL_ACTIONS fan
  where
	frt.workitem_instance_id = p_wi_instance_id and
	frt.fulfillment_action_id = fan.fulfillment_action_id;
BEGIN

  lv_index := 0;
  FOR lv_fa_rec in lc_fa loop
	lv_index := lv_index + 1;
	lv_list(lv_index).fa_instance_id := lv_fa_rec.fa_instance_id ;
	lv_list(lv_index).fulfillment_action_id  := lv_fa_rec.fulfillment_action_id;
	lv_list(lv_index).provisioning_sequence := lv_fa_rec.provisioning_sequence;
	lv_list(lv_index).priority := lv_fa_rec.priority;
	lv_list(lv_index).fa_status := lv_fa_rec.status_code;
	lv_list(lv_index).fulfillment_action := lv_fa_rec.fulfillment_action;

	-- Changed - sacsharm - 11.5.6 ErrorHandling

	-- if lv_fa_rec.error_ref_id > 0 then
	if lv_fa_rec.status_code = 'ERROR' then

		-- XDP_ERRORS_PKG.Get_Message_List (
		-- 	p_message_ref_id => lv_fa_rec.error_ref_id ,
		-- 	p_message_list => lv_err_list,
		-- 	p_sql_code => lv_ret,
		-- 	p_sql_desc => lv_str);
		--if lv_err_list.count > 0 then
		-- 	lv_index2 := lv_err_list.first;
		-- 	lv_list(lv_index).error_description :=
		-- 	lv_err_list(lv_index2).message_text;
		--end if;

		-- Anyway earlier code was interest in last message
		XDP_ERRORS_PKG.Get_Last_Message (
		 	p_object_type => 'FA',
		 	p_object_key => lv_fa_rec.fa_instance_id,
		 	p_message => lv_list(lv_index).error_description,
			p_error_type => lv_error_type,
		 	p_message_timestamp => lv_date);
	end if;

  END LOOP;

  return lv_list;

END Get_FA_List;

/*
  Retrieve the list of commands which have been sent by the
  given FA and the responds SFM received from the FE
*/
Function Get_FA_AUDIT_TRAILS(
	p_fa_instance_id NUMBER)
  return XDP_TYPES.FA_COMMAND_AUDIT_TRAIL
IS
  lv_list XDP_TYPES.FA_COMMAND_AUDIT_TRAIL;
  lv_index number;
  CURSOR lc_fe IS
   select
	fcl.fa_instance_id,
	fcl.fe_command_seq ,
	fan.fulfillment_action,
	frt.fulfillment_action_id  ,
	fcl.command_sent ,
	fcl.command_sent_date ,
	fcl.response ,
	fcl.response_date ,
      fcl.USER_RESPONSE ,
	fcl.msg_id  ,
	fcl.provisioning_procedure,
	fcl.fulfillment_element_name
  from
	xdp_fa_runtime_list frt,
	XDP_FULFILL_ACTIONS fan,
	xdp_fe_cmd_aud_trails fcl
  where
	frt.fa_instance_id = fcl.fa_instance_id and
	frt.fulfillment_action_id = fan.fulfillment_action_id and
	fcl.fa_instance_id = p_fa_instance_id;
BEGIN

  lv_index := 0;
  FOR lv_fa_rec in lc_fe loop
	lv_index := lv_index + 1;
	lv_list(lv_index).fa_instance_id := lv_fa_rec.fa_instance_id ;
	lv_list(lv_index).fulfillment_action_id  := lv_fa_rec.fulfillment_action_id;
	lv_list(lv_index).fulfillment_action := lv_fa_rec.fulfillment_action;
	lv_list(lv_index).command_sequence := lv_fa_rec.fe_command_seq;
	lv_list(lv_index).command_sent := lv_fa_rec.command_sent;
	lv_list(lv_index).command_sent_date:= lv_fa_rec.command_sent_date;
	lv_list(lv_index).fe_response := lv_fa_rec.response;
	lv_list(lv_index).response_date := lv_fa_rec.response_date;
	lv_list(lv_index).user_response := lv_fa_rec.user_response;
	lv_list(lv_index).message_id := lv_fa_rec.msg_id;
	lv_list(lv_index).fulfillment_procedure_name := lv_fa_rec.provisioning_procedure;
	lv_list(lv_index).fulfillment_element_name := lv_fa_rec.fulfillment_element_name;
  END LOOP;

  return lv_list;

END Get_FA_AUDIT_TRAILS;

  -------------------------------------------------------------------
  -- Description : Procedure to reset a Synchronisation Request
  -------------------------------------------------------------------
  --
  PROCEDURE Reset_Sync_Registration (
    pp_sync_label	IN  VARCHAR2
   ,po_error_code       OUT NOCOPY NUMBER
   ,po_error_msg	OUT NOCOPY VARCHAR2
  )
  IS
   -- lv_error_code	NUMBER;
   -- lv_error_msg	VARCHAR2(1000);

  BEGIN

    -- Reset the Synchronisation Request
    --
    Xnp_WF_Sync.Reset_Sync_Register (pp_sync_label => pp_sync_label
                                 ,po_error_code => po_error_code
                                 ,po_error_msg  => po_error_msg);
    -- po_error_code := lv_error_code;
    -- po_error_msg  := lv_error_msg;

    EXCEPTION
      WHEN OTHERS THEN
        po_error_code := -191266;
        FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
        FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
        po_error_msg := FND_MESSAGE.GET;

  END Reset_Sync_Registration;

  -------------------------------------------------------------------
  -- Description : Procedure to recalculate timers
  -------------------------------------------------------------------
  PROCEDURE recalculate
  (
    p_reference_id  IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  )
  IS

  BEGIN
       --- Call the recalculate api from timer core
       xnp_timer_core.recalculate(p_reference_id => p_reference_id
                                 ,p_timer_message_code => p_timer_message_code
                                 ,x_error_code => x_error_code
                                 ,x_error_message => x_error_message
                                 );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;


  END recalculate;

  -------------------------------------------------------------------
  -- Description : Procedure to recalculate all timers
  -------------------------------------------------------------------
  PROCEDURE recalculate_all
  (
    p_reference_id IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  )
  IS

  BEGIN
       --- Call the recalculate_all api from timer core
       xnp_timer_core.recalculate_all
                      (p_reference_id => p_reference_id
                       ,x_error_code => x_error_code
                       ,x_error_message => x_error_message
                      );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;

  END recalculate_all;
  -------------------------------------------------------------------
  -- Description : Procedure to get timer status using reference_id and
  --               timer message code
  -------------------------------------------------------------------
  PROCEDURE get_timer_status
  (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_timer_id OUT NOCOPY NUMBER
    ,x_status OUT NOCOPY VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  )
  IS

  BEGIN
       --- Call the get_timer_status api from timer core
       --- Returns the status and timer_id
       xnp_timer_core.get_timer_status
                      (p_reference_id => p_reference_id
                       ,p_timer_message_code => p_timer_message_code
                       ,x_timer_id => x_timer_id
                       ,x_status => x_status
                       ,x_error_code => x_error_code
                       ,x_error_message => x_error_message
                      );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;

  END get_timer_status;
  -------------------------------------------------------------------
  -- Description : Procedure to update timer status using reference_id
  --               and timer_message_code
  -------------------------------------------------------------------
  PROCEDURE update_timer_status
  (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,p_status IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  )
  IS

  BEGIN
       --- Call the get_timer_status api from timer core
       --- Returns the status and timer_id
       xnp_timer_core.update_timer_status
                      (p_reference_id => p_reference_id
                       ,p_timer_message_code => p_timer_message_code
                       ,p_status => p_status
                       ,x_error_code => x_error_code
                       ,x_error_message => x_error_message
                      );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;

  END update_timer_status;

  -------------------------------------------------------------------
  -- Description : Procedure to remove timer using reference_id and
  --               timer_message_code
  -------------------------------------------------------------------
  PROCEDURE remove_timer
  (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  )
  IS

  BEGIN
       --- Call the remove_timer api from timer core
       xnp_timer_core.remove_timer
                      (p_reference_id => p_reference_id
                       ,p_timer_message_code => p_timer_message_code
                       ,x_error_code => x_error_code
                       ,x_error_message => x_error_message
                      );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;

  END remove_timer;
  -------------------------------------------------------------------
  -- Description : Procedure to restart a timer using a reference_id
  --               and timer_message_code
  -------------------------------------------------------------------
  PROCEDURE restart
  (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  )

  IS

  BEGIN
       --- Call the restart api from timer core
       xnp_timer_core.restart
                      (p_reference_id => p_reference_id
                       ,p_timer_message_code => p_timer_message_code
                       ,x_error_code => x_error_code
                       ,x_error_message => x_error_message
                      );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;

  END restart;
  -------------------------------------------------------------------
  -- Description : Procedure to deregister timers for an order_id
  -------------------------------------------------------------------
  PROCEDURE deregister
  (
    p_order_id IN NUMBER
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  )

  IS

  BEGIN
       --- Call the deregister api from timer core
       xnp_timer_core.deregister
                      (p_order_id => p_order_id
                       ,x_error_code => x_error_code
                       ,x_error_message => x_error_message
                      );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;

  END deregister;
  -------------------------------------------------------------------
  -- Description : Procedure to restart all timers using reference_id
  -------------------------------------------------------------------
  PROCEDURE restart_all
  (
    p_reference_id IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2

  )
  IS

  BEGIN
       --- Call the restart_all api from timer core
       xnp_timer_core.restart_all
                      (p_reference_id => p_reference_id
                       ,x_error_code => x_error_code
                       ,x_error_message => x_error_message
                      );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;

  END restart_all;
  -------------------------------------------------------------------
  -- Description : Procedure to start timers related to a message
  -------------------------------------------------------------------
  PROCEDURE start_related_timers
  (
    p_message_code IN VARCHAR2
    ,p_reference_id IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
    ,p_opp_reference_id IN VARCHAR2 DEFAULT NULL
    ,p_sender_name IN VARCHAR2 DEFAULT NULL
    ,p_recipient_name IN VARCHAR2 DEFAULT NULL
    ,p_order_id IN NUMBER DEFAULT NULL
    ,p_wi_instance_id IN NUMBER DEFAULT NULL
    ,p_fa_instance_id IN NUMBER DEFAULT NULL
  )

  IS

  BEGIN
       --- Call the start_related_timers api from timer core
       xnp_timer_core.start_related_timers
                      (p_message_code => p_message_code
                       ,p_reference_id => p_reference_id
                       ,x_error_code => x_error_code
                       ,x_error_message => x_error_message
                       ,p_opp_reference_id => p_opp_reference_id
                       ,p_sender_name => p_sender_name
                       ,p_recipient_name  => p_recipient_name
                       ,p_order_id => p_order_id
                       ,p_wi_instance_id => p_wi_instance_id
                       ,p_fa_instance_id => p_fa_instance_id
                      );
       EXCEPTION
         WHEN OTHERS THEN
             x_error_code := -191266;
             FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
             FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
             FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
             x_error_message := FND_MESSAGE.GET;

  END start_related_timers;

 --	API to set the order reference information such as order
 -- reference name, order reference value, service provider
 -- order number, and service provider user ID
 PROCEDURE Set_Order_Reference
 (
   p_order_id IN NUMBER,
   p_order_ref_name IN VARCHAR2,
   p_order_ref_value IN VARCHAR2,
   p_sp_order_number IN VARCHAR2 DEFAULT NULL,
   p_sp_user_id  IN NUMBER DEFAULT NULL,
   x_return_code OUT NOCOPY NUMBER,
   x_error_description OUT NOCOPY VARCHAR2
  )
  IS
    lv_ref_name VARCHAR2(80);
    lv_ref_val VARCHAR2(300);
    lv_sp_order VARCHAR2(80);
    --lv_sp_uid NUMBER;
  BEGIN
	 x_return_code := 0;
	 select ORDER_REF_NAME,
                ORDER_REF_VALUE,
                SP_ORDER_NUMBER
                --SP_USERID
	 into lv_ref_name,
              lv_ref_val,
              lv_sp_order
              --,lv_sp_uid
	 from xdp_order_headers
	 where order_id = p_order_id;

	 update xdp_order_headers
	 set
	   order_ref_name = NVL(p_order_ref_name,lv_ref_name),
	   order_ref_value = NVL(p_order_ref_value,lv_ref_val),
	   sp_order_number = NVL(p_sp_order_number,lv_sp_order),
	   --sp_userid = NVL(p_sp_user_id,lv_sp_uid),
       last_updated_by = FND_GLOBAL.USER_ID,
       last_update_date = sysdate,
       last_update_login = FND_GLOBAL.LOGIN_ID
       where order_id = p_order_id;


  EXCEPTION
	WHEN NO_DATA_FOUND THEN
   		x_return_code := SQLCODE;
   		FND_MESSAGE.SET_NAME('XDP', 'XDP_ORDER_NOTEXISTS');
   		FND_MESSAGE.SET_TOKEN('ORDER_ID', p_order_id);
   		x_error_description := FND_MESSAGE.GET;
    WHEN OTHERS THEN
       x_return_code := -191266;
       FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
       FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB');
       FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
       x_error_description := FND_MESSAGE.GET;

  END Set_Order_Reference;

-- a private utility used by XDP_SYNC_LINE_ITEM_PV
  PROCEDURE Get_Parameter_Value_From_WI(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	x_parameter_value OUT NOCOPY VARCHAR2)
  IS
   cursor c_GetLatestWiParam is
	SELECT parameter_value
	FROM
           xdp_worklist_details wd,
           xdp_fulfill_worklist fw,
           xdp_wi_parameters wp
	WHERE FW.line_item_id=p_line_item_id
	  AND FW.workitem_instance_id = wd.workitem_instance_id
          AND wd.workitem_id = wp.workitem_id
          AND wd.parameter_name = wp.parameter_name    --to do
          AND wp.parameter_name = p_parameter_name
          AND parameter_value is not null
          ORDER BY wd.creation_date desc;

  BEGIN
	x_parameter_value := NULL;
	FOR v_GetLatestWiParam in c_GetLatestWiParam LOOP
		x_parameter_value := v_GetLatestWiParam.parameter_value;
		EXIT;		-- ONLY TAKE THE LATEST VALUE
	END LOOP;
  END Get_Parameter_Value_From_WI;

  PROCEDURE XDP_SYNC_LINE_ITEM_PV(
		p_line_item_id IN XDP_ORDER_LINE_ITEMS.LINE_ITEM_ID%TYPE,
		x_return_code OUT NOCOPY NUMBER,
   		x_error_description OUT NOCOPY VARCHAR2
  ) IS
  CURSOR c_line_item IS
	SELECT line_parameter_name, PARAMETER_VALUE
          FROM XDP_ORDER_LINEITEM_DETS
         WHERE LINE_ITEM_ID = p_line_item_id
	   AND PARAMETER_VALUE IS NULL
	FOR UPDATE OF PARAMETER_VALUE NOWAIT;
  l_parameter_value VARCHAR2(4000);
  BEGIN
		FOR l_line_item_dets IN c_line_item LOOP
			Get_Parameter_Value_From_WI(p_line_item_id,l_line_item_dets.line_parameter_name,l_parameter_value);
			IF (l_parameter_value IS NOT NULL) THEN
				UPDATE XDP_ORDER_LINEITEM_DETS SET PARAMETER_VALUE = l_parameter_value
					WHERE CURRENT OF c_line_item;
			END IF;
		END LOOP;

  EXCEPTION
	WHEN OTHERS THEN
       x_return_code := -191266;
       FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
       FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPENGNB.XDP_SYNC_LINE_ITEM_PV');
       FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
       x_error_description := FND_MESSAGE.GET;
  END XDP_SYNC_LINE_ITEM_PV;

Procedure Get_WI_Parameter_Info (p_wi_instance_id 	  IN NUMBER,
				 p_parameter_name 	  IN VARCHAR2,
				 p_evaluation_procedure   OUT NOCOPY VARCHAR2,
				 p_evaluation_mode	  OUT NOCOPY VARCHAR2,
				 p_default_value	  OUT NOCOPY VARCHAR2,
				 p_parameter_value	  OUT NOCOPY VARCHAR2,
				 p_parameter_ref_value    OUT NOCOPY VARCHAR2,
				 p_audit_flag		  OUT NOCOPY VARCHAR2,
				 p_workitem_id	  OUT NOCOPY NUMBER)
IS

   CURSOR c_GetWiParamInfo IS
     select
	is_value_evaluated,
	modified_flag,
	parameter_value,
	parameter_ref_value,
	workitem_id
    from xdp_worklist_details
    where workitem_instance_id = p_wi_instance_id
      and parameter_name = p_parameter_name;

   CURSOR c_GetEvalInfo is
     select
 	wpr.workitem_id,
	wpr.evaluation_procedure,
	wpr.evaluation_mode,
	wpr.default_value,
	NVL(wpr.log_in_audit_trail_flag,'Y') audit_trail_flag
     from
	xdp_wi_parameters wpr,
	xdp_worklist_details wdl
     where
	wpr.workitem_id = wdl.workitem_id and
	wpr.parameter_name = p_parameter_name and
	wdl.workitem_instance_id = p_wi_instance_id;

        lv_found_details BOOLEAN := FALSE;
        lv_found_config BOOLEAN := FALSE;
	lv_Evaluated varchar2(10);
begin

	p_default_value := null;
	p_evaluation_procedure := null;
	p_evaluation_mode := null;
	p_audit_flag := null;

	for v_GetWiParamInfo in c_GetWiParamInfo loop
		p_parameter_value := v_GetWiParamInfo.parameter_value;
		p_parameter_ref_value := v_GetWiParamInfo.parameter_ref_value;
		lv_Evaluated := v_GetWiParamInfo.is_value_evaluated;
		p_workitem_id := v_GetWiParamInfo.workitem_id;

		lv_found_details := TRUE;
	end loop;

	if lv_Evaluated = 'Y' then
		return;
	end if;

	-- Parameter is not Yet Evaluated-- Must be Deferred Evaluation
	-- Get the Deferred Evaluation procedure
	for v_GetEvalInfo in c_GetEvalInfo loop
		p_evaluation_procedure := v_GetEvalInfo.evaluation_procedure;
		p_audit_flag := v_GetEvalInfo.audit_trail_flag;
		p_default_value := v_GetEvalInfo.default_value;
		p_evaluation_mode := v_GetEvalInfo.evaluation_mode;
		p_workitem_id := v_GetEvalInfo.workitem_id;

		lv_found_config := TRUE;
	end loop;

	if (not lv_found_details) and (not lv_found_config) then
		raise no_data_found;
	end if;

end Get_WI_Parameter_Info;

Procedure Get_FA_Parameter_info (p_fa_instance_id 	  IN NUMBER,
				 p_parameter_name 	  IN VARCHAR2,
				 p_evaluation_procedure OUT NOCOPY VARCHAR2,
				 p_fa_id		  OUT NOCOPY NUMBER,
				 p_default_value	  OUT NOCOPY VARCHAR2,
				 p_parameter_value	  OUT NOCOPY VARCHAR2,
				 p_parameter_ref_value  OUT NOCOPY VARCHAR2,
				 p_audit_flag		  OUT NOCOPY VARCHAR2)
is

   CURSOR c_GetFAParamInfo IS
     select
	evaluation_procedure,
	NVL(log_in_audit_trail_flag,'Y') audit_trail_flag,
	default_value,
	parameter_value,
	parameter_ref_value,
	frt.fulfillment_action_id
     from
	xdp_fa_parameters fpr,
	xdp_fa_details frt
     where
	fpr.parameter_name = frt.parameter_name and
	fpr.fulfillment_action_id = frt.fulfillment_action_id and
	fpr.parameter_name = p_parameter_name and
	frt.fa_instance_id = p_fa_instance_id;

        lv_found BOOLEAN := FALSE;
begin

	for v_GetFAParamInfo in c_GetFAParamInfo loop
		p_parameter_value := v_GetFAParamInfo.parameter_value;
		p_parameter_ref_value := v_GetFAParamInfo.parameter_ref_value;
		p_default_value := v_GetFAParamInfo.default_value;
		p_evaluation_procedure := v_GetFAParamInfo.evaluation_procedure;
		p_fa_id := v_GetFAParamInfo.fulfillment_action_id;
		p_audit_flag := v_GetFAParamInfo.audit_trail_flag;

		lv_found := TRUE;
	end loop;

	if not lv_found then
		raise no_data_found;
	end if;

End Get_FA_Parameter_info;

Function DoesWIParamExist (p_wi_instance_id IN NUMBER,
			   p_parameter_name IN VARCHAR2) return VARCHAR2
is

 CURSOR c_CheckWIParam is
      select 'Y' yahoo
      from dual
	where exists(
       select 'x' from
	  xdp_worklist_details
	  where workitem_instance_id = p_wi_instance_id and
		  parameter_name = p_parameter_name);

 lv_exists varchar2(1) := 'N';
begin

  For v_CheckWIParam in c_CheckWIParam loop
	lv_exists := v_CheckWIParam.yahoo;
	exit;
  end loop;


  return (lv_exists);

End DoesWIParamExist;


Function DoesFAParamExist (p_fa_instance_id IN NUMBER,
			   p_parameter_name IN VARCHAR2) return VARCHAR2
is
 lv_exists varchar2(1) := 'N';

  CURSOR c_CheckFAParam is
      select 'Y' yahoo
      from dual
	where exists(
       select 'x' from
	  xdp_fa_details
	  where fa_instance_id = p_fa_instance_id and
		  parameter_name = p_parameter_name);
begin

  For v_CheckFAParam in c_CheckFAParam loop
	lv_exists := v_CheckFAParam.yahoo;
	exit;
  end loop;


  return (lv_exists);

end DoesFAParamExist;


Function DoesOrderParamExist (p_order_id IN NUMBER,
			      p_parameter_name IN VARCHAR2) return VARCHAR2
is

 CURSOR c_CheckOrderParam is
     select 'Y' yahoo
     from dual
     where exists(
	select 'x'
	from xdp_order_parameters
   	where   order_id = p_order_id and
		order_parameter_name = p_parameter_name);

 lv_exists varchar2(1) := 'N';
begin

  For v_CheckOrderParam in c_CheckOrderParam loop
	lv_exists := v_CheckOrderParam.yahoo;
	exit;
  end loop;


  return (lv_exists);
end DoesOrderParamExist;


Function DoesLineParamExist (p_line_item_id IN NUMBER,
			     p_parameter_name IN VARCHAR2) return VARCHAR2
is
  CURSOR c_CheckLineParam is
     select 'Y' yahoo
     from dual
     where exists(
	select 'x'
	from XDP_ORDER_LINEITEM_DETS
	where	line_item_id = p_line_item_id and
		line_parameter_name = p_parameter_name);

 lv_exists varchar2(1) := 'N';
begin

  For v_CheckLineParam in c_CheckLineParam loop
        lv_exists := v_CheckLineParam.yahoo;
        exit;
  end loop;

  return (lv_exists);

end DoesLineParamExist;


Procedure LoadOrderParameters(	p_order_id 		IN NUMBER,
				p_parameter_name 	IN VARCHAR2,
				p_parameter_value 	IN VARCHAR2)
is

begin

     insert into xdp_order_parameters
     (order_id,
	order_parameter_name,
	order_parameter_value,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login
      )
      values
      (	p_order_id,
	p_parameter_name,
	p_parameter_value,
	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.LOGIN_ID
	);

end LoadOrderParameters;

Procedure LoadLineDetails(p_line_item_id 		IN NUMBER,
			  p_parameter_name 		IN VARCHAR2,
			  p_parameter_value 		IN VARCHAR2,
			  p_parameter_reference_value 	IN VARCHAR2)
is
begin

     insert into XDP_ORDER_LINEITEM_DETS
     (	line_item_id,
	line_parameter_name,
	parameter_value,
	parameter_reference_value,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login
     )
     values
     (	p_line_item_id,
	p_parameter_name,
	p_parameter_value,
	p_parameter_reference_value,
	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.LOGIN_ID
     );

end LoadLineDetails;

Procedure LoadWorklistDetails(
        p_wi_instance_id 		IN NUMBER,
		p_parameter_name 		IN VARCHAR2,
		p_workitem_id 		IN NUMBER,
		p_is_value_evaluated	IN VARCHAR2,
		p_parameter_value		IN VARCHAR2,
		p_parameter_ref_value	IN VARCHAR2)
IS
    l_workitem_id NUMBER;
BEGIN
    l_workitem_id := p_workitem_id;
    IF l_workitem_id IS NULL THEN
        SELECT
            workitem_id INTO l_workitem_id
        FROM
            xdp_fulfill_worklist
        WHERE
            workitem_instance_id = p_wi_instance_id;
    END IF;
    INSERT INTO xdp_worklist_details
    (
        workitem_instance_id,
        parameter_name,
        workitem_id,
        is_value_evaluated,
        parameter_value,
        parameter_ref_value,
	modified_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
    )VALUES
    (
        p_wi_instance_id,
        p_parameter_name,
        l_workitem_id,
        p_is_value_evaluated,
        p_parameter_value,
        p_parameter_ref_value,
	'N',
        FND_GLOBAL.USER_ID,
        sysdate,
        FND_GLOBAL.USER_ID,
        sysdate,
        FND_GLOBAL.LOGIN_ID
    );
END LoadWorklistDetails;

Procedure UpdateWorklistDetails(
            p_wi_instance_id        IN NUMBER,
			p_parameter_name        IN VARCHAR2,
            p_is_value_evaluated     IN VARCHAR2,
			p_parameter_value	    IN VARCHAR2,
			p_parameter_ref_value	IN VARCHAR2)
IS
BEGIN
    UPDATE xdp_worklist_details
        SET
            parameter_value = p_parameter_value ,
            parameter_ref_value = p_parameter_ref_value,
            is_value_evaluated = p_is_value_evaluated,
            modified_flag = 'Y',
            last_updated_by = FND_GLOBAL.USER_ID,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.LOGIN_ID
        WHERE
            workitem_instance_id = p_wi_instance_id AND
            parameter_name = p_parameter_name;
END UpdateWorklistDetails;

Procedure LoadFADetails(p_fa_instance_id 	IN NUMBER,
			p_parameter_name	IN VARCHAR2,
			p_fa_id 		IN NUMBER,
			p_is_value_evaluated	IN VARCHAR2,
			p_parameter_value	IN VARCHAR2,
			p_parameter_ref_value	IN VARCHAR2)
is
begin

        insert into xdp_fa_details
	    (  fa_instance_id,
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
	  values
	   (  	p_fa_instance_id,
		p_parameter_name,
		p_fa_id,
		p_is_value_evaluated,
		p_parameter_value,
		p_parameter_ref_value,
		FND_GLOBAL.USER_ID,
		sysdate,
		FND_GLOBAL.USER_ID,
		sysdate,
		FND_GLOBAL.LOGIN_ID
	    );

end LoadFADetails;

Procedure UpdateFaDetails(p_fa_instance_id 	IN NUMBER,
			  p_parameter_name      IN VARCHAR2,
			  p_evaluated_flag      IN VARCHAR2,
			  p_parameter_value	IN VARCHAR2,
			  p_parameter_ref_value	IN VARCHAR2)
is

begin

     update xdp_fa_details
     set
	parameter_value = UpdateFaDetails.p_parameter_value,
	parameter_ref_value = UpdateFaDetails.p_parameter_ref_value,
	is_value_evaluated = UpdateFaDetails.p_evaluated_flag,
	last_updated_by = FND_GLOBAL.USER_ID,
	last_update_date = sysdate,
	last_update_login = FND_GLOBAL.LOGIN_ID
     where
	fa_instance_id = UpdateFaDetails.p_fa_instance_id and
	parameter_name = UpdateFaDetails.p_parameter_name;

end UpdateFaDetails;

Procedure CallWIEvalProc  (p_wi_instance_id 	IN NUMBER,
			   p_procedure_name	IN VARCHAR2,
			   p_order_id 		IN NUMBER,
			   p_line_item_id	IN NUMBER,
			   p_param_val 		IN VARCHAR2,
			   p_param_ref_val 	IN VARCHAR2,
			   p_param_eval_val 	OUT NOCOPY VARCHAR2,
			   p_param_eval_ref_val	OUT NOCOPY VARCHAR2,
			   p_return_code 	OUT NOCOPY NUMBER,
			   p_error_description 	OUT NOCOPY VARCHAR2)
is
    lv_order_id 	number;
    lv_line_item_id number;
    e_wi_eval_failed exception;
begin
    if (p_line_item_id IS NULL) OR (lv_order_id IS NULL) then
        select order_id,line_item_id
        into lv_order_id, lv_line_item_id
        from XDP_FULFILL_WORKLIST
        where workitem_instance_id = p_wi_instance_id;
    else
        lv_order_id := p_order_id;
        lv_line_item_id := p_line_item_id;
    end if;

    XDP_UTILITIES.CallWIParamEvalProc(
        p_procedure_name => CallWIEvalProc.p_procedure_name,
        p_order_id => lv_order_id,
        p_line_item_id => lv_line_item_id,
        p_wi_instance_id => CallWIEvalProc.p_wi_instance_id,
		p_param_val  => CallWIEvalProc.p_param_val,
		p_param_ref_val => CallWIEvalProc.p_param_ref_val,
		p_param_eval_val => CallWIEvalProc.p_param_eval_val,
		p_param_eval_ref_val => CallWIEvalProc.p_param_eval_ref_val,
		p_return_code => CallWIEvalProc.p_return_code,
		p_error_description => CallWIEvalProc.p_error_description);
     if( p_return_code <> 0 ) THEN
        raise e_wi_eval_failed;
     end if;
EXCEPTION
   when others then
   xdpcore.context( 'XDP_ENGINE', 'CallWIEvalProc', 'WI', p_wi_instance_id );
END CallWIEvalProc;

Procedure ComputeWIParamValue(
            p_raise 		IN VARCHAR2,
			p_mode 			IN VARCHAR2,
			p_wi_instance_id 	IN NUMBER,
			p_procedure_name 	IN VARCHAR2,
			p_param_val 		IN VARCHAR2,
			p_param_ref_val 	IN VARCHAR2,
			p_default_value 	IN VARCHAR2,
			p_param_eval_val 	OUT NOCOPY VARCHAR2,
			p_param_eval_ref_val 	OUT NOCOPY VARCHAR2,
			p_return_code 		OUT NOCOPY NUMBER,
			p_error_description 	OUT NOCOPY VARCHAR2)
IS
BEGIN
    p_param_eval_val := NVL(p_param_val,p_default_value);
    p_param_eval_ref_val := p_param_ref_val;

    -- Date: 13-Jan-2005  Author: DPUTHIYE  Bug: 4083708.
    -- Change Desc: In the following IF clause the constant identifier has been replaced with the value of
    -- 'Deferred' eval mode as defined in the UI. The value of the constant seemed to be wrong.
    --IF p_mode = pv_evalModeDeferred THEN
    IF p_mode = 'ON_WORKITEM_START' THEN
        IF p_procedure_name IS NOT NULL then
            EvaluateWIParamValue(
                p_order_id              => NULL,
                p_line_item_id          => NULL,
                p_workitem_id           => NULL,
                p_wi_instance_id        => p_wi_instance_id,
                p_parameter_name        => NULL,
                p_procedure_name        => p_procedure_name,
                p_mode                  => p_mode,
                p_param_val             => p_param_val,
                p_param_ref_val         => p_param_ref_val,
                p_param_eval_val        => p_param_eval_val,
                p_param_eval_ref_val    => p_param_eval_ref_val,
                p_return_code           => p_return_code,
                p_error_description     => p_error_description);
            IF p_return_code <> 0 THEN
                IF p_raise = 'Y' THEN
		    FND_MESSAGE.SET_NAME('XDP', 'XDP_EXEC_EVAL_PROC_ERROR');
                    FND_MESSAGE.SET_TOKEN('ERROR_STRING1', p_procedure_name);
                    FND_MESSAGE.SET_TOKEN('ERROR_STRING2', p_error_description);
                    APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
            END IF;
        END IF;
    END IF;
END ComputeWIParamValue;

--
-- This is the only procedure that should be called when one need to
-- evaluate workitem parameter value
--

Procedure EvaluateWIParamValue(
			p_order_id    	      IN NUMBER,
			p_line_item_id        IN NUMBER,
			p_workitem_id        IN NUMBER,
			p_wi_instance_id      IN NUMBER,
 			p_parameter_name 	  IN VARCHAR2,
			p_procedure_name      IN VARCHAR2,
			p_mode 			      IN VARCHAR2,
			p_param_val 	      IN VARCHAR2,
			p_param_ref_val       IN VARCHAR2,
			p_param_eval_val 	  OUT NOCOPY VARCHAR2,
			p_param_eval_ref_val  OUT NOCOPY VARCHAR2,
			p_return_code 		  OUT NOCOPY NUMBER,
			p_error_description   OUT NOCOPY VARCHAR2)
IS

  l_wi_disp_name varchar2(100);
  l_message_params VARCHAR2(1000);
  l_evalFailed exception;
  lv_item_type varchar2(200);
  lv_item_key varchar2(200);
  lv_error_code NUMBER;
  lv_error_desc VARCHAR2(2000);

  -- skilaru 06/03/2002 fix for ER# 2347984
  -- get the parent line work flow info  to set the error
  -- context in case of wi parameter evaluation failure..

  CURSOR c_getWFData IS
  SELECT oli.wf_item_type, oli.wf_item_key
    FROM xdp_order_line_items oli, xdp_fulfill_worklist fwl
   WHERE oli.line_item_id = fwl.line_item_id
     AND fwl.workitem_instance_id = p_wi_instance_id;

BEGIN

    IF p_procedure_name IS NULL THEN
		p_return_code := -1;
        p_error_description := 'No evaluation procedure is specified when call EvaluateWIParamValue';
    END IF;

    CallWIEvalProc (
        p_wi_instance_id => p_wi_instance_id,
		p_procedure_name => p_procedure_name,
		p_order_id => p_order_id,
		p_line_item_id=> p_line_item_id,
		p_param_val => p_param_val,
		p_param_ref_val => p_param_ref_val,
		p_param_eval_val => p_param_eval_val,
		p_param_eval_ref_val => p_param_eval_ref_val,
		p_return_code => p_return_code,
		p_error_description => p_error_description);

    IF p_return_code <> 0 THEN

       l_wi_disp_name := XDPCORE_WI.get_display_name( p_wi_instance_id );
       -- build the token string for xdp_errors_log..
       l_message_params := 'WI='||l_wi_disp_name||'#XDP#PARAM='|| p_parameter_name||'#XDP#';

       -- set the business error...
       XDPCORE.error_context( 'WI', p_wi_instance_id, 'XDP_WI_PARAM_EVAL_FAILED', l_message_params );
       xdpcore.context( 'XDP_ENGINE', 'CallWIParamEvalProc', 'WI', p_wi_instance_id, p_error_description );

       -- skilaru 06/03/2002 fix for ER# 2347984
       -- Set the Parameter name and Workitem instance ID in the workflow context
       -- so that when user responds to the notification with a new parameter value
       -- we should be able to extract the context and set the new value ..

       FOR lv_rec IN c_getWFData LOOP
         lv_item_type := lv_rec.wf_item_type;
         lv_item_key := lv_rec.wf_item_key;

         xdpcore.CheckNAddItemAttrNumber( lv_item_type, lv_item_key,
                                          'WORKITEM_INSTANCE_ID', p_wi_instance_id,
                                          lv_error_code, lv_error_desc);

         xdpcore.CheckNAddItemAttrText( lv_item_type, lv_item_key,
                                        'WI_PARAMETER_NAME', p_parameter_name,
                                        lv_error_code, lv_error_desc);
         EXIT;
       END LOOP;
       Raise l_evalFailed;
    END IF;

    IF p_mode = pv_evalModeDeferred THEN
        -- no parameter value will be written to the database table in this mode
        RETURN;
    ELSE
        SetWIParamValue(
            p_wi_instance_id =>p_wi_instance_id,
            p_workitem_id =>p_workitem_id,
            p_parameter_name =>p_parameter_name,
            p_is_value_evaluated =>'Y',
            p_parameter_value =>p_param_eval_val,
            p_parameter_ref_value => p_param_eval_ref_val,
            x_return_code => p_return_code,
            x_error_description => p_error_description
        );
    END IF;

exception
  when others then
   xdpcore.context( 'XDP_ENGINE', 'EvaluateWIParamValue', 'PARAMETER', p_parameter_name );
END EvaluateWIParamValue;

Procedure SetWIParamValue(
            p_wi_instance_id 	     IN NUMBER,
            p_workitem_id 		     IN NUMBER,
            p_parameter_name 	     IN VARCHAR2,
            p_parameter_value 	     IN VARCHAR2,
            p_parameter_ref_value 	 IN VARCHAR2,
            p_is_value_evaluated 	 IN VARCHAR2,
            x_return_code            OUT NOCOPY NUMBER,
            x_error_description      IN VARCHAR2)
IS
    lv_exists VARCHAR2(1) := 'N';
BEGIN
    lv_exists := DoesWIParamExist(
                    p_wi_instance_id => p_wi_instance_id,
                    p_parameter_name => p_parameter_name
                 );

    IF lv_exists = 'Y' THEN
        UpdateWorklistDetails(
            p_wi_instance_id        => p_wi_instance_id,
            p_parameter_name        => p_parameter_name,
            p_is_value_evaluated    => p_is_value_evaluated,
            p_parameter_value       => p_parameter_value,
	        p_parameter_ref_value   => p_parameter_ref_value
        );
    ELSE
        LoadWorklistDetails(
            p_wi_instance_id => p_wi_instance_id,
			p_parameter_name => p_parameter_name,
			p_workitem_id    => p_workitem_id,
			p_is_value_evaluated => p_is_value_evaluated,
			p_parameter_value => p_parameter_value,
			p_parameter_ref_value => p_parameter_ref_value);
   END IF;
END SetWIParamValue;

Procedure CallFAEvalProc  (p_fa_instance_id 	IN NUMBER,
			   p_wi_instance_id    IN NUMBER,
			   p_procedure_name	IN VARCHAR2,
			   p_order_id 		IN NUMBER,
			   p_line_item_id	IN NUMBER,
			   p_param_val 		IN VARCHAR2,
			   p_param_ref_val 	IN VARCHAR2,
			   p_param_eval_val 	OUT NOCOPY VARCHAR2,
			   p_param_eval_ref_val	OUT NOCOPY VARCHAR2,
			   p_return_code 	OUT NOCOPY NUMBER,
			   p_error_description 	OUT NOCOPY VARCHAR2)
is

 lv_order_id 	number;
 lv_line_item_id number := -9999;
 lv_wi_id number;

 CURSOR c_GetOrderData is
   select order_id, frt.workitem_instance_id,fwt.line_item_id
   from
	XDP_FULFILL_WORKLIST fwt,
	xdp_fa_runtime_list frt
   where
	fwt.workitem_instance_id = frt.workitem_instance_id and
	frt.fa_instance_id = p_fa_instance_id;

begin

	if p_line_item_id is null then
		for v_GetOrderData in c_GetOrderData loop
			lv_order_id := v_GetOrderData.order_id;
			lv_wi_id := v_GetOrderData.workitem_instance_id;
			lv_line_item_id := v_GetOrderData.line_item_id;
		end loop;

		if lv_line_item_id = -9999 then
			raise no_data_found;
		end if;
	else
		lv_order_id := p_order_id;
		lv_line_item_id := p_line_item_id;
		lv_wi_id := p_wi_instance_id;
	end if;

        XDP_UTILITIES.CallFAParamEvalProc(
		p_procedure_name => CallFAEvalProc.p_procedure_name,
		p_order_id => lv_order_id,
		p_line_item_id => lv_line_item_id,
		p_wi_instance_id => lv_wi_id,
		p_fa_instance_id => CallFAEvalProc.p_fa_instance_id,
		p_param_val  => CallFAEvalProc.p_param_val,
		p_param_ref_val => CallFAEvalProc.p_param_ref_val,
		p_param_eval_val => CallFAEvalProc.p_param_eval_val,
		p_param_eval_ref_val => CallFAEvalProc.p_param_eval_ref_val,
		p_return_code => CallFAEvalProc.p_return_code,
		p_error_description => CallFAEvalProc.p_error_description);

     if( p_return_code <> 0 ) then
       xdpcore.context( 'XDP_ENGINE' , 'CallFAEvalProc', 'WI', p_wi_instance_id );
     end if;
 end CallFAEvalProc;

Procedure ComputeFAParamValue  (p_raise 		IN VARCHAR2,
				p_mode 			IN VARCHAR2,
				p_fa_instance_id 	IN NUMBER,
				p_procedure_name 	IN VARCHAR2,
				p_order_id 		IN NUMBER,
				p_wi_instance_id 	IN NUMBER,
				p_line_item_id		IN NUMBER,
				p_param_val 		IN VARCHAR2,
				p_param_ref_val 	IN VARCHAR2,
				p_default_value 	IN VARCHAR2,
				p_log_flag 		OUT NOCOPY BOOLEAN,
				p_param_eval_val 	OUT NOCOPY VARCHAR2,
				p_param_eval_ref_val 	OUT NOCOPY VARCHAR2,
				p_return_code 		OUT NOCOPY NUMBER,
				p_error_description 	OUT NOCOPY VARCHAR2)
is


begin

   IF p_mode = 'N' THEN
      p_log_flag := FALSE;

	if p_procedure_name is not null then

		CallFAEvalProc(
			p_procedure_name => ComputeFAParamValue.p_procedure_name,
			p_order_id => ComputeFAParamValue.p_order_id,
			p_line_item_id => ComputeFAParamValue.p_line_item_id,
			p_wi_instance_id => ComputeFAParamValue.p_wi_instance_id,
			p_fa_instance_id => ComputeFAParamValue.p_fa_instance_id,
			p_param_val  => ComputeFAParamValue.p_param_val,
			p_param_ref_val => ComputeFAParamValue.p_param_ref_val,
			p_param_eval_val => ComputeFAParamValue.p_param_eval_val,
			p_param_eval_ref_val => ComputeFAParamValue.p_param_eval_ref_val,
			p_return_code => ComputeFAParamValue.p_return_code,
			p_error_description => ComputeFAParamValue.p_error_description);

		if p_raise = 'Y' then
		   IF p_return_code <> 0 Then
			FND_MESSAGE.SET_NAME('XDP', 'XDP_EXEC_EVAL_PROC_ERROR');
			FND_MESSAGE.SET_TOKEN('ERROR_STRING1', p_procedure_name);
			FND_MESSAGE.SET_TOKEN('ERROR_STRING2', p_error_description);
			APP_EXCEPTION.RAISE_EXCEPTION;
		   End IF;
		end if;
	else
		p_param_eval_val := NVL(p_param_val,p_default_value);
		p_param_eval_ref_val := p_param_ref_val;
	end if;

   ELSIF p_param_val IS NOT NULL Then
      p_log_flag := TRUE;
      p_param_eval_val := p_param_val;
      p_param_eval_ref_val := p_param_ref_val;
   ELSE
      p_log_flag := TRUE;
      p_param_eval_val := p_default_value;
      p_param_eval_ref_val := p_param_ref_val;
   END IF;

end ComputeFAParamValue;


Procedure SetFAParamValue (	p_fa_instance_id	IN NUMBER,
				p_wi_instance_id 	IN NUMBER,
	 			p_fa_id 		IN NUMBER,
	 			p_parameter_name	IN VARCHAR2,
	 			p_default_value 	IN VARCHAR2,
	 			p_parameter_value 	IN VARCHAR2,
	 			p_parameter_ref_value 	IN VARCHAR2,
	 			p_eval_flag 		IN BOOLEAN,
	 			p_eval_mode 		IN VARCHAR2,
	 			p_procedure_name 	IN VARCHAR2,
	 			p_order_id 		IN NUMBER,
	 			p_line_item_id		IN NUMBER,
	 			p_return_code 		OUT NOCOPY NUMBER,
	 			p_error_description 	OUT NOCOPY VARCHAR2)
is
 lv_exists varchar2(1) := 'N';
 lv_eval_val varchar2(4000);
 lv_eval_ref_val varchar2(4000);
 lv_eval_flag varchar2(1) := 'N';
 l_message_params varchar2(2000);
 l_fa_disp_name varchar2(100);
begin
    lv_exists := DoesFAParamExist  --  Needs to be changed by Maya
		(p_fa_instance_id => SetFAParamValue.p_fa_instance_id,
		 p_parameter_name => SetFAParamValue.p_parameter_name);

   if p_eval_flag = TRUE and
	  p_eval_mode = 'Y' and
	  p_procedure_name IS NOT NULL THEN

 	lv_eval_flag := 'Y';

		CallFAEvalProc(
			p_procedure_name => SetFAParamValue.p_procedure_name,
			p_order_id => SetFAParamValue.p_order_id,
			p_line_item_id => SetFAParamValue.p_line_item_id,
			p_wi_instance_id => SetFAParamValue.p_wi_instance_id,
			p_fa_instance_id => SetFAParamValue.p_fa_instance_id,
			p_param_val  => SetFAParamValue.p_parameter_value,
			p_param_ref_val => SetFAParamValue.p_parameter_ref_value,
			p_param_eval_val => lv_eval_val,
			p_param_eval_ref_val => lv_eval_ref_val,
			p_return_code => SetFAParamValue.p_return_code,
			p_error_description => SetFAParamValue.p_error_description);

		if p_return_code <> 0 then

                  xdpcore.context( 'XDP_ENGINE', 'SetFAParamValue', 'FA', p_fa_instance_id, p_error_description );
                  -- get FA display name..
                  l_fa_disp_name := XDPCORE_FA.get_display_name( p_fa_instance_id );

                  -- build the token string for xdp_errors_log..
                 l_message_params := 'FA='||l_fa_disp_name||'#XDP#PARAM='||p_parameter_name ||'#XDP#';

                  -- set the business error...
                  XDPCORE.error_context( 'FA', p_fa_instance_id, 'XDP_FA_PARAM_EVAL_FAILED', l_message_params );

                   /*
		   FND_MESSAGE.SET_NAME('XDP', 'XDP_EXEC_EVAL_PROC_ERROR');
		   FND_MESSAGE.SET_TOKEN('ERROR_STRING1', p_procedure_name);
		   FND_MESSAGE.SET_TOKEN('ERROR_STRING2', p_error_description);
		   APP_EXCEPTION.RAISE_EXCEPTION;
                   */
		end if;
	lv_eval_flag := 'Y';
   else
	lv_eval_flag := 'N';
	if p_eval_mode = 'Y' then
		lv_eval_val := NVL(p_parameter_value,p_default_value) ;
	else
		lv_eval_val := p_parameter_value ;
	end if;

	lv_eval_ref_val := p_parameter_ref_value;
   end if;

   IF lv_exists = 'Y' then
	UpdateFaDetails
	 (p_fa_instance_id => SetFAParamValue.p_fa_instance_id,
	  p_parameter_name => SetFAParamValue.p_parameter_name,
	  p_evaluated_flag => lv_eval_flag,
	  p_parameter_value => lv_eval_val,
	  p_parameter_ref_value	=> lv_eval_ref_val);
   ELSE
	 LoadFADetails( p_fa_instance_id => SetFAParamValue.p_fa_instance_id,
			p_parameter_name => SetFAParamValue.p_parameter_name, -- needs to be changed
			p_fa_id => SetFAParamValue.p_fa_id,
			p_is_value_evaluated => lv_eval_flag,
			p_parameter_value => lv_eval_val,
			p_parameter_ref_value => lv_eval_ref_val);
   END IF;

EXCEPTION
  when others then
   xdpcore.context( 'XDP_ENGINE', 'SetFAParamValue', 'FA', p_fa_instance_id );
   raise;
end SetFAParamValue;


Procedure GetFeConfigInfoText (	p_fe 		IN  VARCHAR2,
				p_fe_id   	OUT NOCOPY NUMBER,
				p_fetype_id 	OUT NOCOPY NUMBER,
				p_fetype    	OUT NOCOPY VARCHAR2,
				p_fe_sw_generic OUT NOCOPY VARCHAR2,
				p_adapter_type 	OUT NOCOPY VARCHAR2,
				p_gen_lookup_id OUT NOCOPY NUMBER,
				p_connect_proc  OUT NOCOPY VARCHAR2,
				p_disconnect_proc OUT NOCOPY VARCHAR2)
is

   lv_date DATE := sysdate;

  CURSOR c_GetFeConfig is
   select
     fet.fE_ID,
     fet.fetype_id,
     fee.fulfillment_element_type,
     fsp.sw_generic,
     fsp.adapter_type,
     fsp.fe_sw_gen_lookup_id,
     decode(fge.sw_start_proc,NULL,fsp.sw_start_proc,fge.sw_start_proc) connect_proc,
     decode(fge.sw_exit_proc,NULL,fsp.sw_exit_proc,fge.sw_exit_proc) disconnect_proc
   from
     XDP_FES fet,
     XDP_FE_GENERIC_CONFIG fge,
     XDP_FE_TYPES fee,
     XDP_FE_SW_GEN_LOOKUP fsp
   where
        fet.fulfillment_element_name = p_fe  and
        fet.FE_ID  = fge.FE_ID and
        fet.fetype_id = fee.fetype_id and
        fge.FE_SW_GEN_LOOKUP_ID = fsp.FE_SW_GEN_LOOKUP_ID and
        fge.START_DATE =  (
                      select MAX( FGE2.START_DATE )
                      from XDP_FE_GENERIC_CONFIG fge2
                      where fge2.FE_ID= fet.FE_ID and
                            lv_date >= fge2.START_DATE and
				    lv_date <= NVL(fge2.END_DATE,lv_date));


 lv_exists varchar2(1) := 'N';
begin

   for v_GetFeConfig in c_GetFeConfig loop
	p_fe_id := v_GetFeConfig.fe_id;
	p_fetype_id := v_GetFeConfig.fetype_id;
	p_fetype := v_GetFeConfig.fulfillment_element_type;
	p_fe_sw_generic := v_GetFeConfig.sw_generic;
	p_adapter_type := v_GetFeConfig.adapter_type;
	p_gen_lookup_id := v_GetFeConfig.fe_sw_gen_lookup_id;
	p_connect_proc := v_GetFeConfig.connect_proc;
	p_disconnect_proc := v_GetFeConfig.disconnect_proc;

	lv_exists := 'Y';
	exit;
   end loop;


   if lv_exists = 'N' then
	raise no_data_found;
   end if;

end GetFeConfigInfoText;

Procedure GetFeConfigInfoNum (	p_fe_id   	IN  NUMBER,
				p_fe 		OUT NOCOPY VARCHAR2,
				p_fetype_id 	OUT NOCOPY NUMBER,
				p_fetype    	OUT NOCOPY VARCHAR2,
				p_fe_sw_generic OUT NOCOPY VARCHAR2,
				p_adapter_type 	OUT NOCOPY VARCHAR2,
				p_gen_lookup_id OUT NOCOPY NUMBER,
				p_connect_proc  OUT NOCOPY VARCHAR2,
				p_disconnect_proc OUT NOCOPY VARCHAR2)
is

   lv_date DATE := sysdate;

  CURSOR c_GetFeConfig is
   select
     fet.fulfillment_element_name,
     fet.fetype_id,
     fee.fulfillment_element_type,
     fsp.sw_generic,
     fsp.adapter_type,
     fsp.fe_sw_gen_lookup_id,
     decode(fge.sw_start_proc,NULL,fsp.sw_start_proc,fge.sw_start_proc) connect_proc,
     decode(fge.sw_exit_proc,NULL,fsp.sw_exit_proc,fge.sw_exit_proc) disconnect_proc
   from
     XDP_FES fet,
     XDP_FE_GENERIC_CONFIG fge,
     XDP_FE_TYPES fee,
     XDP_FE_SW_GEN_LOOKUP fsp
   where
        fet.fe_id = p_fe_id  and
        fet.FE_ID  = fge.FE_ID and
        fet.fetype_id = fee.fetype_id and
        fge.FE_SW_GEN_LOOKUP_ID = fsp.FE_SW_GEN_LOOKUP_ID and
        fge.START_DATE =  (
                      select MAX( FGE2.START_DATE )
                      from XDP_FE_GENERIC_CONFIG fge2
                      where fge2.FE_ID= fet.FE_ID and
                            lv_date >= fge2.START_DATE and
				    lv_date <= NVL(fge2.END_DATE,lv_date));

 lv_exists varchar2(1) := 'N';
begin

   for v_GetFeConfig in c_GetFeConfig loop
	p_fe := v_GetFeConfig.fulfillment_element_name;
	p_fetype_id := v_GetFeConfig.fetype_id;
	p_fetype := v_GetFeConfig.fulfillment_element_type;
	p_fe_sw_generic := v_GetFeConfig.sw_generic;
	p_adapter_type := v_GetFeConfig.adapter_type;
	p_gen_lookup_id := v_GetFeConfig.fe_sw_gen_lookup_id;
	p_connect_proc := v_GetFeConfig.connect_proc;
	p_disconnect_proc := v_GetFeConfig.disconnect_proc;

	lv_exists := 'Y';
	exit;
   end loop;


   if lv_exists = 'N' then
	raise no_data_found;
   end if;

end GetFeConfigInfoNum;


Function GetAttrVal(p_attribute_name 	IN VARCHAR2,
		    p_fe_id 		IN NUMBER,
		    p_fe_sw_gen_lookup  IN NUMBER) return varchar2
is

 lv_attrVal varchar2(4000);
 lv_conceal_data varchar2(10);
 lv_publicKey varchar2(80) := 'MGDGDDNDFGDIUHJKDFIUHTER';
 lv_privateKey VARCHAR2(80);

 lv_exists varchar2(1) := 'N';

 CURSOR c_GetAttrValue is
  select
	decode(fe_attribute_value,NULL,default_value,fe_attribute_value) attr_val,
	fan.conceal_data
  from
	xdp_fe_attribute_def fan,
	(select fe_attribute_id, fe_attribute_value
	 from
	   XDP_FE_ATTRIBUTE_VAL fae,
	   XDP_FE_GENERIC_CONFIG fge
	 where
	 fae.fe_generic_config_id = fge.fe_generic_config_id and
	 fge.fe_id = GetAttrVal.p_fe_id and
	 fge.fe_sw_gen_lookup_id = GetAttrVal.p_fe_sw_gen_lookup ) fae2
  where
	fan.fe_attribute_name = GetAttrVal.p_attribute_name and
	fan.fe_sw_gen_lookup_id = GetAttrVal.p_fe_sw_gen_lookup and
	fan.fe_attribute_id = fae2.fe_attribute_id(+);

begin

   for v_GetAttrValue in c_GetAttrValue loop
	lv_attrVal := v_GetAttrValue.attr_val;
	lv_conceal_data := v_GetAttrValue.conceal_data;

	lv_exists := 'Y';
  end loop;

  if lv_exists = 'N' then
	raise no_data_found;
  end if;

  IF lv_conceal_data = 'Y' THEN
     lv_attrVal := DecodeAttrValue(p_attribute_value => lv_attrVal);
  END IF;

	return (lv_attrVal);

end  GetAttrVal;


Function DecodeAttrValue ( p_attribute_value in varchar2) return varchar2

is

 lv_attrVal varchar2(4000);
 lv_conceal_data varchar2(10);
 lv_publicKey varchar2(80) := 'MGDGDDNDFGDIUHJKDFIUHTER';
 lv_privateKey VARCHAR2(80);

begin

     lv_privateKey := xdp_crypt_tools.GetKey(lv_publicKey);
     IF lv_privateKey IS NULL THEN
        FND_MESSAGE.SET_NAME('XDP', 'XDP_DECRYPT_CONCEAL_DATA');
        APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
     lv_attrVal := xdp_crypt_tools.Encrypt(p_attribute_value, lv_privateKey);

     return (lv_attrVal);

end DecodeAttrValue;


Procedure PreFetch_FeAttrList(  p_fe_name in varchar2,
				p_attr_count OUT NOCOPY number)
is

begin
 pv_FeAttributeList.delete;
 pv_FeAttributeList := Get_FE_AttributeVal_List(p_fe_name => PreFetch_FeAttrList.p_fe_name);
 p_attr_count := pv_FeAttributeList.count;

end PreFetch_FeAttrList;


Procedure Fetch_FeAttrFromList( p_index in number,
				p_attr_name OUT NOCOPY varchar2,
				p_attr_value OUT NOCOPY varchar2)
is

begin
 p_attr_name := pv_FeAttributeList(p_index).parameter_name;
 p_attr_value := pv_FeAttributeList(p_index).parameter_value;

end Fetch_FeAttrFromList;


PROCEDURE EvaluateWIParamsOnStart(p_wi_instance_id in number)
IS
    CURSOR c_GetAllWIParams IS
        SELECT
            wpr.parameter_name,
            xfw.order_id,
            xfw.line_item_id,
            xfw.workitem_id,
            wpr.evaluation_procedure,
            wpr.evaluation_mode
        FROM
            xdp_fulfill_worklist xfw,
	        xdp_wi_parameters wpr
        WHERE
            xfw.workitem_instance_id = p_wi_instance_id
        AND xfw.workitem_id = wpr.workitem_id
        AND wpr.evaluation_procedure is not null
        AND wpr.evaluation_mode = pv_evalModeWIStart
        ORDER BY wpr.evaluation_seq;
    l_param_val 	      VARCHAR2(4000);
    l_param_ref_val       VARCHAR2(4000);
    l_param_eval_val 	  VARCHAR2(4000);
    l_is_value_evaluated  VARCHAR2(1);
    l_param_eval_ref_val  VARCHAR2(4000);
    l_return_code 		  NUMBER;
    l_error_description   VARCHAR2(2000);
    e_parameter_eval_failed EXCEPTION;
BEGIN
	FOR v_GetAllWIParams in c_GetAllWIParams LOOP
        BEGIN
            SELECT parameter_value, parameter_ref_value, is_value_evaluated
              INTO l_param_val,l_param_ref_val, l_is_value_evaluated
              FROM xdp_worklist_details
             WHERE workitem_instance_id = p_wi_instance_id
               AND parameter_name = v_GetAllWIParams.parameter_name;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_param_val := NULL;
                l_param_ref_val := NULL;
        END;

        IF ( l_is_value_evaluated = 'N' ) THEN
          BEGIN
            EvaluateWIParamValue(
			p_order_id    	      => v_GetAllWIParams.order_id,
			p_line_item_id        => v_GetAllWIParams.line_item_id,
			p_workitem_id         => v_GetAllWIParams.workitem_id,
			p_wi_instance_id      => p_wi_instance_id,
 			p_parameter_name 	  => v_GetAllWIParams.parameter_name,
			p_procedure_name      => v_GetAllWIParams.evaluation_procedure,
			p_mode 			      => v_GetAllWIParams.evaluation_mode,
			p_param_val 	      => l_param_val,
			p_param_ref_val       => l_param_ref_val,
			p_param_eval_val 	  => l_param_eval_val,
			p_param_eval_ref_val  => l_param_eval_ref_val,
			p_return_code 		  => l_return_code,
			p_error_description   => l_error_description);
               IF l_return_code <> 0 THEN
                 RAISE e_parameter_eval_failed;
               END IF;
             EXCEPTION
             --skilaru 01/16/02
             --This should be handled by changing the signature and returning the
             --errcode. If we change this signature then we need to touch all
             --the packages its been refered from.. by not doing that we only
             --cant differetiate a system exception from a business exception.
               WHEN others THEN
                 RAISE;
            END;
          END IF;
          -- skilaru 06/04/2002
          -- Reset the flag so that when we get NO_DATA_FOUND in the upper block
          -- we wont evaluate that if earlier iteration has initialized thie
          -- value to 'N' ...
          l_is_value_evaluated := NULL;
	END LOOP;
EXCEPTION
  WHEN others THEN
  xdpcore.context( 'XDP_ENGINE', 'EvaluateWIParamsOnStart', 'WI', p_wi_instance_id );
  raise;
END EvaluateWIParamsOnStart;

-- Package initialization
begin
    pv_FeAttributeList.delete;

END XDP_ENGINE;

/
