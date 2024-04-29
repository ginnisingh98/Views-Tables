--------------------------------------------------------
--  DDL for Package PQH_EFC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_EFC_INFO" AUTHID CURRENT_USER AS
/* $Header: pqhefinf.pkh 115.3 2004/02/12 11:16:33 scnair noship $ */
--

-- ----------------------------------------------------------------------------
-- |-------------------------< get_db_version >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Determines the latest minipack version to have been applied.
--
-- ----------------------------------------------------------------------------

FUNCTION get_db_version RETURN VARCHAR2;

--
END pqh_efc_info;

 

/
