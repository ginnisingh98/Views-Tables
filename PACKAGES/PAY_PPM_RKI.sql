--------------------------------------------------------
--  DDL for Package PAY_PPM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPM_RKI" AUTHID CURRENT_USER as
/* $Header: pyppmrhi.pkh 120.0.12010000.2 2008/12/05 13:44:17 abanand ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date                 in date
  ,p_validation_start_date          in date
  ,p_validation_end_date            in date
  ,p_personal_payment_method_id     in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_external_account_id            in number
  ,p_assignment_id                  in number
  ,p_org_payment_method_id          in number
  ,p_amount                         in number
  ,p_comment_id                     in number
  ,p_percentage                     in number
  ,p_priority                       in number
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_object_version_number          in number
  ,p_payee_type                     in varchar2
  ,p_payee_id                       in number
  ,p_ppm_information_category       in varchar2
  ,p_ppm_information1               in varchar2
  ,p_ppm_information2               in varchar2
  ,p_ppm_information3               in varchar2
  ,p_ppm_information4               in varchar2
  ,p_ppm_information5               in varchar2
  ,p_ppm_information6               in varchar2
  ,p_ppm_information7               in varchar2
  ,p_ppm_information8               in varchar2
  ,p_ppm_information9               in varchar2
  ,p_ppm_information10              in varchar2
  ,p_ppm_information11              in varchar2
  ,p_ppm_information12              in varchar2
  ,p_ppm_information13              in varchar2
  ,p_ppm_information14              in varchar2
  ,p_ppm_information15              in varchar2
  ,p_ppm_information16              in varchar2
  ,p_ppm_information17              in varchar2
  ,p_ppm_information18              in varchar2
  ,p_ppm_information19              in varchar2
  ,p_ppm_information20              in varchar2
  ,p_ppm_information21              in varchar2
  ,p_ppm_information22              in varchar2
  ,p_ppm_information23              in varchar2
  ,p_ppm_information24              in varchar2
  ,p_ppm_information25              in varchar2
  ,p_ppm_information26              in varchar2
  ,p_ppm_information27              in varchar2
  ,p_ppm_information28              in varchar2
  ,p_ppm_information29              in varchar2
  ,p_ppm_information30              in varchar2
  );
end pay_ppm_rki;

/
