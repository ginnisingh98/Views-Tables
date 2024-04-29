--------------------------------------------------------
--  DDL for Package PQH_FYI_NOTIFY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FYI_NOTIFY_API" AUTHID CURRENT_USER as
/* $Header: pqfynapi.pkh 120.0 2005/05/29 01:55:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_fyi_notify >------------------------|
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
--   p_transaction_category_id      Yes  number
--   p_transaction_id               Yes  number
--   p_notification_event_cd        Yes  varchar2
--   p_notified_type_cd             No   varchar2
--   p_notified_name                No   varchar2
--   p_notification_date            No   date
--   p_status                       No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_fyi_notified_id              Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_fyi_notify
(
   p_validate                       in boolean    default false
  ,p_fyi_notified_id                out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_transaction_id                 in  number    default null
  ,p_notification_event_cd          in  varchar2  default null
  ,p_notified_type_cd               in  varchar2  default null
  ,p_notified_name                  in  varchar2  default null
  ,p_notification_date              in  date      default null
  ,p_status                         in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_fyi_notify >------------------------|
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
--   p_fyi_notified_id              Yes  number    PK of record
--   p_transaction_category_id      Yes  number
--   p_transaction_id               Yes  number
--   p_notification_event_cd        Yes  varchar2
--   p_notified_type_cd             No   varchar2
--   p_notified_name                No   varchar2
--   p_notification_date            No   date
--   p_status                       No   varchar2
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
procedure update_fyi_notify
  (
   p_validate                       in boolean    default false
  ,p_fyi_notified_id                in  number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_transaction_id                 in  number    default hr_api.g_number
  ,p_notification_event_cd          in  varchar2  default hr_api.g_varchar2
  ,p_notified_type_cd               in  varchar2  default hr_api.g_varchar2
  ,p_notified_name                  in  varchar2  default hr_api.g_varchar2
  ,p_notification_date              in  date      default hr_api.g_date
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_fyi_notify >------------------------|
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
--   p_fyi_notified_id              Yes  number    PK of record
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
procedure delete_fyi_notify
  (
   p_validate                       in boolean        default false
  ,p_fyi_notified_id                in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--
end pqh_fyi_notify_api;

 

/
