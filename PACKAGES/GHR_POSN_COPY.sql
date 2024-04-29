--------------------------------------------------------
--  DDL for Package GHR_POSN_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_POSN_COPY" AUTHID CURRENT_USER AS
/* $Header: ghrposcp.pkh 120.0 2005/05/29 03:37:15 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_seq_location >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve location of sequence number in Position Key Flex.
--
-- Prerequisites:
--   Organization Id.
--
-- In Parameters:
--   p_org_id.
--
-- Post Success:
--   Returns segment name of sequence number data item.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--
-- Access Status:
--
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_seq_location
   (p_business_group_id   in NUMBER default NULL)
    return VARCHAR2;
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_max_seq>--------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve the maximum existing sequence value from the Position Key Flexfield
--   where all other segments are the same as position being created.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_segment1 - p_segment30.
--
-- Post Success:
--   Returns max value of existing combination or returns 1.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--
-- Access Status:
--
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_max_seq
   (p_seq_location in VARCHAR2,
    p_business_group_id in NUMBER   default NULL,
    p_segment1    in VARCHAR2 default NULL,
    p_segment2    in VARCHAR2 default NULL,
    p_segment3    in VARCHAR2 default NULL,
    p_segment4    in VARCHAR2 default NULL,
    p_segment5    in VARCHAR2 default NULL,
    p_segment6    in VARCHAR2 default NULL,
    p_segment7    in VARCHAR2 default NULL,
    p_segment8    in VARCHAR2 default NULL,
    p_segment9    in VARCHAR2 default NULL,
    p_segment10    in VARCHAR2 default NULL,
    p_segment11    in VARCHAR2 default NULL,
    p_segment12    in VARCHAR2 default NULL,
    p_segment13    in VARCHAR2 default NULL,
    p_segment14    in VARCHAR2 default NULL,
    p_segment15    in VARCHAR2 default NULL,
    p_segment16    in VARCHAR2 default NULL,
    p_segment17    in VARCHAR2 default NULL,
    p_segment18    in VARCHAR2 default NULL,
    p_segment19    in VARCHAR2 default NULL,
    p_segment20    in VARCHAR2 default NULL,
    p_segment21    in VARCHAR2 default NULL,
    p_segment22    in VARCHAR2 default NULL,
    p_segment23    in VARCHAR2 default NULL,
    p_segment24    in VARCHAR2 default NULL,
    p_segment25    in VARCHAR2 default NULL,
    p_segment26    in VARCHAR2 default NULL,
    p_segment27    in VARCHAR2 default NULL,
    p_segment28    in VARCHAR2 default NULL,
    p_segment29    in VARCHAR2 default NULL,
    p_segment30    in VARCHAR2 default NULL)
  return VARCHAR2;

/*
 This procedure will be called directly from Position Copy Form and will
create both the position and the required children.  Parameters are as per
the Position API with 1 additional for  source position id (position being copied).
*/

procedure create_position_copy
   (p_position_id                   in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         out nocopy number
  ,p_name                           out nocopy varchar2
  ,p_object_version_number          out nocopy number
  ,p_job_id                         in  number
  ,p_organization_id                in  number
  ,p_effective_date                 in  date
  ,p_date_effective                 in  date
  ,p_validate                       in  boolean   default false
  ,p_availability_status_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id            in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id                 in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_max_persons                    in  number    default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default 'NONE'
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_update_source_cd               in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_segment1                       in  varchar2  default null
  ,p_segment2                       in  varchar2  default null
  ,p_segment3                       in  varchar2  default null
  ,p_segment4                       in  varchar2  default null
  ,p_segment5                       in  varchar2  default null
  ,p_segment6                       in  varchar2  default null
  ,p_segment7                       in  varchar2  default null
  ,p_segment8                       in  varchar2  default null
  ,p_segment9                       in  varchar2  default null
  ,p_segment10                      in  varchar2  default null
  ,p_segment11                      in  varchar2  default null
  ,p_segment12                      in  varchar2  default null
  ,p_segment13                      in  varchar2  default null
  ,p_segment14                      in  varchar2  default null
  ,p_segment15                      in  varchar2  default null
  ,p_segment16                      in  varchar2  default null
  ,p_segment17                      in  varchar2  default null
  ,p_segment18                      in  varchar2  default null
  ,p_segment19                      in  varchar2  default null
  ,p_segment20                      in  varchar2  default null
  ,p_segment21                      in  varchar2  default null
  ,p_segment22                      in  varchar2  default null
  ,p_segment23                      in  varchar2  default null
  ,p_segment24                      in  varchar2  default null
  ,p_segment25                      in  varchar2  default null
  ,p_segment26                      in  varchar2  default null
  ,p_segment27                      in  varchar2  default null
  ,p_segment28                      in  varchar2  default null
  ,p_segment29                      in  varchar2  default null
  ,p_segment30                      in  varchar2  default null
  ,p_concat_segments                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  );

--
-- Given a from position id this procedure will create ALL the extra info
-- details associated with the from position id onto the to position id
-- For position copy we will explicity exclude types:
--  GHR_US_POS_MASS_ACTIONS
--  GHR_US_POS_OBLIG

PROCEDURE create_all_posn_ei (p_source_posn_id      IN NUMBER
                             ,p_effective_date      IN DATE
                             ,p_position_id         IN NUMBER
                             ,p_date_effective      IN DATE);
--
-- Given a from position id and information type this procedure will create the extra info
-- details associated with the from position id onto the to position id
PROCEDURE create_posn_ei (p_source_posn_id      IN NUMBER
                         ,p_effective_date      IN DATE
                         ,p_position_id         IN NUMBER
                         ,p_date_effective      IN DATE
                         ,p_info_type           IN VARCHAR2);
--
--
END ghr_posn_copy;


 

/
