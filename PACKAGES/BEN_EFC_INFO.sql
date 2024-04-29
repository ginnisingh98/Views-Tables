--------------------------------------------------------
--  DDL for Package BEN_EFC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_INFO" AUTHID CURRENT_USER AS
/* $Header: benefinf.pkh 120.0 2005/05/28 04:17:39 appldev noship $ */
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
END ben_efc_info;

 

/
