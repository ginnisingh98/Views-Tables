--------------------------------------------------------
--  DDL for Package PAY_RETRO_STATUS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RETRO_STATUS_LOAD" AUTHID CURRENT_USER as
/* $Header: pyrtsupl.pkh 120.2.12010000.1 2008/11/19 08:58:49 nerao ship $ */

--
-- Global Constants
--
g_update_mode constant varchar2(6):= 'UPDATE';
g_delete_mode constant varchar2(6):= 'DELETE';

--
-- Global Types
--
type t_retro_entry_rec is record
  (element_entry_id          number
  ,reprocess_date            date
  ,retro_component_id        number
  );

type t_retro_entry_tab is table of t_retro_entry_rec
  index by binary_integer;

--
-- ----------------------------------------------------------------------------
-- |----------------------< load_retro_asg_and_entries >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure creates a new unprocessed retro assignment and retro entries.
-- If an unprocessed retro assignment already exists for the assignment, the
-- new retro assignment will supersede the existing one.
--
-- Prerequisites:
--   Please make sure that this procedure is used where the user login
--   information is established so that the WHO columns are populated properly.
--   If this procedure is called from a standalone script, it is advisable to
--   make the following call once before calling this procedure.
--
--     fnd_global.apps_initialize
--       (user_id      => <User ID>
--       ,resp_id      => <Responsibility ID>
--       ,resp_appl_id => <Responsibility Application ID>
--       );
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   Assignment ID.
--   p_reprocess_date               Yes  Date     Reprocess Date of the retro
--                                                assignment. This parameter is
--                                                required when no outstanding
--                                                retro assignment does not
--                                                exist for the assignment.
--                                                The date must be equal to or
--                                                earlier than the earliest
--                                                retro entry reprocess date.
--   p_approval_status              No   Varchar2 Approval Status. If the
--                                                localization rule allows
--                                                multiple status, A (Confirmed
--                                                - Awaiting Processing) or D
--                                                (Deferred) is available.
--                                                Otherwise the value has to be
--                                                P (Included - Awaiting
--                                                Processing).
--
--   p_retro_entry_tab              Yes  Table    Table of retro entry records.
--
--   You can add as many retro entries as you require, but the table index
--   should start with 1. The retro entry record is as follows.
--
--     element_entry_id             Yes  number   Element Entry ID.
--     reprocess_date               Yes  date     Reprocess Date. This parameter
--                                                is required when the equivalent
--                                                retro entry does not exist.
--     retro_component_id           No   number   Retro Component ID.
--
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--   p_retro_assignment_id          Number   Retro Assignment ID
--
-- Post Failure:
--   The procedure will not create or update a retro assignment and raises an
--   error.
--
-- {End Of Comments}
--
procedure load_retro_asg_and_entries
  (p_assignment_id                 in     number
  ,p_reprocess_date                in     date
  ,p_approval_status               in     varchar2 default null
  ,p_retro_entry_tab               in     t_retro_entry_tab
  ,p_retro_assignment_id              out nocopy   number
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------< load_retro_asg_and_entries >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This is an overload version of load_retro_assignment.
-- This procedure creates a new unprocessed retro assignment and retro entries.
-- If an unprocessed retro assignment already exists for the assignment, the
-- new retro assignment will supersede the existing one.
--
-- Prerequisites:
--   Please make sure that this procedure is used where the user login
--   information is established so that the WHO columns are populated properly.
--   If this procedure is called from a standalone script, it is advisable to
--   make the following call once before calling this procedure.
--
--     fnd_global.apps_initialize
--       (user_id      => <User ID>
--       ,resp_id      => <Responsibility ID>
--       ,resp_appl_id => <Responsibility Application ID>
--       );
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   Business Group ID.
--   p_assignment_number            Yes  Varchar2 Assignment Number.
--   p_full_name                    No   Varchar2 Full Name of the person to
--                                                identify the assignment for
--                                                sure.
--   p_reprocess_date               Yes  Date     Reprocess Date of the retro
--                                                assignment. This parameter is
--                                                required when no outstanding
--                                                retro assignment does not
--                                                exist for the assignment.
--                                                The date must be equal to or
--                                                earlier than the earliest
--                                                retro entry reprocess date.
--   p_approval_status              No   Varchar2 Approval Status. If the
--                                                localization rule allows
--                                                multiple status, A (Confirmed
--                                                - Awaiting Processing) or D
--                                                (Deferred) is available.
--                                                Otherwise the value has to be
--                                                P (Included - Awaiting
--                                                Processing).
--
--   p_entry<entry number>_<attribute name> parameters are used for creating
--   a retro entry, hence if either element name or element entry ID is
--   specified for an entry number, corresponding reprocess date must be
--   specified as well. If element entry ID is specified, the value entered
--   for element name will be ignored. If element name is specified without
--   element entry ID, the procedure attempts to find the equivalent element
--   entry, but it will fail if there are more than one entry for the element
--   type and the assignment.
--
--   p_entry1_element_name          No   Varchar2 Element Name.
--   p_entry1_element_entry_id      No   Number   Element Entry ID.
--   p_entry1_reprocess_date        No   Date     Reprocess Date. This parameter
--                                                is required when the equivalent
--                                                retro entry does not exist.
--   p_entry1_component_name        No   Varchar2 Retro Component Name. Also
--                                                known as Recalculation Reason.
--
--   ::::::::::::::::::::::::::
--
--   p_entry15_element_name         No   Varchar2 Element Name.
--   p_entry15_element_entry_id     No   Number   Element Entry ID.
--   p_entry15_reprocess_date       No   Date     Reprocess Date.
--   p_entry15_component_name       No   Varchar2 Retro Component Name. Also
--                                                known as Recalculation Reason.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--   p_retro_assignment_id          Number   Retro Assignment ID
--
-- Post Failure:
--   The procedure will not create or update a retro assignment and raises an
--   error.
--
-- {End Of Comments}
--
procedure load_retro_asg_and_entries
  (p_business_group_id             in     number
  ,p_assignment_number             in     varchar2
  ,p_full_name                     in     varchar2 default null
  ,p_reprocess_date                in     date
  ,p_approval_status               in     varchar2 default null
  --
  ,p_entry1_element_name           in     varchar2 default null
  ,p_entry1_element_entry_id       in     number   default null
  ,p_entry1_reprocess_date         in     date     default null
  ,p_entry1_component_name         in     varchar2 default null
  --
  ,p_entry2_element_name           in     varchar2 default null
  ,p_entry2_element_entry_id       in     number   default null
  ,p_entry2_reprocess_date         in     date     default null
  ,p_entry2_component_name         in     varchar2 default null
  --
  ,p_entry3_element_name           in     varchar2 default null
  ,p_entry3_element_entry_id       in     number   default null
  ,p_entry3_reprocess_date         in     date     default null
  ,p_entry3_component_name         in     varchar2 default null
  --
  ,p_entry4_element_name           in     varchar2 default null
  ,p_entry4_element_entry_id       in     number   default null
  ,p_entry4_reprocess_date         in     date     default null
  ,p_entry4_component_name         in     varchar2 default null
  --
  ,p_entry5_element_name           in     varchar2 default null
  ,p_entry5_element_entry_id       in     number   default null
  ,p_entry5_reprocess_date         in     date     default null
  ,p_entry5_component_name         in     varchar2 default null
  --
  ,p_entry6_element_name           in     varchar2 default null
  ,p_entry6_element_entry_id       in     number   default null
  ,p_entry6_reprocess_date         in     date     default null
  ,p_entry6_component_name         in     varchar2 default null
  --
  ,p_entry7_element_name           in     varchar2 default null
  ,p_entry7_element_entry_id       in     number   default null
  ,p_entry7_reprocess_date         in     date     default null
  ,p_entry7_component_name         in     varchar2 default null
  --
  ,p_entry8_element_name           in     varchar2 default null
  ,p_entry8_element_entry_id       in     number   default null
  ,p_entry8_reprocess_date         in     date     default null
  ,p_entry8_component_name         in     varchar2 default null
  --
  ,p_entry9_element_name           in     varchar2 default null
  ,p_entry9_element_entry_id       in     number   default null
  ,p_entry9_reprocess_date         in     date     default null
  ,p_entry9_component_name         in     varchar2 default null
  --
  ,p_entry10_element_name          in     varchar2 default null
  ,p_entry10_element_entry_id      in     number   default null
  ,p_entry10_reprocess_date        in     date     default null
  ,p_entry10_component_name        in     varchar2 default null
  --
  ,p_entry11_element_name          in     varchar2 default null
  ,p_entry11_element_entry_id      in     number   default null
  ,p_entry11_reprocess_date        in     date     default null
  ,p_entry11_component_name        in     varchar2 default null
  --
  ,p_entry12_element_name          in     varchar2 default null
  ,p_entry12_element_entry_id      in     number   default null
  ,p_entry12_reprocess_date        in     date     default null
  ,p_entry12_component_name        in     varchar2 default null
  --
  ,p_entry13_element_name          in     varchar2 default null
  ,p_entry13_element_entry_id      in     number   default null
  ,p_entry13_reprocess_date        in     date     default null
  ,p_entry13_component_name        in     varchar2 default null
  --
  ,p_entry14_element_name          in     varchar2 default null
  ,p_entry14_element_entry_id      in     number   default null
  ,p_entry14_reprocess_date        in     date     default null
  ,p_entry14_component_name        in     varchar2 default null
  --
  ,p_entry15_element_name          in     varchar2 default null
  ,p_entry15_element_entry_id      in     number   default null
  ,p_entry15_reprocess_date        in     date     default null
  ,p_entry15_component_name        in     varchar2 default null
  --
  ,p_retro_assignment_id              out nocopy   number
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_or_delete_retro_asg >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure updates or deletes an existing unprocessed retro assignment.
-- If the delete mode is selected and the retro assignment is superseding the
-- previous version of retro assignment, this procedure will remove the latest
-- changes and revert it back to the previous state of retro assignment.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   Business Group ID.
--   p_assignment_number            Yes  Varchar2 Assignment Number.
--   p_full_name                    No   Varchar2 Full Name.
--   p_reprocess_date               No   Date     Reprocess Date (for update
--                                                only).
--   p_approval_status              No   Varchar2 Approval Status (for update
--                                                only).
--   p_update_or_delete_mode        No   Varchar2 UPDATE or DELETE.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--
-- Post Failure:
--   The procedure will not update a retro entry and raises an error.
--
-- {End Of Comments}
--
procedure update_or_delete_retro_asg
  (p_business_group_id             in     number
  ,p_assignment_number             in     varchar2
  ,p_full_name                     in     varchar2 default null
  ,p_reprocess_date                in     date     default null
  ,p_approval_status               in     varchar2 default null
  ,p_update_or_delete_mode         in     varchar2 default g_update_mode
  );

--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_reprocess_date >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure is used to update the reprocess date of the system created
-- retro assignments by creating new retro assignment with the new reprocess
-- date and superseding the system created retro assignment with the newly
-- created retro assignment.
--
-- Prerequisites:
--   Please make sure that this procedure is used where the user login
--   information is established so that the WHO columns are populated properly.
--   If this procedure is called from a standalone script, it is advisable to
--   make the following call once before calling this procedure.
--
--     fnd_global.apps_initialize
--       (user_id      => <User ID>
--       ,resp_id      => <Responsibility ID>
--       ,resp_appl_id => <Responsibility Application ID>
--       );
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_number            Yes  varchar2 Assignment Number.
--   p_full_name                    No   Varchar2 Full Name of the person to
--                                                identify the assignment for
--                                                sure.
--   p_reprocess_date               Yes  Date     Reprocess Date of the retro
--                                                assignment. This parameter is
--                                                required when no outstanding
--                                                retro assignment does not
--                                                exist for the assignment.
--                                                The date must be equal to or
--                                                earlier than the earliest
--                                                retro entry reprocess date.
--
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--   p_new_retro_asg_id             Number   Newly created Retro Assignment ID
--
-- Post Failure:
--   The procedure will not create or update a retro assignment and raises an
--   error.
--
-- {End Of Comments}
procedure update_reprocess_date
(p_business_group_id               in     number
  ,p_assignment_number             in     varchar2
  ,p_full_name                     in     varchar2 default null
  ,p_reprocess_date                in     date
  ,p_new_retro_asg_id              out    nocopy number
  );
--
end pay_retro_status_load;

/
