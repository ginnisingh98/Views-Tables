--------------------------------------------------------
--  DDL for Package PQP_EFC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EFC_INFO" AUTHID CURRENT_USER AS
/* $Header: pqpefinf.pkh 115.2 2004/02/13 10:14:01 tmehra noship $ */
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
END pqp_efc_info;

 

/
