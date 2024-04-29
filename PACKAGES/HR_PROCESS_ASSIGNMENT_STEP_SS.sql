--------------------------------------------------------
--  DDL for Package HR_PROCESS_ASSIGNMENT_STEP_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_ASSIGNMENT_STEP_SS" AUTHID CURRENT_USER as
/* $Header: hrpspwrs.pkh 120.3 2008/04/04 09:41:56 gpurohit noship $ */

g_date_format  constant varchar2(10):='RRRR-MM-DD';

--
PROCEDURE create_step
     ( p_validate IN boolean default false,
       p_effective_date in date,
       p_business_group_id in number,
       p_assignment_id in number,
       p_placement_id in number,
       p_step_id in number,
       p_object_version_number  in number,
       p_effective_start_date  in date,
       p_effective_end_date  in date,
       p_reason in varchar2 default hr_api.g_varchar2,
       p_gsp_post_process_warning out nocopy varchar2,
       p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ,
       p_page_error               in out nocopy varchar2,
       p_page_error_msg           in out nocopy varchar2
       );

PROCEDURE update_step
(p_validate in boolean default false,
p_effective_date in date,
p_datetrack_update_mode in varchar2 default 'UPDATE',
p_placement_id in number,
p_business_group_id in number,
p_assignment_id in number,
p_step_id in number,
p_object_version_number in number,
p_effective_start_date in date,
p_effective_end_date in date,
p_reason in varchar2 default hr_api.g_varchar2,
p_gsp_post_process_warning out nocopy varchar2,
p_ltt_salary_data    IN OUT NOCOPY  sshr_sal_prop_tab_typ,
p_page_error               in out nocopy varchar2,
p_page_error_msg           in out nocopy varchar2
);

procedure process_step_save
(  p_item_type IN varchar2,
p_item_key IN varchar2,
p_actId in varchar2,
p_login_person_id in varchar2,
p_effective_date in varchar2,
p_effective_date_option in varchar2,
p_assignment_id in number,
p_placement_id in number,
p_step_id in number,
p_grade_id in number,
p_grade_ladder_pgm_id in number,
p_object_version_number in number,
p_business_group_id in number,
p_effective_start_date in date,
p_effective_end_date in date,
p_reason in varchar2 default hr_api.g_varchar2,
p_salary_change_warning    in out nocopy varchar2,
p_gsp_post_process_warning out nocopy varchar2,
p_gsp_salary_effective_date out nocopy date,
p_flow_mode     in varchar2 default null,
p_rptg_grp_id             IN VARCHAR2 DEFAULT NULL,
p_plan_id                 IN VARCHAR2 DEFAULT NULL,
p_page_error               in out nocopy varchar2,
p_page_error_msg           in out nocopy varchar2
);

 procedure  process_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
);

 procedure  get_transaction_data
(p_transaction_step_id                 in     number
,p_assignment_id      out  nocopy   number
,p_step_id           out  nocopy   number
,p_placement_id out nocopy  number
,p_effective_start_date out   nocopy  date
,p_effective_end_date out nocopy  date
,p_object_version_number out nocopy  number
,p_reason              out   nocopy  varchar2
,p_business_group_id   out nocopy  number
,p_spinal_point out nocopy  varchar2
);

procedure delete_pay_step
(p_item_type                in     wf_items.item_type%TYPE
,p_item_key                 in     wf_items.item_key%TYPE
,p_login_person_id          in      varchar2);

end hr_process_assignment_step_ss;

/
