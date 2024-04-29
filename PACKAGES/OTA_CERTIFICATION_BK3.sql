--------------------------------------------------------
--  DDL for Package OTA_CERTIFICATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERTIFICATION_BK3" AUTHID CURRENT_USER as
/* $Header: otcrtapi.pkh 120.5 2006/07/14 09:29:45 niarora noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_certification_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_certification_b
  ( p_certification_id                in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_certification_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_certification_a
  ( p_certification_id                in number,
  p_object_version_number              in number
  );
--
end ota_certification_bk3;

 

/
