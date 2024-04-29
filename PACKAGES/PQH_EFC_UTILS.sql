--------------------------------------------------------
--  DDL for Package PQH_EFC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_EFC_UTILS" AUTHID CURRENT_USER AS
/* $Header: pqhefutl.pkh 120.0 2005/05/29 02:04:16 appldev noship $ */
--

-- ----------------------------------------------------------------------------
-- |---------------------------< get_efc_version >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Determines the latest EFC / minipack version to have been applied.
--
-- ----------------------------------------------------------------------------

FUNCTION get_efc_version RETURN VARCHAR2;

--
END pqh_efc_utils;

 

/
