--------------------------------------------------------
--  DDL for Package GCS_AGGREGATION_DYN_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_AGGREGATION_DYN_BUILD_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsaggbs.pls 120.1 2005/10/30 05:16:55 appldev noship $ */
--
-- Package
--   gcs_aggregation_dyn_build_pkg
-- Purpose
--   Package procedures for the Aggregation Dynamic Build Program
-- History
--   17-FEB-04	T Cheng		Created
-- Notes
--   The package's main purpose is to create the package body of
--   gcs_aggregation_dynamic_pkg.
--

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   create_package
  -- Purpose
  --   Create the package body of gcs_aggregation_dynamic_pkg.
  -- Arguments
  --   * None *
  -- Example
  --   GCS_AGGREGATION_DYN_BUILD_PKG.create_package;
  -- Notes
  --
  PROCEDURE create_package;

END GCS_AGGREGATION_DYN_BUILD_PKG;

 

/
