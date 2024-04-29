--------------------------------------------------------
--  DDL for Package SR_UWQ_INTEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SR_UWQ_INTEG" AUTHID CURRENT_USER AS
/* $Header: cssruwqs.pls 120.0.12010000.2 2010/05/11 10:22:47 vpremach ship $ */

------------------------------------------------------------------------------------
--  Procedure	: SR_UWQ_INTEG
--  Usage	: Used by UWQ to call Service Request Form
--  Description	: This procedure takes the table of objects containing
--				  the meta data as input and gives the following as output:
--				  1. Action Type -  Method to be used to call the SR Form
--								APP_NAVIGATE.EXECUTE
--				  2. Action Name - Name of the function to call the SR form
--				  3. Action Param - Parameters to be passed to the SR form.
--  Parameters	:
--	p_ieu_media_data	IN	SYSTEM.IEU_UWQ_MEDIA_DATA_NST	Required
--   p_action_type		OUT  NUMBER
--   p_action_name		OUT  VARCHAR2
--   p_action_param		OUT  VARCHAR2
--
--  PRAYADUR      04/28/2004    Added Procedure SR_UWQ_NONMEDIA_ACTIONS for Bug 3357706
---------------------------------------------------------------------------------------

procedure sr_uwq_foo_func
 ( p_ieu_media_data in  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
  p_action_type     out NOCOPY number,
  p_action_name     out NOCOPY varchar2,
  p_action_param    out NOCOPY varchar2);

procedure connect_form_to_foo
 ( p_ieu_media_data in IEU_FRM_PVT.t_ieu_media_data,
  p_action_type     out NOCOPY number,
  p_action_name     out NOCOPY varchar2,
  p_action_param    out NOCOPY varchar2);

procedure enumerate_sr_nodes
  (p_resource_id      in number,
   p_language         in varchar2,
   p_source_lang      in varchar2,
   p_sel_enum_id      in number );

procedure refresh_sr_nodes
  (p_resource_id in number,
   p_node_id in number,
   p_count out NOCOPY number);

procedure insert_row(
 p_node_id	     in number default  -1,
 p_node_view         in varchar2,
 p_node_label        in varchar2,
 p_data_source       in varchar2,
 p_media_type_id     in number,
 p_where_clause      in varchar2,
 p_res_cat_enum_flag in varchar2,
 p_node_type         in varchar2,
 p_hide_if_empty     in varchar2,
 p_node_depth        in number,
 p_parent_id         in number,
 p_node_query        in varchar2,
 p_cursor_sql        in varchar2,
 p_cursor_key_col    in varchar2,
 p_enabled_flag      in varchar2,
 p_creation_date     in date,
 p_created_by        in number,
 p_last_update_date  in date,
 p_last_updated_by   in number,
 p_last_update_login in number,
 x_node_id           out NOCOPY number,
 x_return_status     out NOCOPY varchar2);

procedure update_row(
 p_node_id           in number,
 p_object_version_number  in number,
 p_node_view         in varchar2,
 p_node_label        in varchar2,
 p_data_source       in varchar2,
 p_media_type_id     in number,
 p_where_clause      in varchar2,
 p_res_cat_enum_flag in varchar2,
 p_node_type         in varchar2,
 p_hide_if_empty     in varchar2,
 p_node_depth        in number,
 p_parent_id         in number,
 p_node_query        in varchar2,
 p_cursor_sql        in varchar2,
 p_cursor_key_col    in varchar2,
 p_enabled_flag      in varchar2,
 p_creation_date     in date,
 p_created_by        in number,
 p_last_update_date  in date,
 p_last_updated_by   in number,
 p_last_update_login in number,
 x_return_status     out NOCOPY varchar2);

procedure validate_ivr_parameter(
 p_parameter_code    in out NOCOPY varchar2,
 p_parameter_value   in out NOCOPY varchar2,
 p_parameter_mesg    in out NOCOPY varchar2,
 p_param_action_val  in out NOCOPY varchar2,
 x_parameter_id      out NOCOPY number,
 x_parameter_flag    out NOCOPY varchar2,
 x_customer_id       out NOCOPY number,
 x_customer_type     out NOCOPY varchar2,
 x_return_status     out NOCOPY varchar2);

procedure interpret_service_keys(
 v_service_key       in varchar2,
 v_service_key_value in out NOCOPY varchar2,
 p_cust_id           in number,
 p_cust_account_id   in number,
 p_phone_id          in number,
 x_parameter_code    out NOCOPY varchar2,
 x_return_status     out NOCOPY varchar2);


procedure validate_security(
 p_ivr_data_key     in varchar2,
 p_ivr_data_value   in varchar2,
 p_table_of_agents  in out NOCOPY system.CCT_AGENT_RESP_APP_ID_NST,
 x_return_status    out NOCOPY varchar2);

procedure start_media_item( p_resp_appl_id in number,
                            p_resp_id      in number,
                            p_user_id      in number,
                            p_login_id     in number,
                            x_return_status out nocopy  varchar2,
                            x_msg_count     out nocopy  number,
                            x_msg_data      out nocopy  varchar2,
                            x_media_id      out nocopy  number,
			    p_outbound_dnis in varchar2 DEFAULT NULL, -- Added by vpremach for Bug 9499153
	  		    p_outbound_ani in varchar2 DEFAULT NULL -- Added by vpremach for Bug 9499153
			       );

PROCEDURE SR_UWQ_NONMEDIA_ACTIONS(
p_ieu_action_data     IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
x_action_type         OUT NOCOPY NUMBER,
x_action_name         OUT NOCOPY varchar2,
x_action_param        OUT NOCOPY varchar2,
x_msg_name            OUT NOCOPY varchar2,
x_msg_param           OUT NOCOPY varchar2,
x_dialog_style        OUT NOCOPY number,
x_msg_appl_short_name OUT NOCOPY varchar2) ;


procedure create_service_request(
    p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2,
    p_commit                 IN    VARCHAR2,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER,
    p_resp_id                IN    NUMBER,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER,
    p_org_id                 IN    NUMBER,
    p_request_id             IN    NUMBER,
    p_request_number         IN    VARCHAR2,
    sr_type                  IN    VARCHAR2,
    summary                  IN    VARCHAR2,
    severity_id              IN    VARCHAR2,
    urgency_id               IN    VARCHAR2,
    customer_id              IN    VARCHAR2,
    customer_type            IN    VARCHAR2,
    account_id               IN    VARCHAR2,
    note_type                IN    VARCHAR2,
    note                     IN    VARCHAR2,
    -- contact_id               IN    VARCHAR2,
    -- contact_point_id         IN    VARCHAR2,
    -- primary_flag             IN    VARCHAR2,
    -- contact_point_type       IN    VARCHAR2,
    -- contact_type             IN    VARCHAR2,
    p_auto_assign            IN    VARCHAR2,
    p_auto_generate_tasks    IN    VARCHAR2,
    x_service_request_number         OUT   NOCOPY NUMBER,
    p_default_contract_sla_ind       IN    VARCHAR2,
    p_default_coverage_template_id   IN    NUMBER);


PROCEDURE Build_Solution_Text_Query(
    p_raw_text in varchar2,
    p_solution_type_id_tbl in varchar2,
    p_search_option in number,
    x_solution_text out NOCOPY varchar2);


FUNCTION Get_KM_Params_Str(
    solution_num in varchar2)
  return varchar2;


end sr_uwq_integ;

/
