--------------------------------------------------------
--  DDL for Package GHR_COMPL_AGENCY_COSTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPL_AGENCY_COSTS_BK1" AUTHID CURRENT_USER as
/* $Header: ghcstapi.pkh 120.3 2006/10/11 14:13:52 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_agency_costs_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_agency_costs_b
  (p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_phase                          in     varchar2
  ,p_stage                          in     varchar2
  ,p_category                       in     varchar2
  ,p_amount                         in     number
  ,p_cost_date                      in     date
  ,p_description                    in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_agency_costs_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_agency_costs_a
  (p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_phase                          in     varchar2
  ,p_stage                          in     varchar2
  ,p_category                       in     varchar2
  ,p_amount                         in     number
  ,p_cost_date                      in     date
  ,p_description                    in     varchar2
  ,p_compl_agency_cost_id           in     number
  ,p_object_version_number          in     number
  );
--
end ghr_compl_agency_costs_bk1;

 

/
