--------------------------------------------------------
--  DDL for Package PAY_CONTRIBUTION_HISTORY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CONTRIBUTION_HISTORY_BK2" AUTHID CURRENT_USER as
/* $Header: pyconapi.pkh 115.1 99/09/30 13:47:38 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Contribution_History_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Contribution_History_b
  (
   p_contr_history_id               in  number
  ,p_person_id                      in  number
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_contr_type                     in  varchar2
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_amt_contr                      in  number
  ,p_max_contr_allowed              in  number
  ,p_includable_comp                in  number
  ,p_tax_unit_id                    in  number
  ,p_source_system                  in  varchar2
  ,p_contr_information_category     in  varchar2
  ,p_contr_information1             in  varchar2
  ,p_contr_information2             in  varchar2
  ,p_contr_information3             in  varchar2
  ,p_contr_information4             in  varchar2
  ,p_contr_information5             in  varchar2
  ,p_contr_information6             in  varchar2
  ,p_contr_information7             in  varchar2
  ,p_contr_information8             in  varchar2
  ,p_contr_information9             in  varchar2
  ,p_contr_information10            in  varchar2
  ,p_contr_information11            in  varchar2
  ,p_contr_information12            in  varchar2
  ,p_contr_information13            in  varchar2
  ,p_contr_information14            in  varchar2
  ,p_contr_information15            in  varchar2
  ,p_contr_information16            in  varchar2
  ,p_contr_information17            in  varchar2
  ,p_contr_information18            in  varchar2
  ,p_contr_information19            in  varchar2
  ,p_contr_information20            in  varchar2
  ,p_contr_information21            in  varchar2
  ,p_contr_information22            in  varchar2
  ,p_contr_information23            in  varchar2
  ,p_contr_information24            in  varchar2
  ,p_contr_information25            in  varchar2
  ,p_contr_information26            in  varchar2
  ,p_contr_information27            in  varchar2
  ,p_contr_information28            in  varchar2
  ,p_contr_information29            in  varchar2
  ,p_contr_information30            in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Contribution_History_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Contribution_History_a
  (
   p_contr_history_id               in  number
  ,p_person_id                      in  number
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_contr_type                     in  varchar2
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_amt_contr                      in  number
  ,p_max_contr_allowed              in  number
  ,p_includable_comp                in  number
  ,p_tax_unit_id                    in  number
  ,p_source_system                  in  varchar2
  ,p_contr_information_category     in  varchar2
  ,p_contr_information1             in  varchar2
  ,p_contr_information2             in  varchar2
  ,p_contr_information3             in  varchar2
  ,p_contr_information4             in  varchar2
  ,p_contr_information5             in  varchar2
  ,p_contr_information6             in  varchar2
  ,p_contr_information7             in  varchar2
  ,p_contr_information8             in  varchar2
  ,p_contr_information9             in  varchar2
  ,p_contr_information10            in  varchar2
  ,p_contr_information11            in  varchar2
  ,p_contr_information12            in  varchar2
  ,p_contr_information13            in  varchar2
  ,p_contr_information14            in  varchar2
  ,p_contr_information15            in  varchar2
  ,p_contr_information16            in  varchar2
  ,p_contr_information17            in  varchar2
  ,p_contr_information18            in  varchar2
  ,p_contr_information19            in  varchar2
  ,p_contr_information20            in  varchar2
  ,p_contr_information21            in  varchar2
  ,p_contr_information22            in  varchar2
  ,p_contr_information23            in  varchar2
  ,p_contr_information24            in  varchar2
  ,p_contr_information25            in  varchar2
  ,p_contr_information26            in  varchar2
  ,p_contr_information27            in  varchar2
  ,p_contr_information28            in  varchar2
  ,p_contr_information29            in  varchar2
  ,p_contr_information30            in  varchar2
  ,p_object_version_number          in  number
  );
--
end pay_Contribution_History_bk2;

 

/
