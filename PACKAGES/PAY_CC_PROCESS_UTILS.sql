--------------------------------------------------------
--  DDL for Package PAY_CC_PROCESS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CC_PROCESS_UTILS" AUTHID CURRENT_USER AS
/* $Header: pyccutl.pkh 120.0.12010000.1 2008/07/27 22:19:44 appldev ship $ */

-- Continuous Calculation Process procedures.
-- seeded in pay_report_format_mappings and called by pyugen.
--
procedure action_creation(p_pactid in number,
                          p_stperson in number,
                          p_endperson in number,
                          p_chunk in number);

procedure archinit(p_payroll_action_id in number);
procedure archive_data(p_assactid in number, p_effective_date in date);
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2);
procedure deinitialise (pactid in number);

--Developer utils to create/maintain DYT's
procedure generate_upd_trigger(p_table_name in varchar2,
                               p_owner in varchar2,
                               p_surr_key_name in varchar2,
                               p_eff_str_name in varchar2,
                               p_eff_end_name in varchar2,
                               p_pkg_proc_name in varchar2 default null,
                               p_bg_select in varchar2 default null,
                               p_mode in varchar2 default 'PROCEDURE');
procedure generate_cc_procedure(p_table_name in varchar2,
                                p_surr_key_name in varchar2,
                                p_eff_str_name in varchar2,
                                p_eff_end_name in varchar2,
                                p_owner in varchar2
                               );
procedure generate_upd_script(p_table_name in varchar2
                             );
FUNCTION get_asg_act_status( p_assignment_action_id in number,
                             p_action_type          in varchar2,
                             p_action_status        in varchar2) return varchar2;


--Additional helpers for DYT_PKG
procedure generate_dyt_pkg_behaviour(p_table_name  in varchar2,
                                     p_tab_rki_pkg in varchar2,
                                     p_tab_rku_pkg in varchar2,
                                     p_tab_rkd_pkg in varchar2 );
procedure drop_dyt_pkg_behaviour(p_table_name  in varchar2);

procedure reset_dates_for_run( p_asg_id    in number,
                               p_sysdate   in date,
                               p_assact_id in number);

END PAY_CC_PROCESS_UTILS;

/
