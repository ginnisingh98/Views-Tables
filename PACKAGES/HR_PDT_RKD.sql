--------------------------------------------------------
--  DDL for Package HR_PDT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PDT_RKD" AUTHID CURRENT_USER as
/* $Header: hrpdtrhi.pkh 120.1.12010000.1 2008/07/28 03:39:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_person_deployment_id         in number
  ,p_object_version_number_o      in number
  ,p_from_business_group_id_o     in number
  ,p_to_business_group_id_o       in number
  ,p_from_person_id_o             in number
  ,p_to_person_id_o               in number
  ,p_person_type_id_o             in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_deployment_reason_o          in varchar2
  ,p_employee_number_o            in varchar2
  ,p_leaving_reason_o             in varchar2
  ,p_leaving_person_type_id_o     in number
  ,p_permanent_o                  in varchar2
  ,p_status_o                     in varchar2
  ,p_status_change_reason_o       in varchar2
  ,p_status_change_date_o         in date
  ,p_deplymt_policy_id_o          in number
  ,p_organization_id_o            in number
  ,p_location_id_o                in number
  ,p_job_id_o                     in number
  ,p_position_id_o                in number
  ,p_grade_id_o                   in number
  ,p_supervisor_id_o              in number
  ,p_supervisor_assignment_id_o   in number
  ,p_retain_direct_reports_o      in varchar2
  ,p_payroll_id_o                 in number
  ,p_pay_basis_id_o               in number
  ,p_proposed_salary_o            in varchar2
  ,p_people_group_id_o            in number
  ,p_soft_coding_keyflex_id_o     in number
  ,p_assignment_status_type_id_o  in number
  ,p_ass_status_change_reason_o   in varchar2
  ,p_assignment_category_o        in varchar2
  ,p_per_information_category_o   in varchar2
  ,p_per_information1_o           in varchar2
  ,p_per_information2_o           in varchar2
  ,p_per_information3_o           in varchar2
  ,p_per_information4_o           in varchar2
  ,p_per_information5_o           in varchar2
  ,p_per_information6_o           in varchar2
  ,p_per_information7_o           in varchar2
  ,p_per_information8_o           in varchar2
  ,p_per_information9_o           in varchar2
  ,p_per_information10_o          in varchar2
  ,p_per_information11_o          in varchar2
  ,p_per_information12_o          in varchar2
  ,p_per_information13_o          in varchar2
  ,p_per_information14_o          in varchar2
  ,p_per_information15_o          in varchar2
  ,p_per_information16_o          in varchar2
  ,p_per_information17_o          in varchar2
  ,p_per_information18_o          in varchar2
  ,p_per_information19_o          in varchar2
  ,p_per_information20_o          in varchar2
  ,p_per_information21_o          in varchar2
  ,p_per_information22_o          in varchar2
  ,p_per_information23_o          in varchar2
  ,p_per_information24_o          in varchar2
  ,p_per_information25_o          in varchar2
  ,p_per_information26_o          in varchar2
  ,p_per_information27_o          in varchar2
  ,p_per_information28_o          in varchar2
  ,p_per_information29_o          in varchar2
  ,p_per_information30_o          in varchar2
  );
--
end hr_pdt_rkd;

/
