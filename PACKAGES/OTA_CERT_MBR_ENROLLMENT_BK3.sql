--------------------------------------------------------
--  DDL for Package OTA_CERT_MBR_ENROLLMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_MBR_ENROLLMENT_BK3" AUTHID CURRENT_USER as
/* $Header: otcmeapi.pkh 120.4 2006/07/13 11:44:44 niarora noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_cert_mbr_enrollment_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_cert_mbr_enrollment_b
  ( p_cert_mbr_enrollment_id           in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cert_mbr_enrollment_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cert_mbr_enrollment_a
  ( p_cert_mbr_enrollment_id           in number,
  p_object_version_number              in number
  );
--
end ota_cert_mbr_enrollment_bk3;

 

/
