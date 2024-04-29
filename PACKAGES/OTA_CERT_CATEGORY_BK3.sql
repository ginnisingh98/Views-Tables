--------------------------------------------------------
--  DDL for Package OTA_CERT_CATEGORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_CATEGORY_BK3" AUTHID CURRENT_USER as
/* $Header: otcciapi.pkh 120.3 2006/07/14 11:09:51 niarora noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< delete_cert_cat_inclusion_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_cert_cat_inclusion_b
  ( p_certification_id                in number,
  p_category_usage_id                    in number,
  p_object_version_number              in number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cert_cat_inclusion_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cert_cat_inclusion_a
  ( p_certification_id                in number,
  p_category_usage_id                    in number,
  p_object_version_number              in number
  );
--
end ota_cert_category_bk3;

 

/
