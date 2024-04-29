--------------------------------------------------------
--  DDL for Package PQH_PROCESS_LOG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PROCESS_LOG_API" AUTHID CURRENT_USER as
/* $Header: pqplgapi.pkh 120.0 2005/05/29 02:16:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_process_log >------------------------|
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
--   p_module_cd                    Yes  varchar2
--   p_txn_id                       Yes  number
--   p_master_process_log_id        No   number
--   p_message_text                 No   varchar2
--   p_message_type_cd              Yes  varchar2
--   p_batch_status                 No   varchar2
--   p_batch_start_date             No   date
--   p_batch_end_date               No   date
--   p_txn_table_route_id           No   number
--   p_log_context                  No   varchar2
--   p_information_category         No   varchar2
--   p_information1                 No   varchar2
--   p_information2                 No   varchar2
--   p_information3                 No   varchar2
--   p_information4                 No   varchar2
--   p_information5                 No   varchar2
--   p_information6                 No   varchar2
--   p_information7                 No   varchar2
--   p_information8                 No   varchar2
--   p_information9                 No   varchar2
--   p_information10                No   varchar2
--   p_information11                No   varchar2
--   p_information12                No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_process_log_id               Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_process_log
(
   p_validate                       in boolean    default false
  ,p_process_log_id                 out nocopy number
  ,p_module_cd                      in  varchar2  default null
  ,p_txn_id                         in  number    default null
  ,p_master_process_log_id          in  number    default null
  ,p_message_text                   in  varchar2  default null
  ,p_message_type_cd                in  varchar2  default null
  ,p_batch_status                   in  varchar2  default null
  ,p_batch_start_date               in  date      default null
  ,p_batch_end_date                 in  date      default null
  ,p_txn_table_route_id             in  number    default null
  ,p_log_context                    in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_process_log >------------------------|
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
--   p_process_log_id               Yes  number    PK of record
--   p_module_cd                    Yes  varchar2
--   p_txn_id                       Yes  number
--   p_master_process_log_id        No   number
--   p_message_text                 No   varchar2
--   p_message_type_cd              Yes  varchar2
--   p_batch_status                 No   varchar2
--   p_batch_start_date             No   date
--   p_batch_end_date               No   date
--   p_txn_table_route_id           No   number
--   p_log_context                  No   varchar2
--   p_information_category         No   varchar2
--   p_information1                 No   varchar2
--   p_information2                 No   varchar2
--   p_information3                 No   varchar2
--   p_information4                 No   varchar2
--   p_information5                 No   varchar2
--   p_information6                 No   varchar2
--   p_information7                 No   varchar2
--   p_information8                 No   varchar2
--   p_information9                 No   varchar2
--   p_information10                No   varchar2
--   p_information11                No   varchar2
--   p_information12                No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--   p_effective_date          Yes  date       Session Date.
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
procedure update_process_log
  (
   p_validate                       in boolean    default false
  ,p_process_log_id                 in  number
  ,p_module_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_txn_id                         in  number    default hr_api.g_number
  ,p_master_process_log_id          in  number    default hr_api.g_number
  ,p_message_text                   in  varchar2  default hr_api.g_varchar2
  ,p_message_type_cd                in  varchar2  default hr_api.g_varchar2
  ,p_batch_status                   in  varchar2  default hr_api.g_varchar2
  ,p_batch_start_date               in  date      default hr_api.g_date
  ,p_batch_end_date                 in  date      default hr_api.g_date
  ,p_txn_table_route_id             in  number    default hr_api.g_number
  ,p_log_context                    in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_process_log >------------------------|
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
--   p_process_log_id               Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
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
procedure delete_process_log
  (
   p_validate                       in boolean        default false
  ,p_process_log_id                 in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--
end pqh_process_log_api;

 

/
