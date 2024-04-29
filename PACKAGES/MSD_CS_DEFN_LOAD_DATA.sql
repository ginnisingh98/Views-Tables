--------------------------------------------------------
--  DDL for Package MSD_CS_DEFN_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CS_DEFN_LOAD_DATA" AUTHID CURRENT_USER as
/* $Header: msdcsdfs.pls 120.0 2005/05/25 20:23:00 appldev noship $ */
    Procedure load_row (
        p_name                    in  varchar2,
        p_description             in  varchar2,
        p_plan_type        in varchar2 ,
        p_liability_user_flag   in varchar2,
        p_cs_classification       in  varchar2,
        p_cs_type                 in  varchar2,
        p_strict_flag             in  varchar2,
        p_system_flag             in  varchar2,
        p_multiple_stream_flag    in  varchar2,
        p_planning_server_view_name   in  varchar2,
        p_planning_server_view_name_ds   in  varchar2,
        p_stripe_flag                 in varchar2,
        p_source_view_name            in  varchar2,
        p_collection_program_name     in  varchar2,
        p_collect_addtl_where_clause  in  varchar2,
        p_pull_addtl_where_clause     in  varchar2,
        p_valid_flag                  in  varchar2,
        p_stream_editable_flag        in  varchar2,
        p_aggregation_allowed_flag    in  varchar2,
        p_allocation_allowed_flag     in  varchar2,
        p_dependent_data_flag         in  varchar2,
        p_dependent_demand_code       in  varchar2,
        p_measurement_type            in  varchar2,
        p_enable_flag                 in  varchar2,
        p_cs_lov_view_name	      in  varchar2,
        p_lowest_level_flag	      in  varchar2,
        p_owner                       in  varchar2,
        p_last_update_date            in varchar2,
        p_custom_mode                 in varchar2
    );

    Procedure DEFN_Insert_row (
        p_name                    in  varchar2,
        p_description             in  varchar2,
        p_plan_type        in varchar2 ,
        p_liability_user_flag   in varchar2,
        p_cs_classification       in  varchar2,
        p_cs_type                 in  varchar2,
        p_strict_flag             in  varchar2,
        p_system_flag             in  varchar2,
        p_multiple_stream_flag    in  varchar2,
        p_planning_server_view_name   in  varchar2,
        p_planning_server_view_name_ds   in  varchar2,
        p_stripe_flag                 in varchar2,
        p_source_view_name            in  varchar2,
        p_collection_program_name     in  varchar2,
        p_collect_addtl_where_clause  in  varchar2,
        p_pull_addtl_where_clause     in  varchar2,
        p_valid_flag                  in  varchar2,
        p_stream_editable_flag        in  varchar2,
        p_aggregation_allowed_flag    in  varchar2,
        p_allocation_allowed_flag     in  varchar2,
        p_dependent_data_flag         in  varchar2,
        p_dependent_demand_code       in  varchar2,
        p_enable_flag                 in  varchar2,
        p_cs_lov_view_name	      in  varchar2,
        p_lowest_level_flag	      in  varchar2,
        p_measurement_type            in  varchar2,
        p_owner                       in  varchar2,
        p_last_update_date            in  varchar2
    );
    --
    Procedure DEFN_UPDATE_row (
        p_cs_definition_id        in  number,
        p_name                    in  varchar2,
        p_plan_type        in varchar2 ,
        p_liability_user_flag   in varchar2,
        p_description             in  varchar2,
        p_cs_classification       in  varchar2,
        p_cs_type                 in  varchar2,
        p_strict_flag             in  varchar2,
        p_system_flag             in  varchar2,
        p_multiple_stream_flag    in  varchar2,
        p_planning_server_view_name   in  varchar2,
        p_planning_server_view_name_ds   in  varchar2,
        p_stripe_flag                 in varchar2,
        p_source_view_name            in  varchar2,
        p_collection_program_name     in  varchar2,
        p_collect_addtl_where_clause  in  varchar2,
        p_pull_addtl_where_clause     in  varchar2,
        p_valid_flag                  in  varchar2,
        p_stream_editable_flag        in  varchar2,
        p_aggregation_allowed_flag    in  varchar2,
        p_allocation_allowed_flag     in  varchar2,
        p_dependent_data_flag         in  varchar2,
        p_dependent_demand_code       in  varchar2,
        p_enable_flag                 in  varchar2,
        p_cs_lov_view_name	      in  varchar2,
        p_lowest_level_flag	      in  varchar2,
        p_measurement_type            in  varchar2,
        p_owner                       in  varchar2,
        p_last_update_date            in  varchar2,
        p_custom_mode                 in  varchar2

    );
    --
    Procedure translate_row (
        p_name                    in  varchar2,
        p_description             in  varchar2,
        p_owner                   in  varchar2);

    Procedure add_language;
End;

 

/
