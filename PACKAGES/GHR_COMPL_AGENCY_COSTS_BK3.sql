--------------------------------------------------------
--  DDL for Package GHR_COMPL_AGENCY_COSTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPL_AGENCY_COSTS_BK3" AUTHID CURRENT_USER as
/* $Header: ghcstapi.pkh 120.3 2006/10/11 14:13:52 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_agency_costs_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_agency_costs_b
  (p_compl_agency_cost_id          in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_agency_costs_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_agency_costs_a
  (p_compl_agency_cost_id          in     number
  ,p_object_version_number         in     number
  );
--
end ghr_compl_agency_costs_bk3;

 

/
