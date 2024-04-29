--------------------------------------------------------
--  DDL for Package HR_LOCATION_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_BK7" AUTHID CURRENT_USER AS
/* $Header: hrlocapi.pkh 120.2.12010000.3 2009/10/26 12:26:36 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< disable_location_legal_adr_b >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE disable_location_legal_adr_b
  (     p_effective_date                 IN  DATE,
        p_location_id                    IN  NUMBER,
        p_object_version_number          IN  NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< disable_location_legal_adr_a  >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE disable_location_legal_adr_a
  (     p_effective_date                 IN  DATE,
        p_location_id                    IN  NUMBER,
        p_object_version_number          IN  NUMBER
  );
END hr_location_bk7;
--

/
