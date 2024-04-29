--------------------------------------------------------
--  DDL for Package PQP_GDS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GDS_BK3" AUTHID CURRENT_USER as
/* $Header: pqgdsapi.pkh 120.0 2005/10/28 07:31 rvishwan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_duration_summary_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_duration_summary_b
  (p_gap_duration_summary_id  IN    NUMBER
  ,p_object_version_number          IN    NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_duration_summary_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_duration_summary_a
  (p_gap_duration_summary_id  IN    NUMBER
  ,p_object_version_number          IN    NUMBER
  );
--
end pqp_gds_bk3;

 

/
