--------------------------------------------------------
--  DDL for Package PAY_RUN_RESULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_RESULT_PKG" AUTHID CURRENT_USER as
/* $Header: pycorrrp.pkh 120.1.12010000.1 2008/07/27 22:23:29 appldev ship $ */
--
function get_result_value(p_run_result_id      in number,
                          p_input_value_id     in number,
                          p_iv_name            in varchar2,
                          p_jurisdiction_code  in varchar2,
                          p_business_group_id  in number
                         ) return varchar2;
procedure create_run_result(p_element_entry_id  in            number,
                            p_session_date      in            date,
                            p_business_group_id in            number,
                            p_jc_name           in            varchar2,
                            p_rr_sparse         in            boolean,
                            p_rr_sparse_jc      in            boolean,
                            p_asg_action_id     in            number default null,
                            p_run_result_id        out nocopy number
                           );
procedure create_indirect_rr(p_element_type_id  in            number,
                             p_run_result_id    in            number,
                            p_session_date      in            date,
                            p_business_group_id in            number,
                            p_jc_name           in            varchar2,
                            p_rr_sparse         in            boolean,
                            p_rr_sparse_jc      in            boolean,
                            p_asg_action_id     in            number default null,
                            p_ind_run_result_id        out nocopy number
                           );
procedure maintain_rr_value(p_run_result_id       in            number,
                                  p_session_date        in            date,
                                  p_input_value_id      in            number,
                                  p_value               in            varchar2,
                                  p_formula_result_flag in            varchar2,
                                  p_jc_name             in            varchar2,
                                  p_rr_sparse           in            boolean,
                                  p_rr_sparse_jc        in            boolean,
                                  p_mode                in            varchar2
                                );
function create_run_result_direct
                         (p_element_type_id      in number,
                          p_assignment_action_id in number,
                          p_entry_type           in varchar2,
                          p_source_id            in number,
                          p_source_type          in varchar2,
                          p_status               in varchar2,
                          p_local_unit_id        in number,
                          p_start_date           in date,
                          p_end_date             in date,
                          p_element_entry_id     in number,
                          p_time_def_id          in number
                         )
return number;
end pay_run_result_pkg;

/
