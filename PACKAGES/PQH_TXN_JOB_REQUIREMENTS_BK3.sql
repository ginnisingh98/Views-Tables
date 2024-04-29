--------------------------------------------------------
--  DDL for Package PQH_TXN_JOB_REQUIREMENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_JOB_REQUIREMENTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqtjrapi.pkh 120.0 2005/05/29 02:48:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_TXN_JOB_REQUIREMENT_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_TXN_JOB_REQUIREMENT_b
  (p_effective_date                 in     date
  ,p_txn_job_requirement_id         in     number
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_TXN_JOB_REQUIREMENT_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_TXN_JOB_REQUIREMENT_a
  (p_effective_date                 in     date
  ,p_txn_job_requirement_id         in     number
  ,p_object_version_number          in     number
  );
--
end PQH_TXN_JOB_REQUIREMENTS_BK3;

 

/
