--------------------------------------------------------
--  DDL for Package OTA_CERT_MEMBER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_MEMBER_BK3" AUTHID CURRENT_USER as
/* $Header: otcmbapi.pkh 120.3 2006/07/13 11:48:43 niarora noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_certification_member_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_certification_member_b
  ( p_certification_member_id          in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_certification_member_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_certification_member_a
  ( p_certification_member_id          in number,
  p_object_version_number              in number
  );
--
end ota_cert_member_bk3;

 

/
