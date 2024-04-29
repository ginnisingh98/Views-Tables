--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_COMMON_SAVE_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_COMMON_SAVE_WEB" AUTHID CURRENT_USER AS
/* $Header: hrascmsw.pkh 120.1 2005/09/23 13:51:03 svittal noship $*/
--
g_data_error            exception;
--
-- -------------------------------------------------------------------------- --
-- -----------------------< validate_assignment >---------------------------- --
-- -------------------------------------------------------------------------- --
--
procedure validate_assignment
(p_validate                 in     boolean
,p_assignment_id            in     number
,p_object_version_number    in     number
,p_effective_date           in     date
,p_datetrack_update_mode    in     varchar2
,p_organization_id          in     number
,p_position_id              in     number   default null
,p_job_id                   in     number   default null
,p_grade_id                 in     number   default null
,p_location_id              in     number   default null
,p_employment_category      in     varchar2 default null
--
,p_supervisor_id            in     number   default null
,p_manager_flag             in     varchar2 default null
,p_normal_hours             in     number   default null
,p_frequency                in     varchar2 default null
,p_time_normal_finish       in     varchar2 default null
,p_time_normal_start        in     varchar2 default null
,p_assignment_status_type_id in    number   default null
,p_change_reason            in     varchar2 default null
,p_ass_attribute_category   in     varchar2 default null
,p_ass_attribute1           in     varchar2 default null
,p_ass_attribute2           in     varchar2 default null
,p_ass_attribute3           in     varchar2 default null
,p_ass_attribute4           in     varchar2 default null
,p_ass_attribute5           in     varchar2 default null
,p_ass_attribute6           in     varchar2 default null
,p_ass_attribute7           in     varchar2 default null
,p_ass_attribute8           in     varchar2 default null
,p_ass_attribute9           in     varchar2 default null
,p_ass_attribute10          in     varchar2 default null
,p_ass_attribute11          in     varchar2 default null
,p_ass_attribute12          in     varchar2 default null
,p_ass_attribute13          in     varchar2 default null
,p_ass_attribute14          in     varchar2 default null
,p_ass_attribute15          in     varchar2 default null
,p_ass_attribute16          in     varchar2 default null
,p_ass_attribute17          in     varchar2 default null
,p_ass_attribute18          in     varchar2 default null
,p_ass_attribute19          in     varchar2 default null
,p_ass_attribute20          in     varchar2 default null
,p_ass_attribute21          in     varchar2 default null
,p_ass_attribute22          in     varchar2 default null
,p_ass_attribute23          in     varchar2 default null
,p_ass_attribute24          in     varchar2 default null
,p_ass_attribute25          in     varchar2 default null
,p_ass_attribute26          in     varchar2 default null
,p_ass_attribute27          in     varchar2 default null
,p_ass_attribute28          in     varchar2 default null
,p_ass_attribute29          in     varchar2 default null
,p_ass_attribute30          in     varchar2 default null
,p_scl_segment1             in     varchar2 default null
,p_scl_segment2             in     varchar2 default null
,p_scl_segment3             in     varchar2 default null
,p_scl_segment4             in     varchar2 default null
,p_scl_segment5             in     varchar2 default null
,p_scl_segment6             in     varchar2 default null
,p_scl_segment7             in     varchar2 default null
,p_scl_segment8             in     varchar2 default null
,p_scl_segment9             in     varchar2 default null
,p_scl_segment10            in     varchar2 default null
,p_scl_segment11            in     varchar2 default null
,p_scl_segment12            in     varchar2 default null
,p_scl_segment13            in     varchar2 default null
,p_scl_segment14            in     varchar2 default null
,p_scl_segment15            in     varchar2 default null
,p_scl_segment16            in     varchar2 default null
,p_scl_segment17            in     varchar2 default null
,p_scl_segment18            in     varchar2 default null
,p_scl_segment19            in     varchar2 default null
,p_scl_segment20            in     varchar2 default null
,p_scl_segment21            in     varchar2 default null
,p_scl_segment22            in     varchar2 default null
,p_scl_segment23            in     varchar2 default null
,p_scl_segment24            in     varchar2 default null
,p_scl_segment25            in     varchar2 default null
,p_scl_segment26            in     varchar2 default null
,p_scl_segment27            in     varchar2 default null
,p_scl_segment28            in     varchar2 default null
,p_scl_segment29            in     varchar2 default null
,p_scl_segment30            in     varchar2 default null
,p_pgp_segment1             in     varchar2 default null
,p_pgp_segment2             in     varchar2 default null
,p_pgp_segment3             in     varchar2 default null
,p_pgp_segment4             in     varchar2 default null
,p_pgp_segment5             in     varchar2 default null
,p_pgp_segment6             in     varchar2 default null
,p_pgp_segment7             in     varchar2 default null
,p_pgp_segment8             in     varchar2 default null
,p_pgp_segment9             in     varchar2 default null
,p_pgp_segment10            in     varchar2 default null
,p_pgp_segment11            in     varchar2 default null
,p_pgp_segment12            in     varchar2 default null
,p_pgp_segment13            in     varchar2 default null
,p_pgp_segment14            in     varchar2 default null
,p_pgp_segment15            in     varchar2 default null
,p_pgp_segment16            in     varchar2 default null
,p_pgp_segment17            in     varchar2 default null
,p_pgp_segment18            in     varchar2 default null
,p_pgp_segment19            in     varchar2 default null
,p_pgp_segment20            in     varchar2 default null
,p_pgp_segment21            in     varchar2 default null
,p_pgp_segment22            in     varchar2 default null
,p_pgp_segment23            in     varchar2 default null
,p_pgp_segment24            in     varchar2 default null
,p_pgp_segment25            in     varchar2 default null
,p_pgp_segment26            in     varchar2 default null
,p_pgp_segment27            in     varchar2 default null
,p_pgp_segment28            in     varchar2 default null
,p_pgp_segment29            in     varchar2 default null
,p_pgp_segment30            in     varchar2 default null

--
,p_business_group_id        in     per_all_assignments_f.business_group_id%TYPE
,p_assignment_type          in     per_all_assignments_f.assignment_type%TYPE
,p_vacancy_id               in     per_all_assignments_f.vacancy_id%TYPE
,p_special_ceiling_step_id  in out nocopy per_all_assignments_f.special_ceiling_step_id%TYPE
,p_primary_flag             in     per_all_assignments_f.primary_flag%TYPE
,p_person_id                in     per_all_assignments_f.person_id%TYPE
,p_effective_start_date        out nocopy date
,p_effective_end_date          out nocopy date
,p_element_warning          in     boolean
,p_element_changed          in out nocopy varchar2
,p_email_id                 in     varchar2 default null
);
--
procedure get_asg_from_tt
          (p_transaction_step_id in     number
          ,p_assignment_rec         out nocopy per_all_assignments_f%rowtype
);
--
procedure get_pgp_from_tt
          (p_transaction_step_id in     number
          ,p_pgp_rec         out nocopy pay_people_groups%rowtype
);
--
procedure get_scl_from_tt
          (p_transaction_step_id in     number
          ,p_scl_rec         out nocopy hr_soft_coding_keyflex%rowtype
);
--
procedure get_asg_from_asg(p_assignment_id  in     number
                          ,p_effective_date in     date
                          ,p_assignment_rec    out nocopy per_all_assignments_f%rowtype);
--
procedure get_pgp_from_pgp(p_people_group_id  in     number
                          ,p_pgp_rec    out nocopy pay_people_groups%rowtype);
--
procedure get_scl_from_scl(p_soft_coding_keyflex_id  in     number
                          ,p_scl_rec                    out nocopy hr_soft_coding_keyflex%rowtype);
--
procedure get_asg(
     p_item_type                in     wf_items.item_type%TYPE
    ,p_item_key                 in     wf_items.item_key%TYPE
    ,p_assignment_id            in     per_all_assignments_f.assignment_id%type
    ,p_effective_date           in     date
    ,p_assignment_rec              out nocopy per_all_assignments_f%rowtype);
--
procedure get_step(
     p_item_type                in     wf_items.item_type%TYPE
    ,p_item_key                 in     wf_items.item_key%TYPE
    ,p_api_name                 in     varchar2
    ,p_transaction_step_id         out nocopy number
    ,p_transaction_id              out nocopy number);
--
function step_open(
     p_item_type                in     wf_items.item_type%TYPE
    ,p_item_key                 in     wf_items.item_key%TYPE
    ,p_api_name                 in     varchar2) return boolean;
--
end hr_assignment_common_save_web;

 

/
