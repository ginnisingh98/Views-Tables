--------------------------------------------------------
--  DDL for Package PAY_KR_AEI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_AEI_API" AUTHID CURRENT_USER as
/* $Header: pykraei.pkh 115.3 2002/12/11 11:44:16 krapolu noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< ins_yea_tax_break_info>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call insert api for Assignment Extra Info table
-- to create a KR_YEA_TAX_BREAK_INFO context record for the assignment
--
-- Prerequisites : None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   Boolean  Validate Only flag
--   p_assignment_id                Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_information_type             Yes  Varchar2 Context fo the Assignment
--                                                Extra Info Row
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 EFFECTIVE_DATE
--   p_aei_information2             No   Varchar2 HOUSING_LOAN_INTEREST_REPAY
--   p_aei_information3             No   varchar2 STOCK_SAVING
--   p_aei_information4             No   varchar2 LT_STOCK_SAVING
--
-- Post Success:
--
--  KR_YEA_TAX_BREAK_INFO record will be created for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- KR_YEA_TAX_BREAK_INFO record will not be created,
--  error message will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure ins_yea_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_object_version_number             out NOCOPY number
  ,p_assignment_extra_info_id          out NOCOPY number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_yea_tax_break_info>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call update api for Assignment Extra Info table
-- to create a KR_YEA_TAX_BREAK_INFO context record for the assignment
--
-- Prerequisites : None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_extra_info_id     Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 EFFECTIVE_DATE
--   p_aei_information2             No   Varchar2 HOUSING_LOAN_INTEREST_REPAY
--   p_aei_information3             No   Varchar2 STOCK_SAVING
--   p_aei_information4             No   Varchar2 LT_STOCK_SAVING
--   p_object_version_number        Yes  Number   Object Version Number
--
-- Post Success:
--
--  KR_YEA_TAX_BREAK_INFO record will be updated for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- KR_YEA_TAX_BREAK_INFO record will not be updated,
-- error message will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure upd_yea_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  );
--
-- for TAX_EXEM
--
procedure ins_yea_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_object_version_number             out NOCOPY number
  ,p_assignment_extra_info_id          out NOCOPY number
  );
--
procedure upd_yea_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  );
--
-- for SP_TAX_EXEM
--
procedure ins_yea_sp_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_aei_information16             in     varchar2 default null
  ,p_aei_information17             in     varchar2 default null
  ,p_aei_information18             in     varchar2 default null
  ,p_aei_information19             in     varchar2 default null
  ,p_aei_information20             in     varchar2 default null
  ,p_aei_information21             in     varchar2 default null
  ,p_aei_information22             in     varchar2 default null
  ,p_object_version_number             out NOCOPY number
  ,p_assignment_extra_info_id          out NOCOPY number
  );
--
procedure upd_yea_sp_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_aei_information16             in     varchar2 default null
  ,p_aei_information17             in     varchar2 default null
  ,p_aei_information18             in     varchar2 default null
  ,p_aei_information19             in     varchar2 default null
  ,p_aei_information20             in     varchar2 default null
  ,p_aei_information21             in     varchar2 default null
  ,p_aei_information22             in     varchar2 default null
  );
--
-- for DPNTEDUC_TAX_EXEM
--
procedure ins_yea_dpnteduc_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_object_version_number             out NOCOPY number
  ,p_assignment_extra_info_id          out NOCOPY number
  );
--
procedure upd_yea_dpnteduc_tax_exem_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  );
--
-- for FW_TAX_BEAK
--
procedure ins_yea_fw_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_object_version_number             out NOCOPY number
  ,p_assignment_extra_info_id          out NOCOPY number
  );
--
procedure upd_yea_fw_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  );
--
-- for OVS_TAX_BEAK
--
procedure ins_yea_ovs_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_object_version_number             out NOCOPY number
  ,p_assignment_extra_info_id          out NOCOPY number
  );
--
procedure upd_yea_ovs_tax_break_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  );
--
-- for PREV_ER
--
procedure ins_yea_prev_er_info
  (p_validate                      in     boolean  default null
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_object_version_number             out NOCOPY number
  ,p_assignment_extra_info_id          out NOCOPY number
  );

--
procedure upd_yea_prev_er_info
  (p_validate                      in     boolean  default null
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  );
--
procedure chk_date_in_current_year
  (p_session_date                  in     date
  ,p_entry_date                    in     date
  );
end pay_kr_aei_api;

 

/
