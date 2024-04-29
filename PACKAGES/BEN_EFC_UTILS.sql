--------------------------------------------------------
--  DDL for Package BEN_EFC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_UTILS" AUTHID CURRENT_USER AS
/* $Header: benefutl.pkh 120.0 2005/05/28 04:18:04 appldev noship $ */
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
END ben_efc_utils;

 

/
