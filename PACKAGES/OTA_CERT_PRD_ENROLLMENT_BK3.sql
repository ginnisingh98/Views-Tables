--------------------------------------------------------
--  DDL for Package OTA_CERT_PRD_ENROLLMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_PRD_ENROLLMENT_BK3" AUTHID CURRENT_USER as
/* $Header: otcpeapi.pkh 120.6.12010000.2 2008/09/22 11:03:17 pekasi ship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_cert_prd_enrollment_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_cert_prd_enrollment_b
  ( p_cert_prd_enrollment_id           in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cert_prd_enrollment_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cert_prd_enrollment_a
  ( p_cert_prd_enrollment_id           in number,
  p_object_version_number              in number
  );
--
end ota_cert_prd_enrollment_bk3;

/
