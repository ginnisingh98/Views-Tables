--------------------------------------------------------
--  DDL for Package CSR_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSR_RULES_PVT" AUTHID CURRENT_USER AS
  /* $Header: CSRVRULS.pls 120.0.12010000.10 2009/04/27 11:01:17 venjayar noship $ */

  /**
   * Creates a Rule in the system after validating the eligibility levels
   * provided for the rule.
   * <br>
   * Following Validations are done
   * 1. Atleast one Eligibility Level is provided
   * 2. Rule Document cannot be Empty
   * 3. No Presence of a Duplicate Rule
   *
   * <br>
   * Note that Base Rule ID population is mandatory for certain rules and the
   * API ensures that the proper hierarchy is established.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commit at the end of the API Call
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_rule_name               Name of the Rule to be created
   * @param  p_description             Description of the Rule to be created (Optional)
   * @param  p_base_rule_id            ID of the Base Rule (Optional)
   * @param  p_appl_id                 ID of the Application for Eligibility (Optional)
   * @param  p_resp_id                 ID of the Responsibility for Eligibility (Optional)
   * @param  p_user_id                 ID of the User for Eligibility (Optional)
   * @param  p_terr_id                 ID of the Territory for Eligibility (Optional)
   * @param  p_resource_type           Type of the Resource for Eligibility (Optional)
   * @param  p_resource_id             ID of the Resource for Eligibility (Optional)
   * @param  p_enabled_flag            Rule is Enabled or not (Optional)
   * @param  p_rule_doc                XML Document containing the Rule Spec (Optional)
   * @param  p_window_names            Contains the name of the Windows defined in the rule (Optional)
   * @param  p_window_descriptions     Contains the descriptions of the Windows defined in the rule (Optional)
   * @param  x_rule_id                 ID of the Rule Created
   * @param  x_new_rule_doc            Rule Document might be changed by the API. This returns the new Document
   **/
  PROCEDURE create_rule(
      p_api_version              IN            NUMBER
    , p_init_msg_list            IN            VARCHAR2                DEFAULT NULL
    , p_commit                   IN            VARCHAR2                DEFAULT NULL
    , x_return_status           OUT     NOCOPY VARCHAR2
    , x_msg_data                OUT     NOCOPY VARCHAR2
    , x_msg_count               OUT     NOCOPY NUMBER
    , p_rule_name                IN            VARCHAR2
    , p_description              IN            VARCHAR2                DEFAULT NULL
    , p_base_rule_id             IN            NUMBER                  DEFAULT NULL
    , p_appl_id                  IN            NUMBER                  DEFAULT NULL
    , p_resp_id                  IN            NUMBER                  DEFAULT NULL
    , p_user_id                  IN            NUMBER                  DEFAULT NULL
    , p_terr_id                  IN            NUMBER                  DEFAULT NULL
    , p_resource_type            IN            VARCHAR2                DEFAULT NULL
    , p_resource_id              IN            NUMBER                  DEFAULT NULL
    , p_enabled_flag             IN            VARCHAR2                DEFAULT NULL
    , p_rule_doc                 IN            XMLTYPE
    , p_window_names             IN            jtf_varchar2_table_300  DEFAULT NULL
    , p_window_descriptions      IN            jtf_varchar2_table_1500 DEFAULT NULL
    , x_rule_id                 OUT     NOCOPY NUMBER
    , x_new_rule_doc            OUT     NOCOPY CLOB
    );

  /**
   * Updates the given rule with the given new peramter values. Note that the
   * optional parameters take the value NULL and not FND_API.G_MISS and NULL
   * retains the old value and FND_API.G_MISS clears the old value.
   *
   * <br>
   * Following Validations are done
   * 1. Atleast one Eligibility Level is provided unless it is a site level rule
   *    being updated.
   * 2. Rule Document cannot be Empty
   * 3. No Presence of a Duplicate Rule
   *
   * <br>
   * Note that Base Rule ID population is mandatory for certain rules and the
   * API ensures that the proper hierarchy is established. Also the updated
   * parameter values are propagated automatically to the child rules.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commit at the end of the API Call
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_rule_id                 ID of the Rule to be updated
   * @param  p_object_version_number   Version of the Object being updated
   * @param  p_rule_name               Name of the Rule to be updated
   * @param  p_description             Description of the Rule to be updated (Optional)
   * @param  p_base_rule_id            ID of the Base Rule (Optional)
   * @param  p_appl_id                 ID of the Application for Eligibility (Optional)
   * @param  p_resp_id                 ID of the Responsibility for Eligibility (Optional)
   * @param  p_user_id                 ID of the User for Eligibility (Optional)
   * @param  p_terr_id                 ID of the Territory for Eligibility (Optional)
   * @param  p_resource_type           Type of the Resource for Eligibility (Optional)
   * @param  p_resource_id             ID of the Resource for Eligibility (Optional)
   * @param  p_enabled_flag            Rule is Enabled or not (Optional)
   * @param  p_rule_doc                XML Document containing the Rule Spec (Optional)
   * @param  p_window_names            Contains the name of the Windows defined in the rule (Optional)
   * @param  p_window_descriptions     Contains the descriptions of the Windows defined in the rule (Optional)
   * @param  p_version_msg             Informative Messages indicating the actual change that has happened
   * @param  x_new_rule_doc            Rule Document might be changed by the API. This returns the new Document
   **/
  PROCEDURE update_rule(
      p_api_version              IN            NUMBER
    , p_init_msg_list            IN            VARCHAR2                DEFAULT NULL
    , p_commit                   IN            VARCHAR2                DEFAULT NULL
    , x_return_status            OUT    NOCOPY VARCHAR2
    , x_msg_data                 OUT    NOCOPY VARCHAR2
    , x_msg_count                OUT    NOCOPY NUMBER
    , p_rule_id                  IN            NUMBER
    , p_object_version_number    IN OUT NOCOPY NUMBER
    , p_rule_name                IN            VARCHAR2                DEFAULT NULL
    , p_description              IN            VARCHAR2                DEFAULT NULL
    , p_base_rule_id             IN            NUMBER                  DEFAULT NULL
    , p_appl_id                  IN            NUMBER                  DEFAULT NULL
    , p_resp_id                  IN            NUMBER                  DEFAULT NULL
    , p_user_id                  IN            NUMBER                  DEFAULT NULL
    , p_terr_id                  IN            NUMBER                  DEFAULT NULL
    , p_resource_type            IN            VARCHAR2                DEFAULT NULL
    , p_resource_id              IN            NUMBER                  DEFAULT NULL
    , p_enabled_flag             IN            VARCHAR2                DEFAULT NULL
    , p_rule_doc                 IN            XMLTYPE                 DEFAULT NULL
    , p_window_names             IN            jtf_varchar2_table_300  DEFAULT NULL
    , p_window_descriptions      IN            jtf_varchar2_table_1500 DEFAULT NULL
    , p_version_msgs             IN            jtf_varchar2_table_4000
    , p_force_propagation        IN            VARCHAR2                DEFAULT NULL
    , x_new_rule_doc             OUT    NOCOPY CLOB
    );

  /**
   * Deletes the given rule and delinks the rules based on the current rule.
   *
   * <br>
   * Note that Base Rule ID is mandatory for certain rules and if the respective
   * Base Rule is deleted then the child rules should also deleted.
   * If Base Rule is not mandatory, the child rules are just delinked.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  p_commit                  Commit at the end of the API Call
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_rule_id                 ID of the Rule to be updated
   **/
  PROCEDURE delete_rule(
      p_api_version              IN            NUMBER
    , p_init_msg_list            IN            VARCHAR2    DEFAULT NULL
    , p_commit                   IN            VARCHAR2    DEFAULT NULL
    , x_return_status           OUT     NOCOPY VARCHAR2
    , x_msg_data                OUT     NOCOPY VARCHAR2
    , x_msg_count               OUT     NOCOPY NUMBER
    , p_rule_id                  IN            NUMBER
    );

  /**
   * Retrieves the value of the given Scheduler Parameter based on the
   * eligibility levels given.
   *
   * @param  p_parameter_name          Name of the Parameter
   * @param  p_appl_id                 ID of the Application for Eligibility (Optional)
   * @param  p_resp_id                 ID of the Responsibility for Eligibility (Optional)
   * @param  p_user_id                 ID of the User for Eligibility (Optional)
   * @param  p_terr_id                 ID of the Territory for Eligibility (Optional)
   * @param  p_resource_type           Type of the Resource for Eligibility (Optional)
   * @param  p_resource_id             ID of the Resource for Eligibility (Optional)
   **/
  FUNCTION get_sch_parameter_value(
      p_parameter_name           IN            VARCHAR2
    , p_appl_id                  IN            NUMBER      DEFAULT NULL
    , p_resp_id                  IN            NUMBER      DEFAULT NULL
    , p_user_id                  IN            NUMBER      DEFAULT NULL
    , p_terr_id                  IN            NUMBER      DEFAULT NULL
    , p_resource_type            IN            VARCHAR2    DEFAULT NULL
    , p_resource_id              IN            NUMBER      DEFAULT NULL
    )
    RETURN VARCHAR2;

  /**
   * Retrieves all the rules valid for specified eligibility. Optionally the caller
   * can specify the list of resources and their associated territory to further
   * return the rules eligibile for those resources in addition to the session
   * criteria.
   *
   * If there is no resource specified, there will be one record in the output
   * variable which inturn will a list of session specific rules.
   *
   * However if Resource(s) is(are) specified as part of the Resource List, then
   * the output variable will contain one record for each of the resource and each
   * record will inturn be a table of rules applicable for the Resource, Territory
   * cum Session combination.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  p_appl_id                 ID of the Application for Eligibility (Optional)
   * @param  p_resp_id                 ID of the Responsibility for Eligibility (Optional)
   * @param  p_user_id                 ID of the User for Eligibility (Optional)
   * @param  p_res_tbl                 List of Resources along with their Territory (Optional)
   * @param  x_res_rules_tbl           Session Specific or Resource Specified Rules
   **/
  PROCEDURE get_scheduler_rules(
      p_api_version          IN            NUMBER
    , p_init_msg_list        IN            VARCHAR2               DEFAULT NULL
    , x_return_status       OUT     NOCOPY VARCHAR2
    , x_msg_data            OUT     NOCOPY VARCHAR2
    , x_msg_count           OUT     NOCOPY NUMBER
    , p_appl_id              IN            NUMBER                 DEFAULT NULL
    , p_resp_id              IN            NUMBER                 DEFAULT NULL
    , p_user_id              IN            NUMBER                 DEFAULT NULL
    , p_res_tbl              IN            csf_resource_tbl       DEFAULT NULL
    , x_res_rules_tbl       OUT     NOCOPY csr_resource_rules_tbl
    );

  /**
   * Processes the given WebADI Action and processes the parameters.
   * In case the action is 'UPDATE', all the passed parameters are updated into
   * the Rule as given by P_RULE_ID. Moreover, only those parameters which
   * are valid for the current Eligibility are updated.
   */
  PROCEDURE process_webadi_action(
      p_action                          IN            VARCHAR2
    , p_rule_id                         IN            NUMBER
    , p_object_version_number           IN            NUMBER
    , p_rule_name                       IN            VARCHAR2    DEFAULT NULL
    , p_description                     IN            VARCHAR2    DEFAULT NULL
    , p_base_rule_id                    IN            NUMBER      DEFAULT NULL
    , p_appl_id                         IN            NUMBER      DEFAULT NULL
    , p_resp_id                         IN            NUMBER      DEFAULT NULL
    , p_user_id                         IN            NUMBER      DEFAULT NULL
    , p_terr_id                         IN            NUMBER      DEFAULT NULL
    , p_resource_type                   IN            VARCHAR2    DEFAULT NULL
    , p_resource_id                     IN            NUMBER      DEFAULT NULL
    , p_enabled_flag                    IN            VARCHAR2    DEFAULT NULL
    , p_sp_plan_scope                   IN            NUMBER      DEFAULT NULL
    , p_sp_max_plan_options             IN            NUMBER      DEFAULT NULL
    , p_sp_max_resources                IN            NUMBER      DEFAULT NULL
    , p_sp_max_calc_time                IN            NUMBER      DEFAULT NULL
    , p_sp_max_overtime                 IN            NUMBER      DEFAULT NULL
    , p_sp_wtp_threshold                IN            NUMBER      DEFAULT NULL
    , p_sp_enforce_plan_window          IN            VARCHAR2    DEFAULT NULL
    , p_sp_consider_standby_shifts      IN            VARCHAR2    DEFAULT NULL
    , p_sp_spares_mandatory             IN            VARCHAR2    DEFAULT NULL
    , p_sp_spares_source                IN            VARCHAR2    DEFAULT NULL
    , p_sp_min_task_length              IN            NUMBER      DEFAULT NULL
    , p_sp_default_shift_duration       IN            NUMBER      DEFAULT NULL
    , p_sp_dist_last_child_effort       IN            VARCHAR2    DEFAULT NULL
    , p_sp_pick_contract_resources      IN            VARCHAR2    DEFAULT NULL
    , p_sp_pick_ib_resources            IN            VARCHAR2    DEFAULT NULL
    , p_sp_pick_territory_resources     IN            VARCHAR2    DEFAULT NULL
    , p_sp_pick_skilled_resources       IN            VARCHAR2    DEFAULT NULL
    , p_sp_auto_sch_default_query       IN            NUMBER      DEFAULT NULL
    , p_sp_auto_reject_sts_id_spares    IN            NUMBER      DEFAULT NULL
    , p_sp_auto_reject_sts_id_others    IN            NUMBER      DEFAULT NULL
    , p_sp_force_optimizer_to_group     IN            VARCHAR2    DEFAULT NULL
    , p_sp_optimizer_success_perc       IN            NUMBER      DEFAULT NULL
    , p_sp_commutes_position            IN            VARCHAR2    DEFAULT NULL
    , p_sp_commute_excluded_time        IN            NUMBER      DEFAULT NULL
    , p_sp_commute_home_empty_trip      IN            VARCHAR2    DEFAULT NULL
    , p_sp_router_mode                  IN            VARCHAR2    DEFAULT NULL
    , p_sp_travel_time_extra            IN            NUMBER      DEFAULT NULL
    , p_sp_default_router_enabled       IN            VARCHAR2    DEFAULT NULL
    , p_sp_default_travel_distance      IN            NUMBER      DEFAULT NULL
    , p_sp_default_travel_duration      IN            NUMBER      DEFAULT NULL
    , p_sp_max_distance_in_group        IN            NUMBER      DEFAULT NULL
    , p_sp_max_dist_to_skip_actual      IN            NUMBER      DEFAULT NULL
    , p_rc_router_calc_type             IN            VARCHAR2    DEFAULT NULL
    , p_rc_consider_toll_roads          IN            VARCHAR2    DEFAULT NULL
    , p_rc_route_func_delay_0           IN            NUMBER      DEFAULT NULL
    , p_rc_route_func_delay_1           IN            NUMBER      DEFAULT NULL
    , p_rc_route_func_delay_2           IN            NUMBER      DEFAULT NULL
    , p_rc_route_func_delay_3           IN            NUMBER      DEFAULT NULL
    , p_rc_route_func_delay_4           IN            NUMBER      DEFAULT NULL
    , p_rc_estimate_first_boundary      IN            NUMBER      DEFAULT NULL
    , p_rc_estimate_second_boundary     IN            NUMBER      DEFAULT NULL
    , p_rc_estimate_first_avg_speed     IN            NUMBER      DEFAULT NULL
    , p_rc_estimate_second_avg_speed    IN            NUMBER      DEFAULT NULL
    , p_rc_estimate_third_avg_speed     IN            NUMBER      DEFAULT NULL
    , p_cp_task_per_day_delayed         IN            NUMBER      DEFAULT NULL
    , p_cp_task_per_min_early           IN            NUMBER      DEFAULT NULL
    , p_cp_task_per_min_late            IN            NUMBER      DEFAULT NULL
    , p_cp_tls_per_day_extra            IN            NUMBER      DEFAULT NULL
    , p_cp_tls_per_child_extra          IN            NUMBER      DEFAULT NULL
    , p_cp_parts_violation              IN            NUMBER      DEFAULT NULL
    , p_cp_res_per_min_overtime         IN            NUMBER      DEFAULT NULL
    , p_cp_res_assigned_not_pref        IN            NUMBER      DEFAULT NULL
    , p_cp_res_skill_level              IN            NUMBER      DEFAULT NULL
    , p_cp_standby_shift_usage          IN            NUMBER      DEFAULT NULL
    , p_cp_travel_per_unit_distance     IN            NUMBER      DEFAULT NULL
    , p_cp_travel_per_unit_duration     IN            NUMBER      DEFAULT NULL
    , p_cp_defer_same_site              IN            NUMBER      DEFAULT NULL
    );

  PROCEDURE add_language;

END csr_rules_pvt;

/
