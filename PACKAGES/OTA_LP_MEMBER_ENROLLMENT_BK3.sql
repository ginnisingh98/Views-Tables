--------------------------------------------------------
--  DDL for Package OTA_LP_MEMBER_ENROLLMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_MEMBER_ENROLLMENT_BK3" AUTHID CURRENT_USER as
/* $Header: otlmeapi.pkh 120.1.12010000.3 2009/05/27 13:15:43 pekasi ship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_lp_member_enrollment_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_lp_member_enrollment_b
  ( p_lp_member_enrollment_id                in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_lp_member_enrollment_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lp_member_enrollment_a
  ( p_lp_member_enrollment_id                in number,
  p_object_version_number              in number
  );
--
end ota_lp_member_enrollment_bk3;

/
