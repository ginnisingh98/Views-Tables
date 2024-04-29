--------------------------------------------------------
--  DDL for Package PAY_GB_AEI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_AEI_API" AUTHID CURRENT_USER as
/* $Header: pyaeigbi.pkh 120.5.12010000.3 2009/02/13 16:31:05 namgoyal ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p45_3>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call insert api for Assignment Extra Info table
-- to create a P45(3) context record for the assignment
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   Boolean  Validate Only flag
--   p_assignment_id                Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_information_type             Yes  Varchar2 Context fo the Assignment
--                                                Extra Info Row
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 Send P45(3) EDI Flag
--   p_aei_information2             No   Varchar2 Previous Tax District
--   p_aei_information3             No   varchar2 Date left prevous employer
--   p_aei_information4             No   Varchar2 Previous Tax Code
--   p_aei_information5             No   Varchar2 Previous Tax Basis
--   p_aei_information6             No   Varchar2 Previous last payment period
--                                                type
--   p_aei_information7             No   Varchar2 Previous last payment period
--
-- Bug 1843915
--   p_aei_information8             No   Varchar2 P45(3) Send EDI flag
-- Bug 6345375
--   p_aei_information9             No   Varchar2 Previous Tax Paid Notified
--   p_aei_information10            No   Varchar2 Not paid between start and next 5th April
--   p_aei_information11            No   Varchar2 Continue Student Loan Deductions
--
-- Post Success:
--
--  GB_P45_3 record will be created for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- GB_P45_3 record will not be created, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
procedure pay_gb_ins_p45_3
  (p_validate                      in     boolean  default false
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
  ,p_aei_information12             in     varchar2 default null -- Bug 6994632 added for Prev Tax Pay Notified
  ,p_object_version_number             out nocopy number
  ,p_assignment_extra_info_id          out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p45_3>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call update api for Assignment Extra Info table
-- to create a P45(3) context record for the assignment
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_extra_info_id     Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 Send P45(3) EDI Flag
--   p_aei_information2             No   Varchar2 Previous Tax District
--   p_aei_information3             No   Varchar2 Date left prevous employer
--   p_aei_information4             No   Varchar2 Previous Tax Code
--   p_aei_information5             No   Varchar2 Previous Tax Basis
--   p_aei_information6             No   Varchar2 Previous last payment period
--                                                type
--   p_aei_information7             No   Varchar2 Previous last payment period
--   p_object_version_number        Yes  Number   Object Version Number
--
-- Bug 1843915
--   p_aei_information8             No   Varchar2 P45(3) Send EDI flag
--
-- Bug 6345375
--   p_aei_information9             No   Varchar2 Previous Tax Paid Notified
--   p_aei_information10            No   Varchar2 Not paid between start and next 5th April
--   p_aei_information11            No   Varchar2 Continue Student Loan Deductions

-- Post Success:
--
--  GB_P45_3 record will be updated for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- GB_P45_3 record will not be updated, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure pay_gb_upd_p45_3
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out nocopy number
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
  ,p_aei_information12             in     varchar2 default null -- Bug 6994632 added for Prev Tax Pay Notified
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p46>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call insert api for Assignment Extra Info table
-- to create a P46 context record for the assignment
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_information_type             Yes  Varchar2 Context fo the Assignment
--                                                Extra Info Row
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 Send P46 EDI Flag
--   p_aei_information2             No   Varchar2 P46 Statement
--   p_aei_information3             No   Varchar2 Flag for Send P46 EDI Flag
--   p_aei_information4             No   Varchar2 Flag for Send P46 Student Loan

--
-- Post Success:
--
--  GB_P46 record will be created for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- GB_P46 record will not be created, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
 /* BUG 1843915 Added parameter p_aei_information3  for
     passing value of P46_SEND_EDI_FlAG */
procedure pay_gb_ins_p46
  (p_validate                      in     boolean  default false
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
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p46>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call update api for Assignment Extra Info table
-- to create a P46 context record for the assignment
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_information_type             Yes  Varchar2 Context fo the Assignment
--                                                Extra Info Row
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 Send P45(3) EDI Flag
--   p_aei_information2             No   Varchar2 Previous Tax District
--   p_aei_information3             No   Varchar2 Flag for Send P46 EDI Flag
--   p_object_version_number        Yes  Number   Object Version Number
--
-- Post Success:
--
--  GB_P46 record will be updated for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- GB_P46 record will not be updated, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
 /* BUG 1843915 Added parameter p_aei_information3  for
     passing value of P46_SEND_EDI_FlAG */
procedure pay_gb_upd_p46
  (p_validate                      in     boolean default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p46_pennot>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call insert api for Assignment Extra Info table
-- to create a P46_PENNOT context record for the assignment
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_information_type             Yes  Varchar2 Context fo the Assignment
--                                                Extra Info Row
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 Send P46_PENNOT EDI Flag
--   p_aei_information2             No   Varchar2 Annual Pension
--   p_aei_information3             No   Varchar2 Date Pension Started
--
-- Bug 1843915
--   p_aei_information4             No   Varchar2 P46 Pennot Send EDI Flag
-- Post Success:
--
--  GB_P46_PENNOT record will be created for assignment
--  New object version number should be returned
--
-- Post Failure:
--
-- GB_P46_PENNOT record will not be created, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure pay_gb_ins_p46_pennot
  (p_validate                      in     boolean  default false
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
  ,p_aei_information10              in     varchar2 default null
  ,p_aei_information11              in     varchar2 default null
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p46_pennot>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call update api for Assignment Extra Info table
-- to create a P46_PENNOT context record for the assignment
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_information_type             Yes  Varchar2 Context fo the Assignment
--                                                Extra Info Row
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 Send P46_PENNOT EDI Flag
--   p_aei_information2             No   Varchar2 Annual Pension
--   p_aei_information3             No   Varchar2 Date Pension Started
--   p_object_version_number        Yes  Number   Object Version Number
--
-- Bug 1843915
--   p_aei_information4             No   Varchar2 P46 Pennot Send EDI Flag

-- Post Success:
--
--  GB_P46 record will be updated for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- GB_P46 record will not be updated, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure pay_gb_upd_p46_pennot
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out nocopy number
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
  ,p_aei_information10              in     varchar2 default null
  ,p_aei_information11              in     varchar2 default null
  );
-----------------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p45_info>-----------------------|
-- --------------------------------------------------------------------------
procedure pay_gb_ins_p45_info
-- {Start Of Comments}
--
-- Description:
-- Interface to call insert api for Assignment Extra Info table
-- to create a GB_P45 context record for the assignment.
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   The ID of the assignment
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_person_id                    Yes  Number   The ID for the Person
--   p_effective_date               Yes  Date     The date used to determine
--                                                the current datetracked row
--                                                for the person and asg.
--   p_aggregated_paye_flag         No   Varchar2 The Flag held on the person
--                                                record to determine whether
--                                                the persons PAYE is aggregated
--   p_information_type             Yes  Varchar2 Context fo the Assignment
--                                                Extra Info Row
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 P45 Issued flag
--   p_aei_information2             No   Varchar2 P45 Marked for print flag
--   p_aei_information3             No   Varchar2 Manual issue date
--   p_aei_information4             No   Varchar2 P45 Override date
--   p_object_version_number        Yes  Number   Object Version Number
--
--
-- Post Success:
--
--  GB_P45 record will be inserted for assignment with the extra information
--     set accordingly. The following OUT parameters are set:
--
--  Name                           Type    Description
--  p_object_version_number        Number  New object version number should be set
--                                         and returned.
--  p_assignment_extra_info_id     Number  The new assignment extra info ID
--                                         as the primary key of the record.
--
-- Post Failure:
--
-- GB_P45 record will not be inserted, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_effective_date                in     date
  ,p_aggregated_paye_flag          in     varchar2 default null
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number
  );
-- -----------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p45_info>-----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Interface to call update api for Assignment Extra Info table
-- to create a GB_P45 context record for the assignment.
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   Boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the record will be
--                                                created in the database.
--   p_assignment_extra_info_id     Yes  Number   Primary Key ID of the
--                                                Assignment Extra Info record.
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_assignment_id                Yes  Number   The ID of the assignment
--   p_person_id                    Yes  Number   The ID for the Person
--   p_effective_date               Yes  Date     The date used to determine
--                                                the current datetracked row
--                                                for the person and asg.
--   p_aggregated_paye_flag         No   Varchar2 The Flag held on the person
--                                                record to determine whether
--                                                the persons PAYE is aggregated
--   p_object_version_number        Yes  Number   Object Version Number
--   p_aei_information_category     No   Varchar2
--   p_aei_information1             No   Varchar2 P45 Issued flag
--   p_aei_information2             No   Varchar2 P45 Marked for print flag
--   p_aei_information3             No   Varchar2 Manual issue date
--   p_aei_information4             No   Varchar2 P45 Override date
--
--
-- Post Success:
--
--  GB_P45 record will be updated for assignment with the extra information
--     set accordingly. The following OUT parameters are set:
--
--  Name                           Type    Description
--  p_object_version_number        Number  increased object version number should be set
--                                         and returned.
--
-- Post Failure:
--
-- GB_P45 record will not be updated, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure pay_gb_upd_p45_info
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_person_id                     in     number
  ,p_effective_date                in     date
  ,p_aggregated_paye_flag          in     varchar2 default null
  ,p_object_version_number         in out nocopy number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  );
--
-- -----------------------------------------------------------------------
-- |-------------------------< pay_gb_del_p45_info>-----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Interface to call delete api for Assignment Extra Info table
-- to delete a GB_P45 context record for the assignment.
--
-- Prerequisites : None
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   Boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the record will be
--                                                created in the database.
--   p_assignment_extra_info_id     Yes  Number   Primary Key ID of the
--                                                Assignment Extra Info record.
--   p_business_group_id            Yes  Number   The ID of the Business Group
--   p_object_version_number        Yes  Number   Object Version Number
--
--
-- Post Success:
--
--  GB_P45 record will be deleted for assignment with the extra information
--     set accordingly.
--
-- Post Failure:
--
-- GB_P45 record will not be deleted, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure pay_gb_del_p45_info
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in     number
  );
--

--P46(Expat):Added API procedures
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p46_expat>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call insert api for Assignment Extra Info table
-- to create a P46(Expat) context record for the assignment
--
-- Prerequisites : None
--
-- Post Success:
--
--  GB_P46_expat record will be created for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- GB_P46_expat record will not be created, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}

procedure pay_gb_ins_p46_expat
  (p_validate                      in     boolean  default false
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
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p46_expat>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Alternative interface to call update api for Assignment Extra Info table
-- to create a P46 context record for the assignment
--
-- Prerequisites : None
--
-- Post Success:
--
--  GB_P46_expat record will be updated for assignment
--  New object version number should be returned
--  p_some_warning returned as null
--
-- Post Failure:
--
-- GB_P46_expat record will not be updated, error messgae will be returned
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--

procedure pay_gb_upd_p46_expat
  (p_validate                      in     boolean default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out nocopy number
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

end pay_gb_aei_api;

/
