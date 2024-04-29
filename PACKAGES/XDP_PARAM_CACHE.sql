--------------------------------------------------------
--  DDL for Package XDP_PARAM_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PARAM_CACHE" AUTHID CURRENT_USER AS
/* $Header: XDPPACHS.pls 120.1 2005/06/16 02:15:53 appldev  $ */

	g_FAParam varchar2(10) := 'FA';
	g_WIParam varchar2(10) := 'WI';

	pv_workitem_instance_id number := null;
	pv_workitem_id number := null;

	pv_fa_instance_id number := null;
	pv_fa_id number := null;

TYPE XDP_PARAM IS RECORD
  (
        parameter_name VARCHAR2(40),
        parameter_value VARCHAR2(4000),
        parameter_ref_value VARCHAR2(4000) DEFAULT NULL,
	log_flag varchar2(1),
	evaluation_mode varchar2(80),
	evaluation_proc varchar2(80),
	default_value varchar2(4000)
  );

TYPE XDP_PARAM_LIST IS TABLE OF XDP_PARAM
	INDEX BY BINARY_INTEGER;

cursor c_GetWiParams is
      SELECT
	parameter_name,
	log_in_audit_trail_flag,
        validation_procedure,
	evaluation_mode,
	evaluation_procedure,
	default_value
    FROM
        xdp_wi_parameters
    WHERE
       workitem_id = pv_workitem_id;

cursor c_GetWiParamConfig (p_param_name varchar2) is
      SELECT
	log_in_audit_trail_flag,
        validation_procedure,
	evaluation_mode,
	evaluation_procedure,
	default_value
    FROM
        xdp_wi_parameters
    WHERE
       workitem_id = pv_workitem_id AND
       parameter_name = p_param_name;

cursor c_GetWiConfig (p_wi_instance_id number) is
      SELECT
        wim.wi_type_code,
        wim.fa_exec_map_proc,
        wim.workitem_name,
        wim.workitem_id,
        wim.user_wf_item_type,
        wim.user_wf_item_key_prefix,
        wim.user_wf_process_name,
        wim.wf_exec_proc
    FROM
        xdp_workitems wim,
        xdp_fulfill_worklist fwt
    WHERE
       wim.workitem_id = fwt.workitem_id AND
       fwt.workitem_instance_id = p_wi_instance_id;

	pv_workitem_name varchar2(80) := null;
	pv_workitem_type varchar2(80) := null;

	pv_wi_eval_proc_name varchar2(80) := null;

	pv_wi_item_type varchar2(8) := null;
	pv_wi_process_name varchar2(80) := null;
	pv_wi_key_prefix varchar2(80) := null;

	pv_wi_param_list XDP_PARAM_LIST;

	pv_fa_name varchar2(80) := null;
	pv_fe_routing_proc varchar2(80) := null;

	pv_fa_param_list XDP_PARAM_LIST;

cursor c_GetFaConfig (p_fa_instance_id number) is
      SELECT
	xfa.fulfillment_action_id,
	xfa.fulfillment_action,
	xfa.fe_routing_proc
    FROM
        xdp_fulfill_actions xfa,
        xdp_fa_runtime_list frl
    WHERE
       xfa.fulfillment_action_id = frl.fulfillment_action_id AND
       frl.fa_instance_id = p_fa_instance_id;

cursor c_GetFAParams is
      SELECT
	parameter_name,
	log_in_audit_trail_flag,
	evaluation_procedure,
	default_value
    FROM
        xdp_fa_parameters
    WHERE
       fulfillment_action_id = pv_fa_id;

cursor c_GetFAParamConfig (p_param_name varchar2) is
      SELECT
	log_in_audit_trail_flag,
	evaluation_procedure,
	default_value
    FROM
        xdp_fa_parameters
    WHERE
       fulfillment_action_id = pv_fa_id AND
       parameter_name = p_param_name;


-- Public Routines

 Procedure clear_cache;
 Procedure init_cache(p_wi_instance_id number,
		      p_load_param_config in boolean default TRUE);

 Procedure init_cache(p_wi_instance_id number,
		      p_wi_param_list in varchar2,
		      p_load_param_config in boolean default TRUE);

 Procedure init_cache(p_wi_instance_id number,
		      p_fa_instance_id number,
		      p_load_param_config in boolean default TRUE);

 Procedure Add_wi_param_to_cache(
			p_param_name in varchar2,
			p_param_value in varchar2,
			p_param_ref_value in varchar2 default null,
			p_log_flag in varchar2 default null,
			p_evaluation_mode in varchar2 default null,
			p_evaluation_proc in varchar2 default null,
			p_default_value in varchar2 default null,
			p_update_db in varchar2 default 'Y');

 Procedure Get_WI_param_from_cache(p_param_name in varchar2,
			  p_exists_in_cache OUT NOCOPY varchar2,
			  p_param_value OUT NOCOPY varchar2,
			  p_param_ref_value OUT NOCOPY varchar2,
			  p_log_flag OUT NOCOPY varchar2,
			  p_evaluation_mode OUT NOCOPY varchar2,
			  p_evaluation_proc OUT NOCOPY varchar2,
			  p_default_value OUT NOCOPY varchar2);

 Procedure Get_FA_param_from_cache(p_param_name in varchar2,
			  p_exists_in_cache OUT NOCOPY varchar2,
			  p_param_value OUT NOCOPY varchar2,
			  p_log_flag OUT NOCOPY varchar2,
			  p_evaluation_proc OUT NOCOPY varchar2,
			  p_default_value OUT NOCOPY varchar2);

 Procedure remove_from_cache(p_param_type in varchar2,
			     p_param_name in varchar2);

end XDP_PARAM_CACHE;

 

/
