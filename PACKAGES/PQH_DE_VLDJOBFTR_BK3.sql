--------------------------------------------------------
--  DDL for Package PQH_DE_VLDJOBFTR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDJOBFTR_BK3" AUTHID CURRENT_USER as
/* $Header: pqftrapi.pkh 120.0 2005/05/29 01:54:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Vldtn_Jobftr_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Vldtn_JobFtr_b
  (p_WRKPLC_VLDTN_JOBFTR_ID         In     Number
  ,p_object_version_number          In     number);

Procedure Delete_Vldtn_JobFtr_a
  (p_WRKPLC_VLDTN_Jobftr_ID         In     Number
  ,p_object_version_number          In     number);

end PQH_DE_VLDJOBFTR_BK3;

 

/
