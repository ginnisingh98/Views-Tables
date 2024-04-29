--------------------------------------------------------
--  DDL for Package PQH_PROCESS_LOG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PROCESS_LOG_BK3" AUTHID CURRENT_USER as
/* $Header: pqplgapi.pkh 120.0 2005/05/29 02:16:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_process_log_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_process_log_b
  (
   p_process_log_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_process_log_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_process_log_a
  (
   p_process_log_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_process_log_bk3;

 

/
