--------------------------------------------------------
--  DDL for Package HR_EX_EMPLOYEE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EX_EMPLOYEE_BK1" AUTHID CURRENT_USER as
/* $Header: peexeapi.pkh 120.4.12010000.2 2009/04/30 10:46:10 dparthas ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< actual_termination_emp_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_emp_b
    (p_effective_date                in     date
    ,p_period_of_service_id          in     number
    ,p_object_version_number         in     number
    ,p_actual_termination_date       in     date
    ,p_last_standard_process_date    in     date
    ,p_person_type_id                in     number
    ,p_assignment_status_type_id     in     number
    ,p_business_group_id             in     number
    ,p_attribute_category	     in     varchar2
    ,p_attribute1		     in     varchar2
    ,p_attribute2		     in     varchar2
    ,p_attribute3		     in     varchar2
    ,p_attribute4		     in     varchar2
    ,p_attribute5		     in     varchar2
    ,p_attribute6		     in     varchar2
    ,p_attribute7		     in     varchar2
    ,p_attribute8		     in     varchar2
    ,p_attribute9		     in     varchar2
    ,p_attribute10		     in     varchar2
    ,p_attribute11		     in     varchar2
    ,p_attribute12		     in     varchar2
    ,p_attribute13		     in     varchar2
    ,p_attribute14		     in     varchar2
    ,p_attribute15		     in     varchar2
    ,p_attribute16		     in     varchar2
    ,p_attribute17		     in     varchar2
    ,p_attribute18		     in     varchar2
    ,p_attribute19		     in     varchar2
    ,p_attribute20		     in     varchar2
    ,p_pds_information_category      in	    varchar2
    ,p_pds_information1 	     in     varchar2
    ,p_pds_information2 	     in     varchar2
    ,p_pds_information3 	     in     varchar2
    ,p_pds_information4 	     in     varchar2
    ,p_pds_information5 	     in     varchar2
    ,p_pds_information6 	     in     varchar2
    ,p_pds_information7 	     in     varchar2
    ,p_pds_information8 	     in     varchar2
    ,p_pds_information9 	     in     varchar2
    ,p_pds_information10	     in     varchar2
    ,p_pds_information11	     in     varchar2
    ,p_pds_information12	     in     varchar2
    ,p_pds_information13	     in     varchar2
    ,p_pds_information14	     in     varchar2
    ,p_pds_information15	     in     varchar2
    ,p_pds_information16	     in     varchar2
    ,p_pds_information17	     in     varchar2
    ,p_pds_information18	     in     varchar2
    ,p_pds_information19	     in     varchar2
    ,p_pds_information20	     in     varchar2
    ,p_pds_information21	     in     varchar2
    ,p_pds_information22	     in     varchar2
    ,p_pds_information23	     in     varchar2
    ,p_pds_information24	     in     varchar2
    ,p_pds_information25	     in     varchar2
    ,p_pds_information26	     in     varchar2
    ,p_pds_information27	     in     varchar2
    ,p_pds_information28	     in     varchar2
    ,p_pds_information29	     in     varchar2
    ,p_pds_information30	     in     varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< actual_termination_emp_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_emp_a
    (p_effective_date                in     date
    ,p_period_of_service_id          in     number
    ,p_object_version_number         in     number
    ,p_actual_termination_date       in     date
    ,p_last_standard_process_date    in     date
    ,p_person_type_id                in     number
    ,p_assignment_status_type_id     in     number
    ,p_attribute_category	     in     varchar2
    ,p_attribute1		     in     varchar2
    ,p_attribute2		     in     varchar2
    ,p_attribute3		     in     varchar2
    ,p_attribute4		     in     varchar2
    ,p_attribute5		     in     varchar2
    ,p_attribute6		     in     varchar2
    ,p_attribute7		     in     varchar2
    ,p_attribute8		     in     varchar2
    ,p_attribute9		     in     varchar2
    ,p_attribute10		     in     varchar2
    ,p_attribute11		     in     varchar2
    ,p_attribute12		     in     varchar2
    ,p_attribute13		     in     varchar2
    ,p_attribute14		     in     varchar2
    ,p_attribute15		     in     varchar2
    ,p_attribute16		     in     varchar2
    ,p_attribute17		     in     varchar2
    ,p_attribute18		     in     varchar2
    ,p_attribute19		     in     varchar2
    ,p_attribute20		     in     varchar2
    ,p_pds_information_category      in	    varchar2
    ,p_pds_information1 	     in     varchar2
    ,p_pds_information2 	     in     varchar2
    ,p_pds_information3 	     in     varchar2
    ,p_pds_information4 	     in     varchar2
    ,p_pds_information5 	     in     varchar2
    ,p_pds_information6 	     in     varchar2
    ,p_pds_information7 	     in     varchar2
    ,p_pds_information8 	     in     varchar2
    ,p_pds_information9 	     in     varchar2
    ,p_pds_information10	     in     varchar2
    ,p_pds_information11	     in     varchar2
    ,p_pds_information12	     in     varchar2
    ,p_pds_information13	     in     varchar2
    ,p_pds_information14	     in     varchar2
    ,p_pds_information15	     in     varchar2
    ,p_pds_information16	     in     varchar2
    ,p_pds_information17	     in     varchar2
    ,p_pds_information18	     in     varchar2
    ,p_pds_information19	     in     varchar2
    ,p_pds_information20	     in     varchar2
    ,p_pds_information21	     in     varchar2
    ,p_pds_information22	     in     varchar2
    ,p_pds_information23	     in     varchar2
    ,p_pds_information24	     in     varchar2
    ,p_pds_information25	     in     varchar2
    ,p_pds_information26	     in     varchar2
    ,p_pds_information27	     in     varchar2
    ,p_pds_information28	     in     varchar2
    ,p_pds_information29	     in     varchar2
    ,p_pds_information30	     in     varchar2
    ,p_last_std_process_date_out     in     date
    ,p_supervisor_warning            in     boolean
    ,p_event_warning                 in     boolean
    ,p_interview_warning             in     boolean
    ,p_review_warning                in     boolean
    ,p_recruiter_warning             in     boolean
    ,p_asg_future_changes_warning    in     boolean
    ,p_entries_changed_warning       in     varchar2
    ,p_pay_proposal_warning          in     boolean
    ,p_dod_warning                   in     boolean
    ,p_business_group_id             in     number
    ,p_person_id                     in     number
    );
end hr_ex_employee_bk1;

/
