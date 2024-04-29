--------------------------------------------------------
--  DDL for Package PER_QUA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUA_RKD" AUTHID CURRENT_USER as
/* $Header: pequarhi.pkh 120.0.12010000.1 2008/07/28 05:32:25 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_delete >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure after_delete
  (
  p_qualification_id             in number,
  p_business_group_id_o          in number,
  p_object_version_number_o      in number,
  p_person_id_o                  in number,
  p_title_o                      in varchar2,
  p_grade_attained_o             in varchar2,
  p_status_o                     in varchar2,
  p_awarded_date_o               in date,
  p_fee_o                        in number,
  p_fee_currency_o               in varchar2,
  p_training_completed_amount_o  in number,
  p_reimbursement_arrangements_o in varchar2,
  p_training_completed_units_o   in varchar2,
  p_total_training_amount_o      in number,
  p_start_date_o                 in date,
  p_end_date_o                   in date,
  p_license_number_o             in varchar2,
  p_expiry_date_o                in date,
  p_license_restrictions_o       in varchar2,
  p_projected_completion_date_o  in date,
  p_awarding_body_o              in varchar2,
  p_tuition_method_o             in varchar2,
  p_group_ranking_o              in varchar2,
  p_comments_o                   in varchar2,
  p_qualification_type_id_o      in number,
  p_attendance_id_o              in number,
  p_attribute_category_o         in varchar2,
  p_attribute1_o                 in varchar2,
  p_attribute2_o                 in varchar2,
  p_attribute3_o                 in varchar2,
  p_attribute4_o                 in varchar2,
  p_attribute5_o                 in varchar2,
  p_attribute6_o                 in varchar2,
  p_attribute7_o                 in varchar2,
  p_attribute8_o                 in varchar2,
  p_attribute9_o                 in varchar2,
  p_attribute10_o                in varchar2,
  p_attribute11_o                in varchar2,
  p_attribute12_o                in varchar2,
  p_attribute13_o                in varchar2,
  p_attribute14_o                in varchar2,
  p_attribute15_o                in varchar2,
  p_attribute16_o                in varchar2,
  p_attribute17_o                in varchar2,
  p_attribute18_o                in varchar2,
  p_attribute19_o                in varchar2,
  p_attribute20_o                in varchar2,
	p_qua_information_category_o            in varchar2,
	p_qua_information1_o                    in varchar2,
	p_qua_information2_o                    in varchar2,
	p_qua_information3_o                    in varchar2,
	p_qua_information4_o                    in varchar2,
	p_qua_information5_o                    in varchar2,
	p_qua_information6_o                    in varchar2,
	p_qua_information7_o                    in varchar2,
	p_qua_information8_o                    in varchar2,
	p_qua_information9_o                    in varchar2,
	p_qua_information10_o                   in varchar2,
	p_qua_information11_o                   in varchar2,
	p_qua_information12_o                   in varchar2,
	p_qua_information13_o                   in varchar2,
	p_qua_information14_o                   in varchar2,
	p_qua_information15_o                   in varchar2,
	p_qua_information16_o                   in varchar2,
	p_qua_information17_o                   in varchar2,
	p_qua_information18_o                   in varchar2,
	p_qua_information19_o                   in varchar2,
	p_qua_information20_o                   in varchar2,
  p_professional_body_name_o     in varchar2,
  p_membership_number_o          in varchar2,
  p_membership_category_o        in varchar2,
  p_subscription_payment_meth_o  in varchar2,
  p_party_id_o                  in number
  );
--
end per_qua_rkd;

/
