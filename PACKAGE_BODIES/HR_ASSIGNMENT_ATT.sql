--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_ATT" as
/* $Header: peasgati.pkb 120.4 2007/12/24 06:58:33 gpurohit noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_assignment_att.';
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_asg >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_attribute_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_project_title                in     varchar2 default hr_api.g_varchar2
  ,p_vendor_assignment_number     in     varchar2 default hr_api.g_varchar2
  ,p_vendor_employee_number       in     varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in     number default hr_api.g_number
  ,p_assignment_type              in     varchar2
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  )  is
  l_proc                     varchar2(72)  := g_package||'update_asg';
  l_effective_date           date          := trunc(p_effective_date);
  l_constant_effective_date  constant date := l_effective_date;
  l_effective_date_row       boolean       := true;
  l_validation_start_date    date;
  l_validation_end_date      date;
  l_datetrack_update_mode    varchar2(30);
  l_correction               boolean;
  l_update                   boolean;
  l_update_override          boolean;
  l_update_change_insert     boolean;
  l_lck_start_date           date;
  --
  lv_object_version_number    number := p_object_version_number ;
  --
  -- --------------------------------------------------------------------------
  -- local cursor definitions
  -- --------------------------------------------------------------------------
  -- csr_asg_lck  -> locks all the datetracked rows for the specified assignment
  --                 from the specified lock date. this enforces integrity.
  --                 if the datetrack operation is for an ATTRIBUTE_UPDATE
  --                 then only the current and future rows will be locked. if
  --                 the datetrack operation is a ATTRIBUTE_CORRECTION then
  --                 all assignment rows are locked as we cannot guarantee how
  --                 many rows will be changed.
  -- csr_asg1     -> selects assignment details for the current and future rows
  -- csr_asg2     -> selects assignment details in the past in a descending
  --                 order not including the current row as of the effective
  --                 date.
  --
  -- note: the cursors csr_asg1 and csr_asg2 are specifically not merged
  --       because of the of the order by clause
  --
  -- cursor to lock all rows for which the datetrack operation could
  -- operate over
  cursor csr_asg_lck(c_lck_start_date date) is
    select 1
    from   per_all_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    asg.effective_end_date >= c_lck_start_date
    for    update nowait;
  -- select current and future rows
  cursor csr_asg1 is
  select
   asg.object_version_number
  ,asg.supervisor_id
  -- Assignment Security
  ,asg.supervisor_assignment_id

  ,asg.assignment_number
  ,asg.change_reason
  ,asg.date_probation_end
  ,asg.default_code_comb_id
  ,asg.frequency
  ,asg.internal_address_line
  ,asg.manager_flag
  ,asg.normal_hours
  ,asg.perf_review_period
  ,asg.perf_review_period_frequency
  ,asg.probation_period
  ,asg.probation_unit
  ,asg.sal_review_period
  ,asg.sal_review_period_frequency
  ,asg.set_of_books_id
  ,asg.source_type
  ,asg.time_normal_finish
  ,asg.time_normal_start
  ,asg.ass_attribute_category
  ,asg.ass_attribute1
  ,asg.ass_attribute2
  ,asg.ass_attribute3
  ,asg.ass_attribute4
  ,asg.ass_attribute5
  ,asg.ass_attribute6
  ,asg.ass_attribute7
  ,asg.ass_attribute8
  ,asg.ass_attribute9
  ,asg.ass_attribute10
  ,asg.ass_attribute11
  ,asg.ass_attribute12
  ,asg.ass_attribute13
  ,asg.ass_attribute14
  ,asg.ass_attribute15
  ,asg.ass_attribute16
  ,asg.ass_attribute17
  ,asg.ass_attribute18
  ,asg.ass_attribute19
  ,asg.ass_attribute20
  ,asg.ass_attribute21
  ,asg.ass_attribute22
  ,asg.ass_attribute23
  ,asg.ass_attribute24
  ,asg.ass_attribute25
  ,asg.ass_attribute26
  ,asg.ass_attribute27
  ,asg.ass_attribute28
  ,asg.ass_attribute29
  ,asg.ass_attribute30
  ,asg.title
  ,asg.effective_start_date
  ,asg.effective_end_date
  ,hc.comment_text
  ,asg.project_title
  ,asg.vendor_assignment_number
  ,asg.vendor_employee_number
  ,asg.vendor_id
  from  hr_comments hc
  ,     per_all_assignments_f asg
  where asg.assignment_id=p_assignment_id
  and   asg.effective_end_date >= l_constant_effective_date
  and   hc.comment_id(+) = asg.comment_id
  order by asg.effective_end_date asc;
    -- select past rows not including the current rows
  cursor csr_asg2 is
  select
   asg.object_version_number
  ,asg.supervisor_id
  -- Assignment Security
  ,asg.supervisor_assignment_id
  ,asg.assignment_number
  ,asg.change_reason
  ,asg.date_probation_end
  ,asg.default_code_comb_id
  ,asg.frequency
  ,asg.internal_address_line
  ,asg.manager_flag
  ,asg.normal_hours
  ,asg.perf_review_period
  ,asg.perf_review_period_frequency
  ,asg.probation_period
  ,asg.probation_unit
  ,asg.sal_review_period
  ,asg.sal_review_period_frequency
  ,asg.set_of_books_id
  ,asg.source_type
  ,asg.time_normal_finish
  ,asg.time_normal_start
  ,asg.ass_attribute_category
  ,asg.ass_attribute1
  ,asg.ass_attribute2
  ,asg.ass_attribute3
  ,asg.ass_attribute4
  ,asg.ass_attribute5
  ,asg.ass_attribute6
  ,asg.ass_attribute7
  ,asg.ass_attribute8
  ,asg.ass_attribute9
  ,asg.ass_attribute10
  ,asg.ass_attribute11
  ,asg.ass_attribute12
  ,asg.ass_attribute13
  ,asg.ass_attribute14
  ,asg.ass_attribute15
  ,asg.ass_attribute16
  ,asg.ass_attribute17
  ,asg.ass_attribute18
  ,asg.ass_attribute19
  ,asg.ass_attribute20
  ,asg.ass_attribute21
  ,asg.ass_attribute22
  ,asg.ass_attribute23
  ,asg.ass_attribute24
  ,asg.ass_attribute25
  ,asg.ass_attribute26
  ,asg.ass_attribute27
  ,asg.ass_attribute28
  ,asg.ass_attribute29
  ,asg.ass_attribute30
  ,asg.title
  ,asg.effective_start_date
  ,asg.effective_end_date
  ,hc.comment_text
  ,asg.project_title
  ,asg.vendor_assignment_number
  ,asg.vendor_employee_number
  ,asg.vendor_id
  from  hr_comments hc
  ,     per_all_assignments_f asg
  where asg.assignment_id=p_assignment_id
  and   asg.effective_end_date < l_constant_effective_date
  and   hc.comment_id(+) = asg.comment_id
  order by asg.effective_end_date desc;
  -- IN parameters for API
  l_asg_rec per_all_assignments_f%rowtype;
  l_comments hr_comments.comment_text%TYPE;
  -- OUT parameters for API
  l_soft_coding_keyflex_id     number;
  l_comment_id                 number;
  l_effective_start_date       date;
  l_effective_end_date         date;
  l_concatenated_segments      hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_no_managers_warning        boolean;
  l_other_manager_warning      boolean;
  l_api_no_managers_warning    boolean := false;
  l_org_now_no_manager_warning boolean;
  l_hourly_salaried_warning    boolean;
  l_api_other_manager_warning  boolean := false;
  --
  -- --------------------------------------------------------------------------
  -- |---------------------------< process_row >------------------------------|
  -- --------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description:
  --   This private function is used to determine the correct attribute values
  --   to pass to the API.
  --
  --   1. Determine the parameter value to be passed to the API
  --   2. If at least one parameter value is changing then call the API
  --      else exit function
  --   3. Set any parameters which have been supplied by the resulting call
  --      to the API
  --
  -- Pre Conditions:
  --   A row must be active from the cursor csr_asg1 or csr_asg2
  --
  -- In Arguments:
  --   All the IN arguments hold the current selected cursor row values.
  --
  -- Post Success:
  --   Ths function will return either TRUE or FALSE.
  --   If TRUE is returned, the row has been processed succesfully and
  --   attributes could possibly still be processed.
  --   If FALSE is returned, the row has been processed succesfully
  --   and all the attributes have been updated as far as possible.
  --
  -- Post Failure:
  --   Exceptions are not handled, just raised.
  --
  -- Developer Implementation Notes:
  --   None
  --
  -- Access Status:
  --   Internal to owning procedure.
  --
  -- {End Of Comments}
  -- --------------------------------------------------------------------------
  function process_row
    (c_effective_start_date         in     date
    ,c_object_version_number        in     number
    ,c_supervisor_id                in     number   default hr_api.g_number
    ,c_supervisor_assignment_id     in     number   default hr_api.g_number

    ,c_assignment_number            in     varchar2 default hr_api.g_varchar2
    ,c_change_reason                in     varchar2 default hr_api.g_varchar2
    ,c_comments                     in     varchar2 default hr_api.g_varchar2
    ,c_date_probation_end           in     date     default hr_api.g_date
    ,c_default_code_comb_id         in     number   default hr_api.g_number
    ,c_frequency                    in     varchar2 default hr_api.g_varchar2
    ,c_internal_address_line        in     varchar2 default hr_api.g_varchar2
    ,c_manager_flag                 in     varchar2 default hr_api.g_varchar2
    ,c_normal_hours                 in     number   default hr_api.g_number
    ,c_perf_review_period           in     number   default hr_api.g_number
    ,c_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
    ,c_probation_period             in     number   default hr_api.g_number
    ,c_probation_unit               in     varchar2 default hr_api.g_varchar2
    ,c_sal_review_period            in     number   default hr_api.g_number
    ,c_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
    ,c_set_of_books_id              in     number   default hr_api.g_number
    ,c_source_type                  in     varchar2 default hr_api.g_varchar2
    ,c_time_normal_finish           in     varchar2 default hr_api.g_varchar2
    ,c_time_normal_start            in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute1               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute2               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute3               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute4               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute5               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute6               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute7               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute8               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute9               in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute10              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute11              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute12              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute13              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute14              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute15              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute16              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute17              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute18              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute19              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute20              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute21              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute22              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute23              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute24              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute25              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute26              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute27              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute28              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute29              in     varchar2 default hr_api.g_varchar2
    ,c_ass_attribute30              in     varchar2 default hr_api.g_varchar2
    ,c_title                        in     varchar2 default hr_api.g_varchar2
    ,c_project_title            in varchar2 default hr_api.g_varchar2
    ,c_vendor_assignment_number in varchar2 default hr_api.g_varchar2
    ,c_vendor_employee_number   in varchar2 default hr_api.g_varchar2
    ,c_vendor_id                in number default hr_api.g_number
    )
  return boolean is
    l_proc          varchar2(72)   := g_package||'process_row';
  begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
    -- get the parameter values to pass to the API

--  if (l_effective_date_row) then

    l_asg_rec.supervisor_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_SUPERVISOR_ID'
                              ,p_new_value       => p_supervisor_id
                              ,p_current_value   => c_supervisor_id);

    -- Assignment Security
    l_asg_rec.supervisor_assignment_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_SUPERVISOR_ASSIGNMENT_ID'
                              ,p_new_value       => p_supervisor_assignment_id
                              ,p_current_value   => c_supervisor_assignment_id);


    l_asg_rec.assignment_number:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_assignment_number'
                              ,p_new_value       => p_assignment_number
                              ,p_current_value   => c_assignment_number);

    l_asg_rec.change_reason:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_change_reason'
                              ,p_new_value       => p_change_reason
                              ,p_current_value   => c_change_reason);

    l_comments:=              hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_comments'
                              ,p_new_value       => p_comments
                              ,p_current_value   => c_comments);

    l_asg_rec.date_probation_end:= hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_date_probation_end'
                              ,p_new_value       => p_date_probation_end
                              ,p_current_value   => c_date_probation_end);


    l_asg_rec.default_code_comb_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_default_code_comb_id'
                              ,p_new_value       => p_default_code_comb_id
                              ,p_current_value   => c_default_code_comb_id);

    l_asg_rec.frequency:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_frequency'
                              ,p_new_value       => p_frequency
                              ,p_current_value   => c_frequency);

    l_asg_rec.internal_address_line:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_internal_address_line'
                              ,p_new_value       => p_internal_address_line
                              ,p_current_value   => c_internal_address_line);

    l_asg_rec.manager_flag:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_manager_flag'
                              ,p_new_value       => p_manager_flag
                              ,p_current_value   => c_manager_flag);

    l_asg_rec.normal_hours:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_normal_hours'
                              ,p_new_value       => p_normal_hours
                              ,p_current_value   => c_normal_hours);

    l_asg_rec.perf_review_period:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_perf_review_period'
                              ,p_new_value       => p_perf_review_period
                              ,p_current_value   => c_perf_review_period);

    l_asg_rec.perf_review_period_frequency:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_perf_review_period_frequency'
                              ,p_new_value       => p_perf_review_period_frequency
                              ,p_current_value   => c_perf_review_period_frequency);

    l_asg_rec.probation_period:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_probation_period'
                              ,p_new_value       => p_probation_period
                              ,p_current_value   => c_probation_period);

    l_asg_rec.probation_unit:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_probation_unit'
                              ,p_new_value       => p_probation_unit
                              ,p_current_value   => c_probation_unit);

    l_asg_rec.sal_review_period:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_sal_review_period'
                              ,p_new_value       => p_sal_review_period
                              ,p_current_value   => c_sal_review_period);

    l_asg_rec.sal_review_period_frequency:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_sal_review_period_frequency'
                              ,p_new_value       => p_sal_review_period_frequency
                              ,p_current_value   => c_sal_review_period_frequency);

    l_asg_rec.set_of_books_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_set_of_books_id'
                              ,p_new_value       => p_set_of_books_id
                              ,p_current_value   => c_set_of_books_id);

    l_asg_rec.source_type:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_source_type'
                              ,p_new_value       => p_source_type
                              ,p_current_value   => c_source_type);

    l_asg_rec.time_normal_finish:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_time_normal_finish'
                              ,p_new_value       => p_time_normal_finish
                              ,p_current_value   => c_time_normal_finish);

    l_asg_rec.time_normal_start:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_time_normal_start'
                              ,p_new_value       => p_time_normal_start
                              ,p_current_value   => c_time_normal_start);

    l_asg_rec.ass_attribute_category:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute_category'
                              ,p_new_value       => p_ass_attribute_category
                              ,p_current_value   => c_ass_attribute_category);

    l_asg_rec.ass_attribute1:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute1'
                              ,p_new_value       => p_ass_attribute1
                              ,p_current_value   => c_ass_attribute1);

    l_asg_rec.ass_attribute2:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute2'
                              ,p_new_value       => p_ass_attribute2
                              ,p_current_value   => c_ass_attribute2);

    l_asg_rec.ass_attribute3:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute3'
                              ,p_new_value       => p_ass_attribute3
                              ,p_current_value   => c_ass_attribute3);

    l_asg_rec.ass_attribute4:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute4'
                              ,p_new_value       => p_ass_attribute4
                              ,p_current_value   => c_ass_attribute4);

    l_asg_rec.ass_attribute5:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute5'
                              ,p_new_value       => p_ass_attribute5
                              ,p_current_value   => c_ass_attribute5);

    l_asg_rec.ass_attribute6:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute6'
                              ,p_new_value       => p_ass_attribute6
                              ,p_current_value   => c_ass_attribute6);

    l_asg_rec.ass_attribute7:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute7'
                              ,p_new_value       => p_ass_attribute7
                              ,p_current_value   => c_ass_attribute7);

    l_asg_rec.ass_attribute8:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute8'
                              ,p_new_value       => p_ass_attribute8
                              ,p_current_value   => c_ass_attribute8);

    l_asg_rec.ass_attribute9:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute9'
                              ,p_new_value       => p_ass_attribute9
                              ,p_current_value   => c_ass_attribute9);

    l_asg_rec.ass_attribute10:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute10'
                              ,p_new_value       => p_ass_attribute10
                              ,p_current_value   => c_ass_attribute10);


    l_asg_rec.ass_attribute11:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute11'
                              ,p_new_value       => p_ass_attribute11
                              ,p_current_value   => c_ass_attribute11);

    l_asg_rec.ass_attribute12:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute12'
                              ,p_new_value       => p_ass_attribute12
                              ,p_current_value   => c_ass_attribute12);

    l_asg_rec.ass_attribute13:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute13'
                              ,p_new_value       => p_ass_attribute13
                              ,p_current_value   => c_ass_attribute13);

    l_asg_rec.ass_attribute14:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute14'
                              ,p_new_value       => p_ass_attribute14
                              ,p_current_value   => c_ass_attribute14);

    l_asg_rec.ass_attribute15:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute15'
                              ,p_new_value       => p_ass_attribute15
                              ,p_current_value   => c_ass_attribute15);

    l_asg_rec.ass_attribute16:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute16'
                              ,p_new_value       => p_ass_attribute16
                              ,p_current_value   => c_ass_attribute16);

    l_asg_rec.ass_attribute17:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute17'
                              ,p_new_value       => p_ass_attribute17
                              ,p_current_value   => c_ass_attribute17);

    l_asg_rec.ass_attribute18:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute18'
                              ,p_new_value       => p_ass_attribute18
                              ,p_current_value   => c_ass_attribute18);

    l_asg_rec.ass_attribute19:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute19'
                              ,p_new_value       => p_ass_attribute19
                              ,p_current_value   => c_ass_attribute19);

    l_asg_rec.ass_attribute20:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute20'
                              ,p_new_value       => p_ass_attribute20
                              ,p_current_value   => c_ass_attribute20);

    l_asg_rec.ass_attribute21:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute21'
                              ,p_new_value       => p_ass_attribute21
                              ,p_current_value   => c_ass_attribute21);

    l_asg_rec.ass_attribute22:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute22'
                              ,p_new_value       => p_ass_attribute22
                              ,p_current_value   => c_ass_attribute22);

    l_asg_rec.ass_attribute23:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute23'
                              ,p_new_value       => p_ass_attribute23
                              ,p_current_value   => c_ass_attribute23);

    l_asg_rec.ass_attribute24:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute24'
                              ,p_new_value       => p_ass_attribute24
                              ,p_current_value   => c_ass_attribute24);

    l_asg_rec.ass_attribute25:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute25'
                              ,p_new_value       => p_ass_attribute25
                              ,p_current_value   => c_ass_attribute25);

    l_asg_rec.ass_attribute26:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute26'
                              ,p_new_value       => p_ass_attribute26
                              ,p_current_value   => c_ass_attribute26);

    l_asg_rec.ass_attribute27:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute27'
                              ,p_new_value       => p_ass_attribute27
                              ,p_current_value   => c_ass_attribute27);

    l_asg_rec.ass_attribute28:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute28'
                              ,p_new_value       => p_ass_attribute28
                              ,p_current_value   => c_ass_attribute28);

    l_asg_rec.ass_attribute29:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute29'
                              ,p_new_value       => p_ass_attribute29
                              ,p_current_value   => c_ass_attribute29);

    l_asg_rec.ass_attribute30:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_ass_attribute30'
                              ,p_new_value       => p_ass_attribute30
                              ,p_current_value   => c_ass_attribute30);

    l_asg_rec.title:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_title'
                              ,p_new_value       => p_title
                              ,p_current_value   => c_title);

    l_asg_rec.project_title:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_project_title'
                              ,p_new_value       => p_project_title
                              ,p_current_value   => c_project_title);

    l_asg_rec.vendor_assignment_number:=
         hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_vendor_assignment_number'
                              ,p_new_value       => p_vendor_assignment_number
                              ,p_current_value   => c_vendor_assignment_number);

    l_asg_rec.vendor_employee_number:=
         hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_vendor_employee_number'
                              ,p_new_value       => p_vendor_employee_number
                              ,p_current_value   => c_vendor_employee_number);

     l_asg_rec.vendor_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'p_vendor_id'
                              ,p_new_value       => p_vendor_id
                              ,p_current_value   => c_vendor_id);

--  end if;

--
    -- call the API if at least one attribute can be changed
    if hr_dt_attribute_support.is_current_row_changing then
      -- set the object version number and effective date
      if l_effective_date_row then
        -- as we are on the first row, the ovn and effective date should be
        -- set to the parameter specified by the caller
        l_asg_rec.object_version_number := p_object_version_number;
        l_effective_date        := l_constant_effective_date;
      else
        -- as we are not on the first row, set the ovn and effective date
        -- to the ovn and effective date for the row
        l_asg_rec.object_version_number := c_object_version_number;
        l_effective_date        := c_effective_start_date;
      end if;

    if (p_assignment_type = 'C') then
      -- call cwk api
      hr_assignment_api.update_cwk_asg
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_asg_rec.object_version_number
--      ,p_assignment_category          => l_asg_rec.assignment_category
      ,p_assignment_number            => l_asg_rec.assignment_number
      ,p_change_reason                => l_asg_rec.change_reason
      ,p_comments                     => l_comments
      ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
      ,p_frequency                    => l_asg_rec.frequency
      ,p_internal_address_line        => l_asg_rec.internal_address_line
      ,p_manager_flag                 => l_asg_rec.manager_flag
      ,p_normal_hours                 => l_asg_rec.normal_hours
      ,p_set_of_books_id              => l_asg_rec.set_of_books_id
      ,p_source_type                  => l_asg_rec.source_type
      ,p_supervisor_id                => l_asg_rec.supervisor_id

      ,p_time_normal_finish           => l_asg_rec.time_normal_finish
      ,p_time_normal_start            => l_asg_rec.time_normal_start
      ,p_title                        => l_asg_rec.title
      ,p_project_title                => l_asg_rec.project_title
      ,p_vendor_assignment_number     => l_asg_rec.vendor_assignment_number
      ,p_vendor_employee_number       => l_asg_rec.vendor_employee_number
      ,p_vendor_id                    => l_asg_rec.vendor_id
      --,p_assignment_status_type_id    => l_asg_rec.assignment_status_type_id
      ,p_attribute_category       => l_asg_rec.ass_attribute_category
      ,p_attribute1               => l_asg_rec.ass_attribute1
      ,p_attribute2               => l_asg_rec.ass_attribute2
      ,p_attribute3               => l_asg_rec.ass_attribute3
      ,p_attribute4               => l_asg_rec.ass_attribute4
      ,p_attribute5               => l_asg_rec.ass_attribute5
      ,p_attribute6               => l_asg_rec.ass_attribute6
      ,p_attribute7               => l_asg_rec.ass_attribute7
      ,p_attribute8               => l_asg_rec.ass_attribute8
      ,p_attribute9               => l_asg_rec.ass_attribute9
      ,p_attribute10              => l_asg_rec.ass_attribute10
      ,p_attribute11              => l_asg_rec.ass_attribute11
      ,p_attribute12              => l_asg_rec.ass_attribute12
      ,p_attribute13              => l_asg_rec.ass_attribute13
      ,p_attribute14              => l_asg_rec.ass_attribute14
      ,p_attribute15              => l_asg_rec.ass_attribute15
      ,p_attribute16              => l_asg_rec.ass_attribute16
      ,p_attribute17              => l_asg_rec.ass_attribute17
      ,p_attribute18              => l_asg_rec.ass_attribute18
      ,p_attribute19              => l_asg_rec.ass_attribute19
      ,p_attribute20              => l_asg_rec.ass_attribute20
      ,p_attribute21              => l_asg_rec.ass_attribute21
      ,p_attribute22              => l_asg_rec.ass_attribute22
      ,p_attribute23              => l_asg_rec.ass_attribute23
      ,p_attribute24              => l_asg_rec.ass_attribute24
      ,p_attribute25              => l_asg_rec.ass_attribute25
      ,p_attribute26              => l_asg_rec.ass_attribute26
      ,p_attribute27              => l_asg_rec.ass_attribute27
      ,p_attribute28              => l_asg_rec.ass_attribute28
      ,p_attribute29              => l_asg_rec.ass_attribute29
      ,p_attribute30              => l_asg_rec.ass_attribute30

      -- Assignment Security
      ,p_supervisor_assignment_id     => l_asg_rec.supervisor_assignment_id

      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_comment_id                   => l_comment_id
      ,p_no_managers_warning          => l_no_managers_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_hourly_salaried_warning      => l_hourly_salaried_warning
      );
    else
      -- call emp API
    hr_assignment_api.update_emp_asg
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_asg_rec.object_version_number
      ,p_supervisor_id                => l_asg_rec.supervisor_id
      ,p_assignment_number            => l_asg_rec.assignment_number
      ,p_change_reason                => l_asg_rec.change_reason
      ,p_comments                     => l_comments
      ,p_date_probation_end           => l_asg_rec.date_probation_end
      ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
      ,p_frequency                    => l_asg_rec.frequency
      ,p_internal_address_line        => l_asg_rec.internal_address_line
      ,p_manager_flag                 => l_asg_rec.manager_flag
      ,p_normal_hours                 => l_asg_rec.normal_hours
      ,p_perf_review_period           => l_asg_rec.perf_review_period
      ,p_perf_review_period_frequency => l_asg_rec.perf_review_period_frequency
      ,p_probation_period             => l_asg_rec.probation_period
      ,p_probation_unit               => l_asg_rec.probation_unit
      ,p_sal_review_period            => l_asg_rec.sal_review_period
      ,p_sal_review_period_frequency  => l_asg_rec.sal_review_period_frequency
      ,p_set_of_books_id              => l_asg_rec.set_of_books_id
      ,p_source_type                  => l_asg_rec.source_type
      ,p_time_normal_finish           => l_asg_rec.time_normal_finish
      ,p_time_normal_start            => l_asg_rec.time_normal_start
      ,p_ass_attribute_category       => l_asg_rec.ass_attribute_category
      ,p_ass_attribute1               => l_asg_rec.ass_attribute1
      ,p_ass_attribute2               => l_asg_rec.ass_attribute2
      ,p_ass_attribute3               => l_asg_rec.ass_attribute3
      ,p_ass_attribute4               => l_asg_rec.ass_attribute4
      ,p_ass_attribute5               => l_asg_rec.ass_attribute5
      ,p_ass_attribute6               => l_asg_rec.ass_attribute6
      ,p_ass_attribute7               => l_asg_rec.ass_attribute7
      ,p_ass_attribute8               => l_asg_rec.ass_attribute8
      ,p_ass_attribute9               => l_asg_rec.ass_attribute9
      ,p_ass_attribute10              => l_asg_rec.ass_attribute10
      ,p_ass_attribute11              => l_asg_rec.ass_attribute11
      ,p_ass_attribute12              => l_asg_rec.ass_attribute12
      ,p_ass_attribute13              => l_asg_rec.ass_attribute13
      ,p_ass_attribute14              => l_asg_rec.ass_attribute14
      ,p_ass_attribute15              => l_asg_rec.ass_attribute15
      ,p_ass_attribute16              => l_asg_rec.ass_attribute16
      ,p_ass_attribute17              => l_asg_rec.ass_attribute17
      ,p_ass_attribute18              => l_asg_rec.ass_attribute18
      ,p_ass_attribute19              => l_asg_rec.ass_attribute19
      ,p_ass_attribute20              => l_asg_rec.ass_attribute20
      ,p_ass_attribute21              => l_asg_rec.ass_attribute21
      ,p_ass_attribute22              => l_asg_rec.ass_attribute22
      ,p_ass_attribute23              => l_asg_rec.ass_attribute23
      ,p_ass_attribute24              => l_asg_rec.ass_attribute24
      ,p_ass_attribute25              => l_asg_rec.ass_attribute25
      ,p_ass_attribute26              => l_asg_rec.ass_attribute26
      ,p_ass_attribute27              => l_asg_rec.ass_attribute27
      ,p_ass_attribute28              => l_asg_rec.ass_attribute28
      ,p_ass_attribute29              => l_asg_rec.ass_attribute29
      ,p_ass_attribute30              => l_asg_rec.ass_attribute30
      ,p_title                        => l_asg_rec.title
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_no_managers_warning          => l_no_managers_warning
      ,p_other_manager_warning        => l_other_manager_warning
      -- Assignment Security
      ,p_supervisor_assignment_id     => l_asg_rec.supervisor_assignment_id
      );
      end if;
      --
      if l_effective_date_row then
        -- reset the first row flag
        l_effective_date_row := false;
        -- set all future row operations to a CORRECTION
        l_datetrack_update_mode := hr_api.g_correction;
        -- set the API out parameters for the first transaction
        p_object_version_number := l_asg_rec.object_version_number;
        p_comment_id            := l_comment_id;
        p_effective_start_date  := l_effective_start_date;
        p_effective_end_date    := l_effective_end_date;
      end if;
      -- determine if the warnings have been set at all
      if l_no_managers_warning and not l_api_no_managers_warning then
        l_api_no_managers_warning := l_no_managers_warning;
      end if;
       if l_other_manager_warning and not l_api_other_manager_warning then
        l_api_other_manager_warning := l_other_manager_warning;
      end if;
      hr_utility.set_location(' Leaving:'|| l_proc, 10);
      -- we need to process the next row so return true
      return(true);
    else
      hr_utility.set_location(' Leaving:'|| l_proc, 15);
      -- processing has finished return false
      return(false);
    end if;
  end process_row;
-------------------------------------begin---------------------------------------------
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_asg;
  end if;
  -- lock the current row for the following two reasons:
  -- a) ensure that the current row exists for the person as of the
  --    specified effective date. we only lock the current row so the
  --    CORRECTION datetrack mode is used
  -- b) to populate the l_validation_start_date which is used
  --    in determining the correct datetrack mode on an update operation
  per_asg_shd.lck
    (p_effective_date        => l_constant_effective_date
    ,p_datetrack_mode        => hr_api.g_correction
    ,p_assignment_id         => p_assignment_id
    ,p_object_version_number => p_object_version_number
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date);
  -- determine the datetrack mode to use
  if p_attribute_update_mode = 'ATTRIBUTE_UPDATE' then
    -- ------------------------------------------------------------------------
    -- step 1: as we are performing an ATTRIBUTE_UPDATE we must determine
    --         the initial datetrack mode to use (UPDATE, CORRECTION or
    --         UPDATE_CHANGE_INSERT)
    --
    --    1.1 - call the assignment datetrack find_dt_upd_modes to determine
    --          all possible allowed datetrack update modes
    --    1.2 - determine the actual datetrack mode to use
    --          the logic is as follows;
    --          if update allowed then select UPDATE as mode
    --          if change insert allowed then select UPDATE_CHANGE_INSERT as
    --          mode
    --          otherwise, select CORRECTION as the mode
    -- ------------------------------------------------------------------------
    -- step 1.1
    per_asg_shd.find_dt_upd_modes
      (p_effective_date       => l_constant_effective_date
      ,p_base_key_value       => p_assignment_id
      ,p_correction           => l_correction
      ,p_update               => l_update
      ,p_update_override      => l_update_override
      ,p_update_change_insert => l_update_change_insert);
    -- step 1.2
    if l_update then
      -- we can do an update
      l_datetrack_update_mode := hr_api.g_update;
    elsif l_update_change_insert then
      -- we can do an update change insert
      l_datetrack_update_mode := hr_api.g_update_change_insert;
    elsif (l_validation_start_date = l_constant_effective_date) and
           l_correction then
      -- we can only perform a correction
      l_datetrack_update_mode := hr_api.g_correction;
    else
      -- we cannot perform an update due to a restriction within the APIs
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    end if;
    -- set lock start date to the effective date
    l_lck_start_date := l_constant_effective_date;
  elsif p_attribute_update_mode = 'ATTRIBUTE_CORRECTION' then
    -- set lock start date to start of time and the datetrack mode
    -- to CORRECTION
    l_lck_start_date := hr_api.g_sot;
    l_datetrack_update_mode := hr_api.g_correction;
  else
    -- the datetrack mode is not an ATTRIBUTE_UPDATE or ATTRIBUTE_CORRECTION
    -- so raise DT invalid mode error
    hr_utility.set_message(801, 'HR_7203_DT_UPD_MODE_INVALID');
    hr_utility.raise_error;
  end if;
  -- lock all assignment rows to ensure integrity. note: this will never fail.
  -- if the assignment doesn't exist (i.e. the assignment_id is invalid) then the
  -- business process will error with the correct error
  open csr_asg_lck(l_lck_start_date);
  close csr_asg_lck;
  -- ------------------------------------------------------------------------
  -- process the current and future row(s)
  -- ------------------------------------------------------------------------
  for I in csr_asg1 loop
    if not process_row
      (c_effective_start_date         => I.effective_start_date
      ,c_object_version_number        => I.object_version_number
      ,c_supervisor_id                => I.supervisor_id
      -- Assignment Security
      ,c_supervisor_assignment_id     => I.supervisor_assignment_id

      ,c_assignment_number            => I.assignment_number
      ,c_change_reason                => I.change_reason
      ,c_comments                     => I.comment_text
      ,c_date_probation_end           => I.date_probation_end
      ,c_default_code_comb_id         => I.default_code_comb_id
      ,c_frequency                    => I.frequency
      ,c_internal_address_line        => I.internal_address_line
      ,c_manager_flag                 => I.manager_flag
      ,c_normal_hours                 => I.normal_hours
      ,c_perf_review_period           => I.perf_review_period
      ,c_perf_review_period_frequency => I.perf_review_period_frequency
      ,c_probation_period             => I.probation_period
      ,c_probation_unit               => I.probation_unit
      ,c_sal_review_period            => I.sal_review_period
      ,c_sal_review_period_frequency  => I.sal_review_period_frequency
      ,c_set_of_books_id              => I.set_of_books_id
      ,c_source_type                  => I.source_type
      ,c_time_normal_finish           => I.time_normal_finish
      ,c_time_normal_start            => I.time_normal_start
      ,c_ass_attribute_category       => I.ass_attribute_category
      ,c_ass_attribute1               => I.ass_attribute1
      ,c_ass_attribute2               => I.ass_attribute2
      ,c_ass_attribute3               => I.ass_attribute3
      ,c_ass_attribute4               => I.ass_attribute4
      ,c_ass_attribute5               => I.ass_attribute5
      ,c_ass_attribute6               => I.ass_attribute6
      ,c_ass_attribute7               => I.ass_attribute7
      ,c_ass_attribute8               => I.ass_attribute8
      ,c_ass_attribute9               => I.ass_attribute9
      ,c_ass_attribute10              => I.ass_attribute10
      ,c_ass_attribute11              => I.ass_attribute11
      ,c_ass_attribute12              => I.ass_attribute12
      ,c_ass_attribute13              => I.ass_attribute13
      ,c_ass_attribute14              => I.ass_attribute14
      ,c_ass_attribute15              => I.ass_attribute15
      ,c_ass_attribute16              => I.ass_attribute16
      ,c_ass_attribute17              => I.ass_attribute17
      ,c_ass_attribute18              => I.ass_attribute18
      ,c_ass_attribute19              => I.ass_attribute19
      ,c_ass_attribute20              => I.ass_attribute20
      ,c_ass_attribute21              => I.ass_attribute21
      ,c_ass_attribute22              => I.ass_attribute22
      ,c_ass_attribute23              => I.ass_attribute23
      ,c_ass_attribute24              => I.ass_attribute24
      ,c_ass_attribute25              => I.ass_attribute25
      ,c_ass_attribute26              => I.ass_attribute26
      ,c_ass_attribute27              => I.ass_attribute27
      ,c_ass_attribute28              => I.ass_attribute28
      ,c_ass_attribute29              => I.ass_attribute29
      ,c_ass_attribute30              => I.ass_attribute30
      ,c_title                        => I.title
      ,c_project_title                => I.project_title
      ,c_vendor_assignment_number     => I.vendor_assignment_number
      ,c_vendor_employee_number       => I.vendor_employee_number
      ,c_vendor_id                    => I.vendor_id
     ) then
      -- all the attributes have been processed, exit the loop
      exit;
    end if;
  end loop;
  -- ------------------------------------------------------------------------
  -- process any past row(s)
  if p_attribute_update_mode = 'ATTRIBUTE_CORRECTION' then
    -- reset the parameter statuses
    hr_dt_attribute_support.reset_parameter_statuses;
    for I in csr_asg2 loop
      if not process_row
      (c_effective_start_date         => I.effective_start_date
      ,c_object_version_number        => I.object_version_number
      ,c_supervisor_id                => I.supervisor_id
      -- Assignment Security
      ,c_supervisor_assignment_id     => I.supervisor_assignment_id
      ,c_assignment_number            => I.assignment_number
      ,c_change_reason                => I.change_reason
      ,c_comments                     => I.comment_text
      ,c_date_probation_end           => I.date_probation_end
      ,c_default_code_comb_id         => I.default_code_comb_id
      ,c_frequency                    => I.frequency
      ,c_internal_address_line        => I.internal_address_line
      ,c_manager_flag                 => I.manager_flag
      ,c_normal_hours                 => I.normal_hours
      ,c_perf_review_period           => I.perf_review_period
      ,c_perf_review_period_frequency => I.perf_review_period_frequency
      ,c_probation_period             => I.probation_period
      ,c_probation_unit               => I.probation_unit
      ,c_sal_review_period            => I.sal_review_period
      ,c_sal_review_period_frequency  => I.sal_review_period_frequency
      ,c_set_of_books_id              => I.set_of_books_id
      ,c_source_type                  => I.source_type
      ,c_time_normal_finish           => I.time_normal_finish
      ,c_time_normal_start            => I.time_normal_start
      ,c_ass_attribute_category       => I.ass_attribute_category
      ,c_ass_attribute1               => I.ass_attribute1
      ,c_ass_attribute2               => I.ass_attribute2
      ,c_ass_attribute3               => I.ass_attribute3
      ,c_ass_attribute4               => I.ass_attribute4
      ,c_ass_attribute5               => I.ass_attribute5
      ,c_ass_attribute6               => I.ass_attribute6
      ,c_ass_attribute7               => I.ass_attribute7
      ,c_ass_attribute8               => I.ass_attribute8
      ,c_ass_attribute9               => I.ass_attribute9
      ,c_ass_attribute10              => I.ass_attribute10
      ,c_ass_attribute11              => I.ass_attribute11
      ,c_ass_attribute12              => I.ass_attribute12
      ,c_ass_attribute13              => I.ass_attribute13
      ,c_ass_attribute14              => I.ass_attribute14
      ,c_ass_attribute15              => I.ass_attribute15
      ,c_ass_attribute16              => I.ass_attribute16
      ,c_ass_attribute17              => I.ass_attribute17
      ,c_ass_attribute18              => I.ass_attribute18
      ,c_ass_attribute19              => I.ass_attribute19
      ,c_ass_attribute20              => I.ass_attribute20
      ,c_ass_attribute21              => I.ass_attribute21
      ,c_ass_attribute22              => I.ass_attribute22
      ,c_ass_attribute23              => I.ass_attribute23
      ,c_ass_attribute24              => I.ass_attribute24
      ,c_ass_attribute25              => I.ass_attribute25
      ,c_ass_attribute26              => I.ass_attribute26
      ,c_ass_attribute27              => I.ass_attribute27
      ,c_ass_attribute28              => I.ass_attribute28
      ,c_ass_attribute29              => I.ass_attribute29
      ,c_ass_attribute30              => I.ass_attribute30
      ,c_title                        => I.title
      ,c_project_title                => I.project_title
      ,c_vendor_assignment_number     => I.vendor_assignment_number
      ,c_vendor_employee_number       => I.vendor_employee_number
      ,c_vendor_id                    => I.vendor_id
      ) then
        -- all the attributes have been processed, exit the loop
        exit;
      end if;
    end loop;
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  -- set the warning OUT parameters
  p_no_managers_warning      := l_api_no_managers_warning;
  p_other_manager_warning    := l_api_other_manager_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_asg;
    -- reset IN OUT parameters to original IN value
    p_object_version_number    := p_object_version_number;
    -- reset non-warning OUT parameters to NULL
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_comment_id               := null;
    -- set warning OUT parameters to REAL value
    p_no_managers_warning      := l_api_no_managers_warning;
    p_other_manager_warning    := l_api_other_manager_warning;

 when others then
    p_object_version_number    := lv_object_version_number;
    -- reset  OUT parameters to NULL
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_comment_id               := null;
    p_no_managers_warning      := null;
    p_other_manager_warning    := null;

    RAISE;
--
end update_asg;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_asg_criteria >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_asg_criteria
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_attribute_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_employment_category          in     varchar2 default hr_api.g_varchar2
  ,p_assignment_type              in     varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  )  is
  l_proc                     varchar2(72)  := g_package||'update_asg_criteria';
  l_effective_date           date          := trunc(p_effective_date);
  l_constant_effective_date  constant date := l_effective_date;
  l_effective_date_row       boolean       := true;
  l_validation_start_date    date;
  l_validation_end_date      date;
  l_datetrack_update_mode    varchar2(30);
  l_correction               boolean;
  l_update                   boolean;
  l_update_override          boolean;
  l_update_change_insert     boolean;
  l_lck_start_date           date;
  --
  lv_object_version_number   number := p_object_version_number;
  lv_special_ceiling_step_id  number := p_special_ceiling_step_id ;
  --
  -- --------------------------------------------------------------------------
  -- local cursor definitions
  -- --------------------------------------------------------------------------
  -- csr_asg_lck  -> locks all the datetracked rows for the specified assignment
  --                 from the specified lock date. this enforces integrity.
  --                 if the datetrack operation is for an ATTRIBUTE_UPDATE
  --                 then only the current and future rows will be locked. if
  --                 the datetrack operation is a ATTRIBUTE_CORRECTION then
  --                 all assignment rows are locked as we cannot guarantee how
  --                 many rows will be changed.
  -- csr_asg1     -> selects assignment details for the current and future rows
  -- csr_asg2     -> selects assignment details in the past in a descending
  --                 order not including the current row as of the effective
  --                 date.
  --
  -- note: the cursors csr_asg1 and csr_asg2 are specifically not merged
  --       because of the of the order by clause
  --
  -- cursor to lock all rows for which the datetrack operation could
  -- operate over
  cursor csr_asg_lck(c_lck_start_date date) is
    select 1
    from   per_all_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    asg.effective_end_date >= c_lck_start_date
    for    update nowait;
  -- select current and future rows
  cursor csr_asg1 is
  select
   asg.object_version_number
  ,asg.grade_id
  ,asg.position_id
  ,asg.job_id
  ,asg.payroll_id
  ,asg.location_id
  ,asg.special_ceiling_step_id
  ,asg.organization_id
  ,asg.pay_basis_id
  ,asg.employment_category
  ,asg.effective_start_date
  ,asg.effective_end_date
  from  per_all_assignments_f asg
  where asg.assignment_id=p_assignment_id
  and   asg.effective_end_date >= l_constant_effective_date
  order by asg.effective_end_date asc;
    -- select past rows not including the current rows
  cursor csr_asg2 is
  select
   asg.object_version_number
  ,asg.grade_id
  ,asg.position_id
  ,asg.job_id
  ,asg.payroll_id
  ,asg.location_id
  ,asg.special_ceiling_step_id
  ,asg.organization_id
  ,asg.pay_basis_id
  ,asg.employment_category
  ,asg.effective_start_date
  ,asg.effective_end_date
  from  per_all_assignments_f asg
  where asg.assignment_id=p_assignment_id
  and   asg.effective_end_date < l_constant_effective_date
  order by asg.effective_end_date desc;
  -- IN parameters for API
  l_asg_rec per_all_assignments_f%rowtype;
  -- OUT parameters for API
  l_people_group_id            number;
  l_group_name                 varchar2(240);
  l_effective_start_date       date;
  l_effective_end_date         date;
  l_concatenated_segments      hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_no_managers_warning        boolean;
  l_other_manager_warning      boolean;
  l_spp_delete_warning         boolean;
  l_entries_changed_warning    varchar2(1);
  l_tax_district_changed_warning boolean;
  l_api_no_managers_warning    boolean := false;
  l_api_other_manager_warning  boolean := false;
  l_api_spp_delete_warning     boolean := false;
  l_api_entries_changed_warning varchar2(1) := '';
  l_api_tax_district_changed   boolean := false;
  --
  -- --------------------------------------------------------------------------
  -- |---------------------------< process_row >------------------------------|
  -- --------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description:
  --   This private function is used to determine the correct attribute values
  --   to pass to the API.
  --
  --   1. Determine the parameter value to be passed to the API
  --   2. If at least one parameter value is changing then call the API
  --      else exit function
  --   3. Set any parameters which have been supplied by the resulting call
  --      to the API
  --
  -- Pre Conditions:
  --   A row must be active from the cursor csr_asg1 or csr_asg2
  --
  -- In Arguments:
  --   All the IN arguments hold the current selected cursor row values.
  --
  -- Post Success:
  --   Ths function will return either TRUE or FALSE.
  --   If TRUE is returned, the row has been processed succesfully and
  --   attributes could possibly still be processed.
  --   If FALSE is returned, the row has been processed succesfully
  --   and all the attributes have been updated as far as possible.
  --
  -- Post Failure:
  --   Exceptions are not handled, just raised.
  --
  -- Developer Implementation Notes:
  --   None
  --
  -- Access Status:
  --   Internal to owning procedure.
  --
  -- {End Of Comments}
  -- --------------------------------------------------------------------------
  function process_row
    (c_effective_start_date         in     date
    ,c_object_version_number        in     number
    ,c_grade_id                     in     number   default hr_api.g_number
    ,c_position_id                  in     number   default hr_api.g_number
    ,c_job_id                       in     number   default hr_api.g_number
    ,c_payroll_id                   in     number   default hr_api.g_number
    ,c_location_id                  in     number   default hr_api.g_number
    ,c_special_ceiling_step_id      in out nocopy number
    ,c_organization_id              in     number   default hr_api.g_number
    ,c_pay_basis_id                 in     number   default hr_api.g_number
    ,c_employment_category          in     varchar2 default hr_api.g_varchar2
)
  return boolean is
    l_proc          varchar2(72)   := g_package||'process_row';
  begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
    -- get the parameter values to pass to the API
    l_asg_rec.grade_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_GRADE_ID'
                              ,p_new_value       => p_grade_id
                              ,p_current_value   => c_grade_id);

    l_asg_rec.position_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_POSITION_ID'
                              ,p_new_value       => p_position_id
                              ,p_current_value   => c_position_id);

    l_asg_rec.job_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_JOB_ID'
                              ,p_new_value       => p_job_id
                              ,p_current_value   => c_job_id);

    l_asg_rec.payroll_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PAYROLL_ID'
                              ,p_new_value       => p_payroll_id
                              ,p_current_value   => c_payroll_id);

    l_asg_rec.location_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_LOCATION_ID'
                              ,p_new_value       => p_location_id
                              ,p_current_value   => c_location_id);

    l_asg_rec.special_ceiling_step_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_SPECIAL_CEILING_STEP_ID'
                              ,p_new_value       => p_special_ceiling_step_id
                              ,p_current_value   => c_special_ceiling_step_id);

    l_asg_rec.organization_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ORGANIZATION_ID'
                              ,p_new_value       => p_organization_id
                              ,p_current_value   => c_organization_id);

    l_asg_rec.pay_basis_id:= hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PAY_BASIS_ID'
                              ,p_new_value       => p_pay_basis_id
                              ,p_current_value   => c_pay_basis_id);

    l_asg_rec.employment_category:= hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_EMPLOYMENT_CATEGORY'
                              ,p_new_value       => p_employment_category
                              ,p_current_value   => c_employment_category);

--
    -- call the API if at least one attribute can be changed
    if hr_dt_attribute_support.is_current_row_changing then
      -- set the object version number and effective date
      if l_effective_date_row then
        -- as we are on the first row, the ovn and effective date should be
        -- set to the parameter specified by the caller
        l_asg_rec.object_version_number := p_object_version_number;
        l_effective_date        := l_constant_effective_date;
      else
        -- as we are not on the first row, set the ovn and effective date
        -- to the ovn and effective date for the row
        l_asg_rec.object_version_number := c_object_version_number;
        l_effective_date        := c_effective_start_date;
      end if;
    if p_assignment_type = 'C' then
      hr_assignment_api.update_cwk_asg_criteria
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_asg_rec.object_version_number
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_people_group_name            => l_group_name
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_people_group_id
      ,p_org_now_no_manager_warning   => l_no_managers_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
      );
    else
      -- call API
    hr_assignment_api.update_emp_asg_criteria
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_asg_rec.object_version_number
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_people_group_id
      ,p_group_name                   => l_group_name
      ,p_org_now_no_manager_warning   => l_no_managers_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
      );
      end if;
      --
      if l_effective_date_row then
        -- reset the first row flag
        l_effective_date_row := false;
        -- set all future row operations to a CORRECTION
        l_datetrack_update_mode := hr_api.g_correction;
        -- set the API out parameters for the first transaction
        p_object_version_number   := l_asg_rec.object_version_number;
        p_special_ceiling_step_id := l_asg_rec.special_ceiling_step_id;
        p_effective_start_date    := l_effective_start_date;
        p_effective_end_date      := l_effective_end_date;
      end if;
      -- determine if the warnings have been set at all
      if l_no_managers_warning and not l_api_no_managers_warning then
        l_api_no_managers_warning := l_no_managers_warning;
      end if;
       if l_other_manager_warning and not l_api_other_manager_warning then
        l_api_other_manager_warning := l_other_manager_warning;
      end if;
      if l_spp_delete_warning and not l_api_spp_delete_warning then
        l_api_spp_delete_warning:=l_spp_delete_warning;
      end if;
      if l_entries_changed_warning is not null
         and l_api_entries_changed_warning is null then
        l_api_entries_changed_warning:=l_entries_changed_warning;
      end if;
      if l_tax_district_changed_warning and not l_api_tax_district_changed then
        l_api_tax_district_changed:=l_tax_district_changed_warning;
      end if;
      hr_utility.set_location(' Leaving:'|| l_proc, 10);
      -- we need to process the next row so return true
      return(true);
    else
      hr_utility.set_location(' Leaving:'|| l_proc, 15);
      -- processing has finished return false
      return(false);
    end if;
  end process_row;
-------------------------------------begin---------------------------------------------
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_asg_criteria;
  end if;
  -- lock the current row for the following two reasons:
  -- a) ensure that the current row exists for the person as of the
  --    specified effective date. we only lock the current row so the
  --    CORRECTION datetrack mode is used
  -- b) to populate the l_validation_start_date which is used
  --    in determining the correct datetrack mode on an update operation
  per_asg_shd.lck
    (p_effective_date        => l_constant_effective_date
    ,p_datetrack_mode        => hr_api.g_correction
    ,p_assignment_id         => p_assignment_id
    ,p_object_version_number => p_object_version_number
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date);
  -- determine the datetrack mode to use
  if p_attribute_update_mode = 'ATTRIBUTE_UPDATE' then
    -- ------------------------------------------------------------------------
    -- step 1: as we are performing an ATTRIBUTE_UPDATE we must determine
    --         the initial datetrack mode to use (UPDATE, CORRECTION or
    --         UPDATE_CHANGE_INSERT)
    --
    --    1.1 - call the assignment datetrack find_dt_upd_modes to determine
    --          all possible allowed datetrack update modes
    --    1.2 - determine the actual datetrack mode to use
    --          the logic is as follows;
    --          if update allowed then select UPDATE as mode
    --          if change insert allowed then select UPDATE_CHANGE_INSERT as
    --          mode
    --          otherwise, select CORRECTION as the mode
    -- ------------------------------------------------------------------------
    -- step 1.1
    per_asg_shd.find_dt_upd_modes
      (p_effective_date       => l_constant_effective_date
      ,p_base_key_value       => p_assignment_id
      ,p_correction           => l_correction
      ,p_update               => l_update
      ,p_update_override      => l_update_override
      ,p_update_change_insert => l_update_change_insert);
    -- step 1.2
    if l_update then
      -- we can do an update
      l_datetrack_update_mode := hr_api.g_update;
    elsif l_update_change_insert then
      -- we can do an update change insert
      l_datetrack_update_mode := hr_api.g_update_change_insert;
    elsif (l_validation_start_date = l_constant_effective_date) and
           l_correction then
      -- we can only perform a correction
      l_datetrack_update_mode := hr_api.g_correction;
    else
      -- we cannot perform an update due to a restriction within the APIs
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    end if;
    -- set lock start date to the effective date
    l_lck_start_date := l_constant_effective_date;
  elsif p_attribute_update_mode = 'ATTRIBUTE_CORRECTION' then
    -- set lock start date to start of time and the datetrack mode
    -- to CORRECTION
    l_lck_start_date := hr_api.g_sot;
    l_datetrack_update_mode := hr_api.g_correction;
  else
    -- the datetrack mode is not an ATTRIBUTE_UPDATE or ATTRIBUTE_CORRECTION
    -- so raise DT invalid mode error
    hr_utility.set_message(801, 'HR_7203_DT_UPD_MODE_INVALID');
    hr_utility.raise_error;
  end if;
  -- lock all assignment rows to ensure integrity. note: this will never fail.
  -- if the assignment doesn't exist (i.e. the assignment_id is invalid) then the
  -- business process will error with the correct error
  open csr_asg_lck(l_lck_start_date);
  close csr_asg_lck;
  -- ------------------------------------------------------------------------
  -- process the current and future row(s)
  -- ------------------------------------------------------------------------
  for I in csr_asg1 loop
    if not process_row
      (c_effective_start_date         => I.effective_start_date
      ,c_object_version_number        => I.object_version_number
      ,c_grade_id                     => I.grade_id
      ,c_position_id                  => I.position_id
      ,c_job_id                       => I.job_id
      ,c_payroll_id                   => I.payroll_id
      ,c_location_id                  => I.location_id
      ,c_special_ceiling_step_id      => I.special_ceiling_step_id
      ,c_organization_id              => I.organization_id
      ,c_pay_basis_id                 => I.pay_basis_id
      ,c_employment_category          => I.employment_category) then
      -- all the attributes have been processed, exit the loop
      exit;
    end if;
  end loop;
  -- ------------------------------------------------------------------------
  -- process any past row(s)
  if p_attribute_update_mode = 'ATTRIBUTE_CORRECTION' then
    -- reset the parameter statuses
    hr_dt_attribute_support.reset_parameter_statuses;
    for I in csr_asg2 loop
      if not process_row
      (c_effective_start_date         => I.effective_start_date
      ,c_object_version_number        => I.object_version_number
      ,c_grade_id                     => I.grade_id
      ,c_position_id                  => I.position_id
      ,c_job_id                       => I.job_id
      ,c_payroll_id                   => I.payroll_id
      ,c_location_id                  => I.location_id
      ,c_special_ceiling_step_id      => I.special_ceiling_step_id
      ,c_organization_id              => I.organization_id
      ,c_pay_basis_id                 => I.pay_basis_id
      ,c_employment_category          => I.employment_category) then
        -- all the attributes have been processed, exit the loop
        exit;
      end if;
    end loop;
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  -- set the warning OUT parameters
  p_no_managers_warning      := l_api_no_managers_warning;
  p_other_manager_warning    := l_api_other_manager_warning;
  p_spp_delete_warning       := l_api_spp_delete_warning;
  p_entries_changed_warning  := l_api_entries_changed_warning;
  p_tax_district_changed_warning := l_api_tax_district_changed;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_asg_criteria;
    -- reset IN OUT parameters to original IN value
    p_object_version_number    := p_object_version_number;
    p_special_ceiling_step_id  := p_special_ceiling_step_id;
    -- reset non-warning OUT parameters to NULL
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    -- set warning OUT parameters to REAL value
    p_no_managers_warning      := l_api_no_managers_warning;
    p_other_manager_warning    := l_api_other_manager_warning;
    p_spp_delete_warning       := l_api_spp_delete_warning;
    p_entries_changed_warning  := l_api_entries_changed_warning;
    p_tax_district_changed_warning := l_api_tax_district_changed;

  when others then
    -- reset IN OUT parameters to original IN value
    p_object_version_number    := lv_object_version_number;
    p_special_ceiling_step_id  := lv_special_ceiling_step_id;
    -- reset OUT parameters to NULL
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_no_managers_warning      := null;
    p_other_manager_warning    := null;
    p_spp_delete_warning       := null;
    p_entries_changed_warning  := null;
    p_tax_district_changed_warning := null;
--
end update_asg_criteria;
--
end hr_assignment_att;

/
