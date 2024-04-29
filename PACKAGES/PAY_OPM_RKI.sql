--------------------------------------------------------
--  DDL for Package PAY_OPM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_OPM_RKI" AUTHID CURRENT_USER as
/* $Header: pyopmrhi.pkh 120.1 2005/08/30 07:52:36 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_org_payment_method_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_external_account_id          in number
  ,p_currency_code                in varchar2
  ,p_payment_type_id              in number
  ,p_defined_balance_id           in number
  ,p_org_payment_method_name      in varchar2
  ,p_comment_id                   in number
  ,p_comments                     in varchar2
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_pmeth_information_category   in varchar2
  ,p_pmeth_information1           in varchar2
  ,p_pmeth_information2           in varchar2
  ,p_pmeth_information3           in varchar2
  ,p_pmeth_information4           in varchar2
  ,p_pmeth_information5           in varchar2
  ,p_pmeth_information6           in varchar2
  ,p_pmeth_information7           in varchar2
  ,p_pmeth_information8           in varchar2
  ,p_pmeth_information9           in varchar2
  ,p_pmeth_information10          in varchar2
  ,p_pmeth_information11          in varchar2
  ,p_pmeth_information12          in varchar2
  ,p_pmeth_information13          in varchar2
  ,p_pmeth_information14          in varchar2
  ,p_pmeth_information15          in varchar2
  ,p_pmeth_information16          in varchar2
  ,p_pmeth_information17          in varchar2
  ,p_pmeth_information18          in varchar2
  ,p_pmeth_information19          in varchar2
  ,p_pmeth_information20          in varchar2
  ,p_object_version_number        in number
  ,p_transfer_to_gl_flag          in varchar2
  ,p_cost_payment                 in varchar2
  ,p_cost_cleared_payment         in varchar2
  ,p_cost_cleared_void_payment    in varchar2
  ,p_exclude_manual_payment       in varchar2
  );
end pay_opm_rki;

 

/
