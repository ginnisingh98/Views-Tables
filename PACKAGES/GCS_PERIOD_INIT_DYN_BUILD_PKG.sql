--------------------------------------------------------
--  DDL for Package GCS_PERIOD_INIT_DYN_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_PERIOD_INIT_DYN_BUILD_PKG" AUTHID CURRENT_USER AS
/* $Header: gcspinbs.pls 120.1 2005/10/30 05:16:21 appldev noship $ */
--
-- Package
--   gcs_period_init_dyn_build_pkg
-- Purpose
--   Package procedures for the Period Initialization Dynamic Build Program
-- History
--   04-MAR-04	T Cheng		Created
-- Notes
--   The package's main purpose is to create the package body of
--   gcs_period_init_dynamic_pkg.
--

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   create_package
  -- Purpose
  --   Create the package body of gcs_period_init_dynamic_pkg.
  -- Arguments
  --   * None *
  -- Example
  --   GCS_PERIOD_INIT_DYN_BUILD_PKG.create_package;
  -- Notes
  --
  PROCEDURE create_package;

END GCS_PERIOD_INIT_DYN_BUILD_PKG;

 

/
