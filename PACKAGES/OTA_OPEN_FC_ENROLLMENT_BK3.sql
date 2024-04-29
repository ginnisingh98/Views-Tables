--------------------------------------------------------
--  DDL for Package OTA_OPEN_FC_ENROLLMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OPEN_FC_ENROLLMENT_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_open_fc_enrollment_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_open_fc_enrollment_b
  ( p_enrollment_id                    in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_open_fc_enrollment_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_open_fc_enrollment_a
  ( p_enrollment_id                    in number,
  p_object_version_number              in number
  );
--
end ota_open_fc_enrollment_bk3;

 

/
