--------------------------------------------------------
--  DDL for Package HR_PERF_MGMT_PLAN_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERF_MGMT_PLAN_BK4" AUTHID CURRENT_USER as
/* $Header: pepmpapi.pkh 120.2.12010000.3 2010/01/27 15:18:26 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< publish_plan_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure publish_plan_b
  (p_effective_date                in   date
  ,p_plan_id                       in   number
  ,p_object_version_number         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< publish_plan_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure publish_plan_a
  (p_effective_date                in   date
  ,p_plan_id                       in   number
  ,p_object_version_number         in   number
  );
--
end HR_PERF_MGMT_PLAN_BK4;

/
