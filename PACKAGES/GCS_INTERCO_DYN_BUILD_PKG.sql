--------------------------------------------------------
--  DDL for Package GCS_INTERCO_DYN_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_INTERCO_DYN_BUILD_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsicdbs.pls 120.1 2005/10/30 05:18:40 appldev noship $ */

--
-- Package
--   gcs_interco_dyn_build_pkg
-- Purpose
--   Dynamically created package procedures for the Intercompnay Engine
-- History
--   12-APR-04	Srini Pala		Created
--


  --
  -- Procedure
  --   Interco_Create_Package
  -- Purpose
  --   Create the dynamic portion of the intercompany processing program
  -- Example
  --   GCS_INTERCO_DYN_BUILD_PKG.Interco_Create_Package
  -- Notes
  --
  PROCEDURE Interco_Create_Package(
	x_errbuf	OUT NOCOPY	VARCHAR2,
	x_retcode	OUT NOCOPY	VARCHAR2);

END GCS_INTERCO_DYN_BUILD_PKG;

 

/
