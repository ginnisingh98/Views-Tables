--------------------------------------------------------
--  DDL for Package HR_RATE_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_API_BK3" AUTHID CURRENT_USER AS
/* $Header: pypyrapi.pkh 120.1 2005/10/02 02:34:02 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_rate_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_rate_b
  (p_rate_id               IN     NUMBER
  ,p_rate_type             IN     VARCHAR2
  ,p_object_version_number IN     NUMBER
  ,p_effective_date        IN     DATE);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_rate_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_rate_a
  (p_rate_id               IN     NUMBER
  ,p_rate_type             IN     VARCHAR2
  ,p_object_version_number IN     NUMBER
  ,p_effective_date        IN     DATE);
--
END hr_rate_api_bk3;

 

/
