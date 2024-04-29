--------------------------------------------------------
--  DDL for Package PAY_PPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPE_API" AUTHID CURRENT_USER as
/* $Header: pyppeapi.pkh 120.1.12010000.1 2008/07/27 23:25:09 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_process_event >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is used to create rows on pay_process_events table.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_assignment_id                No   number   Identifies the assignment
--   p_effective_date               Yes  date     Session Date.
--   p_change_type                  Yes  varchar2 Taken from PROCESS_EVENT_TYPE
--                                                lookup
--   p_status                       Yes  varchar2 Taken from PROCESS_EVENT_STATUS
--                                                lookup
--   p_description                  No   varchar2 Description
--   p_event_update_id              No   number   FK to Pay_Event_Update table.
--   p_org_process_event_group_id   No   number
--   p_business_group_id            No   number   Business Group of the Record.
--   p_surrogate_key                No   varchar2
--   p_calculation_date             No   date
--   p_retroactive_status           No   varchar
--
-- Out Parameters:
--   Name                                Type     Description
--   p_process_event_id                  number   PK of record
--   p_object_version_number             number   OVN of record
--
-- Post Failure:
--   1) If the change type argument is not a recognisable value for the lookup
--      type PROCESS_EVENT_TYPE, then raise error HR_xxxx_INVALID_EVENT_TYPE.
--   2) If the status argument is not a recognisable value for the lookup
--      type PROCESS_EVENT_STATUS, then raise error HR_xxxx_INVALID_STATUS_TYPE.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_process_event
  (
   p_validate                       in     boolean   default false
  ,p_assignment_id                  in     number    default null
  ,p_effective_date                 in     date
  ,p_change_type                    in     varchar2
  ,p_status                         in     varchar2
  ,p_description                    in     varchar2   default null
  ,p_process_event_id                  out nocopy     number
  ,p_object_version_number             out nocopy     number
  ,p_event_update_id                in     number     default null
  ,p_org_process_event_group_id     in     number     default null
  ,p_business_group_id              in     number     default null
  ,p_surrogate_key                  in     varchar2   default null
  ,p_calculation_date               in     date       default null
  ,p_retroactive_status             in     varchar2   default null
  ,p_noted_value                    in     varchar2   default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------<update_process_event >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates an existing row on pay_process_events table.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_process_event_id             Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_assignment_id                No   number   Identifies the assignment
--   p_effective_date               No   date     Session Date.
--   p_change_type                  No   varchar2 Taken from PROCESS_EVENT_TYPE
--                                                lookup
--   p_status                       No   varchar2 Taken from PROCESS_EVENT_STATUS
--                                                lookup
--   p_description                  No    varchar2 Description
--   p_event_update_id              No   number   FK to Pay_Event_Update table.
--   p_org_process_event_group_id   No   number
--   p_business_group_id            No   number   Business Group of the Record.
--   p_surrogate_key                No   varchar2
--   p_calculation_date             No   date
--   p_retroactive_status           No   varchar
--
-- Out Parameters:
--   Name                                Type     Description
--   p_object_version_number             number   OVN of record
--
-- Post Failure:
--   1) If the change type argument is not a recognisable value for the lookup
--      type PROCESS_EVENT_TYPE, then raise error HR_xxxx_INVALID_EVENT_TYPE.
--   2) If the status argument is not a recognisable value for the lookup
--      type PROCESS_EVENT_STATUS, then raise error HR_xxxx_INVALID_STATUS_TYPE.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_process_event
  (
   p_validate                       in     boolean default false
  ,p_process_event_id             in     number
  ,p_object_version_number        in out nocopy    number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_change_type                  in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_event_update_id              in     number    default hr_api.g_number
  ,p_org_process_event_group_id   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_surrogate_key                in     varchar2  default hr_api.g_varchar2
  ,p_calculation_date             in     date      default hr_api.g_date
  ,p_retroactive_status           in     varchar2  default hr_api.g_varchar2
  ,p_noted_value                  in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_process_event >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API deletes an existing row on pay_event_updates table.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                      Reqd Type      Description/Valid Values
--   p_validate                Yes  boolean   Commit or Rollback.
--                                            FALSE(default) or TRUE
--   p_process_event_id        Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_process_event
  (
   p_validate                       in     boolean default false
  ,p_process_event_id                     in     number
  ,p_object_version_number                in     number
  );
end pay_ppe_api;

/
