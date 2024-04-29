--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_PROCESSES_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_PROCESSES_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchrtapi.pkh 120.0 2005/05/29 05:40:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_retrieval_processes_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_processes_b
  (p_retrieval_process_id          in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_time_recipient_id             in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_retrieval_processes_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_processes_a
  (p_retrieval_process_id          in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_time_recipient_id             in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_retrieval_processes_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_processes_b
  (p_retrieval_process_id          in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_time_recipient_id             in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_retrieval_processes_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_processes_a
  (p_retrieval_process_id          in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_time_recipient_id             in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_retrieval_processes_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_processes_b
  (p_retrieval_process_id           in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_retrieval_processes_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_processes_a
  (p_retrieval_process_id           in  number
  ,p_object_version_number          in  number
  );
--
end hxc_retrieval_processes_bk_1;

 

/
