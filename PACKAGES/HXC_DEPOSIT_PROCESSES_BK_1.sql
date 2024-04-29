--------------------------------------------------------
--  DDL for Package HXC_DEPOSIT_PROCESSES_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DEPOSIT_PROCESSES_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchdpapi.pkh 120.0 2005/05/29 05:35:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_deposit_processes_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_deposit_processes_b
  (p_deposit_process_id            in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_time_source_id                in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_deposit_processes_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_deposit_processes_a
  (p_deposit_process_id            in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_time_source_id                in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_deposit_processes_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_deposit_processes_b
  (p_deposit_process_id            in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_time_source_id                in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_deposit_processes_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_deposit_processes_a
  (p_deposit_process_id            in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_time_source_id                in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_deposit_processes_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_deposit_processes_b
  (p_deposit_process_id             in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_deposit_processes_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_deposit_processes_a
  (p_deposit_process_id             in  number
  ,p_object_version_number          in  number
  );
--
end hxc_deposit_processes_bk_1;

 

/
