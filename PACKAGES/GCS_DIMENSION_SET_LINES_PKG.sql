--------------------------------------------------------
--  DDL for Package GCS_DIMENSION_SET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DIMENSION_SET_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdmsls.pls 120.1 2005/10/30 05:17:32 appldev noship $ */
--
-- Package
--   gcs_dimension_set_lines_pkg
-- Purpose
--   Package procedures for the Dimension Set Lines Program
-- History
--   29-MAR-04	T Cheng		Created
--

  --
  -- PUBLIC GLOBAL VARIABLES
  --

  -- Holds fnd_global.user_id and login_id
  g_fnd_user_id		NUMBER;
  g_fnd_login_id	NUMBER;

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   Assign_Dimension_Combinations
  -- Purpose
  --
  -- Arguments
  --   p_dimension_set_id	Id of the dimension member set
  -- Example
  --   GCS_DIMENSION_SET_LINES_PKG.Assign_Dimension_Combinations
  --                                 (errbuf, retcode, 111);
  -- Notes
  --
  PROCEDURE Assign_Dimension_Combinations(
    p_errbuf           OUT NOCOPY VARCHAR2,
    p_retcode          OUT NOCOPY VARCHAR2,
    p_dimension_set_id NUMBER);

END GCS_DIMENSION_SET_LINES_PKG;

 

/
