--------------------------------------------------------
--  DDL for Package PAY_CONTRIBUTION_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CONTRIBUTION_HISTORY_API" AUTHID CURRENT_USER as
/* $Header: pyconapi.pkh 115.1 99/09/30 13:47:38 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Contribution_History >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_person_id                    Yes  number
--   p_date_from                    Yes  date
--   p_date_to                      Yes  date
--   p_contr_type                   Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             Yes  varchar2
--   p_amt_contr                    No   number
--   p_max_contr_allowed            No   number
--   p_includable_comp              No   number
--   p_tax_unit_id                  No   number
--   p_source_system                No   varchar2
--   p_contr_information_category   No   varchar2
--   p_contr_information1           No   varchar2
--   p_contr_information2           No   varchar2
--   p_contr_information3           No   varchar2
--   p_contr_information4           No   varchar2
--   p_contr_information5           No   varchar2
--   p_contr_information6           No   varchar2
--   p_contr_information7           No   varchar2
--   p_contr_information8           No   varchar2
--   p_contr_information9           No   varchar2
--   p_contr_information10          No   varchar2
--   p_contr_information11          No   varchar2
--   p_contr_information12          No   varchar2
--   p_contr_information13          No   varchar2
--   p_contr_information14          No   varchar2
--   p_contr_information15          No   varchar2
--   p_contr_information16          No   varchar2
--   p_contr_information17          No   varchar2
--   p_contr_information18          No   varchar2
--   p_contr_information19          No   varchar2
--   p_contr_information20          No   varchar2
--   p_contr_information21          No   varchar2
--   p_contr_information22          No   varchar2
--   p_contr_information23          No   varchar2
--   p_contr_information24          No   varchar2
--   p_contr_information25          No   varchar2
--   p_contr_information26          No   varchar2
--   p_contr_information27          No   varchar2
--   p_contr_information28          No   varchar2
--   p_contr_information29          No   varchar2
--   p_contr_information30          No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_contr_history_id             Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_Contribution_History
(
   p_validate                       in boolean    default false
  ,p_contr_history_id               out number
  ,p_person_id                      in  number    default null
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_contr_type                     in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_amt_contr                      in  number    default null
  ,p_max_contr_allowed              in  number    default null
  ,p_includable_comp                in  number    default null
  ,p_tax_unit_id                    in  number    default null
  ,p_source_system                  in  varchar2  default null
  ,p_contr_information_category     in  varchar2  default null
  ,p_contr_information1             in  varchar2  default null
  ,p_contr_information2             in  varchar2  default null
  ,p_contr_information3             in  varchar2  default null
  ,p_contr_information4             in  varchar2  default null
  ,p_contr_information5             in  varchar2  default null
  ,p_contr_information6             in  varchar2  default null
  ,p_contr_information7             in  varchar2  default null
  ,p_contr_information8             in  varchar2  default null
  ,p_contr_information9             in  varchar2  default null
  ,p_contr_information10            in  varchar2  default null
  ,p_contr_information11            in  varchar2  default null
  ,p_contr_information12            in  varchar2  default null
  ,p_contr_information13            in  varchar2  default null
  ,p_contr_information14            in  varchar2  default null
  ,p_contr_information15            in  varchar2  default null
  ,p_contr_information16            in  varchar2  default null
  ,p_contr_information17            in  varchar2  default null
  ,p_contr_information18            in  varchar2  default null
  ,p_contr_information19            in  varchar2  default null
  ,p_contr_information20            in  varchar2  default null
  ,p_contr_information21            in  varchar2  default null
  ,p_contr_information22            in  varchar2  default null
  ,p_contr_information23            in  varchar2  default null
  ,p_contr_information24            in  varchar2  default null
  ,p_contr_information25            in  varchar2  default null
  ,p_contr_information26            in  varchar2  default null
  ,p_contr_information27            in  varchar2  default null
  ,p_contr_information28            in  varchar2  default null
  ,p_contr_information29            in  varchar2  default null
  ,p_contr_information30            in  varchar2  default null
  ,p_object_version_number          out number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Contribution_History >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_contr_history_id             Yes  number    PK of record
--   p_person_id                    Yes  number
--   p_date_from                    Yes  date
--   p_date_to                      Yes  date
--   p_contr_type                   Yes  varchar2
--   p_business_group_id            Yes  number    Business Group of Record
--   p_legislation_code             Yes  varchar2
--   p_amt_contr                    No   number
--   p_max_contr_allowed            No   number
--   p_includable_comp              No   number
--   p_tax_unit_id                  No   number
--   p_source_system                No   varchar2
--   p_contr_information_category   No   varchar2
--   p_contr_information1           No   varchar2
--   p_contr_information2           No   varchar2
--   p_contr_information3           No   varchar2
--   p_contr_information4           No   varchar2
--   p_contr_information5           No   varchar2
--   p_contr_information6           No   varchar2
--   p_contr_information7           No   varchar2
--   p_contr_information8           No   varchar2
--   p_contr_information9           No   varchar2
--   p_contr_information10          No   varchar2
--   p_contr_information11          No   varchar2
--   p_contr_information12          No   varchar2
--   p_contr_information13          No   varchar2
--   p_contr_information14          No   varchar2
--   p_contr_information15          No   varchar2
--   p_contr_information16          No   varchar2
--   p_contr_information17          No   varchar2
--   p_contr_information18          No   varchar2
--   p_contr_information19          No   varchar2
--   p_contr_information20          No   varchar2
--   p_contr_information21          No   varchar2
--   p_contr_information22          No   varchar2
--   p_contr_information23          No   varchar2
--   p_contr_information24          No   varchar2
--   p_contr_information25          No   varchar2
--   p_contr_information26          No   varchar2
--   p_contr_information27          No   varchar2
--   p_contr_information28          No   varchar2
--   p_contr_information29          No   varchar2
--   p_contr_information30          No   varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_Contribution_History
  (
   p_validate                       in boolean    default false
  ,p_contr_history_id               in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_contr_type                     in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_amt_contr                      in  number    default hr_api.g_number
  ,p_max_contr_allowed              in  number    default hr_api.g_number
  ,p_includable_comp                in  number    default hr_api.g_number
  ,p_tax_unit_id                    in  number    default hr_api.g_number
  ,p_source_system                  in  varchar2  default hr_api.g_varchar2
  ,p_contr_information_category     in  varchar2  default hr_api.g_varchar2
  ,p_contr_information1             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information2             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information3             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information4             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information5             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information6             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information7             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information8             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information9             in  varchar2  default hr_api.g_varchar2
  ,p_contr_information10            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information11            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information12            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information13            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information14            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information15            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information16            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information17            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information18            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information19            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information20            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information21            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information22            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information23            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information24            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information25            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information26            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information27            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information28            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information29            in  varchar2  default hr_api.g_varchar2
  ,p_contr_information30            in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Contribution_History >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_contr_history_id             Yes  number    PK of record
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_Contribution_History
  (
   p_validate                       in boolean        default false
  ,p_contr_history_id               in  number
  ,p_object_version_number          in out number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_contr_history_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_contr_history_id                 in number
   ,p_object_version_number        in number
  );
--
end pay_Contribution_History_api;

 

/
