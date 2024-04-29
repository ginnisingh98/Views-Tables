--------------------------------------------------------
--  DDL for Package PAY_ACTION_INFORMATION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ACTION_INFORMATION_BK1" AUTHID CURRENT_USER as
/* $Header: pyaifapi.pkh 120.1 2005/10/02 02:29:11 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_action_information_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_action_information_b
  (
   p_action_context_id              in  number
  ,p_action_context_type            in  varchar2
  ,p_tax_unit_id                    in  number
  ,p_jurisdiction_code              in  varchar2
  ,p_source_id                      in  number
  ,p_source_text                    in  varchar2
  ,p_tax_group                      in  varchar2
  ,p_effective_date                 in  date
  ,p_assignment_id                  in  number
  ,p_action_information_category    in  varchar2
  ,p_action_information1            in  varchar2
  ,p_action_information2            in  varchar2
  ,p_action_information3            in  varchar2
  ,p_action_information4            in  varchar2
  ,p_action_information5            in  varchar2
  ,p_action_information6            in  varchar2
  ,p_action_information7            in  varchar2
  ,p_action_information8            in  varchar2
  ,p_action_information9            in  varchar2
  ,p_action_information10           in  varchar2
  ,p_action_information11           in  varchar2
  ,p_action_information12           in  varchar2
  ,p_action_information13           in  varchar2
  ,p_action_information14           in  varchar2
  ,p_action_information15           in  varchar2
  ,p_action_information16           in  varchar2
  ,p_action_information17           in  varchar2
  ,p_action_information18           in  varchar2
  ,p_action_information19           in  varchar2
  ,p_action_information20           in  varchar2
  ,p_action_information21           in  varchar2
  ,p_action_information22           in  varchar2
  ,p_action_information23           in  varchar2
  ,p_action_information24           in  varchar2
  ,p_action_information25           in  varchar2
  ,p_action_information26           in  varchar2
  ,p_action_information27           in  varchar2
  ,p_action_information28           in  varchar2
  ,p_action_information29           in  varchar2
  ,p_action_information30           in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_action_information_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_action_information_a
  (
   p_action_information_id          in  number
  ,p_action_context_id              in  number
  ,p_action_context_type            in  varchar2
  ,p_tax_unit_id                    in  number
  ,p_jurisdiction_code              in  varchar2
  ,p_source_id                      in  number
  ,p_source_text                    in  varchar2
  ,p_tax_group                      in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_assignment_id                  in  number
  ,p_action_information_category    in  varchar2
  ,p_action_information1            in  varchar2
  ,p_action_information2            in  varchar2
  ,p_action_information3            in  varchar2
  ,p_action_information4            in  varchar2
  ,p_action_information5            in  varchar2
  ,p_action_information6            in  varchar2
  ,p_action_information7            in  varchar2
  ,p_action_information8            in  varchar2
  ,p_action_information9            in  varchar2
  ,p_action_information10           in  varchar2
  ,p_action_information11           in  varchar2
  ,p_action_information12           in  varchar2
  ,p_action_information13           in  varchar2
  ,p_action_information14           in  varchar2
  ,p_action_information15           in  varchar2
  ,p_action_information16           in  varchar2
  ,p_action_information17           in  varchar2
  ,p_action_information18           in  varchar2
  ,p_action_information19           in  varchar2
  ,p_action_information20           in  varchar2
  ,p_action_information21           in  varchar2
  ,p_action_information22           in  varchar2
  ,p_action_information23           in  varchar2
  ,p_action_information24           in  varchar2
  ,p_action_information25           in  varchar2
  ,p_action_information26           in  varchar2
  ,p_action_information27           in  varchar2
  ,p_action_information28           in  varchar2
  ,p_action_information29           in  varchar2
  ,p_action_information30           in  varchar2
  );
--
end pay_action_information_bk1;

 

/
