--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_PROCESSES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_PROCESSES_API" AUTHID CURRENT_USER as
/* $Header: hxchrtapi.pkh 120.0 2005/05/29 05:40:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_retrieval_processes >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Retrieval Processes
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
--                                                then a new Retrieval Process
--                                                is created.
--                                                Default is FALSE.
--   p_retrieval_process_id         Yes  number   Primary Key for entity
--   p_name                         Yes  varchar2 Name of the Retrieval Process
--   p_time_recipient_id            Yes  number   ID of the Application to
--                                                which the retrieval process
--                                                is applicable
--   p_mapping_id                   Yes  number   ID of the Mapping Process
--                                                for the Retrieval Process
--                                                i.e foreign key to
--                                                hxc_mappings
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the retrieval process has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_retrieval_process_id         number   Primary key of the new
--                                           retrieval process
--   p_object_version_number        number   Object version number for the
--                                           new retrieval process
--
-- Post Failure:
--
-- The retrieval process will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_retrieval_processes
  (p_validate                      in     boolean  default false
  ,p_retrieval_process_id          in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_time_recipient_id             in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_retrieval_processes>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Retrieval Process
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
--                                                then a retrieval process is
--                                                updated. Default is FALSE.
--   p_retrieval_process_id         Yes  number   Primary Key for entity
--   p_name                         Yes  varchar2 Retrieval Process Name
--   p_time_recipient_id            Yes  number   ID of the Application to
--                                                which the Retrieval Process
--                                                is applicable
--   p_mapping_id                   Yes  number   Id of the Mapping Process
--                                                for the retrieval process
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- when the retrieval process has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated retrieval process
--
-- Post Failure:
--
-- The retrieval process will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_retrieval_processes
  (p_validate                      in     boolean  default false
  ,p_retrieval_process_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_time_recipient_id             in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_retrieval_processes >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing retrieval process
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
--                                                then the retrieval process
--                                                is deleted. Default is FALSE.
--   p_retrieval_process_id         Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the retrieval process has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The retrieval process will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_retrieval_processes
  (p_validate                       in  boolean  default false
  ,p_retrieval_process_id           in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_retrieval_processes_api;

 

/
