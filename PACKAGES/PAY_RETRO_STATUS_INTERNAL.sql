--------------------------------------------------------
--  DDL for Package PAY_RETRO_STATUS_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RETRO_STATUS_INTERNAL" AUTHID CURRENT_USER as
/* $Header: pyrtsbsi.pkh 120.2.12010000.2 2010/02/19 09:37:59 pgongada ship $ */

--
-- Global constants
--

-- Constants for the owner type.
g_user   constant varchar2(10) := 'U'; -- User
g_system constant varchar2(10) := 'S'; -- System

--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_unprocessed_retro_asg >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This function returns the unprocessed retro assignment ID for the specified
-- assignment. If no record is found, this returns null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   Assignment ID.
--
-- Post Success:
--   The procedure will return the following value:
--   Name                           Type     Description
--   N/A                            Number   Retro Assignment ID
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_unprocessed_retro_asg
  (p_assignment_id                 in     number
  ) return number;

--
-- ----------------------------------------------------------------------------
-- |------------------------< create_super_retro_asg >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure creates an unprocessed retro assignment that supersedes
-- an existing unprocessed retro assignment.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   Assignment ID.
--   p_reprocess_date               Yes  Date     Reprocess Date.
--   p_start_date                   Yes  Date     Start Date.
--   p_approval_status              No   Varchar2 Approval Status.
--   p_owner_type                   No   Varchar2 Owner type.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--   p_retro_assignment_id          Number   Retro Assignment ID
--
-- Post Failure:
--   The procedure will not create a retro assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_super_retro_asg
  (p_assignment_id                 in     number
  ,p_reprocess_date                in     date
  ,p_start_date                    in     date     default null
  ,p_approval_status               in     varchar2 default null
  ,p_owner_type                    in     varchar2 default g_user
  ,p_retro_assignment_id              out nocopy   number
  );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_retro_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure updates a retro assignment.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_retro_assignment_id          Yes  Number   Retro Assignment ID.
--   p_reprocess_date               No   Date     Reprocess Date.
--   p_start_date                   No   Date     Start Date.
--   p_approval_status              No   Varchar2 Approval Status.
--   p_owner_type                   No   Varchar2 Owner type.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--
-- Post Failure:
--   The procedure will not update a retro assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_retro_asg
  (p_retro_assignment_id           in     number
  ,p_reprocess_date                in     date     default hr_api.g_date
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_approval_status               in     varchar2 default hr_api.g_varchar2
  ,p_owner_type                    in     varchar2 default g_user
  );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_retro_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure deletes a retro assignment. If the retro assignment is
-- superseding another retro assignment, this procedure will reverse it to
-- the previous version.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_retro_assignment_id          Yes  Number   Retro Assignment ID.
--   p_owner_type                   No   Varchar2 Owner type.
--   p_delete_sys_retro_asg         No   Varchar2 Indicate to delete the
--                                                system create retro asg.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--   p_replaced_retro_asg_id        Number   Retro assignment replaced by
--                                           the deleted retro assignment.
--
-- Post Failure:
--   The procedure will not delete a retro assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_retro_asg
  (p_retro_assignment_id           in     number
  ,p_owner_type                    in     varchar2 default g_user
  ,p_delete_sys_retro_asg          in     varchar2 default 'N'
  ,p_replaced_retro_asg_id            out nocopy   number
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_retro_asg_cascade >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure deletes a retro assignment. If the retro assignment is
-- superseding another retro assignment, all of the previous versions are
-- deleted as well.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_retro_assignment_id          Yes  Number   Retro Assignment ID.
--   p_owner_type                   No   Varchar2 Owner type.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--
-- Post Failure:
--   The procedure will not delete a retro assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_retro_asg_cascade
  (p_retro_assignment_id           in     number
  ,p_owner_type                    in     varchar2 default g_user
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< maintain_retro_entry >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure creates or updates an retro entry for the specified retro
-- assignment.
--
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_retro_assignment_id          Yes  Number   Retro Assignment ID.
--   p_element_entry_id             Yes  Number   Element Entry ID.
--   p_reprocess_date               Yes  Date     Reprocess Date.
--   p_effective_date               No   Date     Effective Date.
--   p_retro_component_id           No   Number   Retro Component ID.
--   p_owner_type                   No   Varchar2 Owner type.
--   p_system_reprocess_date        No   Date     System reprocess date.
--   p_entry_param_name             No   Varchar2 Entry parameter name to
--                                                indicate which entry is
--                                                being processed.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--
-- Post Failure:
--   The procedure will not create or update a retro entry and raises an
--   error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure maintain_retro_entry
  (p_retro_assignment_id           in     number
  ,p_element_entry_id              in     number
  ,p_reprocess_date                in     date
  ,p_effective_date                in     date     default null
  ,p_retro_component_id            in     number   default null
  ,p_owner_type                    in     varchar2 default g_user
  ,p_system_reprocess_date         in     date     default hr_api.g_eot
  ,p_entry_param_name              in     varchar2 default null
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_retro_entry >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure deletes a retro entry.
--
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_retro_assignment_id          Yes  Number   Retro Assignment ID.
--   p_element_entry_id             Yes  Number   Element Entry ID.
--   p_owner_type                   No   Varchar2 Owner type.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--
-- Post Failure:
--   The procedure will not delete a retro entry and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_retro_entry
  (p_retro_assignment_id           in     number
  ,p_element_entry_id              in     number
  ,p_owner_type                    in     varchar2 default g_user
  );
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
--   p_assignment_id                Yes  Number   Assignment ID
--   p_reprocess_date               Yes  Date     Reprocess Date of the retro
--                                                assignment.
--                                                The date must be equal to or
--                                                earlier than the earliest
--                                                retro entry reprocess date.
--   p_owner_type                   No   Varchar2 Owner Type
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
procedure update_reprocess_date(
p_assignment_id in number
,p_reprocess_date in date
,p_owner_type in varchar2 default g_user
,p_retro_asg_id out nocopy number);
--
end pay_retro_status_internal;

/
