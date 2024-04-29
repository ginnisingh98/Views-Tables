--------------------------------------------------------
--  DDL for Package PA_FP_WP_GEN_AMT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_WP_GEN_AMT_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAFPWPUS.pls 120.0 2005/05/30 05:09:30 appldev noship $ */
    function get_wp_ptype_id(p_project_id in number)
    return number;

    function get_wp_version_id(p_project_id in number,
                               p_plan_type_id in number,
                               p_proj_str_ver_id in number)
    return number;

    FUNCTION get_wp_track_cost_amt_flag (p_project_id IN NUMBER)
    RETURN VARCHAR2;

    FUNCTION get_wp_pt_time_phase_code(p_project_id IN NUMBER)
    RETURN VARCHAR2;

end Pa_Fp_wp_gen_amt_utils;

 

/
