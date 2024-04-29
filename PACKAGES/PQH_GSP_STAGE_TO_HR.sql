--------------------------------------------------------
--  DDL for Package PQH_GSP_STAGE_TO_HR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_STAGE_TO_HR" AUTHID CURRENT_USER as
/* $Header: pqgspshr.pkh 120.0 2005/05/29 02:00 appldev noship $ */
procedure setup_check(p_copy_entity_txn_id     in number,
                      p_effective_date         in date,
                      p_business_group_id      in number,
                      p_status                 out nocopy varchar2,
		      p_prog_le_created_flag   out nocopy   varchar2,
                      p_sync_le_created_flag   out nocopy   varchar2,
                      p_plan_tp_created_flag   out nocopy   varchar2);
function get_bg_for_cet(p_copy_entity_txn_id in number) return number;
procedure pre_push_data(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
			P_Date_Track_Mode     IN Varchar2 default 'UPDATE_OVERRIDE');
procedure post_push_data(p_copy_entity_txn_id in number,
                         p_effective_date     in date,
                         p_business_group_id  in number,
                         p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure gsp_data_push(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_datetrack_mode     in varchar2,
                        p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure stage_to_hr(p_copy_entity_txn_id in number,
                      p_effective_date     in date,
                      p_business_group_id  in number,
                      p_gl_currency        in varchar2,
                      p_gl_name            in varchar2,
                      p_gl_frequency       in varchar2,
                      p_datetrack_mode     in varchar2,
                      p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure stage_to_point(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
Procedure stage_to_grade(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date);
procedure stage_to_grd_sp(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_datetrack_mode     in varchar2);
procedure stage_to_step(p_copy_entity_txn_id in number,
                        p_business_group_id in number,
                        p_effective_date    in date,
                        p_datetrack_mode    in varchar2);
Procedure stage_to_scale(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure stage_to_hrate(p_copy_entity_txn_id in number,
                         p_business_group_id in number,
                         p_gl_currency       in varchar2,
                         p_effective_date    in date,
                         p_datetrack_mode    in varchar2);
end pqh_gsp_stage_to_hr;

 

/
