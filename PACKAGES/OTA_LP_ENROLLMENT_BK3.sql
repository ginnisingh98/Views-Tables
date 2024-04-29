--------------------------------------------------------
--  DDL for Package OTA_LP_ENROLLMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_ENROLLMENT_BK3" AUTHID CURRENT_USER as
/* $Header: otlpeapi.pkh 120.7 2006/07/12 11:14:59 niarora noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_lp_enrollment_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_lp_enrollment_b
  ( p_lp_enrollment_id                in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_lp_enrollment_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_lp_enrollment_a
  ( p_lp_enrollment_id                in number,
  p_object_version_number              in number
  );
--
end ota_lp_enrollment_bk3;

 

/
