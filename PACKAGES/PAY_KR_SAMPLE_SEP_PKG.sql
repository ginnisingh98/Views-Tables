--------------------------------------------------------
--  DDL for Package PAY_KR_SAMPLE_SEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_SAMPLE_SEP_PKG" AUTHID CURRENT_USER as
/* $Header: pykrsepl.pkh 115.3 2003/05/30 07:45:29 nnaresh noship $ */
--------------------------------------------------------------------------------
function get_wkpd(p_start_date  in date,
                  p_end_date    in date) return varchar2;
--------------------------------------------------------------------------------
function get_wkpd_exclude(p_assignment_id in number,
                          p_start_date    in date,
                          p_end_date      in date,
                          p_exclude_flag  in varchar2 default 'Y') return varchar2;
--------------------------------------------------------------------------------
function get_wkpd_for_calc(p_assignment_id  in number,
                           p_working_period in varchar2,
                           p_wp_format_flag in varchar2, /* Y(YYMMDD), N(XXX) */
                           p_type           in varchar2) /* EARNING, TAX */ return number;
--------------------------------------------------------------------------------
function get_avg_sal(p_assignment_id        in number,
                     p_type                 in varchar2, /* MTH,BON,ALR */
                     p_effective_date       in date,
                     p_base_action_sequence in number default null,
                     p_action_sequence4     in number,
                     p_target_start_date    in date,
                     p_target_end_date      in date,
                     p_balance_type_id      in number) return number;
--------------------------------------------------------------------------------
function get_avg_val(p_business_group_id     in number,
                     p_assignment_action_id  in number,
                     p_performance_flag      in varchar2 default 'N',
                     p_assignment_action_id1 out nocopy number,
                     p_avg_sal1              out nocopy number,
                     p_avg_sal1_std          out nocopy date,
                     p_avg_sal1_edd          out nocopy date,
                     p_avg_sal1_wkd          out nocopy number,
                     p_assignment_action_id2 out nocopy number,
                     p_avg_sal2              out nocopy number,
                     p_avg_sal2_std          out nocopy date,
                     p_avg_sal2_edd          out nocopy date,
                     p_avg_sal2_wkd          out nocopy number,
                     p_assignment_action_id3 out nocopy number,
                     p_avg_sal3              out nocopy number,
                     p_avg_sal3_std          out nocopy date,
                     p_avg_sal3_edd          out nocopy date,
                     p_avg_sal3_wkd          out nocopy number,
                     p_assignment_action_id4 out nocopy number,
                     p_avg_sal4              out nocopy number,
                     p_avg_sal4_std          out nocopy date,
                     p_avg_sal4_edd          out nocopy date,
                     p_avg_sal4_wkd          out nocopy number,
                     p_assignment_action_idb out nocopy number,
                     p_avg_bon               out nocopy number,
                     p_assignment_action_ida out nocopy number,
                     p_avg_alr               out nocopy number) return number;
--------------------------------------------------------------------------------
end pay_kr_sample_sep_pkg;

 

/
