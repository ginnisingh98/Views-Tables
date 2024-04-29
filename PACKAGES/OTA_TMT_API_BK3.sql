--------------------------------------------------------
--  DDL for Package OTA_TMT_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TMT_API_BK3" AUTHID CURRENT_USER as
/* $Header: ottmtapi.pkh 120.1 2005/10/02 02:08:25 aroussel $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_measure_b >-----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_measure_b
  (p_tp_measurement_type_id        in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_measure_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_measure_a
  (p_tp_measurement_type_id        in     number
  ,p_object_version_number         in     number
  );
--
end ota_tmt_api_bk3;

 

/
