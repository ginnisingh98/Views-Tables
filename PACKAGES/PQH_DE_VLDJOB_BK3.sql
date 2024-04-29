--------------------------------------------------------
--  DDL for Package PQH_DE_VLDJOB_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDJOB_BK3" AUTHID CURRENT_USER as
/* $Header: pqwvjapi.pkh 120.0 2005/05/29 03:04:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Vldtn_Job_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Vldtn_Job_b
  (p_WRKPLC_VLDTN_JOB_ID           In     Number
  ,p_object_version_number         In     number);

Procedure Delete_Vldtn_Job_a
  (p_WRKPLC_VLDTN_Job_ID           In     Number
  ,p_object_version_number         In     number);

end PQH_DE_VLDJOB_BK3;

 

/
