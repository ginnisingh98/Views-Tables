--------------------------------------------------------
--  DDL for Package PAY_AUD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AUD_RKD" AUTHID CURRENT_USER as
/* $Header: pyaudrhi.pkh 120.0 2005/05/29 03:04:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_stat_trans_audit_id         in number
  ,p_transaction_type_o           in varchar2
  ,p_transaction_subtype_o        in varchar2
  ,p_transaction_date_o           in date
  ,p_transaction_effective_date_o in date
  ,p_business_group_id_o          in number
  ,p_person_id_o                  in number
  ,p_assignment_id_o              in number
  ,p_source1_o                    in varchar2
  ,p_source1_type_o               in varchar2
  ,p_source2_o                    in varchar2
  ,p_source2_type_o               in varchar2
  ,p_source3_o                    in varchar2
  ,p_source3_type_o               in varchar2
  ,p_source4_o                    in varchar2
  ,p_source4_type_o               in varchar2
  ,p_source5_o                    in varchar2
  ,p_source5_type_o               in varchar2
  ,p_transaction_parent_id_o      in number
  ,p_audit_information_category_o in varchar2
  ,p_audit_information1_o         in varchar2
  ,p_audit_information2_o         in varchar2
  ,p_audit_information3_o         in varchar2
  ,p_audit_information4_o         in varchar2
  ,p_audit_information5_o         in varchar2
  ,p_audit_information6_o         in varchar2
  ,p_audit_information7_o         in varchar2
  ,p_audit_information8_o         in varchar2
  ,p_audit_information9_o         in varchar2
  ,p_audit_information10_o        in varchar2
  ,p_audit_information11_o        in varchar2
  ,p_audit_information12_o        in varchar2
  ,p_audit_information13_o        in varchar2
  ,p_audit_information14_o        in varchar2
  ,p_audit_information15_o        in varchar2
  ,p_audit_information16_o        in varchar2
  ,p_audit_information17_o        in varchar2
  ,p_audit_information18_o        in varchar2
  ,p_audit_information19_o        in varchar2
  ,p_audit_information20_o        in varchar2
  ,p_audit_information21_o        in varchar2
  ,p_audit_information22_o        in varchar2
  ,p_audit_information23_o        in varchar2
  ,p_audit_information24_o        in varchar2
  ,p_audit_information25_o        in varchar2
  ,p_audit_information26_o        in varchar2
  ,p_audit_information27_o        in varchar2
  ,p_audit_information28_o        in varchar2
  ,p_audit_information29_o        in varchar2
  ,p_audit_information30_o        in varchar2
  ,p_title_o                      in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_aud_rkd;

 

/
