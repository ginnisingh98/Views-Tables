--------------------------------------------------------
--  DDL for Package FF_ARCHIVE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_ARCHIVE_API" AUTHID CURRENT_USER as
/* $Header: ffarcapi.pkh 115.1 2002/12/23 12:55:02 arashid ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                    Global Table Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type context_tab_type is table of varchar2(30) index by binary_integer;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_archive_item >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This Business Process Inserts values into
--              FF_ARCHIVE_ITEMS and FF_ARCHIVE_ITEM_CONTEXTS
--              using the appropriate row handlers, after validating
--              the 'in' parameters.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
/*
P_VALIDATE                            IN          Control Parameter.
P_ARCHIVE_ITEM_ID                        OUT  Y   Primary Key, Gen by sequence.
P_USER_ENTITY_ID                      IN      Y   FK to FF_USER_ENTITIES
P_ARCHIVE_VALUE                       IN      Y   The value to be stored and retrieved
P_ARCHIVE_TYPE                        IN          Used for validation of Assignment/Payroll
                                                  Action ID. DEFAULTS TO 'ASSIGNMENT_ACTION
                                                  _ID'
P_ACTION_ID                           IN      Y   This is either the Assignment or Payroll
                                                  Action ID.
P_LEGISLATION_CODE                    IN      Y   To identify legislative Context names.
P_OBJECT_VERSION_NUMBER                  OUT      Handled by Row handler logic.
P_CONTEXT_NAME1                       IN          This will be translated from the
                                                  Legislative Context name to a core one.
                                                  This may also be a core context name.
P_CONTEXT1                            IN          The Context value.
P_CONTEXT_NAME2                       IN          Legislative or Core Context Name.
P_CONTEXT12                           IN          The Context value.
P_CONTEXT_NAME3                       IN          Legislative or Core Context Name.
P_CONTEXT3                            IN          The Context value.
P_CONTEXT_NAME4                       IN          Legislative or Core Context Name.
P_CONTEXT4                            IN          The Context value.
P_CONTEXT_NAME5                       IN          Legislative or Core Context Name.
P_CONTEXT5                            IN          The Context value.
P_CONTEXT_NAME6                       IN          Legislative or Core Context Name.
P_CONTEXT6                            IN          The Context value.
P_CONTEXT_NAME7                       IN          Legislative or Core Context Name.
P_CONTEXT7                            IN          The Context value.
P_CONTEXT_NAME8                       IN          Legislative or Core Context Name.
P_CONTEXT8                            IN          The Context value.
P_CONTEXT_NAME9                       IN          Legislative or Core Context Name.
P_CONTEXT9                            IN          The Context value.
P_CONTEXT_NAME10                      IN          Legislative or Core Context Name.
P_CONTEXT10                           IN          The Context value.
P_CONTEXT_NAME11                      IN          Legislative or Core Context Name.
P_CONTEXT11                           IN          The Context value.
P_CONTEXT_NAME12                      IN          Legislative or Core Context Name.
P_CONTEXT12                           IN          The Context value.
P_CONTEXT_NAME13                      IN          Legislative or Core Context Name.
P_CONTEXT13                           IN          The Context value.
P_CONTEXT_NAME14                      IN          Legislative or Core Context Name.
P_CONTEXT14                           IN          The Context value.
P_CONTEXT_NAME15                      IN          Legislative or Core Context Name.
P_CONTEXT15                           IN          The Context value.
P_CONTEXT_NAME16                      IN          Legislative or Core Context Name.
P_CONTEXT16                           IN          The Context value.
P_CONTEXT_NAME17                      IN          Legislative or Core Context Name.
P_CONTEXT17                           IN          The Context value.
P_CONTEXT_NAME18                      IN          Legislative or Core Context Name.
P_CONTEXT18                           IN          The Context value.
P_CONTEXT_NAME19                      IN          Legislative or Core Context Name.
P_CONTEXT19                           IN          The Context value.
P_CONTEXT_NAME20                      IN          Legislative or Core Context Name.
P_CONTEXT20                           IN          The Context value.
P_CONTEXT_NAME21                      IN          Legislative or Core Context Name.
P_CONTEXT21                           IN          The Context value.
P_CONTEXT_NAME22                      IN          Legislative or Core Context Name.
P_CONTEXT22                           IN          The Context value.
P_CONTEXT_NAME23                      IN          Legislative or Core Context Name.
P_CONTEXT23                           IN          The Context value.
P_CONTEXT_NAME24                      IN          Legislative or Core Context Name.
P_CONTEXT24                           IN          The Context value.
P_CONTEXT_NAME25                      IN          Legislative or Core Context Name.
P_CONTEXT25                           IN          The Context value.
P_CONTEXT_NAME26                      IN          Legislative or Core Context Name.
P_CONTEXT26                           IN          The Context value.
P_CONTEXT_NAME27                      IN          Legislative or Core Context Name.
P_CONTEXT27                           IN          The Context value.
P_CONTEXT_NAME28                      IN          Legislative or Core Context Name.
P_CONTEXT28                           IN          The Context value.
P_CONTEXT_NAME29                      IN          Legislative or Core Context Name.
P_CONTEXT29                           IN          The Context value.
P_CONTEXT_NAME30                      IN          Legislative or Core Context Name.
P_CONTEXT30                           IN          The Context value.
P_CONTEXT_NAME31                      IN          Legislative or Core Context Name.
P_CONTEXT31                           IN          The Context value.*/
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development.
--
-- {End Of Comments}
--
procedure create_archive_item
  (p_validate                      in     boolean  default false
  ,p_archive_item_id                  out nocopy number
  ,p_user_entity_id                in     number
  ,p_archive_value                 in     varchar2
  ,p_archive_type                  in     varchar2 default 'AAP'
  ,p_action_id                     in     number
  ,p_legislation_code              in     varchar2
  ,p_object_version_number            out nocopy number
  ,p_context_name1                 in     varchar2  default null
  ,p_context1                      in     varchar2  default null
  ,p_context_name2                 in     varchar2  default null
  ,p_context2                      in     varchar2  default null
  ,p_context_name3                 in     varchar2  default null
  ,p_context3                      in     varchar2  default null
  ,p_context_name4                 in     varchar2  default null
  ,p_context4                      in     varchar2  default null
  ,p_context_name5                 in     varchar2  default null
  ,p_context5                      in     varchar2  default null
  ,p_context_name6                 in     varchar2  default null
  ,p_context6                      in     varchar2  default null
  ,p_context_name7                 in     varchar2  default null
  ,p_context7                      in     varchar2  default null
  ,p_context_name8                 in     varchar2  default null
  ,p_context8                      in     varchar2  default null
  ,p_context_name9                 in     varchar2  default null
  ,p_context9                      in     varchar2  default null
  ,p_context_name10                in     varchar2  default null
  ,p_context10                     in     varchar2  default null
  ,p_context_name11                in     varchar2  default null
  ,p_context11                     in     varchar2  default null
  ,p_context_name12                in     varchar2  default null
  ,p_context12                     in     varchar2  default null
  ,p_context_name13                in     varchar2  default null
  ,p_context13                     in     varchar2  default null
  ,p_context_name14                in     varchar2  default null
  ,p_context14                     in     varchar2  default null
  ,p_context_name15                in     varchar2  default null
  ,p_context15                     in     varchar2  default null
  ,p_context_name16                in     varchar2  default null
  ,p_context16                     in     varchar2  default null
  ,p_context_name17                in     varchar2  default null
  ,p_context17                     in     varchar2  default null
  ,p_context_name18                in     varchar2  default null
  ,p_context18                     in     varchar2  default null
  ,p_context_name19                in     varchar2  default null
  ,p_context19                     in     varchar2  default null
  ,p_context_name20                in     varchar2  default null
  ,p_context20                     in     varchar2  default null
  ,p_context_name21                in     varchar2  default null
  ,p_context21                     in     varchar2  default null
  ,p_context_name22                in     varchar2  default null
  ,p_context22                     in     varchar2  default null
  ,p_context_name23                in     varchar2  default null
  ,p_context23                     in     varchar2  default null
  ,p_context_name24                in     varchar2  default null
  ,p_context24                     in     varchar2  default null
  ,p_context_name25                in     varchar2  default null
  ,p_context25                     in     varchar2  default null
  ,p_context_name26                in     varchar2  default null
  ,p_context26                     in     varchar2  default null
  ,p_context_name27                in     varchar2  default null
  ,p_context27                     in     varchar2  default null
  ,p_context_name28                in     varchar2  default null
  ,p_context28                     in     varchar2  default null
  ,p_context_name29                in     varchar2  default null
  ,p_context29                     in     varchar2  default null
  ,p_context_name30                in     varchar2  default null
  ,p_context30                     in     varchar2  default null
  ,p_context_name31                in     varchar2  default null
  ,p_context31                     in     varchar2  default null
  ,p_some_warning                     out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_archive_item >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This procedure updates the archive item from the
--              FF_ARCHIVE_ITEMS table, identifying it by parametered
--              ROWID.
--
--
-- Prerequisites: There must be a row already in FF_ARCHIVE_ITEMS to be updated.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- P_ARCHIVE_ITEM_ID                  Y   IN      PK of FF_ARCHIVE_ITEMS.
-- P_EFFECTIVE_DATE                   Y   IN      Required as validation is against
--                                                a datetracked table.
-- P_VALIDATE                             IN      Control Parameter.
-- P_ARCHIVE_VALUE                    Y   IN      The value to be stored and retrieved
-- P_OBJECT_VERSION_NUMBER                IN OUT  Object Version Number for updates.
-- P_SOME_WARNING                            OUT  Generic warning.
--
-- Post Success: Row updated by row-handler.
--
-- Post Failure: Error raised to form.
--
--
-- Access Status:
--   Internal Development.
--
-- {End Of Comments}
--
procedure update_archive_item
  (p_archive_item_id               in     number
  ,p_effective_date                in     date
  ,p_validate                      in     boolean  default false
  ,p_archive_value                 in     varchar2
  ,p_object_version_number         in out nocopy number
  ,p_some_warning                     out nocopy boolean
  );
--
end ff_archive_api;

 

/
