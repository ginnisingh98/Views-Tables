--------------------------------------------------------
--  DDL for Package HR_PERF_MGMT_PLAN_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERF_MGMT_PLAN_BK5" AUTHID CURRENT_USER as
/* $Header: pepmpapi.pkh 120.2.12010000.3 2010/01/27 15:18:26 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< reverse_publish_plan_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure reverse_publish_plan_b
  (p_plan_id                       in   number
  ,p_object_version_number         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< reverse_publish_plan_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure reverse_publish_plan_a
  (p_plan_id                       in   number
  ,p_object_version_number         in   number
  );
--
end HR_PERF_MGMT_PLAN_BK5;

/
