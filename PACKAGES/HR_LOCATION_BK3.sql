--------------------------------------------------------
--  DDL for Package HR_LOCATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_BK3" AUTHID CURRENT_USER AS
/* $Header: hrlocapi.pkh 120.2.12010000.3 2009/10/26 12:26:36 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_location_b >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_location_b
(    p_location_id                  IN NUMBER
    ,p_object_version_number        IN NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_location_a >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_location_a
(    p_location_id                  IN NUMBER
    ,p_object_version_number        IN NUMBER
  );
END hr_location_bk3;

/
