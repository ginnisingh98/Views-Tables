--------------------------------------------------------
--  DDL for Package PQP_EXCEPTION_REPORT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXCEPTION_REPORT_BK3" AUTHID CURRENT_USER as
/* $Header: pqexrapi.pkh 120.0.12010000.2 2008/08/05 13:56:48 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_exception_report_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_exception_report_b
  (p_exception_report_id           in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< delete_exception_report_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_exception_report_a
  (p_exception_report_id           in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in     number
  );
--
end pqp_exception_report_bk3;

/
