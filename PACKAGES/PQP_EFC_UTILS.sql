--------------------------------------------------------
--  DDL for Package PQP_EFC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EFC_UTILS" AUTHID CURRENT_USER AS
/* $Header: pqpefutl.pkh 120.1 2005/05/30 00:12:46 rvishwan noship $ */
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
END pqp_efc_utils;

 

/
