--------------------------------------------------------
--  DDL for Package PAY_AUD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AUD_RKI" AUTHID CURRENT_USER as
/* $Header: pyaudrhi.pkh 120.0 2005/05/29 03:04:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_stat_trans_audit_id         in number
  ,p_transaction_type             in varchar2
  ,p_transaction_subtype          in varchar2
  ,p_transaction_date             in date
  ,p_transaction_effective_date   in date
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_assignment_id                in number
  ,p_source1                      in varchar2
  ,p_source1_type                 in varchar2
  ,p_source2                      in varchar2
  ,p_source2_type                 in varchar2
  ,p_source3                      in varchar2
  ,p_source3_type                 in varchar2
  ,p_source4                      in varchar2
  ,p_source4_type                 in varchar2
  ,p_source5                      in varchar2
  ,p_source5_type                 in varchar2
  ,p_transaction_parent_id        in number
  ,p_audit_information_category   in varchar2
  ,p_audit_information1           in varchar2
  ,p_audit_information2           in varchar2
  ,p_audit_information3           in varchar2
  ,p_audit_information4           in varchar2
  ,p_audit_information5           in varchar2
  ,p_audit_information6           in varchar2
  ,p_audit_information7           in varchar2
  ,p_audit_information8           in varchar2
  ,p_audit_information9           in varchar2
  ,p_audit_information10          in varchar2
  ,p_audit_information11          in varchar2
  ,p_audit_information12          in varchar2
  ,p_audit_information13          in varchar2
  ,p_audit_information14          in varchar2
  ,p_audit_information15          in varchar2
  ,p_audit_information16          in varchar2
  ,p_audit_information17          in varchar2
  ,p_audit_information18          in varchar2
  ,p_audit_information19          in varchar2
  ,p_audit_information20          in varchar2
  ,p_audit_information21          in varchar2
  ,p_audit_information22          in varchar2
  ,p_audit_information23          in varchar2
  ,p_audit_information24          in varchar2
  ,p_audit_information25          in varchar2
  ,p_audit_information26          in varchar2
  ,p_audit_information27          in varchar2
  ,p_audit_information28          in varchar2
  ,p_audit_information29          in varchar2
  ,p_audit_information30          in varchar2
  ,p_title                        in varchar2
  ,p_object_version_number        in number
  );
end pay_aud_rki;

 

/
