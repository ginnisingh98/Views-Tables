--------------------------------------------------------
--  DDL for Package HR_QUA_AWARDS_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUA_AWARDS_UTIL_SS" AUTHID CURRENT_USER AS
/* $Header: hrquawrs.pkh 120.0.12010000.1 2008/07/28 03:45:34 appldev ship $*/

FORMAT_RRRR_MM_DD varchar2(200) := 'RRRR-MM-DD';

G_PACKAGE varchar2(50) := 'HR_QUA_AWARDS_UTIL_SS.';

API_NAME VARCHAR(50) := 'HR_QUA_AWARDS_UTIL_SS.PROCESS_API';

EDUCATION VARCHAR2(10) := 'EDUCATION';

AWARDS VARCHAR2(10) := 'AWARDS';

EDUCATION_CHANGED VARCHAR2(30) := 'EDUCATION_CHANGED';

AWARD_CHANGED VARCHAR2(30) := 'AWARD_CHANGED';

PROCEDURE check_errors
  (p_ignore_sub_date_boundaries  in varchar2 default 'N'
  ,p_mode                    in varchar2
  ,p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP
  ,p_error_message           out nocopy varchar2
  ,p_subjects_error_message  out nocopy varchar2);

PROCEDURE process_api
  (p_validate               in boolean default FALSE
  ,p_transaction_step_id    in number
  ,p_effective_date        in varchar2 default null
  );

procedure get_pending_transaction_ids
  (p_item_type		    in varchar2
  ,p_selected_person_id in varchar2
  ,p_mode               in varchar2
  ,p_process_name       in varchar2
  ,p_activity_name      in varchar2
  ,p_qualifications     out nocopy SSHR_QUA_TAB_TYP
  ,p_qua_attendance     out nocopy SSHR_QUA_ATTENDANCE_TAB_TYP
  ,p_transaction_steps  out nocopy SSHR_TRN_TAB_TYP
  );

function is_qualification_in_pending

(
   p_item_type		    in varchar2
  ,p_selected_person_id in varchar2
  ,p_mode               in varchar2
  ,p_process_name       in varchar2
  ,p_activity_name      in varchar2
  ,p_qualification_id   in number
 )
return varchar2;

PROCEDURE validate_api
  (p_validate                in boolean default TRUE
  ,p_mode                    in varchar2
  ,p_selected_person_id      in number
  ,p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP
);

function decode_value (p_expression in boolean,
		       p_true       in varchar2,
		       p_false      in varchar2) return varchar2 ;


PROCEDURE save_transaction_step
  (p_item_type               in varchar2 default null
  ,p_item_key                in varchar2 default null
  ,p_actid                   in number default null
  ,p_transaction_step_id	 in out nocopy number
  ,p_mode                    in varchar2
  ,p_creator_person_id       in number
  ,p_selected_person_id      in number
  ,p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP
  ,p_proc_call               in varchar2);


PROCEDURE validate_qualification
  (p_validate                in VARCHAR2 DEFAULT 'Y'
  ,p_save_mode               in varchar2 default null
  ,p_mode                    in varchar2
  ,p_creator_person_id       in number
  ,p_selected_person_id      in number
  ,p_item_type               in varchar2 default null
  ,p_item_key                in varchar2 default null
  ,p_act_id                  in varchar2 default null
  ,p_proc_call               in varchar2 default null
  ,p_error_message           in out nocopy varchar2
  ,p_subjects_error_message  in out nocopy varchar2
  ,p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP
);

Procedure start_transaction(itemtype     in     varchar2
                           ,itemkey      in     varchar2
                           ,actid        in     number
                           ,funmode      in     varchar2
                           ,p_selected_person_id in number
                           ,p_creator_person_id in number
                           ,result         out nocopy  varchar2);

PROCEDURE get_pending_transaction_steps
  (p_item_type          in varchar2
  ,p_selected_person_id in varchar2
  ,p_mode               in varchar2
  ,p_process_name       in varchar2
  ,p_activity_name     in varchar2
  ,p_transaction_step_id out nocopy hr_util_misc_web.g_varchar2_tab_type);


PROCEDURE get_entire_qua
  (p_transaction_step_id    in varchar2
  ,p_mode                   out nocopy varchar2
  ,p_qualifications         out nocopy SSHR_QUA_TAB_TYP
  ,p_qua_subjects           out nocopy SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance         out nocopy SSHR_QUA_ATTENDANCE_TAB_TYP
);

Procedure rollback_transaction_step
( p_transaction_step_id varchar2
 );

Function get_qualification_id ( p_transaction_step_id number )
         return Number;

Procedure delete_transaction_step ( p_transaction_step_id in number,
                                    p_creator_person_id in number );


END hr_qua_awards_util_ss;

/
