--------------------------------------------------------
--  DDL for Package GCS_TRANS_HRATES_DYN_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_TRANS_HRATES_DYN_BUILD_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsxlthratesds.pls 120.2 2007/06/28 12:31:12 vkosuri noship $ */
--
-- Package
--   gcs_trans_hrates_dyn_build_pkg
-- Purpose
--   Dynamically created package procedures for the Translation Program
-- History
--   08-DEC-06      	sballepu   	Created
--
  --
  -- Procedure
  --   Create_Package
  -- Purpose
  --   Create the dynamic portion of the translation program for historical rates
  -- Example
  --   GCS_TRANS_HRATES_DYN_BUILD_PKG.g_Create_Package
  -- Notes
  --
  PROCEDURE Create_Package(
	x_errbuf	OUT NOCOPY	VARCHAR2,
	x_retcode	OUT NOCOPY	VARCHAR2);
END GCS_TRANS_HRATES_DYN_BUILD_PKG;


/
