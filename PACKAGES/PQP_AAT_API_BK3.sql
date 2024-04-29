--------------------------------------------------------
--  DDL for Package PQP_AAT_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_AAT_API_BK3" AUTHID CURRENT_USER as
/* $Header: pqaatapi.pkh 120.6.12010000.1 2008/07/28 11:07:01 appldev ship $ */
--
-- ---------------------------------------------------------------------------+
-- |-------------------------< delete_assignment_attribute_b >----------------|
-- ---------------------------------------------------------------------------+
--
procedure delete_assignment_attribute_b
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_assignment_attribute_id       in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  );
--
-- ---------------------------------------------------------------------------+
-- |-------------------------< delete_assignment_attribute_a >----------------|
-- ---------------------------------------------------------------------------+
--
procedure delete_assignment_attribute_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_assignment_attribute_id       in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  );
--
end pqp_aat_api_bk3;

/
