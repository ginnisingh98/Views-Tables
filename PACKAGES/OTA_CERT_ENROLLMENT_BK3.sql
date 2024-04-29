--------------------------------------------------------
--  DDL for Package OTA_CERT_ENROLLMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_ENROLLMENT_BK3" AUTHID CURRENT_USER as
/* $Header: otcreapi.pkh 120.7.12010000.2 2009/03/12 12:17:48 psengupt ship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_cert_enrollment_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_cert_enrollment_b
  ( p_cert_enrollment_id               in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cert_enrollment_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cert_enrollment_a
  ( p_cert_enrollment_id               in number,
  p_object_version_number              in number,
  p_person_id                          in number
  );
--
end ota_cert_enrollment_bk3;


/
