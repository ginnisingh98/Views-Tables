--------------------------------------------------------
--  DDL for Package HXC_DEPOSIT_PROCESSES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DEPOSIT_PROCESSES_API" AUTHID CURRENT_USER as
/* $Header: hxchdpapi.pkh 120.0 2005/05/29 05:35:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_deposit_processes >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Deposit Processes
--
-- Prerequisites:
--
-- None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a new Deposit Process
--                                                is created.
--                                                Default is FALSE.
--   p_deposit_process_id           Yes  number   Primary Key for entity
--   p_name                         Yes  varchar2 Name of the Deposit Process
--   p_time_source_id               Yes  number   ID of the Source to
--                                                which the deposit process
--                                                is applicable
--   p_mapping_id                   Yes  number   ID of the Mapping Process
--                                                for the Deposit Process
--                                                i.e foreign key to
--                                                hxc_mappings
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the deposit process has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_deposit_process_id           number   Primary key of the new
--                                           deposit process
--   p_object_version_number        number   Object version number for the
--                                           new deposit process
--
-- Post Failure:
--
-- The deposit process will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_deposit_processes
  (p_validate                      in     boolean  default false
  ,p_deposit_process_id            in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_time_source_id                in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_deposit_processes>------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Deposit Process
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a deposit process is
--                                                updated. Default is FALSE.
--   p_deposit_process_id           Yes  number   Primary Key for entity
--   p_name                         Yes  varchar2 Deposit Process Name
--   p_time_source_id               Yes  number   ID of the Source to
--                                                which the Deposit Process
--                                                is applicable
--   p_mapping_id                   Yes  number   Id of the Mapping Process
--                                                for the deposit process
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- when the deposit process has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated deposit process
--
-- Post Failure:
--
-- The deposit process will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_deposit_processes
  (p_validate                      in     boolean  default false
  ,p_deposit_process_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_time_source_id                in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_deposit_processes >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing deposit process
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the deposit process
--                                                is deleted. Default is FALSE.
--   p_deposit_process_id           Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the deposit process has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The deposit process will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_deposit_processes
  (p_validate                       in  boolean  default false
  ,p_deposit_process_id             in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_deposit_processes_api;

 

/
